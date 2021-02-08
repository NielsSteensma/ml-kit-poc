//
//  AssetGridCellConfigurator.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 07/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import Photos
import CoreData

class AssetGridCellConfigurator {
    private lazy var imageManager = PHImageManager()

    /**
     Configures the given GridViewCell to show the thumbnail and MLKit results for the given asset.
     */
    func configure(for cell: GridViewCell, with asset: PHAsset, thumbnailSize: CGSize) {
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

    private func setMLKitResults(asset: PHAsset, cell: GridViewCell){
        let context = DBHelper.getViewContext()
        context.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Asset")
            fetchRequest.predicate = NSPredicate(format: "localId == %@", asset.localIdentifier)
            do {
                let foundAsset = try context.fetch(fetchRequest)
                print("SIZE: \(foundAsset.count)")
                if let asset = foundAsset.first,
                   let faceId = asset.value(forKey: "faceId") as? Int,
                   let faces = asset.value(forKey: "amountOfFaces") as? Int {
                    cell.faceId.text = faceId != 0 ? String(faceId) : ""
                    cell.faces.text = faces != 0 ? String(faces) : ""
                }
                cell.layoutIfNeeded()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
