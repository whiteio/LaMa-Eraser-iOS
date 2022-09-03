//
//  EditView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/09/2022.
//

import SwiftUI

struct Coordinates {
    var xCoordinate: CGFloat
    var yCoordinate: CGFloat
}

struct EditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var undoDisabled = true
    @State var redoDisabled = true
    var photoData: Data

    init(photoData: Data) {
        self.photoData = photoData
    }

    @State var scale: CGFloat = 1.0
    @State var offset: Coordinates = Coordinates(xCoordinate: 0, yCoordinate: 0)

    var body: some View {
        VStack {
            ZoomableScrollView {
                Image(uiImage: UIImage(data: photoData)!)
                    .resizable()
                    .scaledToFit()
            }
        }
        .navigationTitle("ERASE")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {}, label: {
                    Image(systemName: "arrow.uturn.backward.circle")
                })
                .tint(.white)
                .disabled(undoDisabled)
                Button(action: {}, label: {
                    Image(systemName: "arrow.uturn.forward.circle")
                })
                .tint(.white)
                .disabled(redoDisabled)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                })
                Spacer()
                Button(action: {}, label: {
                    Text("Save")
                })
            }
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditView(photoData: Data())
                .preferredColorScheme(.dark)
        }
    }
}
