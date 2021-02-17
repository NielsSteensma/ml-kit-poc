//
//  AssetCollection.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 09/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import CoreData

/**
 Resembles a collection of photo assets.
 */
class AssetCollection: NSManagedObject {
    @NSManaged var localId: String
    @NSManaged var name: String
    @NSManaged var assetFaces: Set<AssetFaces>
    @NSManaged var assets: Set<Asset>

    static var batchDeleteRequest: NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: AssetCollection.fetchRequest())
    }

    static func batchDeleteSingleCollectionRequest(for collection: AssetCollection) -> NSBatchDeleteRequest {
        let fetchRequest = AssetCollection.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "localId", collection.localId)
        return NSBatchDeleteRequest(fetchRequest: fetchRequest)
    }

    static func byLocalIdFetchRequest(localId: String) -> NSFetchRequest<AssetCollection> {
        let fetchRequest = AssetCollection.fetchRequest() as! NSFetchRequest<AssetCollection>
        fetchRequest.predicate = NSPredicate(format: "localId == %@", localId)
        return fetchRequest
    }
}
