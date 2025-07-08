//
//  ContactsView.swift
//  goblue
//
//  Created by Joshua Riley on 10/02/2025.
//

import SwiftUI
import ContactsUI

struct ContactsView: View {
    
    @State var selectedTab: String = "hot"
    @State var searchText: String = ""
    @State private var showContactPicker = false

    @State var contacts: [SBContact] = []

    @State var showSendMessageSheet: Bool = false
    @State var selectedContacts: [SBContact] = []
    @AppStorage("apiKey") var apiKey: String = ""

    func getContacts(status: String) -> [SBContact] {
        return contacts.filter { $0.status == status }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Picker(selection: $selectedTab) {
                    Text("Hot contacts").tag("hot")
                    Text("Cold contacts").tag("cold")
                } label: {
                    
                }
                .pickerStyle(.segmented)
                Section {
                    Button {
                        selectedContacts = getContacts(status: selectedTab)
                        showSendMessageSheet = true
                    } label: {
                        ZStack{
                            HStack{
                                Spacer()
                                
                                Text("Bulk Send").padding(.trailing, 10)
                                Image(systemName: "paperplane")
                                Spacer()
                            }.padding(.vertical, 8)
                            
                        }
                    }
                }
                Section{
                    List {
                        ForEach(getContacts(status: selectedTab), id: \.id) { contact in
                                HStack {
                                    Image(systemName: selectedTab == "hot" ? "flame" : "snow")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text("\(contact.first_name) \(contact.last_name)")
                                            .font(.headline)
//                                        Text(selectedTab == "hot" ? "replied \(contact.last_updated.formatted(date: .abbreviated, time: .omitted) ?? "never")" : "submitted \(contact.created_at.formatted(date: .abbreviated, time: .omitted) ?? "never")")
//                                            .font(.subheadline)
//                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Button {
                                        selectedContacts = [contact]
                                        showSendMessageSheet = true
                                    } label: {
                                        Image(systemName: "paperplane")
                                            //.font(.footnote)
                                            .padding(12)
                                            .background(Color.blue.opacity(0.1))
                                            .clipShape(Capsule())
                                            .foregroundColor(.blue)
                                    }

                                }
                                .padding(.vertical, 4)
                                .swipeActions {
                                    
                                    Button(action: {
                                       Task {
                                        do {
                                            try await SupabaseManager.shared.deleteContact(contact.id)
                                            contacts = try await SupabaseManager.shared.getAllContacts()
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                       }
                                    }) {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                    Button(action: {
                                        Task {
                                            var c = contact
                                            c.status = selectedTab == "hot" ? "cold" : "hot"
                                            do {
                                                try await SupabaseManager.shared.updateContact(c)
                                                contacts = try await SupabaseManager.shared.getAllContacts()
                                            } catch {
                                                print(error.localizedDescription)

                                            }
                                        }
                                    }) {
                                        Image(systemName: selectedTab == "hot" ? "snow" : "flame")
                                    }
                                    .tint(selectedTab == "hot" ? .blue : .orange)
                                }
                            
                        }
                    }
                }
            }.navigationTitle("Contacts").navigationBarTitleDisplayMode(.inline).searchable(text: $searchText).toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showContactPicker = true
                    } label: {
                        Image(systemName: "person.crop.circle.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showContactPicker) {
                ContactPickerViewController(showContactPicker: $showContactPicker)
            }
            .sheet(isPresented: $showSendMessageSheet) {
                SendMessageSheetView(contacts: $selectedContacts, showSheet: $showSendMessageSheet)
            }
            .onAppear {
                    Task { @MainActor in
                        do {
                            let apiKey = try await SupabaseManager.shared.getAPIKey(user_id: try await SupabaseManager.shared.getID())
                            self.apiKey = apiKey.key_value
                        } catch {
                            
                        }
                    }
                Task {
                    do {
                        contacts = try await SupabaseManager.shared.getAllContacts()
                    } catch {
                        print(error.localizedDescription)
                    }
                   
                }
            }
        }
        
    }
}

struct ContactPickerViewController: UIViewControllerRepresentable {
    @Binding var showContactPicker: Bool
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.predicateForSelectionOfContact = nil
        picker.predicateForSelectionOfProperty = nil
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPickerViewController
        
        init(_ parent: ContactPickerViewController) {
            self.parent = parent
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.showContactPicker = false
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
            // Here you can handle the selected contacts
            // For example, create new SBContacts and save them to Supabase
            for contact in contacts {
                print(contact)
                if contact.phoneNumbers.count > 0 {
                    // Process each contact
                    let nc = SBContact(first_name: contact.givenName, last_name: contact.familyName, phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "", status: "cold", form_id: UUID())
                    Task {
                        do {
                            try await SupabaseManager.shared.createContact(nc)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                
            }
            parent.showContactPicker = false
        }
    }
}

#Preview {
    ContactsView()
}
