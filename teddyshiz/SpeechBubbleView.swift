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
        // iMessage-style bubble with tail - centered and full width
        VStack {
          Text(displayedText)
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(.black.opacity(0.9))
            .multilineTextAlignment(.center)
            .lineLimit(4)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
              MessageBubbleShape()
                .fill(Color.white)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 2)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 80)
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

// iMessage-style bubble shape with integrated tail on bottom-left
struct MessageBubbleShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let cornerRadius: CGFloat = 20
    let tailWidth: CGFloat = 20
    let tailHeight: CGFloat = 10
    let tailPosition: CGFloat = 50  // Distance from left edge

    // Start at top-left, moving clockwise
    path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))

    // Top edge
    path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))

    // Top-right corner
    path.addArc(
      center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
      radius: cornerRadius,
      startAngle: Angle(degrees: -90),
      endAngle: Angle(degrees: 0),
      clockwise: false
    )

    // Right edge
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))

    // Bottom-right corner
    path.addArc(
      center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
      radius: cornerRadius,
      startAngle: Angle(degrees: 0),
      endAngle: Angle(degrees: 90),
      clockwise: false
    )

    // Bottom edge to tail start
    path.addLine(to: CGPoint(x: rect.minX + tailPosition + tailWidth, y: rect.maxY))

    // Tail - curves down and to the left
    path.addQuadCurve(
      to: CGPoint(x: rect.minX + tailPosition - 5, y: rect.maxY + tailHeight),
      control: CGPoint(x: rect.minX + tailPosition + tailWidth - 5, y: rect.maxY + 5)
    )

    // Tail back up
    path.addQuadCurve(
      to: CGPoint(x: rect.minX + tailPosition, y: rect.maxY),
      control: CGPoint(x: rect.minX + tailPosition - 8, y: rect.maxY + tailHeight - 2)
    )

    // Continue bottom edge to left
    path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))

    // Bottom-left corner
    path.addArc(
      center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
      radius: cornerRadius,
      startAngle: Angle(degrees: 90),
      endAngle: Angle(degrees: 180),
      clockwise: false
    )

    // Left edge
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))

    // Top-left corner
    path.addArc(
      center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
      radius: cornerRadius,
      startAngle: Angle(degrees: 180),
      endAngle: Angle(degrees: 270),
      clockwise: false
    )

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

    SpeechBubbleView(text: "Your message goes here")
  }
}
