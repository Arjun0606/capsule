import SwiftUI
import SwiftData

struct UnlockCeremonyView: View {
    let vault: Vault
    let vaultService: VaultService

    @Environment(\.modelContext) private var context
    @State private var showContent = false
    @State private var showActions = false
    @State private var showIncinerate = false
    @State private var showExtendSheet = false
    @State private var isRestoring = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if showIncinerate {
                IncinerateView(vault: vault, vaultService: vaultService)
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    Spacer()

                    // Unlocked icon
                    VStack(spacing: 32) {
                        ZStack {
                            Circle()
                                .fill(Theme.accent.opacity(0.12))
                                .frame(width: 160, height: 160)

                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 52, weight: .medium))
                                .foregroundStyle(Theme.accent)
                        }

                        VStack(spacing: 12) {
                            Text("\(vault.durationDays) days.")
                                .font(Theme.largeTitle)
                                .foregroundStyle(Theme.textPrimary)

                            Text("You made it.")
                                .font(Theme.title2)
                                .foregroundStyle(Theme.accent)
                        }

                        // Stats recap
                        VStack(spacing: 8) {
                            StatLine(icon: "photo.fill", text: "\(vault.itemCount) memories locked")
                            StatLine(icon: "hand.raised.fill", text: "\(vault.urgesResisted) urges resisted")
                            StatLine(icon: "pencil.line", text: "\(vault.journal.count) letters written")
                            if let first = vault.moods.sorted(by: { $0.date < $1.date }).first,
                               let last = vault.moods.sorted(by: { $0.date < $1.date }).last {
                                StatLine(icon: "chart.line.uptrend.xyaxis",
                                         text: "\(first.mood.emoji) \u{2192} \(last.mood.emoji)")
                            }
                        }
                        .padding(.top, 8)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 30)

                    Spacer()

                    // Three choices
                    if showActions {
                        VStack(spacing: 12) {
                            CapsuleButton(title: "Restore everything", icon: "photo.badge.plus", style: .secondary) {
                                Task { await restoreAll() }
                            }

                            CapsuleButton(title: "Incinerate", icon: "flame.fill", style: .destructive) {
                                withAnimation(Theme.spring) { showIncinerate = true }
                            }

                            CapsuleButton(title: "Not yet — extend timer", icon: "lock.fill", style: .ghost) {
                                showExtendSheet = true
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, Theme.padding)
            }

            if isRestoring {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView().tint(Theme.accent)
                        Text("Restoring to camera roll...")
                            .font(Theme.callout)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .card()
                }
            }
        }
        .sheet(isPresented: $showExtendSheet) {
            ExtendTimerSheet(vault: vault)
        }
        .onAppear {
            HapticsService.unlock()
            withAnimation(Theme.gentle.delay(0.3)) { showContent = true }
            withAnimation(Theme.gentle.delay(1.2)) { showActions = true }
        }
    }

    private func restoreAll() async {
        isRestoring = true
        let photoService = PhotoService()

        for item in vault.items where item.itemType == .photo || item.itemType == .screenshot {
            do {
                let data = try vaultService.decrypt(fileName: item.encryptedFileName)
                _ = try await photoService.restoreImage(data: data)
                vaultService.deleteEncryptedFile(item.encryptedFileName)
                if let thumb = item.thumbnailFileName {
                    vaultService.deleteEncryptedFile(thumb)
                }
            } catch {
                continue
            }
        }

        vault.vaultState = .restored
        try? context.save()
        isRestoring = false
    }
}

// MARK: - Stat Line

struct StatLine: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Theme.accent)
                .frame(width: 20)
            Text(text)
                .font(Theme.callout)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}

// MARK: - Extend Timer Sheet

struct ExtendTimerSheet: View {
    let vault: Vault
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var extraDays = 30

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("How much more time?")
                    .font(Theme.title2)
                    .foregroundStyle(Theme.textPrimary)

                Picker("Days", selection: $extraDays) {
                    Text("30 days").tag(30)
                    Text("60 days").tag(60)
                    Text("90 days").tag(90)
                }
                .pickerStyle(.wheel)
                .frame(height: 150)

                CapsuleButton(title: "Extend vault", icon: "lock.fill") {
                    vault.unlockDate = Calendar.current.date(byAdding: .day, value: extraDays, to: .now) ?? .now
                    vault.durationDays += extraDays
                    vault.vaultState = .locked
                    try? context.save()
                    dismiss()
                }

                Spacer()
            }
            .padding(.horizontal, Theme.padding)
            .padding(.top, 32)
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
