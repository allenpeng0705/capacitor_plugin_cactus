export interface CactusCapPlugin {
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    downloadModel(options: {
        modelSlug: string;
    }): Promise<{
        success: boolean;
        modelPath?: string;
        modelName?: string;
        modelSlug?: string;
        error?: string;
    }>;
    pauseDownload(options: {
        modelSlug: string;
    }): Promise<void>;
    resumeDownload(options: {
        modelSlug: string;
    }): Promise<void>;
    cancelDownload(options: {
        modelSlug: string;
    }): Promise<void>;
    getDownloadProgress(options: {
        modelSlug: string;
    }): Promise<{
        success: boolean;
        stage?: 'downloading' | 'unzipping' | 'finished';
        progress?: number;
        modelPath?: string;
        error?: string;
    }>;
    getAvailableModels(): Promise<{
        success: boolean;
        models?: Array<{
            slug: string;
            path: string;
        }>;
        error?: string;
    }>;
    loadModel(options: {
        modelSlug: string;
        contextSize?: number;
    }): Promise<{
        success: boolean;
        error?: string;
    }>;
    loadLocalModel(options: {
        modelPath: string;
        modelSlug?: string;
        contextSize?: number;
    }): Promise<{
        success: boolean;
        error?: string;
    }>;
    unloadModel(): Promise<{
        success: boolean;
        error?: string;
    }>;
    generateCompletion(options: {
        messages: Array<{
            role: 'system' | 'user' | 'assistant' | 'function';
            content: string;
            name?: string;
            tool_call_id?: string;
        }>;
        temperature?: number;
        maxTokens?: number;
        topP?: number;
        topK?: number;
        stopSequences?: string[];
        tools?: Array<{
            type: 'function';
            function: {
                name: string;
                description: string;
                parameters: any;
            };
        }>;
    }): Promise<{
        success: boolean;
        response?: string;
        timeToFirstTokenMs?: number;
        totalTimeMs?: number;
        tokensPerSecond?: number;
        prefillTokens?: number;
        decodeTokens?: number;
        totalTokens?: number;
        toolCalls?: Array<{
            name: string;
            arguments: any;
        }>;
        error?: string;
    }>;
    /**
     * Generate streaming text completion from a model.
     * This method emits events through the 'cactusStreamingResponse' listener.
     * Events include:
     * - 'start': Stream started
     * - 'token': New token received
     * - 'done': Stream completed
     *
     * @param options The options for generating streaming completion
     * @returns Promise indicating if streaming started successfully
     */
    generateStreamingCompletion(options: {
        messages: Array<{
            role: 'system' | 'user' | 'assistant' | 'function';
            content: string;
            name?: string;
            tool_call_id?: string;
        }>;
        temperature?: number;
        maxTokens?: number;
        topP?: number;
        topK?: number;
        stopSequences?: string[];
        tools?: Array<{
            type: 'function';
            function: {
                name: string;
                description: string;
                parameters: any;
            };
        }>;
    }): Promise<{
        success: boolean;
        error?: string;
    }>;
    transcribeAudio(options: {
        audioPath: string;
        prompt?: string;
        language?: string;
        temperature?: number;
        maxTokens?: number;
    }): Promise<{
        success: boolean;
        transcription?: string;
        error?: string;
    }>;
    getTextEmbeddings(options: {
        text: string;
    }): Promise<{
        success: boolean;
        embeddings?: number[];
        error?: string;
    }>;
    getImageEmbeddings(options: {
        imagePath: string;
    }): Promise<{
        success: boolean;
        embeddings?: number[];
        error?: string;
    }>;
    getAudioEmbeddings(options: {
        audioPath: string;
    }): Promise<{
        success: boolean;
        embeddings?: number[];
        error?: string;
    }>;
}
