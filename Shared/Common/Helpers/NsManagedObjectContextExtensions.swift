//
//  NsManagedObjectContextExtensions.swift
//  MLKitPoc
//
//  Created by Niels Steensma on 11/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    /*
     Executes the given fetch request and returns the first found record.
     */
    func fetchOne<T>(_ request: NSFetchRequest<T>) throws -> T? where T : NSFetchRequestResult {
        try self.fetch(request).first
    }
}
