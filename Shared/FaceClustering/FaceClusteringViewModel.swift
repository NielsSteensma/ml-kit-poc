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
    var assetFaces: [Int16: [AssetFaces]] = [:]
    var phAssetCollection: PHAssetCollection

    init(phAssetCollection: PHAssetCollection) {
        self.phAssetCollection = phAssetCollection
    }

    func fetchAsset(detectedFaceId: Int, index: Int) -> PHAsset {
        let localAssetIdentifier = assetFaces[Int16(detectedFaceId)]![index].asset.localId
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
                    try context.fetch(AssetCollection.byLocalIdFetchRequest(localId: phAssetCollection.localIdentifier))
                let assetFaces = try context.fetch(AssetFaces.byAssetCollectionFetchRequest(assetCollection: assetCollection.first!))
                detectedFaceIds = Array(Set(assetFaces.map({$0.detectedFace.trackingId})))
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func updateAssetFaces(){
        let context = DBHelper.getViewContext()
        context.performAndWait {
            for detectedFaceId in detectedFaceIds {
                do {
                    let detectedFace = try context.fetch(DetectedFace.bytrackingIdFetchRequest(trackingId: detectedFaceId))
                    let fetchedAssetFaces = try context.fetch(AssetFaces.byDetectedFaceFetchRequest(detectedFace: detectedFace.first!))
                    assetFaces[detectedFaceId] = fetchedAssetFaces
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}
