//
//  ViewController.swift
//  Example
//
//  Created by JT Ma on 01/04/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import UIKit
import SecurityBox

class ViewController: UIViewController {
    
    let account = "com.jt.security.kGenericUDIDKey"

    override func viewDidLoad() {
        super.viewDidLoad()

        queryKeychain()
        print(getUDID())
//        renameAccount()
//        deleteUDID()
    }
    
    func getUDID() -> String {
        return UIDevice.current.genericUDID()
    }

    func queryKeychain() {
        do {
            let items = try Keychain.items(service: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup)
            for item in items {
                print(item.account)
            }
        } catch {
            fatalError()
        }
    }
    
    func deleteUDID() {
        let item = Keychain(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do {
            try item.deleteItem()
        } catch {
            fatalError()
        }
    }
    
    func renameAccount() {
        var item = Keychain(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        do {
            try item.renameAccount("com.jt.security.NewAccount")
            try item.savePassword("new password")
        } catch {
            fatalError()
        }
    }

}

