# capacitor-plugin-cactus

A Capacitor plugin that enables local LLM (Large Language Model) inference on mobile devices using the Cactus SDK. Run models locally on iOS and Android for secure, private AI capabilities without internet connectivity.

## Features

- 📱 **Local LLM Inference**: Load and run LLMs directly on your device
- 📥 **Model Management**: Download and manage models locally
- 💬 **Chat Completion**: Generate text responses from models
- 🎤 **Audio Transcription**: Convert speech to text
- 📊 **Embeddings**: Generate text, image, and audio embeddings
- 🧰 **Tool Integration**: Support for function calls and external tool integration

## Installation

### From npm (Production)
```bash
npm install capacitor-plugin-cactus
npx cap sync
```

### From Local Directory (Development)
```bash
npm install /path/to/capacitor-plugin-cactus
npx cap sync
```

## Quick Start

### Download a Model
```typescript
import { CactusCap } from 'capacitor-plugin-cactus';

async function downloadModel() {
  try {
    const result = await CactusCap.downloadModel({ 
      modelSlug: 'qwen3-0.6' 
    });
    console.log('Model downloaded at:', result.modelPath);
  } catch (error) {
    console.error('Error downloading model:', error);
  }
}
```

### Initialize and Use Model
```typescript
async function initializeAndUseModel() {
  // Initialize model
  await CactusCap.initializeModel({ 
    modelSlug: 'qwen3-0.6' 
  });

  // Generate completion
  const result = await CactusCap.generateCompletion({ 
    messages: [
      { role: 'system', content: 'You are a helpful assistant.' },
      { role: 'user', content: 'Hello, how are you?' }
    ]
  });

  console.log('Model response:', result.response);
}
```

## Documentation

For detailed integration instructions, API reference, and troubleshooting, please refer to the [Integration Guide](INTEGRATION_GUIDE.md).

## Platform Support

- ✅ iOS (15.0+)
- ✅ Android (API 23+)
- ⏳ Web (Coming soon)

## Requirements

