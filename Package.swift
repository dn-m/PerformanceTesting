// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PerformanceTesting",
    products: [
        .library(name: "PerformanceTesting", targets: ["PerformanceTesting"]),
    ],
    targets: [
        .target(name: "PerformanceTesting"),
        .testTarget(name: "PerformanceTestingTests", dependencies: ["PerformanceTesting"])
    ]
)
