//
//  FaceDetectionRunner.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 05/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Photos
import UIKit
import CoreData
import Dispatch

class FaceDetectionRunner {
    typealias CompletionHandler = () -> Void
    public static let instance = FaceDetectionRunner()
    private let faceDetection = FaceDetection()
    private static let DISPATCH_QUEUE_LABEL = "com.mlkitpoc.analysis"
    private static let TAG = "FaceDetectionRunner"

    private init() {}

    func run(for collection: PHAssetCollection, completion: @escaping CompletionHandler) {
        Logger.log(tag: FaceDetectionRunner.TAG, message: "Start for collection \(collection.localizedTitle ?? "")")
        cleanupOldAnalysisData()
        let assetCollection = createAssetCollectionIfNotExists(localId: collection.localIdentifier)

        let assets = PHAsset.fetchAssets(in: collection, options: nil)

        // Run the analysis on a serial queue so we get most accurate face tracking results.
        let serialQueue = DispatchQueue(label: FaceDetectionRunner.DISPATCH_QUEUE_LABEL)
        for i in 0..<assets.count {
            serialQueue.async {
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                self.analyse(asset: assets[i],
                             assetCollection: assetCollection,
                             dispatchGroup: dispatchGroup)

                // If we processed last asset we want to invoke the completionhandler
                if i == assets.count - 1 {
                    completion()
                }
            }
        }
    }

    private func analyse(asset: PHAsset, assetCollection: AssetCollection, dispatchGroup: DispatchGroup) {
        PHImageManager.default().requestImageForFaceDetection(for: asset) { [weak self] image in
            guard let self = self, let image = image else {
                return
            }

            let mlKitImage = MLKitImage(uiImage: image, asset: asset, assetCollection: assetCollection)
            self.faceDetection.detect(for: mlKitImage, dispatchGroup: dispatchGroup)
        }

        dispatchGroup.wait()
    }

    private func createAssetCollectionIfNotExists(localId: String) -> AssetCollection {
        var assetCollection: AssetCollection?
        let context = DBHelper.getViewContext()
        context.performAndWait {
            do {
                let foundCollections = try context.fetchOne(AssetCollection.byLocalIdFetchRequest(localId: localId))
                if foundCollections == nil {
                    assetCollection = AssetCollection(context: context)
                    assetCollection!.localId = localId
                }
                else {
                    assetCollection = foundCollections
                }
                try context.save()
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }

        return assetCollection!
    }

    private func cleanupOldAnalysisData() {
        let context = DBHelper.getViewContext()
        context.performAndWait {
            do{
                try context.execute(Asset.batchDeleteRequest)
                try context.execute(DetectedFace.batchDeleteRequest)
                try context.execute(AssetCollection.batchDeleteRequest)
                try context.execute(AssetAssetCollection.batchDeleteRequest)
                try context.execute(AssetFaces.batchDeleteRequest)
                try context.save()
                Logger.log(tag: FaceDetectionRunner.TAG, message: "Cleaning database")
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

}
