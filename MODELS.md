# 3D Model Files Setup

The 3D model files are not included in the repository due to their large size (133 MB total). You need to download them separately.

## Required Model Files

The app requires the following USDZ model files to be placed in the `teddyshiz/Models/` directory:

1. **teddy_highpoly.usdz** (127 MB)
   - High-poly teddy bear model
   - Main 3D asset for the app

2. **pink_teddy.usdz** (6 MB)
   - Alternative pink teddy model
   - Optional variant

## Download Options

### Option 1: Download from Link (Recommended)

**TODO**: Upload model files to a cloud storage and add download link here.

Example:
```
Download link: [Your Google Drive / Dropbox / OneDrive link]
```

### Option 2: Use Your Own USDZ Models

If you have your own teddy bear USDZ models, you can use them instead:

1. Place your `.usdz` files in `teddyshiz/Models/`
2. Update the model name in `TeddyRealityView.swift` if needed

## Installation Steps

1. Download the model files from the link above
2. Create the `Models` folder if it doesn't exist:
   ```bash
   mkdir -p teddyshiz/Models
   ```
3. Copy the downloaded `.usdz` files into `teddyshiz/Models/`
4. Your folder structure should look like:
   ```
   teddyshiz/
   └── teddyshiz/
       └── Models/
           ├── teddy_highpoly.usdz
           └── pink_teddy.usdz
   ```
5. Open the project in Xcode and add the models to the project:
   - Right-click `teddyshiz` folder in Xcode
   - Select "Add Files to 'teddyshiz'..."
   - Navigate to `Models` folder
   - Select both `.usdz` files
   - Check "Copy items if needed"
   - Click "Add"

## Fallback Behavior

If model files are not found, the app will display a simple brown cube as a fallback. This allows you to test the interactions without the actual 3D model.

## Finding USDZ Models

If you need to source your own models:

### Free Options:
- **Sketchfab** - https://sketchfab.com (filter by "Downloadable")
- **Apple's Reality Composer** - Create simple models
- **Blender** - Export as USDZ using plugins

### Paid Options:
- **TurboSquid** - https://www.turbosquid.com
- **CGTrader** - https://www.cgtrader.com

### Converting to USDZ:
If you have models in other formats (.obj, .fbx, .blend):

1. **Using Reality Converter (Mac only)**:
   - Download from Apple Developer site
   - Drag and drop your model
   - Export as USDZ

2. **Using Blender + Python script**:
   ```bash
   # Install USD Python
   pip install usd-core

   # Use provided script (if available)
   python convert_to_usdz.py your_model.obj
   ```

## Model Requirements

For best results, your USDZ model should:
- Be centered at origin (0, 0, 0)
- Face forward along positive Z-axis
- Have reasonable poly count (< 50K triangles for mobile)
- Include materials/textures
- Be scaled appropriately (teddy should be ~0.3 units tall)

## Troubleshooting

**Model not appearing?**
1. Check the console for error messages
2. Verify model is added to Xcode project
3. Ensure model is in Build Phases → Copy Bundle Resources
4. Try loading a simpler test model first

**Model too big/small?**
- Adjust the `baseScale` value in `TeddyRealityView.swift`:
  ```swift
  @State private var baseScale: Float = 0.15  // Adjust this value
  ```

**Model not centered?**
- Adjust the `fixedPosition` in `TeddyRealityView.swift`:
  ```swift
  private let fixedPosition: SIMD3<Float> = [0, -0.15, 0]  // Adjust Y value
  ```

## Need Help?

If you need help obtaining or converting model files, please open an issue on GitHub.

---

**Note**: The app works without models (shows a cube fallback), but the full experience requires the teddy bear USDZ files.
