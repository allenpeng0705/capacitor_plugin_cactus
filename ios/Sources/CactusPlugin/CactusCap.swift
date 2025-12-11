import Foundation
import Capacitor
import Logging

// Conditional import for Cactus module - needed when built with Swift Package Manager
// but not when built as CocoaPod (where Cactus sources are included directly)
#if canImport(Cactus)
import Cactus
#endif

// Set up logging
fileprivate let logger = Logger(label: "CactusCap")

@objc(CactusCap)
public class CactusCap: NSObject, @unchecked Sendable {
    private var languageModel: CactusLanguageModel?
    private let languageModelLock = NSLock()
    
    // Strong reference to keep model alive
    private var strongModelReference: CactusLanguageModel?
    
    // Debug info
    override init() {
        //print("[DEBUG] CactusCap initialized with Cactus framework version: \(Cactus.version)")
        super.init()
    }
    
    // MARK: - Basic Methods
    
    public func echo(_ value: String) -> String {
        return value
    }
    
    // MARK: - Model Management
    
    // MARK: - Download Management
    
    private var activeDownloadTasks: [String: CactusLanguageModel.DownloadTask] = [:]
    
    public func downloadModel(modelSlug: String?, completion: @escaping @Sendable ([String: Any]) -> Void) {
        guard let modelSlug = modelSlug else {
            completion([
                "success": false,
                "error": "Model slug is required"
            ])
            return
        }
        
        logger.info("Starting model download for slug: \(modelSlug)")
        
        // Check if a model with the same slug already exists
        if let existingModelURL = CactusModelsDirectory.shared.storedModelURL(for: modelSlug) {
            logger.info("Found existing model at: \(existingModelURL.path)")
            logger.info("Using existing model without downloading")
            
            // Return the existing model directly
            let result: [String: Any] = [
                "success": true,
                "modelPath": existingModelURL.path,
                "modelName": existingModelURL.lastPathComponent,
                "modelSlug": modelSlug
            ]
            
            DispatchQueue.main.async {
                completion(result)
            }
            return
        }
        
        // Create destination URL using CactusModelsDirectory's public baseURL
        let destinationURL = CactusModelsDirectory.shared.baseURL.appendingPathComponent(modelSlug, isDirectory: true)
        
        // Check if model already exists
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        let modelExists = fileManager.fileExists(atPath: destinationURL.path, isDirectory: &isDirectory)
        logger.info("iOS: Model already exists at \(destinationURL.path): \(modelExists)")
        
        if modelExists && isDirectory.boolValue {
            do {
                let contents = try fileManager.contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: nil)
                logger.info("iOS: Existing model files count: \(contents.count)")
                for file in contents {
                    let attributes = try fileManager.attributesOfItem(atPath: file.path)
                    let fileSize = attributes[.size] as? Int64 ?? 0
                    logger.info("iOS: Existing file: \(file.lastPathComponent) (\(fileSize) bytes)")
                }
            } catch {
                logger.error("iOS: Error checking existing model files: \(error.localizedDescription)")
            }
        } else {
            logger.info("iOS: Model not found, starting download...")
        }
        
        // Create download task using the reference implementation
        let downloadTask = CactusLanguageModel.downloadModelTask(slug: modelSlug, to: destinationURL)
        
        // Store active download task
        activeDownloadTasks[modelSlug] = downloadTask
        
        // Subscribe to progress updates
        let progressSubscription = downloadTask.onProgress { @Sendable [weak self] progressResult in
            switch progressResult {
            case .success(let progress):
                self?.handleDownloadProgress(progress, for: modelSlug)
            case .failure(let error):
                logger.error("Download progress error: \(error.localizedDescription)")
            }
        }
        
