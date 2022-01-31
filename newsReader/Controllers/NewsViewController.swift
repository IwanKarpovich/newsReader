//
//  ViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 7.01.22.
//

import UIKit
import Network
import Firebase


class NewsViewController: UIViewController {
    
    
  
//    var userNames = ""
//    var name = "offline"
//    var typeOfFunc = "top"
//    var categoryName: String = "none"
//    var searchByCountry: String = ""
//    var wordSearch: String = "none"
//    var selectedArticle: Article?
//    var sourcesName: String = "none"
//    var markerArticles: [Article]? = []

    
    var handle: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var newsReaderLabel: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    // var articles: [Article]? = []
    
    var settingsTableArray: [String] = []
    
    override func viewWillDisappear( _ animated: Bool){
        super.viewWillDisappear(animated)
        if let handle = handle{
            Auth.auth().removeStateDidChangeListener(handle)
        }
    
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        handle = Auth.auth().addStateDidChangeListener{ [self](auth, user) in
            
            if user == nil{
                goToAuthefication()
            }
            else  {
                nextView.userNames = (user?.email)!
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-\(nextView.userNames)",
                    AnalyticsParameterItemName: nextView.userNames,
                    AnalyticsParameterContentType: "cont",
                ])
                Analytics.setUserProperty(nextView.userNames, forName: "name users - ")
                Analytics.setUserID(nextView.userNames)
                
                if nextView.markerArticles!.count == 0 {
                    let db = Firestore.firestore()
                    
                    db.collection("users").document(nextView.userNames).collection("markers").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            addArticleToMarkersList(querySnapshot)
                        }
                    }
                    
                }
                
            }
        }
        
        settingsTableArray = []
       
        //self.collectionView.reloadData()
        
        nextView.searchByCountry = searchCountry(country: nextView.searchByCountry)
        
        
        nextView.wordSearch = search(search: nextView.wordSearch)
        settingsTableArray = [nextView.typeOfFunc , nextView.searchByCountry,nextView.categoryName , nextView.wordSearch,nextView.sourcesName]
        settingsTableArray = settingsTableArray.filter(){$0 != "none"}
        
        typeOfInternet(name: nextView.name)
        
        monitNetwork()
        //tableView.reloadData()

//        var index:IndexPath = [0,0]
//        settingsTableArray.remove(at: 0)
       //self.collectionView.reloadData()//deleteItems(at: [IndexPath(row: 0, section: 0)])
        
        self.collectionView.reloadData()
        //self.collectionView.dataSource = self
        //self.collectionView.delegate = self
 
       // collectionView.reloadItems(at: [(0,3)])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser(){
            let vc = storyboard?.instantiateViewController(identifier: "welcome") as! WelcomeViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    

    
