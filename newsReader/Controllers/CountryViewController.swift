//
//  CountryViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 11.01.22.
//

import UIKit

class CountryViewController: UIViewController {
    var checkIndex: Int = 1
    var numberIndex: IndexPath = []
    var categoryName: String = ""
    var wordSearch: String = ""
    var sourcesName: String = ""
    var markerArticles: [Article]? = []
    var userNames: String = ""

    
    
    
    var countryArray: [String] =  ["AE","AR","AT","AU","BE","BG","BR","CA","CH","CN","CO","CU","CZ","DE","EG","FR","GB","GR","HK","HU","ID","IE","IL","IN","IT","JP","KR","LT","LV","MA","MX","MY","NG","NL","NO","NZ","PH","PL","PT","RO","RS","RU","SA","SE","SG","SI","SK","TH","TR","TW","UA","US","VE","ZA","none"]
    
    var typeOfFunc = ""
    var name: String = ""
    var searchByCountry: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    @IBAction func goToMenu(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "menu") as? MenuViewController else { return }
        
        secondViewController.name = name
        secondViewController.typeOfFunc = typeOfFunc
        secondViewController.searchByCountry = searchByCountry
        secondViewController.categoryName = categoryName
        secondViewController.wordSearch = wordSearch
        secondViewController.markerArticles = markerArticles
        secondViewController.sourcesName = sourcesName
        secondViewController.userNames = userNames
        
        show(secondViewController, sender: nil)
    }
    
}

extension CountryViewController: UITableViewDelegate {
    func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType == .checkmark{
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
        }
        else{
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
            checkIndex += 1
            numberIndex = indexPath
            searchByCountry = countryArray[indexPath.row]
        }
        
        tableView.reloadData()
        
    }
}


extension CountryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "indexPath")
        

        if countryArray[indexPath.row] == searchByCountry {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            numberIndex = indexPath
            
        }
        cell.textLabel!.text = countryArray[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}



