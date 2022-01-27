//
//  MenuViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 10.01.22.
//

import UIKit
import Firebase

class MenuViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searcByText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var nextView = 0
    var typeOfFunc = ""
    var name: String = ""
    var searchByCountry: String = ""
    var categoryName: String = ""
    var wordSearch: String = ""
    var sourcesName: String = ""
    var nameUsers: String = ""
    
    var typeSettings: [String] = ["top","category","country","marker","sources","signout","voice"]
    var settingsTableArray: [String] = []
    var markerArticles: [Article]? = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(wordSearch == "none" || wordSearch == "") && ( sourcesName == "none" || sourcesName == "" ) {
            typeSettings.remove(at: 0)
        }

        
        
        tableView.dataSource = self
        tableView.delegate = self
        searcByText.delegate = self
        if wordSearch == "none"{
            searcByText.text = ""
        }
        else{
            searcByText.text = wordSearch
        }
    }
    
    @IBAction func secretButton(_ sender: Any) {
        
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
            secondViewController.searchByCountry = searchByCountry
            secondViewController.typeOfFunc = typeOfFunc
            secondViewController.categoryName = categoryName
            secondViewController.wordSearch = wordSearch
            secondViewController.markerArticles = markerArticles
            secondViewController.sourcesName = sourcesName
            show(secondViewController, sender: nil)
        }
    }
    
    @IBAction func goToSearchNews(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        wordSearch = searcByText.text!
        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
        secondViewController.name = name
        secondViewController.searchByCountry = searchByCountry
        secondViewController.typeOfFunc = typeOfFunc
        secondViewController.categoryName = categoryName
        secondViewController.wordSearch = wordSearch
        secondViewController.sourcesName = sourcesName
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
            secondViewController.sourcesName = sourcesName
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
            secondViewController.sourcesName = sourcesName
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
            secondViewController.sourcesName = sourcesName
            secondViewController.nameUsers = nameUsers

            show(secondViewController, sender: nil)
        }
        if typeSettings[indexPath.row] == "voice" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "voice") as? VoiceViewController else { return }
//            secondViewController.name = name
//            secondViewController.typeOfFunc = typeOfFunc
//            secondViewController.searchByCountry = searchByCountry
//            secondViewController.categoryName = categoryName
//            secondViewController.wordSearch = wordSearch
//            secondViewController.markerArticles = markerArticles
//            secondViewController.sourcesName = sourcesName
//            secondViewController.nameUsers = nameUsers

            show(secondViewController, sender: nil)
        }
        
        if typeSettings[indexPath.row] == "sources" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "sources") as? SourcesViewController else { return }
            secondViewController.name = name
            secondViewController.typeOfFunc = typeOfFunc
            secondViewController.searchByCountry = searchByCountry
            secondViewController.categoryName = categoryName
            secondViewController.wordSearch = wordSearch
            secondViewController.sourcesName = sourcesName
            show(secondViewController, sender: nil)
        }
        
        if typeSettings[indexPath.row] == "signout" {
            
            do {
                try Auth.auth().signOut()
                
            } catch{
                print(error)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
            
            self.show(secondViewController, sender: nil)
        }
        
    }
}


extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
        if sender.isOn {
            secondViewController.typeOfFunc = "top"
        }
        else{
            secondViewController.typeOfFunc = "none"
        }
        
        secondViewController.name = name
        secondViewController.categoryName = categoryName
        secondViewController.searchByCountry = searchByCountry
        secondViewController.wordSearch = wordSearch
        secondViewController.markerArticles = markerArticles
        secondViewController.sourcesName = sourcesName
        show(secondViewController, sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

