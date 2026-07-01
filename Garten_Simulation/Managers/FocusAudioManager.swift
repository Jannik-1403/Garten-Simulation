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
        
        var lastOut: Float = 0.0
        for i in 0..<Int(bufferSize) {
            if type == .whiteNoise {
                // Weißes Rauschen: Zufällige Werte zwischen -1.0 und 1.0 (leicht gedämpft)
                data[i] = Float.random(in: -1.0...1.0) * 0.15
            } else {
                // Braunes Rauschen: Akkumuliertes weißes Rauschen (Tiefpassfilter)
                let white = Float.random(in: -1.0...1.0)
                data[i] = (lastOut + (0.02 * white)) / 1.02
                lastOut = data[i]
                data[i] *= 2.0 // Lautstärke-Kompensation
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
