//
//  ContentView.swift
//  ImageEraser
//
//  Created by Christopher White on 30/08/2022.
//

import SwiftUI
import RiveRuntime
import PhotosUI

enum Route: Hashable {
    case editPhoto(Data)
}

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State var selectedEditIndex = 0
    @State private var selectedPhotoData: Data? {
        didSet {
            withAnimation {
                shouldShowSelectedPhoto = selectedPhotoData != nil
            }
        }
    }
    @State private var shouldShowSelectedPhoto = false

    @State var points: [CGPoint] = []
    @State var previousPointsSegments: [[CGPoint]] = []

    @State private var brushSize = 30.0

    @State private var paths: [Route] = []

    var body: some View {
        NavigationStack(path: $paths) {
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
                        paths.append(.editPhoto(data))
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

    @State private var isEditing = false
    @ViewBuilder private var brushSizeOverlay: some View {
        if shouldShowSelectedPhoto {
            LabeledContent("Brush size", content: {
                Slider(
                    value: $brushSize,
                    in: 10...50,
                    onEditingChanged: { editing in
                        isEditing = editing
                    }
                )
                .frame(width: 100)
                .padding()
            })
            .foregroundColor(.white)
            .padding()
        }
    }

    @ViewBuilder private var undoOverlay: some View {
        if shouldShowSelectedPhoto {
            Button(action: {
                previousPointsSegments.removeLast()
            }, label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.title)
            })
            .disabled(previousPointsSegments.isEmpty)
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

struct ImageMaskingView: View {
    var selectedPhotoData: Data
    @Binding var points: [CGPoint]
    @Binding var previousPointsSegments: [[CGPoint]]
    @Binding var brushSize: Double

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
        VStack(alignment: .trailing) {
            Image(uiImage: UIImage(data: selectedPhotoData)!)
                .resizable()
                .scaledToFit()
                .clipped()
                .gesture(drag)
                .overlay(
                    DrawShape(previousPointsSegments: previousPointsSegments, currentPointsSegment: points)
                        .stroke(style: StrokeStyle(lineWidth: brushSize, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue.opacity(0.4))
                )
                .clipped()
        }
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
