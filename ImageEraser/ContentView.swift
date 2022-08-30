//
//  ContentView.swift
//  ImageEraser
//
//  Created by Christopher White on 30/08/2022.
//

import SwiftUI
import RiveRuntime

struct ContentView: View {
    let button = RiveViewModel(fileName: "button", autoPlay: false)
    var body: some View {
        VStack(alignment: .leading) {
                Text("erase objects from images.")
                    .frame(width: 260, alignment: .leading)
                    .font(.largeTitle)
                    .bold()
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
                    .onTapGesture {
                        try? button.play(animationName: "active")
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
