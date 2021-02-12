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
        let faces: [Face]
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

            let results = sSelf.processResults(image: image.uiImage, faces: faces)
            sSelf.storeResults(mlKitImage: image, results: results)
            dispatchGroup.leave()
        }
    }

    private func processResults(image: UIImage, faces: [Face]?) -> Result {
        return Result(amountOfFaces: faces?.count ?? 0, faces: faces!)
    }

    private func storeResults(mlKitImage: MLKitImage, results: Result) {
        let context = DBHelper.getViewContext()
        let asset = saveAssetInDB(mlKitImage: mlKitImage,
                                  results: results,
                                  context: context)
        saveDetectedFaceTrackingIds(asset: asset,
                                    mlKitImage: mlKitImage,
                                    result: results,
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

    private func saveDetectedFaceTrackingIds(asset: Asset, mlKitImage: MLKitImage, result: Result, context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                // Create each detected face if it doesn't yet exist
                for face in result.faces {
                    let detectedFaces = try context.fetch(DetectedFace.bytrackingIdFetchRequest(trackingId: Int16(face.trackingID)))
                    if detectedFaces.isEmpty {
                        let detectedFace = DetectedFace(context: context)
                        detectedFace.trackingId = Int16(face.trackingID)

                        // Crop the face from the image
                        let croppedFace = UIImage(cgImage: mlKitImage.uiImage.cgImage!.cropping(to: face.frame)!)

                        // Save the cropped face in db ( not great )
                        detectedFace.image = croppedFace.jpegData(compressionQuality: 1.0)!
                        try context.save()
                    }
                }

                // Associate each detected face with the asset and collection
                for face in result.faces {
                    let detectedFace = try context.fetchOne(DetectedFace.bytrackingIdFetchRequest(trackingId: Int16(face.trackingID)))

                    let assetFaces = AssetFaces(context: context)
                    assetFaces.asset = asset
                    assetFaces.assetCollection = mlKitImage.assetCollection
                    assetFaces.detectedFace = detectedFace!
                }
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