- iOS 15.0 or later
- Android API 23 or later
- Swift 5.5 or later (iOS)
- Capacitor 5.x

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`downloadModel(...)`](#downloadmodel)
* [`pauseDownload(...)`](#pausedownload)
* [`resumeDownload(...)`](#resumedownload)
* [`cancelDownload(...)`](#canceldownload)
* [`getDownloadProgress(...)`](#getdownloadprogress)
* [`getAvailableModels()`](#getavailablemodels)
* [`loadModel(...)`](#loadmodel)
* [`loadLocalModel(...)`](#loadlocalmodel)
* [`unloadModel()`](#unloadmodel)
* [`generateCompletion(...)`](#generatecompletion)
* [`generateStreamingCompletion(...)`](#generatestreamingcompletion)
* [`transcribeAudio(...)`](#transcribeaudio)
* [`getTextEmbeddings(...)`](#gettextembeddings)
* [`getImageEmbeddings(...)`](#getimageembeddings)
* [`getAudioEmbeddings(...)`](#getaudioembeddings)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### downloadModel(...)

```typescript
downloadModel(options: { modelSlug: string; }) => Promise<{ success: boolean; modelPath?: string; modelName?: string; modelSlug?: string; error?: string; }>
```

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ modelSlug: string; }</code> |

**Returns:** <code>Promise&lt;{ success: boolean; modelPath?: string; modelName?: string; modelSlug?: string; error?: string; }&gt;</code>

--------------------


### pauseDownload(...)

```typescript
pauseDownload(options: { modelSlug: string; }) => Promise<void>
```

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ modelSlug: string; }</code> |

--------------------


### resumeDownload(...)

```typescript
resumeDownload(options: { modelSlug: string; }) => Promise<void>
```

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ modelSlug: string; }</code> |

--------------------


### cancelDownload(...)

```typescript
cancelDownload(options: { modelSlug: string; }) => Promise<void>
```

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ modelSlug: string; }</code> |

--------------------


### getDownloadProgress(...)

```typescript
getDownloadProgress(options: { modelSlug: string; }) => Promise<{ success: boolean; stage?: 'downloading' | 'unzipping' | 'finished'; progress?: number; modelPath?: string; error?: string; }>
```

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ modelSlug: string; }</code> |

**Returns:** <code>Promise&lt;{ success: boolean; stage?: 'downloading' | 'unzipping' | 'finished'; progress?: number; modelPath?: string; error?: string; }&gt;</code>

--------------------


### getAvailableModels()

```typescript
getAvailableModels() => Promise<{ success: boolean; models?: Array<{ slug: string; path: string; }>; error?: string; }>
```

**Returns:** <code>Promise&lt;{ success: boolean; models?: { slug: string; path: string; }[]; error?: string; }&gt;</code>

--------------------


### loadModel(...)

```typescript
loadModel(options: { modelSlug: string; contextSize?: number; }) => Promise<{ success: boolean; error?: string; }>
```

| Param         | Type                                                      |
| ------------- | --------------------------------------------------------- |
| **`options`** | <code>{ modelSlug: string; contextSize?: number; }</code> |

**Returns:** <code>Promise&lt;{ success: boolean; error?: string; }&gt;</code>

--------------------


### loadLocalModel(...)

```typescript
loadLocalModel(options: { modelPath: string; modelSlug?: string; contextSize?: number; }) => Promise<{ success: boolean; error?: string; }>
```

| Param         | Type                                                                          |
| ------------- | ----------------------------------------------------------------------------- |
| **`options`** | <code>{ modelPath: string; modelSlug?: string; contextSize?: number; }</code> |

**Returns:** <code>Promise&lt;{ success: boolean; error?: string; }&gt;</code>

--------------------


### unloadModel()

```typescript
unloadModel() => Promise<{ success: boolean; error?: string; }>
```

**Returns:** <code>Promise&lt;{ success: boolean; error?: string; }&gt;</code>

--------------------


### generateCompletion(...)

```typescript
generateCompletion(options: { messages: Array<{ role: 'system' | 'user' | 'assistant' | 'function'; content: string; name?: string; tool_call_id?: string; }>; temperature?: number; maxTokens?: number; topP?: number; topK?: number; stopSequences?: string[]; tools?: Array<{ type: 'function'; function: { name: string; description: string; parameters: any; }; }>; }) => Promise<{ success: boolean; response?: string; timeToFirstTokenMs?: number; totalTimeMs?: number; tokensPerSecond?: number; prefillTokens?: number; decodeTokens?: number; totalTokens?: number; toolCalls?: Array<{ name: string; arguments: any; }>; error?: string; }>
```

| Param         | Type                                                                                                                                                                                                                                                                                                                                                  |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`options`** | <code>{ messages: { role: 'function' \| 'system' \| 'user' \| 'assistant'; content: string; name?: string; tool_call_id?: string; }[]; temperature?: number; maxTokens?: number; topP?: number; topK?: number; stopSequences?: string[]; tools?: { type: 'function'; function: { name: string; description: string; parameters: any; }; }[]; }</code> |

**Returns:** <code>Promise&lt;{ success: boolean; response?: string; timeToFirstTokenMs?: number; totalTimeMs?: number; tokensPerSecond?: number; prefillTokens?: number; decodeTokens?: number; totalTokens?: number; toolCalls?: { name: string; arguments: any; }[]; error?: string; }&gt;</code>

--------------------


### generateStreamingCompletion(...)

```typescript
generateStreamingCompletion(options: { messages: Array<{ role: 'system' | 'user' | 'assistant' | 'function'; content: string; name?: string; tool_call_id?: string; }>; temperature?: number; maxTokens?: number; topP?: number; topK?: number; stopSequences?: string[]; tools?: Array<{ type: 'function'; function: { name: string; description: string; parameters: any; }; }>; }) => Promise<{ success: boolean; error?: string; }>
```

Generate streaming text completion from a model.
This method emits events through the 'cactusStreamingResponse' listener.
Events include:
- 'start': Stream started
- 'token': New token received
- 'done': Stream completed

| Param         | Type                                                                                                                                                                                                                                                                                                                                                  | Description                                     |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| **`options`** | <code>{ messages: { role: 'function' \| 'system' \| 'user' \| 'assistant'; content: string; name?: string; tool_call_id?: string; }[]; temperature?: number; maxTokens?: number; topP?: number; topK?: number; stopSequences?: string[]; tools?: { type: 'function'; function: { name: string; description: string; parameters: any; }; }[]; }</code> | The options for generating streaming completion |

**Returns:** <code>Promise&lt;{ success: boolean; error?: string; }&gt;</code>

--------------------


### transcribeAudio(...)

```typescript
transcribeAudio(options: { audioPath: string; prompt?: string; language?: string; temperature?: number; maxTokens?: number; }) => Promise<{ success: boolean; transcription?: string; error?: string; }>
```

| Param         | Type                                                                                                              |
| ------------- | ----------------------------------------------------------------------------------------------------------------- |
| **`options`** | <code>{ audioPath: string; prompt?: string; language?: string; temperature?: number; maxTokens?: number; }</code> |

**Returns:** <code>Promise&lt;{ success: boolean; transcription?: string; error?: string; }&gt;</code>

--------------------


### getTextEmbeddings(...)

```typescript
getTextEmbeddings(options: { text: string; }) => Promise<{ success: boolean; embeddings?: number[]; error?: string; }>
```

| Param         | Type                           |
| ------------- | ------------------------------ |
| **`options`** | <code>{ text: string; }</code> |

**Returns:** <code>Promise&lt;{ success: boolean; embeddings?: number[]; error?: string; }&gt;</code>

--------------------


### getImageEmbeddings(...)

```typescript
getImageEmbeddings(options: { imagePath: string; }) => Promise<{ success: boolean; embeddings?: number[]; error?: string; }>
```

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ imagePath: string; }</code> |

**Returns:** <code>Promise&lt;{ success: boolean; embeddings?: number[]; error?: string; }&gt;</code>

--------------------


### getAudioEmbeddings(...)

```typescript
getAudioEmbeddings(options: { audioPath: string; }) => Promise<{ success: boolean; embeddings?: number[]; error?: string; }>
```

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ audioPath: string; }</code> |

**Returns:** <code>Promise&lt;{ success: boolean; embeddings?: number[]; error?: string; }&gt;</code>

--------------------


### Interfaces


#### Array

| Prop         | Type                | Description                                                                                            |
| ------------ | ------------------- | ------------------------------------------------------------------------------------------------------ |
| **`length`** | <code>number</code> | Gets or sets the length of the array. This is a number one higher than the highest index in the array. |

| Method             | Signature                                                                                                                     | Description                                                                                                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **toString**       | () =&gt; string                                                                                                               | Returns a string representation of an array.                                                                                                                                                                                                |
| **toLocaleString** | () =&gt; string                                                                                                               | Returns a string representation of an array. The elements are converted to string using their toLocalString methods.                                                                                                                        |
| **pop**            | () =&gt; T \| undefined                                                                                                       | Removes the last element from an array and returns it. If the array is empty, undefined is returned and the array is not modified.                                                                                                          |
| **push**           | (...items: T[]) =&gt; number                                                                                                  | Appends new elements to the end of an array, and returns the new length of the array.                                                                                                                                                       |
| **concat**         | (...items: <a href="#concatarray">ConcatArray</a>&lt;T&gt;[]) =&gt; T[]                                                       | Combines two or more arrays. This method returns a new array without modifying any existing arrays.                                                                                                                                         |
| **concat**         | (...items: (T \| <a href="#concatarray">ConcatArray</a>&lt;T&gt;)[]) =&gt; T[]                                                | Combines two or more arrays. This method returns a new array without modifying any existing arrays.                                                                                                                                         |
| **join**           | (separator?: string \| undefined) =&gt; string                                                                                | Adds all the elements of an array into a string, separated by the specified separator string.                                                                                                                                               |
| **reverse**        | () =&gt; T[]                                                                                                                  | Reverses the elements in an array in place. This method mutates the array and returns a reference to the same array.                                                                                                                        |
| **shift**          | () =&gt; T \| undefined                                                                                                       | Removes the first element from an array and returns it. If the array is empty, undefined is returned and the array is not modified.                                                                                                         |
| **slice**          | (start?: number \| undefined, end?: number \| undefined) =&gt; T[]                                                            | Returns a copy of a section of an array. For both start and end, a negative index can be used to indicate an offset from the end of the array. For example, -2 refers to the second to last element of the array.                           |
| **sort**           | (compareFn?: ((a: T, b: T) =&gt; number) \| undefined) =&gt; this                                                             | Sorts an array in place. This method mutates the array and returns a reference to the same array.                                                                                                                                           |
| **splice**         | (start: number, deleteCount?: number \| undefined) =&gt; T[]                                                                  | Removes elements from an array and, if necessary, inserts new elements in their place, returning the deleted elements.                                                                                                                      |
| **splice**         | (start: number, deleteCount: number, ...items: T[]) =&gt; T[]                                                                 | Removes elements from an array and, if necessary, inserts new elements in their place, returning the deleted elements.                                                                                                                      |
| **unshift**        | (...items: T[]) =&gt; number                                                                                                  | Inserts new elements at the start of an array, and returns the new length of the array.                                                                                                                                                     |
| **indexOf**        | (searchElement: T, fromIndex?: number \| undefined) =&gt; number                                                              | Returns the index of the first occurrence of a value in an array, or -1 if it is not present.                                                                                                                                               |
| **lastIndexOf**    | (searchElement: T, fromIndex?: number \| undefined) =&gt; number                                                              | Returns the index of the last occurrence of a specified value in an array, or -1 if it is not present.                                                                                                                                      |
| **every**          | &lt;S extends T&gt;(predicate: (value: T, index: number, array: T[]) =&gt; value is S, thisArg?: any) =&gt; this is S[]       | Determines whether all the members of an array satisfy the specified test.                                                                                                                                                                  |
| **every**          | (predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any) =&gt; boolean                                 | Determines whether all the members of an array satisfy the specified test.                                                                                                                                                                  |
| **some**           | (predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any) =&gt; boolean                                 | Determines whether the specified callback function returns true for any element of an array.                                                                                                                                                |
| **forEach**        | (callbackfn: (value: T, index: number, array: T[]) =&gt; void, thisArg?: any) =&gt; void                                      | Performs the specified action for each element in an array.                                                                                                                                                                                 |
| **map**            | &lt;U&gt;(callbackfn: (value: T, index: number, array: T[]) =&gt; U, thisArg?: any) =&gt; U[]                                 | Calls a defined callback function on each element of an array, and returns an array that contains the results.                                                                                                                              |
| **filter**         | &lt;S extends T&gt;(predicate: (value: T, index: number, array: T[]) =&gt; value is S, thisArg?: any) =&gt; S[]               | Returns the elements of an array that meet the condition specified in a callback function.                                                                                                                                                  |
| **filter**         | (predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any) =&gt; T[]                                     | Returns the elements of an array that meet the condition specified in a callback function.                                                                                                                                                  |
| **reduce**         | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T) =&gt; T                           | Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.                      |
| **reduce**         | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T, initialValue: T) =&gt; T          |                                                                                                                                                                                                                                             |
| **reduce**         | &lt;U&gt;(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) =&gt; U, initialValue: U) =&gt; U | Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.                      |
| **reduceRight**    | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T) =&gt; T                           | Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function. |
| **reduceRight**    | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T, initialValue: T) =&gt; T          |                                                                                                                                                                                                                                             |
| **reduceRight**    | &lt;U&gt;(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) =&gt; U, initialValue: U) =&gt; U | Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function. |


#### ConcatArray

| Prop         | Type                |
| ------------ | ------------------- |
| **`length`** | <code>number</code> |

| Method    | Signature                                                          |
| --------- | ------------------------------------------------------------------ |
| **join**  | (separator?: string \| undefined) =&gt; string                     |
| **slice** | (start?: number \| undefined, end?: number \| undefined) =&gt; T[] |

</docgen-api>
