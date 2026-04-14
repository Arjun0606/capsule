import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showButton = false
    @State private var lockScale: CGFloat = 0.3
    @State private var lockOpacity: Double = 0
    @State private var breathing = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Animated lock icon
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.08))
                    .frame(width: 160, height: 160)
                    .scaleEffect(breathing ? 1.1 : 0.95)
                    .animation(Theme.breathe, value: breathing)

                Circle()
                    .fill(Theme.accent.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .scaleEffect(breathing ? 1.05 : 0.98)
                    .animation(Theme.breathe.delay(0.3), value: breathing)

                Image(systemName: "lock.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(Theme.accent)
                    .scaleEffect(lockScale)
                    .opacity(lockOpacity)
            }
            .onAppear {
                breathing = true
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                    lockScale = 1.0
                    lockOpacity = 1.0
                }
            }

            Spacer().frame(height: 48)

            // Title
            VStack(spacing: 16) {
                Text("Some things\nneed time.")
                    .font(Theme.largeTitle)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 20)

                Text("Lock away what hurts.\nHeal without willpower.")
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 15)
            }
            .onAppear {
                withAnimation(Theme.gentle.delay(0.6)) { showTitle = true }
                withAnimation(Theme.gentle.delay(1.0)) { showSubtitle = true }
                withAnimation(Theme.gentle.delay(1.4)) { showButton = true }
            }

            Spacer()

            // CTA
            VStack(spacing: 12) {
                CapsuleButton(title: "Get started", action: onContinue)
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : 20)

                Text("Your data never leaves your phone.")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .opacity(showButton ? 0.7 : 0)
            }
            .padding(.bottom, 16)
        }
        .padding(.horizontal, Theme.padding)
    }
}
