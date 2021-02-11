//
//  FaceClusteringViewModel.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 11/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Photos

/**
 Viewmodel associated with the face clustering grid.
 */
class FaceClusteringViewModel {
    private(set) var detectedFaceIds: [Int16] = []
    private(set) var assetFaces: [Int16: [AssetFaces]] = [:]
    var phAssetCollection: PHAssetCollection

    init(phAssetCollection: PHAssetCollection) {
        self.phAssetCollection = phAssetCollection
    }

    func fetchAsset(for faceId: Int16, index: Int) -> PHAsset {
        let localAssetIdentifier = assetFaces[faceId]![index].asset.localId
        let fetchedAssets = PHAsset.fetchAssets(withLocalIdentifiers: [localAssetIdentifier], options: nil)
        return fetchedAssets.firstObject!
    }

    func updateData() {
        updateSections()
        updateAssetFaces()
    }

    private func updateSections() {
        let context = DBHelper.getViewContext()
        context.performAndWait {
            do {
                let assetCollection =
                    try context.fetchOne(AssetCollection.byLocalIdFetchRequest(localId: phAssetCollection.localIdentifier))!
                let assetFaces = assetCollection.assetFaces
                detectedFaceIds = Array(Set(assetFaces.map({$0.detectedFace.trackingId})))
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    private func updateAssetFaces(){
        let context = DBHelper.getViewContext()
        context.performAndWait {
            for detectedFaceId in detectedFaceIds {
                do {
                    let detectedFace = try context.fetchOne(DetectedFace.bytrackingIdFetchRequest(trackingId: detectedFaceId))!
                    assetFaces[detectedFaceId] = Array(detectedFace.assetFaces)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}
