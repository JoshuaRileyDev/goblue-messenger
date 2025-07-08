//
//  FormsView.swift
//  goblue
//
//  Created by Joshua Riley on 10/02/2025.
//

import SwiftUI

struct FormsView: View {
    @State private var searchText: String = ""
    @State private var forms: [SBForm] = []
    @State private var showingAddForm = false
    @State private var newFormName: String = ""
    @State private var isLoading = false
    @State private var animateCards = false
    @State private var selectedForm: SBForm?
    @State private var showingDeleteAlert = false
    @State private var formToDelete: SBForm?
    
    private var filteredForms: [SBForm] {
        if searchText.isEmpty {
            return forms
        } else {
            return forms.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.goBG.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.md) {
                        if isLoading {
                            loadingView
                        } else if forms.isEmpty {
                            emptyStateView
                        } else {
                            formsGridView
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
                .searchable(text: $searchText, prompt: "Search forms...")
            }
            .navigationTitle("Forms")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    IconButton("plus", size: 20, color: .goBlue) {
                        showingAddForm = true
                    }
                }
            }
            .task {
                await loadForms()
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                    animateCards = true
                }
            }
            .sheet(isPresented: $showingAddForm) {
                AddFormSheet(newFormName: $newFormName) {
                    await createForm()
                }
            }
            .alert("Delete Form", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let form = formToDelete {
                        Task {
                            await deleteForm(form)
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this form? This action cannot be undone.")
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .goBlue))
                .scaleEffect(1.5)
            
            Text("Loading your forms...")
                .font(.subheadline)
                .foregroundColor(.goTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.xxl)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: "doc.text")
                .font(.system(size: 80))
                .foregroundColor(.goTextTertiary)
                .opacity(animateCards ? 1 : 0)
                .scaleEffect(animateCards ? 1 : 0.5)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No Forms Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.goTextPrimary)
                
                Text("Create your first form to start organizing your messages")
                    .font(.body)
                    .foregroundColor(.goTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .opacity(animateCards ? 1 : 0)
            .offset(y: animateCards ? 0 : 20)
            
            ModernButton(
                "Create Your First Form",
                icon: "plus.circle.fill",
                style: .primary,
                size: .large
            ) {
                showingAddForm = true
            }
            .opacity(animateCards ? 1 : 0)
            .offset(y: animateCards ? 0 : 30)
        }
        .padding(DesignSystem.Spacing.xl)
    }
    
    private var formsGridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
            GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
        ], spacing: DesignSystem.Spacing.md) {
            ForEach(Array(filteredForms.enumerated()), id: \.element.id) { index, form in
                FormCard(
                    form: form,
                    onEdit: {
                        selectedForm = form
                    },
                    onDelete: {
                        formToDelete = form
                        showingDeleteAlert = true
                    }
                )
                .opacity(animateCards ? 1 : 0)
                .offset(y: animateCards ? 0 : 50)
                .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: animateCards)
            }
        }
    }
    
    @MainActor
    private func loadForms() async {
        isLoading = true
        do {
            forms = try await SupabaseManager.shared.getUserForms()
        } catch {
            print("Error fetching forms: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    private func createForm() async {
        guard !newFormName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        do {
            let userID = try await SupabaseManager.shared.getID()
            let newForm = SBForm(id: UUID(), name: newFormName.trimmingCharacters(in: .whitespacesAndNewlines), message_template: "", user_id: userID)
            forms.append(newForm)
            try await SupabaseManager.shared.createForm(newForm)
            newFormName = ""
        } catch {
            print("Error creating form: \(error)")
        }
    }
    
    @MainActor
    private func deleteForm(_ form: SBForm) async {
        do {
            // Delete all form fields first
            let fields = try await SupabaseManager.shared.getFormFields(formID: form.id)
            for field in fields {
                try await SupabaseManager.shared.deleteFormField(field.id)
            }
            
            // Delete the form
            try await SupabaseManager.shared.deleteForm(form.id)
            forms.removeAll { $0.id == form.id }
        } catch {
            print("Error deleting form: \(error)")
        }
    }
}

// MARK: - Form Card Component
struct FormCard: View {
    let form: SBForm
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.title2)
                        .foregroundColor(.goBlue)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: onEdit) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.headline)
                            .foregroundColor(.goTextSecondary)
                            .frame(width: 24, height: 24)
                    }
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(form.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.goTextPrimary)
                        .lineLimit(2)
                    
                    if !form.message_template.isEmpty {
                        Text(form.message_template)
                            .font(.caption)
                            .foregroundColor(.goTextSecondary)
                            .lineLimit(3)
                    } else {
                        Text("No message template")
                            .font(.caption)
                            .foregroundColor(.goTextTertiary)
                            .italic()
                    }
                }
                
                HStack {
                    StatusBadge(
                        text: form.autoFollowUp ? "Auto-follow" : "Manual",
                        status: form.autoFollowUp ? .success : .neutral
                    )
                    
                    Spacer()
                    
                    if form.includeAttachment {
                        Image(systemName: "paperclip")
                            .font(.caption)
                            .foregroundColor(.goAccent)
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .onTapGesture {
            onEdit()
        }
    }
}

// MARK: - Add Form Sheet
struct AddFormSheet: View {
    @Binding var newFormName: String
    let onSave: () async -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isCreating = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.lg) {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.goBlue)
                    
                    Text("Create New Form")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.goTextPrimary)
                    
                    Text("Give your form a descriptive name")
                        .font(.subheadline)
                        .foregroundColor(.goTextSecondary)
                        .multilineTextAlignment(.center)
                }
                
                ModernTextField(
                    "Form Name",
                    placeholder: "Enter form name",
                    text: $newFormName
                )
                
                Spacer()
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    ModernButton(
                        "Create Form",
                        icon: isCreating ? nil : "checkmark",
                        style: .primary,
                        size: .large
                    ) {
                        Task {
                            isCreating = true
                            await onSave()
                            isCreating = false
                            dismiss()
                        }
                    }
                    .disabled(newFormName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating)
                    .overlay(
                        isCreating ?
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                        : nil
                    )
                    
                    ModernButton(
                        "Cancel",
                        style: .ghost,
                        size: .medium
                    ) {
                        dismiss()
                    }
                }
            }
            .padding(DesignSystem.Spacing.xl)
            .background(Color.goBG)
        }
    }
}

#Preview {
    FormsView()
}
