// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LullabyEngine",
    platforms: [.iOS(.v18), .tvOS(.v18), .macOS(.v14)],
    products: [
        .library(name: "LullabyEngine", targets: ["LullabyEngine"]),
    ],
    targets: [
        .target(name: "LullabyEngine"),
        .testTarget(name: "LullabyEngineTests", dependencies: ["LullabyEngine"]),
    ]
)
