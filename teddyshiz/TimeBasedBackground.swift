import SwiftUI
import Foundation
import Combine

/// Time periods throughout the day
enum TimeOfDay {
    case dawn      // 5am - 7am
    case morning   // 7am - 11am
    case midday    // 11am - 3pm
    case afternoon // 3pm - 6pm
    case dusk      // 6pm - 8pm
    case evening   // 8pm - 10pm
    case night     // 10pm - 5am

    /// Get current time of day based on device time
    static var current: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<7:   return .dawn
        case 7..<11:  return .morning
        case 11..<15: return .midday
        case 15..<18: return .afternoon
        case 18..<20: return .dusk
        case 20..<22: return .evening
        default:      return .night
        }
    }

    /// Beautiful gradient colors for each time period
    var gradientColors: [Color] {
        switch self {
        case .dawn:
            // Soft pink to warm orange sunrise
            return [
                Color(red: 1.0, green: 0.75, blue: 0.8),   // Soft pink
                Color(red: 1.0, green: 0.85, blue: 0.7),   // Peach
                Color(red: 1.0, green: 0.9, blue: 0.8)     // Light cream
            ]

        case .morning:
            // Fresh, energetic morning blues
            return [
                Color(red: 0.85, green: 0.95, blue: 1.0),  // Sky blue
                Color(red: 0.95, green: 0.97, blue: 1.0),  // Very light blue
                Color(red: 1.0, green: 0.98, blue: 0.95)   // Warm white
            ]

        case .midday:
            // Bright, clear day
            return [
                Color(red: 0.7, green: 0.85, blue: 1.0),   // Clear blue
                Color(red: 0.85, green: 0.92, blue: 1.0),  // Light blue
                Color(red: 0.95, green: 0.97, blue: 1.0)   // Almost white
            ]

        case .afternoon:
            // Warm, golden afternoon
            return [
                Color(red: 1.0, green: 0.95, blue: 0.85),  // Golden
                Color(red: 1.0, green: 0.92, blue: 0.8),   // Warm amber
                Color(red: 0.95, green: 0.88, blue: 0.75)  // Soft tan
            ]

        case .dusk:
            // Beautiful sunset oranges and purples
            return [
                Color(red: 1.0, green: 0.6, blue: 0.4),    // Orange
                Color(red: 1.0, green: 0.7, blue: 0.6),    // Coral
                Color(red: 0.9, green: 0.7, blue: 0.85)    // Lavender
            ]

        case .evening:
            // Peaceful twilight purples
            return [
                Color(red: 0.5, green: 0.4, blue: 0.7),    // Deep purple
                Color(red: 0.65, green: 0.5, blue: 0.75),  // Purple
                Color(red: 0.75, green: 0.6, blue: 0.8)    // Light purple
            ]

        case .night:
            // Deep, calming night blues
            return [
                Color(red: 0.1, green: 0.15, blue: 0.3),   // Deep navy
                Color(red: 0.15, green: 0.2, blue: 0.4),   // Dark blue
                Color(red: 0.25, green: 0.3, blue: 0.5)    // Blue
            ]
        }
    }

    /// Gradient start and end points for visual variety
    var gradientPoints: (start: UnitPoint, end: UnitPoint) {
        switch self {
        case .dawn:
            return (.bottomLeading, .topTrailing)
        case .morning:
            return (.top, .bottom)
        case .midday:
            return (.topLeading, .bottomTrailing)
        case .afternoon:
            return (.leading, .trailing)
        case .dusk:
            return (.bottomTrailing, .topLeading)
        case .evening:
            return (.bottom, .top)
        case .night:
            return (.topTrailing, .bottomLeading)
        }
    }

    /// Name for debugging/display
    var displayName: String {
        switch self {
        case .dawn: return "Dawn"
        case .morning: return "Morning"
        case .midday: return "Midday"
        case .afternoon: return "Afternoon"
        case .dusk: return "Dusk"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }

    /// Emoji for fun display
    var emoji: String {
        switch self {
        case .dawn: return "🌅"
        case .morning: return "☀️"
        case .midday: return "🌤️"
        case .afternoon: return "🌞"
        case .dusk: return "🌆"
        case .evening: return "🌙"
        case .night: return "✨"
        }
    }

    /// Get next time period in sequence
    var next: TimeOfDay {
        switch self {
        case .dawn: return .morning
        case .morning: return .midday
        case .midday: return .afternoon
        case .afternoon: return .dusk
        case .dusk: return .evening
        case .evening: return .night
        case .night: return .dawn
        }
    }
}

/// Controller for manually changing time of day
@MainActor
class TimeController: ObservableObject {
    @Published var manualTimeOverride: TimeOfDay? = nil

    func cycleToNextTime() {
        let current = manualTimeOverride ?? TimeOfDay.current
        manualTimeOverride = current.next
        print("🎨 Manually cycled time: \(current.emoji) → \(current.next.emoji)")
    }

    func resetToActualTime() {
        manualTimeOverride = nil
        print("🎨 Reset to actual time: \(TimeOfDay.current.emoji)")
    }
}

/// Animated background view that changes based on time of day
struct TimeBasedBackgroundView: View {
    @EnvironmentObject var timeController: TimeController
    @State private var currentTime: TimeOfDay = .current

    // Timer to check for time changes
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: currentTime.gradientColors),
            startPoint: currentTime.gradientPoints.start,
            endPoint: currentTime.gradientPoints.end
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 2.0), value: currentTime)
        .onReceive(timer) { _ in
            // Use manual override if set, otherwise use actual time
            if timeController.manualTimeOverride == nil {
                let newTime = TimeOfDay.current
                if newTime != currentTime {
                    print("🎨 Time changed: \(currentTime.emoji) → \(newTime.emoji)")
                    currentTime = newTime
                }
            }
        }
        .onChange(of: timeController.manualTimeOverride) { _, newOverride in
            if let override = newOverride {
                currentTime = override
            } else {
                currentTime = TimeOfDay.current
            }
        }
        .onAppear {
            print("🎨 Background loaded: \(currentTime.emoji) \(currentTime.displayName)")
        }
    }
}

// Make TimeOfDay Equatable for comparison
extension TimeOfDay: Equatable {}

#Preview {
    ZStack {
        TimeBasedBackgroundView()

        VStack {
            Spacer()

            // Debug info
            VStack(spacing: 8) {
                Text("\(TimeOfDay.current.emoji) \(TimeOfDay.current.displayName)")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Time: \(Calendar.current.component(.hour, from: Date())):00")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .padding()
        }
    }
}
