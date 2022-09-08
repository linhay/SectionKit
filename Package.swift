// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SectionKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "SectionKit", targets: ["SectionKit"]),
        .library(name: "SectionUI", targets: ["SectionUI"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "SectionKit"),
        .target(name: "SectionUI", dependencies: ["SectionKit"]),
        .testTarget(
            name: "SectionKitTests",
            dependencies: ["SectionUI"]
        ),
    ]
)
