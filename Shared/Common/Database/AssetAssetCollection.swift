//
//  AssetAssetCollection.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 09/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import CoreData

/**
 Resembles a photo asset inside an asset collection.
 */
class AssetAssetCollection: NSManagedObject {
    @NSManaged var asset: Asset
    @NSManaged var assetCollection: AssetCollection

    static var batchDeleteRequest: NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: AssetAssetCollection.fetchRequest())
    }
}
