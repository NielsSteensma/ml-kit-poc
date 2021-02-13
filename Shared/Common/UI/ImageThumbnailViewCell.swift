//
//  DetectedFaceViewCell.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 13/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

/**
 Shows the thumbnail of a detected face/image
 */
class ImageThumbnailViewCell: UICollectionViewCell {
    @IBOutlet var thumbnail: UIImageView!
    static let identifier = "ImageThumbnailViewCell"

    func setData(thumbnail: UIImage) {
        self.thumbnail.image = thumbnail
    }
}
