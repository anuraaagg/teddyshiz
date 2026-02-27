import AVFoundation
import Combine
import Foundation

class SpeechController: NSObject, ObservableObject {
  static let shared = SpeechController()

  private let synthesizer = AVSpeechSynthesizer()
  @Published var currentQuote: String = ""
  @Published var isSpeaking: Bool = false

  // Real anime quotes library
  private let animeQuotes: [String] = [
    // Naruto
    "If you don't like your destiny, don't accept it. Instead, have the courage to change it the way you want it to be!",
    "Hard work is worthless for those that don't believe in themselves.",
    "When people are protecting something truly special to them, they truly can become as strong as they can be.",

    // One Piece
    "When do you think people die? When they're forgotten!",
    "I don't want to conquer anything. I just think the guy with the most freedom in this ocean is the Pirate King!",

    // My Hero Academia
    "Whether you win or lose, you can always come out ahead by surpassing yourself.",
    "If you feel yourself hitting up against your limit, remember for what cause you clench your fists!",

    // Attack on Titan
    "If you win, you live. If you lose, you die. If you don't fight, you can't win!",
    "I'm not gonna give up! I'm gonna keep moving forward!",

    // Demon Slayer
    "No matter how many people you may lose, you have no choice but to go on living.",
    "Feel your heart burning! Dry your eyes and look ahead!",

    // Fullmetal Alchemist
    "A lesson without pain is meaningless. For you can gain nothing without sacrificing something.",
    "Stand up and walk. Keep moving forward. You've got two good legs, so get up and use them.",

    // Hunter x Hunter
    "You should enjoy the little detours to the fullest. Because that's where you'll find the things more important than what you want.",

    // Cowboy Bebop
    "Whatever happens, happens.",

    // Sword Art Online
    "Real strength is not just a condition of one's muscle, but a tenderness in one's spirit.",

    // Your Name
    "Treasure the experience. Dreams fade away after you wake up.",

    // Spirited Away
    "Once you do something, you never forget. Even if you can't remember.",
  ]

  override init() {
    super.init()
    synthesizer.delegate = self
  }

  /// Speak a random anime quote with cute voice
  func speakRandomQuote() {
    guard let quote = animeQuotes.randomElement() else { return }
    speakQuote(quote)
  }

  /// Speak a specific quote
  func speakQuote(_ text: String) {
    // Stop any current speech
    if synthesizer.isSpeaking {
      synthesizer.stopSpeaking(at: .immediate)
    }

    currentQuote = text
    isSpeaking = true

    let utterance = AVSpeechUtterance(string: text)

    // Configure voice - try to find a cute/child-like voice
    // Priority: Child voices, then high-pitched female voices
    if let voice = findCuteVoice() {
      utterance.voice = voice
    } else {
      // Fallback to default with high pitch
      utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    }

    // Make it sound like a soft, gentle voice
    utterance.rate = 0.45  // Slower for softer, clearer speech
    utterance.pitchMultiplier = 1.25  // Softer, gentler pitch (not too high)
    utterance.volume = 0.85  // Slightly quieter for gentleness

    // Add slight pre-delay for natural speech
    utterance.preUtteranceDelay = 0.15

    synthesizer.speak(utterance)
  }

  /// Find the softest, most gentle available voice
  private func findCuteVoice() -> AVSpeechSynthesisVoice? {
    let voices = AVSpeechSynthesisVoice.speechVoices()

    // Priority 1: Look for soft, gentle premium voices
    // "Samantha" (en-US) - Warm and gentle
    // "Nicky" (en-US) - Soft female voice
    // "Serena" (en-GB) - Gentle British
    // "Zoe" (en-AU) - Soft Australian
    let preferredVoiceNames = ["Samantha", "Nicky", "Serena", "Zoe", "Ava", "Susan"]

    for name in preferredVoiceNames {
      if let voice = voices.first(where: { $0.name.contains(name) }) {
        print("🎤 Using soft voice: \(voice.name)")
        return voice
      }
    }

    // Priority 2: Any English female voice
    let femaleVoice = voices.first { voice in
      voice.language.starts(with: "en") && voice.gender == .female
    }

    if let voice = femaleVoice {
      print("🎤 Using female voice: \(voice.name)")
      return voice
    }

    // Fallback: Default US English
    print("🎤 Using default voice")
    return AVSpeechSynthesisVoice(language: "en-US")
  }

  /// Stop speaking immediately
  func stopSpeaking() {
    synthesizer.stopSpeaking(at: .immediate)
    isSpeaking = false
  }

  /// List all available voices (for debugging)
  func listAvailableVoices() {
    let voices = AVSpeechSynthesisVoice.speechVoices()
    print("📢 Available TTS Voices:")
    for voice in voices {
      if voice.language.starts(with: "en") {
        print("  - \(voice.name) (\(voice.language)) - Gender: \(voice.gender.rawValue)")
      }
    }
  }
}

// MARK: - AVSpeechSynthesizerDelegate
extension SpeechController: AVSpeechSynthesizerDelegate {
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    print("🎤 Started speaking: \(utterance.speechString)")
    isSpeaking = true
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    print("✅ Finished speaking")
    DispatchQueue.main.async {
      self.isSpeaking = false
      // Clear quote after 2 seconds
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        self.currentQuote = ""
      }
    }
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    DispatchQueue.main.async {
      self.isSpeaking = false
    }
  }
}
