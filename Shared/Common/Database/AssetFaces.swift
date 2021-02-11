//
//  AssetFaces.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 09/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import CoreData

/**
 Resembles a detected face in an asset in a specific asset collection.
 */
class AssetFaces: NSManagedObject {
    @NSManaged var asset: Asset
    @NSManaged var detectedFace: DetectedFace
    @NSManaged var assetCollection: AssetCollection

    static var batchDeleteRequest: NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: AssetFaces.fetchRequest())
    }
}
