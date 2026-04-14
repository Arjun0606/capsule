import SwiftUI

struct LockCeremonyView: View {
    let itemCount: Int
    let durationDays: Int
    let isLocking: Bool
    let onComplete: () -> Void

    @State private var phase: CeremonyPhase = .encrypting
    @State private var lockRotation: Double = 0
    @State private var lockScale: CGFloat = 1.0
    @State private var showSealed = false
    @State private var showButton = false
    @State private var particlesVisible = false

    enum CeremonyPhase {
        case encrypting
        case sealing
        case sealed
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                // Background particles on seal
                if particlesVisible {
                    ParticleEmitter(color: Theme.accent, count: 30)
                        .frame(width: 300, height: 300)
                }

                // Lock animation
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Theme.accent.opacity(showSealed ? 0.15 : 0.05))
                            .frame(width: 180, height: 180)
                            .scaleEffect(showSealed ? 1.0 : 0.8)

                        Image(systemName: showSealed ? "lock.fill" : "lock.open.fill")
                            .font(.system(size: 56, weight: .medium))
                            .foregroundStyle(Theme.accent)
                            .rotationEffect(.degrees(lockRotation))
                            .scaleEffect(lockScale)
                    }

                    // Status text
                    VStack(spacing: 8) {
                        switch phase {
                        case .encrypting:
                            Text("Encrypting \(itemCount) memories...")
                                .font(Theme.headline)
                                .foregroundStyle(Theme.textPrimary)

                            ProgressView()
                                .tint(Theme.accent)

                        case .sealing:
                            Text("Sealing your vault...")
                                .font(Theme.headline)
                                .foregroundStyle(Theme.textPrimary)

                        case .sealed:
                            Text("Vault sealed.")
                                .font(Theme.title)
                                .foregroundStyle(Theme.accent)

                            Text("\(itemCount) memories locked for \(durationDays) days.")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textSecondary)

                            Text("You just did something brave.")
                                .font(Theme.callout)
                                .foregroundStyle(Theme.textSecondary)
                                .padding(.top, 8)
                        }
                    }
                }
            }

            Spacer()

            if showButton {
                CapsuleButton(title: "Begin healing", icon: "heart.fill", action: onComplete)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 16)
            }
        }
        .padding(.horizontal, Theme.padding)
        .onAppear { startCeremony() }
    }

    private func startCeremony() {
        // Phase 1: Encrypting (show spinner)
        phase = .encrypting

        // Phase 2: Sealing (lock animation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(Theme.spring) {
                phase = .sealing
                lockRotation = -15
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    lockRotation = 0
                    showSealed = true
                }
                HapticsService.lock()
            }

            // Phase 3: Sealed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(Theme.spring) {
                    phase = .sealed
                    lockScale = 1.1
                    particlesVisible = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(Theme.spring) { lockScale = 1.0 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(Theme.gentle) { showButton = true }
                }
            }
        }
    }
}
