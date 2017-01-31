//
//  NSDictionaryExtension.swift
//  WeatherApp
//
//  Created by Roopika 1/31/17.
//  Copyright © 2017 Roopika. All rights reserved.
//


import Foundation

extension NSDictionary {
    public func contentsAsURLQueryString() -> NSString? {
        let string: NSMutableString = ""
        let keys: [NSString] = self.allKeys as! [NSString]
        for key in keys {
            var value: AnyObject! = self.object(forKey: key) as AnyObject!
            if value.isKind(of: NSString.self) {
                // value is a string
            } else if value.responds(to: #selector(getter: NSNumber.stringValue)) {
                value = value.stringValue as AnyObject!
            } else {
                //bad parameters
                return nil
            }
            
            let parameterValue = key.isEqual(to: "appID") ? value.description : value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
            let toAppend = key == "" ? parameterValue : "\(key)=\(parameterValue)"
            string.append(toAppend!)
            
            if (keys.last != key) {
                string.append("&")
            }
        }
        return string;
    }
}
