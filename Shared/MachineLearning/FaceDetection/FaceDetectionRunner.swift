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
    // Run the analysis on a serial queue so we get most accurate face tracking results.
    private let serialQueue = DispatchQueue(label: "com.mlkitpoc.analysis")
    private var dispatchGroup: DispatchGroup!
    private static let TAG = "FaceDetectionRunner"

    private init() {}

    func runForAll(completion: @escaping () -> Void) {
        dispatchGroup = DispatchGroup()
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        userCollections.enumerateObjects { [self] collection, index, stop in
            guard collection.canContainAssets else { return }
            serialQueue.sync {
                self.run(for: collection as! PHAssetCollection) {
                }
                serialQueue.sy
            }
        }
        
        dispatchGroup.notify(queue: serialQueue) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func runForCollection(collection: PHAssetCollection, completion: @escaping CompletionHandler) {
        dispatchGroup = DispatchGroup()
        // First clean all existing data for the collection.
        let context = DBHelper.getViewContext()
        context.performAndWait {
            do{
                try context.execute(AssetCollection.byLocalIdFetchRequest(localId: collection.localIdentifier))
                try context.save()

            } catch {
                fatalError(error.localizedDescription)
            }
        }

        run(for: collection, completion: completion)
        dispatchGroup.notify(queue: serialQueue){
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    private func run(for collection: PHAssetCollection, completion: @escaping CompletionHandler) {
        serialQueue.sync {
        Logger.log(tag: FaceDetectionRunner.TAG, message: "Start for collection \(collection.localizedTitle ?? "")")
        let assets = PHAsset.fetchAssets(in: collection, options: nil)

        guard assets.count > 0 else {
            Logger.log(tag: FaceDetectionRunner.TAG, message: "Finish for collection \(collection.localizedTitle ?? "")")
            completion()
            return
        }

        createAssetCollectionIfNotExists(localId: collection.localIdentifier) { [weak self] assetCollection in
            for i in 0..<assets.count {
                self?.analyse(asset: assets[i], assetCollection: assetCollection){}

                // If we processed last asset we want to invoke the completion handler
                if i == assets.count - 1 {
                    Logger.log(tag: FaceDetectionRunner.TAG, message: "Finish for collection \(collection.localizedTitle ?? "")")
                    completion()
                }
            }
        }
        }}

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

    private func createAssetCollectionIfNotExists(localId: String, completion: (_ assetCollection: AssetCollection) -> Void) {
        let context = DBHelper.getViewContext()
        do {
            var assetCollection: AssetCollection?
            let foundCollections = try context.fetchOne(AssetCollection.byLocalIdFetchRequest(localId: localId))
            if foundCollections == nil {
                assetCollection = AssetCollection(context: context)
                assetCollection!.localId = localId
                Logger.log(tag: FaceDetectionRunner.TAG, message: "Created collection \(localId)")
            }
            else {
                assetCollection = foundCollections
                Logger.log(tag: FaceDetectionRunner.TAG, message: "Found existing collection \(localId)")
            }
            try context.save()
            completion(assetCollection!)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}
