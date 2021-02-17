//
//  PHImageManagerExtensions.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 08/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import Photos
import UIKit

/**
 Provides a set of convenient methods to retrieve images for assets in the context of our code.
 */
extension PHImageManager {
    typealias ImageRequestCompletionHandler = (_ image: UIImage?) -> Void

    /**
     Requests the original image for the asset from Apple Photos.
     */
    func requestImageForFaceDetection(for asset: PHAsset, completion: @escaping ImageRequestCompletionHandler) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat // Beware: .opportunistic results in double completion handler calls
        options.resizeMode = .none
        options.isNetworkAccessAllowed = true
        self.requestImage(for: asset,
                          targetSize: PHImageManagerMaximumSize,
                          contentMode: .aspectFit,
                          options: options) { (image, info) in
            completion(image)
        }
    }

    /**
     Requests the original image for the asset from Apple Photos.
     */
    func requestImageForFaceDetectionNew(for asset: PHAsset, completion: @escaping ImageRequestCompletionHandler) {
        let options = PHImageRequestOptions()
        //options.isSynchronous = true
        options.deliveryMode = .highQualityFormat // Beware: .opportunistic results in double completion handler calls
        options.resizeMode = .none
        options.isNetworkAccessAllowed = true
        options.version = .current
        if #available(iOS 13, *) {
            self.requestImageDataAndOrientation(for: asset,
                                                options: options) { (data, _, orientation, _) in
                let imageWithoutOrientation = UIImage(data: data!)
                let uiImageOrientation = orientation.convertToUIImageOrientation()
                completion(UIImage(cgImage: (imageWithoutOrientation?.cgImage!)!,
                                   scale: 1.0, orientation: uiImageOrientation))
            }
        } else {
            self.requestImageForFaceDetection(for: asset){ image in
                completion(image)
            }
        }
    }

    /**
     Requests a thumbnail image for the asset from Apple Photos with the specified target size.
     */
    func requestThumbnailForAssetGrid(for asset: PHAsset,
                                      thumbnailSize: CGSize,
                                      completion: @escaping ImageRequestCompletionHandler) {
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        self.requestImage(for: asset,
                          targetSize: thumbnailSize,
                          contentMode: .aspectFill,
                          options: options) { image, _ in
            completion(image)
        }
    }
}
