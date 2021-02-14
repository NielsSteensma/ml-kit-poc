//
//  DetectedFaceAssetsViewController.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 13/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import Photos

/**
 Shows a grid of all photo assets belonging to a specific detected face.
 */
class DetectedFaceAssetsViewController: UICollectionViewController {
    static let identifier =  "DetectedFaceAssetsController"
    
    private let viewModel = DetectedFaceAssetsViewModel()
    var detectedFace: DetectedFace!

    override func viewDidLoad() {
        collectionView.register(UINib(nibName: ThumbnailViewCell.identifier, bundle: Bundle.main),
                                forCellWithReuseIdentifier: ThumbnailViewCell.identifier)
        viewModel.loadData(for: detectedFace)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.assets?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailViewCell.identifier, for: indexPath) as? ThumbnailViewCell else {
            fatalError(ThumbnailViewCell.unwrapError)
        }
        let asset = viewModel.assets![indexPath.item]
        let phAsset = viewModel.fetchAsset(localIdentifier: asset.asset.localId)
        PHImageManager.default().requestThumbnailForAssetGrid(for: phAsset,
                                                              thumbnailSize: CGSize(width: 100, height: 100)) { image in
            if let thumbnailImage = image {
                cell.configure(for: thumbnailImage)
            }
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = viewModel.assets![indexPath.item].asset
        let phAsset = viewModel.fetchAsset(localIdentifier: asset.localId)
        let assetViewController = self.storyboard?.instantiateViewController(withIdentifier: AssetViewController.identifier) as! AssetViewController
        assetViewController.asset = phAsset
        navigationController?.pushViewController(assetViewController, animated: false)
    }
}

