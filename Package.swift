// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftIGRF",
    products: [
        .executable(name: "igrf", targets: ["IGRFCLI"])
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "IGRFCLI",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "IGRFCLITests",
            dependencies: ["IGRFCLI"],
            path: "Tests/IGRFCLITests",
            resources: [
                .process("TestData")
            ]
        ),
    ]
)
