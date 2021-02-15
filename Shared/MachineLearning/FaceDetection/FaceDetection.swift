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
    private static let TAG = "FaceDetection"

    struct Result {
        let amountOfFaces: Int
        let faces: [Face]
    }

    func detect(for image: MLKitImage, completion: FaceDetectionResultsHandler?) {
        Logger.log(tag: FaceDetection.TAG,
                   message: "start for image \(image.asset.localIdentifier) with dimensions of \(image.uiImage.size)")
        let visionImage = VisionImage(image: image.uiImage)
        visionImage.orientation = image.uiImage.imageOrientation


        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get FaceDetector")
        }

        delegate.faceDetector.process(visionImage) { [weak self] faces, error in
            guard let self = self else {
                return
            }

            guard error == nil else {
                Logger.log(tag: FaceDetection.TAG, message: "Error while detecting faces")
                return
            }

            let results = self.processResults(image: image.uiImage, faces: faces)
            self.storeResults(mlKitImage: image, results: results)
            completion?(results)
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
                    var detectedFace = try context.fetch(DetectedFace.bytrackingIdFetchRequest(trackingId: Int16(face.trackingID))).first
                    if detectedFace == nil {
                        detectedFace = DetectedFace(context: context)
                        detectedFace!.trackingId = Int16(face.trackingID)
                        print("faceId \(detectedFace!.trackingId)")
                        // Crop the face from the image
                        let croppedFace = UIImage(cgImage: mlKitImage.uiImage.cgImage!.cropping(to: face.frame)!)

                        // Save the cropped face in db ( not great )
                        detectedFace!.imageJpegData = croppedFace.jpegData(compressionQuality: 1.0)!
                    } else {

                    }

                    let assetFaces = AssetFaces(context: context)
                    assetFaces.asset = asset
                    assetFaces.assetCollection = mlKitImage.assetCollection
                    assetFaces.detectedFace = detectedFace!
                    try context.save()

                }

            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
