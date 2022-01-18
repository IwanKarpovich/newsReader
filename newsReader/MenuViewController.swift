//
//  MenuViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 10.01.22.
//

import UIKit

class MenuViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searcByText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    

    
    // let mySwitch = UISwitch()
    var nextView = 0
    var typeOfFunc = ""
    var name: String = ""
    var searchByCountry: String = ""
    var categoryName: String = ""
    var wordSearch: String = ""

    
    var typeSettings: [String] = ["top","category","country","marker"]
    var settingsTableArray: [String] = []
    var markerArticles: [Article]? = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searcByText.delegate = self
        if wordSearch == "none"{
        searcByText.text = ""
        }
        else{
            searcByText.text = wordSearch
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func secretButton(_ sender: Any) {
        print("ura")
       
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        nextView+=1
        if nextView == 5 {
            guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
            if name == "online" {
                secondViewController.name = "offline"
            }
            else {
                secondViewController.name = "online"
            }
            //secondViewController.categoryName = categoryName
            secondViewController.searchByCountry = searchByCountry
            secondViewController.typeOfFunc = typeOfFunc
            secondViewController.categoryName = categoryName
            secondViewController.wordSearch = wordSearch

            show(secondViewController, sender: nil)
        }
    }
    
    @IBAction func goToSearchNews(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        wordSearch = searcByText.text!
           print(wordSearch) //this prints My text
        
        
        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
        secondViewController.name = name
        secondViewController.searchByCountry = searchByCountry
        secondViewController.typeOfFunc = typeOfFunc
        secondViewController.categoryName = categoryName
        secondViewController.wordSearch = wordSearch

        show(secondViewController, sender: nil)
        
    }
    
}





extension MenuViewController: UITableViewDelegate {
    func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if typeSettings[indexPath.row] == "category" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "category") as? CatogoryViewController else { return }
            secondViewController.name = name
            secondViewController.typeOfFunc = typeOfFunc
            secondViewController.searchByCountry = searchByCountry
            secondViewController.categoryName = categoryName
            secondViewController.wordSearch = wordSearch
            
            show(secondViewController, sender: nil)
        }
        if typeSettings[indexPath.row] == "country" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "country") as? CountryViewController else { return }
            secondViewController.name = name
            secondViewController.typeOfFunc = typeOfFunc
            secondViewController.searchByCountry = searchByCountry
            secondViewController.categoryName = categoryName
            secondViewController.wordSearch = wordSearch
            
            show(secondViewController, sender: nil)
        }
        
        if typeSettings[indexPath.row] == "marker" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "marker") as? MarkerViewController else { return }
            secondViewController.name = name
            secondViewController.typeOfFunc = typeOfFunc
            secondViewController.searchByCountry = searchByCountry
            secondViewController.categoryName = categoryName
            secondViewController.wordSearch = wordSearch
            secondViewController.markerArticles = markerArticles

            show(secondViewController, sender: nil)
        }
        
    }
}


extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
//var arrayTextField = [UITextField]()

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            print("create")
        }
        
        if typeSettings[indexPath.row] == "textfield" {
            
        }
        
        cell?.textLabel!.text = typeSettings[indexPath.row]
        if typeSettings[indexPath.row] == "top" {
            let switchView = UISwitch(frame: .zero)
            if typeOfFunc == "top" {
                switchView.setOn(true, animated: true)
            }
            else{
                switchView.setOn(false, animated: true)
            }
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            
            cell?.accessoryView = switchView
            
        }
        return cell!
    }
    
    
    @objc func switchChanged(_ sender: UISwitch!){
        //print("Table row switch Changed\(sender.tag)")
        print("Thw switch is \(sender.isOn ? "ON" : "OFF")")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
        if sender.isOn {
            secondViewController.typeOfFunc = "top"
        }
        else{
            secondViewController.typeOfFunc = "none"
        }
        secondViewController.name = name
        secondViewController.searchByCountry = searchByCountry
        secondViewController.categoryName = categoryName
        secondViewController.wordSearch = wordSearch
        
        show(secondViewController, sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

