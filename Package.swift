// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Homework",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MyParser",
            type: .dynamic,
            targets: ["MyParser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.8.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.1"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MyParser",
            dependencies: ["SwiftCSV"]),
        .testTarget(
            name: "MyParserTests",
            dependencies: ["MyParser"]),
        .executableTarget(
            name: "homework",
            dependencies: [
                "MyParser",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log")
            ])
    ]
)
