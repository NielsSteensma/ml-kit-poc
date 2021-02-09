//
//  DBHelper.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 08/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import CoreData

/**
 Provides a set of convenient methods for working with the database.
 */
class DBHelper {
    static func getViewContext() -> NSManagedObjectContext {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        return delegate.persistentContainer.viewContext
    }
}
