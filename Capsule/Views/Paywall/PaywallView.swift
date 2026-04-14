import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 12)

                Spacer().frame(height: 20)

                VStack(spacing: 8) {
                    Text("Full Vault")
                        .font(Theme.largeTitle)
                        .foregroundStyle(Theme.accent)

                    Text("Everything you need to heal.")
                        .font(Theme.callout)
                        .foregroundStyle(Theme.textSecondary)
                }
                .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 32)

                // Features
                VStack(alignment: .leading, spacing: 18) {
                    FeatureRow(icon: "infinity", title: "Unlimited vault items", subtitle: "Lock away everything, not just 10")
                    FeatureRow(icon: "pencil.line", title: "Unsent letters", subtitle: "Write what you need to say")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Recovery graph", subtitle: "Watch yourself get better over time")
                    FeatureRow(icon: "hand.raised.fill", title: "Urge history", subtitle: "See your urges decline week by week")
                    FeatureRow(icon: "brain.head.profile", title: "Science-backed insights", subtitle: "Real research at every milestone")
                    FeatureRow(icon: "lock.fill", title: "Multiple vaults", subtitle: "Different people, different timers")
                }
                .padding(.horizontal, Theme.padding)
                .opacity(showContent ? 1 : 0)

                Spacer()

                // Pricing
                VStack(spacing: 12) {
                    CapsuleButton(title: "$6.99 / month", action: {
                        // StoreKit purchase flow
                    })

                    Button {
                        // StoreKit annual purchase
                    } label: {
                        VStack(spacing: 2) {
                            Text("$39.99 / year")
                                .font(Theme.callout)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Save 52%")
                                .font(Theme.caption)
                                .foregroundStyle(Theme.accent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.smallRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button("Restore purchases") {}
                        .font(Theme.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.horizontal, Theme.padding)
                .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 20)
            }
        }
        .onAppear {
            withAnimation(Theme.gentle.delay(0.2)) { showContent = true }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}
