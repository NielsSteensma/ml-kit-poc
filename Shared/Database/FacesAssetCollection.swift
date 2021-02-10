//
//  FacesAssetCollection.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 09/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import CoreData

/**
 Resembles a face nside an asset collection.
 */
class FacesAssetCollection: NSManagedObject {
    @NSManaged var detectedFace: DetectedFace
    @NSManaged var assetCollection: AssetCollection

    static var batchDeleteRequest: NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: FacesAssetCollection.fetchRequest())
    }
}
