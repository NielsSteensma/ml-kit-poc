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
  Algorithm that runs MLKit for the given asset and saves all detected faces.
 */
class AssetFaceDetection {
    typealias FaceDetectionResultsHandler = ((Int) -> Void)
    private static let TAG = "FaceDetection"
    private var completion: FaceDetectionResultsHandler?

    struct Result {
        let amountOfFaces: Int
        let faces: [Face]
    }

    func detect(for image: MLKitImage, completion: FaceDetectionResultsHandler?) {
        Logger.log(tag: AssetFaceDetection.TAG,
                   message: "start for image \(image.asset.localIdentifier) with dimensions of \(image.uiImage.size)")
        self.completion = completion

        createAsset(mlKitImage: image) { [weak self] asset in
            guard let self = self else {
                return
            }

            self.analyze(mlKitImage: image, asset: asset)
        }
    }

    private func analyze(mlKitImage: MLKitImage, asset: Asset) {
        let visionImage = VisionImage(image: mlKitImage.uiImage)
        visionImage.orientation = mlKitImage.uiImage.imageOrientation

        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get FaceDetector")
        }

        delegate.faceDetector.process(visionImage) { [weak self] faces, error in
            guard let self = self else {
                fatalError("")
            }

            guard let faces = faces, faces.isEmpty == false else {
                Logger.log(tag: AssetFaceDetection.TAG, message: "No faces found")
                self.completion?(0)
                return
            }

            guard error == nil else {
                Logger.log(tag: AssetFaceDetection.TAG, message: "Error while detecting faces")
                return
            }
            Logger.log(tag: AssetFaceDetection.TAG, message: "\(faces.count) faces found")

            self.saveDetectedFaces(asset: asset, mlKitImage: mlKitImage, faces: faces) {
                self.completion?(visionImage.orientation == UIImage.Orientation.up ? 1 : 0)
            }
        }
    }


    private func createAsset(mlKitImage: MLKitImage, completionHandler: (Asset) -> Void) {
        let context = DBHelper.getViewContext()
        context.performAndWait {
            do {
                let asset = Asset(context: context)
                asset.localId = mlKitImage.asset.localIdentifier
                asset.assetCollection = mlKitImage.assetCollection
                try context.save()
                completionHandler(asset)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    private func saveDetectedFaces(asset: Asset, mlKitImage: MLKitImage, faces: [Face], completion: () -> Void) {
        let context = DBHelper.getViewContext()
        context.performAndWait {
            do {
                for face in faces {
                    // Create detected face if it doesn't yet exist
                    var detectedFace = try context.fetch(DetectedFace.byFaceIdFetchRequest(faceId: Int16(face.trackingID))).first
                    print("Detected face: \(face.trackingID) in \(mlKitImage.assetCollection.name)")
                    if detectedFace == nil {
                        let newDetectedFace = DetectedFace(context: context)
                        newDetectedFace.faceId = Int16(face.trackingID)
                        // Crop the face from the image
                        let croppedFace = UIImage(cgImage: mlKitImage.uiImage.cgImage!.cropping(to: face.frame)!)

                        // Save the cropped face in db ( not great )
                        newDetectedFace.imageJpegData = croppedFace.jpegData(compressionQuality: 1.0)!
                        try context.save()
                        detectedFace = newDetectedFace
                    }

                    // Associate the detected face with the asset
                    let assetFaces = AssetFaces(context: context)
                    assetFaces.asset = asset
                    assetFaces.assetCollection = mlKitImage.assetCollection
                    assetFaces.detectedFace = detectedFace!
                    try context.save()
                }
            } catch {
                fatalError(error.localizedDescription)
            }
            completion()
        }
    }
}
