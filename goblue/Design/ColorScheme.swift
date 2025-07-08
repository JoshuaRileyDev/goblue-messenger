//
//  ColorScheme.swift
//  goblue
//
//  Created by Joshua Riley on 10/02/2025.
//

import SwiftUI

extension Color {
    // Primary Brand Colors
    static let goBlue = Color("GoBlue")
    static let goBlueLight = Color("GoBlueLight")
    static let goBlueDark = Color("GoBlueDark")
    
    // Accent Colors
    static let goAccent = Color("GoAccent")
    static let goAccentLight = Color("GoAccentLight")
    
    // Background Colors
    static let goBG = Color("GoBG")
    static let goCardBG = Color("GoCardBG")
    static let goSurfaceBG = Color("GoSurfaceBG")
    
    // Text Colors
    static let goTextPrimary = Color("GoTextPrimary")
    static let goTextSecondary = Color("GoTextSecondary")
    static let goTextTertiary = Color("GoTextTertiary")
    
    // Status Colors
    static let goSuccess = Color("GoSuccess")
    static let goWarning = Color("GoWarning")
    static let goError = Color("GoError")
    static let goInfo = Color("GoInfo")
    
    // Glass Effect
    static let goGlass = Color.white.opacity(0.15)
    static let goGlassBorder = Color.white.opacity(0.2)
}

// Beautiful Gradients
extension LinearGradient {
    static let goBlueGradient = LinearGradient(
        gradient: Gradient(colors: [Color.goBlue, Color.goBlueDark]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goAccentGradient = LinearGradient(
        gradient: Gradient(colors: [Color.goAccent, Color.goAccentLight]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let goBackgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.goBG, Color.goSurfaceBG]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let goGlassGradient = LinearGradient(
        gradient: Gradient(colors: [Color.goGlass, Color.goGlass.opacity(0.05)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// Design System Constants
struct DesignSystem {
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let circle: CGFloat = 50
    }
    
    struct Shadow {
        static let light = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.15)
        static let heavy = Color.black.opacity(0.25)
    }
}