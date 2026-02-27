import RealityKit
import SwiftUI

struct TeddyRealityView: View {
  var appState: TeddyAppState
  @State private var teddyEntity: ModelEntity?

  // Scale animation tracking
  @State private var isBreathingIn = false
  @State private var breathingTimer: Timer?
  @State private var baseScale: Float = 0.15  // Store initial scale

  // Fixed position - NEVER changes, teddy only rotates in place
  private let fixedPosition: SIMD3<Float> = [0, -0.15, 0]

  // Rotation tracking for drag interaction - start with identity (no rotation)
  @State private var currentRotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0])
  @State private var lastRotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0])
  @State private var isDragging = false

  // Gesture tracking for multi-tap and complex interactions
  @State private var tapCount = 0
  @State private var lastTapTime = Date.distantPast
  @State private var longPressActive = false

  var body: some View {
    ZStack {
      RealityView { content in
        print("🎨 RealityView: Starting to create scene...")

        // Create anchor positioned in front of camera - FIXED position
        let anchor = AnchorEntity(.camera)
        anchor.position = [0, 0, -1.0]  // Fixed distance from camera, centered

        // Add lighting to the scene
        // Directional light from above-front
        let mainLight = DirectionalLight()
        mainLight.light.intensity = 3000
        mainLight.light.color = .white
        mainLight.orientation = simd_quatf(angle: -.pi / 3, axis: [1, 0, 0])
        mainLight.position = [0, 0.5, 0]
        anchor.addChild(mainLight)

        // Soft fill light from the side
        let fillLight = DirectionalLight()
        fillLight.light.intensity = 1500
        fillLight.light.color = .init(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0)
        fillLight.orientation = simd_quatf(angle: .pi / 4, axis: [0, 1, 0])
        anchor.addChild(fillLight)

        // Fallback for Simulator test - use a simple box
        let mesh = MeshResource.generateBox(size: 0.2)
        let material = SimpleMaterial(color: .brown, isMetallic: false)
        let fallbackEntity = ModelEntity(mesh: mesh, materials: [material])
        fallbackEntity.generateCollisionShapes(recursive: false)
        fallbackEntity.components.set(InputTargetComponent())
        fallbackEntity.name = "fallback"  // Tag it so we can find it later

        anchor.addChild(fallbackEntity)
        content.add(anchor)

        print("✅ RealityView: Fallback box added")

        DispatchQueue.main.async {
          self.teddyEntity = fallbackEntity
          self.baseScale = 1.0  // Fallback box uses scale 1.0
          self.startBreathingAnimation()
        }

        // Try to load the actual model asynchronously
        Task {
          do {
            print("📦 RealityView: Loading high-poly teddy model...")
            let entity = try await ModelEntity(named: "teddy_highpoly")
            print("✅ RealityView: Model loaded successfully!")

            // This model has only one teddy bear with built-in textures
            // No need to hide anything!

            // FIXED scale - keep teddy small and consistent
            entity.scale = [0.0015, 0.0015, 0.0015]  // Smaller, fixed scale
            entity.position = fixedPosition  // Center vertically - LOCKED position

            // Default orientation - teddy facing forward (no rotation needed)
            // The model should face the camera by default
            entity.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
            self.currentRotation = simd_quatf(angle: 0, axis: [0, 1, 0])
            self.lastRotation = simd_quatf(angle: 0, axis: [0, 1, 0])

            // Add collision component so it responds to gestures
            if entity.collision == nil {
              entity.generateCollisionShapes(recursive: true)
            }
            entity.components.set(InputTargetComponent())

            // Don't apply custom fur shader - this model has its own materials!
            // The high-poly model already has fabric textures and normal maps
            print("✅ Using built-in materials from high-poly model")

            // Replace the fallback (keep the lights!)
            if let fallback = anchor.children.first(where: { $0.name == "fallback" }) {
              anchor.removeChild(fallback)
            }
            anchor.addChild(entity)
            print("🎯 RealityView: Teddy model displayed!")

            await MainActor.run {
              self.teddyEntity = entity
              self.baseScale = 0.0015  // FIXED base scale - matches entity.scale above
              self.startBreathingAnimation()
            }
          } catch {
            print("❌ Failed to load teddy_highpoly.usdz: \(error), using fallback")
          }
        }
      }

      // Overlay tap/drag area for gestures (works better on simulator)
      Color.clear
        .contentShape(Rectangle())
        // Primary gesture: Drag for rotation (most common)
        .gesture(
          DragGesture(minimumDistance: 10)  // Increased threshold to avoid accidental drags
            .onChanged { value in
              guard let entity = teddyEntity else { return }

              // Check for swipe up gesture (before starting drag)
              if !isDragging && value.translation.height < -80 {
                print("⬆️ Swipe up - lift teddy!")
                appState.liftTeddy()
                isDragging = true
                return
              }

              if !isDragging {
                print("👋 Drag started - rotating")
                isDragging = true
              }

              // ONLY rotate around Y-axis (vertical/center axis) - keeps teddy upright
              let sensitivity: Float = 0.01
              let rotationY = simd_quatf(angle: Float(value.translation.width) * sensitivity, axis: [0, 1, 0])

              // Apply rotation ONLY around Y-axis from last position
              currentRotation = lastRotation * rotationY

              // Create a new transform that ONLY changes orientation
              // This ensures position and scale stay locked
              var transform = Transform()
              transform.rotation = currentRotation
              transform.translation = fixedPosition  // Force-lock position to constant
              transform.scale = [baseScale, baseScale, baseScale]  // Force-lock scale

              // Apply the transform all at once (relative to parent anchor)
              entity.transform = transform
            }
            .onEnded { _ in
              print("✋ Drag ended - keeping rotation")
              isDragging = false

              // Save current rotation as the new base (no spring-back)
              lastRotation = currentRotation
            }
        )
        // Secondary gesture: Tap with location (only triggers if drag doesn't happen)
        .highPriorityGesture(
          SpatialTapGesture()
            .onEnded { value in
              if !isDragging && !longPressActive {
                handleTap(at: value.location)
              }
            }
        )
    }
    // Tickle detection using pinch or fast drag wasn't explicitly provided by native RealityView drag
    // Easily adapted by measuring drag speed.
    .onAppear {
      MotionController.shared.startMonitoring(appState: appState)
    }
    .onDisappear {
      MotionController.shared.stopMonitoring()
    }
    .onChange(of: appState.mood) { _, _ in
      startBreathingAnimation()
    }
  }

  private func handleTap(at location: CGPoint) {
    let now = Date()
    let timeSinceLastTap = now.timeIntervalSince(lastTapTime)

    // Reset tap count if too much time has passed (> 0.5s)
    if timeSinceLastTap > 0.5 {
      tapCount = 0
    }

    tapCount += 1
    lastTapTime = now

    // Schedule a check after a short delay to determine final tap count
    Task {
      try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5s delay

      // Only process if this is still the latest tap
      if now == self.lastTapTime {
        // Check if tap is on upper portion of screen (head area) for single tap
        let isTopHalf = location.y < UIScreen.main.bounds.height * 0.4

        switch self.tapCount {
        case 1:
          if isTopHalf {
            print("👆 Single tap on head - start purring!")
            appState.tapHead()
            // Stop purring after 3 seconds
            Task {
              try? await Task.sleep(nanoseconds: 3_000_000_000)
              appState.stopPetting()
            }
          } else {
            print("👆 Single tap - heartbeat")
            appState.tapBelly()
          }
        case 2:
          print("👆👆 Double tap - breathing")
          appState.doubleTapBreathing()
        case 3:
          print("👆👆👆 Triple tap - quote!")
          appState.speakRandomQuote()
        default:
          // More than 3 taps
          print("👆👆👆+ Multiple taps - quote!")
          appState.speakRandomQuote()
        }
        self.tapCount = 0
      }
    }
  }

  private func startBreathingAnimation() {
    breathingTimer?.invalidate()

    let duration = appState.breathingDuration

    breathingTimer = Timer.scheduledTimer(withTimeInterval: duration / 2.0, repeats: true) { _ in
      guard let entity = self.teddyEntity else { return }
      self.isBreathingIn.toggle()

      // Breathing effect: scale up slightly (1.05x) when breathing in
      let breathingScale: Float = self.isBreathingIn ? 1.05 : 1.0
      let newScale = self.baseScale * breathingScale

      var transform = entity.transform
      transform.scale = [newScale, newScale, newScale]  // Scale uniformly in all directions
      // IMPORTANT: Keep position centered vertically - no drift
      transform.translation = fixedPosition

      entity.move(
        to: transform, relativeTo: entity.parent, duration: duration / 2.0,
        timingFunction: .easeInOut)
    }
  }


  private func applyPlushieMaterial(to entity: ModelEntity) {
    // Create a soft, plushie-like material
    var material = PhysicallyBasedMaterial()

    // Soft pink color for teddy bear
    material.baseColor = .init(tint: .init(red: 1.0, green: 0.75, blue: 0.82, alpha: 1.0))

    // High roughness for fuzzy/matte appearance (like fabric/fur)
    material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.92)

    // No metallic (plushies aren't shiny)
    material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 0.0)

    // Clearcoat for very subtle sheen on fur tips
    material.clearcoat = PhysicallyBasedMaterial.Clearcoat(floatLiteral: 0.08)
    material.clearcoatRoughness = PhysicallyBasedMaterial.ClearcoatRoughness(floatLiteral: 0.95)

    // Apply material to all mesh parts
    if let model = entity.model {
      entity.model?.materials = Array(repeating: material, count: model.mesh.expectedMaterialCount)
    }

    // Recursively apply to all child entities
    for child in entity.children {
      if let childModel = child as? ModelEntity {
        applyPlushieMaterial(to: childModel)
      }
    }
  }
}
