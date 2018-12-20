//
//  NetworkingManager.swift
//  Countries
//
//  Created by Anuradha Dubey on 18/12/18.
//

import UIKit
import CoreData

class NetworkingManager: NSObject {
    
    static let sharedInstance = NetworkingManager()
    private override init() {}
    var dataTask: URLSessionDataTask?
    var errorMessage = ""


    func callSearchApi( searchText : String, completion: @escaping (_ isSuccess : Bool, _ errorMessage : String) -> Void)
    {
        dataTask?.cancel()
        let originalString =  "https://restcountries.eu/rest/v2/name/\(searchText)"
        var urlString = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlString!)
        
        dataTask = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            
            if let error = error
            {
                self.errorMessage = "Error: " + error.localizedDescription + "\n"
                //completion(false, self.errorMessage)
            }
            else if let data = data{
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: []) as? AnyObject
                    if let dictionary = result as? Dictionary<String, Any> , result!["status"] as! Int == 404
                    {
                        self.errorMessage = dictionary["message"] as! String
                        completion(false, self.errorMessage)
                    }
                    else
                    {
                        
                        let country = result as! [[String : Any]]
                        
                        for dict in country
                        {
                            let mapCountry: MappedCountry = MappedCountry()
                            mapCountry.name = (dict["name"] as! String)
                            mapCountry.alpha2Code = (dict["alpha2Code"] ) as? String
                            mapCountry.alpha3Code = (dict["alpha3Code"] ) as? String
                            mapCountry.altSpellings = (dict["altSpellings"]) as? [String]
                            mapCountry.area = (dict["area"]) as? Float
                            mapCountry.callingCodes = (dict["callingCodes"] ) as? [String]
                            mapCountry.capital = dict["capital"]  as? String
                            mapCountry.cioc = dict["cioc"]  as? String
                            mapCountry.currencies = dict["currencies"] as? [[String : String]]
                            mapCountry.demonym = (dict["demonym"]) as? String
                            mapCountry.flag = (dict["flag"]) as? String
                            mapCountry.languages = (dict["languages"] as! [[String : AnyObject]])
                            mapCountry.latlng = (dict["latlng"]) as? [Float32]
                            mapCountry.nativeName = (dict["nativeName"]) as? String
                            mapCountry.numericCode = (dict["numericCode"]) as? String
                            mapCountry.population = (dict["population"] ) as? Int64
                            mapCountry.region = (dict["region"]) as? String
                            mapCountry.regionalBlocs = (dict["regionalBlocs"]) as? [[String : Any]]
                            mapCountry.subregion = (dict["subregion"]) as? String
                            mapCountry.timezones = (dict["timezones"]) as? [String]
                            mapCountry.topLevelDomain = (dict["topLevelDomain"] ) as? [String]
                            mapCountry.translations = (dict["translations"]) as? [String : String]
                            countries.append(mapCountry)
                        }
                        completion(true, "")
                    }
                }
                catch let parseError as NSError {
                    self.errorMessage = "JSONSerialization error: \(parseError.localizedDescription)\n"
                    completion(false, self.errorMessage)
                }
            }
        }
        
        dataTask!.resume()
    }
    
    func saveCountry( countryInfo : MappedCountry, completion: @escaping (_ isSaved : Bool) -> Void)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if checkValueExists(appdelegate: appDelegate, context: managedContext, countryInfo: countryInfo) {
            
            completion(false)
        }
        saveImage(countryInfo: countryInfo)

        let entity = NSEntityDescription.entity(forEntityName: "Country", in: managedContext)!
        let country = NSManagedObject(entity: entity, insertInto: managedContext) as! Country
        
        country.setValue(countryInfo.name , forKey: "name")
        country.setValue(countryInfo.alpha2Code , forKey: "alpha2Code")
        country.setValue(countryInfo.alpha3Code , forKey: "alpha3Code")
        country.setValue(countryInfo.altSpellings , forKey: "altSpellings")
        country.setValue(countryInfo.area , forKey: "area")
        country.setValue(countryInfo.callingCodes , forKey: "callingCodes")
        country.setValue(countryInfo.capital , forKey: "capital")
        country.setValue(countryInfo.cioc , forKey: "cioc")
        country.setValue(countryInfo.currencies , forKey: "currencies")
        country.setValue(countryInfo.demonym , forKey: "demonym")
        country.setValue(countryInfo.flag , forKey: "flag")
        country.setValue(countryInfo.languages , forKey: "languages")
        country.setValue(countryInfo.latlng , forKey: "latlng")
        country.setValue(countryInfo.nativeName , forKey: "nativeName")
        country.setValue(countryInfo.numericCode , forKey: "numericCode")
        country.setValue(countryInfo.population , forKey: "population")
        country.setValue(countryInfo.region , forKey: "region")
        country.setValue(countryInfo.regionalBlocs , forKey: "regionalBlocs")
        country.setValue(countryInfo.subregion , forKey: "subregion")
        country.setValue(countryInfo.timezones , forKey: "timezones")
        country.setValue(countryInfo.topLevelDomain , forKey: "topLevelDomain")
        country.setValue(countryInfo.translations , forKey: "translations")

        do {
            
            try managedContext.save()
            
        } catch {
            
            print("Failed saving")
        }
        
        completion(true)
    }
    
    func checkValueExists(appdelegate : AppDelegate, context : NSManagedObjectContext, countryInfo : MappedCountry) -> Bool
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Country")
        fetchRequest.predicate = NSPredicate(format: "name = %@", (countryInfo.name)!)
        
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        if results.count > 0{
            return true
        }
        else{
            return false
        }
    }
    
    func fetchCountry(searchText : String, completion: @escaping () -> Void)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Country")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        var results: [NSManagedObject] = []
        do {
            results = try managedContext.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        for country in results
        {
            let mapCountry: MappedCountry = MappedCountry()
            mapCountry.name = country.value(forKey: "name") as? String
            mapCountry.alpha2Code = country.value(forKey: "alpha2Code") as? String
            mapCountry.alpha3Code = country.value(forKey: "alpha3Code") as? String
            mapCountry.altSpellings = country.value(forKey: "altSpellings") as? [String]
            mapCountry.area = country.value(forKey:"area" ) as? Float
            mapCountry.callingCodes = country.value(forKey:"callingCodes" ) as? [String]
            mapCountry.capital = country.value(forKey:"capital" )  as? String
            mapCountry.cioc = country.value(forKey:"cioc" )  as? String
            mapCountry.currencies = country.value(forKey:"currencies" ) as? [[String : String]]
            mapCountry.demonym = country.value(forKey:"demonym" ) as? String
            mapCountry.flag = country.value(forKey:"flag" ) as? String
            mapCountry.languages = country.value(forKey:"languages" ) as? [[String : AnyObject]]
            mapCountry.latlng = country.value(forKey:"latlng" ) as? [Float32]
            mapCountry.nativeName = country.value(forKey:"nativeName" ) as? String
            mapCountry.numericCode = country.value(forKey:"numericCode" ) as? String
            mapCountry.population = country.value(forKey:"population" ) as? Int64
            mapCountry.region = country.value(forKey:"region" ) as? String
            mapCountry.regionalBlocs = country.value(forKey:"regionalBlocs" ) as? [[String : Any]]
            mapCountry.subregion = country.value(forKey:"subregion" ) as? String
            mapCountry.timezones = country.value(forKey:"timezones" ) as? [String]
            mapCountry.topLevelDomain = country.value(forKey:"topLevelDomain" ) as? [String]
            mapCountry.translations = country.value(forKey:"translations" ) as? [String : String]
            countries.append(mapCountry)
        }
        
        completion()
    }
    
    func saveImage(countryInfo : MappedCountry)
    {
        if let url = URL(string: countryInfo.flag!)
        {
            let fileManager = FileManager.default
            if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let nameStr = countryInfo.name?.replacingOccurrences(of: " ", with: "")
                let path = tDocumentDirectory.appendingPathComponent(nameStr!).appendingPathExtension("svg")
                if !fileManager.fileExists(atPath: path.path) {
                    do {
                        let loadedFileData = NSData(contentsOf: url as URL)
                        try loadedFileData?.write(to: path, options: .atomic)
                    } catch {
                        NSLog("Couldn't create document directory")
                    }
                }
                else{
                }
            }
        }
    }

}
