import { WebPlugin } from '@capacitor/core';
export class CactusCapWeb extends WebPlugin {
    constructor() {
        super(...arguments);
        this.isModelInitialized = false;
    }
    async echo(options) {
        console.log('ECHO', options);
        return options;
    }
    async downloadModel(options) {
        console.log('Web: Downloading model:', options.modelSlug);
        return {
            success: true,
            modelPath: `/mock/path/to/${options.modelSlug}`,
            modelName: options.modelSlug,
            modelSlug: options.modelSlug
        };
    }
    async getAvailableModels() {
        console.log('Web: Getting available models');
        return {
            success: true,
            models: [
                {
                    slug: 'qwen3-0.6',
                    path: '/mock/path/to/qwen3-0.6'
                },
                {
                    slug: 'lfm2-vl-450m',
                    path: '/mock/path/to/lfm2-vl-450m'
                }
            ]
        };
    }
    async initializeModel(options) {
        this.isModelInitialized = true;
        console.log('CactusPlugin.initializeModel() called with:', options);
        return { success: true };
    }
    async loadModel(options) {
        this.isModelInitialized = true;
        const { modelSlug, contextSize = 2048 } = options;
        console.log('CactusPlugin.loadModel() called with:', { modelSlug, contextSize });
        return { success: true };
    }
    async loadLocalModel(options) {
        this.isModelInitialized = true;
        const { modelPath, modelSlug, contextSize = 2048 } = options;
        console.log('CactusPlugin.loadLocalModel() called with:', { modelPath, modelSlug, contextSize });
        return { success: true };
    }
    async generateCompletion(options) {
        if (!this.isModelInitialized) {
            return { success: false, error: 'No model initialized' };
        }
        console.log('Web: Generating completion with messages:', options.messages);
        // Check if we should return a tool call
        if (options.tools && options.tools.length > 0) {
            return {
                success: true,
                response: '',
                toolCalls: [
                    {
                        name: options.tools[0].function.name,
                        arguments: JSON.parse(JSON.stringify({ location: 'New York' }))
                    }
                ],
                timeToFirstTokenMs: 100,
                totalTimeMs: 200,
                tokensPerSecond: 50
            };
        }
        return {
            success: true,
            response: `Mock response for: ${options.messages[options.messages.length - 1].content}`,
            timeToFirstTokenMs: 100,
            totalTimeMs: 500,
            tokensPerSecond: 50,
            prefillTokens: 10,
            decodeTokens: 20,
            totalTokens: 30
        };
    }
    async generateStreamingCompletion(options) {
        if (!this.isModelInitialized) {
            return { success: false, error: 'No model initialized' };
        }
        console.log('Web: Generating streaming completion with messages:', options.messages);
        // For web mock, we'll just simulate a stream by emitting events
        setTimeout(() => {
            this.notifyListeners('cactusStreamingResponse', {
                type: 'start',
                data: {}
            });
        }, 100);
        // Simulate streaming tokens
        const tokens = ['Mock', ' stream', ' response', ' for:', ' ', options.messages[options.messages.length - 1].content];
        let fullResponse = '';
        tokens.forEach((token, index) => {
            fullResponse += token;
            setTimeout(() => {
                this.notifyListeners('cactusStreamingResponse', {
                    type: 'token',
                    data: {
                        token,
                        completion: fullResponse
                    }
                });
            }, 200 + (index * 100));
        });
        // Simulate completion
        setTimeout(() => {
            this.notifyListeners('cactusStreamingResponse', {
                type: 'done',
                data: {
                    completion: fullResponse,
                    usage: {
                        prefillTokens: 10,
                        decodeTokens: tokens.length,
                        totalTokens: 10 + tokens.length
                    },
                    generationMetrics: {
                        timeToFirstTokenMs: 100,
                        totalTimeMs: 500,
                        tokensPerSecond: 50
                    }
                }
            });
        }, 200 + (tokens.length * 100));
        return { success: true };
    }
    async transcribeAudio(options) {
        console.log('Web: Transcribing audio from path:', options.audioPath);
        return {
            success: true,
            transcription: 'Mock transcription of the audio file (mock)'
        };
    }
    async unloadModel() {
        this.isModelInitialized = false;
        console.log('Web: Model unloaded');
        return { success: true };
    }
    async getTextEmbeddings(options) {
        console.log('Web: Getting text embeddings for:', options.text);
        if (!this.isModelInitialized) {
            return { success: false, error: 'No model initialized' };
        }
        // Generate mock embeddings with 1024 dimensions
        const embeddings = Array.from({ length: 1024 }, () => Math.random() * 2 - 1);
        return {
            success: true,
            embeddings
        };
    }
    async getImageEmbeddings(options) {
        console.log('Web: Getting image embeddings for:', options.imagePath);
        if (!this.isModelInitialized) {
            return { success: false, error: 'No model initialized' };
        }
        // Generate mock embeddings with 1024 dimensions
        const embeddings = Array.from({ length: 1024 }, () => Math.random() * 2 - 1);
        return {
            success: true,
            embeddings
        };
    }
    async getAudioEmbeddings(options) {
        console.log('Web: Getting audio embeddings for:', options.audioPath);
        if (!this.isModelInitialized) {
            return { success: false, error: 'No model initialized' };
        }
        // Generate mock embeddings with 1024 dimensions
        const embeddings = Array.from({ length: 1024 }, () => Math.random() * 2 - 1);
        return {
            success: true,
            embeddings
        };
    }
    // Download Management Methods
    async pauseDownload(options) {
        console.log('Web: Pausing download for model:', options.modelSlug);
        // Mock implementation - no-op for web
    }
    async resumeDownload(options) {
        console.log('Web: Resuming download for model:', options.modelSlug);
        // Mock implementation - no-op for web
    }
    async cancelDownload(options) {
        console.log('Web: Cancelling download for model:', options.modelSlug);
        // Mock implementation - no-op for web
    }
    async getDownloadProgress(options) {
        console.log('Web: Getting download progress for model:', options.modelSlug);
        return {
            success: true,
            stage: 'finished',
            progress: 1.0,
            modelPath: `/mock/path/to/${options.modelSlug}`
        };
    }
}
//# sourceMappingURL=web.js.map