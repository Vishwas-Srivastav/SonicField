// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "SonicField",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "SonicField",
            targets: ["SonicField"]
        ),
        .library(
            name: "SonicFieldKit",
            targets: ["SonicFieldKit"]
        )
    ],
    targets: [
        .target(
            name: "SonicFieldKit",
            dependencies: [],
            path: "Sources/SonicFieldKit"
        ),
        .executableTarget(
            name: "SonicField",
            dependencies: ["SonicFieldKit"],
            path: "Sources/SonicFieldApp"
        ),
        .testTarget(
            name: "SonicFieldTests",
            dependencies: ["SonicFieldKit"],
            path: "Tests/SonicFieldTests"
        )
    ]
)
