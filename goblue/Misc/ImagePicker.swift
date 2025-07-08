//
//  ImagePicker.swift
//  shortcuts
//
//  Created by Joshua Riley on 26/03/2024.
//

import SwiftUI
import PhotosUI

func getImage(_ imageVal: String, _ defaultImage: String) -> UIImage { // Replace with actual lock screen image variable
    
    if imageVal.isEmpty {
        // Return static image
        return UIImage(named: defaultImage)!
    } else {
        // Load image from documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageUrl = documentsDirectory
            .appendingPathComponent(imageVal) // Modify file extension if needed

        if let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
            return image
        } else {
            // Return fallback image if loading fails
            return  UIImage(named: defaultImage)!
        }
    }
}


struct ImagePickerButton: View {
    
    @State var label: String
    @Binding var image: String
    @State var defaultImage: String
    @State var showImagePicker = false
    
    var body: some View {
        Button {
            self.showImagePicker.toggle()
        } label: {
            HStack{
                Label(label, systemImage: "photo")
                Spacer()
                Image(uiImage: getImage(image, defaultImage)).resizable().aspectRatio(contentMode: .fit).frame(width:60)
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(showPicker: $showImagePicker, showErrorAlert: .constant(false), image: $image)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var showPicker: Bool
    @Binding var showErrorAlert: Bool
    @Binding var image: String
    var quality: CGFloat = 0.45
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    // MARK: Delegate Methods
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let image = results.first?.itemProvider {
                if image.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    self.parent.showPicker.toggle()
                    self.parent.showErrorAlert.toggle()
                }else{
                    image.loadObject(ofClass: UIImage.self) { image, err in
                        if(err != nil){
                            self.parent.showPicker.toggle()
                        }else{
                            if let data = (image as? UIImage)?.pngData() {
                                let fileName = UUID().uuidString + ".png"
                                if let fileURL = self.saveImageToDocumentsDirectory(data: data, fileName: fileName) {
                                    DispatchQueue.main.async {
                                        self.parent.image = fileName
                                        self.parent.showPicker.toggle()
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
            } else {
                self.parent.showPicker.toggle()
            }
        }
        
        private func saveImageToDocumentsDirectory(data: Data, fileName: String) -> URL? {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = documentsDirectory?.appendingPathComponent(fileName)
            
            do {
                try FileManager.default.createDirectory(at: fileURL!.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                try data.write(to: fileURL!)
                return fileURL
            } catch {
                print("Error saving image to documents directory: \(error)")
                return nil
            }
        }
    }
}

