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
    let touchID = GenericTouchID()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        queryKeychain()
        print(getUDID())
//        renameAccount()
//        deleteKeychainItem()
        
        touchID.authenticate { (message) in
            if let message = message {
                // if the completion is not nil show an alert
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Darn!", style: .default)
                alertView.addAction(okAction)
                self.present(alertView, animated: true)
            } else {
                print("Logging in with Touch ID Successful!")
            }
        }
    }
    
    func getUDID() -> String {
        do {
            return try UIDevice.current.genericUDID()
        } catch {
            return "generic UDID error!"
        }
    }

    func queryKeychain() {
        do {
            let items = try PwdKeychain.items(service: KeychainConfiguration.serviceName,
                                              accessGroup: KeychainConfiguration.accessGroup)
            for item in items {
                print(item.account)
            }
        } catch {
            fatalError()
        }
    }
    
    func deleteKeychainItem() {
        let item = PwdKeychain(service: KeychainConfiguration.serviceName,
                               account: account,
                               accessGroup: KeychainConfiguration.accessGroup)
        do {
            try item.deleteItem()
        } catch {
            fatalError()
        }
    }
    
    func renameAccount() {
        var item = PwdKeychain(service: KeychainConfiguration.serviceName,
                               account: account,
                               accessGroup: KeychainConfiguration.accessGroup)
        do {
            try item.renameAccount("com.jt.security.NewAccount")
            try item.savePassword("new password")
        } catch {
            fatalError()
        }
    }

}
