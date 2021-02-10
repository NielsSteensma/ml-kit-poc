//
//  AssetFaces.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 09/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import CoreData

class AssetFaces: NSManagedObject {
    @NSManaged var asset: Asset
    @NSManaged var detectedFace: DetectedFace
    @NSManaged var assetCollection: AssetCollection

    static var batchDeleteRequest: NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: AssetFaces.fetchRequest())
    }

    static func byAssetCollectionFetchRequest(assetCollection: AssetCollection) -> NSFetchRequest<AssetFaces> {
        let fetchRequest = AssetFaces.fetchRequest() as! NSFetchRequest<AssetFaces>
        fetchRequest.predicate = NSPredicate(format: "assetCollection == %@", assetCollection)
        return fetchRequest
    }

    static func byDetectedFaceFetchRequest(detectedFace: DetectedFace) -> NSFetchRequest<AssetFaces> {
        let fetchRequest = AssetFaces.fetchRequest() as! NSFetchRequest<AssetFaces>
        fetchRequest.predicate = NSPredicate(format: "detectedFace == %@", detectedFace)
        return fetchRequest
    }
}