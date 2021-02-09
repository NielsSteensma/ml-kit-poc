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
            sSelf.saveInDB(mlKitImage: image, results: results)
            dispatchGroup.leave()
        }
    }

    private func processResults(faces: [Face]?) -> Result {
        return Result(amountOfFaces: faces?.count ?? 0,
                       trackingIds: faces?.map{ $0.trackingID } ?? [])
    }

    private func saveInDB(mlKitImage: MLKitImage, results: Result) {
        let context = DBHelper.getViewContext()

        context.performAndWait {
            let asset = Asset(context: context)
            asset.localId = mlKitImage.asset.localIdentifier
            asset.amountOfFaces = Int16(results.amountOfFaces)
            if !results.trackingIds.isEmpty {
                // For now just insert the first found faceId
                asset.faceId = Int16(results.trackingIds[0])
            }

            do {
                try context.save()
                Logger.log(tag: FaceDetection.TAG, message: "Inserting analysis data")
            } catch {
                Logger.log(tag: FaceDetection.TAG, message: "Error while inserting analysis data")
            }
        }
    }
}
