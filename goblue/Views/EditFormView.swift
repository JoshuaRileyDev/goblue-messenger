//
//  EditFormView.swift
//  goblue
//
//  Created by Joshua Riley on 10/02/2025.
//

import SwiftUI

struct EditFormView: View {
    @State private var showingAddField = false
    @State private var newFieldName = ""

    @State private var fields: [String] = ["First Name", "Last Name", "Email", "Phone"]

    @State var messageTemplate: String = ""
    
    @Binding var form: SBForm
    @State private var showingEditFormName = false

    @State private var formFields: [SBFormField] = []
    
    @State var postLaterValue: String = "0"
    @State var showChooseGif = false
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $form.enableCapturing) {
                    Label("Enable capturing", systemImage: "list.bullet.clipboard")
                }
                .onChange(of: form.enableCapturing) { newValue in
                    Task {
                        try await SupabaseManager.shared.updateForm(form)
                    }
                }
                Button {
                    UIPasteboard.general.string = "https://api.goblue.app/v1/forms/\(form.id)/webhook"
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "doc.on.doc")
                        Text("Copy Capture URL")
                        Spacer()
                        
                    }
                }
            }
            Section {
                NavigationLink(destination: {
                    Form {
                        Section("Send POST request to"){
                            HStack {
                                TextField(text: .constant("https://api.goblue.app/v1/forms/\(form.id.uuidString.lowercased())/webhook")) {
                                    
                                }
                                Button(action: {
                                    UIPasteboard.general.string = "https://api.goblue.app/v1/forms/\(form.id.uuidString.lowercased())/webhook"
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        Section("Request body as JSON") {
                            Text("""
                            {
                                \(formFields.map { "\"\(toPascalCase($0.name))\": \"\"" }.joined(separator: ",\n    "))
                                "phoneNumber":""
                            }
                            """).padding(.all, 2)
                        }
                    }
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                        Text("View API example")
                        Spacer()
                    }
                }
            }
            Section("Form fields") {
                List {
                    ForEach(formFields, id: \.id) { field in
                        HStack {
                            Text(field.name)
                            Spacer()
                            if field.name != "phoneNumber" {
                                Button(action: {
                                    if let index = formFields.firstIndex(where: { $0.id == field.id }) {
                                        formFields.remove(at: index)
                                        Task {
                                            try await SupabaseManager.shared.deleteFormField(field.id)
                                        }
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                }
                Button {
                    showingAddField = true
                } label: {
                    Label("Add Field", systemImage: "plus")
                }

            }
            Toggle(isOn: $form.autoFollowUp, label:{
                Label("Auto Follow-up", systemImage: "message")
            })
            .onChange(of: form.autoFollowUp) { newValue in
                Task {
                    try await SupabaseManager.shared.updateForm(form)
                }
            }
            Section {
                Toggle(isOn: $form.postLater, label:{
                    Label("Send later", systemImage: "clock.arrow.circlepath")
                })
                .onChange(of: form.postLater) { newValue in
                    Task {
                        try await SupabaseManager.shared.updateForm(form)
                    }
                }
                if form.postLater {
                    HStack{
                        Text("Send in")
                        Spacer()
                        TextField(text: $postLaterValue) {
                            
                        }
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                        .onChange(of: postLaterValue) { newValue in
                            Task {
                                form.postLaterValue = Int(postLaterValue) ?? 0
                                try await SupabaseManager.shared.updateForm(form)
                            }
                        }
                        Picker(selection: $form.postLaterType) {
                            Text("Minute(s)").tag("minutes")
                            Text("Hour(s)").tag("hours")
                            Text("Day(s)").tag("days")
                            Text("Week(s)").tag("weeks")
                        } label: {
                            
                        }
                        .onChange(of: form.postLaterType) { newValue in
                            Task {
                                try await SupabaseManager.shared.updateForm(form)
                            }
                        }

                    }
                    .onAppear(){
                        self.postLaterValue = "\(form.postLaterValue)"
                    }
                }
            }
            .onChange(of: form.postLater) { newValue in
                Task {
                    try await SupabaseManager.shared.updateForm(form)
                }
            }
            if form.autoFollowUp {
                Section {
                    NavigationLink(destination: {
                        Form {
                            Section("Quick Fields"){
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90, maximum: .infinity))], spacing: 8) {
                                    ForEach(formFields, id: \.id) { field in
                                        Button {
                                            form.message_template = "\(form.message_template){{\(field.name)}}"
                                            Task {
                                                try await SupabaseManager.shared.updateForm(form)
                                            }
                                        } label: {
                                            HStack {
                                                Image(systemName: "text.append")
                                                Text(field.name)
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
                            TextEditor(text: $form.message_template)
                                .frame(minHeight: 80)
                                .onChange(of: form.message_template) { _, _ in
                                    Task {
                                        try await SupabaseManager.shared.updateForm(form)
                                    }
                                }
                            Section {
                                Toggle("Include attachment", systemImage: "paperclip", isOn: $form.includeAttachment)
                                .onChange(of: form.includeAttachment) { newValue in
                                    Task {
                                        try await SupabaseManager.shared.updateForm(form)
                                    }
                                }
                            }
                            if form.includeAttachment {
                                Section {
                                    Picker(selection: $form.attachmentType) {
                                        Text("Gif").tag("gif")
                                    } label: {
                                        Text("Choose Attachment")
                                    }

                                }
                                if form.attachmentType == "gif" {
                                    Button {
                                        showChooseGif = true
                                    } label: {
                                        Text("Choose Gif")
                                    }
                                }
                            }
                        }
                    }, label: {
                        Label("Configure Message", systemImage: "note.text")
                    }
                    )
                }
            }
        }
        .sheet(isPresented: $showChooseGif) {
            ChooseGifView(form: $form).presentationDetents([.medium])
        }
        .navigationTitle("\(form.name)").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEditFormName = true
                }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .alert("Edit form name", isPresented: $showingEditFormName) {
            TextField("Form Name", text: $form.name)
            Button("Save") {
                Task {
                    try? await SupabaseManager.shared.updateForm(form)
                }
            }
        }
        .alert("Add New Field", isPresented: $showingAddField) {
            TextField("Field Name", text: $newFieldName)
            Button("Add") {
                Task {
                    let newField = SBFormField(id: UUID(), name: newFieldName, form_id: form.id)
                    self.formFields.append(newField)
                    try await SupabaseManager.shared.createFormField(newField)
                    
                }
            }
            Button("Cancel", role: .cancel) {
                newFieldName = ""
            }
        } message: {
            Text("Enter a name for the new field")
        }
        .onAppear {
            Task {
                formFields = try await SupabaseManager.shared.getFormFields(formID: form.id)
                if formFields.count == 0 {
                    let newField = SBFormField(id: UUID(), name: "phoneNumber", form_id: form.id)
                    try await SupabaseManager.shared.createFormField(newField)
                    formFields.append(newField)
                }
            }
        }
    }
}
