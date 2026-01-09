import SwiftUI
import WatchKit
import AVFoundation

// MARK: - App Intent for Siri Shortcuts Integration
// This allows your app to be triggered via AssistiveTouch gestures configured to run shortcuts

@available(watchOS 9.0, *)
struct CaptureAhaIntent: AppIntent {
    static var title: LocalizedStringResource = "Capture Aha! Moment"
    static var description = IntentDescription("Captures the last 30 seconds of audio for processing")
    
    func perform() async throws -> some IntentResult {
        // This will be called when the shortcut is triggered
        // The app will be launched/activated automatically
        return .result()
    }
}

// MARK: - Main App Entry Point
@main
struct AhaCatcherApp: App {
    @StateObject private var audioCapture = AudioCaptureManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioCapture)
                .onAppear {
                    // When app launches via shortcut, immediately start capture
                    Task {
                        await audioCapture.startCapture()
                    }
                }
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject var audioCapture: AudioCaptureManager
    
    var body: some View {
        VStack {
            if audioCapture.isCapturing {
                Text("Capturing...")
                    .font(.headline)
                ProgressView()
            } else if audioCapture.isProcessing {
                Text("Processing...")
                    .font(.headline)
            } else {
                Text("Aha! Catcher")
                    .font(.headline)
                Text("Perform your gesture to capture")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

// MARK: - Audio Capture Manager
class AudioCaptureManager: ObservableObject {
    @Published var isCapturing = false
    @Published var isProcessing = false
    
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private let bufferSize: Int = 30 * 44100 // 30 seconds at 44.1kHz
    private let audioQueue = DispatchQueue(label: "audio.capture.queue")
    private var audioSamples: [Float] = []
    
    func startCapture() async {
        // Request microphone permission
        let granted = await requestMicrophonePermission()
        guard granted else {
            print("Microphone permission denied")
            return
        }
        
        await MainActor.run {
            isCapturing = true
        }
        
        // Start recording
        await recordAudio()
    }
    
    private func requestMicrophonePermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    private func recordAudio() async {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            
            let engine = AVAudioEngine()
            let inputNode = engine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            // NOTE: For true "last 30 seconds" capture, we'd need a continuous background buffer
            // This would significantly impact battery life. For MVP, we capture 30 seconds
            // starting from when the gesture is triggered. The user's "Aha!" moment should
            // be captured in this window.
            let maxSamples = bufferSize
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                guard let self = self,
                      let channelData = buffer.floatChannelData else { return }
                let channelDataValue = channelData.pointee
                let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride)
                    .map { channelDataValue[$0] }
                
                self.audioQueue.async {
                    self.audioSamples.append(contentsOf: channelDataValueArray)
                    
                    // Prevent excessive memory usage
                    if self.audioSamples.count > maxSamples {
                        self.audioSamples.removeFirst(self.audioSamples.count - maxSamples)
                    }
                }
            }
            
            try engine.start()
            self.audioEngine = engine
            
            // Record for 30 seconds
            try await Task.sleep(nanoseconds: 30_000_000_000)
            
            engine.stop()
            inputNode.removeTap(onBus: 0)
            try audioSession.setActive(false)
            
            // Get the final audio buffer (thread-safe)
            let finalBuffer = await withCheckedContinuation { continuation in
                audioQueue.async {
                    continuation.resume(returning: self.audioSamples)
                }
            }
            
            await MainActor.run {
                isCapturing = false
                isProcessing = true
            }
            
            // Process the captured audio
            await processAudio(buffer: finalBuffer)
            
        } catch {
            print("Recording error: \(error)")
            await MainActor.run {
                isCapturing = false
                isProcessing = false
            }
        }
    }
    
    private func processAudio(buffer: [Float]) async {
        // Convert audio buffer to WAV format
        let audioData = convertToWAV(audioBuffer: buffer)
        
        // Upload to cloud API
        await uploadAudio(audioData: audioData)
        
        await MainActor.run {
            isProcessing = false
        }
    }
    
    private func convertToWAV(audioBuffer: [Float], sampleRate: Int = 44100) -> Data {
        // Convert Float samples to Int16 PCM
        let int16Samples = audioBuffer.map { sample -> Int16 in
            let clamped = max(-1.0, min(1.0, sample))
            return Int16(clamped * Float(Int16.max))
        }
        
        // Create WAV file format
        var wavData = Data()
        
        let numChannels: UInt16 = 1 // Mono
        let bitsPerSample: UInt16 = 16
        let byteRate = UInt32(sampleRate * Int(numChannels) * Int(bitsPerSample) / 8)
        let blockAlign = numChannels * bitsPerSample / 8
        let dataSize = UInt32(int16Samples.count * 2)
        let fileSize = UInt32(36 + dataSize)
        
        // RIFF header
        wavData.append("RIFF".data(using: .ascii)!)
        wavData.append(contentsOf: withUnsafeBytes(of: fileSize.littleEndian) { Data($0) })
        wavData.append("WAVE".data(using: .ascii)!)
        
        // fmt chunk
        wavData.append("fmt ".data(using: .ascii)!)
        wavData.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        wavData.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) }) // PCM
        wavData.append(contentsOf: withUnsafeBytes(of: numChannels.littleEndian) { Data($0) })
        wavData.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        wavData.append(contentsOf: withUnsafeBytes(of: byteRate.littleEndian) { Data($0) })
        wavData.append(contentsOf: withUnsafeBytes(of: blockAlign.littleEndian) { Data($0) })
        wavData.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Data($0) })
        
        // data chunk
        wavData.append("data".data(using: .ascii)!)
        wavData.append(contentsOf: withUnsafeBytes(of: dataSize.littleEndian) { Data($0) })
        
        // Audio samples
        int16Samples.forEach { sample in
            wavData.append(contentsOf: withUnsafeBytes(of: sample.littleEndian) { Data($0) })
        }
        
        return wavData
    }
    
    private func uploadAudio(audioData: Data) async {
        // TODO: Replace with your actual API endpoint
        guard let url = URL(string: "https://api.example.com/audio/upload") else {
            print("Invalid API URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("audio/wav", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer YOUR_API_TOKEN", forHTTPHeaderField: "Authorization")
        
        // Configure URLSession for background uploads
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 60.0
        config.timeoutIntervalForResource = 300.0
        
        let session = URLSession(configuration: config)
        
        do {
            let (data, response) = try await session.upload(for: request, from: audioData)
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                print("Upload successful: \(String(data: data, encoding: .utf8) ?? "")")
            } else {
                print("Upload failed with status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
        } catch {
            print("Upload error: \(error)")
            // TODO: Implement retry logic or queue for later
        }
    }
}

