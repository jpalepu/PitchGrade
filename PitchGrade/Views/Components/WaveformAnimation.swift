import SwiftUI

struct WaveformAnimation: View {
    @State private var isAnimating = false
    let numberOfBars = 8
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<numberOfBars, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.8),
                                Color.blue.opacity(0.4)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.2))
                            .blur(radius: 2)
                    )
                    .scaleEffect(y: isAnimating ? 0.3 : 1)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
        }
        .frame(width: 100, height: 100)
        .drawingGroup() // For better performance
        .overlay {
            // Glassy overlay effect
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.2),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 3)
                .opacity(0.5)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WaveformAnimation()
    }
} 