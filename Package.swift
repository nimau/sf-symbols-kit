// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SFSymbolsKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SFSymbolsKit",
            targets: ["SFSymbolsKit"]
        ),
    ],
    targets: [
        .target(
            name: "SFSymbolsKit",
            path: "Sources/SFSymbolsKit"
        ),
        .testTarget(
            name: "SFSymbolsKitTests",
            dependencies: ["SFSymbolsKit"]
        ),
    ]
)
