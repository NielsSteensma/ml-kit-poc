//
//  DetectedFaceAssetsViewModel.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 13/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Photos

class DetectedFaceAssetsViewModel {
    private(set) var assets: [AssetFaces]?

    func loadData(for detectedFace: DetectedFace) {
        let context = DBHelper.getViewContext()
        do {
            assets = try context.fetch(AssetFaces.byDetectedFaceFetchRequest(detectedFace: detectedFace))
        } catch{
            fatalError(error.localizedDescription)
        }
    }

    func fetchAsset(localIdentifier: String) -> PHAsset {
        let fetchedAssets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        return fetchedAssets.firstObject!
    }
}
