//
//  CGImagePropertyOrientationExentions.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 17/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

extension CGImagePropertyOrientation {
    func convertToUIImageOrientation() -> UIImage.Orientation{
        switch self {
        case .up:
            return UIImage.Orientation.up
        case .upMirrored:
            return UIImage.Orientation.upMirrored
        case .down:
            return UIImage.Orientation.down
        case .downMirrored:
            return UIImage.Orientation.downMirrored
        case .left:
            return UIImage.Orientation.left
        case .leftMirrored:
            return UIImage.Orientation.leftMirrored
        case .right:
            return UIImage.Orientation.right
        case .rightMirrored:
            return UIImage.Orientation.rightMirrored
        }
    }
}
