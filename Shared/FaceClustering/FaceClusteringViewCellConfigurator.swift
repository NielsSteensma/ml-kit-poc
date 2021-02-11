//
//  FaceClusteringCellConfigurator.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 07/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import Photos

class FaceClusteringViewCellConfigurator {
    private lazy var imageManager = PHImageManager()

    /**
     Configures the given GridViewCell to show the thumbnail and MLKit results for the given asset.
     */
    func configure(for cell: FaceClusteringViewCell, with asset: PHAsset, thumbnailSize: CGSize) {
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier

        PHImageManager.default().requestThumbnailForAssetGrid(for: asset,
                                                              thumbnailSize: thumbnailSize) { image in
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        }

        setMLKitResults(asset: asset, cell: cell)
    }

    private func setMLKitResults(asset: PHAsset, cell: FaceClusteringViewCell){
        let context = DBHelper.getViewContext()
        context.perform {
            do {
                let fetchRequest = Asset.byLocalAssetIdFetchRequest(localAssetId: asset.localIdentifier)
                let foundAsset = try context.fetchOne(fetchRequest)
                if let asset = foundAsset {
                    cell.faces.text = asset.amountOfFaces != 0 ? String(asset.amountOfFaces) : ""
                }
                cell.layoutIfNeeded()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
