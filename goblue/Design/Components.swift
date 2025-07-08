//
//  Components.swift
//  goblue
//
//  Created by Joshua Riley on 10/02/2025.
//

import SwiftUI

// MARK: - Glass Card Component
struct GlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let showBorder: Bool
    
    init(cornerRadius: CGFloat = DesignSystem.CornerRadius.lg, showBorder: Bool = true, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.linearGradient(colors: [Color.goGlass, Color.goGlass.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.goGlassBorder, lineWidth: showBorder ? 1 : 0)
                    )
                    .shadow(color: DesignSystem.Shadow.light, radius: 8, x: 0, y: 4)
            )
    }
}

// MARK: - Modern Button Component
struct ModernButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let size: ButtonSize
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, ghost, destructive
    }
    
    enum ButtonSize {
        case small, medium, large
        
        var height: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 48
            case .large: return 56
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return .caption
            case .medium: return .body
            case .large: return .headline
            }
        }
    }
    
    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, size: ButtonSize = .medium, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(size.fontSize)
                }
                Text(title)
                    .font(size.fontSize)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(backgroundForStyle)
            .foregroundColor(foregroundForStyle)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundForStyle: some View {
        Group {
            switch style {
            case .primary:
                LinearGradient.goBlueGradient
            case .secondary:
                Color.goCardBG
            case .ghost:
                Color.clear
            case .destructive:
                Color.goError
            }
        }
    }
    
    private var foregroundForStyle: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return .goBlue
        case .ghost:
            return .goTextPrimary
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary, .destructive:
            return DesignSystem.Shadow.medium
        case .secondary:
            return DesignSystem.Shadow.light
        case .ghost:
            return .clear
        }
    }
    
    private var shadowRadius: CGFloat {
        style == .ghost ? 0 : 4
    }
    
    private var shadowOffset: CGFloat {
        style == .ghost ? 0 : 2
    }
}

// MARK: - Modern Text Field
struct ModernTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    
    init(_ title: String, placeholder: String = "", text: Binding<String>, isSecure: Bool = false, keyboardType: UIKeyboardType = .default, textContentType: UITextContentType? = nil) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.textContentType = textContentType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            if !title.isEmpty {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.goTextSecondary)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(Color.goCardBG)
                    .stroke(Color.goGlassBorder, lineWidth: 1)
                    .frame(height: 48)
                
                HStack {
                    if text.isEmpty && !placeholder.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.goTextTertiary)
                    }
                    
                    if isSecure {
                        SecureField("", text: $text)
                            .textFieldStyle(PlainTextFieldStyle())
                            .keyboardType(keyboardType)
                            .textContentType(textContentType)
                    } else {
                        TextField("", text: $text)
                            .textFieldStyle(PlainTextFieldStyle())
                            .keyboardType(keyboardType)
                            .textContentType(textContentType)
                            .autocapitalization(.none)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .foregroundColor(.goTextPrimary)
            }
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let text: String
    let status: Status
    
    enum Status {
        case success, warning, error, info, neutral
        
        var color: Color {
            switch self {
            case .success: return .goSuccess
            case .warning: return .goWarning
            case .error: return .goError
            case .info: return .goInfo
            case .neutral: return .goTextSecondary
            }
        }
    }
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                Capsule()
                    .fill(status.color.opacity(0.15))
            )
            .foregroundColor(status.color)
    }
}

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let size: CGFloat
    let color: Color
    let action: () -> Void
    
    init(_ icon: String, size: CGFloat = 24, color: Color = .goBlue, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(color)
                .frame(width: size + 16, height: size + 16)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modern List Row
struct ModernListRow<Content: View>: View {
    let content: Content
    let showChevron: Bool
    let action: (() -> Void)?
    
    init(showChevron: Bool = true, action: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack {
                content
                
                Spacer()
                
                if showChevron && action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.goTextTertiary)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(Color.goCardBG)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(color: DesignSystem.Shadow.light, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}