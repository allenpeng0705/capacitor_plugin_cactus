import Foundation
@preconcurrency import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CactusPlugin)
public class CactusPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "CactusPlugin"
    public let jsName = "CactusCap"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "downloadModel", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getAvailableModels", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "initializeModel", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "loadModel", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "loadLocalModel", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "generateCompletion", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "generateStreamingCompletion", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "transcribeAudio", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "unloadModel", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getTextEmbeddings", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getImageEmbeddings", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getAudioEmbeddings", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "pauseDownload", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "resumeDownload", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "cancelDownload", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getDownloadProgress", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = CactusCap()
    private var streamingNotificationObserver: Any?

    @objc override public func load() {
        super.load()
        
        // Listen for download progress notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDownloadProgress),
            name: Notification.Name("modelDownloadProgress"),
            object: nil
        )
        
        // Listen for download completion notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDownloadFinished),
            name: Notification.Name("modelDownloadFinished"),
            object: nil
        )
    }
    
    @objc public func unload() {
        // Remove observers when plugin is unloaded
        NotificationCenter.default.removeObserver(self)
        
        // Remove streaming notification observer if it exists
        if let observer = streamingNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
            streamingNotificationObserver = nil
        }
    }
    
    @objc func handleDownloadProgress(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            notifyListeners("modelDownloadProgress", data: userInfo)
        }
    }
    
    @objc func handleDownloadFinished(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            notifyListeners("modelDownloadFinished", data: userInfo)
        }
    }

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

    @objc func downloadModel(_ call: CAPPluginCall) {
        let modelSlug = call.getString("modelSlug")
        implementation.downloadModel(modelSlug: modelSlug) { result in
            call.resolve(result)
        }
    }

    @objc func getAvailableModels(_ call: CAPPluginCall) {
        let result = implementation.getAvailableModels()
        call.resolve(result)
    }

    @objc func initializeModel(_ call: CAPPluginCall) {
        let modelSlug = call.getString("modelSlug")
        let modelPath = call.getString("modelPath")
        let contextSize = call.getInt("contextSize") ?? 2048
        implementation.initializeModel(modelSlug: modelSlug, modelPath: modelPath, contextSize: contextSize) { result in
            call.resolve(result)
        }
    }
    
    @objc func loadModel(_ call: CAPPluginCall) {
        guard let modelSlug = call.getString("modelSlug") else {
            call.reject("modelSlug is required")
            return
        }
        let contextSize = call.getInt("contextSize") ?? 2048
        implementation.loadModel(modelSlug: modelSlug, contextSize: contextSize) { result in
            call.resolve(result)
        }
    }
    
    @objc func loadLocalModel(_ call: CAPPluginCall) {
        guard let modelPath = call.getString("modelPath") else {
            call.reject("modelPath is required")
            return
        }
        let modelSlug = call.getString("modelSlug")
        let contextSize = call.getInt("contextSize") ?? 2048
        implementation.loadLocalModel(modelPath: modelPath, modelSlug: modelSlug, contextSize: contextSize) { result in
            call.resolve(result)
        }
    }

    @objc func generateCompletion(_ call: CAPPluginCall) {
        guard let messages = call.getArray("messages") as? [[String: Any]] else {
            call.resolve([
                "success": false,
                "response": "",
                "error": "Invalid messages format"
            ])
            return
        }
        
        let temperature = call.getFloat("temperature") ?? 0.7
        let maxTokens = call.getInt("maxTokens") ?? 100
        let topP = call.getFloat("topP") ?? 0.9
        let topK = call.getInt("topK") ?? 40
        let stopSequences = call.getArray("stopSequences") as? [String]
        let tools = call.getArray("tools") as? [[String: Any]]
        
        implementation.generateCompletion(
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens,
            topP: topP,
            topK: topK,
            stopSequences: stopSequences,
            tools: tools
        ) { result in
            call.resolve(result)
        }
    }

    @objc func generateStreamingCompletion(_ call: CAPPluginCall) {
        guard let messages = call.getArray("messages") as? [[String: Any]] else {
            call.resolve([
                "success": false,
                "error": "Invalid messages format"
            ])
            return
        }
        
        let temperature = call.getFloat("temperature") ?? 0.7
        let maxTokens = call.getInt("maxTokens") ?? 100
        let topP = call.getFloat("topP") ?? 0.9
        let topK = call.getInt("topK") ?? 40
        let stopSequences = call.getArray("stopSequences") as? [String]
        let tools = call.getArray("tools") as? [[String: Any]]
        
        // Set up notification observer for streaming events
        let eventName = "cactusStreamingResponse"
        
        // Clean up any existing observer first
        if let observer = streamingNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // Remove any existing observer first
        if let observer = streamingNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
            streamingNotificationObserver = nil
        }
        
        // Add new observer for streaming notifications
        streamingNotificationObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name(eventName),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let userInfo = notification.userInfo as? [String: Any] {
                self?.notifyListeners(eventName, data: userInfo)
            }
        }
        
        // Create a local reference to the completion call
        let completionCall = call
        
        implementation.generateStreamingCompletion(
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens,
            topP: topP,
            topK: topK,
            stopSequences: stopSequences,
            tools: tools,
            eventName: eventName
        ) { result in
            // Resolve the call with the result
            completionCall.resolve(result)
        }
    }

    @objc func transcribeAudio(_ call: CAPPluginCall) {
        guard let audioPath = call.getString("audioPath") else {
            call.reject("audioPath is required")
            return
        }
        
        let prompt = call.getString("prompt")
        let language = call.getString("language")
        let temperature = call.getFloat("temperature") ?? 0.6
        let maxTokens = call.getInt("maxTokens") ?? 200
        
        implementation.transcribeAudio(
            audioPath: audioPath,
            prompt: prompt,
            language: language,
            temperature: temperature,
            maxTokens: maxTokens
        ) { result in
            call.resolve(result)
        }
    }

    @objc func pauseDownload(_ call: CAPPluginCall) {
        let result = implementation.pauseDownload()
        call.resolve(result)
    }

    @objc func resumeDownload(_ call: CAPPluginCall) {
        let result = implementation.resumeDownload()
        call.resolve(result)
    }

    @objc func cancelDownload(_ call: CAPPluginCall) {
        let result = implementation.cancelDownload()
        call.resolve(result)
    }

    @objc func getDownloadProgress(_ call: CAPPluginCall) {
        let result = implementation.getDownloadProgress()
        call.resolve(result)
    }

    @objc func unloadModel(_ call: CAPPluginCall) {
        let result = implementation.unloadModel()
        call.resolve(result)
    }
    
    @objc func getTextEmbeddings(_ call: CAPPluginCall) {
        guard let text = call.getString("text") else {
            call.resolve([
                "success": false,
                "error": "text parameter is required"
            ])
            return
        }
        implementation.getTextEmbeddings(text: text) { result in
            call.resolve(result)
        }
    }
    
    @objc func getImageEmbeddings(_ call: CAPPluginCall) {
        guard let imagePath = call.getString("imagePath") else {
            call.resolve([
                "success": false,
                "error": "imagePath parameter is required"
            ])
            return
        }
        implementation.getImageEmbeddings(imagePath: imagePath) { result in
            call.resolve(result)
        }
    }
    
    @objc func getAudioEmbeddings(_ call: CAPPluginCall) {
        guard let audioPath = call.getString("audioPath") else {
            call.resolve([
                "success": false,
                "error": "audioPath parameter is required"
            ])
            return
        }
        implementation.getAudioEmbeddings(audioPath: audioPath) { result in
            call.resolve(result)
        }
    }
}