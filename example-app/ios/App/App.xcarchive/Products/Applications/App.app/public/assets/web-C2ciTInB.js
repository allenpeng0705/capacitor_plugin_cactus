import { a as WebPlugin } from "./index-D60Z-Dy-.js";
class CactusCapWeb extends WebPlugin {
  constructor() {
    super(...arguments);
    this.isModelInitialized = false;
  }
  async echo(options) {
    console.log("ECHO", options);
    return options;
  }
  async downloadModel(options) {
    console.log("Web: Downloading model:", options.modelSlug);
    return {
      success: true,
      modelPath: `/mock/path/to/${options.modelSlug}`,
      modelName: options.modelSlug,
      modelSlug: options.modelSlug
    };
  }
  async getModels() {
    console.log("Web: Getting models");
    return {
      success: true,
      models: [
        {
          slug: "qwen3-0.6",
          path: "/mock/path/to/qwen3-0.6"
        },
        {
          slug: "lfm2-vl-450m",
          path: "/mock/path/to/lfm2-vl-450m"
        }
      ]
    };
  }
  async initializeModel(options = {}) {
    this.isModelInitialized = true;
    console.log("CactusPlugin.initializeModel() called with:", options);
    return { success: true, message: "Model initialized successfully" };
  }
  async loadModel(options) {
    this.isModelInitialized = true;
    const { modelSlug, contextSize = 2048 } = options;
    console.log("CactusPlugin.loadModel() called with:", { modelSlug, contextSize });
    return { success: true, message: `Model ${modelSlug} loaded successfully` };
  }
  async loadLocalModel(options) {
    this.isModelInitialized = true;
    const { modelPath, modelSlug, contextSize = 2048 } = options;
    console.log("CactusPlugin.loadLocalModel() called with:", { modelPath, modelSlug, contextSize });
    return { success: true, message: "Local model loaded successfully" };
  }
  async generateCompletion(options) {
    if (!this.isModelInitialized) {
      return { success: false, response: "", error: "No model initialized" };
    }
    console.log("Web: Generating completion with messages:", options.messages);
    if (options.tools && options.tools.length > 0) {
      return {
        success: true,
        response: "",
        functionCalls: [
          {
            name: options.tools[0].function.name,
            arguments: JSON.stringify({ location: "New York" })
          }
        ]
      };
    }
    return {
      success: true,
      response: `Mock response for: ${options.messages[options.messages.length - 1].content}`
    };
  }
  async transcribeAudio(options) {
    console.log("Web: Transcribing audio from path:", options.audioPath);
    return {
      success: true,
      transcription: "Mock transcription of the audio file (mock)"
    };
  }
  async unloadModel() {
    this.isModelInitialized = false;
    console.log("Web: Model unloaded");
    return { success: true };
  }
  async getTextEmbeddings(options) {
    console.log("Web: Getting text embeddings for:", options.text);
    if (!this.isModelInitialized) {
      return { success: false, embeddings: [], error: "No model initialized" };
    }
    const embeddings = Array.from({ length: 1024 }, () => Math.random() * 2 - 1);
    return {
      success: true,
      embeddings
    };
  }
  async getImageEmbeddings(options) {
    console.log("Web: Getting image embeddings for:", options.imagePath);
    if (!this.isModelInitialized) {
      return { success: false, embeddings: [], error: "No model initialized" };
    }
    const embeddings = Array.from({ length: 1024 }, () => Math.random() * 2 - 1);
    return {
      success: true,
      embeddings
    };
  }
  async getAudioEmbeddings(options) {
    console.log("Web: Getting audio embeddings for:", options.audioPath);
    if (!this.isModelInitialized) {
      return { success: false, embeddings: [], error: "No model initialized" };
    }
    const embeddings = Array.from({ length: 1024 }, () => Math.random() * 2 - 1);
    return {
      success: true,
      embeddings
    };
  }
  // Download Management Methods
  async pauseDownload(options) {
    console.log("Web: Pausing download for model:", options.modelSlug);
  }
  async resumeDownload(options) {
    console.log("Web: Resuming download for model:", options.modelSlug);
  }
  async cancelDownload(options) {
    console.log("Web: Cancelling download for model:", options.modelSlug);
  }
  async getDownloadProgress(options) {
    console.log("Web: Getting download progress for model:", options.modelSlug);
    return {
      success: true,
      modelSlug: options.modelSlug,
      isCancelled: false,
      isPaused: false,
      isFinished: true,
      stage: "finished",
      progress: 1,
      modelPath: `/mock/path/to/${options.modelSlug}`
    };
  }
}
export {
  CactusCapWeb
};
