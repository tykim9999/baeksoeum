// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RenderIcon",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "RenderIcon"),
    ]
)
