//
//  ShareableImage.swift
//  ImageEraser
//
//  Created by Christopher White on 10/10/2022.
//

import SwiftUI

struct ShareableImage: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }

    public var image: Image
    public var caption: String
}
