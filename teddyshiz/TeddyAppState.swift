import Foundation
import Combine
import CoreGraphics

enum TeddyMood {
    case idle
    case petted
    case listening      // Triple tap - listening to voice message
    case hugged        // Pinch gesture - being hugged
    case excited       // Swipe up - lifted/playing
}

@MainActor
class TeddyAppState: ObservableObject {
    @Published var mood: TeddyMood = .idle
    @Published var isGlowFlares: Bool = false

    // Configurable constants based on state
    var breathingDuration: TimeInterval {
        switch mood {
        case .excited: return 1.5
        case .listening: return 2.8
        case .hugged: return 3.0
        default: return 3.5
        }
    }

    @Published var isLullabyPlaying: Bool = false
    @Published var isBreathingActive: Bool = false
    @Published var showTimeChangeReaction: Bool = false
    @Published var showTimePicker: Bool = false
    @Published var timeChangeEmoji: String = ""
    @Published var timePickerLocation: CGPoint = .zero

    private var returnToIdleTask: Task<Void, Never>?
    private var breathingTask: Task<Void, Never>?
    private var longPressTask: Task<Void, Never>?
    private var longPressStartLocation: CGPoint = .zero
    
    func tapBelly() {
        isGlowFlares = true
        HapticController.shared.playHeartbeat()
        AudioController.shared.playHeartbeat()

        // Return glow to normal after flash
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            isGlowFlares = false
        }
    }

    func tapBodyOrEar() {
        HapticController.shared.playSqueak()
        AudioController.shared.playSqueak()
        // Animations handled by RealityKit directly
    }

    func startPetting() {
        mood = .petted
        HapticController.shared.startContinuousHaptic()
        AudioController.shared.startPurring()
        cancelReturnToIdle()
    }
    
    func stopPetting() {
        if mood == .petted {
            HapticController.shared.stopContinuousHaptic()
            AudioController.shared.stopPurring()
            scheduleReturnToIdle(after: 1.0)
        }
    }
    
    func tickle() {
        HapticController.shared.playGiggle()
        AudioController.shared.playGiggle()
        // Wiggle animation in RealityKit
    }

    func shake() {
        // Toggle lullaby on/off
        if isLullabyPlaying {
            AudioController.shared.stopLullaby()
            isLullabyPlaying = false
            print("🎵 Lullaby stopped")
        } else {
            AudioController.shared.startLullaby()
            isLullabyPlaying = true
            print("🎵 Lullaby started")
        }
        HapticController.shared.playSurprise()
    }
    
    private func scheduleReturnToIdle(after seconds: TimeInterval) {
        cancelReturnToIdle()
        returnToIdleTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self.mood = .idle
        }
    }
    
    private func cancelReturnToIdle() {
        returnToIdleTask?.cancel()
        returnToIdleTask = nil
    }

    // MARK: - New Conversation/Play Interactions

    func startListening() {
        // Triple tap - start listening mode
        mood = .listening
        cancelReturnToIdle()
        isGlowFlares = true
        HapticController.shared.playListeningStart()
        AudioController.shared.playListeningChime()

        // Pulse glow while listening (3 pulses)
        Task {
            for _ in 0..<3 {
                try? await Task.sleep(nanoseconds: 800_000_000)
                isGlowFlares.toggle()
            }

            // After listening period (5s total), teddy responds with anime quote!
            try? await Task.sleep(nanoseconds: 1_600_000_000)  // Remaining time to make 5s

            // Teddy speaks!
            await MainActor.run {
                self.speakRandomQuote()
            }
        }
    }

    func stopListening() {
        if mood == .listening {
            HapticController.shared.playListeningEnd()
            AudioController.shared.playResponseSound()
            isGlowFlares = false
            scheduleReturnToIdle(after: 1.0)
        }
    }

    func speakRandomQuote() {
        // Teddy speaks a random anime quote
        print("💬 Teddy is speaking!")
        isGlowFlares = true
        HapticController.shared.playListeningEnd()
        SpeechController.shared.speakRandomQuote()

        // Keep glow while speaking
        Task {
            // Wait for speech to finish (estimated 5s max)
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            isGlowFlares = false
            scheduleReturnToIdle(after: 1.0)
        }
    }

    func whisperSecret() {
        // Long press - whisper mode
        guard mood != .listening else { return }
        HapticController.shared.playWhisper()
        AudioController.shared.playWhisperSound()

        // Subtle glow effect
        Task {
            isGlowFlares = true
            try? await Task.sleep(nanoseconds: 500_000_000)
            isGlowFlares = false
        }
    }

    func hugTeddy() {
        // Pinch gesture - hug
        mood = .hugged
        cancelReturnToIdle()
        HapticController.shared.playHug()
        AudioController.shared.playHappyGiggle()

        // Warm expanding glow
        isGlowFlares = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            isGlowFlares = false
        }

        scheduleReturnToIdle(after: 2.0)
    }

    func liftTeddy() {
        // Swipe up - excited play mode
        mood = .excited
        cancelReturnToIdle()
        HapticController.shared.playBounce()
        AudioController.shared.playExcitedSqueak()

        scheduleReturnToIdle(after: 2.0)
    }

    func doubleTapBreathing() {
        // Double tap - toggle breathing/calm effect
        guard mood != .listening else { return }

        print("🫁 Double tap - current breathing state: \(isBreathingActive)")

        if isBreathingActive {
            // Stop breathing
            print("🫁 Stopping manual breathing")
            stopBreathing()
        } else {
            // Start breathing
            print("🫁 Starting manual breathing")
            startBreathing()
        }
    }

    private func startBreathing() {
        isBreathingActive = true
        HapticController.shared.playBreathing()
        print("🫁 Breathing started")

        // Cancel any existing breathing task
        breathingTask?.cancel()

        // Start continuous breathing glow loop
        breathingTask = Task {
            while !Task.isCancelled && isBreathingActive {
                // Breathing in (glow on)
                await MainActor.run {
                    isGlowFlares = true
                }
                try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5s inhale

                guard !Task.isCancelled && isBreathingActive else { break }

                // Breathing out (glow off)
                await MainActor.run {
                    isGlowFlares = false
                }
                try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5s exhale
            }

            // Ensure glow is off when stopped
            await MainActor.run {
                isGlowFlares = false
            }
        }
    }

    private func stopBreathing() {
        isBreathingActive = false
        breathingTask?.cancel()
        breathingTask = nil
        isGlowFlares = false
        print("🫁 Breathing stopped")
    }

    func tapHead() {
        // Head pat - start purring
        startPetting()
    }

    // MARK: - Long Press Time Change

    func startLongPress(at location: CGPoint) {
        // Cancel any existing long press
        longPressTask?.cancel()

        // Store the tap location for later
        longPressStartLocation = location

        print("⏰ Long press started at \(location) - hold for 2s to change time")
        isGlowFlares = true

        longPressTask = Task {
            // Wait for 2 seconds with haptic feedback
            for i in 1...2 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }

                // Pulse haptic feedback every second
                await MainActor.run {
                    HapticController.shared.playSqueak()
                }

                print("⏰ Long press: \(i)s / 2s")
            }

            // Successfully held for 2 seconds - trigger time change!
            guard !Task.isCancelled else { return }

            await MainActor.run {
                triggerTimeChange()
            }
        }
    }

    func cancelLongPress() {
        longPressTask?.cancel()
        longPressTask = nil
        isGlowFlares = false
        print("⏰ Long press cancelled")
    }

    private func triggerTimeChange() {
        print("⏰ Long press completed - showing time picker at \(longPressStartLocation)")

        // Turn off glow
        isGlowFlares = false

        // Play haptic feedback
        HapticController.shared.playBounce()

        // Set picker location and show it
        timePickerLocation = longPressStartLocation
        showTimePicker = true
    }

    func selectTimeOfDay(_ time: TimeOfDay) {
        print("⏰ Time selected: \(time.emoji) \(time.displayName)")

        // Show reaction overlay with emoji
        timeChangeEmoji = time.emoji
        showTimeChangeReaction = true

        // Play excited reaction
        AudioController.shared.playExcitedSqueak()

        // Post notification to change time with selected time
        NotificationCenter.default.post(
            name: .changeTimeOfDay,
            object: nil,
            userInfo: ["time": time]
        )

        // Hide reaction after 2 seconds
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                showTimeChangeReaction = false
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let changeTimeOfDay = Notification.Name("changeTimeOfDay")
}
