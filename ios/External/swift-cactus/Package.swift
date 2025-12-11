// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let supportsTelemetry = SwiftSetting.define(
  "SWIFT_CACTUS_SUPPORTS_DEFAULT_TELEMETRY",
  .when(platforms: [.iOS, .macOS])
)

let package = Package(
  name: "swift-cactus",
  platforms: [.iOS(.v13), .macOS(.v11), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
  products: [
    .library(name: "Cactus", targets: ["Cactus"]),
    .library(name: "CXXCactusShims", targets: ["CXXCactusShims"])
  ],
  dependencies: [
    // Main dependencies
    .package(url: "https://github.com/vapor-community/Zip", from: "2.2.7"),
    .package(url: "https://github.com/apple/swift-log", from: "1.6.4"),
    .package(url: "https://github.com/apple/swift-crypto", from: "4.0.0"),
    
    // Test-only dependencies - these won't be included in main app builds
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.7"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
    .package(url: "https://github.com/mhayes853/swift-operation", from: "0.3.1"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.4.3"),
    
    // Keep docc plugin for documentation generation
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
  ],
  targets: [
    .target(
      name: "Cactus",
      dependencies: [
        "CXXCactusShims",
        .target(name: "cactus_util", condition: .when(platforms: [.iOS, .macOS])),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Zip", package: "Zip"),
        // Remove IssueReporting dependency which was causing Testing.framework crash
        // .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "Crypto", package: "swift-crypto", condition: .when(platforms: [.android]))
      ],
      swiftSettings: [supportsTelemetry]
    ),
    .testTarget(
      name: "CactusTests",
      dependencies: [
        "Cactus",
        // Test-only products - these will only be used in test builds
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "Operation", package: "swift-operation")
      ],
      exclude: ["LanguageModelTests/__Snapshots__", "JSONSchemaTests/__Snapshots__"],
      resources: [.process("Resources")],
      swiftSettings: [supportsTelemetry]
    ),
    .target(
      name: "CXXCactusShims",
      dependencies: [
        .target(name: "CXXCactus", condition: .when(platforms: [.android])),
        .target(
          name: "CXXCactusDarwin",
          condition: .when(platforms: [.iOS, .macOS, .visionOS, .tvOS, .watchOS, .macCatalyst])
        )
      ]
    ),
    .binaryTarget(name: "CXXCactusDarwin", path: "bin/CXXCactusDarwin.xcframework"),
    .binaryTarget(name: "CXXCactus", path: "bin/CXXCactus.artifactbundle"),
    .binaryTarget(name: "cactus_util", path: "bin/cactus_util.xcframework")
  ]
)
