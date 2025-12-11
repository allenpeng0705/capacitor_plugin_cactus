// Test script to verify the response format from CactusCap.generateCompletion

// Mock the plugin response to simulate what our fixed code returns
const mockPluginResponse = {
  success: true,
  response: "Hello, how can I help you today?",
  tokensPerSecond: 12.5,
  prefillTokens: 10,
  decodeTokens: 5,
  totalTokens: 15
};

// This is what the JavaScript code in capacitor-welcome.js does
console.log("Testing response format...");
console.log("Direct access to response:", mockPluginResponse.response);
console.log("Type of response:", typeof mockPluginResponse.response);
console.log("Display in HTML would be:", `<div>${mockPluginResponse.response}</div>`);

// This simulates what would happen if response was still an object
const badResponse = {
  success: true,
  response: { text: "Hello, how can I help you today?" }
};

console.log("\nBad response example:");
console.log("Direct access to bad response:", badResponse.response);
console.log("Type of bad response:", typeof badResponse.response);
console.log("Display in HTML would be:", `<div>${badResponse.response}</div>`);

// Test function calls response format
const mockPluginResponseWithFunctions = {
  success: true,
  response: "",
  tokensPerSecond: 12.5,
  prefillTokens: 10,
  decodeTokens: 5,
  totalTokens: 15,
  functionCalls: [
    {
      name: "get_weather",
      arguments: '{"location":"New York","unit":"celsius"}'
    }
  ]
};

console.log("\nTesting function calls format...");
console.log("Function calls present:", mockPluginResponseWithFunctions.functionCalls.length > 0);
if (mockPluginResponseWithFunctions.functionCalls.length > 0) {
  const funcCall = mockPluginResponseWithFunctions.functionCalls[0];
  console.log("Function name:", funcCall.name);
  console.log("Function arguments (JSON string):", funcCall.arguments);
  console.log("Function arguments (parsed):", JSON.parse(funcCall.arguments));
}
