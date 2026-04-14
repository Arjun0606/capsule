import SwiftUI
import SwiftData

struct SettingsView: View {
    let vault: Vault
    let vaultService: VaultService

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var showIncinerateConfirm = false

    var body: some View {
        NavigationStack {
            List {
                // Vault info
                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(vault.vaultState.rawValue.capitalized)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    HStack {
                        Text("Items locked")
                        Spacer()
                        Text("\(vault.itemCount)")
                            .foregroundStyle(Theme.textSecondary)
                    }
                    HStack {
                        Text("Unlock date")
                        Spacer()
                        Text(vault.unlockDate, style: .date)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    HStack {
                        Text("Days remaining")
                        Spacer()
                        Text("\(vault.daysRemaining)")
                            .foregroundStyle(Theme.textSecondary)
                    }
                } header: {
                    Text("Vault")
                }

                // Notifications
                Section {
                    HStack {
                        Text("Daily check-in")
                        Spacer()
                        Text("8:00 PM")
                            .foregroundStyle(Theme.textSecondary)
                    }
                } header: {
                    Text("Notifications")
                }

                // Danger zone
                Section {
                    // Incinerate early
                    Button {
                        showIncinerateConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(Theme.destructive)
                            Text("Incinerate vault now")
                                .foregroundStyle(Theme.destructive)
                        }
                    }
                } header: {
                    Text("Moved on?")
                } footer: {
                    Text("If you've healed and don't need to wait for the timer, you can incinerate everything now. This is permanent.")
                }

                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Link(destination: URL(string: "https://github.com/Arjun0606/capsule")!) {
                        HStack {
                            Text("Source code")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .fullScreenCover(isPresented: $showIncinerateConfirm) {
                IncinerateView(vault: vault, vaultService: vaultService)
            }
        }
    }
}
