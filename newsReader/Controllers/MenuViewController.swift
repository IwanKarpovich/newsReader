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
    
     var mbnextView = 0
//    var typeOfFunc = ""
//    var name: String = ""
//    var searchByCountry: String = ""
//    var categoryName: String = ""
//    var wordSearch: String = ""
//    var sourcesName: String = ""
//    var userNames: String = ""
    
    var settingTypes: [String] = ["top","category","country","sources","marker","signout"]
    var settingsTableArray: [String] = []
//    var markerArticles: [Article]? = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        if(wordSearch == "none" || wordSearch == "") && ( sourcesName == "none" || sourcesName == "" ) {
        //            settingTypes.remove(at: 0)
        //        }
        
        if nextView.typeOfFunc == "none"{
            settingTypes.remove(at: 1)
            settingTypes.remove(at: 1)
        }
        
        
        tableView.dataSource = self
        tableView.delegate = self
        searcByText.delegate = self
        if nextView.wordSearch == "none"{
            searcByText.text = ""
        }
        else{
            searcByText.text = nextView.wordSearch
        }
    }
    @IBAction func deleteSearchName(_ sender: Any) {
        nextView.wordSearch = "none"
        searcByText.text = ""
        searcByText.reloadInputViews()
    }
    
    @IBAction func goToNews(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? NewsViewController else { return }
        if nextView.typeOfFunc == "none"{
            nextView.searchByCountry = "none"
            nextView.categoryName = "none"
        }
//        secondViewController.searchByCountry = searchByCountry
//        secondViewController.name = name
//        secondViewController.typeOfFunc = typeOfFunc
//        secondViewController.categoryName = categoryName
//        secondViewController.wordSearch = wordSearch
//        secondViewController.sourcesName = sourcesName
        navigationController?.popViewController(animated: true)

       // navigationController?.pushViewController(secondViewController, animated: true)

       // show(secondViewController, sender: nil)
    }
    
    @IBAction func secretButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        mbnextView+=1
#if DEBUG
        if mbnextView == 5 {
            guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? NewsViewController else { return }
            if nextView.name == "online" {
                nextView.name = "offline"
            }
            else {
                nextView.name = "online"
            }
//            secondViewController.searchByCountry = searchByCountry
//            secondViewController.typeOfFunc = typeOfFunc
//            secondViewController.categoryName = categoryName
//            secondViewController.wordSearch = wordSearch
//            secondViewController.markerArticles = markerArticles
//            secondViewController.sourcesName = sourcesName
            //navigationController?.popViewController(animated: true)
            show(secondViewController, sender: nil)
        }
#endif
    }
    
    @IBAction func goToSearchNews(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        nextView.wordSearch = searcByText.text!
        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? NewsViewController else { return }
//        secondViewController.name = name
//        secondViewController.searchByCountry = searchByCountry
//        secondViewController.typeOfFunc = typeOfFunc
//        secondViewController.categoryName = categoryName
//        secondViewController.wordSearch = wordSearch
//        secondViewController.sourcesName = sourcesName
        navigationController?.popViewController(animated: true)

        //show(secondViewController, sender: nil)
        
    }
    
}

extension MenuViewController: UITableViewDelegate {
    func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if settingTypes[indexPath.row + 1] == "category" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "category") as? CatogoryViewController else { return }
//            secondViewController.name = name
//            secondViewController.typeOfFunc = typeOfFunc
//            secondViewController.searchByCountry = searchByCountry
//            secondViewController.categoryName = categoryName
//            secondViewController.wordSearch = wordSearch
//            secondViewController.markerArticles = markerArticles
//            secondViewController.sourcesName = sourcesName
//            secondViewController.userNames = userNames
            navigationController?.pushViewController(secondViewController, animated: true)

            //   show(secondViewController, sender: nil)
        }
        if settingTypes[indexPath.row + 1] == "country" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "country") as? CountryViewController else { return }
