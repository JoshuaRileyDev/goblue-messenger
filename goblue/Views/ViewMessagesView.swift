//
//  ViewMessagesView.swift
//  goblue
//
//  Created by Joshua Riley on 15/03/2025.
//

import SwiftUI

struct ViewMessagesView: View {

    @State private var messages: [SBMessage] = []

    var body: some View {
        Form{
            ForEach(messages, id: \.id) { message in
                Text(message.message)
            }
        }.navigationTitle("Queued Messages").navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                do {
                    self.messages = try await SupabaseManager.shared.getMessages()
                    print(self.messages)
                } catch {
                    print("Error fetching messages: \(error)")
                }
            }
        }
    }
}

#Preview {
    ViewMessagesView()
}
