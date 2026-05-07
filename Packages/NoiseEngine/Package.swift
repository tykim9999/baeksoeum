// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NoiseEngine",
    platforms: [.iOS(.v18), .tvOS(.v18), .macOS(.v14)],
    products: [
        .library(name: "NoiseEngine", targets: ["NoiseEngine"]),
    ],
    targets: [
        .target(name: "NoiseEngine"),
        .testTarget(name: "NoiseEngineTests", dependencies: ["NoiseEngine"]),
    ]
)
