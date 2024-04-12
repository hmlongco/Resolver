// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Resolver",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_14),
        .tvOS(.v13),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Resolver",
            targets: ["Resolver"]
        ),
        .library(
            name: "Resolver-Static",
            type: .static,
            targets: ["Resolver"]
        ),
        .library(
            name: "Resolver-Dynamic",
            type: .dynamic,
            targets: ["Resolver"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Resolver",
            dependencies: [],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "ResolverTests",
            dependencies: ["Resolver"]
        ),
    ]
)
