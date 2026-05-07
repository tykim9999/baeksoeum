# 백색소음 — 개인정보 처리방침 (Privacy Policy)

Last updated: 2026-05-07

본 방침은 한국 「개인정보 보호법」(PIPA) 및 Apple App Store의 App Privacy 요구사항을 따릅니다.
This policy complies with Korea's Personal Information Protection Act (PIPA) and Apple's App Store privacy requirements.

---

## 한국어

### 1. 수집하는 개인정보

**없음.** 백색소음은 다음을 수집하지 않습니다:

- 이름, 이메일, 전화번호 등 개인 식별 정보
- 위치 정보
- 광고 식별자 (IDFA)
- 사용 분석 데이터
- 충돌 보고서 (crash report)
- 기기 식별자
- 마이크 또는 카메라 입력

### 2. 사용자가 입력한 데이터

다음 데이터는 사용자가 직접 입력하며, **사용자의 기기에만 저장**됩니다:

- 아기 이름과 생년월일 (선택사항)
- 잠 기록 (시작/종료 시각)
- 잠자리 루틴 단계 및 연속 일수
- 마지막으로 선택한 사운드와 볼륨 (다음 실행 시 복원용)

이 데이터는 SwiftData를 통해 기기 내부 저장소(iOS의 Application Support 디렉터리)에 저장되며, 외부 서버로 전송되지 않습니다.

### 3. iCloud 동기화

iCloud 동기화 기능을 활성화하면 (선택사항), 위 데이터는 사용자의 **개인 iCloud 컨테이너**에 동기화되어 사용자의 다른 Apple 기기 (iPhone, iPad, Apple TV) 사이에서 공유됩니다.

- 데이터는 Apple의 CloudKit Private Database에 저장됩니다
- 다른 사용자나 본 앱 개발자는 이 데이터에 접근할 수 없습니다
- Apple은 이 데이터를 분석하거나 광고에 사용하지 않습니다
- iCloud 계정 설정에서 언제든 비활성화하거나 삭제할 수 있습니다

### 4. 제3자 제공

본 앱은 **제3자 SDK를 사용하지 않습니다.** 광고 네트워크, 분석 플랫폼, 소셜 로그인, 광고 추적 라이브러리가 포함되어 있지 않습니다.

### 5. 어린이 데이터

본 앱은 4+ 등급으로 영유아의 부모/보호자가 사용하는 것을 전제로 합니다. 아기에 관한 데이터(이름, 생년월일)는 보호자가 직접 입력하며, 위에서 설명한 대로 기기 내부에만 저장됩니다.

### 6. 데이터 보관 및 삭제

- 모든 데이터는 사용자 기기에 보관됩니다
- 앱을 삭제하면 기기 내 데이터는 함께 삭제됩니다
- iCloud 동기화 활성 시: iCloud 계정 설정 → 저장공간 → 백색소음에서 삭제 가능

### 7. 개인정보 보호 책임자

| 항목 | 내용 |
|------|------|
| 이름 | tykim |
| 이메일 | dev.main.datalabs@gmail.com |
| 처리 위탁 | 없음 |
| 국외 이전 | 없음 (iCloud는 사용자의 Apple 계정 설정을 따름) |

### 8. 본 방침의 변경

본 방침이 변경될 경우, 앱 업데이트 시 GitHub 저장소를 통해 공지합니다. 중대한 변경 시 앱 내에서도 알립니다.

---

## English

### 1. Personal information collected

**None.** BaekSoeum does not collect:

- Names, emails, phone numbers, or any personal identifiers
- Location data
- Advertising identifiers (IDFA)
- Usage analytics
- Crash reports
- Device identifiers
- Microphone or camera input

### 2. User-entered data

The following is entered by the user and **stored only on the device**:

- Baby's name and birthdate (optional)
- Sleep events (start / end timestamps)
- Bedtime routine steps and streak count
- Last selected sound and volume (restored on next launch)

Data is stored in the device's local storage via SwiftData (iOS Application Support directory). It is not sent to any external server.

### 3. iCloud sync

If iCloud sync is enabled (optional), the above data is synced to the user's **private iCloud container** and shared across the user's own Apple devices (iPhone, iPad, Apple TV).

- Stored in Apple's CloudKit Private Database
- No other users and not the app developer can access this data
- Apple does not analyze it or use it for advertising
- Can be disabled or deleted at any time via the user's iCloud account settings

### 4. Third parties

The app uses **no third-party SDKs.** No ad networks, analytics platforms, social logins, or ad-tracking libraries are included.

### 5. Children's data

This app is rated 4+ and is intended for use by parents/guardians of infants. Data about the baby (name, birthdate) is entered by the parent/guardian and stored on-device as described above.

### 6. Data retention and deletion

- All data is retained on the user's device
- Deleting the app removes all on-device data
- iCloud-synced data: delete via iCloud Account Settings → Storage → BaekSoeum

### 7. Contact

| Field | Value |
|-------|-------|
| Name | tykim |
| Email | dev.main.datalabs@gmail.com |
| Data processing delegation | None |
| International transfers | None (iCloud follows the user's Apple account settings) |

### 8. Policy changes

If this policy changes, we will announce it via the GitHub repository on app update. Material changes will also be announced inside the app.

---

## Apple App Store — App Privacy Questionnaire pre-fill

For App Store Connect's privacy declaration page, the answers are:

| Question | Answer |
|----------|--------|
| Does your app collect data? | **No** |
| Does the app use third-party tracking? | **No** |
| Data Used to Track You | **None** |
| Data Linked to You | **None** |
| Data Not Linked to You | **None** |

The user-entered data (baby info, sleep log, routine) is **not "collected"** in App Store privacy terms because it never leaves the user's iCloud Private Database (which is treated by Apple as user-controlled storage equivalent to local device storage).
