//
//  Asset.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 09/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import CoreData

/**
 Resembles a photo asset.
 */
@objc(Asset)
final class Asset: NSManagedObject {
    @NSManaged var localId: String
    @NSManaged var amountOfFaces: Int16
    @NSManaged var faceId: Int16

    static var batchDeleteRequest: NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: Asset.fetchRequest())
    }
    
    static func byLocalAssetIdFetchRequest(localAssetId: String) -> NSFetchRequest<Asset> {
        let fetchRequest = Asset.fetchRequest() as! NSFetchRequest<Asset>
        fetchRequest.predicate = NSPredicate(format: "localId == %@", localAssetId)
        return fetchRequest
    }
}
