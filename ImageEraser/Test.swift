//
//  Test.swift
//  ImageEraser
//
//  Created by Christopher White on 30/08/2022.
//

import SwiftUI

struct Test: View {
    @State private var isShowingRed = false
    var body: some View {
        VStack {
            Button("Tap Me") {
                withAnimation {
                    isShowingRed.toggle()
                }
            }

            if isShowingRed {
                Rectangle()
                    .fill(.red)
                    .frame(width: 200, height: 200)
            } else {
                Rectangle()
                    .fill(.blue)
                    .frame(width: 100, height: 100)
            }
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
