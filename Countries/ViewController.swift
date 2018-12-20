//
//  ViewController.swift
//  Countries
//
//  Created by Anuradha Dubey on 18/12/18.
//

import UIKit
import WebKit
import Reachability
import SVGKit

var countries = [MappedCountry]()
var isOnline : Bool?

class CountryCell: UITableViewCell{
    
    static let reuseIdentifier = "CountryCell"
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchText = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        searchText.font = UIFont(name: "Nexa", size: 15)
        searchText.textColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UITableViewDatasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.reuseIdentifier, for: indexPath) as! CountryCell
    
        let mappedData = countries[indexPath.row]
        cell.countryNameLabel.text = mappedData.name
        
        
        
        DispatchQueue.global(qos: .background).async
        {
            if let url = URL(string: mappedData.flag!)
            {
                let fileManager = FileManager.default
                if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let nameStr = mappedData.name?.replacingOccurrences(of: " ", with: "")
                    let path = tDocumentDirectory.appendingPathComponent(nameStr!).appendingPathExtension("svg")
                    if (isOnline!)
                    {
                        if !fileManager.fileExists(atPath: path.path) {
                            do {
                                let loadedFileData = NSData(contentsOf: url as URL)
                                do {
                                    //try loadedFileData?.write(to: path, options: .atomic)
                                    
                                    let receivedIcon: SVGKImage = SVGKImage(data: loadedFileData! as Data)
                                    
                                    //                                    let image = SVGKImage(contentsOfFile: path.path)
                                    DispatchQueue.main.async {
                                        cell.flagImageView.image = nil
                                        cell.flagImageView.image = receivedIcon.uiImage
                                    }
                                    
                                } catch {
                                    print("error")
                                }
                            } catch {
                                NSLog("Couldn't create document directory")
                            }
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            let image = SVGKImage(contentsOfFile: path.path)
                            cell.flagImageView.image = image!.uiImage
                        }
                    }
                }
               
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let mainStoryboard = self.mainStoryboard() else {
            return
        }
        let viewController: CountryDetailViewController? = (mainStoryboard.instantiateViewController(withIdentifier: "CountryDetailViewController") as! CountryDetailViewController)
        let mappedData = countries[indexPath.row]
        viewController!.countryInfo = mappedData
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    // This method returns main storyboard
    func mainStoryboard() -> UIStoryboard? {
        let tempMainStoryboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil)
        guard let mainStoryboard = tempMainStoryboard else {
            return nil
        }
        return mainStoryboard
    }

    
    // MARK: - UISearchBarDelegates
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        checkInternetConnection()
        print(searchText)
        countries.removeAll()
        if (searchText.count > 0) {
            if isOnline!
            {
                callCountryApi(searchText: searchText)
            }
            else
            {
                NetworkingManager.sharedInstance.fetchCountry(searchText: searchText) {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            }
        }
        else if searchText.isEmpty{
            countries.removeAll()
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if text.isEmpty
        {
            countries.removeAll()
            self.tableView.reloadData()
        }
        
        return true
    }
    
    func callCountryApi(searchText : String)
    {
        DispatchQueue.global(qos: .userInteractive).async {
            NetworkingManager.sharedInstance.callSearchApi(searchText: searchText, completion: { ( isSuccess, errorMessage) in
                
                DispatchQueue.main.async {
                    if (isSuccess)
                    {
                        self.tableView.reloadData()
                    }
                    else
                    {
                        self.showAlert(message: errorMessage)
                    }
                }
               
            })
            
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
    
    func checkInternetConnection()
    {
        if ReachabilityManager.shared.reachability.connection != .none{
            isOnline = true
        }
        else{
            isOnline = false
        }
    }

}

