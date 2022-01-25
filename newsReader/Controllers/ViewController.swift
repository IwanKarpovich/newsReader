//
//  ViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 7.01.22.
//

import UIKit
import Network
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var timer: Timer?
    
    var nameUsers = ""
    var name = "offline"
    var typeOfFunc = "top"
    var categoryName: String = "none"
    var searchByCountry: String = ""
    var wordSearch: String = "none"
    var selectedArticle: Article?
    var handle: AuthStateDidChangeListenerHandle?
    var sourcesName: String = "none"
    
    
    
    @IBOutlet weak var newsReaderLabel: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    var articles: [Article]? = []
    var settingsTableArray: [String] = []
    var markerArticles: [Article]? = []
    var didSelectedArticle: Article?
    
    override func viewWillDisappear( _ animated: Bool){
        super.viewWillDisappear(animated)
        if let handle = handle{
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser(){
            let vc = storyboard?.instantiateViewController(identifier: "welcome") as! WelcomeViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    fileprivate func addArticleToMarkersList(_ querySnapshot: QuerySnapshot?) {
        for document in querySnapshot!.documents {
            let headline = document.get("headline") as! String
            let desc = document.get("desc") as! String
            let author = document.get("author") as? String
            let url = document.get("url") as! String
            let imageUrl = document.get("imageUrl") as! String
            
            let article = Article()
            article.author = author
            article.desc = desc
            article.headline = headline
            article.url = url
            article.imageUrl = imageUrl
            self.markerArticles?.append(article)
        }
    }
    
    override func viewWillAppear( _ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        handle = Auth.auth().addStateDidChangeListener{ [self](auth, user) in
            
            if user == nil{
                goToAuthefication()
            }
            else  {
                self.nameUsers = (user?.email)!
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-\(nameUsers)",
                    AnalyticsParameterItemName: nameUsers,
                    AnalyticsParameterContentType: "cont",
                ])
                Analytics.setUserProperty(nameUsers, forName: "name users - ")
                Analytics.setUserID(nameUsers)
                
                if markerArticles!.count == 0 {
                    let db = Firestore.firestore()
                    
                    db.collection("users").document(nameUsers).collection("markers").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            addArticleToMarkersList(querySnapshot)
                        }
                    }
               
                }
                
            }
        }
        
        searchByCountry = searchCountry(country: searchByCountry)


        wordSearch = search(search: wordSearch)
        settingsTableArray = [typeOfFunc, categoryName , searchByCountry, wordSearch,sourcesName]
        settingsTableArray = settingsTableArray.filter(){$0 != "none"}
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell")
  
        typeOfInternet(name: name)

        monitNetwork()
    }
    
    func typeOfInternet(name: String){
        if name == "offline" {
            testFunc1()
        }
        else{
            
            fetchArticles(type: typeOfFunc,category: categoryName,country: searchByCountry,search: wordSearch, source: sourcesName)
        }
    }
    
    
    func goToAuthefication() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "auth") as? AuthViewController else { return }
        
        self.show(secondViewController, sender: nil)
        
    }
    
    func monitNetwork() {
        var number: Int = 1
        
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    
                }
                
            } else {
                DispatchQueue.main.async {
                    number += 1
                    if number % 2 == 0{
                        let alert = UIAlertController(title:"WARNING", message: "YOU DON'T HANE INTERNET", preferredStyle: .alert)
                        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okBtn)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    
    @IBAction func menuButton(_ sender: Any) {
        
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "menu") as? MenuViewController else { return }
        
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
    
    func search(search:String) -> String{
    if search == "" {
        let newSearch = "none"
        return newSearch
     }
        return search
    }
    func searchCountry(country: String) -> String{
        if country == ""{
            let locale: NSLocale = NSLocale.current as NSLocale
            var country: String? = locale.countryCode
            if country == "BY" {
                country = "RU"
            }
            searchByCountry = country!
            return country!
        }
        return country
    }
    
    func fetchArticles(type: String, category: String,country: String,search: String,source: String){
        var urlstring: String = ""
        var newcategoryName = ""
        var newSearchName = ""
        var newSourceName = ""
        var newCountry = ""
        if category == "none"{
            newcategoryName = ""
        }
        else{
            newcategoryName = "&"+"category=" + category
        }
        
        if search == "none"{
            newSearchName = ""
        }
        else{
            newSearchName = "q=" + search + "&"
        }
        
        if source == "none"{
            newSourceName = ""
        }
        else{
            newSourceName = ""+"sources=" + source
        }
        
        if country == "none"{
            newCountry = ""
        }
        else{
            newCountry = "country=" + country
        }
        
        
        if type == "top" {
            let lastCategoryName = newCountry+newcategoryName+newSourceName
            
            urlstring = "https://newsapi.org/v2/top-headlines?" + newSearchName + lastCategoryName + "&apiKey=7da15afd85a443ab8a7e06ce2778bcc5"
            
            
        }
        else{
            if newSearchName == "" {
                newSearchName = "q=bitcoin" + "&"
            }
            urlstring = "https://newsapi.org/v2/everything?" + newSearchName + "apiKey=7da15afd85a443ab8a7e06ce2778bcc5"
            
        }
        
        let urlRequest =  URLRequest(url: URL(string: urlstring)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest){
            (data,response,error) in
            
            if error != nil {
                return
            }
            
            self.articles = [Article]()
            do{
                
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                if let articlesFromJson = json["articles"] as? [[String:AnyObject]] {
                    for articlesFromJson in articlesFromJson{
                        let article = Article()
                        let title = articlesFromJson["title"] as? String
                        let author = articlesFromJson["author"] as? String
                        let desc = articlesFromJson["description"] as? String
                        let url = articlesFromJson["url"] as? String
                        let urlToImage = articlesFromJson["urlToImage"] as? String
                        
                        
                        article.author = author
                        article.desc = desc
                        article.headline = title
                        article.url = url
                        article.imageUrl = urlToImage
                        
                        self.articles?.append(article)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch{
                print(error)
            }
        }
        
        task.resume()
    }
    
    
    @IBAction func buttonDown(_ sender: Any) {
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return settingsTableArray.count//typeSettings.count
        }
        else {
            return self.articles?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
            
            cell.title.text = self.articles?[indexPath.item].headline
            
            cell.desc.text = self.articles?[indexPath.item].desc
            cell.author.text = self.articles?[indexPath.item].author
            if let imageURL = self.articles?[indexPath.item].imageUrl {
                cell.imgView.downloadImage(from: (imageURL) as String)
            }
            
            return cell
            
        }
        else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            
            
            
            cell?.backgroundColor = UIColor.systemGray5
            cell?.layer.cornerRadius = 8
            cell?.textLabel!.text = settingsTableArray[indexPath.row] + " news"
            
            return cell!
            
        }
        
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {
        
        let swipeMarker = UIContextualAction(style: .destructive, title: "marker") { [self]
            (action, view ,success) in
            self.tableView.performBatchUpdates({
                
                let selectedArticleHeadline = articles![indexPath.row].headline
                let db = Firestore.firestore()
                let washingtonRef = db.collection("users").document(nameUsers).collection("markers")
                
                
                let articleIndex = (markerArticles?.firstIndex(where: { $0.headline == selectedArticleHeadline }))
                if let articleIndex = articleIndex
                {
                    washingtonRef.document("marker\(selectedArticleHeadline ?? "")").delete()
                    markerArticles?.remove(at: articleIndex)
                    
                }
                else{
                    self.markerArticles?.append(self.articles![indexPath.row])
                    washingtonRef.document("marker\( markerArticles![markerArticles!.count - 1].headline ?? "")").setData([
                        "headline":markerArticles![markerArticles!.count - 1].headline!,
                        "desc": markerArticles![markerArticles!.count - 1].desc!,
                        "author": markerArticles![markerArticles!.count - 1].author!,
                        "url": markerArticles![markerArticles!.count - 1].url!,
                        "imageUrl": markerArticles![markerArticles!.count - 1].imageUrl!,
                        "marker": markerArticles![markerArticles!.count - 1].marker
                    ])
                }
            }, completion: {(result) in success(true)})
        }
        let selectedArticleUrl = articles![indexPath.row].url
        let articleIndex = (markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
        if articleIndex != nil {
            swipeMarker.image = UIImage(systemName: "star.fill")
            
            
        }
        else{
            swipeMarker.image = UIImage(systemName: "star")
            
        }
        swipeMarker.backgroundColor = UIColor.systemBlue
        
        
        let configure = UISwipeActionsConfiguration(actions: [swipeMarker])
        configure.performsFirstActionWithFullSwipe = false
        return configure
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section  == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let secondViewController = storyboard.instantiateViewController(identifier: "web") as? WebViewController else { return }
            selectedArticle = articles![indexPath.row]
            secondViewController.name = name
            secondViewController.typeOfFunc = typeOfFunc
            secondViewController.url = self.articles?[indexPath.item].url
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        var height: CGFloat = 205.0
        if indexPath.section  == 0 {
            height = 20
        }
        return height
        
    }
    
    func testFunc1(){
        let data = Data(inputJSON.utf8)
        
        print(data)
        self.articles = [Article]()
        
        do{
            
            if  let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]{
                if let articlesFromJson = json["articles"] as? [[String:AnyObject]] {
                    for articlesFromJson in articlesFromJson{
                        let article = Article()
                        let title = articlesFromJson["title"] as? String
                        let author = articlesFromJson["author"] as? String
                        let desc = articlesFromJson["description"] as? String
                        let url = articlesFromJson["url"] as? String
                        let urlToImage = articlesFromJson["urlToImage"] as? String
                        
                        
                        article.author = author
                        article.desc = desc
                        article.headline = title
                        article.url = url
                        article.imageUrl = urlToImage
                        self.articles?.append(article)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }} catch{
                print(error)
            }
    }
    
    enum NetworkError: Error {
        case invaidData
    }
}

extension UIImageView{
    func downloadImage(from url:String = "https://www.hzpc.com/uploads/overview-transparent-896/dc78aee8-3f50-5ba8-b8d3-6cf74852aa2b/3175818931/Colomba%20%282%29.png"){
        let const = URL(string: url)
        let urlRequest = URLRequest(url: const ?? URL(string: "https://www.hzpc.com/uploads/overview-transparent-896/dc78aee8-3f50-5ba8-b8d3-6cf74852aa2b/3175818931/Colomba%20%282%29.png")! )
        
        let task = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in
            if error != nil {
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}

class Core {
    
    static let shared = Core()
    
    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    func setIsNotNewUse(){
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}
