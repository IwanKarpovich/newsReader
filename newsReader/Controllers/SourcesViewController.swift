//
//  SourcesViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 23.01.22.
//

import UIKit

class SourcesViewController: UIViewController {
    var checkIndex: Int = 1
    var numberIndex: IndexPath = []
    var categoryName: String = ""
    var typeOfFunc = ""
    var name: String = ""
    var searchByCountry: String = ""
    var wordSearch: String = ""
    var sourcesName: String = "none"
    
    
    var sourcesArray: [String] = ["abc-news","abc-news-au","aftenposten","al-jazeera-english","ansa","argaam","ars-technica","ary-news","associated-press","australian-financial-review","axios","bbc-news","bbc-sport","bild","blasting-news-br","bleacher-report","bloomberg","breitbart-news","business-insider","business-insider-uk","buzzfeed","cbc-news","cbs-news","cnn","cnn-es","crypto-coins-news","der-tagesspiegel","die-zeit","el-mundo","engadget","entertainment-weekly","espn","espn-cric-info","financial-post","focus","football-italia","fortune","four-four-two","fox-news","fox-sports","globo","google-news","google-news-ar","google-news-au","google-news-br","google-news-ca","google-news-fr","google-news-in","google-news-is","google-news-it","google-news-ru","google-news-sa","google-news-uk","goteborgs-posten","gruenderszene","hacker-news","handelsblatt","ign","il-sole-24-ore","independent","infobae","info-money","la-gaceta","la-nacion","la-repubblica","le-monde","lenta","lequipe","les-echos","liberation","marca","mashable","medical-news-today","msnbc","mtv-news","mtv-news-uk","national-geographic","national-review","nbc-news","news24","new-scientist","news-com-au","newsweek","new-york-magazine","next-big-future","nfl-news","nhl-news","nrk","politico","polygon","rbc","recode","reddit-r-all","reuters","rt","rte","rtl-nieuws","sabq","spiegel-online","svenska-dagbladet","t3n","talksport","techcrunch","techcrunch-cn","techradar","the-american-conservative","the-globe-and-mail","the-hill","the-hindu","the-huffington-post","the-irish-times","the-jerusalem-post","the-lad-bible","the-next-web","the-sport-bible","the-times-of-india","the-verge","the-wall-street-journal","the-washington-post","the-washington-times","time","usa-today","vice-news","wired","wired-de","wirtschafts-woche","xinhua-net","ynet", "none"]
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    @IBAction func backToNews(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "menu") as? MenuViewController else { return }

        secondViewController.categoryName = categoryName
        secondViewController.name = name
        
        if sourcesName == "none" {
            typeOfFunc = "top"
        }
        secondViewController.typeOfFunc = typeOfFunc
        secondViewController.searchByCountry = searchByCountry
        secondViewController.wordSearch = wordSearch
        secondViewController.sourcesName = sourcesName
        show(secondViewController, sender: nil)
        

        
    }
    
    
}

extension SourcesViewController: UITableViewDelegate {
    func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType == .checkmark{
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
        }
        else{
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
            checkIndex += 1
            numberIndex = indexPath
            sourcesName = sourcesArray[indexPath.row]
        }
        tableView.reloadData()
        
        
    }
}


extension SourcesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourcesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "indexPath")
        
    
        if  sourcesArray[indexPath.row] == sourcesName {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            numberIndex = indexPath
        }
        cell.textLabel!.text = sourcesArray[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
