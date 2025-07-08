//
//  HomeView.swift
//  goblue
//
//  Created by Joshua Riley on 18/02/2025.
//

import SwiftUI

struct HomeView: View {
    
    @State var lastUsed: Int = 0
    

    func getLastUsedStatus() -> some View {
        let currentTime = Int(Date().timeIntervalSince1970)
        let timeDiff = currentTime - (lastUsed/1000)
        
        return VStack {
            if timeDiff > 3 {
                VStack(spacing: 20) {
                    Text("Setup Required")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .opacity(timeDiff > 3 ? 1 : 0)
                        .animation(.easeIn(duration: 0.3).delay(0.1), value: timeDiff > 3)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Text("1")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(.blue))
                            
                            Text("Download iOS Shortcuts")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                if let url = URL(string: "https://apps.apple.com/us/app/shortcuts/id915249334") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .opacity(timeDiff > 3 ? 1 : 0)
                        .animation(.easeIn(duration: 0.3).delay(0.2), value: timeDiff > 3)
                        
                        HStack(spacing: 12) {
                            Text("2")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(.blue))
                            
                            Text("Install GoBlue Messenger shortcut")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                // Replace with actual shortcut URL
                                if let url = URL(string: "https://www.icloud.com/shortcuts/5bf6565e60a341a6ac41723d9aa25e07") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .opacity(timeDiff > 3 ? 1 : 0)
                        .animation(.easeIn(duration: 0.3).delay(0.3), value: timeDiff > 3)
                        HStack(spacing: 12) {
                            Text("3")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(.blue))
                            
                            Text("Install GoBlue Webhook shortcut")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                // Replace with actual shortcut URL
                                if let url = URL(string: "https://www.icloud.com/shortcuts/d1890618b76f400d9b828b444237b9e6") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .opacity(timeDiff > 3 ? 1 : 0)
                        .animation(.easeIn(duration: 0.3).delay(0.3), value: timeDiff > 3)
                        HStack(spacing: 12) {
                            Text("4")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(.blue))
                            
                            Text("Run shortcut")
                                .font(.headline)
                            
                            Spacer()
                        }
                        .opacity(timeDiff > 3 ? 1 : 0)
                        .animation(.easeIn(duration: 0.3).delay(0.4), value: timeDiff > 3)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .opacity(timeDiff > 3 ? 1 : 0)
                            .animation(.easeIn(duration: 0.3), value: timeDiff > 3)
                    )
                    
                    Button(action: {
                        if let url = URL(string: "shortcuts://run-shortcut?name=GoBlue%20Messenger") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Run Shortcut")
                            Image(systemName: "sparkles")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .padding(.horizontal)
                    .opacity(timeDiff > 3 ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.5), value: timeDiff > 3)
                }
                .padding()
            } else {
                Text("Recently used")
                    .foregroundColor(.green)

            }
        }
    }

    var body: some View {
        NavigationStack{
            getLastUsedStatus()
                .navigationTitle("GoBlue").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            ViewMessagesView()
                        } label: {
                            Image(systemName: "message.fill")
                        }

                    }
                }
        }
        
    }
}

#Preview {
    HomeView()
}
