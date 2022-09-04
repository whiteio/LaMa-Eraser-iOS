//
//  ContentView.swift
//  ImageEraser
//
//  Created by Christopher White on 30/08/2022.
//

import SwiftUI
import RiveRuntime
import PhotosUI

struct ContentView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        NavigationStack(path: $store.paths) {
            VStack {
                SplashscreenContentView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RiveViewModel(fileName: "shapes").view()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .blur(radius: 30)
                    .blendMode(.hardLight)
            )
            .background(
                Image("Spline")
                    .blur(radius: 50)
                    .offset(x: 200, y: 100)
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .editPhoto(photoData):
                    EditView(photoData: photoData)
                }
            }
            .toolbar(.hidden)
            .ignoresSafeArea()
        }
    }
}

struct SelectContentView: View {
    let button = RiveViewModel(fileName: "button", autoPlay: false)

    var body: some View {
        VStack(alignment: .leading) {
            button.view()
                .frame(width: 236, height: 64)
                .background(
                    Color.black
                        .cornerRadius(30)
                        .blur(radius: 10)
                        .opacity(0.3)
                        .offset(y: 10)
                )
                .overlay(
                    Label("Select a photo", systemImage: "photo.fill")
                        .bold()
                        .offset(x: 4, y: 4)
                )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView,
                      context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

struct SplashscreenContentView: View {
    @EnvironmentObject var store: Store
    
    @State var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack {
            Text("erase objects from images.")
                .frame(width: 260, alignment: .leading)
                .font(.largeTitle)
                .bold()
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                SelectContentView()
            }
            .tint(.black)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        store.navigateToPath(.editPhoto(data))
                    }
                }
            }
        }
    }
}
