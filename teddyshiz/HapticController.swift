import CoreHaptics
import Foundation

class HapticController {
  static let shared = HapticController()
  private var engine: CHHapticEngine?
  private var continuousPlayer: CHHapticAdvancedPatternPlayer?
  private var breathingPlayer: CHHapticAdvancedPatternPlayer?

  init() {
    createEngine()
  }

  private func createEngine() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    do {
      engine = try CHHapticEngine()
      try engine?.start()

      engine?.resetHandler = { [weak self] in
        do {
          try self?.engine?.start()
        } catch {
          print("Failed to restart engine: \(error)")
        }
      }
    } catch {
      print("Haptic Engine Error: \(error)")
    }
  }

  func startBreathingHaptic() {
    guard let engine = engine else { return }

    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.05)
    let event = CHHapticEvent(
      eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0,
      duration: 3.5)

    do {
      let pattern = try CHHapticPattern(events: [event], parameters: [])
      breathingPlayer = try engine.makeAdvancedPlayer(with: pattern)
      breathingPlayer?.loopEnabled = true
      try breathingPlayer?.start(atTime: 0)
    } catch {
      print("Failed to play breathing haptic: \(error)")
    }
  }

  func playHeartbeat() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    var events = [CHHapticEvent]()
    // 3 beats, 0.9s apart
    for i in 0..<3 {
      let timeOffset = Double(i) * 0.9
      // lub
      let int1 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
      let sharp1 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
      let lub = CHHapticEvent(
        eventType: .hapticTransient, parameters: [int1, sharp1], relativeTime: timeOffset)

      // dub
      let int2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
      let sharp2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.15)
      let dub = CHHapticEvent(
        eventType: .hapticTransient, parameters: [int2, sharp2], relativeTime: timeOffset + 0.15)

      events.append(lub)
      events.append(dub)
    }

    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: 0)
    } catch {
      print("Failed to play heartbeat: \(error)")
    }
  }

  func playSqueak() {
    playTransient(intensity: 0.6, sharpness: 0.4)
  }

  func playSurprise() {
    playTransient(intensity: 1.0, sharpness: 0.8)
  }

  func playGiggle() {
    playTransient(intensity: 0.8, sharpness: 0.6)
  }

  private func playTransient(intensity: Float, sharpness: Float) {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    let i = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
    let s = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
    let event = CHHapticEvent(eventType: .hapticTransient, parameters: [i, s], relativeTime: 0)

    do {
      let pattern = try CHHapticPattern(events: [event], parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: 0)
    } catch {
      print("Failed to play transient: \(error)")
    }
  }

  func startContinuousHaptic() {
    guard let engine = engine else { return }
    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.25)
    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
    let event = CHHapticEvent(
      eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0,
      duration: 100)

    do {
      let pattern = try CHHapticPattern(events: [event], parameters: [])
      continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
      try continuousPlayer?.start(atTime: 0)
    } catch {
      print("Continuous error: \(error)")
    }
  }

  func stopContinuousHaptic() {
    do {
      try continuousPlayer?.stop(atTime: 0)
    } catch {
      print(error)
    }
  }

  // MARK: - New Interaction Haptics

  func playListeningStart() {
    // Rising tone haptic - getting attention
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    var events = [CHHapticEvent]()
    for i in 0..<3 {
      let intensity = 0.3 + (Float(i) * 0.2)  // 0.3 -> 0.5 -> 0.7
      let int = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
      let sharp = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
      let event = CHHapticEvent(
        eventType: .hapticTransient, parameters: [int, sharp], relativeTime: Double(i) * 0.15)
      events.append(event)
    }

    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: 0)
    } catch {
      print("Failed to play listening start: \(error)")
    }
  }

  func playListeningEnd() {
    // Falling tone haptic - acknowledgment
    playTransient(intensity: 0.6, sharpness: 0.2)
  }

  func playWhisper() {
    // Very soft, gentle haptic
    playTransient(intensity: 0.2, sharpness: 0.05)
  }

  func playHug() {
    // Warm, sustained haptic
    guard let engine = engine else { return }
    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
    let event = CHHapticEvent(
      eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0,
      duration: 1.0)

    do {
      let pattern = try CHHapticPattern(events: [event], parameters: [])
      let player = try engine.makePlayer(with: pattern)
      try player.start(atTime: 0)
    } catch {
      print("Failed to play hug: \(error)")
    }
  }

  func playBounce() {
    // Quick bouncy haptic sequence
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    var events = [CHHapticEvent]()
    let bounces = [0.0, 0.2, 0.35]  // Timing
    let intensities: [Float] = [0.8, 0.6, 0.4]  // Decreasing

    for (index, time) in bounces.enumerated() {
      let int = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensities[index])
      let sharp = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
      let event = CHHapticEvent(
        eventType: .hapticTransient, parameters: [int, sharp], relativeTime: time)
      events.append(event)
    }

    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: 0)
    } catch {
      print("Failed to play bounce: \(error)")
    }
  }

  func playQuickTap() {
    // Sharp, quick double tap
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    var events = [CHHapticEvent]()
    for i in 0..<2 {
      let int = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
      let sharp = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
      let event = CHHapticEvent(
        eventType: .hapticTransient, parameters: [int, sharp], relativeTime: Double(i) * 0.1)
      events.append(event)
    }

    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: 0)
    } catch {
      print("Failed to play quick tap: \(error)")
    }
  }

  func playBreathing() {
    // Gentle, calm breathing haptic
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
    let event = CHHapticEvent(
      eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 2.1)

    do {
      let pattern = try CHHapticPattern(events: [event], parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: 0)
    } catch {
      print("Failed to play breathing: \(error)")
    }
  }
}
