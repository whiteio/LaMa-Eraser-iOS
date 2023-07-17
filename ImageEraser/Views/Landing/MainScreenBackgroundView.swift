//
//  MainScreenBackgroundView.swift
//  ImageEraser
//
//  Created by Christopher White on 20/06/2023.
//

import SwiftUI

struct MainScreenBackgroundView: View {
    var body: some View {
        ZStack {
            Polygon(count: 3, cornerRadius: 40)
                .fill(LinearGradient(colors: [.red, .orange], startPoint: .bottomLeading, endPoint: .topTrailing))
                .frame(width: 350, height: 350)
                .phaseAnimator([0, 30, 60, 90], content: { view, phase in
                    view.rotationEffect(.degrees(phase))
                }, animation: { _ in
                    Animation.linear(duration: 1.5)
                })
                .phaseAnimator([250, -250], content: { view, phase in
                    view.offset(x: phase, y: -phase)
                }, animation: { _ in
                    Animation.linear(duration: 6)
                })
            Polygon(count: 6, cornerRadius: 40)
                .fill(LinearGradient(colors: [.blue, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 210, height: 210)
                .phaseAnimator([400, -300], content: { view, phase in
                    view.offset(x: phase)
                }, animation: { _ in
                    Animation.linear(duration: 5)
                })
                .phaseAnimator([200, 400, 100], content: { view, phase in
                    view.offset(y: phase)
                }, animation: { _ in
                    Animation.linear(duration: 5)
                })
            Circle()
                .fill(LinearGradient(colors: [.white, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 200, height: 200)
                .phaseAnimator([300, -300], content: { view, phase in
                    view.offset(x: phase)
                }, animation: { _ in
                    Animation.linear(duration: 6)
                })
                .phaseAnimator([200, 400, 100], content: { view, phase in
                    view.offset(y: phase)
                }, animation: { _ in
                    Animation.linear(duration: 6)
                })
        }
        .blur(radius: 30)
        .blendMode(.hardLight)
    }
}
