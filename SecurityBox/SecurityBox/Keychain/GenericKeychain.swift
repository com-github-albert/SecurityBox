//
//  GenericKeychain.swift
//  SecurityBox
//
//  Created by JT Ma on 31/03/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import Foundation

public struct PwdKeychain {
    
    public enum PwdKeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    public init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    public fileprivate(set) var account: String
    fileprivate let service: String
    fileprivate let accessGroup: String?
}

public extension PwdKeychain {
    func readPassword() throws -> String {
        var query = PwdKeychain.query(service: service, account: account, accessGroup: accessGroup)
        // Reture the attributes of the first match only.
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        // Return the attributes of the keychain item (the password is acquired in the secItemFormatToDictionary: method):.
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        // Reture the data of the keychain item.
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // If no items were found, throw an error.
        guard status != errSecItemNotFound else { throw PwdKeychainError.noPassword }
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw PwdKeychainError.unhandledError(status: status) }
        
        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String : AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                throw PwdKeychainError.unexpectedPasswordData
        }
        
        return password
    }
    
    func savePassword(_ password: String) throws {
        // Encode the password into an Data object.
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        
        do {
            // Check for an existing item in the keychain.
            try _ = readPassword()
            
            // Set a new password.
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
            // Update the existing item.
            let query = PwdKeychain.query(service: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw PwdKeychainError.unhandledError(status: status) }
        } catch PwdKeychainError.noPassword {
            /*
             No password was found in the keychain. Create a dictionary to save
             as a new keychain item.
             */
            var newItem = PwdKeychain.query(service: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw PwdKeychainError.unhandledError(status: status) }
        }
    }
    
    mutating func renameAccount(_ newAccountName: String) throws {
        // Try to update an existing item with the new account name.
        var attributesToUpdate = [String : AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?
        
        let query = PwdKeychain.query(service: service, account: self.account, accessGroup: accessGroup)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw PwdKeychainError.unhandledError(status: status) }
        
        self.account = newAccountName
    }
    
    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = PwdKeychain.query(service: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw PwdKeychainError.unhandledError(status: status) }
    }
}

extension PwdKeychain {
    public static func items(service: String, account: String? = nil, accessGroup: String? = nil) throws -> [PwdKeychain] {
        // Build a query for all items that match the service and access group.
        var query = PwdKeychain.query(service: service, account: account, accessGroup: accessGroup)
        // Reture the attributes of the keychain item all.
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        // Return the attributes of the keychain item.
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        // Reture the data of the keychain item.
        query[kSecReturnData as String] = kCFBooleanFalse
        
        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw PwdKeychainError.unhandledError(status: status) }
        
        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String : AnyObject]] else { throw PwdKeychainError.unexpectedItemData }
        
        // Create a `KeychainPasswordItem` for each dictionary in the query result.
        var passwordItems = [PwdKeychain]()
        for result in resultData {
            guard let account  = result[kSecAttrAccount as String] as? String else { throw PwdKeychainError.unexpectedItemData }
            
            let passwordItem = PwdKeychain(service: service, account: account, accessGroup: accessGroup)
            passwordItems.append(passwordItem)
        }
        
        return passwordItems
    }
    
    fileprivate static func query(service: String, account: String? = nil, accessGroup: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        // This keychain item is a generic password.
        query[kSecClass as String] = kSecClassGenericPassword
        // Set keychain service
        query[kSecAttrService as String] = service as AnyObject?
        // Set keychain account
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        // Set keychain accessgroup
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}
