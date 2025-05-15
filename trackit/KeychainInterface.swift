//
//  KeychainInterface.swift
//  trackit
//
//  Created by Samuel Valencia on 5/15/25.
//

import Security
import Foundation

struct KeychainInterface {
    enum KeychainConstraints {
        static let service = "com.h2technologiesllc.trackit"
        static let usernameAccount = "username"
        static let tokenAccount = "token"
    }
    
    static func saveUsername(username: String) -> Bool {
        print("Saving username")
        print(username)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainConstraints.service,
            kSecAttrAccount as String: KeychainConstraints.usernameAccount,
            kSecValueData as String: Data(username.utf8)
        ]
        
        SecItemDelete(query as CFDictionary) //Delete existing data
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }


    static func saveToken(token: String) -> Bool {
        print("Saving token")
        print(token)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainConstraints.service,
            kSecAttrAccount as String: KeychainConstraints.tokenAccount,
            kSecValueData as String: Data(token.utf8)
        ]
        
        SecItemDelete(query as CFDictionary) //Delete existing data
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    static func getUsername() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainConstraints.service,
            kSecAttrAccount as String: KeychainConstraints.usernameAccount,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let username = String(data: data, encoding: .utf8) {
            return username
        } else {
            return nil
        }
    }
    
    static func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainConstraints.service,
            kSecAttrAccount as String: KeychainConstraints.tokenAccount,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        } else {
            return nil
        }
    }
    
    static public func saveUserInfo(username: String, token: String) -> Bool {
        let uResult = saveUsername(username: username)
        let tResult = saveToken(token: token)
        
        return uResult && tResult
    }
    
    static public func fetchUserInfo() -> (String?, String?) {
        let uResult = getUsername()
        let tResult = getToken()
        
        return (uResult, tResult)
    }
    
    
}


