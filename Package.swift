// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "VEXA",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        .library(name: "Protobuf", targets: ["Protobuf"])
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/queues.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.0-rc.1"),
        .package(url: "https://github.com/GetStream/stream-chat-vapor-swift.git", from: "0.1.0"),

        // Mailgun
        .package(url: "https://github.com/vapor-community/mailgun.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "Protobuf", dependencies: [
            .product(name: "SwiftProtobuf", package: "swift-protobuf")
        ]),
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
                .product(name: "Mailgun", package: "mailgun"),
                .product(name: "StreamSDKVapor", package: "stream-chat-vapor-swift"),
                "Protobuf"
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
