import SwiftUI
import SwiftData

struct IncinerateView: View {
    let vault: Vault
    let vaultService: VaultService

    @Environment(\.modelContext) private var context
    @State private var typedText = ""
    @State private var phase: IncineratePhase = .confirm
    @State private var showParticles = false

    private let confirmWord = "INCINERATE"

    enum IncineratePhase {
        case confirm
        case burning
        case done
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if showParticles {
                IncinerateEmitter()
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                Spacer()

                switch phase {
                case .confirm:
                    confirmView

                case .burning:
                    burningView

                case .done:
                    doneView
                }

                Spacer()
            }
            .padding(.horizontal, Theme.padding)
        }
    }

    // MARK: - Confirm Phase

    private var confirmView: some View {
        VStack(spacing: 32) {
            Image(systemName: "flame.fill")
                .font(.system(size: 52))
                .foregroundStyle(Theme.destructive)

            VStack(spacing: 12) {
                Text("Incinerate everything?")
                    .font(Theme.title)
                    .foregroundStyle(Theme.textPrimary)

                Text("\(vault.itemCount) memories will be\npermanently destroyed.")
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)

                Text("This cannot be undone.")
                    .font(Theme.callout)
                    .foregroundStyle(Theme.destructive)
                    .padding(.top, 4)
            }

            VStack(spacing: 12) {
                Text("Type INCINERATE to confirm")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textSecondary)

                TextField("", text: $typedText)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
                    .padding()
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.smallRadius, style: .continuous))
            }

            if typedText == confirmWord {
                CapsuleButton(title: "Incinerate", icon: "flame.fill", style: .destructive) {
                    startIncineration()
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Burning Phase

    private var burningView: some View {
        VStack(spacing: 24) {
            Image(systemName: "flame.fill")
                .font(.system(size: 64))
                .foregroundStyle(.orange)
                .symbolEffect(.pulse, options: .repeating)

            Text("Incinerating...")
                .font(Theme.title2)
                .foregroundStyle(Theme.textPrimary)

            Text("\(vault.itemCount) memories")
                .font(Theme.callout)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: - Done Phase

    private var doneView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.success)

            Text("Gone.")
                .font(Theme.largeTitle)
                .foregroundStyle(Theme.textPrimary)

            Text("You let go.\nThat took real courage.")
                .font(Theme.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Actions

    private func startIncineration() {
        HapticsService.incinerate()
        withAnimation(Theme.spring) {
            phase = .burning
            showParticles = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            vaultService.incinerateVault(vault, context: context)
            withAnimation(Theme.spring) {
                phase = .done
                showParticles = false
            }
        }
    }
}
