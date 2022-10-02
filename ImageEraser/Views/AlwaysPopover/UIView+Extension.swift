//
//  UIView+Extension.swift
//  ImageEraser
//
//  Created by Christopher White on 02/10/2022.
//

import UIKit

extension UIView {
    func closestVC() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}
