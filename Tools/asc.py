#!/usr/bin/env -S uv run --with pyjwt --with requests --quiet python3
"""
App Store Connect API thin client.

Reads credentials from environment:
  ASC_KEY_ID       — 10-char Key ID
  ASC_ISSUER_ID    — UUID issuer ID (visible at the top of the Keys page)
  ASC_KEY_PATH     — path to the .p8 private key file

Generate the key once at:
  https://appstoreconnect.apple.com/access/integrations/api
  → Keys → ⊕ → Access: App Manager → Generate
  → Download the .p8 file (only chance — Apple won't re-show it)

Usage:
  ./Tools/asc.py builds                    # list recent builds
  ./Tools/asc.py builds <bundle_id>        # filter by bundle id
  ./Tools/asc.py apps                      # list your apps
  ./Tools/asc.py testers                   # list internal testers
  ./Tools/asc.py invite <bundle_id> <email> [<first> <last>]
"""

from __future__ import annotations

import datetime as dt
import json
import os
import sys
import time
from pathlib import Path

try:
    import jwt
    import requests
except ImportError as e:
    print(f"missing dependency: {e}; run via 'uv run --with pyjwt --with requests'", file=sys.stderr)
    sys.exit(1)

API = "https://api.appstoreconnect.apple.com/v1"


def make_token() -> str:
    key_id = os.environ.get("ASC_KEY_ID")
    issuer = os.environ.get("ASC_ISSUER_ID")
    key_path = os.environ.get("ASC_KEY_PATH")
    if not key_id or not issuer or not key_path:
        print("set ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH (see file header)", file=sys.stderr)
        sys.exit(2)
    if not Path(key_path).expanduser().exists():
        print(f"key file not found: {key_path}", file=sys.stderr)
        sys.exit(2)
    private_key = Path(key_path).expanduser().read_text()
    now = int(time.time())
    payload = {
        "iss": issuer,
        "iat": now,
        "exp": now + 60 * 15,    # max 20 min per Apple
        "aud": "appstoreconnect-v1",
    }
    return jwt.encode(payload, private_key, algorithm="ES256", headers={"kid": key_id, "typ": "JWT"})


def auth_headers() -> dict[str, str]:
    return {"Authorization": f"Bearer {make_token()}"}


def get(path: str, params: dict | None = None) -> dict:
    r = requests.get(f"{API}{path}", headers=auth_headers(), params=params, timeout=30)
    if r.status_code >= 400:
        print(f"HTTP {r.status_code}: {r.text}", file=sys.stderr)
        sys.exit(1)
    return r.json()


def post(path: str, body: dict) -> dict:
    r = requests.post(f"{API}{path}", headers={**auth_headers(), "Content-Type": "application/json"},
                      json=body, timeout=30)
    if r.status_code >= 400:
        print(f"HTTP {r.status_code}: {r.text}", file=sys.stderr)
        sys.exit(1)
    return r.json()


def cmd_apps():
    data = get("/apps", {"limit": 50, "fields[apps]": "name,bundleId"})
    for app in data.get("data", []):
        attr = app.get("attributes", {})
        print(f"  {app['id']:15s}  {attr.get('bundleId',''):40s}  {attr.get('name','')}")


def cmd_builds(bundle_id: str | None = None):
    params: dict[str, str | int] = {
        "limit": 20,
        "sort": "-uploadedDate",
        "fields[builds]": "version,uploadedDate,processingState,expired,minOsVersion",
    }
    if bundle_id:
        # Filter by app via the app's id
        apps = get("/apps", {"filter[bundleId]": bundle_id, "limit": 1})
        if not apps.get("data"):
            print(f"no app found for bundle id {bundle_id}", file=sys.stderr)
            sys.exit(1)
        app_id = apps["data"][0]["id"]
        params["filter[app]"] = app_id

    data = get("/builds", params)
    print(f"  {'version':10s}  {'state':18s}  {'uploaded':19s}  expired")
    print(f"  {'-'*10}  {'-'*18}  {'-'*19}  {'-'*7}")
    for b in data.get("data", []):
        a = b.get("attributes", {})
        uploaded = a.get("uploadedDate", "")[:19].replace("T", " ")
        print(f"  {a.get('version','?'):10s}  {a.get('processingState','?'):18s}  {uploaded:19s}  {a.get('expired')}")


def cmd_testers():
    data = get("/betaTesters", {"limit": 50, "fields[betaTesters]": "firstName,lastName,email,inviteType"})
    for t in data.get("data", []):
        a = t.get("attributes", {})
        name = f"{a.get('firstName','')} {a.get('lastName','')}".strip()
        print(f"  {a.get('email','?'):40s}  {a.get('inviteType','?'):10s}  {name}")


def cmd_invite(bundle_id: str, email: str, first: str = "", last: str = ""):
    apps = get("/apps", {"filter[bundleId]": bundle_id, "limit": 1})
    if not apps.get("data"):
        print(f"no app found for bundle id {bundle_id}", file=sys.stderr)
        sys.exit(1)
    app_id = apps["data"][0]["id"]

    # First try to find or create a default Internal Testing group, then add tester
    groups = get(f"/apps/{app_id}/betaGroups", {"filter[isInternalGroup]": "true", "limit": 5})
    if not groups.get("data"):
        print("no internal group found; create one in App Store Connect first", file=sys.stderr)
        sys.exit(1)
    group_id = groups["data"][0]["id"]

    body = {
        "data": {
            "type": "betaTesters",
            "attributes": {
                "email": email,
                "firstName": first,
                "lastName": last,
            },
            "relationships": {
                "betaGroups": {
                    "data": [{"type": "betaGroups", "id": group_id}]
                }
            }
        }
    }
    result = post("/betaTesters", body)
    print(f"  invited: {email} (id {result['data']['id']})")


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return
    cmd = args[0]
    rest = args[1:]
    if cmd == "apps":            cmd_apps()
    elif cmd == "builds":        cmd_builds(rest[0] if rest else None)
    elif cmd == "testers":       cmd_testers()
    elif cmd == "invite":
        if len(rest) < 2:
            print("usage: invite <bundle_id> <email> [<first> <last>]", file=sys.stderr); sys.exit(2)
        cmd_invite(*rest)
    else:
        print(__doc__); sys.exit(2)


if __name__ == "__main__":
    main()
