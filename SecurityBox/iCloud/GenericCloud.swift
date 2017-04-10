//
//  GenericiCloud.swift
//  SecurityBox
//
//  Created by JT Ma on 05/04/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import CloudKit

public struct GenericCloud {
    public let container: CKContainer
    public let publicDatabase: CKDatabase
    public fileprivate(set) var userRecordID: CKRecordID?
    
    fileprivate var applicationPermissionStatus = CKApplicationPermissionStatus.initialState
    
    public init(containerIdentifier: String) {
        container = CKContainer(identifier: containerIdentifier)
        publicDatabase = container.publicCloudDatabase
        
    }
}

extension GenericCloud {
    func checkAccountAvailable(success: @escaping ()->()) {
        container.accountStatus { (status, error) in
            guard error != nil else { return }
            
            switch status {
            case .available:
                /* The iCloud account credentials are available for this application */
                DispatchQueue.main.async(execute: {
                    success()
                })
                break
            case .couldNotDetermine:
                /* An error occurred when getting the account status, consult the corresponding NSError */
                break
            case .noAccount:
                /* No iCloud account is logged in on this device */
                break
            case .restricted:
                /* Parental Controls / Device Management has denied access to iCloud account credentials */
                break
            }
        }
    }
    
    func requestDiscoverabilityPermission(success: ()->()) {
        
    }
}

extension GenericCloud {
    func startSubscriptions() {
        
    }
    
    func subscribe() {
        
    }
    
    func unsubscribe() {
        
    }
}

class Test {
    func test() {
        _ = GenericCloud(containerIdentifier: "test")
    }
}
