import AVFoundation
import Foundation

class AudioController {
  static let shared = AudioController()

  // Players for each audio file type
  private var lullabyPlayer: AVAudioPlayer?
  private var heartbeatPlayer: AVAudioPlayer?
  private var breathingPlayer: AVAudioPlayer?
  private var purringPlayer: AVAudioPlayer?
  private var squeakPlayer: AVAudioPlayer?
  private var gigglePlayer: AVAudioPlayer?
  private var surprisePlayer: AVAudioPlayer?

  init() {
    setupAudioSession()
    loadSounds()
    startBackgroundSounds()
  }

  private func setupAudioSession() {
    do {
      // Use .playback category so audio plays even when silent switch is on
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try AVAudioSession.sharedInstance().setActive(true)
      print("✅ Audio session configured for playback")
    } catch {
      print("❌ Failed to set audio session category: \(error)")
    }
  }

  private func loadSounds() {
    // Load sounds if they exist in the bundle.
    // It's expected that the user drops these into the Xcode project later.
    lullabyPlayer = loadPlayer(named: "lullaby")
    lullabyPlayer?.numberOfLoops = -1

    heartbeatPlayer = loadPlayer(named: "heartbeat")
    breathingPlayer = loadPlayer(named: "breathing")
    breathingPlayer?.numberOfLoops = -1

    purringPlayer = loadPlayer(named: "purring")
    purringPlayer?.numberOfLoops = -1

    squeakPlayer = loadPlayer(named: "squeak")
    gigglePlayer = loadPlayer(named: "giggle")
    surprisePlayer = loadPlayer(named: "surprise")
  }

  private func loadPlayer(named name: String) -> AVAudioPlayer? {
    // Try common extensions
    for ext in ["mp3", "wav", "m4a"] {
      if let url = Bundle.main.url(forResource: name, withExtension: ext) {
        return try? AVAudioPlayer(contentsOf: url)
      }
    }
    print("Warning: Audio file \(name) not found in bundle.")
    return nil
  }

  private func startBackgroundSounds() {
    // Don't play lullaby automatically - can be enabled later if needed
    // lullabyPlayer?.volume = 0.2
    // lullabyPlayer?.play()

    breathingPlayer?.volume = 0.1
    breathingPlayer?.play()
  }

  func setLullabyVolume(_ v: Float) {
    lullabyPlayer?.setVolume(v, fadeDuration: 1.0)
  }

  func startLullaby() {
    lullabyPlayer?.volume = 0.2
    lullabyPlayer?.play()
  }

  func stopLullaby() {
    lullabyPlayer?.setVolume(0, fadeDuration: 2.0)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      self.lullabyPlayer?.pause()
    }
  }

  func playHeartbeat() {
    heartbeatPlayer?.play()
  }

  func playSqueak() {
    // Vary pitch slightly
    squeakPlayer?.enableRate = true
    squeakPlayer?.rate = Float.random(in: 0.95...1.05)
    squeakPlayer?.play()
  }

  func playGiggle() {
    gigglePlayer?.play()
  }

  func playSurprise() {
    surprisePlayer?.play()
  }

  func startPurring() {
    purringPlayer?.volume = 0.5
    purringPlayer?.play()
  }

  func stopPurring() {
    purringPlayer?.setVolume(0, fadeDuration: 0.5)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.purringPlayer?.pause()
    }
  }

  // MARK: - New Interaction Sounds

  func playListeningChime() {
    // Play a rising chime to indicate listening mode
    // For now, use squeak with modified pitch
    squeakPlayer?.enableRate = true
    squeakPlayer?.rate = 1.2
    squeakPlayer?.play()
  }

  func playResponseSound() {
    // Play a confirmation sound after listening
    // Use squeak with lower pitch
    squeakPlayer?.enableRate = true
    squeakPlayer?.rate = 0.8
    squeakPlayer?.play()
  }

  func playWhisperSound() {
    // Very soft, gentle sound
    squeakPlayer?.enableRate = true
    squeakPlayer?.rate = 0.7
    squeakPlayer?.volume = 0.3
    squeakPlayer?.play()
    // Reset volume after
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.squeakPlayer?.volume = 1.0
    }
  }

  func playHappyGiggle() {
    // Happy, extended giggle
    gigglePlayer?.play()
  }

  func playExcitedSqueak() {
    // High-pitched excited squeak
    squeakPlayer?.enableRate = true
    squeakPlayer?.rate = 1.3
    squeakPlayer?.play()
  }

  func playQuickSqueak() {
    // Quick double squeak
    squeakPlayer?.enableRate = true
    squeakPlayer?.rate = Float.random(in: 1.0...1.1)
    squeakPlayer?.play()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      self.squeakPlayer?.play()
    }
  }
}
