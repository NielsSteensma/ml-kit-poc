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

    private static let TAG = "FaceDetectionRunner"
    private let serialOperationQueue: OperationQueue

    init() {
        serialOperationQueue = OperationQueue()
        serialOperationQueue.underlyingQueue = DispatchQueue.main
        serialOperationQueue.maxConcurrentOperationCount = 1
        serialOperationQueue.isSuspended = false
    }

    /**
     Runs face detection for all the top level PHAssetCollections of the user
     */
    func run(completion: @escaping () -> Void) {
        Logger.log(tag: FaceDetectionRunner.TAG, message: "Starting run for all users top level asset collections")
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        userCollections.enumerateObjects { [self] collection, index, stop in
            guard collection.canContainAssets else { return }
            guard let assetCollection = collection as? PHAssetCollection else { return }
            serialOperationQueue.addOperation(CollectionFaceDetectionOperation(for: assetCollection))
        }

        serialOperationQueue.addOperation {
            Logger.log(tag: FaceDetectionRunner.TAG, message: "Finished run for all users top level asset collections")
            completion()
        }
    }

    /**
     Runs face detection for the given asset collection
     */
    func run(for assetCollection: PHAssetCollection, completion: @escaping CompletionHandler) {
        Logger.log(tag: FaceDetectionRunner.TAG, message: "Starting run for asset collection: \(assetCollection.localizedTitle ?? "")")
        serialOperationQueue.addOperation(CollectionFaceDetectionOperation(for: assetCollection))
        serialOperationQueue.addOperation {
            Logger.log(tag: FaceDetectionRunner.TAG, message: "Finished run for asset collection: \(assetCollection.localizedTitle ?? "")")
            completion()
        }
    }
}
