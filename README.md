# SecurityBox

## Keychain Services

### 1. Concepts
Keychain is simply a database stored in the file system, a user or application can create as many keychains as desired.

### 2. Use Keychain Services functions

```swift
var item = [String: AnyObject]()
```
* Query keychain item with service name, account name and access group. Set keychain type, this keychain is a generic password.

```swift
item[kSecClass as String] = kSecClassGenericPassword
item[kSecAttrService as String] = service as AnyObject?
item[kSecAttrAccount as String] = account as AnyObject?
item[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
```
* Save password. Convert password string to data type add create a dictionary to save as a new keychain item.

```swift
let encodedPassword = password.data(using: String.Encoding.utf8)!
item[kSecValueData as String] = encodedPassword as AnyObject?
let status = SecItemAdd(item as CFDictionary, nil)
```
* Read password. You could get attributes of the first match only or all items. Also you could get return attribute and data. Finally fetch the password in parsed password string with "SecItemCopyMatching" method.

```swift
item[kSecMatchLimit as String] = kSecMatchLimitOne
item[kSecReturnAttributes as String] = kCFBooleanTrue
item[kSecReturnData as String] = kCFBooleanTrue
var queryResult: AnyObject?
let status = withUnsafeMutablePointer(to: &queryResult) {
    SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
}
let passwordData = item[kSecValueData as String] as? Data,
let password = String(data: passwordData, encoding: String.Encoding.utf8)
```
* Update keychain item. You should update new item, likes password and account with "SecItemUpdate" method.

```swift
let status = SecItemUpdate(item as CFDictionary, attributesToUpdate as CFDictionary)
```
* Delete keychain item. It's very easy.

```swift
let status = SecItemDelete(item as CFDictionary)
```
* Finally, you just need to throws an error if an unexpected status was returned.

```swift
guard status != errSecItemNotFound else { throw PwdKeychainError }
guard status == noErr else { throw PwdKeychainError.unhandledError(status: status) }
```

### 3. AccessGroup
By default, only the app that created an item can access it in the future. But Keychain Services does more than simply check the identity of an app. Instead, it compares a keychain item’s access group, recorded as the kSecAttrAccessGroup attribute, with the list of access groups to which an app belongs. If one of the app’s access groups matches the keychain item’s group, access is granted. Similarly, Keychain Services allows an app to create keychain items with the kSecAttrAccessGroup attribute set to any of the app’s own access groups.

## UDID