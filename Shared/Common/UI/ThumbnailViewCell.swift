//
//  ThumbnailFaceViewCell.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 13/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

/**
 Shows a simple square thumbnail with the given image
 */
class ThumbnailViewCell: UICollectionViewCell {
    @IBOutlet private var thumbnail: UIImageView!
    static let identifier = "ThumbnailViewCell"
    static let unwrapError = "Unable to find image thumbnail view cell"

    override func prepareForReuse() {
        self.thumbnail.image = nil
    }
    
    func configure(for thumbnailImage: UIImage) {
        self.thumbnail.image = thumbnailImage
    }
}
