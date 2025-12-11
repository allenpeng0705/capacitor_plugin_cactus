#!/bin/bash -e

# Setup script for the Cactus Capacitor plugin

echo "🔧 Setting up Cactus Capacitor plugin..."

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACTUS_DIR="$SCRIPT_DIR/ios/External/swift-cactus"
OUTPUT_DIR="$SCRIPT_DIR/ios/Frameworks"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to build the Cactus framework using SPM
build_cactus_framework() {
    echo "📦 Building Cactus framework with Swift Package Manager..."
    
    # Navigate to the swift-cactus directory
    cd "$CACTUS_DIR"
    
    # Build the Cactus framework for iOS device
    echo "▶️  Building for iOS device..."
    swift build --configuration release --arch arm64 -Xswiftc "-sdk" -Xswiftc "$(xcrun --sdk iphoneos --show-sdk-path)" -Xswiftc "-target" -Xswiftc "arm64-apple-ios13.0"
    
    # Build the Cactus framework for iOS simulator
    echo "▶️  Building for iOS simulator..."
    swift build --configuration release --arch arm64 -Xswiftc "-sdk" -Xswiftc "$(xcrun --sdk iphonesimulator --show-sdk-path)" -Xswiftc "-target" -Xswiftc "arm64-apple-ios13.0-simulator"
    
    # Return to the original directory
    cd "$SCRIPT_DIR"
    
    echo "✅ Cactus framework built successfully!"
    echo "📝 Next steps:"
    echo "1. Open your Xcode project"
    echo "2. Add the built Cactus framework to your project"
    echo "3. Add CXXCactusDarwin.xcframework and cactus_util.xcframework from ios/External/swift-cactus/bin"
    echo "4. Build and run your app"
}

# Function to install dependencies
install_dependencies() {
    echo "📦 Installing Node.js dependencies..."
    npm install
    echo "✅ Node.js dependencies installed!"
}

# Function to build the plugin
build_plugin() {
    echo "🔧 Building Capacitor plugin..."
    npm run build
    echo "✅ Plugin built successfully!"
}

# Main menu
show_menu() {
    echo "====================================="
    echo "   Cactus Capacitor Plugin Setup"
    echo "====================================="
    echo "1. Build Cactus framework"
    echo "2. Install dependencies"
    echo "3. Build plugin"
    echo "4. Run all setup steps"
    echo "5. Exit"
    echo "====================================="
    read -p "Select an option: " choice
    
    case $choice in
        1) build_cactus_framework ;;
        2) install_dependencies ;;
        3) build_plugin ;;
        4) 
            install_dependencies
            build_cactus_framework
            build_plugin
            ;;
        5) exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
}

# Run the menu
show_menu
