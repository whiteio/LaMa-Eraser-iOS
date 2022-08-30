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
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data? {
        didSet {
            withAnimation {
                shouldShowSelectedPhoto = selectedPhotoData != nil
            }
        }
    }
    @State private var shouldShowSelectedPhoto = false

    var body: some View {
        VStack {
            if shouldShowSelectedPhoto, let data = selectedPhotoData {
                VStack {
                    ImageMaskingView(selectedPhotoData: data)
                }
                .frame(maxHeight: .infinity)
                .background(VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .ignoresSafeArea())

            } else {
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
                }
            }
        }
    }
}

struct ImageMaskingView: View {
    var selectedPhotoData: Data
    @State var points: [CGPoint] = []

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                points.append(value.location)
            }
            .onEnded { _ in }
    }

    var body: some View {
            Image(uiImage: UIImage(data: selectedPhotoData)!)
                .resizable()
                .scaledToFit()
                .clipped()
                .gesture(drag)
                .border(.red)
                .overlay(
                    DrawShape(points: points)
                        .stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue.opacity(0.4))
                )
                .clipped()
    }
}

struct DrawShape: Shape {

    var points: [CGPoint]

    // drawing is happening here
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let firstPoint = points.first else { return path }

        path.move(to: firstPoint)
        for pointIndex in 1..<points.count {
            path.addLine(to: points[pointIndex])

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
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
