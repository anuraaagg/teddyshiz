import SwiftUI

/// iOS-style reaction picker for selecting time of day
struct TimeReactionPickerView: View {
    @Binding var isPresented: Bool
    let tapLocation: CGPoint
    let onTimeSelected: (TimeOfDay) -> Void

    // All available times of day with their SF Symbol icons
    private let allTimes: [(time: TimeOfDay, icon: String)] = [
        (.dawn, "sunrise.fill"),
        (.morning, "sun.max.fill"),
        (.midday, "sun.and.horizon.fill"),
        (.afternoon, "sun.min.fill"),
        (.dusk, "sunset.fill"),
        (.evening, "moon.stars.fill"),
        (.night, "moon.fill")
    ]

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        VStack(spacing: 0) {
            // Premium picker bubble with tail
            VStack(spacing: 0) {
                // Main bubble body
                HStack(spacing: 14) {
                    ForEach(allTimes, id: \.time) { item in
                        Button(action: {
                            selectTime(item.time)
                        }) {
                            Image(systemName: item.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color.primary.opacity(0.9),
                                            Color.primary.opacity(0.7)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(PremiumButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.6),
                                            Color.white.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )

                // Tail pointing down to tap location
                PickerTailShape()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        PickerTailShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .frame(width: 24, height: 12)
                    .offset(y: -1)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .position(x: tapLocation.x, y: tapLocation.y - 60)  // Position above tap
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    private func selectTime(_ time: TimeOfDay) {
        // Animate out
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.9
            opacity = 0
        }

        // Call handler and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onTimeSelected(time)
            isPresented = false
        }
    }
}

/// Premium button style with subtle scale and highlight
struct PremiumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .brightness(configuration.isPressed ? 0.1 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Tail shape for picker bubble style pointer
struct PickerTailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start from top-left
        path.move(to: CGPoint(x: 0, y: 0))

        // Line to top-right
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))

        // Curve down to bottom center (the point)
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.midY)
        )

        // Curve back up to top-left
        path.addQuadCurve(
            to: CGPoint(x: 0, y: 0),
            control: CGPoint(x: 0, y: rect.midY)
        )

        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()

        TimeReactionPickerView(
            isPresented: .constant(true),
            tapLocation: CGPoint(x: 200, y: 400)
        ) { time in
            print("Selected: \(time.displayName)")
        }
    }
}
