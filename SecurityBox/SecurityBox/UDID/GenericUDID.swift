//
//  GenericUDID.swift
//  SecurityBox
//
//  Created by JT Ma on 31/03/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import UIKit

extension UIDevice {
    
    public func genericUDID() -> String {
        let item = Keychain(service: KeychainConfiguration.serviceName, account: kGenericUDIDKey(), accessGroup: KeychainConfiguration.accessGroup)
        do {
            let udid = try item.readPassword()
            return udid
        } catch Keychain.KeychainError.noPassword {
            do {
                let idfv = identifierForVendor!.uuidString
                try item.savePassword(idfv)
                return idfv
            } catch {
                fatalError("Error fetching save password - \(error)")
            }
        } catch {
            fatalError("Error fetching read password - \(error)")
        }
    }
    
    private func kGenericUDIDKey() -> String {
        return "com.jt.security.kGenericUDIDKey"
    }
}
