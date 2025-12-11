import Foundation

// Simulate the CactusLanguageModel.transcribe method signature
class MockLanguageModel {
    func transcribe(
        audio: URL,
        prompt: String,
        options: [String: Any],
        onToken: @Sendable (String) -> Void
    ) throws -> (response: String) {
        // Simulate generating some tokens
        let tokens = ["Hello", " ", "world", "!"]
        for token in tokens {
            onToken(token)
            // Simulate delay between tokens
            Thread.sleep(forTimeInterval: 0.1)
        }
        return (response: "Hello world!")
    }
}

// Test the async closure pattern we implemented
func testAsyncClosure() {
    let model = MockLanguageModel()
    let audioURL = URL(fileURLWithPath: "/tmp/test.mp3")
    let options: [String: Any] = [:]
    
    Task {
        do {
            let result = try model.transcribe(
                audio: audioURL,
                prompt: "",
                options: options,
                onToken: { @Sendable token in
                    // This is the pattern we fixed - using Task.detached for async operations in a sync closure
                    Task.detached {
                        await MainActor.run {
                            print("Token received: \(token)")
                        }
                    }
                }
            )
            
            await MainActor.run {
                print("Transcription result: \(result.response)")
            }
        } catch {
            await MainActor.run {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

print("Testing async closure fix...")
testAsyncClosure()

// Keep the program running long enough to see the results
RunLoop.main.run(until: Date(timeIntervalSinceNow: 1.0))
print("Test completed!")