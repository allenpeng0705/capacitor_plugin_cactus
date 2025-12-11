# Cactus Capacitor Plugin Integration Guide

This guide explains how to integrate the Cactus Capacitor plugin into your Capacitor project.

## Table of Contents

- [Installation](#installation)
- [iOS Setup](#ios-setup)
- [Android Setup](#android-setup)
- [Plugin Usage](#plugin-usage)
  - [Model Management](#model-management)
  - [Chat Completion](#chat-completion)
  - [Audio Transcription](#audio-transcription)
  - [Embeddings](#embeddings)
  - [Local Model Loading](#local-model-loading)
- [API Reference](#api-reference)
- [Example App](#example-app)

## Installation

### From Local Directory (Development)
1. **Install the plugin from local directory**:   
   ```bash
   npm install /path/to/capacitor-plugin-cactus
   ```

2. **Sync the plugin with your project**:   
   ```bash
   npx cap sync
   ```

### From npm (Production)
1. **Install the plugin from npm**:   
   ```bash
   npm install capacitor-plugin-cactus
   ```

2. **Sync the plugin with your project**:   
   ```bash
   npx cap sync
   ```

## iOS Setup

### Automatic Integration (Recommended)

The plugin includes all necessary dependencies and configuration automatically. After running `npx cap sync`, the following components are automatically set up:

1. **Source Files**: The Cactus SDK source files are included directly in the plugin through CocoaPods
2. **Dependencies**: Required frameworks (`CXXCactusDarwin.xcframework`, `cactus_util.xcframework`) and libraries (`Zip`) are automatically included
3. **Configuration**: No additional Xcode configuration is needed

### Manual Integration (Advanced)

If you need to manually configure the dependencies, follow these steps:

#### 1. Add Cactus SDK Source Files

1. Open your project in Xcode
2. Navigate to the `ios/External/swift-cactus` directory in the plugin
3. Drag and drop the source files into your Xcode project
4. Ensure "Copy items if needed" is unchecked
5. Add the files to your plugin target

#### 2. Configure Required Frameworks

Add the following frameworks to your Xcode project:

- `CXXCactusDarwin.xcframework` (located in `ios/External/CXXCactusDarwin.xcframework`)
- `cactus_util.xcframework` (located in `ios/External/cactus_util.xcframework`)

#### 3. Integrate Zip Library

The plugin uses the `Zip` library for handling compressed model files. This is automatically added via CocoaPods, but if you need to add it manually:

1. Add the Zip library to your project:
   ```bash
   pod 'Zip', '~> 2.1.3'
   ```
2. Run `pod install`
3. Ensure the Zip library is correctly linked in your Xcode project

#### 4. Build Settings Configuration

Make sure the following build settings are configured correctly:

- **iOS Deployment Target**: 15.0 or later
- **Swift Language Version**: 5.5 or later
- **Framework Search Paths**: Include paths to the Cactus SDK frameworks
- **Library Search Paths**: Include paths to any additional libraries

### Important Notes
- The plugin requires iOS 15.0 or later
- Ensure your project is using Swift 5.5 or later
- If you encounter build errors, check the "Link Binary With Libraries" section in Xcode to ensure all dependencies are correctly linked
- For issues with the Zip library, verify that the `unzipFile` method calls include the optional `password` parameter

## Android Setup

### Automatic Integration (Recommended)

The plugin automatically adds the Cactus SDK dependency to your Android project via Maven Central and configures the necessary permissions.

### Manual Integration (Advanced)

#### 1. Maven Central Dependency

1. Open your project's `build.gradle` file (at the project root)
2. Ensure Maven Central is added as a repository:
   ```gradle
   repositories {
       mavenCentral()
   }
   ```
3. Open your app's `build.gradle` file
4. Add the Cactus SDK dependency:
   ```gradle
   dependencies {
       implementation "com.cactuscompute:cactus:1.2.0-beta"
   }
   ```

#### 2. Configure ProGuard (Optional)

If you're using ProGuard, add the following rules to your `proguard-rules.pro` file:

```
-keep class com.cactuscompute.** { *; }
-keep interface com.cactuscompute.** { *; }
```

#### 3. Permissions

Add the required permissions to your `AndroidManifest.xml`:

```xml
<!-- For model downloads -->
<uses-permission android:name="android.permission.INTERNET" />
<!-- For audio transcription -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<!-- For local model loading (Android 10 and below) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<!-- For model storage (Android 10 and below) -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- For Android 10+ scoped storage -->
<application
    android:requestLegacyExternalStorage="true"
    ...>
</application>
```

#### 4. Gradle Configuration

Ensure your Gradle settings are compatible with the Cactus SDK:

- **Minimum SDK Version**: 23 or later
- **Compile SDK Version**: 33 or later
- **Build Tools Version**: 33.0.0 or later
- **Java Version**: 11 or later

#### 5. Native Library Configuration

If the Cactus SDK requires native libraries, ensure they're correctly included:

```gradle
dependencies {
    // Add any additional native libraries required by Cactus SDK
    implementation fileTree(dir: 'libs', include: ['*.jar', '*.so'])
}

android {
    // Ensure native libraries are properly extracted
    sourceSets {
        main {
            jniLibs.srcDirs = ['libs']
        }
    }
}
```

### Important Notes
- The plugin requires Android API 23 (Marshmallow) or later
- For Android 10+, you may need to handle scoped storage permissions
- If you encounter "Could not find com.cactuscompute:cactus" errors, verify that Maven Central is added to your repositories
- For native library errors, check that the correct architecture versions are included (arm64-v8a, armeabi-v7a, x86, x86_64)

## Web Setup

### Overview

The Web platform implementation provides a mock interface for development and testing purposes. It doesn't actually download or run LLM models locally, but simulates the API responses to help with development workflows.

### Integration Steps

1. **No Additional Dependencies Required**
   - The Web platform implementation is included in the plugin package
   - It doesn't require any additional dependencies or configuration

2. **Usage in Web Applications**
   - The Web implementation automatically returns mock responses for all API methods
   - This allows you to develop and test your application UI without needing native platforms
   - All methods return the same interfaces as native platforms, making it easy to switch between platforms

### Mock Behavior

#### Model Management
- `downloadModel`: Returns a mock success response immediately
- `getModels`: Returns a predefined list of available models
- `initializeModel`: Simulates model initialization
- `unloadModel`: Simulates model unloading

#### Chat Completion
- Returns a mock response based on the input messages
- Supports mock tool calling functionality

#### Audio Transcription
- Returns a mock transcription result

#### Embeddings
- Returns mock embedding vectors

### Web-Specific Implementation

For a full implementation of the Web platform with actual model inference, you would need to integrate with a Web LLM framework or service. The current implementation is designed to help with cross-platform development by providing consistent API interfaces.

## Plugin Usage

### Model Management

#### Download a Model

```typescript
import { CactusCap } from 'capacitor-plugin-cactus';

async function downloadModel() {
  try {
    const result = await CactusCap.downloadModel({ modelSlug: 'qwen3-0.6' });
    console.log('Model downloaded:', result);
  } catch (error) {
    console.error('Error downloading model:', error);
  }
}
```

#### Get Available Models

```typescript
async function getAvailableModels() {
  try {
    const result = await CactusCap.getAvailableModels();
    console.log('Available models:', result.models);
  } catch (error) {
    console.error('Error getting models:', error);
  }
}
```

### Download a Model with Progress

```typescript
async function downloadModelWithProgress() {
  try {
    // Note: Progress events are handled through native notifications
    // For web integration, use the web-specific implementation
    const result = await CactusCap.downloadModel({ 
      modelSlug: 'qwen3-0.6' 
    });
    console.log('Model downloaded:', result);
  } catch (error) {
    console.error('Error downloading model:', error);
  }
}

#### Initialize a Model

```typescript
async function initializeModel() {
  try {
    const result = await CactusCap.initializeModel({
      modelSlug: 'qwen3-0.6',
      contextSize: 2048
    });
    console.log('Model initialized:', result);
  } catch (error) {
    console.error('Error initializing model:', error);
  }
}
```

#### Unload a Model

```typescript
async function unloadModel() {
  try {
    const result = await CactusCap.unloadModel();
    console.log('Model unloaded:', result);
  } catch (error) {
    console.error('Error unloading model:', error);
  }
}
```

### Chat Completion

```typescript
async function generateCompletion() {
  try {
    const result = await CactusCap.generateCompletion({
      messages: [
        { role: 'system', content: 'You are a helpful assistant.' },
        { role: 'user', content: 'Hello, how are you?' }
      ],
      temperature: 0.7,
      maxTokens: 100
    });
    console.log('Completion result:', result);
  } catch (error) {
    console.error('Error generating completion:', error);
  }
}
```

#### With Tool Calling

```typescript
async function generateCompletionWithTools() {
  try {
    const result = await CactusCap.generateCompletion({
      messages: [
        { role: 'user', content: 'What\'s the weather in New York?' }
      ],
      tools: [
        {
          name: 'get_weather',
          description: 'Get the current weather for a location',
          parameters: {
            type: 'object',
            properties: {
              location: {
                type: 'string',
                description: 'The city name'
              }
            },
            required: ['location']
          }
        }
      ]
    });
    console.log('Completion with tools:', result);
    
    if (result.toolCall) {
      // Handle tool call
      console.log('Tool call received:', result.toolCall);
    }
  } catch (error) {
    console.error('Error generating completion with tools:', error);
  }
}
```

### Audio Transcription

```typescript
async function transcribeAudio() {
  try {
    const result = await CactusCap.transcribeAudio({
      audioPath: '/path/to/audio.wav',
      prompt: 'Transcribe this audio file'
    });
    console.log('Transcription result:', result);
  } catch (error) {
    console.error('Error transcribing audio:', error);
  }
}
```

### Embeddings

#### Text Embeddings

```typescript
async function getTextEmbeddings() {
  try {
    const result = await CactusCap.getTextEmbeddings({
      text: 'The quick brown fox jumps over the lazy dog'
    });
    console.log('Text embeddings:', result.embeddings);
  } catch (error) {
    console.error('Error getting text embeddings:', error);
  }
}
```

#### Image Embeddings

```typescript
async function getImageEmbeddings() {
  try {
    const result = await CactusCap.getImageEmbeddings({
      imagePath: '/path/to/image.jpg'
    });
    console.log('Image embeddings:', result.embeddings);
  } catch (error) {
    console.error('Error getting image embeddings:', error);
  }
}
```

#### Audio Embeddings

```typescript
async function getAudioEmbeddings() {
  try {
    const result = await CactusCap.getAudioEmbeddings({
      audioPath: '/path/to/audio.wav'
    });
    console.log('Audio embeddings:', result.embeddings);
  } catch (error) {
    console.error('Error getting audio embeddings:', error);
  }
}
```

### Local Model Loading

```typescript
async function loadLocalModel() {
  try {
    const result = await CactusCap.initializeModel({
      modelPath: '/path/to/local/model',
      contextSize: 2048
    });
    console.log('Local model loaded:', result);
  } catch (error) {
    console.error('Error loading local model:', error);
  }
}
```

## API Reference

### Model Management

```typescript
// Download a model
CactusCap.downloadModel(options: { 
  modelSlug: string;
}): Promise<{
  success: boolean;
  modelPath: string;
  error?: string;
}>

// Get available models
CactusCap.getAvailableModels(): Promise<{
  success: boolean;
  models: Array<{
    slug: string;
    path: string;
  }>
}>

// Initialize a model
CactusCap.initializeModel(options: {
  modelSlug?: string;
  modelPath?: string;
  contextSize?: number;
}): Promise<{
  success: boolean;
  error?: string;
}>

// Unload the current model
CactusCap.unloadModel(): Promise<{
  success: boolean;
  error?: string;
}>
```

### Chat Completion

```typescript
CactusCap.generateCompletion(options: {
  messages: Array<{
    role: 'system' | 'user' | 'assistant';
    content: string;
  }>;
  temperature?: number;
  maxTokens?: number;
  tools?: Array<{
    type: 'function';
    function: {
      name: string;
      description: string;
      parameters: Record<string, any>;
    };
  }>;
}): Promise<{
  success: boolean;
  response: string;
  functionCalls?: Array<{
    name: string;
    arguments: string;
  }>;
  error?: string;
}>
```

### Audio Transcription

```typescript
CactusCap.transcribeAudio(options: {
  audioPath: string;
  prompt?: string;
  language?: string;
  temperature?: number;
  maxTokens?: number;
}): Promise<{
  success: boolean;
  transcription: string;
  error?: string;
}>
```

### Embeddings

```typescript
// Text embeddings
CactusCap.getTextEmbeddings(options: {
  text: string;
}): Promise<{
  success: boolean;
  embeddings: Array<number>;
  error?: string;
}>

// Image embeddings
CactusCap.getImageEmbeddings(options: {
  imagePath: string;
}): Promise<{
  success: boolean;
  embeddings: Array<number>;
  error?: string;
}>

// Audio embeddings
CactusCap.getAudioEmbeddings(options: {
  audioPath: string;
}): Promise<{
  success: boolean;
  embeddings: Array<number>;
  error?: string;
}>
```

## Example App

The plugin includes an example app that demonstrates all the plugin functionality. To run the example app:

1. **Build the plugin**:   
   ```bash
   npm run build
   ```

2. **Navigate to the example app**:   
   ```bash
   cd example-app
   ```

3. **Install dependencies**:   
   ```bash
   npm install
   ```

4. **Build the example app**:   
   ```bash
   npm run build
   ```

5. **Run on iOS**:   
   ```bash
   npx cap open ios
   ```
   Then build and run in Xcode

6. **Run on Android**:   
   ```bash
   npx cap open android
   ```
   Then build and run in Android Studio

## Troubleshooting

### iOS Dependencies

#### Missing Cactus Frameworks
**Issue**: Xcode build fails with "Framework not found CXXCactusDarwin" or "Framework not found cactus_util"
**Solution**:
1. Verify that you've run `npx cap sync` after installing the plugin
2. Check that the frameworks are properly added in the Pods project
3. If using manual integration, ensure the frameworks are added to your project with correct search paths

#### Zip Library Issues
**Issue**: Build fails with "Zip library not found" or "Undefined symbol: _OBJC_CLASS_$_ZipArchive"
**Solution**:
1. Run `pod install` in your ios directory to ensure the Zip library is properly installed
2. Check your Podfile.lock to verify that Zip is listed as a dependency
3. For manual integration, follow the Zip library installation instructions in the iOS Setup section

#### Swift Version Mismatch
**Issue**: Build fails with "Could not build module 'CactusCap'" due to Swift version conflicts
**Solution**:
1. Ensure your project is using Swift 5.5 or later
2. Check that the plugin's Swift version matches your project's Swift version
3. Update Xcode to the latest version if necessary

### Android Dependencies

#### Maven Central Repository Issues
**Issue**: Gradle build fails with "Could not find com.cactuscompute:cactus:1.2.0-beta"
**Solution**:
1. Verify that Maven Central is added to your project's repositories in build.gradle
2. Check your internet connection and proxy settings
3. Clean your Gradle cache: `cd android && ./gradlew cleanBuildCache && cd ..`

#### Permission Errors
**Issue**: Runtime errors with "Permission denied" when accessing external storage or downloading models
**Solution**:
1. Ensure all required permissions are added to your AndroidManifest.xml
2. For Android 10+, enable legacy storage or implement scoped storage
3. Request runtime permissions for dangerous permissions (RECORD_AUDIO, READ_EXTERNAL_STORAGE)

#### Native Library Errors
**Issue**: "UnsatisfiedLinkError: library 'cactus_jni' not found" or similar native library errors
**Solution**:
1. Ensure your app's build.gradle includes jniLibs configuration
2. Check that the native libraries include the correct architectures for your target devices
3. Verify that the Cactus SDK version matches the plugin requirements

### Web Platform

#### Mock Implementation Limitations
**Issue**: No actual model inference on web platform
**Solution**:
1. The web implementation is currently a mock for development purposes
2. For real web inference, consider integrating with WebLLM or other web-based LLM frameworks
3. Use the mock implementation for UI development and testing

### Common Integration Issues

#### Plugin Not Found
**Issue**: "Cannot find module 'capacitor-plugin-cactus'"
**Solution**:
1. Ensure the plugin is properly installed: `npm install capacitor-plugin-cactus`
2. Verify the plugin is listed in your package.json dependencies
3. Run `npx cap sync` to ensure the plugin is synced with your project

#### Method Not Found
**Issue**: "Method 'downloadModel' not found on plugin 'CactusCap'"
**Solution**:
1. Ensure you're using the latest version of the plugin
2. Run `npx cap sync` to update the plugin in your native projects
3. Check that the plugin is correctly imported in your JavaScript/TypeScript code

#### Model Download Failures
**Issue**: Model downloads fail with network errors or timeouts
**Solution**:
1. Check your internet connection
2. Ensure the device has sufficient storage space
3. For iOS, verify that the app has internet permission
4. For Android, check network security configuration if using custom endpoints

### General Tips

1. **Keep Dependencies Updated**: Regularly update the plugin and its dependencies to the latest versions
2. **Clean Builds**: Perform clean builds (Xcode: Cmd+Shift+K, Android Studio: Build > Clean Project) when encountering build issues
3. **Check Logs**: Review native logs (Xcode console, Android Studio Logcat) for detailed error information
4. **Test on Real Devices**: Some issues only occur on real devices, not simulators/emulators
5. **Verify File Paths**: Ensure all file paths (model paths, audio paths) are correctly formatted and accessible

The example app includes UI components for:
- Model management (download, initialize, unload)
- Chat completion with tool calling
- Audio transcription
- Text, image, and audio embeddings
- Local model loading

## Troubleshooting

### iOS Build Errors

- **Build failed with CocoaPods**: Try running `pod deintegrate && pod install` in your iOS directory
- **Missing dependencies**: Ensure you're using the latest version of the plugin and have run `npx cap sync`
- **Swift version mismatch**: Verify that your project is using Swift 5.5 or later
- **iOS version compatibility**: Ensure your deployment target is iOS 15.0 or later

### Android Build Errors

- **Dependency conflicts**: Check for conflicts with other dependencies in your project
- **Permission issues**: Ensure all required permissions are added to `AndroidManifest.xml`
- **Min SDK version**: The plugin requires Android API 23 or later
- **Gradle synchronization failed**: Try cleaning and rebuilding your Android project

### Common Issues

- **Model not found**: Ensure you're using the correct model slug
- **Permission denied**: Check that your app has the necessary permissions for file access and internet
- **Out of memory**: Large models may require more memory - consider using smaller models or increasing app memory limits

## Support

If you encounter any issues, please refer to:
- The Cactus SDK documentation: [https://cactuscompute.com/docs](https://cactuscompute.com/docs)
- The GitHub repository for issues: [https://github.com/cactus-compute/capacitor-plugin-cactus/issues](https://github.com/cactus-compute/capacitor-plugin-cactus/issues)

## License

MIT
