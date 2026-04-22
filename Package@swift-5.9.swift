// swift-tools-version: 5.9
// Legacy manifest for Swift 5.x toolchains.

import PackageDescription

let package = Package(
    name: "LMStudioKit",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(
            name: "LMStudioKit",
            targets: ["LMStudioKit"]
        ),
    ],
    targets: [
        .target(
            name: "LMStudioKit"
        ),
        .testTarget(
            name: "LMStudioKitTests",
            dependencies: [
                "LMStudioKit",
                .product(name: "Testing", package: "swift-testing")
            ]
        ),
    ]
)
