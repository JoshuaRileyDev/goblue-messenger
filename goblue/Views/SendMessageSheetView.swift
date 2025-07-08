//
//  SendMessageSheetView.swift
//  goblue
//
//  Created by Joshua Riley on 15/02/2025.
//

import SwiftUI

struct SendMessageSheetView: View {
    
    @Binding var contacts: [SBContact]
    @Binding var showSheet: Bool
    @State var message: String = ""
    
    @State var formFields: [String] = ["First Name","Last Name", "Phone Number"]
    
    var body: some View {
        NavigationStack{
            Form{
                Section("Quick Fields"){
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90, maximum: .infinity))], spacing: 8) {
                        ForEach(formFields, id: \.self) { field in
                            Button {
                                message = "\(message){{\(toPascalCase(field))}}"
                            } label: {
                                HStack {
                                    Image(systemName: "text.append")
                                    Text(field)
                                }
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                            }
                        }
                    }.listRowBackground(Color.clear).buttonStyle(BorderlessButtonStyle())
                }
                TextEditor(text: $message).frame(height: 100)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            do {
                                let userID = try await SupabaseManager.shared.getID()
                                let messages = contacts.map { contact in
                                    let personalizedMessage = message
                                        .replacingOccurrences(of: "{{firstName}}", with: contact.first_name)
                                        .replacingOccurrences(of: "{{lastName}}", with: contact.last_name)
                                        .replacingOccurrences(of: "{{phoneNumber}}", with: contact.phoneNumber)
                                    
                                    return SBMessage(
                                        user_id: userID,
                                        phoneNumber: contact.phoneNumber,
                                        message: personalizedMessage
                                    )
                                }
                                _ = try await SupabaseManager.shared.sendBulkMessages(messages)
                                showSheet = false
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }) {
                        Image(systemName: "paperplane")
                    }
                }
            }
        }
    }
}
