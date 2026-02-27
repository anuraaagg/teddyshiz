import SwiftUI

struct SpeechBubbleView: View {
  let text: String
  @State private var displayedText: String = ""
  @State private var isAnimating = false
  @State private var animationId: UUID = UUID()

  var body: some View {
    VStack {
      Spacer()  // Push to bottom

      if !text.isEmpty {
        // Chat bubble with tail and glass effect
        VStack(spacing: 0) {
          // Main bubble body with glass effect
          ZStack {
            // Glassmorphism background with blur
            BubbleShape()
              .fill(
                LinearGradient(
                  gradient: Gradient(colors: [
                    Color.white.opacity(0.4),
                    Color.white.opacity(0.3),
                  ]),
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .background(
                BubbleShape()
                  .fill(.ultraThinMaterial)
              )
              .overlay(
                BubbleShape()
                  .stroke(
                    LinearGradient(
                      gradient: Gradient(colors: [
                        Color.white.opacity(0.8),
                        Color.white.opacity(0.5),
                      ]),
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                  )
              )
              .shadow(color: Color.black.opacity(0.2), radius: 25, x: 0, y: 12)
              .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

            // Text content with typing animation
            Text(displayedText)
              .font(.system(size: 17, weight: .medium, design: .serif))
              .foregroundColor(.black.opacity(0.85))  // Dark text for contrast
              .multilineTextAlignment(.center)
              .lineLimit(5)
              .padding(.horizontal, 28)
              .padding(.vertical, 20)
          }
          .frame(maxWidth: .infinity)
          .frame(minHeight: 70, maxHeight: 150)

          // Tail pointing down to bottom-left
          HStack {
            TailShape()
              .fill(
                LinearGradient(
                  gradient: Gradient(colors: [
                    Color.white.opacity(0.35),
                    Color.white.opacity(0.25),
                  ]),
                  startPoint: .top,
                  endPoint: .bottom
                )
              )
              .background(
                TailShape()
                  .fill(.ultraThinMaterial)
              )
              .overlay(
                TailShape()
                  .stroke(
                    Color.white.opacity(0.6),
                    lineWidth: 1.5
                  )
              )
              .frame(width: 28, height: 14)
              .offset(y: -2)  // Better overlap with bubble
              .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
              .padding(.leading, 40)  // Position to left

            Spacer()
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 50)  // Position from bottom with safe area
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: text)
        .onAppear {
          // Set initial text when view appears
          if !text.isEmpty && displayedText.isEmpty {
            displayedText = text
          }
        }
        .onChange(of: text) { _, newText in
          if !newText.isEmpty {
            // Generate new animation ID to cancel previous animation
            animationId = UUID()
            animateTyping()
          } else {
            // Clear displayed text when text becomes empty
            displayedText = ""
          }
        }
      }
    }
  }

  private func animateTyping() {
    guard !text.isEmpty else { return }

    // Show text immediately for better UX
    displayedText = text
    isAnimating = false
  }
}

// Custom shape for rounded bubble body
struct BubbleShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let cornerRadius: CGFloat = 24

    path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))

    return path
  }
}

// Custom shape for chat bubble tail pointing down
struct TailShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()

    // Triangle tail pointing downward
    path.move(to: CGPoint(x: rect.midX - rect.width / 2, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.midX + rect.width / 2, y: rect.minY))
    path.closeSubpath()

    return path
  }
}

#Preview {
  ZStack {
    // Sample background
    LinearGradient(
      gradient: Gradient(colors: [
        Color(red: 0.95, green: 0.94, blue: 0.96),
        Color(red: 0.98, green: 0.97, blue: 0.96),
      ]),
      startPoint: .top,
      endPoint: .bottom
    )
    .ignoresSafeArea()

    SpeechBubbleView(text: "Believe in yourself! I believe in you!")
  }
}
