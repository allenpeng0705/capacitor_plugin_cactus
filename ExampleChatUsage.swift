import Cactus
import Foundation

// MARK: - Direct Usage of Cactus SDK (as shown in swift-cactus sample)
func directChatCompletionExample() {
    Task {
        do {
            // Get the model URL for the specific model
            let modelURL = try await CactusModelsDirectory.shared
                .modelURL(for: "qwen3-0.6")
            
            // Create the language model
            let model = try CactusLanguageModel(from: modelURL)
            
            // Call chatCompletion directly with messages
            let completion = try model.chatCompletion(
                messages: [
                    .system("You are a philosopher, philosophize about anything."),
                    .user("What is the meaning of life?")
                ]
            )
            
            // Print the result
            print("Direct chatCompletion result:")
            print(completion)
            
        } catch {
            print("Error with direct chatCompletion: \(error)")
        }
    }
}

// MARK: - How generateCompletion in CactusCap uses chatCompletion
// This demonstrates the plugin's implementation pattern
func pluginStyleChatCompletionExample() {
    Task {
        do {
            // This is similar to what happens inside generateCompletion function
            let modelURL = try await CactusModelsDirectory.shared
                .modelURL(for: "qwen3-0.6")
            
            let model = try CactusLanguageModel(from: modelURL)
            
            // Convert messages to the required format
            let messages: [ChatMessage] = [
                .system("You are a helpful assistant.")
            ]
            
            // Set up inference options
            let options = InferenceOptions(
                maxTokens: 1024,
                temperature: 0.7,
                topP: 0.9,
                stopWords: [],
                repeatPenalty: 1.1,
                stream: true
            )
            
            // Process completion with token streaming
            try model.chatCompletion(
                messages: messages,
                options: options,
                onToken: { token in
                    // This is where the plugin would send tokens to JavaScript
                    print("Received token: \(token)")
                }
            )
            
        } catch {
            print("Error with plugin-style chatCompletion: \(error)")
        }
    }
}

// MARK: - Example of using generateCompletion through Capacitor JS API
/*
// In JavaScript/TypeScript (Ionic/Capacitor app):

import { CactusCap } from 'capacitor-plugin-cactus';

async function generateCompletion() {
  try {
    const result = await CactusCap.generateCompletion({
      messages: [
        { role: 'system', content: 'You are a philosopher.' },
        { role: 'user', content: 'What is happiness?' }
      ],
      options: {
        maxTokens: 512,
        temperature: 0.8
      },
      onToken: (token) => {
        console.log('Streaming token:', token);
      }
    });
    
    console.log('Final completion:', result);
  } catch (error) {
    console.error('Error:', error);
  }
}
*/
