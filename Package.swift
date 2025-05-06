// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftIGRF",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "IGRFCore",
            targets: ["IGRFCore"]
        ),
        .executable(
            name: "igrf",
            targets: ["IGRFCLI"]
        ),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IGRFCore",
            dependencies: [],
            path: "Sources/Core",
            resources: [
                .process("Resources/SHC_files")
            ]
        ),
        .executableTarget(
            name: "IGRFCLI",
            dependencies: ["IGRFCore"],
            path: "Sources/CLI"
        ),
        .testTarget(
            name: "IGRFCLITests",
            dependencies: ["IGRFCLI", "IGRFCore"],
            path: "Tests/IGRFCLITests",
            resources: [
                .process("TestData")
            ]
        ),
    ]
)
