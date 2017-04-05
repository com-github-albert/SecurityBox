//
//  KeychainConfiguration.swift
//  SecurityBox
//
//  Created by JT Ma on 31/03/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import Foundation

public struct KeychainConfiguration {
    public static let serviceName = "MyAppService"
    
    /*
     Specifying an access group to use with `Keychain` instances
     will create items shared accross both apps.
     
     For information on App ID prefixes, see:
     https://developer.apple.com/library/ios/documentation/General/Conceptual/DevPedia-CocoaCore/AppID.html
     and:
     https://developer.apple.com/library/ios/technotes/tn2311/_index.html
     and
     https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/02concepts/concepts.html#//apple_ref/doc/uid/TP30000897-CH204-TP9
     */
//    public static let accessGroup = "[YOUR APP ID PREFIX].com.jt.security.GenericKeychainShared"
    
    /*
     Not specifying an access group to use with `Keychain` instances
     will create items specific to each app.
     */
    public static let accessGroup: String? = nil
}
