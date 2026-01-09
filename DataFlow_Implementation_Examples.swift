import Foundation
import AVFoundation
import WatchConnectivity

// MARK: - Approach 1: Direct Upload from Watch

class DirectUploadManager {
    private let apiEndpoint = URL(string: "https://api.example.com/audio/upload")!
    
    /// Uploads audio data directly from Watch to cloud API
    func uploadAudio(audioData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        var request = URLRequest(url: apiEndpoint)
        request.httpMethod = "POST"
        request.setValue("audio/wav", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer YOUR_API_TOKEN", forHTTPHeaderField: "Authorization")
        
        // Use background URLSession for better battery efficiency
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.waitsForConnectivity = true // Wait for network if unavailable
        config.timeoutIntervalForRequest = 60.0
        config.timeoutIntervalForResource = 300.0 // 5 minutes for large uploads
        
        let session = URLSession(configuration: config)
        
        let task = session.uploadTask(with: request, from: audioData) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(UploadError.invalidResponse))
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                // Success - extract response ID if needed
                let responseId = String(data: data ?? Data(), encoding: .utf8) ?? ""
                completion(.success(responseId))
            } else {
                completion(.failure(UploadError.serverError(httpResponse.statusCode)))
            }
        }
        
        task.resume()
    }
    
    /// Converts Float audio buffer to WAV format Data
    func convertToWAV(audioBuffer: [Float], sampleRate: Int = 44100) -> Data {
        // Convert Float samples to Int16 PCM
        let int16Samples = audioBuffer.map { sample -> Int16 in
            let clamped = max(-1.0, min(1.0, sample))
            return Int16(clamped * Float(Int16.max))
        }
        
        // Create WAV file format
        var wavData = Data()
        
        // WAV header
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
        wavData.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) }) // fmt chunk size
        wavData.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) }) // PCM format
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
}

enum UploadError: Error {
    case invalidResponse
    case serverError(Int)
    case networkUnavailable
}

// MARK: - Approach 2: iPhone Intermediary via Watch Connectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    private var session: WCSession?
    @Published var isReachable = false
    
    override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else {
            print("Watch Connectivity not supported")
            return
        }
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    /// Send audio file to iPhone for upload
    func sendAudioToiPhone(audioFileURL: URL, metadata: [String: Any] = [:]) -> Bool {
        guard let session = session, session.isReachable else {
            print("iPhone not reachable")
            return false
        }
        
        var fileMetadata = metadata
        fileMetadata["timestamp"] = Date().timeIntervalSince1970
        fileMetadata["type"] = "audio_capture"
        
        session.transferFile(audioFileURL, metadata: fileMetadata)
        return true
    }
    
    /// Send audio data as message (for smaller files)
    func sendAudioDataToiPhone(audioData: Data, metadata: [String: Any] = [:]) -> Bool {
        guard let session = session, session.isReachable else {
            print("iPhone not reachable")
            return false
        }
        
        var message: [String: Any] = metadata
        message["audioData"] = audioData
        message["timestamp"] = Date().timeIntervalSince1970
        
        session.sendMessage(message, replyHandler: { response in
            print("Received reply from iPhone: \(response)")
        }, errorHandler: { error in
            print("Error sending to iPhone: \(error)")
        })
        
        return true
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error)")
            return
        }
        
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
}

// MARK: - iPhone Side: Receive and Upload

#if os(iOS)
class iPhoneUploadManager: NSObject, WCSessionDelegate {
    private let apiEndpoint = URL(string: "https://api.example.com/audio/upload")!
    
    func setupWatchConnectivity() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation
    }
    
    /// Receive file from Watch and upload to cloud
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // Process received file
        let audioData = try? Data(contentsOf: file.fileURL)
        
        // Optionally compress/encode audio here before upload
        // let compressedData = compressAudio(audioData)
        
        // Upload to cloud API
        uploadToCloud(audioData: audioData ?? Data(), metadata: file.metadata ?? [:])
        
        // Clean up temporary file
        try? FileManager.default.removeItem(at: file.fileURL)
    }
    
    /// Receive message from Watch and upload to cloud
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let audioData = message["audioData"] as? Data else { return }
        
        // Upload to cloud API
        uploadToCloud(audioData: audioData, metadata: message)
    }
    
    private func uploadToCloud(audioData: Data, metadata: [String: Any]) {
        var request = URLRequest(url: apiEndpoint)
        request.httpMethod = "POST"
        request.setValue("audio/wav", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer YOUR_API_TOKEN", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.uploadTask(with: request, from: audioData) { data, response, error in
            if let error = error {
                print("Upload error: \(error)")
                // Queue for retry
                return
            }
            
            print("Upload successful")
        }
        
        task.resume()
    }
}
#endif

// MARK: - Hybrid Approach: Smart Routing

class HybridUploadManager {
    private let directUpload = DirectUploadManager()
    private let watchConnectivity = WatchConnectivityManager.shared
    
    /// Intelligently routes upload based on network conditions
    func uploadAudio(audioData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        // Check network availability on Watch
        let networkAvailable = checkNetworkAvailability()
        
        if networkAvailable {
            // Try direct upload first
            directUpload.uploadAudio(audioData: audioData) { result in
                switch result {
                case .success:
                    completion(result)
                case .failure:
                    // Fallback to iPhone if direct upload fails
                    self.fallbackToiPhone(audioData: audioData, completion: completion)
                }
            }
        } else {
            // No network, use iPhone
            fallbackToiPhone(audioData: audioData, completion: completion)
        }
    }
    
    private func checkNetworkAvailability() -> Bool {
        // Check if Watch has network connectivity
        // This is a simplified check - in production, use Network framework
        return true // Placeholder
    }
    
    private func fallbackToiPhone(audioData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        // Save to temporary file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("wav")
        
        do {
            try audioData.write(to: tempURL)
            
            if watchConnectivity.sendAudioToiPhone(audioFileURL: tempURL) {
                // Successfully sent to iPhone
                // iPhone will handle upload and notify via Watch Connectivity if needed
                completion(.success("sent_to_iphone"))
            } else {
                completion(.failure(UploadError.networkUnavailable))
            }
        } catch {
            completion(.failure(error))
        }
    }
}

