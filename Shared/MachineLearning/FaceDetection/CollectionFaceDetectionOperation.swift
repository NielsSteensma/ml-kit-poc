//
//  CollectionFaceDetectionOperation.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 15/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Photos

/**
 Operation that detects and stores all faces in the given asset collection
 */
class CollectionFaceDetectionOperation: ConcurrentOperation {
    typealias CompletionHandler = () -> Void
    private static let TAG = "CollectionFaceDetectionOperation"
    private let phAssetCollection: PHAssetCollection
    private var assetCollection: AssetCollection!
    private let faceDetection = FaceDetection()
    private var assets = [PHAsset]()

    init(for phAssetCollection: PHAssetCollection) {
        self.phAssetCollection = phAssetCollection
    }

    override func start() {
        super.start()
        Logger.log(tag: CollectionFaceDetectionOperation.TAG,
                   message: "Start run for asset collection: \(phAssetCollection.localizedTitle ?? "")")

        createOrFetchAssetCollection(localId: phAssetCollection.localIdentifier) { collection in
            assetCollection = collection
            let fetchResult = PHAsset.fetchAssets(in: phAssetCollection, options: nil)

            guard fetchResult.count > 0 else {
                Logger.log(tag: CollectionFaceDetectionOperation.TAG,
                           message: "Finish run for empty asset collection: \(phAssetCollection.localizedTitle ?? "")")
                completeOperation()
                return
            }

            // Ugly, but it works for now.
            fetchResult.enumerateObjects { [self] asset, index, stop in
                assets.append(asset)
            }

            // Recursively go through each asset
            analyseAssetsRecursively()
        }
    }

    private func analyseAssetsRecursively() {
        guard let asset = assets.first else {
            Logger.log(tag: CollectionFaceDetectionOperation.TAG,
                       message: "Finish run for asset collection: \(phAssetCollection.localizedTitle ?? "")")
            completeOperation()
            return
        }

        assets.removeFirst()
        self.analyse(asset: asset, assetCollection: assetCollection) { [weak self] in
            guard let self = self else { fatalError("Recursion failed") }
            self.analyseAssetsRecursively()
        }
    }

    private func analyse(asset: PHAsset, assetCollection: AssetCollection, completion: @escaping CompletionHandler) {
        PHImageManager.default().requestImageForFaceDetection(for: asset) { [weak self] image in
            guard let self = self, let image = image else {
                return
            }

            let mlKitImage = MLKitImage(uiImage: image, asset: asset, assetCollection: assetCollection)
            self.faceDetection.detect(for: mlKitImage) { _ in
                completion()
            }
        }
    }

    private func createOrFetchAssetCollection(localId: String, completion: (_ assetCollection: AssetCollection) -> Void) {
        let context = DBHelper.getViewContext()
        do {
            let existingCollection = try context.fetchOne(AssetCollection.byLocalIdFetchRequest(localId: localId))

            if let assetCollection = existingCollection {
                Logger.log(tag: CollectionFaceDetectionOperation.TAG, message: "Found existing collection \(localId)")
                completion(assetCollection)
                return
            }

            let assetCollection = AssetCollection(context: context)
            assetCollection.localId = localId
            Logger.log(tag: CollectionFaceDetectionOperation.TAG, message: "Created collection \(localId)")
            completion(assetCollection)
            return
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}
