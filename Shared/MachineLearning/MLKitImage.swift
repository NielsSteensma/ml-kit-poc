//
//  MLKitImage.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 05/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import Photos

/**
 Represents required image data for use in any of our MLKit algorithms.
 */
struct MLKitImage {
    let uiImage: UIImage
    let asset: PHAsset
    let assetCollection: AssetCollection
}
