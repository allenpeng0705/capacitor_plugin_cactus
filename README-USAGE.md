# CactusCap Plugin Usage Guide

This guide explains how to use the CactusCap plugin in your JavaScript or TypeScript projects to leverage local LLMs with the option to use cloud-based LLMs like Gemini for hybrid AI applications.

## Table of Contents

1. [Installation](#installation)
2. [Basic Setup](#basic-setup)
3. [Model Management](#model-management)
   - [Downloading Models](#downloading-models)
   - [Loading Models](#loading-models)
   - [Unloading Models](#unloading-models)
   - [Checking Available Models](#checking-available-models)
4. [Text Generation](#text-generation)
   - [Single Completion](#single-completion)
   - [Streaming Completion](#streaming-completion)
5. [Audio Transcription](#audio-transcription)
6. [Embeddings Generation](#embeddings-generation)
7. [Hybrid Local/Cloud LLM Approach](#hybrid-localcloud-llm-approach)
8. [Error Handling](#error-handling)
9. [API Reference](#api-reference)

## Installation

First, install the plugin in your Capacitor project:

```bash
npm install capacitor-plugin-cactus
npx cap sync
```

## Basic Setup

Import the plugin in your JavaScript/TypeScript files:

```javascript
// For JavaScript
import { CactusCap } from 'capacitor-plugin-cactus';

// For TypeScript
import { CactusCap, type CactusCapPlugin } from 'capacitor-plugin-cactus';
```

## Model Management

### Downloading Models

Download a model by its slug (e.g., "qwen3-0.6", "gemma3-270m"):

```javascript
async function downloadModel() {
  try {
    const result = await CactusCap.downloadModel({
      modelSlug: 'qwen3-0.6'
    });
    
    if (result.success) {
      console.log('Model downloaded successfully:', result.modelPath);
    } else {
      console.error('Error downloading model:', result.error);
    }
  } catch (error) {
    console.error('Exception during model download:', error);
  }
}
```

### Loading Models

#### Load a downloaded model by slug:

```javascript
async function loadModel() {
  try {
    const result = await CactusCap.loadModel({
      modelSlug: 'qwen3-0.6',
      contextSize: 2048 // Optional, default varies by model
    });
    
    if (result.success) {
      console.log('Model loaded successfully');
    } else {
      console.error('Error loading model:', result.error);
    }
  } catch (error) {
    console.error('Exception during model loading:', error);
  }
}
```

#### Load a local model from a specific path:

```javascript
async function loadLocalModel() {
  try {
    const result = await CactusCap.loadLocalModel({
      modelPath: '/path/to/model/folder',
      modelSlug: 'custom-model', // Optional
      contextSize: 2048 // Optional
    });
    
    if (result.success) {
      console.log('Local model loaded successfully');
    } else {
      console.error('Error loading local model:', result.error);
    }
  } catch (error) {
    console.error('Exception during local model loading:', error);
  }
}
```

### Unloading Models

Unload the currently loaded model to free up resources:

```javascript
async function unloadModel() {
  try {
    const result = await CactusCap.unloadModel();
    
    if (result.success) {
      console.log('Model unloaded successfully');
    } else {
      console.error('Error unloading model:', result.error);
    }
  } catch (error) {
    console.error('Exception during model unloading:', error);
  }
}
```

### Checking Available Models

List all models that are currently downloaded:

```javascript
async function getAvailableModels() {
  try {
    const result = await CactusCap.getAvailableModels();
    
    if (result.success && result.models) {
      console.log('Available models:', result.models);
      // Example: [{ slug: 'qwen3-0.6', path: '/path/to/qwen3-0.6' }]
    } else {
      console.error('Error getting available models:', result.error);
    }
  } catch (error) {
    console.error('Exception during getting available models:', error);
  }
}
```

## Text Generation

### Single Completion

Generate a single text completion:

```javascript
async function generateText() {
  try {
    const messages = [
      { role: 'system', content: 'You are a helpful assistant.' },
      { role: 'user', content: 'Explain quantum computing in simple terms.' }
    ];
    
    const result = await CactusCap.generateCompletion({
      messages,
      temperature: 0.7,
      maxTokens: 1000,
      topP: 0.9,
      topK: 40,
      stopSequences: ['\n\n']
    });
    
    if (result.success && result.response) {
      console.log('Generated response:', result.response);
      console.log('Performance:', {
        timeToFirstTokenMs: result.timeToFirstTokenMs,
        totalTimeMs: result.totalTimeMs,
        tokensPerSecond: result.tokensPerSecond
      });
    } else {
      console.error('Error generating text:', result.error);
    }
  } catch (error) {
    console.error('Exception during text generation:', error);
  }
}
```

### Streaming Completion

Generate streaming text completion:

```javascript
// First, set up a listener for streaming events
window.addEventListener('cactusStreamingResponse', (event) => {
  const { type, data } = event.detail;
  
  switch (type) {
    case 'start':
      console.log('Streaming started');
      break;
    case 'token':
      console.log('Received token:', data.token);
      console.log('Current completion:', data.completion);
      // Update UI with new token here
      break;
    case 'done':
      console.log('Streaming completed');
      console.log('Full completion:', data.completion);
      console.log('Usage:', data.usage);
      console.log('Generation metrics:', data.generationMetrics);
      break;
  }
});

// Then start streaming completion
async function generateStreamingText() {
  try {
    const messages = [
      { role: 'system', content: 'You are a helpful assistant.' },
      { role: 'user', content: 'Write a poem about AI.' }
    ];
    
    const result = await CactusCap.generateStreamingCompletion({
      messages,
      temperature: 0.8,
      maxTokens: 500
    });
    
    if (!result.success) {
      console.error('Error starting streaming:', result.error);
    }
  } catch (error) {
    console.error('Exception during streaming setup:', error);
  }
}
```

## Audio Transcription

Transcribe audio files to text:

```javascript
async function transcribeAudio() {
  try {
    const result = await CactusCap.transcribeAudio({
      audioPath: '/path/to/audio/file.mp3',
      prompt: 'Transcribe this meeting recording', // Optional
      language: 'en', // Optional
      temperature: 0.0 // Optional
    });
    
    if (result.success && result.transcription) {
      console.log('Transcription:', result.transcription);
    } else {
      console.error('Error transcribing audio:', result.error);
    }
  } catch (error) {
    console.error('Exception during audio transcription:', error);
  }
}
```

## Embeddings Generation

Generate embeddings for text, images, or audio:

### Text Embeddings

```javascript
async function getTextEmbeddings() {
  try {
    const result = await CactusCap.getTextEmbeddings({
      text: 'This is a sample sentence for embeddings'
    });
    
    if (result.success && result.embeddings) {
      console.log('Text embeddings generated:', result.embeddings.length, 'dimensions');
    } else {
      console.error('Error generating text embeddings:', result.error);
    }
  } catch (error) {
    console.error('Exception during text embeddings generation:', error);
  }
}
```

### Image Embeddings

```javascript
async function getImageEmbeddings() {
  try {
    const result = await CactusCap.getImageEmbeddings({
      imagePath: '/path/to/image/file.jpg'
    });
    
    if (result.success && result.embeddings) {
      console.log('Image embeddings generated:', result.embeddings.length, 'dimensions');
    } else {
      console.error('Error generating image embeddings:', result.error);
    }
  } catch (error) {
    console.error('Exception during image embeddings generation:', error);
  }
}
```

### Audio Embeddings

```javascript
async function getAudioEmbeddings() {
  try {
    const result = await CactusCap.getAudioEmbeddings({
      audioPath: '/path/to/audio/file.mp3'
    });
    
    if (result.success && result.embeddings) {
      console.log('Audio embeddings generated:', result.embeddings.length, 'dimensions');
    } else {
      console.error('Error generating audio embeddings:', result.error);
    }
  } catch (error) {
    console.error('Exception during audio embeddings generation:', error);
  }
}
```

## Hybrid Local/Cloud LLM Approach

This example shows how to use both local LLM (Cactus) and cloud-based LLM (Gemini) in your application:

```javascript
import { CactusCap } from 'capacitor-plugin-cactus';

// Gemini API setup
const GEMINI_API_KEY = 'your-gemini-api-key';
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

// Helper function to detect network connectivity
async function isOnline() {
  return navigator.onLine;
}

// Main AI generation function that uses local LLM when offline and cloud LLM when online
async function generateAIResponse(prompt, useLocalOnly = false) {
  try {
    const isConnected = await isOnline();
    
    // If online and not forced to use local, use Gemini cloud
    if (isConnected && !useLocalOnly) {
      console.log('Using Gemini cloud LLM');
      return await generateGeminiResponse(prompt);
    } 
    // Otherwise use local Cactus LLM
    else {
      console.log('Using local Cactus LLM');
      return await generateCactusResponse(prompt);
    }
  } catch (error) {
    console.error('AI generation error:', error);
    throw error;
  }
}

// Generate response using Gemini cloud API
async function generateGeminiResponse(prompt) {
  try {
    const response = await fetch(`${GEMINI_API_URL}?key=${GEMINI_API_KEY}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        contents: [{
          parts: [{ text: prompt }]
        }],
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 1000
        }
      })
    });
    
    const data = await response.json();
    
    if (data.candidates && data.candidates.length > 0) {
      return data.candidates[0].content.parts[0].text;
    } else {
      throw new Error('Gemini API error: No response generated');
    }
  } catch (error) {
    console.error('Gemini API error:', error);
    // Fallback to local LLM if cloud fails
    console.log('Falling back to local Cactus LLM');
    return await generateCactusResponse(prompt);
  }
}

// Generate response using local Cactus LLM
async function generateCactusResponse(prompt) {
  try {
    // Check if a model is loaded
    const availableModels = await CactusCap.getAvailableModels();
    
    if (!availableModels.success || !availableModels.models || availableModels.models.length === 0) {
      console.log('No models available locally. Downloading qwen3-0.6...');
      await CactusCap.downloadModel({ modelSlug: 'qwen3-0.6' });
      await CactusCap.loadModel({ modelSlug: 'qwen3-0.6' });
    }
    
    const messages = [
      { role: 'system', content: 'You are a helpful assistant.' },
      { role: 'user', content: prompt }
    ];
    
    const result = await CactusCap.generateCompletion({
      messages,
      temperature: 0.7,
      maxTokens: 1000
    });
    
    if (result.success && result.response) {
      return result.response;
    } else {
      throw new Error(`Cactus LLM error: ${result.error}`);
    }
  } catch (error) {
    console.error('Cactus LLM error:', error);
    throw error;
  }
}

// Usage example
async function main() {
  try {
    const prompt = 'What are the benefits of using local LLMs?';
    
    // Auto-select between cloud and local
    const response1 = await generateAIResponse(prompt);
    console.log('AI Response (auto):', response1);
    
    // Force use local LLM
    const response2 = await generateAIResponse(prompt, true);
    console.log('AI Response (local only):', response2);
    
  } catch (error) {
    console.error('Main function error:', error);
  }
}

main();
```

## Error Handling

Implement robust error handling for all plugin operations:

```javascript
async function safePluginOperation() {
  try {
    // Plugin operation here
    const result = await CactusCap.someOperation();
    
    if (!result.success) {
      // Handle API-level error
      throw new Error(result.error || 'Unknown plugin error');
    }
    
    return result;
  } catch (error) {
    // Handle different types of errors
    if (error instanceof TypeError) {
      console.error('Type error:', error.message);
    } else if (error instanceof RangeError) {
      console.error('Range error:', error.message);
    } else {
      console.error('General error:', error.message);
    }
    
    // Optionally retry or fallback
    return { success: false, error: error.message };
  }
}
```

## API Reference

### Model Management

- `downloadModel(options: { modelSlug: string })`
- `pauseDownload(options: { modelSlug: string })`
- `resumeDownload(options: { modelSlug: string })`
- `cancelDownload(options: { modelSlug: string })`
- `getDownloadProgress(options: { modelSlug: string })`
- `getAvailableModels()`
- `loadModel(options: { modelSlug: string, contextSize?: number })`
- `loadLocalModel(options: { modelPath: string, modelSlug?: string, contextSize?: number })`
- `unloadModel()`

### Text Generation

- `generateCompletion(options: { messages, temperature?, maxTokens?, topP?, topK?, stopSequences?, tools? })`
- `generateStreamingCompletion(options: { messages, temperature?, maxTokens?, topP?, topK?, stopSequences?, tools? })`

### Audio

- `transcribeAudio(options: { audioPath, prompt?, language?, temperature?, maxTokens? })`

### Embeddings

- `getTextEmbeddings(options: { text })`
- `getImageEmbeddings(options: { imagePath })`
- `getAudioEmbeddings(options: { audioPath })`

## Events

- `cactusStreamingResponse`: Emitted during streaming completion with events:
  - `{ type: 'start', data: {} }`
  - `{ type: 'token', data: { token, completion } }`
  - `{ type: 'done', data: { completion, usage, generationMetrics } }`

## Tips

1. **Model Selection**: Choose smaller models (e.g., "qwen3-0.6") for better performance on mobile devices.

2. **Memory Management**: Always unload models when not in use to free up memory.

3. **Offline-First Design**: Design your app to work seamlessly with both online and offline modes.

4. **Performance Monitoring**: Use the metrics returned by the plugin to monitor and optimize performance.

5. **Fallback Strategies**: Implement fallbacks from cloud to local LLMs when network connectivity is poor.

6. **User Experience**: Show clear indicators to users when switching between local and cloud models.

## Troubleshooting

- **Model download fails**: Check network connectivity and storage space.
- **Generation is slow**: Try smaller models or adjust generation parameters.
- **Plugin not found**: Ensure proper installation and sync (run `npx cap sync`).
- **Permission errors**: Ensure your app has necessary permissions for storage and network access.

## Example Applications

1. **Offline AI Assistant**: Use local LLM for basic queries and Gemini for complex ones.
2. **Hybrid Chatbot**: Switch between local and cloud based on content complexity.
3. **Edge AI Applications**: Process sensitive data locally while using cloud for non-sensitive tasks.
4. **Travel Assistant**: Use local LLM for offline travel tips and cloud for real-time updates.

## Conclusion

The CactusCap plugin enables you to build powerful hybrid AI applications that leverage both local and cloud-based LLMs. By following this guide, you can create applications that work seamlessly online and offline, providing users with reliable AI capabilities regardless of their network connectivity.