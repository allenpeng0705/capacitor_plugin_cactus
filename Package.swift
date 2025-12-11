// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CapacitorPluginCactus",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorPluginCactus",
            targets: ["CactusPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0"),
        // Add swift-cactus as a dependency, but we'll exclude test-only dependencies
        .package(path: "./ios/External/swift-cactus")
    ],
    targets: [
        .target(
            name: "CactusPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                // Add the Cactus product, which should not include test dependencies
                .product(name: "Cactus", package: "swift-cactus", condition: .when(platforms: [.iOS]))
            ],
            path: "ios/Sources/CactusPlugin"),
        .testTarget(
            name: "CactusPluginTests",
            dependencies: ["CactusPlugin"],
            path: "ios/Tests/CactusPluginTests")
    ]
)