        // Start download and wait for completion
        Task {
            let startTime = Date()
            
            do {
                // Resume the download task
                downloadTask.resume()
                
                // Wait for completion using the reference implementation's async method
                let downloadedURL = try await CactusLanguageModel.downloadModel(
                    slug: modelSlug,
                    to: destinationURL,
                    onProgress: { @Sendable [weak self] progressResult in
                        switch progressResult {
                        case .success(let progress):
                            self?.handleDownloadProgress(progress, for: modelSlug)
                        case .failure(let error):
                            logger.error("Download progress error: \(error.localizedDescription)")
                        }
                    }
                )
                
                let downloadTime = Date().timeIntervalSince(startTime) * 1000 // Convert to ms
                
                // Log completion
                logger.info("Model download completed successfully in \(downloadTime) ms")
                logger.info("Final model path: \(downloadedURL.path)")
                logger.info("Model name: \(downloadedURL.lastPathComponent)")
                
                // Check final model files
                do {
                    let contents = try fileManager.contentsOfDirectory(at: downloadedURL, includingPropertiesForKeys: nil)
                    logger.info("iOS: Final model files count: \(contents.count)")
                    for file in contents {
                        let attributes = try fileManager.attributesOfItem(atPath: file.path)
                        let fileSize = attributes[.size] as? Int64 ?? 0
                        logger.info("iOS: Final file: \(file.lastPathComponent) (\(fileSize) bytes)")
                    }
                } catch {
                    logger.error("iOS: Error checking final model files: \(error.localizedDescription)")
                }
                
                // Clean up
                progressSubscription.cancel()
                activeDownloadTasks.removeValue(forKey: modelSlug)
                
                // Prepare and return successful completion result
                let result: [String: Any] = [
                    "success": true,
                    "modelPath": downloadedURL.path,
                    "modelName": downloadedURL.lastPathComponent,
                    "modelSlug": modelSlug
                ]
                
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                // Handle cancellation error specifically
                if error is CancellationError {
                    logger.info("Model download cancelled for slug: \(modelSlug)")
                    let result: [String: Any] = [
                        "success": false,
                        "error": "Download cancelled",
                        "cancelled": true,
                        "modelSlug": modelSlug
                    ]
                    DispatchQueue.main.async {
                        completion(result)
                    }
                } else {
                    // Log other errors
                    logger.error("Error downloading model: \(error.localizedDescription)")
                    
                    // Return error completion result
                    let errorResult: [String: Any] = [
                        "success": false,
                        "error": error.localizedDescription,
                        "modelSlug": modelSlug
                    ]
                    DispatchQueue.main.async {
                        completion(errorResult)
                    }
                }
                
                // Clean up
                progressSubscription.cancel()
                activeDownloadTasks.removeValue(forKey: modelSlug)
            }
        }
    }
    
    /// Handles download progress updates
    private func handleDownloadProgress(_ progress: CactusLanguageModel.DownloadProgress, for modelSlug: String) {
        switch progress {
        case .downloading(let fraction):
            logger.debug("Downloading progress for \(modelSlug): \(fraction * 100)%")
            // Notify listeners about download progress
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("modelDownloadProgress"),
                    object: nil,
                    userInfo: [
                        "modelSlug": modelSlug,
                        "stage": "downloading",
                        "progress": fraction
                    ]
                )
            }
        case .unzipping(let fraction):
            logger.debug("Unzipping progress for \(modelSlug): \(fraction * 100)%")
            // Notify listeners about unzip progress
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("modelDownloadProgress"),
                    object: nil,
                    userInfo: [
                        "modelSlug": modelSlug,
                        "stage": "unzipping",
                        "progress": fraction
                    ]
                )
            }
        case .finished(let url):
            logger.debug("Download finished for \(modelSlug) at: \(url.path)")
            // Notify listeners about download completion
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("modelDownloadFinished"),
                    object: nil,
                    userInfo: [
                        "modelSlug": modelSlug,
                        "modelPath": url.path
                    ]
                )
            }
        }
    }
    
    /// Pauses a download for a specific model slug
    public func pauseDownload() -> [String: Any] {
        // Pause all active downloads
        for (modelSlug, downloadTask) in activeDownloadTasks {
            downloadTask.pause()
            logger.info("Paused download for model: \(modelSlug)")
        }
        
        return [
            "success": true,
            "message": "All downloads paused"
        ]
    }
    
    public func resumeDownload() -> [String: Any] {
        // Resume all paused downloads
        for (modelSlug, downloadTask) in activeDownloadTasks {
            downloadTask.resume()
            logger.info("Resumed download for model: \(modelSlug)")
        }
        
        return [
            "success": true,
            "message": "All downloads resumed"
        ]
    }
    
    public func cancelDownload() -> [String: Any] {
        // Cancel all active downloads
        for (modelSlug, downloadTask) in activeDownloadTasks {
            downloadTask.cancel()
            logger.info("Cancelled download for model: \(modelSlug)")
        }
        
        return [
            "success": true,
            "message": "All downloads cancelled"
        ]
    }
    
    public func getDownloadProgress() -> [String: Any] {
        // Get progress for all active downloads
        var allProgress: [String: Any] = [:]
        
        for (modelSlug, downloadTask) in activeDownloadTasks {
            let progress = downloadTask.currentProgress
            var progressInfo: [String: Any] = [
                "isCancelled": downloadTask.isCancelled,
                "isPaused": downloadTask.isPaused,
                "isFinished": downloadTask.isFinished
            ]
            
            switch progress {
            case .downloading(let fraction):
                progressInfo["stage"] = "downloading"
                progressInfo["progress"] = fraction
            case .unzipping(let fraction):
                progressInfo["stage"] = "unzipping"
                progressInfo["progress"] = fraction
            case .finished(let url):
                progressInfo["stage"] = "finished"
                progressInfo["modelPath"] = url.path
            }
            
            allProgress[modelSlug] = progressInfo
        }
        
        return [
            "success": true,
            "progress": allProgress
        ]
    }
    
    public func getAvailableModels() -> [String: Any] {
        let models = CactusModelsDirectory.shared.storedModels()
        let modelList = models.map { model in
            [
                "slug": model.slug,
                "path": model.url.path
            ] as [String: Any]
        }
            
        return [
            "success": true,
            "models": modelList
        ]
    }
    
    public func initializeModel(modelSlug: String?, modelPath: String?, contextSize: Int, completion: @escaping @Sendable ([String: Any]) -> Void) {
        // First, unload any existing model
        unloadModel()
        
        // Use Task directly without DispatchQueue to avoid unnecessary thread hopping
        Task {
            do {
                let modelURL: URL
                let resolvedSlug: String
                
                if let path = modelPath {
                    modelURL = URL(fileURLWithPath: path)
                    resolvedSlug = modelSlug ?? "local-model"
                } else if let slug = modelSlug {
                    modelURL = try await CactusModelsDirectory.shared.modelURL(for: slug)
                    resolvedSlug = slug
                } else {
                    // Try to find a model in the models directory
                    let models = try FileManager.default.contentsOfDirectory(at: CactusModelsDirectory.shared.baseURL, includingPropertiesForKeys: nil)
                    let ggufModels = models.filter { $0.pathExtension == "gguf" }
                    
                    guard !ggufModels.isEmpty else {
                        throw NSError(domain: "CactusCap", code: 2, userInfo: [NSLocalizedDescriptionKey: "No GGUF model found in models directory"])
                    }
                    
                    modelURL = ggufModels.first!
                    resolvedSlug = modelURL.lastPathComponent
                }
                
                // Initialize the model using the convenience init
                let model = try CactusLanguageModel(
                    from: modelURL,
                    contextSize: contextSize,
                    modelSlug: resolvedSlug
                )
                
                // Ensure thread-safe access to languageModel
                self.languageModelLock.withLock {
                    self.languageModel = model
                    self.strongModelReference = model // Store strong reference
                }
                
                print("[DEBUG] Model initialized successfully with context size: \(model.configuration.contextSize)")
                
                // Return result on main thread
                await MainActor.run {
                    completion(["success": true])
                }
            } catch {
                logger.error("Error initializing model: \(error.localizedDescription)")
                
                // Return error on main thread
                await MainActor.run {
                    completion([
                        "success": false,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }
    
    public func loadModel(modelSlug: String, contextSize: Int, completion: @escaping @Sendable ([String: Any]) -> Void) {
        // Load model from slug (downloaded models)
        self.initializeModel(modelSlug: modelSlug, modelPath: nil, contextSize: contextSize, completion: completion)
    }
    
    public func loadLocalModel(modelPath: String, modelSlug: String?, contextSize: Int, completion: @escaping @Sendable ([String: Any]) -> Void) {
        // Load model from local path (bundled models)
        self.initializeModel(modelSlug: modelSlug, modelPath: modelPath, contextSize: contextSize, completion: completion)
    }
    
    public func unloadModel() -> [String: Any] {
        self.languageModelLock.lock()
        defer { self.languageModelLock.unlock() }
        
        guard let model = self.languageModel else {
            return ["success": false, "error": "No model loaded"]
        }
        // There's no explicit unloadModel method in CactusLanguageModel
        // Instead, we'll stop any ongoing generation, reset the context, and release the model reference
        model.stop()
        model.reset()
        self.languageModel = nil
        return ["success": true]
    }
    
    // MARK: - Generation Methods
    
    public func generateCompletion(
        messages: [[String: Any]],
        temperature: Float,
        maxTokens: Int,
        topP: Float,
        topK: Int,
        stopSequences: [String]?,
        tools: [[String: Any]]?,
        completion: @escaping @Sendable ([String: Any]) -> Void
    ) {
        print("[DEBUG] generateCompletion called with messages: \(messages), temperature: \(temperature), maxTokens: \(maxTokens), tools: \(tools)")
        
        // First, check if model exists and create a strong reference
        let model: CactusLanguageModel? = self.languageModelLock.withLock {
            self.languageModel
        }
        
        print("[DEBUG] Model loaded: \(model != nil)")
        
        guard let model = model else {
            completion([
                "success": false,
                "error": "Model not initialized"
            ])
            return
        }
        
        //print("[DEBUG] languageModel is nil: \(model == nil)")
        
        do {
            // Convert messages to CactusLanguageModel.ChatMessage format before creating Task
            let chatMessages = try messages.map { message -> CactusLanguageModel.ChatMessage in
                guard let roleStr = message["role"] as? String, 
                      let content = message["content"] as? String else {
                    throw NSError(domain: "CactusCap", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid message format"])
                }
                
                print("[DEBUG] Converting message: role=\(roleStr), content=\(content)")
                
                // Use the safer convenience methods instead of direct initializer
                switch roleStr {
                case "system":
                    return CactusLanguageModel.ChatMessage.system(content)
                case "user":
                    return CactusLanguageModel.ChatMessage.user(content)
                case "assistant":
                    return CactusLanguageModel.ChatMessage.assistant(content)
                default:
                    throw NSError(domain: "CactusCap", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid role: \(roleStr)"])
                }
            }
            
            print("[DEBUG] Converted chat messages: \(chatMessages)")
            
            // Prepare options
            var options = CactusLanguageModel.InferenceOptions(
                maxTokens: maxTokens,
                temperature: temperature,
                topP: topP,
                topK: topK,
                stopSequences: CactusLanguageModel.InferenceOptions.defaultStopSequences
            )
            
            if let stopSequences = stopSequences {
                options.stopSequences = stopSequences
            }
            
            print("[DEBUG] Inference options: \(options)")
            
            // Prepare functions if provided
            var functionDefinitions: [CactusLanguageModel.FunctionDefinition] = []
            if let tools = tools {
                functionDefinitions = try tools.map { tool -> CactusLanguageModel.FunctionDefinition in
                    guard let type = tool["type"] as? String, 
                          let function = tool["function"] as? [String: Any] else {
                        throw NSError(domain: "CactusCap", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid tool format"])
                    }
                    
                    guard type == "function" else {
                        throw NSError(domain: "CactusCap", code: 0, userInfo: [NSLocalizedDescriptionKey: "Only function tools are supported"])
                    }
                    
                    guard let name = function["name"] as? String, 
                          let description = function["description"] as? String else {
                        throw NSError(domain: "CactusCap", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid function format"])
                    }
                    
                    // Create a simple object schema for parameters (using default JSONSchema for now)
                    let functionDef = CactusLanguageModel.FunctionDefinition(
                        name: name,
                        description: description,
                        parameters: JSONSchema(true)
                    )
                    
                    return functionDef
                }
            }
            
            // Create a local strong reference to the model that will be used in the background thread
            let localModel = model
            let localCompletion = completion
            
            // Use Task to match SwiftCactusiOSApp pattern exactly
            Task {
                do {
                    // Generate completion using the strong model reference we already have
                    // Use the same synchronous approach as SwiftCactusiOSApp
                    let result = try localModel.chatCompletion(
                        messages: chatMessages
                    )
                    
                    print("[DEBUG] Chat completion result: \(result)")
                    
                    // Extract the response text and any additional fields we need
                    // This structure matches what the JavaScript code expects (result.response is the actual text)
                    var completionDict: [String: Any] = [
                        "success": true,
                        "response": result.response,
                        "tokensPerSecond": result.tokensPerSecond,
                        "prefillTokens": result.prefillTokens,
                        "decodeTokens": result.decodeTokens,
                        "totalTokens": result.totalTokens
                    ]
                    
                    // Add function calls if present
                    if !result.functionCalls.isEmpty {
                        // Convert FunctionCall objects to JSON-serializable dictionaries
                        let functionCallsDict = try result.functionCalls.map { functionCall -> [String: Any] in
                            var dict: [String: Any] = [
                                "name": functionCall.name
                            ]
                            
                            // Encode arguments as JSON string
                            let encoder = JSONEncoder()
                            let argsData = try encoder.encode(functionCall.arguments)
                            let argsString = String(data: argsData, encoding: .utf8) ?? "{}"
                            dict["arguments"] = argsString
                            
                            return dict
                        }
                        
                        completionDict["functionCalls"] = functionCallsDict
                    }
                    
                    // Return result on main thread
                    await MainActor.run { 
                        localCompletion(completionDict)
                    }
                } catch {
                    print("[DEBUG] Error in generateCompletion: \(error)")
                    print("[DEBUG] Error description: \(error.localizedDescription)")
                    if let nsError = error as NSError? {
                        print("[DEBUG] Error domain: \(nsError.domain)")
                        print("[DEBUG] Error code: \(nsError.code)")
                        print("[DEBUG] Error user info: \(nsError.userInfo)")
                    }
                     //Return error on main thread
                     await MainActor.run {
                         localCompletion([
                             "success": false,
                             "error": error.localizedDescription
                         ])
                     }
                }
            }
        } catch {
            // Handle conversion errors immediately
            completion([
                "success": false,
                "error": error.localizedDescription
            ])
        }
    }
    
    // MARK: - Transcription Methods
    
    public func transcribeAudio(
        audioPath: String,
        prompt: String?,
        language: String?,
        temperature: Float,
        maxTokens: Int,
        completion: @escaping @Sendable ([String: Any]) -> Void
    ) {
        let model = self.languageModelLock.withLock {
            self.languageModel
        }
        
        guard let languageModel = model else {
            completion([
                "success": false,
                "error": "Model not initialized"
            ])
            return
        }
        
        do {
            // Convert to URL before creating async block to avoid data races
            let audioURL = URL(fileURLWithPath: audioPath)
            
            // Create options
            let options = CactusLanguageModel.InferenceOptions(
                maxTokens: maxTokens,
                temperature: temperature,
                topP: 0.95,
                topK: 20,
                stopSequences: CactusLanguageModel.InferenceOptions.defaultStopSequences
            )
            
            // Create local strong references
            let localPrompt = prompt
            let localLanguageModel = languageModel
            let localCompletion = completion
            
            // Use Task instead of DispatchQueue for better concurrency
            Task {
                do {
                    // Transcribe the audio using the local strong reference
                    let result = try localLanguageModel.transcribe(
                        audio: audioURL,
                        prompt: localPrompt ?? "",
                        options: options,
                        onToken: { @Sendable token in
                            // Notify listeners about token received
                            Task.detached {
                                await MainActor.run {
                                    NotificationCenter.default.post(name: Notification.Name("tokenReceived"), object: nil, userInfo: ["token": token])
                                }
                            }
                        }
                    )
                    
                    // Return result on main thread
                    await MainActor.run {
                        localCompletion([
                            "success": true,
                            "transcription": result.response
                        ])
                    }
                } catch {
                    // Return error on main thread
                    await MainActor.run {
                        localCompletion([
                            "success": false,
                            "error": error.localizedDescription
                        ])
                    }
                }
            }
        } catch {
            // Handle conversion errors immediately
            completion([
                "success": false,
                "error": error.localizedDescription
            ])
        }
    }
    
    // MARK: - Streaming Generation Method
    
    public func generateStreamingCompletion(
        messages: [[String: Any]],
        temperature: Float,
        maxTokens: Int,
        topP: Float,
        topK: Int,
        stopSequences: [String]?,
        tools: [[String: Any]]?,
        eventName: String,
        completion: @escaping @Sendable ([String: Any]) -> Void
    ) {
        print("[DEBUG] generateStreamingCompletion called")
        
        // First, check if model exists and create a strong reference
        let model: CactusLanguageModel? = self.languageModelLock.withLock { self.languageModel }
        
        guard let model = model else {
            completion([
                "success": false,
                "error": "Model not initialized"
            ])
            return
        }
        
        do {
            // Convert messages to CactusLanguageModel.ChatMessage format
            let chatMessages = try messages.map { message -> CactusLanguageModel.ChatMessage in
                guard let roleStr = message["role"] as? String, 
                      let content = message["content"] as? String else {
                    throw NSError(domain: "CactusCap", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid message format"])
                }
                
                // Use the safer convenience methods instead of direct initializer
                switch roleStr {
                case "system":
                    return CactusLanguageModel.ChatMessage.system(content)
                case "user":
                    return CactusLanguageModel.ChatMessage.user(content)
                case "assistant":
                    return CactusLanguageModel.ChatMessage.assistant(content)
                case "function":
                    return CactusLanguageModel.ChatMessage.assistant(content) // Handle function role as assistant
                default:
                    throw NSError(domain: "CactusCap", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid role: \(roleStr)"])
                }
            }
            
            // Prepare options
            var options = CactusLanguageModel.InferenceOptions(
                maxTokens: maxTokens,
                temperature: temperature,
                topP: topP,
                topK: topK,
                stopSequences: CactusLanguageModel.InferenceOptions.defaultStopSequences
            )
            
            if let stopSequences = stopSequences {
                options.stopSequences = stopSequences
            }
            
            // Create local strong references
            let localModel = model
            let localCompletion = completion
            let localEventName = eventName
            
            // Use Task to perform generation with actual streaming via onToken callback
            Task {
                // Send start event
                await MainActor.run { 
                    NotificationCenter.default.post(
                        name: Notification.Name(localEventName),
                        object: nil,
                        userInfo: ["type": "start", "data": [:]]
                    )
                }
                
                do {
                    // Generate completion using chatCompletion with onToken callback
                    let result = try localModel.chatCompletion(
                        messages: chatMessages,
                        options: options,
                        onToken: { @Sendable token in
                            // Send token to JavaScript via plugin event immediately when received
                    Task.detached { @MainActor in
                        NotificationCenter.default.post(
                            name: Notification.Name(localEventName),
                            object: nil,
                            userInfo: ["type": "token", "data": ["token": token, "completion": ""]]
                        )
                    }
                        }
                    )
                    
                    // Send final done event
                    await MainActor.run { 
                        let doneEventData: [String: Any] = [
                            "type": "done",
                            "data": [
                                "completion": result.response,
                                "usage": [
                                    "prefillTokens": result.prefillTokens,
                                    "decodeTokens": result.decodeTokens,
                                    "totalTokens": result.totalTokens
                                ],
                                "generationMetrics": [
                                    "tokensPerSecond": result.tokensPerSecond
                                ]
                            ]
                        ]
                        NotificationCenter.default.post(
                            name: Notification.Name(localEventName),
                            object: nil,
                            userInfo: doneEventData
                        )
                    }
                    
                    // Return final result on main thread
                    await MainActor.run { 
                        var completionDict: [String: Any] = [
                            "success": true,
                            "response": result.response,
                            "tokensPerSecond": result.tokensPerSecond,
                            "prefillTokens": result.prefillTokens,
                            "decodeTokens": result.decodeTokens,
                            "totalTokens": result.totalTokens,
                            "timeToFirstToken": result.timeIntervalToFirstToken
                        ]
                        
                        // Add function calls if present
                        if !result.functionCalls.isEmpty {
                            // Convert FunctionCall objects to JSON-serializable dictionaries
                            do {
                                let functionCallsDict = try result.functionCalls.map { functionCall -> [String: Any] in
                                    var dict: [String: Any] = [
                                        "name": functionCall.name
                                    ]
                                    
                                    // Encode arguments as JSON string
                                    let encoder = JSONEncoder()
                                    let argsData = try encoder.encode(functionCall.arguments)
                                    let argsString = String(data: argsData, encoding: .utf8) ?? "{}"
                                    dict["arguments"] = argsString
                                    
                                    return dict
                                }
                                
                                completionDict["functionCalls"] = functionCallsDict
                            } catch {
                                // Handle encoding error
                                print("[DEBUG] Error encoding function call arguments: \(error.localizedDescription)")
                            }
                        }
                        
                        localCompletion(completionDict)
                    }
                } catch {
                    print("[DEBUG] Error in generateStreamingCompletion: \(error)")
                    
                    // Return error on main thread
                    await MainActor.run { 
                        localCompletion([
                            "success": false,
                            "error": error.localizedDescription
                        ])
                    }
                }
            }
        } catch {
            // Handle conversion errors immediately
            completion([
                "success": false,
                "error": error.localizedDescription
            ])
        }
    }
    
    // MARK: - Embedding Methods
    
    public func getTextEmbeddings(text: String, completion: @escaping @Sendable ([String: Any]) -> Void) {
        let model = self.languageModelLock.withLock {
            self.languageModel
        }
        
        guard let languageModel = model else {
            completion([
                "success": false,
                "error": "Model not initialized"
            ])
            return
        }
        
        do {
            // Create local strong references
            let localText = text
            let localLanguageModel = languageModel
            let localCompletion = completion
            
            // Use Task instead of DispatchQueue for better concurrency
            Task {
                do {
                    // Generate embeddings using the local strong reference
                    let embeddings = try localLanguageModel.embeddings(for: localText)
                    
                    // Return result on main thread
                    await MainActor.run {
                        localCompletion([
                            "success": true,
                            "embeddings": embeddings
                        ])
                    }
                } catch {
                    // Return error on main thread
                    await MainActor.run {
                        localCompletion([
                            "success": false,
                            "error": error.localizedDescription
                        ])
                    }
                }
            }
        } catch {
            // Handle conversion errors immediately
            completion([
                "success": false,
                "error": error.localizedDescription
            ])
        }
    }
    
    public func getImageEmbeddings(imagePath: String, completion: @escaping @Sendable ([String: Any]) -> Void) {
        let model = self.languageModelLock.withLock {
            self.languageModel
        }
        
        guard let languageModel = model else {
            completion([
                "success": false,
                "error": "Model not initialized"
            ])
            return
        }
        
        do {
            // Convert to URL before creating async block to avoid data races
            let imageURL = URL(fileURLWithPath: imagePath)
            
            // Create local strong references
            let localImageURL = imageURL
            let localLanguageModel = languageModel
            let localCompletion = completion
            
            // Use Task instead of DispatchQueue for better concurrency
            Task {
                do {
                    // Generate embeddings using the local strong reference
                    let embeddings = try localLanguageModel.imageEmbeddings(for: localImageURL)
                    
                    // Return result on main thread
                    await MainActor.run {
                        localCompletion([
                            "success": true,
                            "embeddings": embeddings
                        ])
                    }
                } catch {
                    // Return error on main thread
                    await MainActor.run {
                        localCompletion([
                            "success": false,
                            "error": error.localizedDescription
                        ])
                    }
                }
            }
        } catch {
            // Handle conversion errors immediately
            completion([
                "success": false,
                "error": error.localizedDescription
            ])
        }
    }
    
    public func getAudioEmbeddings(audioPath: String, completion: @escaping @Sendable ([String: Any]) -> Void) {
        let model = self.languageModelLock.withLock {
            self.languageModel
        }
        
        guard let languageModel = model else {
            completion([
                "success": false,
                "error": "Model not initialized"
            ])
            return
        }
        
        do {
            // Convert to URL before creating async block to avoid data races
            let audioURL = URL(fileURLWithPath: audioPath)
            
            // Create local strong references
            let localAudioURL = audioURL
            let localLanguageModel = languageModel
            let localCompletion = completion
            
            // Use Task instead of DispatchQueue for better concurrency
            Task {
                do {
                    // Generate embeddings using the local strong reference
                    let embeddings = try localLanguageModel.audioEmbeddings(for: localAudioURL)
                    
                    // Return result on main thread
                    await MainActor.run {
                        localCompletion([
                            "success": true,
                            "embeddings": embeddings
                        ])
                    }
                } catch {
                    // Return error on main thread
                    await MainActor.run {
                        localCompletion([
                            "success": false,
                            "error": error.localizedDescription
                        ])
                    }
                }
            }
        } catch {
            // Handle conversion errors immediately
            completion([
                "success": false,
                "error": error.localizedDescription
            ])
        }
    }
}
