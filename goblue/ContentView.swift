//
//  ContentView.swift
//  goblue
//
//  Created by Joshua Riley on 10/02/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var isLoading = true
    @State private var splashOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.5
    @State private var pulseAnimation: Bool = false
    
    var body: some View {
        Group {
            if isLoading {
                SplashScreenView(opacity: splashOpacity, logoScale: logoScale, pulseAnimation: pulseAnimation)
            } else if isLoggedIn {
                MainTabView()
                    .transition(.opacity.combined(with: .scale))
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.8), value: isLoading)
        .animation(.easeInOut(duration: 0.6), value: isLoggedIn)
        .onAppear {
            startSplashAnimation()
            checkAuthStatus()
        }
    }
    
    private func startSplashAnimation() {
        withAnimation(.easeOut(duration: 0.8)) {
            splashOpacity = 1
            logoScale = 1
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
    
    private func checkAuthStatus() {
        Task {
            // Check if user is logged in when view appears
            if let session = try? SupabaseManager.shared.supabase.auth.session {
                isLoggedIn = session.accessToken != nil
            }
            
            // Beautiful splash screen delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Beautiful Splash Screen
struct SplashScreenView: View {
    let opacity: Double
    let logoScale: CGFloat
    let pulseAnimation: Bool
    
    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient.goBlueGradient
                .ignoresSafeArea()
            
            // Floating particles effect
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 4...12))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        .linear(duration: Double.random(in: 3...8))
                        .repeatForever(autoreverses: false),
                        value: pulseAnimation
                    )
            }
            
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Logo with beautiful animations
                Image("logo-p")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280)
                    .scaleEffect(logoScale)
                    .opacity(opacity)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                
                // Loading indicator
                VStack(spacing: DesignSystem.Spacing.md) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text("Loading your messages...")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(opacity * 0.8)
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        TabView {
            ContactsView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Contacts")
                }
            
            FormsView()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Forms")
                }
            
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .tint(.goBlue)
        .background(Color.goBG)
    }
}

#Preview {
    ContentView()
}
