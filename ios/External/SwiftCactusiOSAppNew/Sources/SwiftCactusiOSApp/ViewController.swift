import UIKit
import Cactus
import Logging

class ViewController: UIViewController {

    private var cactusLabel: UILabel!
    private var loadModelButton: UIButton!
    private var generateResponseButton: UIButton!
    private var textView: UITextView!
    private var languageModel: CactusLanguageModel?
    private let logger = Logger(label: "com.cactus.SwiftCactusiOSApp")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up logging
        //LoggingSystem.bootstrap(StreamLogHandler.standardOutput)
        
        // Set up UI
        setupUI()
        
        // Test Cactus framework
        //testCactusFramework()
    }
    
    //private func testCactusFramework() {
        //logger.info("Testing Cactus Framework Integration")
        
        // Get Cactus version
        //let cactusVersion = Cactus.version
        //logger.info("Cactus Framework Version: \(cactusVersion)")
        //textView.text = "Cactus Framework Version: \(cactusVersion)\n\n"
        
        // Get models directory
        //let modelURL = CactusModelsDirectory.shared.modelURL(for: "qwen3-0.6")
        //logger.info("Models URL: \(modelURL)")
        //textView.text.append("Models Directory: \(modelsDirectory.path)\n\n")
    //}
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Cactus Label
        cactusLabel = UILabel()
        cactusLabel.translatesAutoresizingMaskIntoConstraints = false
        cactusLabel.text = "Cactus Framework Demo"
        cactusLabel.font = UIFont.boldSystemFont(ofSize: 24)
        cactusLabel.textAlignment = .center
        view.addSubview(cactusLabel)
        
        // Load Model Button
        loadModelButton = UIButton(type: .system)
        loadModelButton.translatesAutoresizingMaskIntoConstraints = false
        loadModelButton.setTitle("Load Model", for: .normal)
        loadModelButton.addTarget(self, action: #selector(loadModelButtonTapped), for: .touchUpInside)
        loadModelButton.backgroundColor = .systemBlue
        loadModelButton.setTitleColor(.white, for: .normal)
        loadModelButton.layer.cornerRadius = 8
        view.addSubview(loadModelButton)
        
        // Generate Response Button
        generateResponseButton = UIButton(type: .system)
        generateResponseButton.translatesAutoresizingMaskIntoConstraints = false
        generateResponseButton.setTitle("Generate Response", for: .normal)
        generateResponseButton.addTarget(self, action: #selector(generateResponseButtonTapped), for: .touchUpInside)
        generateResponseButton.backgroundColor = .systemGreen
        generateResponseButton.setTitleColor(.white, for: .normal)
        generateResponseButton.layer.cornerRadius = 8
        generateResponseButton.isEnabled = false
        view.addSubview(generateResponseButton)
        
        // Text View
        textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(textView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            cactusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cactusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cactusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            loadModelButton.topAnchor.constraint(equalTo: cactusLabel.bottomAnchor, constant: 40),
            loadModelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            loadModelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loadModelButton.heightAnchor.constraint(equalToConstant: 50),
            
            generateResponseButton.topAnchor.constraint(equalTo: loadModelButton.bottomAnchor, constant: 20),
            generateResponseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            generateResponseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            generateResponseButton.heightAnchor.constraint(equalToConstant: 50),
            
            textView.topAnchor.constraint(equalTo: generateResponseButton.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    
    @objc private func loadModelButtonTapped() {
        loadModelButton.isEnabled = false
        textView.text.append("Loading model...\n")
        
        // Load model asynchronously
        Task {
            do {
                // Get model URL for qwen3-0.6
                let modelURL = try await CactusModelsDirectory.shared.modelURL(for: "qwen3-0.6")
                logger.info("Model URL: \(modelURL)")
                
                // Initialize the model
                languageModel = try CactusLanguageModel(from: modelURL)
                logger.info("Model loaded successfully")
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.textView.text.append("Model loaded successfully!\n\n")
                    self.generateResponseButton.isEnabled = true
                    self.loadModelButton.isEnabled = true
                }
            } catch {
                logger.error("Failed to load model: \(error)")
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.textView.text.append("Failed to load model: \(error)\n\n")
                    self.loadModelButton.isEnabled = true
                }
            }
        }
    }
    
    @objc private func generateResponseButtonTapped() {
        guard let model = languageModel else { return }
        
        generateResponseButton.isEnabled = false
        textView.text.append("Generating response...\n")
        
        // Generate response asynchronously
        Task {
            do {
                // Create messages
                let completion = try model.chatCompletion(
                  messages: [
                    .system("You are a philosopher, philosophize about anything."),
                    .user("What is the meaning of life?")
                  ]
                )
                
                // Generate response
                //let completion = try await model.chatCompletion(messages: messages)
                //logger.info("Generated response: \(completion)")
                
                // Update UI on main thread
                DispatchQueue.main.async {
                  self.textView.text.append("Response: \(completion)\n\n")
                    self.generateResponseButton.isEnabled = true
                }
            } catch {
                logger.error("Failed to generate response: \(error)")
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.textView.text.append("Failed to generate response: \(error)\n\n")
                    self.generateResponseButton.isEnabled = true
                }
            }
        }
    }
}
