# Teddyshiz 🧸

An interactive 3D teddy bear companion app for iOS built with SwiftUI and RealityKit. Pet, hug, and interact with your virtual teddy bear featuring haptic feedback, spatial audio, and cute anime quotes!

## Features

### 🎮 Interactive Gestures
- **Single Tap Belly** - Heartbeat effect with haptic feedback
- **Triple Tap** - Teddy speaks random anime quotes with iOS TTS (cute baby voice)
- **Drag** - Rotate teddy around its Y-axis (stays centered)
- **Swipe Up** - Teddy gets excited and bounces
- **Shake Device** - Toggle lullaby music on/off
- **2-Finger Drag** - Pet the teddy (continuous purring sound)

### 🎨 Visual Effects
- Real-time breathing animation with dynamic scaling
- Glow/flare effects for different moods
- Liquid glass speech bubble UI at bottom
- Smooth Y-axis rotation while staying centered
- Multiple mood states (idle, petted, listening, hugged, excited)

### 🔊 Audio System
- **Background Sounds**: Breathing ambient audio
- **Purring**: Continuous sound during petting
- **Lullaby**: Toggleable peaceful music (shake to start/stop)
- **Haptic Feedback**: Rich haptic patterns for all interactions
- **Text-to-Speech**: 19 anime quotes spoken with baby voice

### 💬 Anime Quotes
Includes quotes from popular anime series:
- My Hero Academia
- Demon Slayer
- Attack on Titan
- One Piece
- Naruto
- Spy x Family
- Jujutsu Kaisen
- Haikyuu
- Fullmetal Alchemist
- And more!

## Technical Details

### Built With
- **SwiftUI** - Modern UI framework
- **RealityKit** - 3D rendering and AR
- **AVFoundation** - Audio playback and TTS
- **CoreHaptics** - Advanced haptic feedback
- **CoreMotion** - Device shake detection

### Architecture
- `TeddyRealityView.swift` - Main 3D view with gesture handling
- `TeddyAppState.swift` - State management for moods and interactions
- `SpeechController.swift` - Text-to-speech system
- `AudioController.swift` - Audio playback management
- `HapticController.swift` - Haptic feedback patterns
- `MotionController.swift` - Device motion detection
- `SpeechBubbleView.swift` - Quote display UI

### Key Features
- **Fixed Position System**: Teddy stays centered, only rotates
- **Y-axis Only Rotation**: Natural spinning without tilting
- **Non-overlapping Gestures**: Carefully tuned gesture priorities
- **Baby Voice TTS**: Prioritizes Zoe (Australian) or Samantha (US) voices
- **Glassmorphism UI**: Modern liquid glass speech bubble design

## Requirements

- iOS 18.0+
- Xcode 16.0+
- iPhone with A12 Bionic or later (for optimal performance)
- Device with haptic engine (iPhone 8 or later)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/teddyshiz.git
cd teddyshiz
```

2. Open the project in Xcode:
```bash
open teddyshiz.xcodeproj
```

3. **Download required assets** (models and large audio):
   - See [MODELS.md](MODELS.md) for 3D model setup (~133 MB)
   - See [AUDIO.md](AUDIO.md) for lullaby.mp3 setup (~10 MB)

4. Select your target device (iOS Simulator or physical iPhone)

5. Build and run (⌘R)

## Required Assets

### 3D Models
The 3D teddy bear models are **not included** in the repository due to their large size. Download instructions: [MODELS.md](MODELS.md)

### Audio Files
- ✅ `breathing.wav` (256 KB) - Included in repo
- ✅ `purring.wav` (124 KB) - Included in repo
- 📥 `lullaby.mp3` (9.6 MB) - Download separately (see [AUDIO.md](AUDIO.md))

The app will work without models/lullaby but with limited functionality (cube fallback, no lullaby music).

## Interaction Guide

### Basic Interactions
1. **Wake up teddy** - Tap the screen to see the heartbeat
2. **Make teddy talk** - Triple tap anywhere to hear a random anime quote
3. **Rotate teddy** - Drag horizontally to spin teddy around
4. **Pet teddy** - Use two fingers to drag and hear purring
5. **Play lullaby** - Shake your device to start/stop the lullaby

### Mood States
- **Idle** - Default peaceful state with slow breathing
- **Petted** - Happy state with continuous purring
- **Listening** - Active state with flares while preparing quote
- **Hugged** - Comforted state with slower breathing
- **Excited** - Energetic state with faster breathing

## Development

### Project Structure
```
teddyshiz/
├── teddyshiz/
│   ├── Assets.xcassets/      # App icons and assets
│   ├── Models/                # 3D model files (.usdz)
│   ├── *.swift                # Swift source files
│   ├── *.wav                  # Audio files (breathing, purring)
│   └── *.mp3                  # Music file (lullaby)
├── teddyshiz.xcodeproj/       # Xcode project
├── .gitignore                 # Git ignore rules
├── README.md                  # This file
└── TWEET_INTERACTIONS.md      # Social media interaction guide
```

### Adding New Quotes
Edit `SpeechController.swift` and add quotes to the `animeQuotes` array:
```swift
private let animeQuotes = [
    "Your new quote here! - Series Name"
]
```

### Adjusting Voice Settings
Modify voice parameters in `SpeechController.swift`:
```swift
utterance.rate = 0.48           // Speech speed (0.0-1.0)
utterance.pitchMultiplier = 1.6  // Voice pitch (higher = more baby-like)
utterance.volume = 0.9           // Volume (0.0-1.0)
```

## Known Issues

- Teddy model uses a simple brown box on iOS Simulator (3D models work on device)
- Some gestures may feel sensitive - thresholds can be adjusted in `TeddyRealityView.swift`

## Future Enhancements

- [ ] Custom 3D teddy bear model with fur shading
- [ ] More interaction types (tickle, squeeze)
- [ ] Customizable teddy appearance
- [ ] Save favorite quotes
- [ ] More audio variations
- [ ] Sleep mode with snoring sounds

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Credits

Created with SwiftUI, RealityKit, and lots of ❤️

Anime quotes from various popular series for entertainment purposes only.

---

**Note**: This is an interactive entertainment app. Best experienced on a physical iPhone with haptic feedback enabled!
