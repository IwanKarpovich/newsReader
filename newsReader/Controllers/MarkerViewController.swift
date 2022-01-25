//
//  MarkerViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 14.01.22.
//

import UIKit

class MarkerViewController: UIViewController {
    
    var numberIndex: IndexPath = []
    var categoryName: String = ""
    var typeOfFunc = ""
    var name: String = ""
    var searchByCountry: String = ""
    var wordSearch: String = ""
    var markerArticles: [Article]? = []
    var selectedArticle: Article?
    var sourcesName: String = ""
    var nameUsers: String = ""
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell")
        
    }
    
    @IBAction func goBackToMenu(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
        
        secondViewController.name = name
        secondViewController.typeOfFunc = typeOfFunc
        secondViewController.searchByCountry = searchByCountry
        secondViewController.categoryName = categoryName
        secondViewController.wordSearch = wordSearch
        secondViewController.markerArticles = markerArticles
        secondViewController.sourcesName = sourcesName
        show(secondViewController, sender: nil)
    }
    
}



extension MarkerViewController: UITableViewDelegate {
    func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedArticle = markerArticles![indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "web") as? WebViewController else { return }
        
        selectedArticle = markerArticles![indexPath.row]
        secondViewController.name = name
        secondViewController.typeOfFunc = typeOfFunc
        secondViewController.url = self.markerArticles?[indexPath.item].url
        secondViewController.categoryName = categoryName
        secondViewController.searchByCountry = searchByCountry
        secondViewController.wordSearch = wordSearch
        secondViewController.selectedArticle = selectedArticle
        secondViewController.markerArticles = markerArticles
        secondViewController.nameUsers = nameUsers
        secondViewController.sourcesName = sourcesName
        show(secondViewController, sender: nil)
        
        
    }
}


extension MarkerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return markerArticles!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        
        cell.title.text = self.markerArticles?[indexPath.item].headline
        cell.desc.text = self.markerArticles?[indexPath.item].desc
        cell.author.text = self.markerArticles?[indexPath.item].author
        if let imageURL = self.markerArticles?[indexPath.item].imageUrl {
            cell.imgView.downloadImage(from: (imageURL) )
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

