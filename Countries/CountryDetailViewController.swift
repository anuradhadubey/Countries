//
//  CountryDetailViewController.swift
//  Countries
//
//  Created by Anuradha Dubey on 18/12/18.
//

import UIKit
import SVGKit

class CountryDetailCell: UITableViewCell {
    static let reuseIdentifier = "CountryDetailCell"
    @IBOutlet weak var valueLabel: UILabel!
}

class FlagHeader: UITableViewCell {
    static let reuseIdentifier = "FlagHeader"
    @IBOutlet weak var flagImageView: UIImageView!
}

class ContentHeader: UITableViewCell {
    static let reuseIdentifier = "ContentHeader"
    @IBOutlet weak var headingLabel: UILabel!
}

class CountryDetailViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var tableView: UITableView!
    var countryInfo = MappedCountry()
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveBtn()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func updateSaveBtn()
    {
        if isOnline! {
            saveBtn.isUserInteractionEnabled = true
            saveBtn.layer.borderColor = UIColor.white.cgColor
            saveBtn.layer.borderWidth = 1.0
            saveBtn.setTitleColor(UIColor.white, for: .normal)

        }
        else
        {
            saveBtn.isUserInteractionEnabled = false
            saveBtn.layer.borderColor = UIColor.darkGray.cgColor
            saveBtn.layer.borderWidth = 1.0
            saveBtn.setTitleColor(UIColor.darkGray, for: .normal)
        }
        
        self.tableView.reloadData()
        
    }
    
    //MARK: - UITableViewDatasource
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = getRows(section: section)
        return count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryDetailCell.reuseIdentifier, for: indexPath) as! CountryDetailCell
        
    
        if(indexPath.section == 1)
        {
            cell.valueLabel.text = countryInfo.name
        }
        else if (indexPath.section == 2){
            cell.valueLabel.text = countryInfo.capital
        }
        else if (indexPath.section == 3){
            let array : [String] = countryInfo.callingCodes!
            cell.valueLabel.text = array[indexPath.row]
        }
        else if (indexPath.section == 4){
            cell.valueLabel.text = countryInfo.region
        }
        else if (indexPath.section == 5){
            cell.valueLabel.text = countryInfo.subregion
        }
        else if (indexPath.section == 6){
            let array : [String]! = (countryInfo.timezones)
            if let arry = array, array.count > 0
            {
                cell.valueLabel.text = arry[indexPath.row]
            }
        }
        else if (indexPath.section == 7){
            let array : [[String : String]]! = (countryInfo.currencies)
            if let arry = array, array.count > 0
            {
                cell.valueLabel.text = arry[indexPath.row]["name"]! + " (" + arry[indexPath.row]["code"]! + ")"
            }
            
        }
        else if (indexPath.section == 8){
            let array : [[String : AnyObject]]! = (countryInfo.languages)
            if let arry = array, array.count > 0
            {
                cell.valueLabel.text = (arry[indexPath.row]["name"]! as! String) + " (" + (arry[indexPath.row]["nativeName"]! as! String) + ")"
            }
            
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let  headerCell = tableView.dequeueReusableCell(withIdentifier: FlagHeader.reuseIdentifier) as! FlagHeader
            if let url = URL(string: countryInfo.flag!)
            {
                let fileManager = FileManager.default
                if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let nameStr = countryInfo.name?.replacingOccurrences(of: " ", with: "")
                    let path = tDocumentDirectory.appendingPathComponent(nameStr!).appendingPathExtension("svg")
                    if(isOnline!)
                    {
                        if !fileManager.fileExists(atPath: path.path) {
                            do {
                                let loadedFileData = NSData(contentsOf: url as URL)
                                do {
                                    let receivedIcon: SVGKImage = SVGKImage(data: loadedFileData! as Data)
                                    
                                    DispatchQueue.main.async {
                                        headerCell.flagImageView.image = nil
                                        headerCell.flagImageView.image = receivedIcon.uiImage
                                    }
                                    
                                } catch {
                                    print("error")
                                }
                            } catch {
                                NSLog("Couldn't create document directory")
                            }
                        }
                        else{
                        }
                    }
                    else{
                        let image = SVGKImage(contentsOfFile: path.path)
                        headerCell.flagImageView.image = nil
                        headerCell.flagImageView.image = image!.uiImage
                    }                    
                }
                
            }
            return headerCell
        }
        else
        {
            let  headerCell = tableView.dequeueReusableCell(withIdentifier: ContentHeader.reuseIdentifier) as! ContentHeader
            headerCell.headingLabel.text = self.setHeadingOnLabels(section: section).uppercased()
            return headerCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 250
        }
        else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    
    func setHeadingOnLabels(section: Int)-> String
    {
        let heading: String!
        switch section {
        case 1:
            heading = "Name"
            break
        case 2:
            heading = "Capital"
            break
        case 3:
            heading = "Calling Codes"
            break
        case 4:
            heading = "Region"
            break
        case 5:
            heading = "Sub-Region"
            break
        case 6:
            heading = "Timezones"
            break
        case 7:
            heading = "Currencies"
            break
        case 8:
            heading = "Languages"
            break
        default:
            heading = ""
            break
        }
        return heading
    }
    
    func getRows(section: Int)-> Int
    {
        let count: Int!
        switch section {
        case 0:
            count = 0
            break
        case 3:
            let a : [String] = countryInfo.callingCodes!
            count = a.count
            break
        case 6:
            let a : [String] = countryInfo.timezones!
            count = a.count
            break
        case 7:
            let a: [[String : String]] = countryInfo.currencies!
            count = a.count
            break
        case 8:
            let a : [[String : AnyObject]] = countryInfo.languages!
            count = a.count
            break
        default:
            count = 1
            break
        }
        return count
    }

    @IBAction func goToMainView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func saveData(_ sender: Any)
    {
        NetworkingManager.sharedInstance.saveCountry(countryInfo: countryInfo) { (isSaved) in
            
            DispatchQueue.main.async {
                if isSaved
                {
                    self.showAlert(message: "Data saved successfully.")
                }
                else
                {
                    self.showAlert(message: "Data already saved.")
                }
            }
            
        }
    }
    
    func showAlert(message : String)
    {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action:UIAlertAction) in
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        
    }
}
