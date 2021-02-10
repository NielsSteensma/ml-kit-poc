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

    static var batchDeleteRequest: NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: AssetCollection.fetchRequest())
    }

    static func byLocalIdFetchRequest(localId: String) -> NSFetchRequest<AssetCollection> {
        let fetchRequest = AssetCollection.fetchRequest() as! NSFetchRequest<AssetCollection>
        fetchRequest.predicate = NSPredicate(format: "localId == %@", localId)
        return fetchRequest
    }
}
