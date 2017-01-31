
//
//  MyNetwork.swift
//  WeatherApp
//
//  Created by Roopika 1/31/17.
//  Copyright © 2017 Roopika. All rights reserved.
//

import Foundation
import UIKit

public enum HTTPMethod: String {
    case GET = "GET", POST = "POST", PUT = "PUT", DELETE = "DELETE"
}

open class MyNetwork:NSObject, URLSessionDataDelegate {

    let urlSession: URLSession = Foundation.URLSession.shared
    let hostURL = "http://api.openweathermap.org/data/2.5/weather?q="

    required public override init() {
        super.init()
    }
    

    static var instance = MyNetwork()
    static var userId : String?
    static var token : String?
    static var isShowOverLayImage : Bool?

}



//MARK: Public API
extension MyNetwork {

    //with uniform resource identifier
    public func requestWithUri(_ uri:String,
        httpMethod: HTTPMethod,
        httpBodyParameters:AnyObject?,
        completion: ((String, AnyObject?, NSError?) -> Void)!){
            _request(uri, httpMethod: httpMethod, httpBody: httpBodyParameters, shouldAppendURL: true, completion: completion)
    }
    
    public func requestWithUri(_ uri:String,
        httpMethod: HTTPMethod,
        httpBodyParameters:AnyObject?,
        isJSONObject:Bool,
        completion: ((String, AnyObject?, NSError?) -> Void)!){
            _request(uri, httpMethod: httpMethod, httpBody: httpBodyParameters, shouldAppendURL: true, isJSONObject : isJSONObject,completion: completion)
    }
    
    //with uniform resource locator
    public func requestWithUrl(_ url:String,
        httpMethod: HTTPMethod,
        httpBodyParameters:AnyObject?,
        completion: @escaping ((String, AnyObject?, NSError?) -> Void)){
            _request(url, httpMethod: httpMethod, httpBody: httpBodyParameters, shouldAppendURL: false, completion: completion)
    }
    
    public func downloadImage(_ url:String, completion: @escaping ((_ imageData: Data?) ->Void))
    {
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler:{(data, response, error) in
        
                if data != nil
                {
                    completion(data)
                    return
                }
            completion(nil)

        }).resume()
    }

}

//MARK: Private Methods
extension MyNetwork {
    
    fileprivate func _request(_ target:String,
        httpMethod:HTTPMethod,
        httpBody: AnyObject?,
        shouldAppendURL : Bool,
        isJSONObject : Bool,
        completion: ((String, AnyObject?, NSError?) -> Void)!)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        

        var url : String = target
        if shouldAppendURL {
            url = "\(self.hostURL)\(target)"
            //if self.isLoggedIn() {
                //url = "\(self.loggedInURL)\(target)"
            //}
        }
        print("Outgoing URL : \(url)")
        if let encodedURLString = (url as NSString).addingPercentEscapes(using: String.Encoding.utf8.rawValue){
            let request = buildHttpRequest(encodedURLString, httpBody: httpBody, isJSONObject : isJSONObject, httpMethod: httpMethod)
            print(request.allHTTPHeaderFields)
            urlSession.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                
                if (error == nil) {
                    // Success
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("URL Session Task Completed: HTTP \(statusCode)")
                }
                else {
                    // Failure
                    print("URL Session Task Failed: %@", error!.localizedDescription);
                }
                
                var status : String = ""
                var content : AnyObject? = nil
                if error != nil {
                    print("HTTP request error code:\(status) : \(error!.localizedDescription), for URL: \(url)")
                    status = "-999" //network error
                    completion(status, nil, error as? NSError)
                } else {
                    let _: NSString? = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    (status, content) = JSONSerialization.parseBasicResponse(data!)
                    if let contentExists: AnyObject = content{
                        if let _ = contentExists as? NSDictionary{
                            //print("content as Dictionary : \(contentAsDictionary)")
                        }
                        
                        if let _ = contentExists as? NSString{
                            //print("content as String : \(contentAsString)")
                        }
                        
                        if let _ = contentExists as? NSArray{
                            //print("content as Array : \(contentAsArray)")
                        }
                        
                        completion(status, contentExists, nil)
                    }
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false

            }).resume()
        }
    }
    
    fileprivate func _request(_ target:String,
        httpMethod:HTTPMethod,
        httpBody: AnyObject?,
        shouldAppendURL : Bool,
        completion: ((String, AnyObject?, NSError?) -> Void)!)
    {
        _request(target, httpMethod: httpMethod, httpBody: httpBody, shouldAppendURL: shouldAppendURL, isJSONObject : false, completion: completion)
    }
    
    public func buildHttpRequest(_ urlString: String,
        httpBody: AnyObject?,
        isJSONObject : Bool,
        httpMethod: HTTPMethod) -> NSMutableURLRequest {
            
            if let url = URL(string: urlString){
                
                let request = NSMutableURLRequest(url:url)
                request.httpMethod = httpMethod.rawValue
                if let data = httpBody as? Data
                {
                    request.httpBody = data
                }
                
                // Headers
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                if let bodyParams = httpBody as? NSDictionary {
                    //var error: NSError?
                    if let body: NSString = bodyParams.contentsAsURLQueryString(){
                        if isJSONObject {
                            do {
                                let value = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
                                request.httpBody = value
                            }
                            catch let error as NSError {
                                print("HTTPBODY : A JSON Object build error occurred, here are the details:\n \(error)")
                            }

                        } else {
                            request.httpBody = body.data(using: String.Encoding.utf8.rawValue)
                        }
                    }
                    else{
                        
                        do {
                            let value = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
                            request.httpBody = value
                        }
                            
                        catch let error as NSError {
                            print("HTTPBODY : A JSON Object build error occurred, here are the details:\n \(error)")
                        }
                    }
                    
        
                    
                } else if let bodyParams = httpBody as? NSArray {
                    
                    do {
                        let value = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
                        request.httpBody = value
                    }
                        
                    catch let error as NSError {
                        print("HTTPBODY : A JSON Object build error occurred, here are the details:\n \(error)")
                    }
                }
                else if let bodyParams = httpBody as? NSString{
                    //var error: NSError?
                    if let body = bodyParams.data(using: String.Encoding.utf8.rawValue) {
                        request.httpBody = body
                    }
                }
                else if let bodyParams = httpBody as? Data {
                    request.httpBody = bodyParams
                }
                else if let bodyParams = httpBody as? Bool {
                    let booleanString = bodyParams ? "true" : "false"
                    request.httpBody = booleanString.data(using: String.Encoding.utf8)
                }
                
                return request
            }
            return NSMutableURLRequest()
    }
    
    fileprivate func _buildHttpRequest(_ urlString: String,
        httpBody: AnyObject?,
        httpMethod: HTTPMethod) -> NSMutableURLRequest {
            return buildHttpRequest(urlString, httpBody: httpBody, isJSONObject : false, httpMethod: httpMethod)
    }
    
}

