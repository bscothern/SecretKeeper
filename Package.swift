// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SecretKeeper",
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", .exact("0.5.0")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "SecretKeeper",
            dependencies: [
                "SPMUtility", "Yams",
            ]
        ),
        .testTarget(
            name: "SecretKeeperTests",
            dependencies: ["SecretKeeper"]
        ),
    ]
)
