//
//  ChooseGifView.swift
//  goblue
//
//  Created by Joshua Riley on 01/03/2025.
//

import SwiftUI

struct ChooseGifView: View {
    @Environment(\.dismiss) var dismiss
    @State private var gifs: [SBGif] = []
    @State private var selectedGif: SBGif?
    @Binding var form: SBForm
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(gifs.enumerated()), id: \.offset) { index, gif in
                    Button{
                        self.form.attachmentValue = gif.url
                        Task {
                            try await SupabaseManager.shared.updateForm(form)
                            dismiss()
                        }
                        
                        
                    } label: {
                        Text(gif.uuid.uuidString)
                    }
                        
                }
            }.navigationTitle("Choose a Gif").navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                Task {
                    print("getting gifs")
                    do {
                        self.gifs = try await SupabaseManager.shared.getGifs()
                        print(self.gifs.count)
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
            }
        }
    }
}
