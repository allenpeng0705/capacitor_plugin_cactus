# Testing Real Model Download for Cactus Plugin

This document provides instructions to verify that the Cactus plugin is downloading real models from the Cactus SDK rather than using mock data.

## Key Changes Made

I've added comprehensive logging to both Android and iOS implementations to verify real model downloads:

### Android Implementation (CactusCap.java)
- Added logging to check if model already exists before download
- Added logging to show existing model files and sizes
- Added download time measurement
- Added logging to show final model files and sizes

### iOS Implementation (CactusCap.swift)
- Added logging to check if model already exists before download
- Added logging to show existing model files and sizes
- Added download time measurement
- Added logging to show final model files and sizes

## How to Verify Real Model Downloads

### 1. Android Platform

#### Step 1: Check Logs from Device
```bash
# Get the list of connected devices
/Users/shileipeng/Library/Android/sdk/platform-tools/adb devices

# Monitor Cactus-specific logs (replace emulator-5554 with your device ID)
/Users/shileipeng/Library/Android/sdk/platform-tools/adb -s emulator-5554 logcat -v time | grep -i "cactus"
```

#### Expected Log Output
You should see logs like:
```
I/Cactus: Android: Downloading model with slug: qwen3-0.6
I/Cactus: Android: Model already exists: false
I/Cactus: Android: Model not found, starting download...
I/Cactus: Android: Model download completed in 12345 ms
I/Cactus: Android: Final model files: 5
I/Cactus: Android: Final file: config.json (1234 bytes)
I/Cactus: Android: Final file: weights.bin (589000000 bytes)
...
```

#### Step 2: Verify Model Files Exist
```bash
# Access the device shell
/Users/shileipeng/Library/Android/sdk/platform-tools/adb -s emulator-5554 shell

# Check model files
cd /data/data/com.tripwiki.example/files/cactus/models/qwen3-0.6
ls -la
```

### 2. iOS Platform

#### Step 1: Run the App with Xcode Debugger
1. Open the project in Xcode:
   ```bash
   open /Users/shileipeng/Documents/react_native/capacitor_plugin/capacitor-plugin-cactus/example-app/ios/App/App.xcworkspace
   ```

2. Run the app on a device or simulator
3. Open the Console in Xcode (View → Debug Area → Activate Console)
4. Filter logs by "Cactus"

#### Expected Log Output
You should see logs like:
```
ios: Model already exists at /Users/user/Library/Developer/CoreSimulator/Devices/.../cactus/models/qwen3-0.6: false
ios: Model not found, starting download...
Download progress: 10.5%
Download progress: 25.3%
...
Model download completed successfully in 15678 ms
Final model path: /Users/user/Library/Developer/CoreSimulator/Devices/.../cactus/models/qwen3-0.6
ios: Final model files count: 5
nios: Final file: config.json (1234 bytes)
ios: Final file: weights.bin (589000000 bytes)
```

### 3. Web Platform (Development Only)

Note: The web platform continues to use mock data for development purposes. This is clearly indicated in the code:

```javascript
// In src/web.ts
public async downloadModel(options: { modelSlug?: string; }): Promise<{ success: boolean; modelPath: string; }> {
  // Mock implementation for web
  return {
    success: true,
    modelPath: '/mock/path/to/qwen3-0.6'
  };
}
```

## Troubleshooting

### Model Download Too Fast
If the download seems too fast, it's likely because:
1. The model is already downloaded and cached on the device/emulator
2. Emulators have fast downloads since files are transferred within the same machine
3. The `qwen3-0.6` model is relatively small (~600MB)

To verify a fresh download:
- On Android: Delete the model directory and try again
  ```bash
  adb -s emulator-5554 shell rm -rf /data/data/com.tripwiki.example/files/cactus/models/qwen3-0.6
  ```

- On iOS: Delete the app and reinstall it, or use the Xcode console to monitor the download progress

## Verification Summary

The Cactus plugin is now properly configured to:
1. Use the real Cactus SDK for model downloads on Android and iOS
2. Provide detailed logging to verify real model downloads
3. Clearly separate mock web implementation for development purposes
4. Download actual model files that can be verified on the device

When you run the app and initiate a model download, you should now see the real download process with proper timing and file verification.