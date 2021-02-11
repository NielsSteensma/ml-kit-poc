//
//  DetectedFace.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 09/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import CoreData

/**
 Resembles a detected face.
 */
@objc(DetectedFace)
final class DetectedFace: NSManagedObject {
    @NSManaged var trackingId: Int16
    @NSManaged var assetFaces: Set<AssetFaces>

    static var batchDeleteRequest: NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: DetectedFace.fetchRequest())
    }

    static func bytrackingIdFetchRequest(trackingId: Int16) -> NSFetchRequest<DetectedFace> {
        let fetchRequest = DetectedFace.fetchRequest() as! NSFetchRequest<DetectedFace>
        fetchRequest.predicate = NSPredicate(format: "trackingId == %d", Int16(trackingId))
        return fetchRequest
    }
}
