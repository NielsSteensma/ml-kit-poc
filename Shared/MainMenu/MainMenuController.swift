//
//  MainMenuController.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 14/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

/**
 Shows the main menu of the app.
 */
class MainMenuController: UIViewController {

    @IBAction func onUserWantsToCleanData(_ sender: Any) {
        // Verify the delete
        let confirmationAlertController = UIAlertController(title: "Confirmation",
                                                            message: "Do you really want to clean the database?",
                                                            preferredStyle: .alert)
        confirmationAlertController.addAction(UIAlertAction(title: "No", style: .cancel))
        confirmationAlertController.addAction(UIAlertAction(title: "Yes", style: .destructive){ [weak self] _ in
            self?.cleanDatabase()
        })
        present(confirmationAlertController, animated: false)
    }

    private func cleanDatabase() {
        let context = DBHelper.getViewContext()
        context.performAndWait {
            do{
                try context.execute(Asset.batchDeleteRequest)
                try context.execute(DetectedFace.batchDeleteRequest)
                try context.execute(AssetCollection.batchDeleteRequest)
                try context.execute(AssetAssetCollection.batchDeleteRequest)
                try context.execute(AssetFaces.batchDeleteRequest)
                try context.save()

                // Show succes
                let succesAlertController = UIAlertController(title: "Succes!",
                                                              message: "The database was cleaned",
                                                              preferredStyle: .alert)
                succesAlertController.addAction(UIAlertAction(title: "Okay", style: .default))
                present(succesAlertController, animated: false)

            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
