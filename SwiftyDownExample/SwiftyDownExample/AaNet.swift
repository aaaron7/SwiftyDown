//
//  AaNet.swift
//  style_ios
//
//  Created by wenjin on 1/25/16.
//  Copyright © 2016 Wenjin. All rights reserved.
//

import Foundation





class AaNet: NSObject {
    
    
    class func request( method : String = "GET",var url : String ,form : Dictionary<String,AnyObject> = [:],success : (data : NSData?)->Void,fail:(error : NSError?)->Void){
        
        
        if method == "GET"{
            url += "?" + AaNet().buildParams(form)
        }
        
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
                            
        req.HTTPMethod = method
        
        if method == "POST" {
            req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let string = AaNet().buildParams(form)
            print("POST PARAMS \(form)")
            req.HTTPBody = string.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        let session = NSURLSession.sharedSession()
        
        print(req.description)
        
        let task = session.dataTaskWithRequest(req) { (data, response, error) -> Void in
            if error != nil{
                fail(error: error)
                print(response)
            }else{
                if (response as! NSHTTPURLResponse).statusCode  == 200{
                    success(data : data)
                }else{
                    fail(error: error)
                    print(response)

                }
            }

        }
        
        task.resume()
        
    }
    
    
    func buildParams(parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sort() {
            let value: AnyObject! = parameters[key]
            components += self.queryComponents(key, value)
        }
        
        return (components.map{"\($0)=\($1)"} as [String]).joinWithSeparator("&")
    }
        
        
    func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)", value)
            }
        } else {
            components.appendContentsOf([(escape(key), escape("\(value)"))])
        }
        
        return components
    }
    func escape(string: String) -> String {
        let legalURLCharactersToBeEscaped: CFStringRef = ":&=;+!@#$()',*"
        return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
}