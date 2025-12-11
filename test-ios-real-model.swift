import Cactus
import Foundation
import Logging

// Set up logging
LoggingSystem.bootstrap(StreamLogHandler.standardOutput)

// Create a logger
let logger = Logger(label: "cactus-test")

logger.info("Starting iOS Cactus SDK test...")

do {
    // Test 1: Check CactusModelsDirectory
    let modelsDirectory = CactusModelsDirectory.shared
    logger.info("Models directory base URL: \(modelsDirectory.baseURL)")
    
    // Test 2: Try to download a small model
    let modelSlug = "qwen3-0.6"
    let destinationURL = modelsDirectory.baseURL.appendingPathComponent(modelSlug, isDirectory: true)
    
    logger.info("Downloading model \(modelSlug) to: \(destinationURL)")
    
    // Create download task
    let downloadTask = CactusLanguageModel.downloadModelTask(slug: modelSlug, to: destinationURL)
    
    // Subscribe to progress updates
    let progressSubscription = downloadTask.onProgress { progressResult in
        switch progressResult {
        case .success(let progress):
            logger.info("Download progress: \(progress.fractionCompleted * 100)%")
            logger.info("Downloaded: \(progress.completedUnitCount) bytes of \(progress.totalUnitCount) bytes")
        case .failure(let error):
            logger.error("Progress error: \(error)")
        }
    }
    
    // Start download and wait for completion
    logger.info("Starting download...")
    let startTime = Date()
    
    let downloadedURL = try await CactusLanguageModel.downloadModel(
        slug: modelSlug,
        to: destinationURL
    )
    
    let downloadTime = Date().timeIntervalSince(startTime)
    logger.info("Download completed in \(downloadTime) seconds")
    logger.info("Model downloaded to: \(downloadedURL)")
    
    // Test 3: Check if model files exist
    let fileManager = FileManager.default
    let contents = try fileManager.contentsOfDirectory(at: downloadedURL, includingPropertiesForKeys: nil)
    logger.info("Model contains \(contents.count) files:")
    
    for file in contents {
        let attributes = try fileManager.attributesOfItem(atPath: file.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        logger.info("- \(file.lastPathComponent): \(fileSize) bytes")
    }
    
    // Clean up
    progressSubscription.cancel()
    
    logger.info("iOS Cactus SDK test completed successfully!")
    
} catch {
    logger.error("Error during iOS Cactus SDK test: \(error)")
}
