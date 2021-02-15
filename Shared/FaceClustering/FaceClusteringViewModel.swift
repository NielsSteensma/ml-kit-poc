//
//  FaceClusteringViewModel.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 11/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Photos
import UIKit

/**
 Viewmodel associated with the face clustering grid.
 */
class FaceClusteringViewModel {
    private(set) var detectedFaceIds: [Int16] = []
    private(set) var assetFaces: [Int16: [AssetFaces]] = [:]
    var phAssetCollection: PHAssetCollection
    private let faceDetectionRunner = FaceDetectionRunner()

    init(phAssetCollection: PHAssetCollection) {
        self.phAssetCollection = phAssetCollection
    }

    func runFaceDetection(completion: @escaping () -> Void) {
        faceDetectionRunner.run(for: phAssetCollection) { [weak self] in
            self?.loadData()
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func fetchFaceImage(trackingId: Int16) -> UIImage {
        let context = DBHelper.getViewContext()
        do {
            let detectedFace = try context.fetchOne(DetectedFace.bytrackingIdFetchRequest(trackingId: trackingId))
            return UIImage(data: detectedFace!.imageJpegData)!
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchAsset(for faceId: Int16, index: Int) -> PHAsset {
        let localAssetIdentifier = assetFaces[faceId]![index].asset.localId
        let fetchedAssets = PHAsset.fetchAssets(withLocalIdentifiers: [localAssetIdentifier], options: nil)
        return fetchedAssets.firstObject!
    }

    func loadData() {
        let context = DBHelper.getViewContext()
        do {
            // Load the collection
            let assetCollectionFetchRequest = AssetCollection.byLocalIdFetchRequest(localId: phAssetCollection.localIdentifier)
            guard let assetCollection = try context.fetchOne(assetCollectionFetchRequest) else {
                return
            }

            // Set all unique face ids found for the collection
            detectedFaceIds = Array(Set(assetCollection.assetFaces.map({$0.detectedFace.trackingId})))

            // For each face id fetch the assets of the collection
            for detectedFaceId in detectedFaceIds {
                let detectedFace = try context.fetchOne(DetectedFace.bytrackingIdFetchRequest(trackingId: detectedFaceId))!
                assetFaces[detectedFaceId] = Array(detectedFace.assetFaces)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