//    override func viewWillAppear( _ animated: Bool) {
//        super.viewWillAppear(animated)
    override func viewDidLoad() {
        super.viewDidLoad()

        
 
        
        nextView.searchByCountry = searchCountry(country: nextView.searchByCountry)
        
        
        nextView.wordSearch = search(search: nextView.wordSearch)
        settingsTableArray = [nextView.typeOfFunc,nextView.categoryName , nextView.searchByCountry, nextView.wordSearch,nextView.sourcesName]
        settingsTableArray = settingsTableArray.filter(){$0 != "none"}

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell")
        tableView.register(UINib(nibName: "BadTableViewCell", bundle: nil), forCellReuseIdentifier: "BadTableViewCell")

        
        self.collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        typeOfInternet(name: nextView.name)
        
        monitNetwork()
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
            nextView.markerArticles?.append(article)
        }
    }
    
    func typeOfInternet(name: String){
        if name == "offline" {
            testFunc1()
        }
        else{
            
            fetchArticles(type: nextView.typeOfFunc,category: nextView.categoryName,country: nextView.searchByCountry,search: nextView.wordSearch, source: nextView.sourcesName)
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
        
//        secondViewController.name = name
//        secondViewController.typeOfFunc = typeOfFunc
//        secondViewController.searchByCountry = searchByCountry
//        secondViewController.categoryName = categoryName
//        secondViewController.wordSearch = wordSearch
//        secondViewController.markerArticles = markerArticles
//        secondViewController.sourcesName = sourcesName
//        secondViewController.userNames = userNames
        
       // show(secondViewController, sender: nil)
        navigationController?.pushViewController(secondViewController, animated: true)
     
       // present(secondViewController, animated: true)
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
            nextView.searchByCountry = country!
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
            newcategoryName = ""+"category=" + category + "&"
        }
        
        
//        if source == "none"{
//            newSourceName = ""
//        }
//        else{
//            newSourceName = ""+"sources=" + source + "&"
//        }
        
        if country == "none"{
            newCountry = ""
        }
        else{
            newCountry = "country=" + country + "&"
        }
        
        if source == "none"{
            newSourceName = ""
        }
        else{
            newcategoryName = ""
            newCountry = ""

            newSourceName = ""+"sources=" + source + "&"
        }
        
        if search == "none"{
            newSearchName = ""
        }
        else{
            
            newSearchName = "q=" + search + ""
            
            if newSourceName != "none"{
                newSearchName = newSearchName + "&"
            }
        }

        
        
        if type == "top" {
            let lastCategoryName = newCountry+newcategoryName+newSourceName
            
            urlstring = "https://newsapi.org/v2/top-headlines?" + newSearchName + lastCategoryName + "pageSize=100&apiKey=7da15afd85a443ab8a7e06ce2778bcc5"
            
            //0d86c989d6a64f0693508f45a227d8a8
        }
        else{
//            if newSearchName == "" {
//                newSearchName = "q=bitcoin"
//            }
            urlstring = "https://newsapi.org/v2/everything?" + newSearchName + newSourceName + "pageSize=100&apiKey=7da15afd85a443ab8a7e06ce2778bcc5"
            
        }
        
        
        // Articles self.tableView.reloadData()
        articlesState.requestArticle(urlstring: urlstring, onSuccess: self.tableView.reloadData)
    }
    
    
    @IBAction func buttonDown(_ sender: Any) {
    }
    
   
    func testFunc1(){
        let data = Data(inputJSON.utf8)
        
        let newArticles = articlesState.parseJson(data)
        articlesState.setArticles(newArticles:newArticles,onSuccess:  self.tableView.reloadData)
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
extension NewsViewController: UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if articlesState.articles.count == 0{
            return 1 //settingsTableArray.count//typeSettings.count
            }
            else{
            return 0
            }
        }
        else {
            return articlesState.articles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
            
            cell.title.text = articlesState.articles[indexPath.item].headline
            
            cell.desc.text = articlesState.articles[indexPath.item].desc
            cell.author.text = articlesState.articles[indexPath.item].author
            if let imageURL = articlesState.articles[indexPath.item].imageUrl {
                cell.imgView.downloadImage(from: (imageURL) as String)
            }
            
            return cell
            
        }
        else {

            let cell = tableView.dequeueReusableCell(withIdentifier: "BadTableViewCell", for: indexPath) as! BadTableViewCell
            
            cell.textBadeLabel.text = "No results found"
//            let imageAttachment = NSTextAttachment()
//            imageAttachment.image = UIImage(systemName: "x.circle")
//
//            // If you want to enable Color in the SF Symbols.
//
//            let fullString = NSMutableAttributedString(string: "  \(settingsTableArray[indexPath.row]) NEWS ")
//            fullString.append(NSAttributedString(attachment: imageAttachment))
//            fullString.append(NSAttributedString(string: "  "))
//
//            cell.chipLabel.attributedText = fullString
            
            
            
            

            
            return cell
//
        }
        
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {
        
        let swipeMarker = UIContextualAction(style: .destructive, title: "marker") { [self]
            (action, view ,success) in
            self.tableView.performBatchUpdates({
                
                let selectedArticleHeadline = articlesState.articles[indexPath.row].headline
                let db = Firestore.firestore()
                let userMarkers = db.collection("users").document(nextView.userNames).collection("markers")
                
                
                let articleIndex = (nextView.markerArticles?.firstIndex(where: { $0.headline == selectedArticleHeadline }))
                if let articleIndex = articleIndex
                {
                    userMarkers.document("marker\(selectedArticleHeadline ?? "")").delete()
                    nextView.markerArticles?.remove(at: articleIndex)
                    
                }
                else{
                    nextView.markerArticles?.append(articlesState.articles[indexPath.row])
                    userMarkers.document("marker\( nextView.markerArticles![nextView.markerArticles!.count - 1].headline ?? "")").setData([
                        "headline": nextView.markerArticles![nextView.markerArticles!.count - 1].headline as Any,
                        "desc":  nextView.markerArticles![nextView.markerArticles!.count - 1].desc as Any,
                        "author":  nextView.markerArticles![nextView.markerArticles!.count - 1].author as Any,
                        "url":  nextView.markerArticles![nextView.markerArticles!.count - 1].url as Any,
                        "imageUrl":  nextView.markerArticles![nextView.markerArticles!.count - 1].imageUrl as Any,
                        "marker": nextView.markerArticles![nextView.markerArticles!.count - 1].marker,
                        "note":" "
                    ])
                }
            }, completion: {(result) in success(true)})
        }
        let selectedArticleUrl = articlesState.articles[indexPath.row].url
        let articleIndex = (nextView.markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
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
            nextView.selectedArticle = articlesState.articles[indexPath.row]
//            secondViewController.name = name
//            secondViewController.typeOfFunc = typeOfFunc
            nextView.url = articlesState.articles[indexPath.item].url
//            secondViewController.categoryName = categoryName
//            secondViewController.searchByCountry = searchByCountry
//            secondViewController.wordSearch = wordSearch
//            secondViewController.selectedArticle = selectedArticle
//            secondViewController.markerArticles = markerArticles
//            secondViewController.userNames = userNames
//            secondViewController.sourcesName = sourcesName
            
            show(secondViewController, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        var height: CGFloat = 205.0
        if indexPath.section  == 0 {
            height = 800
            
        }
        return height
        
    }
    
}
extension NewsViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView (_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // settingsTableArray.remove(at: indexPath.row)
        

     //collectionView.reloadData()
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingsTableArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.textLabel.text = " " + settingsTableArray[indexPath.row] + "  "

//        cell.textLabel.layer.masksToBounds = true
        cell.textLabel.layer.cornerRadius = 14
    
//        cell.textLabel.layer.borderColor = UIColor.lightGray.cgColor
//        cell.textLabel.layer.borderWidth = 1.0
//        cell.layer.borderWidth = Constants.borderWidth
//        cell.layer.borderColor = UIColor.lightGray.cgColor
    //    var heights = [10.0,20.0,30.0,40.0,50.0,60.0,70.0,80.0,90.0,100.0,110.0] as [CGFloat]
      //  cell.textLabel.sizeToFit()
        return cell
        
    }

 

    
}
private enum Constants {
    static let spacing: CGFloat = 28
    static let borderWidth: CGFloat = 1
    static let reuseID = "CollectionCell"
}
