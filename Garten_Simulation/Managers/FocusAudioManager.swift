import Foundation
import AVFoundation
import Combine

/// Steuert das Abspielen von Fokus-Sounds mit hochwertiger Echtzeit-Synthese
class FocusAudioManager: ObservableObject {
    static let shared = FocusAudioManager()

    // MARK: - Engine Components
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var eqNode: AVAudioUnitEQ?
    private var reverbNode: AVAudioUnitReverb?
    private var audioPlayer: AVAudioPlayer?

    // MARK: - State
    @Published var currentSound: FocusSound = .none
    @Published var isPlaying: Bool = false

    private let sampleRate: Double = 44100
    // 4 Sekunden Puffer für nahtloses Looping
    private var bufferDuration: Double = 4.0

    private init() {
        setupAudioSession()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
        } catch {
            print("FocusAudioManager: Audio Session Setup fehlgeschlagen: \(error)")
        }
    }

    // MARK: - Public API

    func play(sound: FocusSound) {
        stop()
        guard sound != .none else { return }

        currentSound = sound
        isPlaying = true

        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("FocusAudioManager: Aktivieren fehlgeschlagen: \(error)")
        }

        if sound == .rain || sound == .cafe || sound == .zenFlute ||
           sound == .whiteNoise || sound == .brownNoise {
            playSynthesized(sound: sound)
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil

        playerNode?.stop()
        playerNode = nil

        eqNode = nil
        reverbNode = nil

        audioEngine?.stop()
        audioEngine = nil

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {}

        currentSound = .none
        isPlaying = false
    }

    // MARK: - Synthese-Engine

    private func playSynthesized(sound: FocusSound) {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        let eq = AVAudioUnitEQ(numberOfBands: 3)
        let reverb = AVAudioUnitReverb()

        engine.attach(player)
        engine.attach(eq)
        engine.attach(reverb)

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        engine.connect(player, to: eq, format: format)
        engine.connect(eq, to: reverb, format: format)
        engine.connect(reverb, to: engine.mainMixerNode, format: format)

        // Sound-spezifische Effekte konfigurieren
        configureEffects(eq: eq, reverb: reverb, for: sound)

        // Puffer erzeugen
        guard let buffer = buildBuffer(for: sound, format: format) else { return }

        do {
            try engine.start()
            player.play()
            player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            self.audioEngine = engine
            self.playerNode = player
            self.eqNode = eq
            self.reverbNode = reverb
        } catch {
            print("FocusAudioManager: Engine-Start fehlgeschlagen: \(error)")
            isPlaying = false
        }
    }

    private func configureEffects(eq: AVAudioUnitEQ, reverb: AVAudioUnitReverb, for sound: FocusSound) {
        switch sound {
        case .rain:
            // Hochpass: entfernt Ultratiefton, Tiefpass: entfernt zu hartes Knistern
            eq.bands[0].filterType = .highPass
            eq.bands[0].frequency = 120
            eq.bands[0].bypass = false
            eq.bands[1].filterType = .lowPass
            eq.bands[1].frequency = 8000
            eq.bands[1].bypass = false
            eq.bands[2].filterType = .parametric
            eq.bands[2].frequency = 2500
            eq.bands[2].gain = -4
            eq.bands[2].bandwidth = 1.5
            eq.bands[2].bypass = false
            reverb.loadFactoryPreset(.largeChamber)
            reverb.wetDryMix = 25

        case .cafe:
            // Warmton: anheben bei 200Hz, absenken bei 4kHz+ für Stimmengemurmel
            eq.bands[0].filterType = .highPass
            eq.bands[0].frequency = 80
            eq.bands[0].bypass = false
            eq.bands[1].filterType = .parametric
            eq.bands[1].frequency = 300
            eq.bands[1].gain = 3
            eq.bands[1].bandwidth = 1.0
            eq.bands[1].bypass = false
            eq.bands[2].filterType = .lowPass
            eq.bands[2].frequency = 5000
            eq.bands[2].bypass = false
            reverb.loadFactoryPreset(.mediumHall)
            reverb.wetDryMix = 35

        case .zenFlute:
            // Klar und offen mit etwas Hall für Raum-Gefühl
            eq.bands[0].filterType = .highPass
            eq.bands[0].frequency = 200
            eq.bands[0].bypass = false
            eq.bands[1].filterType = .parametric
            eq.bands[1].frequency = 1200
            eq.bands[1].gain = 2
            eq.bands[1].bandwidth = 2.0
            eq.bands[1].bypass = false
            eq.bands[2].filterType = .lowPass
            eq.bands[2].frequency = 10000
            eq.bands[2].bypass = false
            reverb.loadFactoryPreset(.cathedral)
            reverb.wetDryMix = 30

        case .whiteNoise:
            // Sehr weich und gleichmäßig
            eq.bands[0].filterType = .highPass
            eq.bands[0].frequency = 200
            eq.bands[0].bypass = false
            eq.bands[1].filterType = .lowPass
            eq.bands[1].frequency = 12000
            eq.bands[1].bypass = false
            eq.bands[2].bypass = true
            reverb.loadFactoryPreset(.smallRoom)
            reverb.wetDryMix = 10

        case .brownNoise:
            // Warm und bassreich
            eq.bands[0].filterType = .highPass
            eq.bands[0].frequency = 40
            eq.bands[0].bypass = false
            eq.bands[1].filterType = .parametric
            eq.bands[1].frequency = 150
            eq.bands[1].gain = 4
            eq.bands[1].bandwidth = 1.5
            eq.bands[1].bypass = false
            eq.bands[2].filterType = .lowPass
            eq.bands[2].frequency = 600
            eq.bands[2].bypass = false
            reverb.loadFactoryPreset(.smallRoom)
            reverb.wetDryMix = 8

        case .none:
            eq.bands[0].bypass = true
            eq.bands[1].bypass = true
            eq.bands[2].bypass = true
            reverb.wetDryMix = 0
        }
    }

    // MARK: - Puffer-Erzeugung

    private func buildBuffer(for sound: FocusSound, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(sampleRate * bufferDuration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount

        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else { return nil }

        switch sound {
        case .rain:
            fillRain(left: left, right: right, count: Int(frameCount))
        case .cafe:
            fillCafe(left: left, right: right, count: Int(frameCount))
        case .zenFlute:
            fillZenFlute(left: left, right: right, count: Int(frameCount))
        case .whiteNoise:
            fillWhiteNoise(left: left, right: right, count: Int(frameCount))
        case .brownNoise:
            fillBrownNoise(left: left, right: right, count: Int(frameCount))
        case .none:
            break
        }

        return buffer
    }

    // MARK: - Regen (mehrschichtig)

    private func fillRain(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, count: Int) {
        // Schicht 1: Basisrauschen (Dauerregen-Teppich)
        var b0: Float = 0, b1: Float = 0, b2: Float = 0, b3: Float = 0
        var b0r: Float = 0, b1r: Float = 0, b2r: Float = 0, b3r: Float = 0

        // Schicht 2: Amplitudenmodulation (Windböen)
        var lfoPhase: Double = 0
        let lfoSpeed = 0.08 / sampleRate // sehr langsam

        // Schicht 3: Einzeltropfen-Simulation
        var dropTimer: Int = 0
        var dropInterval: Int = Int.random(in: 800...2400)
        var dropAmplitude: Float = 0

        let gain: Float = 0.22

        for i in 0..<count {
            let wL = Float.random(in: -1.0...1.0)
            let wR = Float.random(in: -1.0...1.0)

            // Pink-Noise Filter für natürliches Regen-Spektrum (links)
            b0 = 0.99886 * b0 + wL * 0.0555179
            b1 = 0.99332 * b1 + wL * 0.0750759
            b2 = 0.96900 * b2 + wL * 0.1538520
            b3 = 0.86650 * b3 + wL * 0.3104856
            let pinkL = (b0 + b1 + b2 + b3 + wL * 0.5362) * 0.14

            // Pink-Noise rechts (leicht phasenversetzt für Stereo-Breite)
            b0r = 0.99886 * b0r + wR * 0.0555179
            b1r = 0.99332 * b1r + wR * 0.0750759
            b2r = 0.96900 * b2r + wR * 0.1538520
            b3r = 0.86650 * b3r + wR * 0.3104856
            let pinkR = (b0r + b1r + b2r + b3r + wR * 0.5362) * 0.14

            // Langsame Windmodulation (LFO)
            lfoPhase += lfoSpeed
            let windMod = Float(0.75 + 0.25 * sin(lfoPhase * .pi * 2))

            // Tropfen
            dropTimer += 1
            if dropTimer >= dropInterval {
                dropTimer = 0
                dropInterval = Int.random(in: 600...2200)
                dropAmplitude = Float.random(in: 0.15...0.45)
            }
            // Tropfen klingt schnell ab
            let drop = dropAmplitude
            dropAmplitude *= 0.988

            let outL = clamp((pinkL * windMod + drop * Float.random(in: -1...1) * 0.08) * gain)
            let outR = clamp((pinkR * windMod + drop * Float.random(in: -1...1) * 0.08) * gain)

            left[i] = outL
            right[i] = outR
        }
    }

    // MARK: - Kaffeehaus (Stimmengemurmel + Atmo)

    private func fillCafe(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, count: Int) {
        // Mehrere "Stimm"-Frequenzbänder als Bandpass-gefiltertes Rauschen
        var voices: [(freq: Float, band: Float, phase: Float, vol: Float)] = [
            (280, 0, 0, 0.35),
            (420, 0, 0, 0.25),
            (650, 0, 0, 0.20),
            (1100, 0, 0, 0.12),
            (1800, 0, 0, 0.08)
        ]
        var bgL: Float = 0 // Hintergrund-Rauschen
        var bgR: Float = 0

        // Atemmodulation (2-4 sec Perioden = natürliches Auf/Ab)
        var lfoPhase: Double = 0
        let lfoRate = 0.35 / sampleRate

        let sR = Float(sampleRate)
        let gain: Float = 0.20

        for i in 0..<count {
            let white = Float.random(in: -1.0...1.0)
            let whiteR = Float.random(in: -1.0...1.0)

            // Hintergrundteppich (leises, weiches Rauschen)
            bgL = 0.97 * bgL + 0.03 * white
            bgR = 0.97 * bgR + 0.03 * whiteR

            // Bandpassgefilterte Stimmschichten
            var mixL: Float = bgL * 0.15
            var mixR: Float = bgR * 0.15

            for j in 0..<voices.count {
                let omega = 2 * Float.pi * voices[j].freq / sR
                let alpha = Float(sin(Double(omega))) / (2 * 2.0) // Q=2.0
                let bpFiltered = alpha * white - alpha * voices[j].phase
                voices[j].phase = (1 - alpha * 2) * voices[j].phase + voices[j].band * alpha
                voices[j].band = bpFiltered

                let voiceOut = bpFiltered * voices[j].vol
                mixL += voiceOut
                mixR += voiceOut * Float.random(in: 0.8...1.0) // leichte Stereo-Varianz
            }

            // Frequenzmodulation = natürliche Sprachkadenz
            lfoPhase += lfoRate
            let speechMod = Float(0.6 + 0.4 * sin(lfoPhase * .pi * 2) * sin(lfoPhase * .pi * 0.7))

            left[i] = clamp(mixL * speechMod * gain)
            right[i] = clamp(mixR * speechMod * gain)
        }
    }

    // MARK: - Zen-Flöte (harmonische Additivsynthese)

    private func fillZenFlute(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, count: Int) {
        // Pentatonische Töne für meditativen Charakter
        let rootFrequencies: [Float] = [261.63, 293.66, 329.63, 392.00, 440.00, 523.25] // C4, D4, E4, G4, A4, C5
        let sR = Float(sampleRate)
        let gain: Float = 0.30

        // Phasen für Hauptton + Obertöne
        var phases = Array(repeating: Float(0), count: rootFrequencies.count * 4)

        // Hüllkurven: lange Attack, lange Release (Atemschwingungen)
        var noteTimer: Int = Int(sampleRate * 2.5) // erste Note nach 2.5s
        var noteLength: Int = Int(sampleRate * Double.random(in: 3.0...6.0))
        var currentNote = 0
        var envPhase: Double = 0
        let envRate = 1.0 / (sampleRate * 2.0) // 2s Attack/Release

        // Atemgeräusch-Rauschen für Flöten-Charakter
        var breathL: Float = 0, breathR: Float = 0
        var breathEnv: Float = 0

        for i in 0..<count {
            noteTimer += 1
            if noteTimer >= noteLength {
                noteTimer = 0
                noteLength = Int(sampleRate * Double.random(in: 2.5...5.5))
                currentNote = Int.random(in: 0..<rootFrequencies.count)
                envPhase = 0
                breathEnv = Float.random(in: 0.08...0.18)
            }

            // Hüllkurve: sin²-förmig für weiches An-/Abschwellen
            envPhase = min(envPhase + envRate * 2, 1.0)
            let env = Float(sin(envPhase * .pi / 2))

            let baseFreq = rootFrequencies[currentNote]
            var sample: Float = 0

            // Grundton + 3 Obertöne mit abnehmender Amplitude
            let harmonicAmps: [Float] = [1.0, 0.5, 0.25, 0.12]
            let harmonicMult: [Float] = [1.0, 2.0, 3.0, 4.0]

            let phaseBase = currentNote * 4
            for h in 0..<4 {
                let freq = baseFreq * harmonicMult[h]
                let inc = freq / sR
                phases[phaseBase + h] = phases[phaseBase + h].truncatingRemainder(dividingBy: 1.0) + inc
                sample += Float(sin(Double(phases[phaseBase + h]) * .pi * 2)) * harmonicAmps[h]
            }

            // Atmen (Rauschen am Anfang jeder Note)
            let white = Float.random(in: -1.0...1.0)
            breathL = 0.92 * breathL + 0.08 * white
            breathR = 0.92 * breathR + 0.08 * Float.random(in: -1.0...1.0)
            breathEnv *= 0.9995

            let finalSample = (sample * 0.75 + breathL * breathEnv) * env * gain
            let finalSampleR = (sample * 0.75 + breathR * breathEnv) * env * gain

            left[i] = clamp(finalSample)
            right[i] = clamp(finalSampleR)
        }
    }

    // MARK: - Weißes Rauschen (Pink-gefiltert)

    private func fillWhiteNoise(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, count: Int) {
        var b0: Float = 0, b1: Float = 0, b2: Float = 0, b3: Float = 0, b4: Float = 0, b5: Float = 0, b6: Float = 0
        var b0r: Float = 0, b1r: Float = 0, b2r: Float = 0, b3r: Float = 0, b4r: Float = 0, b5r: Float = 0, b6r: Float = 0

        for i in 0..<count {
            let wL = Float.random(in: -1.0...1.0)
            let wR = Float.random(in: -1.0...1.0)

            b0 = 0.99886 * b0 + wL * 0.0555179
            b1 = 0.99332 * b1 + wL * 0.0750759
            b2 = 0.96900 * b2 + wL * 0.1538520
            b3 = 0.86650 * b3 + wL * 0.3104856
            b4 = 0.55000 * b4 + wL * 0.5329522
            b5 = -0.7616 * b5 - wL * 0.0168980
            let pinkL = b0 + b1 + b2 + b3 + b4 + b5 + b6 + wL * 0.5362
            b6 = wL * 0.115926

            b0r = 0.99886 * b0r + wR * 0.0555179
            b1r = 0.99332 * b1r + wR * 0.0750759
            b2r = 0.96900 * b2r + wR * 0.1538520
            b3r = 0.86650 * b3r + wR * 0.3104856
            b4r = 0.55000 * b4r + wR * 0.5329522
            b5r = -0.7616 * b5r - wR * 0.0168980
            let pinkR = b0r + b1r + b2r + b3r + b4r + b5r + b6r + wR * 0.5362
            b6r = wR * 0.115926

            left[i] = clamp(pinkL * 0.11)
            right[i] = clamp(pinkR * 0.11)
        }
    }

    // MARK: - Braunes Rauschen (tief und warm)

    private func fillBrownNoise(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, count: Int) {
        var lastL: Float = 0, lastR: Float = 0
        var last2L: Float = 0, last2R: Float = 0

        for i in 0..<count {
            let wL = Float.random(in: -1.0...1.0)
            let wR = Float.random(in: -1.0...1.0)

            lastL = 0.993 * lastL + 0.007 * wL
            last2L = 0.991 * last2L + 0.009 * lastL
            lastR = 0.993 * lastR + 0.007 * wR
            last2R = 0.991 * last2R + 0.009 * lastR

            left[i] = clamp(last2L * 7.0)
            right[i] = clamp(last2R * 7.0)
        }
    }

    // MARK: - Helper

    @inline(__always)
    private func clamp(_ value: Float) -> Float {
        // Sanftes Soft-Clipping statt hartem Limiter
        if value > 0.95 { return 0.95 + tanh((value - 0.95) * 5) * 0.05 }
        if value < -0.95 { return -0.95 + tanh((value + 0.95) * 5) * 0.05 }
        return value
    }
}
