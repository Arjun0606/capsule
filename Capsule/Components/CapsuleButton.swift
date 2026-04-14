import SwiftUI

struct CapsuleButton: View {
    let title: String
    var icon: String? = nil
    var style: ButtonStyle = .primary
    let action: () -> Void

    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case ghost
    }

    var body: some View {
        Button(action: {
            HapticsService.light()
            action()
        }) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(Theme.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.smallRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:     Theme.accent
        case .secondary:   Theme.surfaceElevated
        case .destructive: Theme.destructive
        case .ghost:       .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:     .black
        case .secondary:   Theme.textPrimary
        case .destructive: .white
        case .ghost:       Theme.textSecondary
        }
    }
}
