// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SectionKit",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(name: "SectionKit", targets: ["SectionKit"]),
        .library(name: "SectionUI", targets: ["SectionUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(name: "SectionKit",
                path: "SectionKit"),
        .target(name: "SectionUI",
                dependencies: ["SectionKit"],
                path: "SectionUI")
    ]
)
