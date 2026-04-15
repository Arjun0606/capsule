import SwiftUI
import SwiftData

struct UnsentLetterView: View {
    let vault: Vault

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var letterText = ""
    @FocusState private var isFocused: Bool

    private let prompts = [
        "Say what you need to say.",
        "Write about your deepest thoughts and feelings.",
        "What do you wish they understood?",
        "What do you wish you had said?",
        "What are you most angry about?",
        "What do you miss the most?",
        "What did this relationship teach you?",
    ]

    @State private var currentPrompt: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Prompt
                    VStack(spacing: 8) {
                        Text(currentPrompt)
                            .font(Theme.callout)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)

                        Text("This will never be sent.\nIt's locked in your vault.")
                            .font(Theme.caption)
                            .foregroundStyle(Theme.textSecondary.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, Theme.padding)

                    // Text editor
                    TextEditor(text: $letterText)
                        .font(Theme.body)
                        .foregroundStyle(Theme.textPrimary)
                        .scrollContentBackground(.hidden)
                        .focused($isFocused)
                        .padding(.horizontal, Theme.padding)
                        .padding(.top, 16)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveLetter() }
                        .foregroundStyle(Theme.accent)
                        .disabled(letterText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItem(placement: .principal) {
                    Text("Unsent Letter")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                }
            }
            .onAppear {
                currentPrompt = prompts.randomElement() ?? prompts[0]
                isFocused = true
            }
        }
    }

    private func saveLetter() {
        let trimmed = letterText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let entry = JournalEntry(body: trimmed, prompt: currentPrompt)
        entry.vault = vault
        context.insert(entry)
        try? context.save()
        HapticsService.light()
        dismiss()
    }
}
