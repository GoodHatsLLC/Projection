// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Projection",
    platforms: [.macOS(.v10_15), .iOS(.v14)],
    products: [
        .library(
            name: "Projection",
            targets: ["Projection"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/GoodHatsLLC/Bimapping.git", .upToNextMajor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "Projection",
            dependencies: [
                "Bimapping"
            ]
        ),
        .testTarget(
            name: "ProjectionTests",
            dependencies: ["Projection"]
        ),
    ]
)
