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
        collectionView.register(UINib(nibName: ImageThumbnailViewCell.identifier, bundle: Bundle.main), forCellWithReuseIdentifier: ImageThumbnailViewCell.identifier)
        viewModel.loadData()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.detectedFaces.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageThumbnailViewCell.identifier, for: indexPath) as? ImageThumbnailViewCell else {
            fatalError("Unable to find image thumbnail view cell")
        }
        let detectedFace = viewModel.detectedFaces[indexPath.item]
        cell.setData(thumbnail: UIImage(data: detectedFace.image)!)
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
