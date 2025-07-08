//
//  SettingsView.swift
//  goblue
//
//  Created by Joshua Riley on 10/02/2025.
//

import SwiftUI

struct KeyboardDoneButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                }
            }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil,
                                      from: nil,
                                      for: nil)
    }
}

extension View {
    func addKeyboardDoneButton() -> some View {
        modifier(KeyboardDoneButton())
    }
}

struct SettingsView: View {
    
    @State private var apiKey = "YOUR-API-KEY-HERE"
    @State private var showCopiedAlert = false
    
    @AppStorage("leadPhoto") var leadPhoto = ""
    @AppStorage("groupName") var groupName = ""
    
    var body: some View {
        NavigationView {
            Form {
//                Section(header: Text("API settings")) {
//                    HStack {
//                        Text("API Key").padding(.trailing, 10)
//                        SecureField("API Key", text: $apiKey)
//                            .textContentType(.password)
//                        
//                        Button(action: {
//                            UIPasteboard.general.string = apiKey
//                            showCopiedAlert = true
//                            
//                            // Hide the alert after 2 seconds
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                showCopiedAlert = false
//                            }
//                        }) {
//                            Image(systemName: "doc.on.doc")
//                                .foregroundColor(.blue)
//                        }
//                    }
//                    .alert("Copied!", isPresented: $showCopiedAlert) {
//                        Button("OK", role: .cancel) { }
//                    }
//                }
                Section(header: Text("Contact Settings")) {
                    HStack{
                        Text("Group Name")
                        Spacer()
                        TextField(text: $groupName) {
                            EmptyView()
                        }.frame(width: 100)
                            .addKeyboardDoneButton()
                        
                    }
                    ImagePickerButton(label: "Set Lead Photo", image: $leadPhoto, defaultImage: "leadPhoto")
                }
                Section() {
                    Button(action: {
                        Task {
                            do {
                                try await SupabaseManager.shared.logout()
                            } catch {
                                print("Error logging out: \(error)")
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                            Spacer()
                        }
                    }
                }
                
            }.navigationTitle("Settings").onAppear {
                Task {
                    do {
                        apiKey = try await SupabaseManager.shared.getAPIKey()
                    } catch {
                        print("Error getting API key: \(error)")
                    }
                }
            }
        }
    }
}
