//
//  Logger.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 05/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

class Logger {
    /**
        Prints a message to the console in the format tag: message
     */
    static func log(tag: String, message: String) {
        print("\(tag): \(message)")
    }
}
