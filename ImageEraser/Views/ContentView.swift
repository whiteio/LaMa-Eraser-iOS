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

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    var body: some View {
        NavigationStack(path: $store.paths) {
            VStack {
                SplashscreenContentView(selectedItem: $selectedItem)
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
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedPhotoData = data
                        store.navigateToPath(.editPhoto(data))
                    }
                }
            }
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

struct DrawShape: Shape {
    var previousPointsSegments: [PointsSegment]
    var currentPointsSegment: PointsSegment

    // drawing is happening here
    func path(in rect: CGRect) -> Path {
        var path = Path()

        for segment in previousPointsSegments {
            guard let firstPoint = segment.rectPoints.first else { return path }

            path.move(to: firstPoint)

            path.move(to: firstPoint)
            for pointIndex in 1..<segment.rectPoints.count {
                path.addLine(to: segment.rectPoints[pointIndex])
            }
        }

        guard let currentSegmentFirstPoint = currentPointsSegment.rectPoints.first else { return path }

        path.move(to: currentSegmentFirstPoint)
        for pointIndex in 1..<currentPointsSegment.rectPoints.count {
            path.addLine(to: currentPointsSegment.rectPoints[pointIndex])

        }
        return path
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
    @Binding var selectedItem: PhotosPickerItem?

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
        }
    }
}
