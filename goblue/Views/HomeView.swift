//
//  HomeView.swift
//  goblue
//
//  Created by Joshua Riley on 18/02/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var lastUsed: Int = 0
    @State private var animateCards = false
    @State private var showWelcome = false
    
    private let setupSteps = [
        SetupStep(
            number: 1,
            title: "Download iOS Shortcuts",
            description: "Get the Shortcuts app from App Store",
            url: "https://apps.apple.com/us/app/shortcuts/id915249334",
            icon: "arrow.down.circle.fill",
            color: .goBlue
        ),
        SetupStep(
            number: 2,
            title: "Install GoBlue Messenger",
            description: "Add the messaging shortcut to your device",
            url: "https://www.icloud.com/shortcuts/5bf6565e60a341a6ac41723d9aa25e07",
            icon: "plus.circle.fill",
            color: .goAccent
        ),
        SetupStep(
            number: 3,
            title: "Install GoBlue Webhook",
            description: "Add the webhook integration shortcut",
            url: "https://www.icloud.com/shortcuts/d1890618b76f400d9b828b444237b9e6",
            icon: "link.circle.fill",
            color: .goInfo
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                    // Welcome header
                    welcomeHeader
                    
                    // Status card
                    statusCard
                    
                    // Setup steps or recent activity
                    if needsSetup {
                        setupStepsSection
                        actionButtonsSection
                    } else {
                        recentActivitySection
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .background(Color.goBG)
            .navigationTitle("GoBlue")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ViewMessagesView()
                    } label: {
                        IconButton("message.fill", size: 20, color: .goBlue) {}
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showWelcome = true
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateCards = true
            }
        }
    }
    
    private var needsSetup: Bool {
        let currentTime = Int(Date().timeIntervalSince1970)
        let timeDiff = currentTime - (lastUsed / 1000)
        return timeDiff > 3
    }
    
    private var welcomeHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image("leadPhoto")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
                .opacity(showWelcome ? 1 : 0)
                .scaleEffect(showWelcome ? 1 : 0.8)
            
            Text("Welcome to GoBlue")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.goTextPrimary)
                .opacity(showWelcome ? 1 : 0)
                .offset(y: showWelcome ? 0 : 20)
        }
    }
    
    private var statusCard: some View {
        GlassCard {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: needsSetup ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(needsSetup ? .goWarning : .goSuccess)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(needsSetup ? "Setup Required" : "Ready to Go!")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.goTextPrimary)
                    
                    Text(needsSetup ? "Complete setup to start messaging" : "Your shortcuts are configured")
                        .font(.caption)
                        .foregroundColor(.goTextSecondary)
                }
                
                Spacer()
                
                StatusBadge(
                    text: needsSetup ? "Setup" : "Active",
                    status: needsSetup ? .warning : .success
                )
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 30)
    }
    
    private var setupStepsSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Setup Steps")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.goTextPrimary)
                Spacer()
            }
            
            ForEach(Array(setupSteps.enumerated()), id: \.element.number) { index, step in
                SetupStepCard(step: step)
                    .opacity(animateCards ? 1 : 0)
                    .offset(y: animateCards ? 0 : 50)
                    .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: animateCards)
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ModernButton(
                "Run GoBlue Shortcut",
                icon: "sparkles",
                style: .primary,
                size: .large
            ) {
                runShortcut()
            }
            
            ModernButton(
                "Test Integration",
                icon: "play.circle",
                style: .secondary,
                size: .medium
            ) {
                testIntegration()
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.5), value: animateCards)
    }
    
    private var recentActivitySection: some View {
        GlassCard {
            VStack(spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.goSuccess)
                    Text("Recent Activity")
                        .font(.headline)
                        .foregroundColor(.goTextPrimary)
                    Spacer()
                }
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Shortcuts are active and ready")
                        .font(.body)
                        .foregroundColor(.goTextSecondary)
                    
                    Text("Last used: Recently")
                        .font(.caption)
                        .foregroundColor(.goSuccess)
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
    
    private func runShortcut() {
        if let url = URL(string: "shortcuts://run-shortcut?name=GoBlue%20Messenger") {
            UIApplication.shared.open(url)
        }
    }
    
    private func testIntegration() {
        // Add test integration logic here
        print("Testing integration...")
    }
}

// MARK: - Setup Step Model
struct SetupStep {
    let number: Int
    let title: String
    let description: String
    let url: String
    let icon: String
    let color: Color
}

// MARK: - Setup Step Card Component
struct SetupStepCard: View {
    let step: SetupStep
    
    var body: some View {
        ModernListRow(action: {
            openURL(step.url)
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Step number circle
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [step.color, step.color.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 40, height: 40)
                    
                    Text("\(step.number)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(step.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.goTextPrimary)
                    
                    Text(step.description)
                        .font(.caption)
                        .foregroundColor(.goTextSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: step.icon)
                    .font(.title2)
                    .foregroundColor(step.color)
            }
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    HomeView()
}
