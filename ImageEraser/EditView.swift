//
//  EditView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/09/2022.
//

import SwiftUI

struct EditView: View {
    @State var undoDisabled = false
    @State var redoDisabled = true
    var photoData: Data

    init(photoData: Data) {
        self.photoData = photoData
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }

    var body: some View {
        Rectangle()
            .navigationTitle("ERASE")
            .navigationBarTitleDisplayMode(.inline)
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
                    Button(action: {}, label: {
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
