//
//  DetectedFacesViewModel.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 13/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

/**
 Viewmodel associated with the detected face grid.
 */
class DetectedFacesViewModel {
    private(set) var detectedFaces: [DetectedFace]!

    func loadData() {
        let context = DBHelper.getViewContext()
        do {
            detectedFaces = try context.fetch(DetectedFace.fetchRequest()) as? [DetectedFace]
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
