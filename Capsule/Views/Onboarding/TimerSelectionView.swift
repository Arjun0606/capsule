import SwiftUI

struct TimerSelectionView: View {
    @Binding var durationDays: Int
    let onLock: () -> Void

    @State private var showContent = false

    private let options: [(days: Int, label: String, sublabel: String)] = [
        (30, "30 days", "The acute phase"),
        (60, "60 days", "Most chosen"),
        (90, "90 days", "Full reset"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            VStack(spacing: 12) {
                Text("How long do\nyou need?")
                    .font(Theme.title)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("This lock is real. You will not be able\nto see these until the timer ends.")
                    .font(Theme.callout)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)

            Spacer().frame(height: 48)

            // Timer options
            VStack(spacing: 12) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    Button {
                        HapticsService.light()
                        withAnimation(Theme.springSnap) {
                            durationDays = option.days
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.label)
                                    .font(Theme.headline)
                                    .foregroundStyle(
                                        durationDays == option.days ? .black : Theme.textPrimary
                                    )

                                Text(option.sublabel)
                                    .font(Theme.caption)
                                    .foregroundStyle(
                                        durationDays == option.days
                                            ? .black.opacity(0.6)
                                            : Theme.textSecondary
                                    )
                            }

                            Spacer()

                            if durationDays == option.days {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.black)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(Theme.cardPadding)
                        .background(
                            durationDays == option.days ? Theme.accent : Theme.surface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Theme.smallRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(Theme.spring.delay(Double(index) * 0.1 + 0.2), value: showContent)
                }
            }

            Spacer()

            // Lock button
            VStack(spacing: 12) {
                CapsuleButton(title: "Lock it. I'm ready.", icon: "lock.fill", action: onLock)

                Text("Nothing is deleted permanently.\nWhen the timer ends, you choose.")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(showContent ? 1 : 0)

            Spacer().frame(height: 16)
        }
        .padding(.horizontal, Theme.padding)
        .onAppear {
            withAnimation(Theme.gentle.delay(0.1)) { showContent = true }
        }
    }
}
