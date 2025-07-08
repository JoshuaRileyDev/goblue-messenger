//
//  LoginView.swift
//  goblue
//
//  Created by Joshua Riley on 11/02/2025.
//

import SwiftUI
import Supabase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccessMessage = false
    @State private var successMessage = ""
    @State private var animateContent = false
    
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Beautiful animated background
                LinearGradient.goBlueGradient
                    .ignoresSafeArea()
                
                // Floating circles animation
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: CGFloat.random(in: 100...200))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .animation(
                            .linear(duration: Double.random(in: 15...25))
                            .repeatForever(autoreverses: false),
                            value: animateContent
                        )
                }
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xxl) {
                        Spacer(minLength: 60)
                        
                        // Logo and welcome section
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            Image("logo-l")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 220)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                .scaleEffect(animateContent ? 1 : 0.8)
                                .opacity(animateContent ? 1 : 0)
                            
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                Text("Welcome Back")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Sign in to continue your messaging journey")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        }
                        
                        // Login form in glass card
                        GlassCard(cornerRadius: DesignSystem.CornerRadius.xl) {
                            VStack(spacing: DesignSystem.Spacing.lg) {
                                VStack(spacing: DesignSystem.Spacing.md) {
                                    ModernTextField(
                                        "Email",
                                        placeholder: "Enter your email",
                                        text: $email,
                                        keyboardType: .emailAddress,
                                        textContentType: .emailAddress
                                    )
                                    
                                    ModernTextField(
                                        "Password",
                                        placeholder: "Enter your password",
                                        text: $password,
                                        isSecure: true,
                                        textContentType: .password
                                    )
                                }
                                
                                VStack(spacing: DesignSystem.Spacing.md) {
                                    ModernButton(
                                        "Sign In",
                                        icon: isLoading ? nil : "arrow.right",
                                        style: .primary,
                                        size: .large
                                    ) {
                                        signIn()
                                    }
                                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                                    .overlay(
                                        // Loading overlay
                                        isLoading ? 
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.9)
                                        : nil
                                    )
                                    
                                    ModernButton(
                                        "Forgot Password?",
                                        style: .ghost,
                                        size: .medium
                                    ) {
                                        resetPassword()
                                    }
                                    .disabled(email.isEmpty)
                                }
                            }
                            .padding(DesignSystem.Spacing.xl)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 50)
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateContent = true
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccessMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(successMessage)
        }
    }
    
    private func signIn() {
        isLoading = true
        Task {
            do {
                try await SupabaseManager.shared.supabase.auth.signIn(
                    email: email,
                    password: password
                )
                
                await MainActor.run {
                    isLoading = false
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isLoggedIn = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func resetPassword() {
        Task {
            do {
                try await SupabaseManager.shared.supabase.auth.resetPasswordForEmail(email)
                await MainActor.run {
                    successMessage = "Password reset link sent to your email"
                    showSuccessMessage = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}
