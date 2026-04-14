import SwiftUI

struct ProgressRing: View {
    let progress: Double
    var size: CGFloat = 220
    var lineWidth: CGFloat = 10

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Theme.surfaceElevated, lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [Theme.accent.opacity(0.6), Theme.accent],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * animatedProgress)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Glow dot at end
            Circle()
                .fill(Theme.accent)
                .frame(width: lineWidth + 4, height: lineWidth + 4)
                .shadow(color: Theme.accent.opacity(0.6), radius: 8)
                .offset(y: -size / 2)
                .rotationEffect(.degrees(360 * animatedProgress - 90))
                .opacity(animatedProgress > 0.01 ? 1 : 0)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(Theme.spring) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, new in
            withAnimation(Theme.spring) {
                animatedProgress = new
            }
        }
    }
}

// MARK: - Small inline progress bar

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.surfaceElevated)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.accent)
                    .frame(width: geo.size.width * min(1, progress))
            }
        }
        .frame(height: 6)
    }
}
