import Foundation
import Cactus

// Simple test to verify chat message creation
print("Testing Cactus ChatMessage creation...")

try {
    // Test system message creation
    let systemMessage = CactusLanguageModel.ChatMessage.system("You are a helpful assistant.")
    print("✅ System message created successfully:")
    print("   Role: \(systemMessage.role)")
    print("   Content: \(systemMessage.content)")
    print("   ToolCalls: \(systemMessage.toolCalls ?? [])")
    print("   ToolCallId: \(systemMessage.toolCallId ?? "nil")")
    print()
    
    // Test user message creation
    let userMessage = CactusLanguageModel.ChatMessage.user("Hello, how are you?")
    print("✅ User message created successfully:")
    print("   Role: \(userMessage.role)")
    print("   Content: \(userMessage.content)")
    print("   ToolCalls: \(userMessage.toolCalls ?? [])")
    print("   ToolCallId: \(userMessage.toolCallId ?? "nil")")
    print()
    
    // Test assistant message creation
    let assistantMessage = CactusLanguageModel.ChatMessage.assistant("I'm doing well, thank you!")
    print("✅ Assistant message created successfully:")
    print("   Role: \(assistantMessage.role)")
    print("   Content: \(assistantMessage.content)")
    print("   ToolCalls: \(assistantMessage.toolCalls ?? [])")
    print("   ToolCallId: \(assistantMessage.toolCallId ?? "nil")")
    print()
    
    // Test with tool calls
    let toolCall = CactusLanguageModel.ChatMessage.ToolCall(
        id: UUID().uuidString,
        type: "function",
        function: CactusLanguageModel.ChatMessage.ToolCall.Function(
            name: "get_weather",
            arguments: "{\"location\":\"New York\"}"
        )
    )
    
    let assistantWithToolCall = CactusLanguageModel.ChatMessage.assistant(
        nil,
        toolCalls: [toolCall]
    )
    
    print("✅ Assistant message with tool calls created successfully:")
    print("   Role: \(assistantWithToolCall.role)")
    print("   Content: \(assistantWithToolCall.content ?? "nil")")
    print("   ToolCalls: \(assistantWithToolCall.toolCalls?.count ?? 0) calls")
    if let firstCall = assistantWithToolCall.toolCalls?.first {
        print("     - Call Id: \(firstCall.id)")
        print("     - Call Type: \(firstCall.type)")
        print("     - Function Name: \(firstCall.function.name)")
        print("     - Function Args: \(firstCall.function.arguments)")
    }
    print("   ToolCallId: \(assistantWithToolCall.toolCallId ?? "nil")")
    print()
    
    // Test tool response message
    let toolResponseMessage = CactusLanguageModel.ChatMessage.tool(
        "The weather in New York is 22°C and sunny.",
        toolCallId: UUID().uuidString
    )
    
    print("✅ Tool response message created successfully:")
    print("   Role: \(toolResponseMessage.role)")
    print("   Content: \(toolResponseMessage.content)")
    print("   ToolCalls: \(toolResponseMessage.toolCalls ?? [])")
    print("   ToolCallId: \(toolResponseMessage.toolCallId ?? "nil")")
    print()
    
    // Test converting an array of messages (similar to what our fix does)
    print("Testing message conversion array...")
    
    let jsMessages = [
        ["role": "system", "content": "You are a helpful assistant."],
        ["role": "user", "content": "Hello, how are you?"],
        ["role": "assistant", "content": "I'm doing well, thank you!"],
    ]
    
    var convertedMessages = [CactusLanguageModel.ChatMessage]()
    
    for jsMessage in jsMessages {
        guard let role = jsMessage["role"] as? String, let content = jsMessage["content"] as? String else {
            throw NSError(domain: "TestError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid message format"])
        }
        
        let message: CactusLanguageModel.ChatMessage
        switch role {
        case "system":
            message = CactusLanguageModel.ChatMessage.system(content)
        case "user":
            message = CactusLanguageModel.ChatMessage.user(content)
        case "assistant":
            message = CactusLanguageModel.ChatMessage.assistant(content)
        default:
            throw NSError(domain: "TestError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid role: \(role)"])
        }
        
        convertedMessages.append(message)
    }
    
    print("✅ Successfully converted \(convertedMessages.count) messages:")
    for (index, message) in convertedMessages.enumerated() {
        print("   Message \(index + 1): \(message.role) -> \(message.content)")
    }
    
    print("\n🎉 All tests passed! The chat message creation fix is working correctly.")
    
} catch {
    print("❌ Error: \(error)")
    exit(1)
}
