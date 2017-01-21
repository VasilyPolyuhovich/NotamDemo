//
//  StringExtencions.swift
//  RocketRouteDemo
//
//  Created by Vasyl Polyukhovych on 10/20/16.
//  Copyright © 2016 Vasyl Polyukhovych. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    
    public var xmlEscaped: String {
        // we need to make sure "&" is escaped first. Not doing this may break escaping the other characters
        var escaped = replacingOccurrences(of: "&", with: "&amp;", options: .literal)
        
        // replace the other four special characters
        let escapeChars = ["<" : "&lt;", ">" : "&gt;", "'" : "&apos;", "\"" : "&quot;"]
        for (char, echar) in escapeChars {
            escaped = escaped.replacingOccurrences(of: char, with: echar, options: .literal)
        }
        
        return escaped
    }
    
    func toMd5() -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let data = self.data(using: String.Encoding.utf8) {
            let _ = data.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(data.count), &digest)
            }
        }
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
}
