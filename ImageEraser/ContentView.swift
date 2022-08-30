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
        .overlay(alignment: .topTrailing, content: {
            closeOverlay
        })
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedPhotoData = data
                }
            }
        }
    }

    @ViewBuilder private var closeOverlay: some View {
        if shouldShowSelectedPhoto {
            Button {
                withAnimation(.spring()) {
                    selectedPhotoData = nil
                    selectedItem = nil
                }
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 36, height: 36)
                    .foregroundColor(.black)
                    .background(.white)
                    .mask(Circle())
                    .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding()
        }
    }
}

struct ImageMaskingView: View {
    var selectedPhotoData: Data
    @State var points: [CGPoint] = []
    @State var previousPointsSegments: [[CGPoint]] = []

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                points.append(value.location)
            }
            .onEnded { _ in
                previousPointsSegments.append(points)
                points = []
            }
    }

    var body: some View {
            Image(uiImage: UIImage(data: selectedPhotoData)!)
                .resizable()
                .scaledToFit()
                .clipped()
                .gesture(drag)
                .overlay(
                    DrawShape(previousPointsSegments: previousPointsSegments, currentPointsSegment: points)
                        .stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue.opacity(0.4))
                )
                .clipped()
    }
}

struct DrawShape: Shape {
    var previousPointsSegments: [[CGPoint]]
    var currentPointsSegment: [CGPoint]

    // drawing is happening here
    func path(in rect: CGRect) -> Path {
        var path = Path()

        for segment in previousPointsSegments {
            guard let firstPoint = segment.first else { return path }

            path.move(to: firstPoint)

            path.move(to: firstPoint)
            for pointIndex in 1..<segment.count {
                path.addLine(to: segment[pointIndex])

            }
        }

        guard let currentSegmentFirstPoint = currentPointsSegment.first else { return path }

        path.move(to: currentSegmentFirstPoint)
        for pointIndex in 1..<currentPointsSegment.count {
            path.addLine(to: currentPointsSegment[pointIndex])

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
