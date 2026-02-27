# Audio Files Setup

This project uses three audio files. The small audio files (breathing and purring) are included in the repository, but the large lullaby file needs to be downloaded separately.

## Audio Files

### Included in Repository ✅

1. **breathing.wav** (256 KB)
   - Ambient breathing sound loop
   - Already included in the repo

2. **purring.wav** (124 KB)
   - Purring sound when petting teddy
   - Already included in the repo

### Download Separately 📥

3. **lullaby.mp3** (9.6 MB)
   - Peaceful lullaby music
   - Toggles on/off with shake gesture
   - **Download link**: [TODO: Add your download link here]

## Installation Steps

1. Download `lullaby.mp3` from the link above
2. Place it in the `teddyshiz/` folder (same level as other Swift files)
3. In Xcode, drag the file into the `teddyshiz` group
4. Make sure "Copy items if needed" is checked
5. Verify it appears in Build Phases → Copy Bundle Resources

Your folder structure should look like:
```
teddyshiz/
└── teddyshiz/
    ├── breathing.wav       ✅ (included)
    ├── purring.wav         ✅ (included)
    └── lullaby.mp3         📥 (download separately)
```

## Alternative: Use Your Own Lullaby

If you want to use your own lullaby music:

1. Find or create a peaceful lullaby MP3/WAV file
2. Name it `lullaby.mp3` (or update the filename in `AudioController.swift`)
3. Place it in `teddyshiz/` folder
4. Add it to Xcode project

### Recommended Lullaby Characteristics:
- **Duration**: 2-5 minutes (loops automatically)
- **Tempo**: Slow (60-80 BPM)
- **Volume**: Soft and peaceful
- **Format**: MP3 or WAV
- **Size**: Under 10 MB preferred

## Finding Royalty-Free Music

### Free Sources:
- **YouTube Audio Library** - https://studio.youtube.com/channel/UC/music
- **Free Music Archive** - https://freemusicarchive.org
- **Incompetech** - https://incompetech.com (Kevin MacLeod)
- **Bensound** - https://www.bensound.com
- **Purple Planet** - https://www.purple-planet.com

### Paid Sources:
- **Epidemic Sound** - https://www.epidemicsound.com
- **Artlist** - https://artlist.io
- **AudioJungle** - https://audiojungle.net

## Updating Audio in Code

If you use different filenames, update `AudioController.swift`:

```swift
// In AudioController.swift, update the URLs:
private func setupAudioPlayers() {
    // Change these if you use different filenames:
    if let breathingURL = Bundle.main.url(forResource: "breathing", withExtension: "wav") {
        breathingPlayer = try? AVAudioPlayer(contentsOf: breathingURL)
    }

    if let purringURL = Bundle.main.url(forResource: "purring", withExtension: "wav") {
        purringPlayer = try? AVAudioPlayer(contentsOf: purringURL)
    }

    if let lullabyURL = Bundle.main.url(forResource: "lullaby", withExtension: "mp3") {
        lullabyPlayer = try? AVAudioPlayer(contentsOf: lullabyURL)
    }
}
```

## App Behavior Without Lullaby

If the lullaby file is missing:
- Breathing and purring will still work
- Shake gesture will attempt to play lullaby but fail silently
- No crash or error message shown to user
- App remains functional for all other interactions

## Troubleshooting

**Audio not playing?**
1. Check that file is added to Xcode project
2. Verify file is in Build Phases → Copy Bundle Resources
3. Check console for error messages
4. Ensure correct filename and extension
5. Test on physical device (simulator has audio quirks)

**Volume too loud/soft?**
- Adjust volume in `AudioController.swift`:
  ```swift
  lullabyPlayer?.volume = 0.2  // 0.0 to 1.0
  breathingPlayer?.volume = 0.15
  purringPlayer?.volume = 0.4
  ```

**Wrong audio format?**
- Convert to MP3 or WAV using:
  - **Online**: https://cloudconvert.com
  - **Mac**: `afconvert input.mp3 -d LEI16@44100 -f WAVE output.wav`
  - **ffmpeg**: `ffmpeg -i input.mp3 output.wav`

## File Size Considerations

| File | Size | Included in Repo |
|------|------|------------------|
| breathing.wav | 256 KB | ✅ Yes |
| purring.wav | 124 KB | ✅ Yes |
| lullaby.mp3 | 9.6 MB | ❌ No (download separately) |
| **Total** | **~10 MB** | 380 KB in repo |

By keeping the lullaby separate, we keep the repository size minimal while still including the essential audio files.

## Need Help?

If you have trouble finding or adding audio files, please open an issue on GitHub.

---

**Note**: The app will work without the lullaby file, but the shake gesture won't play music.
