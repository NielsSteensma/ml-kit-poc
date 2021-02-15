//
//  MainMenuViewModel.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 14/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

/**
 Viewmodel associated with the main menu.
 */
class MainMenuViewModel {

    func runFaceClusteringForAllAlbums(completionHandler: @escaping () -> Void) {
        FaceDetectionRunner.instance.runForAll(completion: completionHandler)
    }

    func cleanDatabase(succesHandler: () -> Void) {
        let context = DBHelper.getViewContext()
        context.performAndWait {
            do{
                try context.execute(Asset.batchDeleteRequest)
                try context.execute(DetectedFace.batchDeleteRequest)
                try context.execute(AssetCollection.batchDeleteRequest)
                try context.execute(AssetAssetCollection.batchDeleteRequest)
                try context.execute(AssetFaces.batchDeleteRequest)
                try context.save()
                succesHandler()

            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