//            secondViewController.name = name
//            secondViewController.typeOfFunc = typeOfFunc
//            secondViewController.searchByCountry = searchByCountry
//            secondViewController.categoryName = categoryName
//            secondViewController.wordSearch = wordSearch
//            secondViewController.markerArticles = markerArticles
//            secondViewController.sourcesName = sourcesName
//            secondViewController.userNames = userNames
            navigationController?.pushViewController(secondViewController, animated: true)

            //  show(secondViewController, sender: nil)
        }
        
        if settingTypes[indexPath.row + 1] == "marker" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "marker") as? MarkerViewController else { return }
//            secondViewController.name = name
//            secondViewController.typeOfFunc = typeOfFunc
//            secondViewController.searchByCountry = searchByCountry
//            secondViewController.categoryName = categoryName
//            secondViewController.wordSearch = wordSearch
//            secondViewController.markerArticles = markerArticles
//            secondViewController.sourcesName = sourcesName
//            secondViewController.userNames = userNames
            navigationController?.pushViewController(secondViewController, animated: true)

           // show(secondViewController, sender: nil)
        }
        if settingTypes[indexPath.row + 1] == "voice" {
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
            navigationController?.pushViewController(secondViewController, animated: true)

            //show(secondViewController, sender: nil)
        }
        
        if settingTypes[indexPath.row + 1] == "sources" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "sources") as? SourcesViewController else { return }
//            secondViewController.name = name
//            secondViewController.typeOfFunc = typeOfFunc
//            secondViewController.searchByCountry = searchByCountry
//            secondViewController.categoryName = categoryName
//            secondViewController.wordSearch = wordSearch
//            secondViewController.markerArticles = markerArticles
//            secondViewController.sourcesName = sourcesName
//            secondViewController.userNames = userNames
            navigationController?.pushViewController(secondViewController, animated: true)

          //  show(secondViewController, sender: nil)
        }
        
        if settingTypes[indexPath.row + 1] == "signout" {
            
            do {
                try Auth.auth().signOut()
                
            } catch{
                print(error)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? NewsViewController else { return }
            nextView.markerArticles = []
            self.show(secondViewController, sender: nil)
        }
        
    }
}


extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        } else{
            return settingTypes.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            
            if settingTypes[indexPath.row] == "textfield" {
                
            }
            
            cell?.textLabel!.text = settingTypes[indexPath.row]
            
            
            if settingTypes[indexPath.row] == "top" {
                let switchView = UISwitch(frame: .zero)
                if nextView.typeOfFunc == "top" {
                    switchView.setOn(true, animated: true)
                }
                else{
                    switchView.setOn(false, animated: true)
                }
                //switchView.tag = indexPath.row
                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                
                cell?.accessoryView = switchView
                
            }
            return cell!
        }
        else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "twocell")
            
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            

            
            cell?.textLabel!.text = settingTypes[indexPath.row + 1]
            
            
            //            if settingTypes[indexPath.row] == "top" {
            //                let switchView = UISwitch(frame: .zero)
            //                if typeOfFunc == "top" {
            //                    switchView.setOn(true, animated: true)
            //                }
            //                else{
            //                    switchView.setOn(false, animated: true)
            //                }
            //                switchView.tag = indexPath.row
            //                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            //
            //                cell?.accessoryView = switchView
            //
            //            }
            return cell!
        }
    }
    
    
    @objc func switchChanged(_ sender: UISwitch!){
        
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? NewsViewController else { return }
        if sender.isOn {
            nextView.typeOfFunc = "top"
            
            if nextView.typeOfFunc == "top"{
                settingTypes.insert("category", at: 1)
                settingTypes.insert("country", at: 1)
                
            }
        }
        else{
            nextView.typeOfFunc = "none"
            if nextView.typeOfFunc == "none"{
                settingTypes.remove(at: 1)
                settingTypes.remove(at: 1)
            }
        }
        //        if wordSearch == "none" {
        //            typeOfFunc = "top"
        //        }
        
        //        secondViewController.name = name
        //        secondViewController.categoryName = categoryName
        //        secondViewController.searchByCountry = searchByCountry
        //        secondViewController.wordSearch = wordSearch
        //        secondViewController.markerArticles = markerArticles
        //        secondViewController.sourcesName = sourcesName
        //        show(secondViewController, sender: nil)
        
       // deleteData(indexPath: [0,1])
        tableView.reloadData()
    }
    
    func deleteData(indexPath: IndexPath) {
           
           tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.reloadData()


   }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

