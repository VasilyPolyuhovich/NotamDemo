//
//  Api.swift
//  RocketRouteDemo
//
//  Created by Vasyl Polyukhovych on 10/18/16.
//  Copyright © 2016 Vasyl Polyukhovych. All rights reserved.
//

import Foundation
import UIKit

class APIRequesManager: NSObject, XMLParserDelegate {
    private let currentUser : User = User()
    private let pCategoryKey = "RocketRoute"
    private let apiKey = "dvNDMzS3FtyEYnhWuZLm"
    private let apiURLString = "https://apidev.rocketroute.com/notam/v1/"
    
    
    public func auth(){
        //        let soapRequest = AEXMLDocument()
        //        let body = soapRequest.addChild(name: "AUTH")
        //        body.addChild(name: "USR", value: currentUser.email)
        //        body.addChild(name: "PASSWD", value: MD5(currentUser.password))
        //        body.addChild(name: "DEVICEID", value: UIDevice.current.identifierForVendor!.uuidString)
        //        body.addChild(name: "PCATEGORY", value: pCategoryKey)
        //        body.addChild(name: "APPMD5", value: currentUser.apiKey)
    }
    
    public func getNotam(codeICAO: String?, completion: @escaping (_ result: [Notam]) -> Void){
    
        if let code = codeICAO{
            let xml = prepareXMLRequest(codeICAO: code)
            getNotamsFromServer(xml: xml){ result in
                if let notams = result {
                  completion(notams)
                }
            }
        }
    }
    
    func prepareXMLRequest(codeICAO: String) -> String{
        let requestXML = AEXMLDocument()
        let req = requestXML.addChild(name: "REQNOTAM")
        req.addChild(name: "USR", value: "vasilitch@gmail.com")
        req.addChild(name: "PASSWD", value: currentUser.password.toMd5())
        req.addChild(name: "ICAO", value: codeICAO)
        
        let soapRequest = AEXMLDocument()
        let envelopeAttributes = ["xmlns:SOAP-ENV" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "SOAP-ENV:Envelope", attributes: envelopeAttributes)
        let body = envelope.addChild(name: "SOAP-ENV:Body")
        //doing magic
        body.addChild(name:  "request", value: "<![CDATA[\(requestXML.xmlCompact)]]>")
        return soapRequest.xmlCompact
    }
    
    func getNotamsFromServer(xml:String!, completion: @escaping (_ result: (Array<Notam>)?) -> Void){
        let soapMessage = xml
        let url = URL(string: apiURLString)
        var theRequest = URLRequest(url: url!)
        //let soapMessage = soapMessage.characters.count
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.httpMethod = "POST"
        theRequest.httpBody = soapMessage?.data(using: String.Encoding.utf8, allowLossyConversion: false) // or false
        let msgLength = theRequest.httpBody?.count
        theRequest.addValue("\(msgLength)", forHTTPHeaderField: "Content-Length")
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        var notamsArray = [Notam]()
        // make the request
        let task = session.dataTask(with: theRequest, completionHandler: { (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling POST on \(self.apiURLString)")
                print(error ?? "")
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive data")
                return
            }
            let soapXML =  try! AEXMLDocument.init(xml: data!)
            let responceXML =  try! AEXMLDocument.init(xml:soapXML.xmlCompact)
            let response = responceXML.root["SOAP-ENV:Body"].children[0].value!

            if let respStr = response.fromBase64(){
                let notamXML = try! AEXMLDocument.init(xml: respStr)
                for item in notamXML.root["NOTAMSET"].children {
                    var dict = Dictionary<String, String>()
                    for notam in item.children {
                        if let value = notam.value {
                            dict[notam.name] = value
                        }else{
                            dict[notam.name] = ""
                        }
                    }
                    notamsArray.append(Notam.init(dictionary: dict))
                }
                     completion(notamsArray)
            }
        })
        task.resume()

    }
}
