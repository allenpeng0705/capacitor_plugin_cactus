package com.tripwiki.plugins.cactus;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Logger;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import android.content.Context;
import com.cactus.CactusContextInitializer;

@CapacitorPlugin(name = "CactusCap")
public class CactusPlugin extends Plugin {
    private CactusCap implementation;
    
    @Override
    public void load() {
        super.load();
        // Initialize CactusContext first
        Context context = getContext();
        try {
            CactusContextInitializer.INSTANCE.initialize(context);
            Logger.info("Cactus", "CactusPlugin: CactusContextInitializer initialized successfully");
        } catch (Exception e) {
            Logger.error("Cactus", "CactusPlugin: Failed to initialize CactusContextInitializer: " + e.getMessage(), e);
        }
        
        // Initialize the implementation with the plugin's context and plugin reference
        implementation = new CactusCap(context, this);
        Logger.info("Cactus", "CactusPlugin: Loaded and initialized CactusCap");
    }
    
    // Public method to forward notifyListeners calls from CactusCap
    public void notifyListeners(String eventName, JSObject data) {
        super.notifyListeners(eventName, data);
    }


    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");
        JSObject ret = new JSObject();
        ret.put("value", implementation.echo(value));
        call.resolve(ret);
    }

    @PluginMethod
    public void downloadModel(PluginCall call) {
        String modelSlug = call.getString("modelSlug");
        call.resolve(implementation.downloadModel(modelSlug));
    }

    @PluginMethod
    public void getAvailableModels(PluginCall call) {
        JSObject result = implementation.getAvailableModels();
        call.resolve(result);
    }

    @PluginMethod
    public void initializeModel(PluginCall call) {
        String modelSlug = call.getString("modelSlug");
        String modelPath = call.getString("modelPath");
        int contextSize = call.getInt("contextSize", 2048);
        JSObject result = implementation.initializeModel(modelSlug, modelPath, contextSize);
        call.resolve(result);
    }
    
    @PluginMethod
    public void loadModel(PluginCall call) {
        String modelSlug = call.getString("modelSlug");
        if (modelSlug == null) {
            call.reject("modelSlug is required");
            return;
        }
        int contextSize = call.getInt("contextSize", 2048);
        JSObject result = implementation.loadModel(modelSlug, contextSize);
        call.resolve(result);
    }
    
    @PluginMethod
    public void loadLocalModel(PluginCall call) {
        String modelPath = call.getString("modelPath");
        if (modelPath == null) {
            call.reject("modelPath is required");
            return;
        }
        String modelSlug = call.getString("modelSlug");
        int contextSize = call.getInt("contextSize", 2048);
        JSObject result = implementation.loadLocalModel(modelPath, modelSlug, contextSize);
        call.resolve(result);
    }

    @PluginMethod
    public void generateCompletion(PluginCall call) {
        JSArray messages = call.getArray("messages");
        float temperature = call.getFloat("temperature", 0.7f);
        int maxTokens = call.getInt("maxTokens", 100);
        float topP = call.getFloat("topP", 0.0f);
        int topK = call.getInt("topK", 0);
        JSArray stopSequences = call.getArray("stopSequences");
        JSArray tools = call.getArray("tools");
        
        JSObject result = implementation.generateCompletion(messages, temperature, maxTokens, topP, topK, stopSequences, tools);
        call.resolve(result);
    }
    
    @PluginMethod
    public void generateStreamingCompletion(PluginCall call) {
        JSArray messages = call.getArray("messages");
        float temperature = call.getFloat("temperature", 0.7f);
        int maxTokens = call.getInt("maxTokens", 100);
        float topP = call.getFloat("topP", 0.0f);
        int topK = call.getInt("topK", 0);
        JSArray stopSequences = call.getArray("stopSequences");
        JSArray tools = call.getArray("tools");
        
        JSObject result = implementation.generateStreamingCompletion(messages, temperature, maxTokens, topP, topK, stopSequences, tools, call);
        call.resolve(result);
    }

    @PluginMethod
    public void transcribeAudio(PluginCall call) {
        String audioPath = call.getString("audioPath");
        String prompt = call.getString("prompt");
        String language = call.getString("language");
        float temperature = call.getFloat("temperature", 0.0f);
        int maxTokens = call.getInt("maxTokens", 0);
        JSObject result = implementation.transcribeAudio(audioPath, prompt, language, temperature, maxTokens);
        call.resolve(result);
    }

    @PluginMethod
    public void unloadModel(PluginCall call) {
        JSObject result = implementation.unloadModel();
        call.resolve(result);
    }

    @PluginMethod
    public void getTextEmbeddings(PluginCall call) {
        String text = call.getString("text");
        JSObject result = implementation.getTextEmbeddings(text);
        call.resolve(result);
    }

    // Image and audio embeddings are not supported in the current Cactus SDK version

    // Download management methods
    @PluginMethod
    public void pauseDownload(PluginCall call) {
        String modelSlug = call.getString("modelSlug");
        JSObject result = implementation.pauseDownload(modelSlug);
        call.resolve(result);
    }

    @PluginMethod
    public void resumeDownload(PluginCall call) {
        String modelSlug = call.getString("modelSlug");
        JSObject result = implementation.resumeDownload(modelSlug);
        call.resolve(result);
    }

    @PluginMethod
    public void cancelDownload(PluginCall call) {
        String modelSlug = call.getString("modelSlug");
        JSObject result = implementation.cancelDownload(modelSlug);
        call.resolve(result);
    }

    @PluginMethod
    public void getDownloadProgress(PluginCall call) {
        String modelSlug = call.getString("modelSlug");
        JSObject result = implementation.getDownloadProgress(modelSlug);
        call.resolve(result);
    }
}
