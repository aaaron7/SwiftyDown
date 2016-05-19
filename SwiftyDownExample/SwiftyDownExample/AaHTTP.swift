//
//  AaHTTP.swift
//  ConsultantLoop
//
//  Created by wenjin on 3/19/16.
//  Copyright © 2016 wenjin. All rights reserved.
//

import Foundation
import SwiftyJSON

enum RequestMethod{
    case Post
    case Get
}

typealias aht = AaHTTP

class AaHTTP {
    
    private var method : RequestMethod
    
    private var hostName = "http://debug.api.swift.gg/"
    
    private var curUrl = ""
    
    private var parameters : [String : AnyObject] = [:]
    private var finalParas : [String : AnyObject] = [:]
    
    static let shareInstance = AaHTTP(m: .Get)
    
    static let sharedInstanceSocial = AaHTTP(m : .Get,host : "http://contact.maishoudian.com")
    
    init(m : RequestMethod){
        method = m
        setDefaultParas()
    }
    
    init(m : RequestMethod, host : String){
        method = m
        hostName = host
        setDefaultParas()
    }
    
    private func setDefaultParas(){
        _ = defaultParameter().reduce("", combine: { (str, p) -> String in
            self.parameters[p.0] = p.1
            return ""
        })
    }
    //"app_id":"8ef0adeae22e9e61fb00249a906637d7"
    func addDefaultParas(p :[String : AnyObject]){
        _ = p.reduce("", combine: { (str, p) -> String in
            self.parameters[p.0] = p.1
            return ""
        })
    }
    
    func fetch(url : String) -> AaHTTP{
        setDefaultParas()
        curUrl = "\(hostName)\(url)"
        self.method = .Get
        return self
    }
    
    func post(url : String) -> AaHTTP{
        setDefaultParas()
        curUrl = "\(hostName)\(url)"
        self.method = .Post
        return self
    }
    
    func paras(p : [String:AnyObject]) -> AaHTTP{
        self.finalParas = [:]

        _ = parameters.reduce("", combine: { (str, p) -> String in
            self.finalParas[p.0] = p.1
            return ""
        })
        _ = p.reduce("") { (str, p) -> String in
            self.finalParas[p.0] = p.1
            return ""
        }
        return self
    }
    
    func go(success : JSON -> Void, failure : NSError?->Void){
        var smethod = ""
        if method == .Get{
            smethod = "GET"
        }else{
            smethod = "POST"
        }
        
        AaNet.request(smethod, url: curUrl, form: finalParas, success: { (data) -> Void in
            print("request successed in \(self.curUrl)")
            success(JSON(data: data!))
            }) { (error) -> Void in
                print("request failed in \(self.curUrl)")
                failure(error)
        }
    }
    
    func go(success : JSON -> Void){
        var smethod = ""
        if method == .Get{
            smethod = "GET"
        }else{
            smethod = "POST"
        }
        
        AaNet.request(smethod, url: curUrl, form: finalParas, success: { (data) -> Void in
            print("request successed in \(self.curUrl)")
            success(JSON(data: data!))
        }) { (error) -> Void in
            print("request failed in \(self.curUrl)")
            print(error)
        }
    }
    
    private func defaultParameter()->[String:AnyObject] {
        var result: [String : AnyObject] = [:]
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"]

        return result
    }
}