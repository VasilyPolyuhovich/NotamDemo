//
//  Notam.swift
//  RocketRouteDemo
//
//  Created by Vasyl Polyukhovych on 10/20/16.
//  Copyright © 2016 Vasyl Polyukhovych. All rights reserved.
//

import Foundation
import CoreLocation

enum NotamKeys: String {
    case ItemQ = "ItemQ"
    case ItemA = "ItemA"
    case ItemB = "ItemB"
    case ItemC = "ItemC"
    case ItemD = "ItemD"
    case ItemE = "ItemE"
    case ItemF = "ItemF"
    case ItemG = "ItemG"
}

class Notam: NSObject {
    
    public var notamLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0,longitude: 0)
    public var notamMessage:String = "no message"
    var itemQ = ""
    var itemA = ""
    var itemB = ""
    var itemC = ""
    var itemD = ""
    var itemE = ""
    var itemF = ""
    var itemG = ""
    
    convenience init(dictionary: [String: String]) {
        self.init()
        itemQ = dictionary[NotamKeys.ItemQ.rawValue] ?? ""
        
        if (!itemQ.isEmpty) {
            notamLocation = DMStoDEC(locationString: itemQ)
        }
        
        itemA = dictionary[NotamKeys.ItemA.rawValue] ?? ""
        itemB = dictionary[NotamKeys.ItemB.rawValue] ?? ""
        itemC = dictionary[NotamKeys.ItemC.rawValue] ?? ""
        itemD = dictionary[NotamKeys.ItemD.rawValue] ?? ""
        itemE = dictionary[NotamKeys.ItemE.rawValue] ?? ""
        itemF = dictionary[NotamKeys.ItemF.rawValue] ?? ""
        itemG = dictionary[NotamKeys.ItemG.rawValue] ?? ""
        
        notamMessage = itemE
    }
    
    override init() {
        super.init()
    }
    
    func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafePointer(to: &i) {
                $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
            }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
    
    func convert(degrees: Double?, minutes: Double?, seconds: Double?, direction: String) -> Double {
        let sign = (direction == "W" || direction == "S") ? -1.0 : 1.0
        return (degrees! + (minutes! + seconds!/60.0)/60.0) * sign
    }
    
    func DMStoDEC(locationString: String) -> CLLocationCoordinate2D
    {
        var location = CLLocationCoordinate2D()
        let coords = locationString.components(separatedBy: "/");
        if coords.count > 1{
            if let cItem = coords.last {
                let regex = re.compile("([0-9]{4}[NS])([0-9]{5}[EW])")
                let m = regex.finditer(cItem)
                if let dmsStr = m.last?.groups(){
                    if let lat = dmsStr[0]{
                        let latArr = Array(lat.characters)
                        var degrees:String, minutes:String, direction:String
                        degrees = String(latArr[0...1])
                        minutes = String(latArr[2...3])
                        direction = String(latArr[4])
                        location.latitude = convert(degrees:Double(degrees), minutes: Double(minutes), seconds: 0, direction: direction)
                    }
                    if let long = dmsStr[1]{
                        let longArr = Array(long.characters)
                        var degrees:String, minutes:String, direction:String
                        degrees = String(longArr[0...2])
                        minutes = String(longArr[3...4])
                        direction = String(longArr[5])
                        location.longitude = convert(degrees:Double(degrees), minutes: Double(minutes), seconds: 0, direction: direction)
                    }
                }
            }
        }
        
        return location
    }
}
