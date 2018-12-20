//
//  Country+CoreDataProperties.swift
//  
//
//  Created by Anuradha Dubey on 20/12/18.
//
//

import Foundation
import CoreData


extension Country {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Country> {
        return NSFetchRequest<Country>(entityName: "Country")
    }

    @NSManaged public var alpha2Code: String?
    @NSManaged public var alpha3Code: String?
    @NSManaged public var altSpellings: NSObject?
    @NSManaged public var area: Float
    @NSManaged public var borders: NSObject?
    @NSManaged public var callingCodes: NSObject?
    @NSManaged public var capital: String?
    @NSManaged public var cioc: String?
    @NSManaged public var currencies: NSObject?
    @NSManaged public var demonym: String?
    @NSManaged public var flag: String?
    @NSManaged public var languages: NSObject?
    @NSManaged public var latlng: NSObject?
    @NSManaged public var name: String?
    @NSManaged public var nativeName: String?
    @NSManaged public var numericCode: String?
    @NSManaged public var population: Int64
    @NSManaged public var region: String?
    @NSManaged public var regionalBlocs: NSObject?
    @NSManaged public var subregion: String?
    @NSManaged public var timezones: NSObject?
    @NSManaged public var topLevelDomain: NSObject?
    @NSManaged public var translations: NSObject?

}
