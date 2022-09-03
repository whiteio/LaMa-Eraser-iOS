//
//  EditView.swift
//  ImageEraser
//
//  Created by Christopher White on 02/09/2022.
//

import SwiftUI

struct Coordinates {
    var x: CGFloat
    var y: CGFloat
}

struct EditView: View {
    @State var undoDisabled = true
    @State var redoDisabled = true
    var photoData: Data

    init(photoData: Data) {
        self.photoData = photoData
    }

    @State var scale: CGFloat = 1.0
    @State var offset: Coordinates = Coordinates(x: 0, y: 0)
    @State var imageTopPadding: CGFloat = 0.0

    var body: some View {
        VStack {
            ZoomableScrollView {
                Rectangle()
                    .padding(.top, imageTopPadding)
                    .background(NavBarAccessor { navBar in
                        imageTopPadding = navBar.frame.height
                    })
            }
        }
        .ignoresSafeArea()
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

struct NavBarAccessor: UIViewControllerRepresentable {
    var callback: (UINavigationBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavBarAccessor>) ->
    UIViewController {
        proxyController.callback = callback
        return proxyController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavBarAccessor>) {
    }

    typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UINavigationBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let navBar = self.navigationController {
                self.callback(navBar.navigationBar)
            }
        }
    }
}
