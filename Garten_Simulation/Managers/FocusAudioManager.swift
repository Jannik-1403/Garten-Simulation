import Foundation
import AVFoundation
import Combine

/// Steuert das Abspielen von Fokus-Sounds (lokale Dateien & synthetisches Rauschen)
class FocusAudioManager: ObservableObject {
    static let shared = FocusAudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    
    @Published var currentSound: FocusSound = .none
    @Published var isPlaying: Bool = false
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            // Ermöglicht das Abspielen im Hintergrund und optionales Mischen mit anderen Musik-Apps
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
        } catch {
            print("FocusAudioManager: Audio Session Setup fehlgeschlagen: \(error)")
        }
    }
    
    /// Startet das Abspielen eines Fokus-Sounds
    func play(sound: FocusSound) {
        stop()
        
        guard sound != .none else { return }
        
        currentSound = sound
        isPlaying = true
        
        // Audio Session aktiv schalten
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("FocusAudioManager: Aktivieren der Audio Session fehlgeschlagen: \(error)")
        }
        
        if sound == .whiteNoise || sound == .brownNoise {
            playSynthesizedNoise(type: sound)
        } else {
            playBundleFile(named: sound.fileName)
        }
    }
    
    /// Stoppt das Abspielen und setzt den Zustand zurück
    func stop() {
        // Stop AVAudioPlayer
        if let player = audioPlayer {
            player.stop()
            audioPlayer = nil
        }
        
        // Stop AVAudioEngine & PlayerNode
        if let node = audioPlayerNode {
            node.stop()
            audioPlayerNode = nil
        }
        if let engine = audioEngine {
            engine.stop()
            audioEngine = nil
        }
        
        // Audio Session inaktivieren (mit Option, andere Apps nicht zu unterbrechen)
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("FocusAudioManager: Deaktivieren der Audio Session fehlgeschlagen: \(error)")
        }
        
        currentSound = .none
        isPlaying = false
    }
    
    private func playBundleFile(named name: String) {
        guard !name.isEmpty,
              let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("FocusAudioManager: Sound-Datei '\(name).mp3' nicht im Bundle gefunden. Nutze weißes Rauschen als Fallback.")
            playSynthesizedNoise(type: .whiteNoise)
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // Unendliches Looping
            player.prepareToPlay()
            player.play()
            self.audioPlayer = player
        } catch {
            print("FocusAudioManager: Fehler beim Abspielen von \(name).mp3: \(error)")
            playSynthesizedNoise(type: .whiteNoise)
        }
    }
    
    private func playSynthesizedNoise(type: FocusSound) {
        let engine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()
        engine.attach(playerNode)
        
        // Standard-Audioformat (Mono, 44.1kHz)
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        
        // Erzeuge 2 Sekunden Puffer für nahtloses Loopen
        let bufferSize = AVAudioFrameCount(44100 * 2)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferSize) else {
            print("FocusAudioManager: Puffer-Erstellung fehlgeschlagen.")
            return
        }
        buffer.frameLength = bufferSize
        
        guard let channels = buffer.floatChannelData else {
            print("FocusAudioManager: Kanal-Daten nicht verfügbar.")
            return
        }
        let data = channels[0]
        
        var b0: Float = 0.0
        var b1: Float = 0.0
        var b2: Float = 0.0
        var b3: Float = 0.0
        var b4: Float = 0.0
        var b5: Float = 0.0
        var b6: Float = 0.0
        
        var lastOut1: Float = 0.0
        var lastOut2: Float = 0.0
        
        for i in 0..<Int(bufferSize) {
            let white = Float.random(in: -1.0...1.0)
            if type == .whiteNoise {
                // Paul Kellet Pink Noise Filter (sehr weicher, natürlicher Wasserfall-Sound)
                b0 = 0.99886 * b0 + white * 0.0555179
                b1 = 0.99332 * b1 + white * 0.0750759
                b2 = 0.96900 * b2 + white * 0.1538520
                b3 = 0.86650 * b3 + white * 0.3104856
                b4 = 0.55000 * b4 + white * 0.5329522
                b5 = -0.7616 * b5 - white * 0.0168980
                let pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362
                b6 = white * 0.115926
                data[i] = pink * 0.12
            } else {
                // 2-Pol-Tiefpassfilter für warmes, tiefes Brown Noise (Meeresrauschen)
                lastOut1 = 0.993 * lastOut1 + 0.007 * white
                lastOut2 = 0.991 * lastOut2 + 0.009 * lastOut1
                data[i] = lastOut2 * 8.5
            }
            
            // Soft-Clipping Limiter gegen digitale Verzerrung
            if data[i] > 1.0 {
                data[i] = 1.0
            } else if data[i] < -1.0 {
                data[i] = -1.0
            }
        }
        
        do {
            try engine.start()
            playerNode.play()
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            
            self.audioEngine = engine
            self.audioPlayerNode = playerNode
        } catch {
            print("FocusAudioManager: AudioEngine-Start fehlgeschlagen: \(error)")
        }
    }
}
