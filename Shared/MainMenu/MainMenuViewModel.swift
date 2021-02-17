//
//  MainMenuViewModel.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 14/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import CoreData

/**
 Viewmodel associated with the main menu.
 */
class MainMenuViewModel {
    private let faceDetectionRunner = FaceDetectionRunner()

    func runFaceClusteringForAllAlbums(completion: @escaping () -> Void) {
        faceDetectionRunner.run() {
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func cleanDatabase(succesHandler: () -> Void) {
        let context = DBHelper.getViewContext()
        context.performAndWait {
            do {
                try context.executeAndMergeChanges(using: AssetFaces.batchDeleteRequest)
                try context.executeAndMergeChanges(using: AssetCollection.batchDeleteRequest)
                try context.executeAndMergeChanges(using: DetectedFace.batchDeleteRequest)
                try context.executeAndMergeChanges(using: Asset.batchDeleteRequest)
                context.reset()
                succesHandler()

            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    /**
    func cleanDatabase(succesHandler: () -> Void) {
        do
        let context = DBHelper.getViewContext()
        let coordinator = context.persistentStoreCoordinator
        let currentStore = coordinator?.persistentStores.last!
        let currentStoreUrl = currentStore!.url!
        do {
            try coordinator?.destroyPersistentStore(at: currentStoreUrl, ofType: NSSQLiteStoreType)
            try coordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: currentStoreUrl)
            context.reset()
            succesHandler()
        } catch {
            fatalError(error.localizedDescription)
        }

        /**context.performAndWait {
            do {
                // ToDo: use a batch delete approach here
                deleteAllData(entityName: "AssetFaces")
                deleteAllData(entityName: "AssetCollection")
                deleteAllData(entityName: "DetectedFace")
                deleteAllData(entityName: "Asset")
                succesHandler()

            } catch {
                fatalError(error.localizedDescription)
            }
        }**/
    }**/

    private func deleteAllData(entityName: String) {
        let context = DBHelper.getViewContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let data = try context.fetch(fetchRequest)
            for object in data as! [NSManagedObject] {
                context.delete(object)
            }
            try context.save()
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}
