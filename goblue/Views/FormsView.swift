//
//  FormsView.swift
//  goblue
//
//  Created by Joshua Riley on 10/02/2025.
//

import SwiftUI

struct FormsView: View {
    
    @State var searchText: String = ""
    @State private var forms: [SBForm] = []
    @State private var showingAddForm = false
    @State private var newFormName: String = ""

    func deleteForm(at offsets: IndexSet) {
        Task {
            let id = forms[offsets.first!].id
            // delete all form fields
            let fields = try await SupabaseManager.shared.getFormFields(formID: id)
            for field in fields {
                try await SupabaseManager.shared.deleteFormField(field.id)
            }
            try await SupabaseManager.shared.deleteForm(id)
            forms.remove(atOffsets: offsets)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                List {
                    ForEach(Array(forms.enumerated()), id: \.element.id) { index, form in
                        NavigationLink(destination: EditFormView(form: $forms[index])) {
                            HStack {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            
                                    Text(form.name)
                                        .font(.headline)
                                
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteForm)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddForm = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Forms").searchable(text: $searchText)
            .task {
                do {
                    forms = try await SupabaseManager.shared.getUserForms()
                } catch {
                    print("Error fetching forms: \(error)")
                }
            }
            .alert("Add Form", isPresented: $showingAddForm) {
                TextField("Form Name", text: $newFormName)
                Button("Save") {
                    Task {
                        let newForm = SBForm(id: UUID(), name: newFormName, message_template: "", user_id: try await SupabaseManager.shared.getID())
                        forms.append(newForm)
                        try await SupabaseManager.shared.createForm(newForm)
                         
                    }
                }
            }
        }
    }
}

#Preview {
    FormsView()
}
