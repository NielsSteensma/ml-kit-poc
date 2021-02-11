//
//  FaceHeader.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 10/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

class FaceHeader: UICollectionReusableView {
    @IBOutlet var faceIdLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        faceIdLabel.text = ""
    }

    func setData(faceId: Int16){
        faceIdLabel.text = String("Face: \(faceId)")
    }
}
