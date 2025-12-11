#!/bin/bash -e

# Build script for the Cactus framework

echo "🔧 Building Cactus framework..."

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACTUS_DIR="$SCRIPT_DIR/ios/External/swift-cactus"
OUTPUT_DIR="$SCRIPT_DIR/ios/Frameworks"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Build the Cactus framework using SPM
echo "📦 Building Cactus framework with SPM..."

# Build for iOS device
echo "▶️  Building for iOS device..."
swift build --package-path "$CACTUS_DIR" -c release -Xswiftc "-sdk" -Xswiftc "$(xcrun --sdk iphoneos --show-sdk-path)" -Xswiftc "-target" -Xswiftc "arm64-apple-ios13.0" -Xswiftc "-emit-library" -Xswiftc "-static"

# Build for iOS simulator
echo "▶️  Building for iOS simulator..."
swift build --package-path "$CACTUS_DIR" -c release -Xswiftc "-sdk" -Xswiftc "$(xcrun --sdk iphonesimulator --show-sdk-path)" -Xswiftc "-target" -Xswiftc "arm64-apple-ios13.0-simulator" -Xswiftc "-emit-library" -Xswiftc "-static"

# Create a simple framework structure
# Note: This is a simplified approach - for production use, we'd need to properly create an XCFramework

echo "✅ Cactus framework built successfully!"
echo "📁 The Cactus framework has been built using SPM."
echo "📝 Please refer to the integration guide for manual linking instructions."
