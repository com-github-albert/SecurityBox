//
//  GenericTouchID.swift
//  SecurityBox
//
//  Created by JT Ma on 17/05/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import Foundation
import LocalAuthentication

public struct GenericTouchID {
    
    private let context = LAContext()
    let localozedReasionString = "Logging in with Touch ID"
    
    public func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    public func authenticate(completion: @escaping (String?) -> Void) {
        guard canEvaluatePolicy() else {
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: localozedReasionString) { (success, error) in
                                if success {
                                    DispatchQueue.main.async {
                                        completion(nil)
                                    }
                                } else {
                                    let message: String
                                    
                                    switch error {
                                    case LAError.authenticationFailed?:
                                        message = "There was a problem verifying your identity."
                                    case LAError.userCancel?:
                                        message = "You pressed cancel."
                                    case LAError.userFallback?:
                                        message = "You pressed password."
                                    default:
                                        message = "Touch ID may not be configured"
                                    }
                                    
                                    completion(message)
                                }
        }
    }
}
