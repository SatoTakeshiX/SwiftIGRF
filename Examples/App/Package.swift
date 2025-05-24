// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppExample",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "IGRFApp", targets: ["IGRFApp"])
    ],
    dependencies: [
        .package(path: "../../")  // SwiftIGRFパッケージへの相対パス
    ],
    targets: [
        .target(
            name: "IGRFApp",
            dependencies: [
                .product(name: "IGRFClient", package: "SwiftIGRF")
            ]
        )
    ]
)
