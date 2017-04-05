//
//  GenericUDID.swift
//  SecurityBox
//
//  Created by JT Ma on 31/03/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import UIKit

extension UIDevice {
    
    public enum UDIDError: Error {
        case failedSave
        case failedRead
    }
    
    public func genericUDID() throws -> String {
        let item = PwdKeychain(service: KeychainConfiguration.serviceName, account: kGenericUDIDKey(), accessGroup: KeychainConfiguration.accessGroup)
        do {
            let udid = try item.readPassword()
            return udid
        } catch PwdKeychain.PwdKeychainError.noPassword {
            do {
                let idfv = identifierForVendor!.uuidString
                try item.savePassword(idfv)
                return idfv
            } catch {
                throw UDIDError.failedSave
            }
        } catch {
            throw UDIDError.failedRead
        }
    }
    
    private func kGenericUDIDKey() -> String {
        return "com.jt.security.kGenericUDIDKey"
    }
}
