//
//  FaceHeader.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 10/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

class FaceHeader: UICollectionReusableView {
    static let identifier = "FaceHeader"

    @IBOutlet private var faceThumbnail: UIImageView!
    override func prepareForReuse() {
        super.prepareForReuse()
        faceThumbnail.image = nil
    }

    func setData(faceId: Int16, image: UIImage) {
        faceThumbnail.image = image
        faceThumbnail.contentMode = .scaleAspectFill
    }
}
