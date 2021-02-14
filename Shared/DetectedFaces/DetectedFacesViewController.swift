//
//  DetectedFacesViewController.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 13/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

/**
 Shows a grid of all detected faces.
 */
class DetectedFacesViewController : UICollectionViewController {
    private let viewModel = DetectedFacesViewModel()

    override func viewDidLoad() {
        collectionView.register(UINib(nibName: ThumbnailViewCell.identifier, bundle: Bundle.main),
                                forCellWithReuseIdentifier: ThumbnailViewCell.identifier)
        viewModel.loadData()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.detectedFaces.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailViewCell.identifier, for: indexPath) as? ThumbnailViewCell else {
            fatalError(ThumbnailViewCell.unwrapError)
        }
        let detectedFace = viewModel.detectedFaces[indexPath.item]
        if let faceThumbnail = UIImage(data: detectedFace.imageJpegData) {
            cell.configure(for: faceThumbnail)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detectedFace = viewModel.detectedFaces[indexPath.item]
        let controller =
            storyboard!.instantiateViewController(withIdentifier: DetectedFaceAssetsViewController.identifier) as! DetectedFaceAssetsViewController
        controller.detectedFace = detectedFace
        navigationController?.pushViewController(controller, animated: false)
    }
}
