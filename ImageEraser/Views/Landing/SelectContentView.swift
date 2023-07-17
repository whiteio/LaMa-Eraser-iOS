//
//  SelectContentView.swift
//  ImageEraser
//
//  Created by Christopher White on 20/06/2023.
//

import SwiftUI

struct SelectContentView: View {
    var body: some View {
        VStack(alignment: .center) {
            Label("Select a photo", systemImage: "photo.fill")
                .bold()
                .padding(.vertical, 12)
                .padding(.horizontal, 26)
                .tint(.black)
        }
    }
}
