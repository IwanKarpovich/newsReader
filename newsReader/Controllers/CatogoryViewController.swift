//
//  CatogoryViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 11.01.22.
//

import UIKit

class CatogoryViewController: UIViewController {
    var checkIndex: Int = 1
    var numberIndex: IndexPath = []
    var categoryName: String = ""
    var typeOfFunc = ""
    var name: String = ""
    var searchByCountry: String = ""
    var wordSearch: String = ""
    var sourcesName: String = ""
    var markerArticles: [Article]? = []
    var userNames: String = ""
    
    
    var categoryArray: [String] = ["business","entertainment", "general","health","science","sports","technology","none"]
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    
    @IBAction func backToNews(_ sender: Any) {
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

extension CatogoryViewController: UITableViewDelegate {
    func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if checkIndex == 1 {
            tableView.cellForRow(at: numberIndex)?.accessoryType = .none
            checkIndex -= 1
        }
        if tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType == .checkmark{
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
        }
        else{
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
            checkIndex += 1
            numberIndex = indexPath
            categoryName = categoryArray[indexPath.row]
        }
        
    }
}


extension CatogoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        if categoryArray[indexPath.row] == categoryName {
            cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
            numberIndex = indexPath
        }
        cell?.textLabel!.text = categoryArray[indexPath.row]
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
