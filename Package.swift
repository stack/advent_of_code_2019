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
            name: "Day01",
            dependencies: ["Utilities"]),
        .target(
            name: "Day02",
            dependencies: ["Utilities"]),
        .target(
            name: "Day03",
            dependencies: ["Utilities"]),
        .target(
            name: "Day04",
            dependencies: ["Utilities"]),
        .target(
            name: "Day05",
            dependencies: ["Utilities"]),
        .target(
            name: "Day06",
            dependencies: ["Utilities"]),
        .target(
            name: "Day07",
            dependencies: ["Utilities"]),
        .target(
            name: "Day08",
            dependencies: ["Utilities"]),
        .target(
            name: "Day09",
            dependencies: ["Utilities"]),
        .target(
            name: "Day10",
            dependencies: ["Utilities"]),
        .target(
            name: "Day11",
            dependencies: ["Utilities"]),
        .target(
            name: "Day12",
            dependencies: ["Utilities"]),
        .target(
            name: "Day13",
            dependencies: ["Utilities"]),
        .target(
            name: "Day14",
            dependencies: ["Utilities"]),
        .target(
            name: "Day15",
            dependencies: ["Utilities"]),
        .target(
            name: "Day16",
            dependencies: ["Utilities"]),
        .target(
            name: "Day17",
            dependencies: ["Utilities"]),
        .target(
            name: "Day18",
            dependencies: ["Utilities"]),
        .target(
            name: "Day19",
            dependencies: ["Utilities"]),
        .target(
            name: "Utilities",
            dependencies: []),
        .testTarget(
            name: "UtilitiesTests",
            dependencies: ["Utilities"])
    ]
)
