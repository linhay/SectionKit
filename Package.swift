// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SectionKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "SectionKit", targets: ["SectionKit"]),
        .library(name: "SectionUI", targets: ["SectionUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(name: "SectionKit", exclude: ["AGENTS.md"]),
        .target(name: "SectionUI", dependencies: ["SectionKit"], exclude: ["AGENTS.md", "Beta"]),
        .testTarget(
            name: "SectionKitTests",
            dependencies: ["SectionKit", "SectionUI"]
        ),
    ]
)
