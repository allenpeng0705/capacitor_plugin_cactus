import { SplashScreen } from '@capacitor/splash-screen';
import { Camera } from '@capacitor/camera';
import { CactusCap } from 'capacitor-plugin-cactus';

window.customElements.define(
  'capacitor-welcome',
  class extends HTMLElement {
    constructor() {
      super();

      SplashScreen.hide();

      const root = this.attachShadow({ mode: 'open' });

      root.innerHTML = `
    <style>
      :host {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
        display: block;
        width: 100%;
        height: 100%;
        padding: 20px;
        box-sizing: border-box;
      }
      
      main {
        padding: 0;
        max-width: 100%;
      }
      
      .container {
        width: 100%;
        box-sizing: border-box;
        margin: 0 auto;
      }
      
      h1 {
        font-size: 2em;
        text-align: center;
        margin-bottom: 30px;
        color: #333;
      }
      
      h2 {
        font-size: 1.5em;
        margin: 20px 0;
        color: #555;
      }
      
      /* Very prominent button styles */
      .prominent-button {
        width: 100%;
        padding: 25px;
        font-size: 1.8em;
        font-weight: bold;
        background-color: #ff0000;
        color: white;
        border: none;
        border-radius: 15px;
        cursor: pointer;
        margin: 20px 0;
        text-align: center;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
      }
      
      .prominent-button:hover {
        background-color: #cc0000;
      }
      
      .prominent-button:active {
        transform: scale(0.98);
      }
      
      /* Model management buttons */
      .model-buttons {
        display: flex;
        flex-direction: column;
        gap: 10px;
        margin: 20px 0;
      }
      
      .model-button {
        width: 100%;
        padding: 15px;
        font-size: 1.2em;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        box-sizing: border-box;
      }
      
      .download-button {
        background-color: #4caf50;
        color: white;
      }
      
      .load-button {
        background-color: #2196f3;
        color: white;
      }
      
      .loadlocal-button {
        background-color: #ff9800;
        color: white;
      }
      
      .unload-button {
        background-color: #f44336;
        color: white;
      }
      
      /* Chat container */
      .chat-container {
        width: 100%;
        margin-top: 20px;
        box-sizing: border-box;
      }
      
      #chat-messages {
        border: 1px solid #ddd;
        border-radius: 8px;
        padding: 15px;
        min-height: 300px;
        margin-bottom: 15px;
        background-color: #f9f9f9;
      }
      
      .message {
        margin: 10px 0;
        padding: 10px;
        border-radius: 8px;
      }
      
      .user-message {
        background-color: #e3f2fd;
        text-align: right;
      }
      
      .ai-message {
        background-color: #fff9c4;
        text-align: left;
      }
      
      #chat-input {
        width: 100%;
        padding: 15px;
        font-size: 1.1em;
        border: 1px solid #ddd;
        border-radius: 8px;
        margin-bottom: 15px;
        box-sizing: border-box;
      }
      
      .secondary-button {
        width: 100%;
        padding: 15px;
        font-size: 1.2em;
        background-color: #2196f3;
        color: white;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        box-sizing: border-box;
      }
      
      .status {
        background-color: #f0f0f0;
        padding: 10px;
        border-radius: 4px;
        margin: 10px 0;
        font-weight: bold;
      }
      
      .loading {
        display: inline-block;
        width: 20px;
        height: 20px;
        border: 3px solid rgba(0,0,0,.3);
        border-radius: 50%;
        border-top-color: #000;
        animation: spin 1s ease-in-out infinite;
      }
      
      @keyframes spin {
        to { transform: rotate(360deg); }
      }
    </style>
    <div class="container">
      <main>
        <h1>Cactus Plugin Demo</h1>
        
        <div class="status">
          <span id="model-status">Status: Ready</span>
        </div>
        
        <!-- Model management buttons -->
        <div class="model-buttons">
          <h2>Model Management</h2>
          <button class="model-button download-button" id="download-model">Download Model</button>
          <button class="model-button load-button" id="load-model">Load Model</button>
          <button class="model-button loadlocal-button" id="load-local-model">Load Local Model</button>
          <button class="model-button unload-button" id="unload-model">Unload Model</button>
        </div>
        
        <!-- Text Embeddings Test -->
        <div class="model-buttons">
          <h2>Embeddings Test</h2>
          <button class="model-button load-button" id="test-text-embeddings">Test Text Embeddings</button>
        </div>
        
        <!-- Very prominent Generate Response button -->
        <button class="prominent-button" id="generating-response">GENERATE RESPONSE</button>
        <button class="prominent-button" id="generating-streaming-response" style="background-color: #4CAF50;">GENERATE STREAMING RESPONSE</button>
        
        <div class="chat-container">
          <h2>Chat</h2>
          <div id="chat-messages"></div>
          <textarea id="chat-input" placeholder="Type your message here..."></textarea>
          <button class="secondary-button" id="send-message">Send Message</button>
          <div id="chat-loading" style="display: none; margin-top: 10px;">
            <span class="loading"></span> Loading response...
          </div>
        </div>
      </main>
    </div>
      `;
    }

    connectedCallback() {
      const self = this;
      
      // Add debug logging
      console.log('Capacitor welcome element connected');
      
      // Initialize variables
      let isModelLoaded = false;
      const statusElement = self.shadowRoot.querySelector('#model-status');
      const chatMessages = self.shadowRoot.querySelector('#chat-messages');
      const chatLoading = self.shadowRoot.querySelector('#chat-loading');
      
      // Update status helper
      const updateStatus = (message) => {
        if (statusElement) {
          statusElement.textContent = `Status: ${message}`;
        }
      };
      
      // Add message to chat helper
      const addMessage = (sender, message) => {
        if (chatMessages) {
          const messageDiv = document.createElement('div');
          messageDiv.className = `message ${sender}-message`;
          messageDiv.innerHTML = `<strong>${sender}:</strong> ${message}`;
          chatMessages.appendChild(messageDiv);
          // Scroll to bottom
          chatMessages.scrollTop = chatMessages.scrollHeight;
        }
      };
      
      // Show loading
      const showLoading = () => {
        if (chatLoading) {
          chatLoading.style.display = 'block';
        }
      };
      
      // Hide loading
      const hideLoading = () => {
        if (chatLoading) {
          chatLoading.style.display = 'none';
        }
      };
      
      // Model management button handlers
      
      // Download Model button
      self.shadowRoot.querySelector('#download-model').addEventListener('click', async function (e) {
        e.preventDefault();
        updateStatus('Downloading model...');
        
        try {
          // Use the same model slug as the working Swift example
          const modelSlug = 'qwen3-0.6';
          const result = await CactusCap.downloadModel({ modelSlug: modelSlug });
          updateStatus('Model downloaded successfully');
          console.log('Model download result:', result);
        } catch (error) {
          updateStatus('Error downloading model');
          console.error('Error downloading model:', error);
        }
      });
      
      // Load Model button
      self.shadowRoot.querySelector('#load-model').addEventListener('click', async function (e) {
        e.preventDefault();
        updateStatus('Loading model...');
        
        try {
          // Use the same model slug as the working Swift example
          const modelSlug = 'qwen3-0.6';
          const result = await CactusCap.loadModel({ modelSlug: modelSlug });
          isModelLoaded = true;
          updateStatus('Model loaded successfully');
          console.log('Model load result:', result);
        } catch (error) {
          updateStatus('Error loading model');
          console.error('Error loading model:', error);
        }
      });
      
      // Load Local Model button
      self.shadowRoot.querySelector('#load-local-model').addEventListener('click', async function (e) {
        e.preventDefault();
        updateStatus('Loading local model...');
        
        try {
          // First get the list of stored models
          const modelsResult = await CactusCap.getAvailableModels();
          
          if (modelsResult.success) {
            // Find the model with the matching slug
            const targetModel = modelsResult.models.find(model => model.slug === 'qwen3-0.6');
            
            if (targetModel) {
              console.log('Found stored model at path:', targetModel.path);
              
              // Use the actual stored model path
              const result = await CactusCap.loadLocalModel({ 
                modelPath: targetModel.path,
                modelSlug: 'qwen3-0.6' // Optional, but recommended for caching
              });
              
              isModelLoaded = true;
              updateStatus('Local model loaded successfully');
              console.log('Local model load result:', result);
            } else {
              updateStatus('Error: Model not found. Please download it first.');
              console.error('Model not found in stored models');
            }
          } else {
            updateStatus('Error: Failed to retrieve models');
            console.error('Failed to get models:', modelsResult.error);
          }
        } catch (error) {
          updateStatus('Error loading local model');
          console.error('Error loading local model:', error);
        }
      });
      
      // Unload Model button
      self.shadowRoot.querySelector('#unload-model').addEventListener('click', async function (e) {
        e.preventDefault();
        updateStatus('Unloading model...');
        
        try {
          const result = await CactusCap.unloadModel({});
          isModelLoaded = false;
          updateStatus('Model unloaded successfully');
          console.log('Model unload result:', result);
        } catch (error) {
          updateStatus('Error unloading model');
          console.error('Error unloading model:', error);
        }
      });
      
      // Test Text Embeddings button
      self.shadowRoot.querySelector('#test-text-embeddings').addEventListener('click', async function (e) {
        e.preventDefault();
        updateStatus('Generating text embeddings...');
        
        try {
          const testText = 'Hello, world! This is a test for text embeddings.';
          const result = await CactusCap.getTextEmbeddings({ text: testText });
          
          if (result.success && result.embeddings) {
            updateStatus('Text embeddings generated successfully');
            console.log('Text embeddings result:', result);
            console.log('Embedding vector length:', result.embeddings.length);
            console.log('First 10 embedding values:', result.embeddings.slice(0, 10));
            addMessage('AI', `Text embeddings generated! Vector length: ${result.embeddings.length}<br><br>First 10 values:<br>${result.embeddings.slice(0, 10).join(', ')}`);
          } else {
            updateStatus('Error generating text embeddings');
            console.error('Error generating text embeddings:', result.error);
            addMessage('AI', `Error generating embeddings: ${result.error}`);
          }
        } catch (error) {
          updateStatus('Error generating text embeddings');
          console.error('Error generating text embeddings:', error);
          addMessage('AI', `Error: ${error.message || 'Failed to generate embeddings'}`);
        }
      });
      
      // Add event listener for streaming events
      const handleStreamingEvent = (event) => {
        console.log('Streaming event received:', event);
        
        const { type, data } = event;
        
        switch (type) {
          case 'start':
            console.log('Streaming started');
            // Create a new AI message element for streaming response
            const streamingMessage = document.createElement('div');
            streamingMessage.className = 'message ai-message';
            streamingMessage.innerHTML = '<strong>AI:</strong> <span id="streaming-response"></span>';
            chatMessages.appendChild(streamingMessage);
            // Scroll to bottom
            chatMessages.scrollTop = chatMessages.scrollHeight;
            break;
            
          case 'token':
            console.log('Received token:', data.token);
            // Update the streaming message with the new token
            const streamingResponse = chatMessages.querySelector('#streaming-response');
            if (streamingResponse) {
              streamingResponse.textContent += data.token;
              // Scroll to bottom
              chatMessages.scrollTop = chatMessages.scrollHeight;
            }
            break;
            
          case 'done':
            console.log('Streaming completed:', data);
            updateStatus('Ready');
            hideLoading();
            break;
        }
      };
      
      // Add event listener
      CactusCap.addListener('cactusStreamingResponse', handleStreamingEvent);
      
      // Generate response button click handler
      self.shadowRoot.querySelector('#generating-response').addEventListener('click', async function (e) {
        e.preventDefault();
        
        console.log('Generate response button clicked');
        
        // Show loading indicator
        showLoading();
        
        try {
          // Static input message
          const staticInput = "Hello, how are you?";
          
          // Add user message to chat
          addMessage('User', staticInput);
          
          // Call the Cactus plugin to generate a completion
          updateStatus('Generating response...');
          
          const result = await CactusCap.generateCompletion({
            messages: [
              {role: 'system', content: "You are a helpful assistant and always polite to the user."},
              { role: 'user', content: staticInput }
            ],
            temperature: 0.7
          });
          
          // Add AI response to chat
          addMessage('AI', result.response);
          updateStatus('Ready');
          
        } catch (error) {
          console.error('Error generating response:', error);
          addMessage('AI', 'Error: ' + (error.message || 'Failed to generate response'));
          updateStatus('Error');
        } finally {
          // Hide loading indicator
          hideLoading();
        }
      });
      
      // Generate streaming response button click handler
      self.shadowRoot.querySelector('#generating-streaming-response').addEventListener('click', async function (e) {
        e.preventDefault();
        
        console.log('Generate streaming response button clicked');
        
        // Show loading indicator
        showLoading();
        
        try {
          // Static input message
          const staticInput = "Hello, how are you?";
          
          // Add user message to chat
          addMessage('User', staticInput);
          
          // Call the Cactus plugin to generate a streaming completion
          updateStatus('Generating streaming response...');
          
          // This will trigger streaming events
          const result = await CactusCap.generateStreamingCompletion({
            messages: [
              {role: 'system', content: "You are a helpful assistant and always polite to the user."},
              { role: 'user', content: staticInput }
            ],
            temperature: 0.7
          });
          
          console.log('Streaming completion finished with result:', result);
          
        } catch (error) {
          console.error('Error generating streaming response:', error);
          addMessage('AI', 'Error: ' + (error.message || 'Failed to generate streaming response'));
          updateStatus('Error');
          hideLoading();
        }
      });
      
      // Send message button click handler
      self.shadowRoot.querySelector('#send-message').addEventListener('click', async function (e) {
        e.preventDefault();
        
        const chatInput = self.shadowRoot.querySelector('#chat-input');
        const message = chatInput.value.trim();
        
        if (!message) {
          return;
        }
        
        // Clear input
        chatInput.value = '';
        
        // Add user message to chat
        addMessage('User', message);
        
        // Show loading indicator
        showLoading();
        
        try {
          // Call the Cactus plugin to generate a completion
          updateStatus('Generating response...');
          
          const result = await CactusCap.generateCompletion({
            messages: [
              {role: 'system', content: "You are a helpful assistant and always polite to the user."},
              { role: 'user', content: message }
            ],
            maxTokens: 500,
            temperature: 0.5
          });
          
          // Add AI response to chat
          addMessage('AI', result.response);
          updateStatus('Ready');
          
        } catch (error) {
          console.error('Error generating response:', error);
          addMessage('AI', 'Error: ' + (error.message || 'Failed to generate response'));
          updateStatus('Error');
        } finally {
          // Hide loading indicator
          hideLoading();
        }
      });
    }
  },
);

window.customElements.define(
  'capacitor-welcome-titlebar',
  class extends HTMLElement {
    constructor() {
      super();

      const root = this.attachShadow({ mode: 'open' });
      root.innerHTML = `
    <style>
      :host {
        display: block;
        padding: 15px 10px;
        text-align: center;
        background-color: #73B5F6;
        color: white;
      }
      h1 {
        margin: 0;
        font-size: 0.9em;
      }
    </style>
    <h1><slot></slot></h1>
      `;
    }
  },
);