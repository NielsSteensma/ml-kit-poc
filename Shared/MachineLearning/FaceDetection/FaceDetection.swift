//
//  FaceDetector.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 04/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import MLKit
import MLKitFaceDetection
import CoreData

/**
  Algorithm that runs MLKit on the given picture and returns all faces that were detected.
 */
class FaceDetection {
    typealias FaceDetectionResultsHandler = ((_ results: Result) -> Void)
    private let faceDetector: FaceDetector
    private static let TAG = "FaceDetection"

    struct Result {
        let amountOfFaces: Int
        let trackingIds: [Int]
    }

    init() {
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.isTrackingEnabled = true
        self.faceDetector = FaceDetector.faceDetector(options: options)
    }

    func detect(for image: MLKitImage, dispatchGroup: DispatchGroup) {
        Logger.log(tag: FaceDetection.TAG,
                   message: "start for image \(image.asset.localIdentifier) " +
                            "with dimensions of \(image.uiImage.size)")
        let visionImage = VisionImage(image: image.uiImage)
        visionImage.orientation = image.uiImage.imageOrientation

        faceDetector.process(visionImage) { [weak self] faces, error in
            guard let sSelf = self else {
                return
            }

            guard error == nil else {
                Logger.log(tag: FaceDetection.TAG, message: "Error while detecting faces")
                return
            }

            let results = sSelf.processResults(faces: faces)
            sSelf.storeResults(mlKitImage: image, results: results)
            dispatchGroup.leave()
        }
    }

    private func processResults(faces: [Face]?) -> Result {
        return Result(amountOfFaces: faces?.count ?? 0,
                       trackingIds: faces?.map{ $0.trackingID } ?? [])
    }

    private func storeResults(mlKitImage: MLKitImage, results: Result) {
        let context = DBHelper.getViewContext()
        let asset = saveAssetInDB(mlKitImage: mlKitImage,
                                  results: results,
                                  context: context)
        saveDetectedFaceTrackingIds(asset: asset,
                                    mlKitImage: mlKitImage,
                                    trackingIds: results.trackingIds,
                                    context: context)
    }

    private func saveAssetInDB(mlKitImage: MLKitImage, results: Result, context: NSManagedObjectContext) -> Asset {
        var createdAsset: Asset?
        context.performAndWait {
            do {
                // Save asset
                let asset = Asset(context: context)
                asset.localId = mlKitImage.asset.localIdentifier
                asset.amountOfFaces = Int16(results.amountOfFaces)
                if !results.trackingIds.isEmpty {
                    // For now just insert the first found faceId
                    asset.faceId = Int16(results.trackingIds[0])
                }

                // Associate asset with asset collection
                let assetAssetCollection = AssetAssetCollection(context: context)
                assetAssetCollection.asset = asset
                assetAssetCollection.assetCollection = mlKitImage.assetCollection
                try context.save()
                createdAsset = asset
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        return createdAsset!
    }

    private func saveDetectedFaceTrackingIds(asset: Asset, mlKitImage: MLKitImage, trackingIds: [Int], context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                // Create each detected face if it doesn't yet exist
                for trackingId in trackingIds {
                    let detectedFaces = try context.fetch(DetectedFace.bytrackingIdFetchRequest(trackingId: Int16(trackingId)))
                    if detectedFaces.isEmpty {
                        let detectedFace = DetectedFace(context: context)
                        detectedFace.trackingId = Int16(trackingId)
                        try context.save()
                    }
                }

                // Associate each detected face with the asset and collection
                for trackingId in trackingIds {
                    let detectedFaces = try context.fetch(DetectedFace.bytrackingIdFetchRequest(trackingId: Int16(trackingId)))

                    let assetFaces = AssetFaces(context: context)
                    assetFaces.asset = asset
                    assetFaces.assetCollection = mlKitImage.assetCollection
                    assetFaces.detectedFace = detectedFaces.first!
                }
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
