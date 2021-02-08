//
//  FaceDetectionRunner.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 05/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import Photos
import UIKit
import CoreData

class FaceDetectionRunner {
    typealias CompletionHandler = () -> Void
    private let faceDetection = FaceDetection()
    private static let TAG = "FaceDetectionRunner"

    func run(for collection: PHAssetCollection, completion: @escaping CompletionHandler) {
        Logger.log(tag: FaceDetectionRunner.TAG, message: "Start for collection \(collection.localizedTitle ?? "")")
        cleanupOldAnalysisData()
        self.analyze(collection: collection, completion: completion)
    }

    private func analyze(collection: PHAssetCollection, completion: @escaping CompletionHandler) {
        let assets = PHAsset.fetchAssets(in: collection, options: nil)

        for i in 0..<assets.count {
            let asset = assets[i]
            PHImageManager.default().requestImageForFaceDetection(for: asset) { [weak self] image in
                guard let self = self, let image = image else {
                    if i == assets.count - 1 {
                        // Make sure to call completion handler for last processed image
                        completion()
                    }
                    return
                }

                let mlKitImage = MLKitImage(uiImage: image, asset: asset)
                self.faceDetection.detect(for: mlKitImage) { _ in
                    // Make sure to call completion handler for last processed image
                    if i == assets.count - 1 {
                        completion()
                    }
                }
            }
        }
    }

    private func cleanupOldAnalysisData() {
        let context = DBHelper.getViewContext()
        context.performAndWait {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Asset")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do{
                try context.execute(deleteRequest)
                try context.save()
                Logger.log(tag: FaceDetectionRunner.TAG, message: "Cleaning database")
            } catch {
                print(error)
            }
        }
    }
}
