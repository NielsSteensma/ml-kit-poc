//
//  ConcurrentOperation.swift
//  MLKitPoc iOS
//
//  Created by Niels Steensma on 15/02/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation

/**
 Subclass to make it easier to perform manual state handling of a NSOperation
 */
class ConcurrentOperation : Operation {
    private var _isExecuting = false
    override var isExecuting: Bool {
        get { return _isExecuting }
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished = false
    override var isFinished: Bool {
        get { return _isFinished }
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    override func start() {
        guard !isCancelled else { return }
        // Do not call super here, we want to maintain state ourselves
        isExecuting = true
    }

    func completeOperation() {
        isExecuting = false
        isFinished = true
    }
}
