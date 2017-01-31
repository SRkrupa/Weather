//
//  NSJSONSerializationExtension.swift
//  WeatherApp
//
//  Created by Roopika 1/31/17.
//  Copyright © 2017 Roopika. All rights reserved.
//


import Foundation

public extension JSONSerialization {
    public class func parseIntFromJson(_ json:NSDictionary, key:String) -> Int {
        var result = 0
        if let value = json[key] as? Int {
            result = value
        }
        
        return result
    }
    
    public class func parseBoolFromJson(_ json:NSDictionary, key:String) -> Bool {
        var result = false
        if let value = json[key] as? Bool {
            result = value
        }
        
        return result
    }
    
    public class func parseStringFromJson(_ json:NSDictionary, key:String) -> String {
        var result = ""
        if let value = json[key] as? String {
            result = value
        }
        
        return result
    }
    
    public class func parseDictionaryFromJson(_ json:NSDictionary, key:String) -> NSDictionary {
        var result = NSDictionary()
        if let value = json[key] as? NSDictionary {
            result = value
        }
        
        return result
    }
    
    public class func parseArrayOfDictFromJson(_ json:NSDictionary, key:String) -> [NSDictionary] {
        var result = [NSDictionary]()
        if let value = json[key] as? [NSDictionary] {
            result = value
        }
        
        return result
    }
    
    
    
    public class func parseTimestampFromJson(_ json:NSDictionary, key:String) -> TimeInterval {
        var result = 0.0
        if let value = json[key] as? TimeInterval {
            result = value
        }
        return result
    }
    
    public class func parseBasicResponse(_ data:Data) -> (status: String, content:AnyObject?) {
        var dictionary: NSDictionary?
        var array: NSArray?
        
        if let value =  _buildJsonDictionary(data) as? NSDictionary {
            dictionary = value
        } else if let value = _buildJsonArray(data) as? NSArray {
            array = value
            return parseBasicArrayResponse(array!)
        }
        else if let asString = NSString(data: data, encoding: String.Encoding.utf8.rawValue){
            return ("0",asString)
        }
        else{
            print("invalid")
        }
        
        return parseBasicResponse(dictionary!)
    }
    
    public class func parseBasicResponse(_ requestDictionary:NSDictionary) -> (status: String, content:AnyObject?) {
        var status = "1"
        if let value = requestDictionary["status"] as? String {
            status = value
        }
        let content: AnyObject? = requestDictionary
        
        return (status, content)
    }
    
    
    public class func parseBasicArrayResponse(_ requestArray:NSArray) -> (status: String, content:AnyObject?) {
        var status = "1"
        if requestArray.count <= 0 {
            status = "0"
        }
        let content: AnyObject? = requestArray
        
        return (status, content)
    }
    
    
    
    public class func _buildJsonDictionary(_ data:Data) -> AnyObject? {
        
        do {
            if case let JSON as NSDictionary = try JSONSerialization.jsonObject(with: data, options: []) {
                return JSON
            }
        }
        
        
        catch let error as NSError {
            // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
            print("JSONDictionary : A JSON parsing error occurred, here are the details:\n \(error)")
        }
        
        /*
        var error: NSError?
        if let object = NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String: AnyObject]], let dictionary = object.first {
            return dictionary
        } else {
            //let asString = NSString(data: data, encoding: NSUTF8StringEncoding)
            //print("ERROR Dictionary JSON: \(errorOccured)")
            print(error)
        }*/
        return nil
    }
    
    public class func _buildJsonArray(_ data:Data) -> AnyObject? {
        
        do {
            if case let JSON as NSArray = try JSONSerialization.jsonObject(with: data, options: []) {
                return JSON
            }
        }
            
            
        catch let error as NSError {
            // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
            print("JSONArray : A JSON parsing error occurred, here are the details:\n \(error)")
        }
        
        return nil
        /*
        var error: NSError?
        let object = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSArray
        if let errorOccured = error{
            //print("ERROR Array JSON: \(errorOccured)")
        }
        return object*/
    }
}
