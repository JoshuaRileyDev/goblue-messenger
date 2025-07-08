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
    
    var body: some View {
        Group {
            if isLoading {
                ZStack {
                    Color.blue.opacity(0.1)
                        .ignoresSafeArea()
                    
                    Image("logo-p").resizable().aspectRatio(contentMode: .fit).frame(width: 250)
                }
            } else if isLoggedIn {
                TabView {
                    ContactsView()
                        .tabItem {
                            Image(systemName: "person.2.fill")
                            Text("Contacts")
                        }
//                    GroupsView()
//                        .tabItem {
//                            Image(systemName: "rectangle.3.group.fill")
//                            Text("Groups")
//                        }
                    FormsView()
                        .tabItem {
                            Image(systemName: "doc.fill")
                            Text("Forms")
                        }
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                }
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            Task {
                // Check if user is logged in when view appears
                if let session = try? SupabaseManager.shared.supabase.auth.session {
                    isLoggedIn = session.accessToken != nil
                }
                
                // Simulate splash screen delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
