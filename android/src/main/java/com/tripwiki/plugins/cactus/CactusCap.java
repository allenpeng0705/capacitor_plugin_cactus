package com.tripwiki.plugins.cactus;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Logger;
import com.tripwiki.plugins.cactus.CactusPlugin;
import com.getcapacitor.PluginCall;

// Import only what we need
import com.cactus.CactusLM;
import com.cactus.CactusInitParams;
import com.cactus.CactusCompletionParams;
import com.cactus.CactusSTT;
import com.cactus.ChatMessage;
import com.cactus.CactusModel;
import com.cactus.services.ToolFilterConfig;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.CoroutineContext;
import kotlin.coroutines.EmptyCoroutineContext;
import kotlinx.coroutines.BuildersKt;
import kotlinx.coroutines.Dispatchers;
import kotlin.jvm.functions.Function2;

import android.content.Context;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CactusCap {
    private CactusLM lm;
    private CactusSTT stt;
    private boolean isModelInitialized = false;
    private String currentModelSlug = null;
    private File modelsDirectory;
    private Context context;
    private CactusPlugin plugin;

    public CactusCap(Context context, CactusPlugin plugin) {
        // Initialize CactusLM and CactusSTT instances
        this.lm = new CactusLM();
        this.stt = new CactusSTT();
        this.context = context;
        this.plugin = plugin;
        
        // Initialize the models directory when the plugin is created
        File filesDir = context.getFilesDir();
        File cactusDir = new File(filesDir, "cactus");
        this.modelsDirectory = new File(cactusDir, "models");
        
        // Create the directory if it doesn't exist
        if (!this.modelsDirectory.exists()) {
            this.modelsDirectory.mkdirs();
        }
        
        Logger.info("Cactus", "Android: Models directory: " + this.modelsDirectory.getAbsolutePath());
    }

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }

    public JSObject downloadModel(String modelSlug) {
        // Use Cactus SDK to download the model
        String slug = modelSlug != null ? modelSlug : "qwen3-0.6";
        Logger.info("Cactus", "Android: Downloading model with slug: " + slug);
        
        try {
            // Check if model already exists
            File modelDir = new File(modelsDirectory, slug);
            boolean modelExists = modelDir.exists() && modelDir.isDirectory() && modelDir.listFiles().length > 0;
            Logger.info("Cactus", "Android: Model already exists: " + modelExists);
            
            if (modelExists) {
                Logger.info("Cactus", "Android: Model files found: " + modelDir.listFiles().length);
                for (File file : modelDir.listFiles()) {
                    Logger.info("Cactus", "Android: Existing file: " + file.getName() + " (" + file.length() + " bytes)");
                }
            } else {
                Logger.info("Cactus", "Android: Model not found, starting download...");
            }
            
            // Run the suspend function in a blocking context and measure time
            long startTime = System.currentTimeMillis();
            BuildersKt.runBlocking(Dispatchers.getIO(), new kotlin.jvm.functions.Function2<kotlinx.coroutines.CoroutineScope, kotlin.coroutines.Continuation<? super kotlin.Unit>, Object>() {
                @Override
                public Object invoke(kotlinx.coroutines.CoroutineScope coroutineScope, kotlin.coroutines.Continuation<? super kotlin.Unit> continuation) {
                    return lm.downloadModel(slug, continuation);
                }
            });
            long endTime = System.currentTimeMillis();
            long downloadTime = endTime - startTime;
            
            // Log download time
            Logger.info("Cactus", "Android: Model download completed in " + downloadTime + " ms");
            
            // Get the actual model path
            modelDir = new File(modelsDirectory, slug);
            String modelPath = modelDir.getAbsolutePath();
            
            // Log final model directory contents
            if (modelDir.exists() && modelDir.isDirectory()) {
                File[] files = modelDir.listFiles();
                Logger.info("Cactus", "Android: Final model files: " + (files != null ? files.length : 0));
                if (files != null) {
                    for (File file : files) {
                        Logger.info("Cactus", "Android: Final file: " + file.getName() + " (" + file.length() + " bytes)");
                    }
                }
            }
            
            JSObject result = new JSObject();
            result.put("success", true);
            result.put("modelPath", modelPath);
            result.put("downloadTimeMs", downloadTime);
            result.put("modelExists", modelExists);
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error downloading model: " + e.getMessage(), e);
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Error downloading model: " + e.getMessage());
            return result;
        }
    }
    
    public JSObject pauseDownload(String modelSlug) {
        // Use Cactus SDK to pause the download
        Logger.info("Cactus", "Android: Pausing download");
        
        try {
            // Currently not supported in Cactus SDK
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Pause download is not supported in the current Cactus SDK version");
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error pausing download: " + e.getMessage(), e);
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Error pausing download: " + e.getMessage());
            return result;
        }
    }
    
    public JSObject resumeDownload(String modelSlug) {
        // Use Cactus SDK to resume the download
        Logger.info("Cactus", "Android: Resuming download");
        
        try {
            // Currently not supported in Cactus SDK
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Resume download is not supported in the current Cactus SDK version");
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error resuming download: " + e.getMessage(), e);
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Error resuming download: " + e.getMessage());
            return result;
        }
    }
    
    public JSObject cancelDownload(String modelSlug) {
        // Use Cactus SDK to cancel the download
        Logger.info("Cactus", "Android: Canceling download");
        
        try {
            // Currently not supported in Cactus SDK
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Cancel download is not supported in the current Cactus SDK version");
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error canceling download: " + e.getMessage(), e);
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Error canceling download: " + e.getMessage());
            return result;
        }
    }
    
    public JSObject getDownloadProgress(String modelSlug) {
        // Use Cactus SDK to get download progress
        Logger.info("Cactus", "Android: Getting download progress");
        
        try {
            // For now, return dummy progress since we can't find CactusDownloadProgress
            JSObject result = new JSObject();
            result.put("success", true);
            result.put("progress", 0.0);
            result.put("totalBytes", 0L);
            result.put("downloadedBytes", 0L);
            result.put("status", "unknown");
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error getting download progress: " + e.getMessage(), e);
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Error getting download progress: " + e.getMessage());
            return result;
        }
    }

    public JSObject getAvailableModels() {
        // Use Cactus SDK to get available models
        Logger.info("Cactus", "Android: Getting available models");
        
        try {
            // Use runBlocking to call the suspend function
            final List<CactusModel> models = BuildersKt.runBlocking(Dispatchers.getIO(), new kotlin.jvm.functions.Function2<kotlinx.coroutines.CoroutineScope, kotlin.coroutines.Continuation<? super List<CactusModel>>, Object>() {
                @Override
                public Object invoke(kotlinx.coroutines.CoroutineScope coroutineScope, kotlin.coroutines.Continuation<? super List<CactusModel>> continuation) {
                    return lm.getModels(continuation);
                }
            });
            
            JSArray modelsArray = new JSArray();
            for (CactusModel model : models) {
                JSObject modelObj = new JSObject();
                modelObj.put("slug", model.getSlug());
                modelObj.put("name", model.getName());
                modelObj.put("sizeMB", model.getSize_mb());
                modelObj.put("supportsToolCalling", model.getSupports_tool_calling());
                modelObj.put("supportsVision", model.getSupports_vision());
                modelObj.put("isDownloaded", model.isDownloaded());
                modelObj.put("quantization", model.getQuantization());
                modelsArray.put(modelObj);
            }
            
            JSObject result = new JSObject();
            result.put("success", true);
            result.put("models", modelsArray);
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error getting available models: " + e.getMessage(), e);
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Error getting available models: " + e.getMessage());
            return result;
        }
    }

    public JSObject initializeModel(String modelSlug, String modelPath, int contextSize) {
        // Use Cactus SDK to initialize the model
        String slug = modelSlug != null ? modelSlug : "qwen3-0.6";
        currentModelSlug = slug;
        Logger.info("Cactus", "Android: Initializing model: " + slug + " with context size: " + contextSize);
        
        try {
            // Run the suspend function in a blocking context
            BuildersKt.runBlocking(Dispatchers.getIO(), new kotlin.jvm.functions.Function2<kotlinx.coroutines.CoroutineScope, kotlin.coroutines.Continuation<? super kotlin.Unit>, Object>() {
                @Override
                public Object invoke(kotlinx.coroutines.CoroutineScope coroutineScope, kotlin.coroutines.Continuation<? super kotlin.Unit> continuation) {
                    CactusInitParams params = new CactusInitParams(slug, contextSize);
                    return lm.initializeModel(params, continuation);
                }
            });
            
            isModelInitialized = true;
            JSObject result = new JSObject();
            result.put("success", true);
            // Return the actual model path for reference
            if (modelPath != null) {
                result.put("modelPath", modelPath);
            } else {
                File modelDir = new File(modelsDirectory, slug);
                result.put("modelPath", modelDir.getAbsolutePath());
            }
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error initializing model: " + e.getMessage(), e);
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Error initializing model: " + e.getMessage());
            return result;
        }
    }
    
    public JSObject loadModel(String modelSlug, int contextSize) {
        // Load model from slug (downloaded models)
        return initializeModel(modelSlug, null, contextSize);
    }
    
    public JSObject loadLocalModel(String modelPath, String modelSlug, int contextSize) {
        // Load model from local path (bundled models)
        return initializeModel(modelSlug, modelPath, contextSize);
    }

    public JSObject generateCompletion(JSArray messages, float temperature, int maxTokens, float topP, int topK, JSArray stopSequences, JSArray tools) {
        // Use Cactus SDK to generate completion
        JSObject result = new JSObject();
        
        if (!isModelInitialized) {
            result.put("success", false);
            result.put("error", "No model initialized");
            return result;
        }
        
        Logger.info("Cactus", "Android: Generating completion with " + messages.length() + " messages");
        Logger.info("Cactus", "Android: Temperature: " + temperature + ", Max Tokens: " + maxTokens);
        
        try {
            // Convert JSArray messages to List<ChatMessage>
            List<ChatMessage> chatMessages = new ArrayList<>();
            for (int i = 0; i < messages.length(); i++) {
                try {
                    org.json.JSONObject jsonObj = messages.getJSONObject(i);
                    
                    // Extract required fields
                    String role = jsonObj.getString("role");
                    String content = jsonObj.getString("content");
                    
                    // Extract optional fields with safe defaults
                    String name = jsonObj.optString("name", null);
                    String toolCallId = jsonObj.optString("tool_call_id", null);
                    
                    // Handle images if present
                    org.json.JSONArray imagesArray = jsonObj.optJSONArray("images");
                    List<String> images = new ArrayList<>();
                    if (imagesArray != null) {
                        for (int j = 0; j < imagesArray.length(); j++) {
                            try {
                                images.add(imagesArray.getString(j));
                            } catch (org.json.JSONException e) {
                                // Ignore invalid images
                            }
                        }
                    }
                    
                    chatMessages.add(new ChatMessage(content, role, images, null));
                } catch (org.json.JSONException e) {
                    continue;
                }
            }
            
            // Tools functionality is temporarily disabled due to API uncertainty
            // Convert JSArray tools to List<CactusTool> if present
            // List<CactusTool> cactusTools = new ArrayList<>();
            // if (tools != null && tools.length() > 0) {
            //     for (int i = 0; i < tools.length(); i++) {
            //         JSObject toolObj = tools.getJSObject(i);
            //         JSObject functionObj = toolObj.getJSObject("function");
            //         String name = functionObj.getString("name");
            //         String description = functionObj.getString("description");
            //         JSObject paramsObj = functionObj.getJSObject("parameters");
            //         
            //         // Convert parameters to Map<String, ToolParameter>
            //         Map<String, Object> parameters = new HashMap<>();
            //         if (paramsObj != null) {
            //             for (String key : paramsObj.keys()) {
            //                 JSObject paramObj = paramsObj.getJSObject(key);
            //                 String paramType = paramObj.getString("type");
            //                 String paramDescription = paramObj.getString("description");
            //                 boolean required = paramObj.getBoolean("required", false);
            //                 
            //                 // parameters.put(key, new ToolParameter(paramType, paramDescription, required));
            //             }
            //         }
            //         
            //         cactusTools.add(generateTool(name, description, parameters));
            //     }
            // }
            
            // Convert JSArray stopSequences to List<String>
            List<String> stopSeqList = new ArrayList<>();
            if (stopSequences != null && stopSequences.length() > 0) {
                for (int i = 0; i < stopSequences.length(); i++) {
                    stopSeqList.add(stopSequences.getString(i));
                }
            }
            
            // Create CactusCompletionParams
            CactusCompletionParams params = new CactusCompletionParams(
                null, // model - use current
                temperature > 0 ? (double) temperature : null, // temperature
                topK > 0 ? topK : null, // topK
                topP > 0 ? (double) topP : null, // topP
                maxTokens > 0 ? maxTokens : 512, // maxTokens
                stopSeqList, // stopSequences
                new java.util.ArrayList<>(), // tools - temporarily disabled due to API uncertainty
                com.cactus.InferenceMode.LOCAL, // mode
                null // cactusToken
            );
            
            // Use runBlocking to call suspend function
            final com.cactus.CactusCompletionResult completionResult = BuildersKt.runBlocking(Dispatchers.getIO(), new kotlin.jvm.functions.Function2<kotlinx.coroutines.CoroutineScope, kotlin.coroutines.Continuation<? super com.cactus.CactusCompletionResult>, Object>() {
                @Override
                public Object invoke(kotlinx.coroutines.CoroutineScope coroutineScope, kotlin.coroutines.Continuation<? super com.cactus.CactusCompletionResult> continuation) {
                    return lm.generateCompletion(chatMessages, params, null, continuation);
                }
            });
            
            result.put("success", completionResult.getSuccess());
            result.put("response", completionResult.getResponse() != null ? completionResult.getResponse() : "");
            result.put("timeToFirstTokenMs", completionResult.getTimeToFirstTokenMs());
            result.put("totalTimeMs", completionResult.getTotalTimeMs());
            result.put("tokensPerSecond", completionResult.getTokensPerSecond());
            result.put("prefillTokens", completionResult.getPrefillTokens());
            result.put("decodeTokens", completionResult.getDecodeTokens());
            result.put("totalTokens", completionResult.getTotalTokens());
            
            // Handle tool calls if present
            List<com.cactus.ToolCall> toolCalls = completionResult.getToolCalls();
            if (toolCalls != null && !toolCalls.isEmpty()) {
                JSArray toolCallsArray = new JSArray();
                for (com.cactus.ToolCall toolCall : toolCalls) {
                    JSObject toolCallObj = new JSObject();
                    toolCallObj.put("name", toolCall.getName());
                    
                    JSObject argumentsObj = new JSObject();
                    for (Map.Entry<String, String> entry : toolCall.getArguments().entrySet()) {
                        argumentsObj.put(entry.getKey(), entry.getValue());
                    }
                    toolCallObj.put("arguments", argumentsObj);
                    
                    toolCallsArray.put(toolCallObj);
                }
                result.put("toolCalls", toolCallsArray);
            }
            
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error generating completion: " + e.getMessage(), e);
            result.put("success", false);
            result.put("error", "Error generating completion: " + e.getMessage());
            return result;
        }
    }
    
    public JSObject generateStreamingCompletion(JSArray messages, float temperature, int maxTokens, float topP, int topK, JSArray stopSequences, JSArray tools, com.getcapacitor.PluginCall call) {
        // Use Cactus SDK to generate streaming completion
        JSObject result = new JSObject();
        
        if (!isModelInitialized) {
            result.put("success", false);
            result.put("error", "No model initialized");
            return result;
        }
        
        Logger.info("Cactus", "Android: Generating streaming completion with " + messages.length() + " messages");
        
        try {
            // Convert JSArray messages to List<ChatMessage>
            List<ChatMessage> chatMessages = new ArrayList<>();
            for (int i = 0; i < messages.length(); i++) {
                try {
                    org.json.JSONObject jsonObj = messages.getJSONObject(i);
                    
                    // Extract required fields
                    String role = jsonObj.getString("role");
                    String content = jsonObj.getString("content");
                    
                    // Extract optional fields with safe defaults
                    jsonObj.optString("name", null); // Not used in current implementation
                    jsonObj.optString("tool_call_id", null); // Not used in current implementation
                    
                    // Handle images if present
                    org.json.JSONArray imagesArray = jsonObj.optJSONArray("images");
                    List<String> images = new ArrayList<>();
                    if (imagesArray != null) {
                        for (int j = 0; j < imagesArray.length(); j++) {
                            try {
                                images.add(imagesArray.getString(j));
                            } catch (org.json.JSONException e) {
                                // Ignore invalid images
                            }
                        }
                    }
                    
                    chatMessages.add(new ChatMessage(content, role, images, null));
                } catch (org.json.JSONException e) {
                    continue;
                }
            }
            
            // Tools functionality is temporarily disabled due to API uncertainty
            // Convert JSArray stopSequences to List<String>
            List<String> stopSeqList = new ArrayList<>();
            if (stopSequences != null && stopSequences.length() > 0) {
                for (int i = 0; i < stopSequences.length(); i++) {
                    stopSeqList.add(stopSequences.getString(i));
                }
            }
            
            // Create CactusCompletionParams
            CactusCompletionParams params = new CactusCompletionParams(
                null, // model - use current
                temperature > 0 ? (double) temperature : null, // temperature
                topK > 0 ? topK : null, // topK
                topP > 0 ? (double) topP : null, // topP
                maxTokens > 0 ? maxTokens : 512, // maxTokens
                stopSeqList, // stopSequences
                new java.util.ArrayList<>(), // tools - temporarily disabled
                com.cactus.InferenceMode.LOCAL, // mode
                null // cactusToken
            );
            
            // Use the streaming API with onToken callback
            new Thread(() -> {
                try {
                    // Send start event to JavaScript
                    JSObject startData = new JSObject();
                    startData.put("type", "start");
                    plugin.notifyListeners("cactusStreamingResponse", startData);
                    
                    // Use runBlocking to call suspend function
                            final com.cactus.CactusCompletionResult completionResult = BuildersKt.runBlocking(Dispatchers.getIO(), new kotlin.jvm.functions.Function2<kotlinx.coroutines.CoroutineScope, kotlin.coroutines.Continuation<? super com.cactus.CactusCompletionResult>, Object>() {
                                @Override
                                public Object invoke(kotlinx.coroutines.CoroutineScope coroutineScope, kotlin.coroutines.Continuation<? super com.cactus.CactusCompletionResult> continuation) {
                                    // Create a Function2<String, UInt, Unit> callback as required by the Kotlin API
                                    kotlin.jvm.functions.Function2<String, kotlin.UInt, Unit> onTokenCallback = new kotlin.jvm.functions.Function2<String, kotlin.UInt, Unit>() {
                                        @Override
                                        public Unit invoke(String token, kotlin.UInt tokenId) {
                                            // Send token event to JavaScript
                                    JSObject tokenData = new JSObject();
                                    tokenData.put("type", "token");
                                    tokenData.put("token", token);
                                    plugin.notifyListeners("cactusStreamingResponse", tokenData);
                                            return Unit.INSTANCE;
                                        }
                                    };
                                    return lm.generateCompletion(chatMessages, params, onTokenCallback, continuation);
                                }
                            });
                    
                    // Send done event with final completion result
                    JSObject doneData = new JSObject();
                    doneData.put("type", "done");
                    doneData.put("success", completionResult.getSuccess());
                    doneData.put("response", completionResult.getResponse() != null ? completionResult.getResponse() : "");
                    doneData.put("modelSlug", currentModelSlug);
                    doneData.put("generationMetrics", new JSObject() {
                        {
                            put("totalTimeMs", completionResult.getTotalTimeMs());
                            put("tokensPerSecond", completionResult.getTokensPerSecond());
                            put("timeToFirstTokenMs", completionResult.getTimeToFirstTokenMs());
                            put("prefillTokens", completionResult.getPrefillTokens());
                            put("decodeTokens", completionResult.getDecodeTokens());
                            put("totalTokens", completionResult.getTotalTokens());
                        }
                    });
                    plugin.notifyListeners("cactusStreamingResponse", doneData);
                } catch (Exception e) {
                    Logger.error("Android: Error in streaming completion: " + e.getMessage(), e);
                    JSObject eventData = new JSObject();
                    eventData.put("type", "error");
                    eventData.put("error", "Error in streaming completion: " + e.getMessage());
                    plugin.notifyListeners("cactusStreamingResponse", eventData);
                }
            }).start();
            
            result.put("success", true);
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error generating streaming completion: " + e.getMessage(), e);
            result.put("success", false);
            result.put("error", "Error generating streaming completion: " + e.getMessage());
            return result;
        }
    }

    public JSObject transcribeAudio(String audioPath, String prompt, String language, float temperature, int maxTokens) {
        // Use Cactus SDK to transcribe audio
        Logger.info("Cactus", "Android: Transcribing audio from path: " + audioPath);
        
        try {
            // Create transcription params
            com.cactus.CactusTranscriptionParams params = new com.cactus.CactusTranscriptionParams();
            // Max tokens is not supported in transcription parameters
            
            // Use runBlocking to call suspend function
            final com.cactus.CactusTranscriptionResult transcriptionResult = BuildersKt.runBlocking(Dispatchers.getIO(), new kotlin.jvm.functions.Function2<kotlinx.coroutines.CoroutineScope, kotlin.coroutines.Continuation<? super com.cactus.CactusTranscriptionResult>, Object>() {
                @Override
                public Object invoke(kotlinx.coroutines.CoroutineScope coroutineScope, kotlin.coroutines.Continuation<? super com.cactus.CactusTranscriptionResult> continuation) {
                    return stt.transcribe(
                        audioPath,
                        prompt != null ? prompt : "<|startoftranscript|><|en|><|transcribe|><|notimestamps|>",
                        params,
                        null, // onToken callback
                        com.cactus.TranscriptionMode.LOCAL,
                        null, // apiKey
                        continuation
                    );
                }
            });
            
            JSObject result = new JSObject();
            result.put("success", transcriptionResult.getSuccess());
            result.put("transcription", transcriptionResult.getText() != null ? transcriptionResult.getText() : "");
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error transcribing audio: " + e.getMessage(), e);
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Error transcribing audio: " + e.getMessage());
            return result;
        }
    }

    public JSObject unloadModel() {
        // Use Cactus SDK to unload the model
        Logger.info("Cactus", "Android: Unloading model");
        
        try {
            lm.unload();
            isModelInitialized = false;
            currentModelSlug = null;
            
            JSObject result = new JSObject();
            result.put("success", true);
            result.put("message", "Model unloaded successfully");
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error unloading model: " + e.getMessage(), e);
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("message", "Error unloading model: " + e.getMessage());
            return result;
        }
    }

    public JSObject getTextEmbeddings(String text) {
        // Use Cactus SDK to generate text embeddings
        Logger.info("Cactus", "Android: Generating embeddings for text: " + text);
        
        try {
            // Use runBlocking to call suspend function
            final com.cactus.CactusEmbeddingResult embeddingResult = BuildersKt.runBlocking(Dispatchers.getIO(), new kotlin.jvm.functions.Function2<kotlinx.coroutines.CoroutineScope, kotlin.coroutines.Continuation<? super com.cactus.CactusEmbeddingResult>, Object>() {
                @Override
                public Object invoke(kotlinx.coroutines.CoroutineScope coroutineScope, kotlin.coroutines.Continuation<? super com.cactus.CactusEmbeddingResult> continuation) {
                    return lm.generateEmbedding(text, null, continuation);
                }
            });
            
            JSObject result = new JSObject();
            result.put("success", embeddingResult.getSuccess());
            
            // Convert List<Double> to JSArray
            JSArray embeddingsArray = new JSArray();
            for (Double value : embeddingResult.getEmbeddings()) {
                embeddingsArray.put(value);
            }
            result.put("embeddings", embeddingsArray);
            
            return result;
        } catch (Exception e) {
            Logger.error("Android: Error generating embeddings: " + e.getMessage(), e);
            JSObject result = new JSObject();
            result.put("success", false);
            result.put("error", "Error generating embeddings: " + e.getMessage());
            return result;
        }
    }
    
    // Image and audio embeddings are not supported in the current Cactus SDK version

    // Helper method to generate CactusTool from parameters
    private Object generateTool(String name, String description, Map<String, Object> parameters) {
        // This is a placeholder - CactusTool API seems different in the current SDK version
        // For now, we'll return null since the exact API isn't clear
        return null;
    }
}
