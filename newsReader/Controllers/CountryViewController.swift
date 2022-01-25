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

    
    
    var countryArray: [String] =  ["AE","AR","AT","AU","BE","BG","BR","CA","CH","CN","CO","CU","CZ","DE","EG","FR","GB","GR","HK","HU","ID","IE","IL","IN","IT","JP","KR","LT","LV","MA","MX","MY","NG","NL","NO","NZ","PH","PL","PT","RO","RS","RU","SA","SE","SG","SI","SK","TH","TR","TW","UA","US","VE","ZA","none"]
    
    var typeOfFunc = ""
    var name: String = ""
    var searchByCountry: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
       // tableView.register(UINib(nibName: "CountryTableViewCell", bundle: nil), forCellReuseIdentifier: "CountryTableViewCell")

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func goToMenu(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
        
        secondViewController.searchByCountry = searchByCountry
        secondViewController.name = name
        secondViewController.typeOfFunc = typeOfFunc
        secondViewController.categoryName = categoryName
        secondViewController.wordSearch = wordSearch
        secondViewController.sourcesName = sourcesName

        
        
        
        show(secondViewController, sender: nil)
    }
    
    
}

extension CountryViewController: UITableViewDelegate {
    func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if checkIndex == 1 {
//            tableView.cellForRow(at: numberIndex)?.accessoryType = .none
//            checkIndex -= 1
//        }
        if tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType == .checkmark{
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
        }
        else{
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
            checkIndex += 1
            numberIndex = indexPath
            print("sf")
            searchByCountry = countryArray[indexPath.row]
            print(searchByCountry)
        }
        
        tableView.reloadData()

        
    }
}


extension CountryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell", for: indexPath) as! CountryTableViewCell
        var cell = UITableViewCell(style: .default, reuseIdentifier: "indexPath")

       
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell") as! CountryTableViewCell
            print("create")
        }
        print(searchByCountry)
        if countryArray[indexPath.row] == searchByCountry {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            numberIndex = indexPath

        }
        
        cell.textLabel!.text = countryArray[indexPath.row]
        //cell.textCountry.text = countryArray[indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}



