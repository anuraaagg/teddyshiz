import SwiftUI

struct ContentView: View {
  @StateObject private var appState = TeddyAppState()
  @StateObject private var speechController = SpeechController.shared
  @StateObject private var timeController = TimeController()

  // Long press tracking for screen-wide time change
  @State private var longPressStartTime: Date?
  @State private var longPressLocation: CGPoint?
  @State private var longPressActive = false

  var body: some View {
    ZStack {
      // Time-based gradient background
      TimeBasedBackgroundView()
        .environmentObject(timeController)

      // Warm glowing belly - BEHIND the teddy
      VStack {
        Spacer()

        Circle()
          .fill(
            RadialGradient(
              gradient: Gradient(colors: [
                Color(red: 1.0, green: 0.85, blue: 0.3).opacity(0.4),  // Warmer, softer glow
                Color(red: 1.0, green: 0.7, blue: 0.2).opacity(0.2),
                Color.clear,
              ]),
              center: .center,
              startRadius: 10,
              endRadius: appState.isGlowFlares ? 120 : 60
            )
          )
          .frame(width: 300, height: 300)  // Larger glow
          .scaleEffect(
            appState.isBreathingActive
              ? (appState.isGlowFlares ? 1.8 : 1.0)  // Manual breathing control
              : (appState.isGlowFlares ? 1.8 : glowScale)  // Idle breathing or special effects
          )
          .opacity(
            appState.isBreathingActive
              ? (appState.isGlowFlares ? 1.0 : 0.5)  // Manual breathing control
              : (appState.isGlowFlares ? 1.0 : glowOpacity)  // Idle breathing or special effects
          )
          .blur(radius: 25)  // More blur for softer effect
          .blendMode(.normal)  // Normal blend for light background
          .animation(
            appState.isBreathingActive
              ? .easeInOut(duration: 1.5)  // Smooth breathing when manually controlled
              : (appState.isGlowFlares
                ? .spring(response: 0.3, dampingFraction: 0.6)
                : .easeInOut(duration: appState.breathingDuration / 2.0).repeatForever(
                  autoreverses: true)),
            value: appState.isGlowFlares
          )
          .animation(
            appState.isBreathingActive
              ? .linear(duration: 0)  // No idle animation when manually breathing
              : .easeInOut(duration: appState.breathingDuration / 2.0).repeatForever(
                autoreverses: true),
            value: glowScale
          )
          .offset(y: 0)  // Centered behind teddy

        Spacer()
          .frame(height: 100)
      }
      // Ignoring gestures on the glow so they pass through to RealityKit
      .allowsHitTesting(false)

      // 3D Teddy View - IN FRONT of the glow
      TeddyRealityView(appState: appState)
        .ignoresSafeArea()

      // Speech bubble overlay - shows when teddy speaks
      SpeechBubbleView(text: speechController.currentQuote)
        .allowsHitTesting(false)

      // Time picker - iOS style reaction picker
      if appState.showTimePicker {
        ZStack {
          // Dimmed background
          Color.black.opacity(0.3)
            .ignoresSafeArea()
            .onTapGesture {
              withAnimation {
                appState.showTimePicker = false
              }
            }

          // Reaction picker at tap location
          TimeReactionPickerView(
            isPresented: $appState.showTimePicker,
            tapLocation: appState.timePickerLocation
          ) { selectedTime in
            appState.selectTimeOfDay(selectedTime)
          }
        }
        .transition(.opacity)
        .zIndex(100)
      }

      // Time change toast notification - compact iOS style
      if appState.showTimeChangeReaction {
        VStack {
          // Compact toast at top
          HStack(spacing: 10) {
            Text(appState.timeChangeEmoji)
              .font(.system(size: 22))

            Text("Time changed")
              .font(.system(size: 15, weight: .medium, design: .serif))
              .foregroundColor(.primary.opacity(0.9))
          }
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .background(
            Capsule()
              .fill(.ultraThinMaterial)
              .overlay(
                Capsule()
                  .fill(
                    LinearGradient(
                      colors: [
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.1)
                      ],
                      startPoint: .top,
                      endPoint: .bottom
                    )
                  )
              )
              .overlay(
                Capsule()
                  .strokeBorder(
                    Color.white.opacity(0.3),
                    lineWidth: 1
                  )
              )
              .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
              .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 3)
          )
          .padding(.top, 60)
          .scaleEffect(appState.showTimeChangeReaction ? 1.0 : 0.8)
          .opacity(appState.showTimeChangeReaction ? 1.0 : 0)
          .animation(.spring(response: 0.4, dampingFraction: 0.7), value: appState.showTimeChangeReaction)

          Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .allowsHitTesting(false)
      }

      // Subtle vignette for light background
      RadialGradient(
        gradient: Gradient(colors: [
          Color.clear,
          Color.gray.opacity(0.15),  // Very subtle gray vignette
        ]),
        center: .center,
        startRadius: 300,
        endRadius: 550
      )
      .ignoresSafeArea()
      .allowsHitTesting(false)
    }
    // Screen-wide long press gesture for time change
    .simultaneousGesture(
      DragGesture(minimumDistance: 5)  // Small movement allowed (5pt)
        .onChanged { value in
          // Start long press tracking on first touch
          if longPressStartTime == nil {
            longPressStartTime = Date()
            longPressLocation = value.startLocation
            print("⏰ Touch started, tracking for long press...")
          }

          // Check if 2 seconds have passed and finger hasn't moved much
          if let startTime = longPressStartTime,
             let startLoc = longPressLocation,
             !longPressActive {

            let duration = Date().timeIntervalSince(startTime)
            let distance = hypot(value.location.x - startLoc.x, value.location.y - startLoc.y)

            // Only trigger if held still (< 15pt movement) for 2+ seconds
            if duration >= 2.0 && distance < 15 {
              longPressActive = true
              appState.startLongPress(at: startLoc)
              print("⏰ Long press triggered after \(duration)s")
            } else if duration > 2.0 && distance >= 15 {
              // Moved too much, cancel
              print("⏰ Cancelled - moved \(distance)pt")
              longPressStartTime = nil
              longPressLocation = nil
            }
          }
        }
        .onEnded { _ in
          // Reset state
          if !longPressActive && longPressStartTime != nil {
            print("⏰ Long press cancelled - touch ended too soon")
            appState.cancelLongPress()
          }
          if longPressActive {
            longPressActive = false
          }
          longPressStartTime = nil
          longPressLocation = nil
        }
    )
    .onAppear {
      startIdleAnimation()
      setupTimeChangeNotification()
    }
    // Force the app to always respond and be active
    .statusBar(hidden: true)
  }

  private func setupTimeChangeNotification() {
    NotificationCenter.default.addObserver(
      forName: .changeTimeOfDay,
      object: nil,
      queue: .main
    ) { [weak timeController] notification in
      Task { @MainActor in
        // Get the selected time from notification
        if let userInfo = notification.userInfo,
           let selectedTime = userInfo["time"] as? TimeOfDay {
          // Set manual time override
          timeController?.manualTimeOverride = selectedTime
        }
      }
    }
  }

  // Values for continuous breathing glow
  @State private var glowScale: CGFloat = 1.0
  @State private var glowOpacity: Double = 0.5

  private func startIdleAnimation() {
    // Since it repeats forever, we just set the target state
    withAnimation(
      .easeInOut(duration: appState.breathingDuration / 2.0).repeatForever(autoreverses: true)
    ) {
      glowScale = 1.45
      glowOpacity = 1.0
    }
  }
}

#Preview {
  ContentView()
}
