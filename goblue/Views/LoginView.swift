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
    
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    Image("logo-l").resizable().aspectRatio(contentMode: .fit).frame(width: 200).padding(.top, 30).padding(.bottom, 10)
                    
                    VStack(spacing: 20) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10).background(.white).cornerRadius(10)
                            if email.isEmpty{
                                Text("Enter email")
                                    .foregroundColor(.black)
                                    .padding()
                            }
                            TextField("", text: $email)
                                .textFieldStyle(.plain)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding()
                                .cornerRadius(10)
                                .foregroundStyle(.black)
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10).background(.white).cornerRadius(10)
                            if password.isEmpty  {
                                Text("Enter password")
                                    .foregroundColor(.black)
                                    .padding()
                            }
                            SecureField("", text: $password)
                                .textFieldStyle(.plain)
                                .textContentType(.password)
                                .padding()
                                .cornerRadius(10)
                                .foregroundStyle(.black)
                        }
                        
                        Button {
                            isLoading = true
                            Task {
                                do {
                                    try await SupabaseManager.shared.supabase.auth.signIn(
                                        email: email,
                                        password: password
                                    )
                                    isLoading = false
                                    isLoggedIn = true
                                } catch {
                                    isLoading = false
                                    errorMessage = error.localizedDescription
                                    showError = true
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                                
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Sign In")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                            }
                            .frame(height: 50)
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                        
                        Button("Forgot Password?") {
                            Task {
                                do {
                                    try await SupabaseManager.shared.supabase.auth.resetPasswordForEmail(email)
                                    // Show success message
                                } catch {
                                    errorMessage = error.localizedDescription
                                    showError = true
                                }
                            }
                        }
                        .foregroundColor(.blue)
                        .disabled(email.isEmpty)
                    }
                    .padding(.horizontal, 25)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}
