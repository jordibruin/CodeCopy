import SwiftUI

public struct SmallButton: View {
    
    public enum IconPlacement {
        case leading
        case trailing
    }
    
    
    public var action : () -> ()
    let title: LocalizedStringKey
    var icon = ""
    var iconPlacement: IconPlacement
    let helpText: LocalizedStringKey
    let tintColor: Color
    let symbolColor: Color?
    let keyboardshortcutString: String?
    
    public init(
        action: @escaping () -> (),
        title: LocalizedStringKey,
        icon: String = "",
        iconPlacement: IconPlacement = .leading,
        helpText: LocalizedStringKey,
        tintColor: Color,
        symbolColor: Color? = nil,
        keyboardshortcutString: String? = nil
    ) {
        self.action = action
        self.title = title
        self.icon = icon
        self.iconPlacement = iconPlacement
        self.helpText = helpText
        self.tintColor = tintColor
        self.symbolColor = symbolColor
        self.keyboardshortcutString = keyboardshortcutString
    }
    
    @State private var isHovering : Bool = false
    
    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 3) {
                if icon.isEmpty == false && iconPlacement == .leading && keyboardshortcutString == nil {
                    Image(systemName: icon)
                        .foregroundColor(symbolColor ?? .primary)
                }
                
                Text(title)
                    .foregroundColor(tintColor)
                    .offset(y: -0.5)
                
                if icon.isEmpty == false && iconPlacement == .trailing {
                    Image(systemName: icon)
                        .foregroundColor(symbolColor ?? .primary)
                }
                
                if let keyboardshortcutString {
                    ZStack {
                        // Correct opacity
                        Color.primary.opacity(0.07)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .frame(width: 22, height: 22)
                        
                        Text(keyboardshortcutString)
                            .fontWeight(.medium)
                            .opacity(0.7)
                    }
                    .padding(.leading, 2)
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 6)
            .padding(.vertical, 6)
            .frame(minHeight: 32)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .font(.system(.headline, design: .rounded).weight(.semibold))
        .foregroundColor(isHovering ? .primary : .secondary)
        .background(isHovering ? tintColor.opacity(0.1) : tintColor.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .help(helpText)
        .onHover { hover in
            withAnimation(.easeIn(duration: 0.25)) {
                isHovering = hover
            }
        }
    }
}
