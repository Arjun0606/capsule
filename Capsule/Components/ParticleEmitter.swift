import SwiftUI

// MARK: - Floating particles for ceremonies

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: Double
}

struct ParticleEmitter: View {
    let color: Color
    let count: Int
    @State private var particles: [Particle] = []
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    Circle()
                        .fill(color)
                        .frame(width: p.size, height: p.size)
                        .position(x: p.x, y: isAnimating ? -p.size : p.y)
                        .opacity(isAnimating ? 0 : p.opacity)
                        .blur(radius: p.size > 6 ? 1 : 0)
                }
            }
            .onAppear {
                particles = (0..<count).map { _ in
                    Particle(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height),
                        size: CGFloat.random(in: 2...8),
                        opacity: Double.random(in: 0.2...0.7),
                        speed: Double.random(in: 2...5)
                    )
                }
                withAnimation(.easeOut(duration: 4)) {
                    isAnimating = true
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Fire particles for incinerate

struct FireParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
}

struct IncinerateEmitter: View {
    @State private var particles: [FireParticle] = []
    @State private var isActive = false

    let colors: [Color] = [
        .orange, .red, Color(red: 1.0, green: 0.3, blue: 0.0), .yellow
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    Circle()
                        .fill(colors.randomElement() ?? .orange)
                        .frame(width: p.size, height: p.size)
                        .position(x: p.x, y: isActive ? p.y - 200 : p.y)
                        .opacity(isActive ? 0 : 0.9)
                        .blur(radius: 2)
                }
            }
            .onAppear {
                particles = (0..<40).map { _ in
                    FireParticle(
                        x: CGFloat.random(in: geo.size.width * 0.2...geo.size.width * 0.8),
                        y: CGFloat.random(in: geo.size.height * 0.3...geo.size.height * 0.7),
                        size: CGFloat.random(in: 4...14)
                    )
                }
                withAnimation(.easeOut(duration: 3)) {
                    isActive = true
                }
            }
        }
        .allowsHitTesting(false)
    }
}
