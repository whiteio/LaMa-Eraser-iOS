//
//  Data+Extras.swift
//  ImageEraser
//
//  Created by Christopher White on 04/09/2022.
//

import Foundation
import CoreGraphics
import UIKit

extension Data {
    func getSize() -> CGSize {
        let image = UIImage(data: self)
        if let cgImage = image?.cgImage {
            return CGSize(width: cgImage.width, height: cgImage.height)
        }

        return CGSize(width: 0, height: 0)
    }
}
