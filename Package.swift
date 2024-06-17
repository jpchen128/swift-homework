// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Homework",
    products: [
        .library(
            name: "MyParser",
            targets: ["MyParser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.8.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.1"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
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
            ],
            path: "Sources/Homework"
        ),
        .executableTarget(
            name: "streaming",
            dependencies: [
                "MyParser",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ],
            path: "Sources/Streaming"
        ),
        .executableTarget(
            name: "microservice",
            dependencies: [
                "MyParser",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Vapor", package: "vapor")
            ],
            path: "Sources/MicroService"
        )
    ]
)
