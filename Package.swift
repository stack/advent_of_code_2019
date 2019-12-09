// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "advent_of_code_2019",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "01",
            dependencies: ["Utilities"]),
        .target(
            name: "02",
            dependencies: ["Utilities"]),
        .target(
            name: "03",
            dependencies: ["Utilities"]),
        .target(
            name: "04",
            dependencies: ["Utilities"]),
        .target(
            name: "05",
            dependencies: ["Utilities"]),
        .target(
            name: "06",
            dependencies: ["Utilities"]),
        .target(
            name: "07",
            dependencies: ["Utilities"]),
        .target(
            name: "08",
            dependencies: ["Utilities"]),
        .target(
            name: "09",
            dependencies: ["Utilities"]),
        .target(
            name: "Utilities",
            dependencies: [])
    ]
)
