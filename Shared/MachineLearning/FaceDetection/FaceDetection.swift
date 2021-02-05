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
    private let faceDetector: FaceDetector
    private static let TAG = "FaceDetection"

    init() {
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.isTrackingEnabled = true
        self.faceDetector = FaceDetector.faceDetector(options: options)
    }

    struct Results {
        let amountOfFaces: Int
        let trackingIds: [Int]
    }

    func detect(for image: MLKitImage, completion: @escaping (_ results: Results) -> Void) {
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
            completion(results)
        }
    }

    private func processResults(faces: [Face]?) -> Results {
        return Results(amountOfFaces: faces?.count ?? 0,
                       trackingIds: faces?.map{ $0.trackingID } ?? [])
    }

    private func saveInDB(mlKitImage: MLKitImage, results: Results) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let context = delegate.persistentContainer.viewContext

        // Check if we already did perform an analysis for this asset
        var foundAssets: [NSManagedObject]?
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Asset")
        fetchRequest.predicate = NSPredicate(format: "localId == %@", mlKitImage.asset.localIdentifier)
        do {
            foundAssets = try context.fetch(fetchRequest)
        } catch {
            Logger.log(tag: FaceDetection.TAG, message: "Error while checking if asset already exists")
        }

        guard foundAssets!.isEmpty else {
            Logger.log(tag: FaceDetection.TAG, message: "Found existing asset data")
            return
        }

        // Insert the results for the asset
        let asset = NSEntityDescription.insertNewObject(forEntityName: "Asset", into: context)
        asset.setValue(mlKitImage.asset.localIdentifier, forKey: "localId")
        asset.setValue(results.amountOfFaces, forKey: "amountOfFaces")
        if !results.trackingIds.isEmpty {
            // For now just insert the first found faceId
            asset.setValue(results.trackingIds[0], forKey: "faceId")
        }

        do {
            try context.save()
        } catch {
            Logger.log(tag: FaceDetection.TAG, message: "Error while saving asset")
        }
    }
}
