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
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            guard let secondViewController = storyboard.instantiateViewController(identifier: "welcome") as? WelcomeViewController else { return }
//            self.show(secondViewController, sender: nil)
        }
    }
    
    override func viewWillAppear( _ animated: Bool) {
        super.viewWillAppear(animated)
        

        
        handle = Auth.auth().addStateDidChangeListener{ [self](auth, user) in
            print("In FUNC")
            print(user)
            
            if user == nil{
                print("not error")
                goToAuthefication()
                //                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                //                guard let secondViewController = storyboard.instantiateViewController(identifier: "auth") as? AuthViewController else { return }
                //
                //                self.show(secondViewController, sender: nil)
                
                //self.showModalAuth()
            }
            else  {
                self.nameUsers = (user?.email)!
                print(nameUsers)
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-\(nameUsers)",
                  AnalyticsParameterItemName: nameUsers,
                  AnalyticsParameterContentType: "cont",
                ])
                Analytics.setUserProperty(nameUsers, forName: "name users - ")
                Analytics.setUserID(nameUsers)

                if markerArticles!.count == 0 {
                    let db = Firestore.firestore()
                    
                    // let docRef = db.collection("users").document(nameUsers).collection("markers").document("marker\(selectedArticleHeadline)")
                    db.collection("users").document(nameUsers).collection("markers").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let headline = document.get("headline") as! String
                                let desc = document.get("desc") as! String
                                let author = document.get("author") as? String
                                let url = document.get("url") as! String
                                let imageUrl = document.get("imageUrl") as! String
                                let marker = document.get("marker") as! Bool
                                let article = Article()
                                article.author = author
                                article.desc = desc
                                article.headline = headline
                                article.url = url
                                article.imageUrl = imageUrl
                                self.markerArticles?.append(article)
                            }
                        }
                    }
                    
                    
                }
                
            }
            
            
            
        }
        // self.navigationController!.navigationBar.isHidden = true
        
        if searchByCountry == ""{
            let locale: NSLocale = NSLocale.current as NSLocale
            var country: String? = locale.countryCode
            print(country ?? "no country")
            if country == "BY" {
                country = "RU"
            }
            searchByCountry = country!
            
        }
        if wordSearch == "" {
            wordSearch = "none"
        }
        settingsTableArray = [typeOfFunc, categoryName , searchByCountry, wordSearch,sourcesName]
        print(settingsTableArray)
        settingsTableArray = settingsTableArray.filter(){$0 != "none"}
        print(settingsTableArray)
        
        print(typeOfFunc)
        print(searchByCountry)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell")
        
        
        
        print(typeOfFunc)
        testFunc(rilo: "ruka")
        print(sourcesName)
        if name == "offline" {
            testFunc1()
        }
        else{
            
            fetchArticles(type: typeOfFunc,category: categoryName,country: searchByCountry,search: wordSearch, source: sourcesName)
        }
        print(name)
        print(categoryName)
        monitNetwork()
        
        
    }
    
    //    func Authefication() -> String {
    //        Auth.auth().addStateDidChangeListener{ [self](auth, user) in
    //            print("In FUNC")
    //            if user != nil{
    //            return user as String
    //            }
    //            else{
    //              return nil
    //            }
    //       }
    //    }
    
    func goToAuthefication() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "auth") as? AuthViewController else { return }
        
        self.show(secondViewController, sender: nil)
        
        //        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "auth")
        //        self.present(viewController!, animated: true)
    }
    
    func monitNetwork() {
        var number: Int = 1
        
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    
                    print("YOU HAVE INTERNET")
                    
                }
                
            } else {
                DispatchQueue.main.async {
                    number += 1
                    if number % 2 == 0{
                        let alert = UIAlertController(title:"WARNING", message: "YOU DON'T HANE INTERNET", preferredStyle: .alert)
                        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okBtn)
                        self.present(alert, animated: true, completion: nil)
                        
                        print("YOU DON'T HANE INTERNET")
                    }
                    
                    
                }
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    
    @IBAction func menuButton(_ sender: Any) {
        print("aer")
        print(markerArticles)
        let db = Firestore.firestore()
        
        
        //        let viewController = storyboard?.instantiateViewController(withIdentifier: "menu")
        //        self.present(viewController!, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "menu") as? MenuViewController else { return }
        
        secondViewController.name = name
        secondViewController.typeOfFunc = typeOfFunc
        secondViewController.searchByCountry = searchByCountry
        secondViewController.categoryName = categoryName
        secondViewController.wordSearch = wordSearch
        secondViewController.markerArticles = markerArticles
        secondViewController.sourcesName = sourcesName

        print("dsfsf")
        
        
        
        show(secondViewController, sender: nil)
        
    }
    
    func testFunc(rilo: String){
        print(rilo)
    }
    
    func fetchArticles(type: String, category: String,country: String,search: String,source: String){
        var urlstring: String = ""
        var newcategoryName = ""
        var newSearchName = ""
        var newSourceName = ""
        var newCountry = ""
        print(category)
        if category == "none"{
            newcategoryName = ""//"business"
        }
        else{
            newcategoryName = "&"+"category=" + category
        }
        
        
        
        
        if search == "none"{
            newSearchName = ""//"business"
        }
        else{
            newSearchName = "q=" + search + "&"
        }
        
        if source == "none"{
            newSourceName = ""//"business"
        }
        else{
            newSourceName = ""+"sources=" + source
        }
        
        if country == "none"{
            newCountry = ""//"business"
        }
        else{
            newCountry = "country=" + country
        }
        
        
        print(newcategoryName)
        if type == "top" {
            //country=us&
            var lastCategoryName = newCountry+newcategoryName+newSourceName
            
            urlstring = "https://newsapi.org/v2/top-headlines?" + newSearchName + lastCategoryName + "&apiKey=7da15afd85a443ab8a7e06ce2778bcc5"
            
            
        }
        else{
            //var lastCategoryName = "category=" + newcategoryName
            if newSearchName == "" {
                newSearchName = "q=bitcoin" + "&"
            }
            urlstring = "https://newsapi.org/v2/everything?" + newSearchName + "apiKey=7da15afd85a443ab8a7e06ce2778bcc5"
            
        }
        print(urlstring)
        
        
        
        let urlRequest =  URLRequest(url: URL(string: urlstring
                                              
                                              
                                             )!)
        
        //  "https://newsapi.org/v2/top-headlines?country=us&apiKey=7da15afd85a443ab8a7e06ce2778bcc5"
        
        let task = URLSession.shared.dataTask(with: urlRequest){
            (data,response,error) in
            
            if error != nil {
                
                print(error)
                return
            }
            
            self.articles = [Article]()
            //            if let data = data,
            //               let urlResponse = response as? HTTPURLResponse,
            //               urlResponse.statusCode == 200 {
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
        //      }
        
        task.resume()
        print("Evdfdffsfsf")
        
    }
    
    
    @IBAction func buttonDown(_ sender: Any) {
        print("da")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    //    func numberOfRowsInSection (_ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
    //
    //          return 1 //articles?.count ?? 0
    //        }
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
            //            print("Image")
            if let imageURL = self.articles?[indexPath.item].imageUrl {
                cell.imgView.downloadImage(from: (imageURL) as String)
            }
            
            return cell
            
        }
        else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                //                print("create")
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
                //                Firestore.firestore().collection("users")
                //                            .document(nameUsers)
                //                            .getDocument { (document, error) in
                //                                debugPrint(document?.exists)
                //                                if document?.exists ?? false {
                //
                //                                } else {
                //                                    washingtonRef.setData(["headline":[]])
                //                                }
                //                            }
                
                let articleIndex = (markerArticles?.firstIndex(where: { $0.headline == selectedArticleHeadline }))
                if let articleIndex = articleIndex
                {
                    washingtonRef.document("marker\(selectedArticleHeadline)").delete()
                    //                    washingtonRef.setData([
                    //                        "headline": FieldValue.arrayRemove([markerArticles![articleIndex].headline]),
                    //                        "desc": FieldValue.arrayRemove([markerArticles![articleIndex].desc]),
                    //                        "author": FieldValue.arrayRemove([markerArticles![articleIndex].author]),
                    //                        "url": FieldValue.arrayRemove([markerArticles![articleIndex].url]),
                    //                        "imageUrl": FieldValue.arrayRemove([markerArticles![articleIndex].imageUrl]),
                    //                        "marker": FieldValue.arrayRemove([markerArticles![articleIndex].marker])
                    //
                    //                    ])
                    markerArticles?.remove(at: articleIndex)
                
                    
                    
                }
                else{
                    self.markerArticles?.append(self.articles![indexPath.row])
                    //                    washingtonRef.updateData([
                    //                        "headline": FieldValue.arrayUnion([markerArticles![markerArticles!.count - 1].headline]),
                    //                        "desc": FieldValue.arrayUnion([markerArticles![markerArticles!.count - 1].desc]),
                    //                        "author": FieldValue.arrayUnion([markerArticles![markerArticles!.count - 1].author]),
                    //                        "url": FieldValue.arrayUnion([markerArticles![markerArticles!.count - 1].url]),
                    //                        "imageUrl": FieldValue.arrayUnion([markerArticles![markerArticles!.count - 1].imageUrl]),
                    //                        "marker": FieldValue.arrayUnion([markerArticles![markerArticles!.count - 1].marker])
                    //
                    //                    ])
                    washingtonRef.document("marker\( markerArticles![markerArticles!.count - 1].headline)").setData([
                        "headline":markerArticles![markerArticles!.count - 1].headline, //FieldValue.arrayRemove([markerArticles![markerArticles!.count - 1].headline]),
                        "desc": markerArticles![markerArticles!.count - 1].desc,//FieldValue.arrayRemove([markerArticles![markerArticles!.count - 1].desc]),
                        "author": markerArticles![markerArticles!.count - 1].author,//FieldValue.arrayRemove([markerArticles![markerArticles!.count - 1].author]),
                        "url": markerArticles![markerArticles!.count - 1].url,//FieldValue.arrayRemove([markerArticles![markerArticles!.count - 1].url]),
                        "imageUrl": markerArticles![markerArticles!.count - 1].imageUrl,//FieldValue.arrayRemove([markerArticles![markerArticles!.count - 1].imageUrl]),
                        "marker": markerArticles![markerArticles!.count - 1].marker//FieldValue.arrayRemove([markerArticles![markerArticles!.count - 1].marker])
                        
                    ])
                    
                    
                    
                }
                //        let docRef = db.collection("users").document(nameUsers)
                
                //                docRef.getDocument { (document, error) in
                //                    if let document = document, document.exists {
                //                        let dataDescription = document.get("regions") as! [String] //document.data().map(String.init(describing:)) ?? "nil"
                //                        print("Document data: \(dataDescription)")
                //                    } else {
                //                        print("Document does not exist")
                //                    }
                //                }
                print(markerArticles)
                print("delete")
                
                
            }, completion: {(result) in success(true)})
        }
        let selectedArticleUrl = articles![indexPath.row].url
        let articleIndex = (markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
        if let articleIndex = articleIndex {
            swipeMarker.image = UIImage(systemName: "star.fill")
            
            
        }
        else{
            swipeMarker.image = UIImage(systemName: "star")
            
        }
        swipeMarker.backgroundColor = UIColor.systemBlue
        
        
        let configure = UISwipeActionsConfiguration(actions: [swipeMarker])
        configure.performsFirstActionWithFullSwipe = false
        
        //        db.collection("users").document("marker").addDocument(data: [
        //            "headline": self.articles![indexPath.row].headline ,
        //            "desc": self.articles![indexPath.row].desc
        //
        //        ])
        
        
        return configure
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let webVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "web") as! WebViewController
        //        webVC.url = self.articles?[indexPath.item].url
        //        self.present(webVC, animated: true, completion: nil)
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

       

            //   secondViewController.articles = articles
            
            //   secondViewController.wordSearch = articles
            
            
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
                print(error)
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

let inputJSON = """
{"status":"ok","totalResults":1353,"articles":[{"source":{"id":"the-verge","name":"The Verge"},"author":"Richard Lawler","title":"Facebook finally has live chat support for people who are locked out of their accounts","description":"For the first time, Facebook is testing live chat agents for English-speaking users who have been locked out of their accounts. The updated support feature comes along with other changes to help creators manage their pages.","url":"https://www.theverge.com/2021/12/10/22827708/meta-facebook-instagram-account-lockout-support-tools","urlToImage":"https://cdn.vox-cdn.com/thumbor/cJN55ufuqlQ61k76Tq3BG7mGsic=/0x146:2040x1214/fit-in/1200x630/cdn.vox-cdn.com/uploads/chorus_asset/file/9441069/acastro_171002_1777_0004_v4.jpg","publishedAt":"2021-12-10T14:36:17Z","content":"Better customer support for creators and average users alike\\r\\nFacebook artwork\\r\\nIllustration by Alex Castro / The Verge\\r\\nDespite eagerly participating in a platform vs. platform war of escalating fin… [+2477 chars]"},{"source":{"id":null,"name":"VentureBeat"},"author":"wpengine","title":"LongTailPro can supercharge all of your SEO efforts for only $40","description":"LongTailPro is a nifty keyword suggestion tool that can help a business or manager find those skeleton key words that can unlock a bounty of new web traffic for your product.","url":"https://venturebeat.com/2021/12/30/longtailpro-can-supercharge-all-of-your-seo-efforts-for-only-40/","urlToImage":"https://venturebeat.com/wp-content/uploads/2021/12/sale_29427_article_image.jpg?w=1200&strip=all","publishedAt":"2021-12-30T15:00:00Z","content":"Long tail keywords are usually phrases of three words or more and theyre a lot more common in the search world than you might think. In fact, as much as 70 percent of all Google search traffic is a l… [+2269 chars]"},{"source":{"id":null,"name":"ReadWrite"},"author":"Timothy Carter","title":"Why Focusing on SEO Keywords is Hurting Your Campaign","description":"One of the first things you’ll need to do for any search engine optimization campaign is keyword research — at least, that’s what you’ll hear from most SEO experts. For the most part, I’m inclined to agree. Having the proper selection of target keywords can m…","url":"https://readwrite.com/2022/01/06/why-focusing-on-seo-keywords-is-hurting-your-campaign/","urlToImage":"https://images.readwrite.com/wp-content/uploads/2021/12/SEO-Keywords.jpg","publishedAt":"2022-01-06T15:00:58Z","content":"One of the first things youll need to do for any search engine optimization campaign is keyword research at least, thats what youll hear from most SEO experts. For the most part, Im inclined to agree… [+8015 chars]"},{"source":{"id":null,"name":"Gizmodo.com"},"author":"David Nield","title":"How to Organize Your Mess of a Dropbox Once and for All","description":"Dropbox is one of those huge, ubiquitous apps—like Gmail, or iMessage, or Spotify—that is constantly adding new features. But if you’re not using the service on a daily basis, you might miss some of the tools that have been added. The most recent Dropbox upgr…","url":"https://gizmodo.com/how-to-organize-your-mess-of-a-dropbox-once-and-for-all-1848265498","urlToImage":"https://i.kinja-img.com/gawker-media/image/upload/c_fill,f_auto,fl_progressive,g_center,h_675,pg_1,q_80,w_1200/153b6168d2ac09e7d46225cbe0f773cd.jpg","publishedAt":"2021-12-24T13:30:00Z","content":"Dropbox is one of those huge, ubiquitous appslike Gmail, or iMessage, or Spotifythat is constantly adding new features. But if youre not using the service on a daily basis, you might miss some of the… [+4691 chars]"},{"source":{"id":null,"name":"Gizmodo.com"},"author":"Brianna Provenzano","title":"TikTok Testing Feature That Lets You Stream Live From Your PC","description":"While almost every other app is trying to become TikTok, TikTok is apparently angling to be more like Twitch.Read more...","url":"https://gizmodo.com/tiktok-testing-feature-that-lets-you-stream-live-from-y-1848227244","urlToImage":"https://i.kinja-img.com/gawker-media/image/upload/c_fill,f_auto,fl_progressive,g_center,h_675,pg_1,q_80,w_1200/b8f3c567c26d4d7842c258ce0d67ab1d.jpg","publishedAt":"2021-12-16T18:25:00Z","content":"While almost every other app is trying to become TikTok, TikTok is apparently angling to be more like Twitch.\\r\\nOn Thursday, TechCrunch reported that TikTok is testing out something called TikTok Live… [+2035 chars]"},{"source":{"id":null,"name":"New York Times"},"author":"Lou Stoppard","title":"How Gen Z is Channeling 1990s Fashion","description":"The icons and fashions of the fin de siecle are objects of fascination for those who didn’t experience them the first time around. Here’s what they say about why.","url":"https://www.nytimes.com/2021/12/23/style/gen-z-fashion-1990s.html","urlToImage":"https://static01.nyt.com/images/2021/12/22/fashion/22GENZ-90s-1/22GENZ-90s-1-facebookJumbo.jpg","publishedAt":"2021-12-23T08:00:15Z","content":"James Abraham, 35, who runs the popular Instagram account @90sanxiety, which he started in 2016, sees the intrigue as related to the sense of something uncompromising about the period the rawness, th… [+1904 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Matt Southern","title":"Keyword Stemming: Is It A Google Ranking Factor? via @sejournal, @MattGSouthern","description":"Is keyword stemming a Google search ranking factor? Let\'s investigate those claims and get clarity around keyword stemming and its relationship with SEO.The post Keyword Stemming: Is It A Google Ranking Factor? appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/ranking-factors/keyword-stemming/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/12/chapter-48-61bb585be77df-sej.png","publishedAt":"2022-01-03T12:45:08Z","content":"When people talk about keyword stemming as a ranking factor, they’re referring to Google’s ability to recognize different variations of the same word.\\r\\nSince Google can understand when a user enters … [+3833 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Matt Southern","title":"Keyword Density: Is It A Google Ranking Factor? via @sejournal, @MattGSouthern","description":"Some still say keyword density matters, but should you be stressing about the percentage of keywords in your copy?The post Keyword Density: Is It A Google Ranking Factor? appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/ranking-factors/keyword-density/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/12/rf-keyword-density-61b865911d59a-sej.png","publishedAt":"2021-12-15T12:45:09Z","content":"Keyword density has long been thought of as a ranking factor.\\r\\nSome consider it an essential piece to the SEO puzzle for achieving a Page 1 position in Google.\\r\\nWhy is it so highly regarded?\\r\\nWe know… [+5579 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Matt Southern","title":"Keyword Prominence As A Google Ranking Factor: What You Need To Know via @sejournal, @MattGSouthern","description":"Do you think keyword prominence is a ranking factor in Google\'s search algorithms? Let\'s see what the evidence says.The post Keyword Prominence As A Google Ranking Factor: What You Need To Know appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/ranking-factors/keyword-prominence/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/12/rf-keyword-prominence-61bb368cbe247-sej.png","publishedAt":"2021-12-19T15:00:42Z","content":"Keyword prominence is an SEO best practice that involves using a page’s target keyword early in order to send a strong signal to Google about what the page should rank for.\\r\\nIt’s a concept comparable… [+6611 chars]"},{"source":{"id":null,"name":"Entrepreneur"},"author":"Entrepreneur Store","title":"Earn Passive Income for Your Business with Shopify","description":"Build a Shopify Store on a budget.","url":"https://www.entrepreneur.com/article/401090","urlToImage":"https://assets.entrepreneur.com/content/3x2/2000/1638838503-Ent-ShopifyStore.jpg","publishedAt":"2021-12-12T14:00:00Z","content":"E-commerce boomed during the pandemic and as people have become more comfortable with shopping online, there\'s good reason to believe the upward trend will only continue. For savvy entrepreneurs, thi… [+1733 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Tony Wright","title":"How Can Different Departments Avoid Keyword Cannibalization? via @sejournal, @tonynwright","description":"How can you avoid cannibalization in search results when multiple departments in your company want to rank on the same keywords?The post How Can Different Departments Avoid Keyword Cannibalization? appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/cannibalizing-search-results/431440/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/12/cannibalization-2-61d4577e4d10d-sej.png","publishedAt":"2022-01-04T15:45:28Z","content":"This week’s Ask An SEO question comes from Caroline in Cleveland, who wrote:\\r\\nMultiple divisions of our company want to rank for the same keywords.\\r\\nAre there any tips for how to approach this type o… [+3303 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Matt Southern","title":"Keyword Stuffing As A Google Ranking Factor: What You Need To Know via @sejournal, @MattGSouthern","description":"Keyword stuffing was a widely used technique because it yielded results. But is it a ranking factor today?The post Keyword Stuffing As A Google Ranking Factor: What You Need To Know appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/ranking-factors/keyword-stuffing/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/12/chapter-49-61bb605ee1a03-sej.png","publishedAt":"2022-01-05T07:45:11Z","content":"If some keywords are good, then more must be better, right?\\r\\nThat’s the simple logic behind keyword stuffing as a ranking factor.\\r\\nIn the early days of web search, way before SEO was a thing, Google … [+4911 chars]"},{"source":{"id":null,"name":"Entrepreneur"},"author":"Entrepreneur Store","title":"Scale Your Business with a Comprehensive Digital Marketing Plan","description":"Give your digital marketing strategy a boost with this Cyber Week discount.","url":"https://www.entrepreneur.com/article/404336","urlToImage":"https://assets.entrepreneur.com/content/3x2/2000/1640217158-Ent-2022DigitalMarketing.jpeg","publishedAt":"2021-12-29T17:00:00Z","content":"As the world has increasingly shifted toward online businesses, it\'s absolutely essential that all entrepreneurs have a digital marketing plan. If you\'re not sure what you\'re doing when it comes to r… [+1838 chars]"},{"source":{"id":null,"name":"Boing Boing"},"author":"Devin Nealy","title":"Watch this chicken leg disappear in acid","description":"Science is such an interesting double-edged sword. On one end, science provides innumerable life-saving innovations and technological conveniences that are integral to our continued survival as a species. At the same time, some of the most horrific weapons hu…","url":"https://boingboing.net/2021/12/27/watch-this-chicken-leg-disappear-in-acid.html","urlToImage":"https://i0.wp.com/boingboing.net/wp-content/uploads/2021/12/Screen-Shot-2021-12-27-at-8.25.29-AM.png?fit=1200%2C679&ssl=1","publishedAt":"2021-12-27T19:31:07Z","content":"Science is such an interesting double-edged sword. On one end, science provides innumerable life-saving innovations and technological conveniences that are integral to our continued survival as a spe… [+860 chars]"},{"source":{"id":null,"name":"Search Engine Land"},"author":"Pamela Parker","title":"SEO software tools: What marketers need to know","description":"SEO platforms offer numerous capabilities that range from keyword research and rank-checking to backlink analysis and acquisition, as well as competitive intelligence, social signal integration, and workflow rights and roles. \\n\\nPlease visit Search Engine Land…","url":"https://searchengineland.com/seo-software-tools-what-marketers-need-to-know-378360","urlToImage":"https://searchengineland.com/figz/wp-content/seloads/2022/01/shutterstock_387573454.jpg","publishedAt":"2022-01-10T09:48:34Z","content":"Search Engine Optimization remains the stalwart mainstay of digital marketing, with search driving around 50% of website traffic on average, according to an analysis of SimilarWeb data by Growth Badg… [+11056 chars]"},{"source":{"id":"reuters","name":"Reuters"},"author":null,"title":"Reuters Poll news stories from around the world - Reuters","description":"Reuters polls experts on the outlook for major world economies, central bank policy, foreign exchange rates, stock markets, money market and bond yields, housing markets, global asset allocation and more. The news stories linked to below are highlights only.","url":"https://www.reuters.com/markets/asia/reuters-poll-news-stories-around-world-2021-12-13/","urlToImage":"https://www.reuters.com/pf/resources/images/reuters/reuters-default.png?d=63","publishedAt":"2021-12-13T09:52:00Z","content":"Reuters polls experts on the outlook for major world economies, central bank policy, foreign exchange rates, stock markets, money market and bond yields, housing markets, global asset allocation and … [+3722 chars]"},{"source":{"id":null,"name":"Oberien.de"},"author":null,"title":"Thoughts on Return, Break and Continue","description":"Commonly, the keywords return, break and continue are used to influence the control flow of a program. Designing my own language rebo, I’m at a point where I want to implement a form of control-flow-changing operations. This post is primarily a braindump of i…","url":"https://blog.oberien.de/2022/01/04/thoughts-on-return-break-continue.html","urlToImage":null,"publishedAt":"2022-01-07T15:32:03Z","content":"2022-01-04\\r\\nCommonly, the keywords return, break and continue are used to influence the\\r\\ncontrol flow of a program.\\r\\nDesigning my own language rebo, Im at a point\\r\\nwhere I want to implement a form of… [+6756 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Semrush","title":"Dominate SERPs With Search Intent: How To Improve Your SEO & Content Strategy via @sejournal, @semrush","description":"It\'s up to you to be on the SERPs at the right time for each type of search.Rank better by understanding Search Intent.The post Dominate SERPs With Search Intent: How To Improve Your SEO & Content Strategy appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/semrush-search-intent-strategy/428162/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/11/featured-image-61a69e58d42f7-sej.jpg","publishedAt":"2021-12-14T06:00:32Z","content":"How do you build an SEO and content strategy that targets intent?\\r\\nWhy is it important to consider search intent?\\r\\nHow do you show the right content to the right audience at the right time in the buy… [+6991 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Similarweb","title":"7 Steps To Outrank Your True SEO Competition via @sejournal, @SimilarWeb","description":"To outrank the competition that is taking a large share of your target market, you\'ll need to focus on each of these 7 SEO plays.The post 7 Steps To Outrank Your True SEO Competition appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/simiarweb-true-seo-competition/428779/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/11/blog-thumbnail-default-1-61af886bf08ac-sej.png","publishedAt":"2021-12-15T06:00:04Z","content":"This post was sponsored by Similarweb. The opinions expressed in this article are the sponsor’s own.\\r\\nAny good athlete knows the value of watching a competitor’s games to study their strategy and lea… [+10617 chars]"},{"source":{"id":null,"name":"Github.com"},"author":"babashka","title":"Ad-hoc ClojureScript scripting of Mac applications","description":"Ad-hoc ClojureScript scripting of Mac applications via Apple&#39;s Open Scripting Architecture. - GitHub - babashka/obb: Ad-hoc ClojureScript scripting of Mac applications via Apple&#39;s Open Scri...","url":"https://github.com/babashka/obb","urlToImage":"https://opengraph.githubassets.com/422725a72d272560fd888a431a9c202f4ff3a37e2b5c63c15c1daa89de3e00aa/babashka/obb","publishedAt":"2022-01-03T10:38:30Z","content":"Ad-hoc ClojureScript scripting of Mac applications via Apple\'s Open Scripting Architecture.\\r\\nStatus\\r\\nExperimental.\\r\\nInstallation\\r\\nHomebrew\\r\\n$ brew install babashka/brew/obb\\r\\nManual\\r\\nDownload from Git… [+1521 chars]"},{"source":{"id":null,"name":"Moz.com"},"author":"AbdulGaniy Shehu","title":"3 Effective Ways to Quickly Identify Your SaaS Brand’s Top SEO Competitors","description":"To stay on top of your game as a SaaS business, you must identify the companies you\'re competing with from an SEO standpoint. That way, you’ll know the content strategies to focus on, the keywords to target, and the type of backlinks to acquire. In this post,…","url":"https://moz.com/blog/identify-saas-brand-competitors","urlToImage":"https://moz.com/images/blog/AbdulGaniy-SaaS-OG-Max-Quality.jpg?w=1200&h=630&q=82&auto=format&fit=clip&dm=1639485845&s=6096525fe8ec9037b3c9b60ee73eb9e2","publishedAt":"2021-12-21T08:00:00Z","content":"The author\'s views are entirely his or her own (excluding the unlikely event of hypnosis) and may not always reflect the views of Moz.There are over 22,600 software-as-a-service (SaaS) companies in t… [+8405 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Jason Hennessey","title":"How To Create A Winning Local SEO Content Strategy via @sejournal, @jasonhennessey","description":"Learn how to use localized content to boost your business\'s visibility in local search and the number of customers visiting your store, online and off.The post How To Create A Winning Local SEO Content Strategy appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/local-seo-content-strategy/431651/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2022/01/local-seo-content-strategy-61d8713a823ba-sej.png","publishedAt":"2022-01-10T14:45:27Z","content":"Local SEO has historically been seen as the art of directory optimization, Google Business Profiles, and locally-run ads.\\r\\nAnd while these methods are effective in getting you found in local search, … [+7299 chars]"},{"source":{"id":"the-next-web","name":"The Next Web"},"author":"Alina Valyaeva","title":"Oi, marketers! Stay away from these 5 types of stock photos","description":"Stock photos don’t a great reputation. They’re cheesy and are easily recognizable, so a lot of marketers avoid using them. But I’d like to argue that stock photos aren’t the issue, it’s how you choose them. Genuine top-quality stock photos expand your marketi…","url":"https://thenextweb.com/news/5-stock-photo-stereotypes-not-use-marketing","urlToImage":"https://img-cdn.tnwcdn.com/image/growth-quarters?filter_last=1&fit=1280%2C640&url=https%3A%2F%2Fcdn0.tnwcdn.com%2Fwp-content%2Fblogs.dir%2F1%2Ffiles%2F2021%2F12%2Fmarketing-stock-photos-gq.jpg&signature=6c604f2ddef2e57d3ab095112b710632","publishedAt":"2021-12-10T07:00:11Z","content":"Stock photos dont a great reputation. Theyre cheesy and are easily recognizable, so a lot of marketers avoid using them. But Id like to argue that stock photos arent the issue, its how you choose the… [+3927 chars]"},{"source":{"id":null,"name":"Contentmarketinginstitute.com"},"author":"Mike Murray","title":"How To Find SEO and Keyword Ranking Success on Google in 2022","description":"With its MUM algorithm, Google aims to give searchers what they want more often. That could be a win for content marketers who keep up. Here’s what you need to know about MUM and other SEO developments in 2022. Continue reading →\\nThe post How To Find SEO and …","url":"https://contentmarketinginstitute.com/seo-keywords-google-rankings/","urlToImage":"https://contentmarketinginstitute.com/wp-content/uploads/2021/12/SEO-Keyword-Ranking-Success.png","publishedAt":"2022-01-05T11:00:12Z","content":"Heading into the new year, Im usually full of cautionary notes about SEO, keywords, rankings, and organic traffic, all tied to search engines like Google.\\r\\nThese days, Im optimistic because technolog… [+9381 chars]"},{"source":{"id":null,"name":"Simonwillison.net"},"author":null,"title":"95% of problems once solved by metaclasses can be solved by __init_subclass__","description":"David Beazley [on Twitter](https://twitter.com/dabeaz/status/1466731368956809219) said:\\n\\n> I think 95% of the problems once solved by a metaclass can be solved by `__init_subclass__` instead\\n\\nThis inspired me to finally learn how to use it! I used [my asyncin…","url":"https://til.simonwillison.net/python/init-subclass","urlToImage":"https://til.simonwillison.net/-/media/screenshot/python_init-subclass.md","publishedAt":"2022-01-05T16:35:08Z","content":"David Beazley on Twitter said:\\r\\nI think 95% of the problems once solved by a metaclass can be solved by __init_subclass__ instead\\r\\nThis inspired me to finally learn how to use it! I used my asyncinje… [+1874 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Matt Bertram","title":"5 On-Page SEO Factors To Check In Underperforming Content","description":"Check out these 5 top on-page optimizations that can help you get a quick win under your belt when time and/or budgets are tight.The post 5 On-Page SEO Factors To Check In Underperforming Content appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/on-page-seo-underperforming/424184/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/10/on-page-seo-factors-618bfeb4d92e6-sej.png","publishedAt":"2022-01-03T13:45:52Z","content":"The SEO landscape is constantly changing, and so is on-page SEO. As a result, we now have to think beyond just the title and meta description to optimize our pages for major search engines.\\r\\nThere ar… [+6865 chars]"},{"source":{"id":null,"name":"Techmeme.com"},"author":null,"title":"Google details Android 12 Go edition, coming to low-end phones in 2022 with faster app launches, longer battery life, better sharing, and more privacy controls (Charmaine D\'Silva/The Keyword)","description":"Charmaine D\'Silva / The Keyword:\\nGoogle details Android 12 Go edition, coming to low-end phones in 2022 with faster app launches, longer battery life, better sharing, and more privacy controls  —  Android (Go edition) launched in 2017 with the goal to help mo…","url":"https://www.techmeme.com/211214/p36","urlToImage":"https://storage.googleapis.com/gweb-uniblog-publish-prod/images/Android_12_Go_edition_-_3_button_Nav_light.max-1300x1300.png","publishedAt":"2021-12-14T20:15:01Z","content":"CB Insights Newsletter\\r\\n724,948 subscribers get our free newsletter to stay a step ahead on technology trends, venture capital, startups, and the industries of tomorrow."},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Julia McCoy","title":"15 Awesome Paid SEO Tools That Are Worth the Money via @sejournal, @JuliaEMcCoy","description":"SEO is never easy but having the right tools can streamline processes, save you time, and ensure better outcomes. Check these paid SEO tools out.The post 15 Awesome Paid SEO Tools That Are Worth the Money appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/paid-seo-tools-2/418838/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/09/15-fantastic-paid-seo-tools-that-will-help-your-company-win-big-time-614e0332a16e1-sej.png","publishedAt":"2022-01-04T07:45:28Z","content":"Excellent SEO is the cornerstone of any serious marketing strategy. You should be using it, too.\\r\\nWhy are your search rankings so important?\\r\\nTry this number on for size: click-through rate (CTR) is … [+10603 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Miranda Miller","title":"Are HTML Heading Tags (H2-H6) A Google Ranking Factor? via @sejournal, @mirandalmwrites","description":"Will adding H2 to H6 subheadings and using specific keywords in them help your content rank higher in Google Search?The post Are HTML Heading Tags (H2-H6) A Google Ranking Factor? appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/ranking-factors/html-heading-tags-h2-h6/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/11/chapter-41-61b1016464b31-sej.png","publishedAt":"2021-12-10T12:45:47Z","content":"In a previous article, we explored the evidence around H1 tags as a Google ranking factor.\\r\\nNow, let’s take a look at the rest of the heading tags — H2 to H6.\\r\\nWill using these tags help your content… [+4394 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Roger Montti","title":"Amazon Alexa SEO Tools Is Closing via @sejournal, @martinibuster","description":"Amazon\'s powerful suite of SEO and online marketing tools will disappear in 2022, a loss for the search marketing communityThe post Amazon Alexa SEO Tools Is Closing appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/amazon-alexa-seo-suite-retiring/429690/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/12/alexa-marketing-software-re-61b2f3cc43aa8-sej.jpg","publishedAt":"2021-12-10T06:48:02Z","content":"Alexa.com announced that it will be retiring its marketing services after 25 years. Founded in 1996, Alexa was subsequently acquired by Amazon in 1999. It was initially known for providing rankings b… [+4161 chars]"},{"source":{"id":null,"name":"Windows Central"},"author":"Sean Endicott","title":"Microsoft Teams is upping its search capabilities with the power of AI","description":"Teams now supports more filters and tabbed categories to help you find relevant content.\\n\\n\\n\\nWhat you need to know\\n\\n\\nMicrosoft Teams has a revamped search experience.\\nSearches can now be sorted by tabs and with filters.\\nYou can also search through content in T…","url":"https://www.windowscentral.com/new-microsoft-teams-search-experience-helps-you-find-relevant-content","urlToImage":"https://www.windowscentral.com/sites/wpcentral.com/files/styles/large/public/field/image/2021/12/teams-search-filters.jpg","publishedAt":"2021-12-10T16:31:13Z","content":"Microsoft refreshed the search experience with Teams. Finding content should be significantly easier through the new experience, which supports both tabs and filters. Additionally, Teams can now answ… [+1072 chars]"},{"source":{"id":null,"name":"Contentmarketinginstitute.com"},"author":"Sally Ofuonyebi","title":"Try These Tools To Create Content That Works for Search Engines and Audiences","description":"Successful content creators realize writing for your audience isn’t different from writing for search engines. Here are 13 tools to help create valuable content that audiences discover and consume. Continue reading →\\nThe post Try These Tools To Create Content…","url":"https://contentmarketinginstitute.com/2021/12/tools-create-content-seo-audiences/","urlToImage":"https://contentmarketinginstitute.com/wp-content/uploads/2021/12/tools-create-content-that-works-search-engines-audiences.png","publishedAt":"2021-12-15T11:00:39Z","content":"Some content creators think writing to satisfy your audience and impress search engines put them between a rock and a hard place.\\r\\nBut successful content marketers recognize writing for your audience… [+8632 chars]"},{"source":{"id":null,"name":"9to5Mac"},"author":"Derek Wise","title":"Amazon responds after Alexa encourages dangerous penny challenge","description":"Amazon Echos are very common smart home devices. The smart speakers provide convenient access to music, control over smart home devices, and quick answers to questions – they can be quite helpful. But these devices are far from perfect, as illustrated by an A…","url":"https://9to5mac.com/2021/12/28/amazon-responds-after-alexa-encourages-dangerous-penny-challenge/","urlToImage":"https://i1.wp.com/9to5mac.com/wp-content/uploads/sites/6/2021/12/alexa-pennies.jpg?resize=1200%2C628&quality=82&strip=all&ssl=1","publishedAt":"2021-12-28T19:40:27Z","content":"Amazon Echos are very common smart home devices. The smart speakers provide convenient access to music, control over smart home devices, and quick answers to questions they can be quite helpful. But … [+2272 chars]"},{"source":{"id":null,"name":"Android Community"},"author":"Ida Torres","title":"Facebook brings new tools for moderation, live chat support for creators","description":"Facebook has been courting the content creator communities for years now, bringing tools and features that can help them create more content for the platform and reach a wide audience on their various services. But along with features, it’s also important tha…","url":"https://androidcommunity.com/facebook-brings-new-tools-for-moderation-live-chat-support-for-creators-20211213/","urlToImage":"https://androidcommunity.com/wp-content/uploads/2021/12/Screen-Shot-2021-12-14-at-10.39.03-AM.jpg","publishedAt":"2021-12-14T02:44:01Z","content":"Facebook has been courting the content creator communities for years now, bringing tools and features that can help them create more content for the platform and reach a wide audience on their variou… [+2070 chars]"},{"source":{"id":null,"name":"Srad.jp"},"author":"headless","title":"サンタ追跡 2021","description":"今年も NORAD のサンタ追跡ミッションが間もなく開始される\\n(公式サイト、\\nニュースリリース、\\nサンタ追跡 2021年版トレーラー)。\\n\\nNORAD のサンタ追跡公式サイトでは、日本時間 24 日 18 時から出発の準備を進めるサンタの更新情報を確認できるようになる。米国では 5G C バンドの信号による航空機の電波高度計等への干渉が懸念され、航空業界からは 1 月 5 日までの商用サービス延期だけでは不十分との声も出ているが、ルドルフがナビゲートするサンタのフライトシステムは影響を受けない。\\n\\n20 時には…","url":"https://idle.srad.jp/story/21/12/23/2039226/","urlToImage":"https://srad.jp/static/articles/21/12/23/2039226-4-thumb.png","publishedAt":"2021-12-24T02:17:00Z","content":"NORAD \\r\\n( 2021)NORAD 24 18 5G C 1 5 \\r\\n20 COVID-19 Amazon Alexa Bing NORAD \\r\\n(AndroidiOS)\\r\\nNORAD Bing Map Google 10 Google 24 19 Google Google \\r\\n(The Keyword [1][2])"},{"source":{"id":null,"name":"9to5Mac"},"author":"José Adorno","title":"Facebook launches new tools for creators with live chat support, help when locked out of accounts, more","description":"Facebook has announced a lot of new features during this past week. Now, the company is unveiling the latest patch of updates on its efforts to build a better platform for creators and communities.\\n more…\\nThe post Facebook launches new tools for creators with…","url":"https://9to5mac.com/2021/12/10/facebook-launches-new-tools-for-creators-with-live-chat-support-help-when-locked-out-of-accounts-more/","urlToImage":"https://i1.wp.com/9to5mac.com/wp-content/uploads/sites/6/2021/12/facebook-instagram-support-9to5mac.jpg?resize=1200%2C628&quality=82&strip=all&ssl=1","publishedAt":"2021-12-10T14:00:00Z","content":"Facebook has announced a lot of new features during this past week. Now, the company is unveiling the latest patch of updates on its efforts to build a better platform for creators and communities.\\r\\n… [+2232 chars]"},{"source":{"id":null,"name":"Entrepreneur"},"author":"Thomas Helfrich","title":"5 Ways AI Will Change the Digital Marketing Game in 2022","description":"What will AI mean for marketers in 2022? From chatbots and other virtual assistants to generating the content, enhancing user experiences and more, AI is already making major changes to the digital marketing landscape. While it may be difficult to predict the…","url":"https://www.entrepreneur.com/article/401518","urlToImage":"https://assets.entrepreneur.com/content/3x2/2000/1639598334-GettyImages-1310347004.jpg","publishedAt":"2021-12-23T16:00:00Z","content":"Today\'s digital marketers are swimming in such a sea of data that sometimes it feels like you\'re simultaneously drowning and treading water. Then, artificial intelligence walks majestically into the … [+7201 chars]"},{"source":{"id":null,"name":"Entrepreneur"},"author":"Pulkit Agrawal","title":"How to Improve Your Conversion Rates With the Help of SEO","description":"Here are some effective conversion rate optimization strategies that\'ll improve the user experience while increasing your bottom line.","url":"https://www.entrepreneur.com/article/398406","urlToImage":"https://assets.entrepreneur.com/content/3x2/2000/1639681980-GettyImages-1253233924.jpg","publishedAt":"2021-12-17T23:00:00Z","content":"As defined by Hotjar, conversion rate optimization (CRO) is the practice of increasing the percentage of users who perform a desired action on a website. This action may be anything from scrolling th… [+5738 chars]"},{"source":{"id":null,"name":"Zacks.com"},"author":"Bryan Hayes","title":"Neutralize Higher Health Insurance Premiums In 2022","description":"Buy These Health Providers to Counteract Bigger Health Insurance Premiums","url":"http://www.zacks.com/commentary/1844566/neutralize-higher-health-insurance-premiums-in-2022?cid=CS-ENTREPRENEUR-FT-investment_ideas-1844566","urlToImage":"https://assets.entrepreneur.com/providers/zacks/hero-image-zacks-410464.jpeg","publishedAt":"2021-12-28T19:34:00Z","content":"Its no secret health insurance premiums have only gone one way over time. Over the last decade, family premiums for employer-sponsored coverage have jumped 47% according to the 2021 Kaiser Family Fou… [+8283 chars]"},{"source":{"id":null,"name":"Entrepreneur"},"author":"Sim Aulakh","title":"3 Ways Direct-to-Consumer Brands Can Leverage Media Coverage","description":"Connecting directly to their customers is the blueprint for rapid growth.","url":"https://www.entrepreneur.com/article/401747","urlToImage":"https://assets.entrepreneur.com/content/3x2/2000/1639774623-shutterstock-411716665.jpg","publishedAt":"2021-12-27T21:59:00Z","content":"The digital marketing landscape has undergone a drastic shift. No longer can marketers rely on traditional marketing channels of search and social. The costs are rising, and profit margins are dimini… [+6305 chars]"},{"source":{"id":null,"name":"Forbes"},"author":"Akiko Katayama, Contributor, \\n Akiko Katayama, Contributor\\n https://www.forbes.com/sites/akikokatayama/","title":"Aged Sushi Has Become A Keyword For Top Sushi Chefs","description":"In the competitive $13 billion Japanese sushi market, aged sushi is drawing attention.  By aging fish, umami, or savory deliciousness of fish, can dramatically increase.  Top chefs in New York also apply aging techniques to their offerings despite its highly …","url":"https://www.forbes.com/sites/akikokatayama/2021/12/27/aged-sushi-has-become-a-keyword-for-top-sushi-chefs/","urlToImage":"https://thumbor.forbes.com/thumbor/fit-in/1200x0/filters%3Aformat%28jpg%29/https%3A%2F%2Fspecials-images.forbesimg.com%2Fimageserve%2F61c8a7fd145fc732afd1087f%2F0x0.jpg","publishedAt":"2021-12-27T13:00:00Z","content":"For Michelin-starred Chef Eiji Ichimura, aged fish is the answer to perfect sushi. \\r\\nAkiko Katayama\\r\\nThere are approximately 23,000 sushi restaurants in Japan and it is a $13 billion industry. How do… [+5064 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Kristi Hines","title":"6 Expert Tips For Small Business SEO Strategy In 2022 via @sejournal, @kristileilani","description":"Where should SMBs focus their SEO efforts in 2022? Here\'s what our network of search experts had to say.The post 6 Expert Tips For Small Business SEO Strategy In 2022 appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/small-business-seo-tips/429650/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2022/01/expert-tips-for-small-business-61c4350ed5891-sej.png","publishedAt":"2022-01-07T07:45:53Z","content":"Are you prepared for small business SEO in 2022?\\r\\nIf you’re still scrambling to formulate a strategy, you’re not alone. The uncertainty of ongoing pandemic-related business interruptions and changes … [+6175 chars]"},{"source":{"id":null,"name":"Hubspot.com"},"author":"Amanda Zantal-Wiener","title":"What Is Bounce Rate? (And How Can I Fix Mine?)","description":"Bounce rate is a metric that can be confusing when you first stumble upon it. I’m sure several questions pop into your head: Is a bounce rate close to 100% good or bad? Is it at all like a bounced email? Is it a vanity metric that I should ignore? And if I wa…","url":"https://blog.hubspot.com/marketing/what-is-bounce-rate-fix#article","urlToImage":"https://blog.hubspot.com/hubfs/Copy%20of%20Untitled-Nov-23-2021-08-55-42-91-PM.png#keepProtocol","publishedAt":"2021-12-22T12:00:00Z","content":"Bounce rate is a metric that can be confusing when you first stumble upon it. Im sure several questions pop into your head: Is a bounce rate close to 100% good or bad? Is it at all like a bounced ema… [+8548 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Angie Nikoleychuk","title":"Using Google Trends To Optimize Your Content Strategy Timing - Ep. 252 via @sejournal, @Juxtacognition","description":"Google Trends does more than just show search trends. Find out how to push your content to the top with this unique search tool.The post Using Google Trends To Optimize Your Content Strategy Timing [Podcast] appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/google-trends-optimize-content-strategy/429673/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/12/sejshow-featured-image-ep252-61b40f14e27d3-sej.jpg","publishedAt":"2021-12-13T15:45:16Z","content":"Creating content and want to know what was trending in search last week, month, or year? Google Trends can help you find useful and timely data. But how do you use it effectively?\\r\\nIf you want to cre… [+3601 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Pro Rank Tracker","title":"Huge Update: Leading Rank Tracking Tool, ProRankTracker, Upgrades For 2022 via @sejournal, @ProRanktracker","description":"You: get a complete picture of your rankings and analyze your SEO results.Your clients: get professional, white-labeled, modern reporting to put them at ease.The post Huge Update: Leading Rank Tracking Tool, ProRankTracker, Upgrades For 2022 appeared first on…","url":"https://www.searchenginejournal.com/proranktracker-seo-tool-update/431266/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/12/featured-image-61cdf84ce1f22-sej.png","publishedAt":"2022-01-04T06:00:06Z","content":"Enhanced Tracking Features\\r\\nOrganic search and mobile rankings are updated daily. With ProRankTracker, you have the option, under certain plans, to check your rankings on demand.\\r\\nYou can also enhanc… [+3593 chars]"},{"source":{"id":null,"name":"ReadWrite"},"author":"Nate Nead","title":"Can You Make a Website Popular for Free?","description":"Making a website popular is one of the most straightforward ways to build wealth online. Whether you’re interested in selling a specific product or service or just using advertising to monetize your visitors, if you can make a website sufficiently popular, yo…","url":"https://readwrite.com/2021/12/13/can-you-make-a-website-popular-for-free/","urlToImage":"https://images.readwrite.com/wp-content/uploads/2021/12/make-website-popular-for-free.jpg","publishedAt":"2021-12-14T01:13:47Z","content":"Making a website popular is one of the most straightforward ways to build wealth online. Whether youre interested in selling a specific product or service or just using advertising to monetize your v… [+7572 chars]"},{"source":{"id":null,"name":"ReadWrite"},"author":"Ronald Gabriel","title":"10 Growth Hacks to Improve your Online Store Performance","description":"Regardless of which industry your business operates in, as long as you have an online presence, it’s crucial to hack your growth to generate sales and ROI. Similarly, online e-commerce stores face a common challenge that needs to be resolved to improve the st…","url":"https://readwrite.com/2022/01/07/10-growth-hacks-to-improve-your-online-store-performance/","urlToImage":"https://images.readwrite.com/wp-content/uploads/2021/11/pexels-negative-space-34577.jpg","publishedAt":"2022-01-07T17:01:02Z","content":"Regardless of which industry your business operates in, as long as you have an online presence, its crucial to hack your growth to generate sales and ROI. Similarly, online e-commerce stores face a c… [+7776 chars]"},{"source":{"id":null,"name":"MakeUseOf"},"author":"Tamal Das","title":"The 10 Best Job Websites to Find Remote Work","description":"Do you want to work remotely and find the best career opportunities? Here are some job websites you might find useful!","url":"https://www.makeuseof.com/best-job-websites-find-remote-work/","urlToImage":"https://static1.makeuseofimages.com/wordpress/wp-content/uploads/2021/12/Remote-Work-Job-Sites-Featured-Image.jpeg","publishedAt":"2022-01-06T13:45:46Z","content":"Remote jobs or jobs that let you work from home ensure a better work-life balance than a 9-5 office job. Here, you can also save the time and money you would have to spend commuting to an office job.… [+6970 chars]"},{"source":{"id":null,"name":"9to5Mac"},"author":"Seth Kurkowski","title":"Hands-on: TweetDeck preview brings native polls, customizable decks, and design overhaul","description":"For years I’ve been a power user of Twitter’s TweetDeck. The ability to see tweets as they happen in real-time from those I follow or specific keywords is an essential tool in modern journalism. A preview of the newest version keeps that idea while bringing a…","url":"https://9to5mac.com/2021/12/20/hands-on-tweetdeck-preview-brings-native-polls-customizable-decks-and-design-overhaul/","urlToImage":"https://i1.wp.com/9to5mac.com/wp-content/uploads/sites/6/2021/12/Tweetdeck_Gradient-1.png?resize=1200%2C628&quality=82&strip=all&ssl=1","publishedAt":"2021-12-20T21:44:03Z","content":"For years I’ve been a power user of Twitter’s TweetDeck. The ability to see tweets as they happen in real-time from those I follow or specific keywords is an essential tool in modern journalism. A pr… [+3536 chars]"},{"source":{"id":null,"name":"Semrush.com"},"author":null,"title":"SEO Clinic Episode III: How to Analyze Your Place in the Online Market and Unwrap New Growth Avenues","description":"We invited 5 digital marketing experts to share their ideas on how a brand can use insights from competitive and SEO analysis to evaluate market gaps and close them. Go through the videos below and learn how to explore the competitive landscape, use keyword a…","url":"https://www.semrush.com/blog/unwrap-new-growth-avenues/","urlToImage":"https://static.semrush.com/blog/uploads/media/13/88/13884d57fbc55e1ab92be7fcc2a25f93/analyze-your-place-in-the-online-market-sm.png","publishedAt":"2021-12-14T12:56:00Z","content":"In the continuation of our SEO Clinic series, welcome to the third episode, dedicated to assessing your place in the online market and ways to expand market share through SEO. \\r\\nWe invited 5 digital … [+6718 chars]"},{"source":{"id":null,"name":"Impress.co.jp"},"author":null,"title":"グーグル、サンタクロースへのインタビューを公開","description":"グーグルは、同社の公式ブログ「Google The Keyword」で、「サンタが街にやってくる――サンタへのインタビューを実施（Santa Claus is coming to town — and we interviewed him）」と題した記事を公開した。","url":"https://k-tai.watch.impress.co.jp/docs/news/1377031.html","urlToImage":"https://k-tai.watch.impress.co.jp/img/ktw/list/1377/031/01.png","publishedAt":"2021-12-24T04:00:55Z","content":"Google The KeywordSanta Claus is coming to town and we interviewed him \\r\\n Google TrendsSanta Claus \\r\\nSanta Claus is coming to town and we interviewed him\\r\\n12Google Hey Google, Call Santa\\r\\nArt Colorin… [+232 chars]"},{"source":{"id":null,"name":"MarketWatch"},"author":"Jacob Passy","title":": Thousands of home appraisals may contain racially biased language, federal regulator finds","description":"FHFA found home appraisers making references to the neighborhood\'s racial demographics in their assessments of a home\'s value.","url":"https://www.marketwatch.com/story/one-spicy-neighborhood-thousands-of-home-appraisals-may-contain-racially-biased-language-federal-regulator-finds-11639529530","urlToImage":"https://images.mktw.net/im-452432/social","publishedAt":"2021-12-15T10:57:00Z","content":"Despite policies meant to bar race-related bias in assessing property values, many home appraisers continue to make references to the neighborhoods racial demographics in their assessments of a homes… [+2935 chars]"},{"source":{"id":null,"name":"Codeproject.com"},"author":"Steve_Hemlocks","title":"State Oriented Programming or \'IF\' free programming","description":"A way of thinking about programming that reduces the number of conditional statements in your code and improves testability.","url":"https://www.codeproject.com/Articles/5320784/State-Oriented-Programming-or-IF-free-programming","urlToImage":"https://www.codeproject.com/KB/Articles/5320784/Thumbnail.Png","publishedAt":"2021-12-24T12:55:00Z","content":"Introduction\\r\\nState Oriented Programming is a way of thinking about programming not as process flow but as state and behaviour. With traditional programming, and by traditional I include procedural, … [+36794 chars]"},{"source":{"id":null,"name":"Tasshin.com"},"author":"Tasshin","title":"A Guide to Twitter","description":"Our hope is that this guide to Twitter will be useful to you, wherever you are in your Twitter journey.","url":"https://tasshin.com/blog/a-guide-to-twitter/","urlToImage":"https://tasshin.com/wp-content/uploads/2021/04/01tf_headshot_2020_cropped-scaled.jpg","publishedAt":"2021-12-31T20:47:23Z","content":"Co-Authored with Brian Hall\\r\\nI started using Twitter in March, 2007, one year after Jack did. I was 15, and I loved reading Metafilter, Digg, TechCrunch, Lifehacker, and 43 Folders. I must have read … [+33456 chars]"},{"source":{"id":null,"name":"MakeUseOf"},"author":"Khamosh Pathak","title":"3 Effective SMS Spam Blocking Apps for iPhone","description":"Call blocking lets you filter calls from identified and verified spammers. You can do the same for SMS spam with these useful apps.","url":"https://www.makeuseof.com/tag/sms-spam-blocking-iphone/","urlToImage":"https://static1.makeuseofimages.com/wordpress/wp-content/uploads/2017/11/sms-spam-blocking-iphone.jpg","publishedAt":"2022-01-04T12:00:24Z","content":"Apple has made tracks in recent years to help curb the number of spam calls reaching iPhones, with call blocking features that allow third-party apps to filter calls from identified and verified spam… [+6659 chars]"},{"source":{"id":null,"name":"Searchenginewatch.com"},"author":"Jacob M.","title":"How to optimize keywords and SEO titles with popular keywords","description":"Everything you need to get more traffic and amp up conversion rates\\nThe post How to optimize keywords and SEO titles with popular keywords appeared first on Search Engine Watch.","url":"http://www.searchenginewatch.com/2021/12/22/how-to-optimize-keywords-and-seo-titles-with-popular-keywords/","urlToImage":"https://www.searchenginewatch.com/wp-content/uploads/2021/12/How-to-optimize-keywords-and-SEO-titles-with-popular-keywords.png","publishedAt":"2021-12-22T14:57:06Z","content":"30-second summary:\\r\\n<ul><li>Title optimization of articles, blogs, or webpages is critical to get traffic and earn money from Adsense and affiliates</li><li>The standard advice is to stick to one key… [+13239 chars]"},{"source":{"id":null,"name":"Github.com"},"author":"RSS-Bridge","title":"RSS-Bridge – The RSS feed for websites missing it","description":"The RSS feed for websites missing it. Contribute to RSS-Bridge/rss-bridge development by creating an account on GitHub.","url":"https://github.com/RSS-Bridge/rss-bridge","urlToImage":"https://repository-images.githubusercontent.com/11935508/5d62b680-977c-11e9-99ec-5d131da3c993","publishedAt":"2022-01-02T19:19:45Z","content":"RSS-Bridge is a PHP project capable of generating RSS and Atom feeds for websites that don\'t have one. It can be used on webservers or as a stand-alone application in CLI mode.\\r\\nImportant: RSS-Bridge… [+4799 chars]"},{"source":{"id":null,"name":"Forbes"},"author":"Kristopher Jones, Forbes Councils Member, \\n Kristopher Jones, Forbes Councils Member\\n https://www.forbes.com/sites/forbesagencycouncil/people/kristopherjones1/","title":"3 Tactics All Enterprises Need To Scale SEO Efforts","description":"In the world of SEO, it\'s important to remember that there can never be a “set it and forget it” mindset.","url":"https://www.forbes.com/sites/forbesagencycouncil/2021/12/16/3-tactics-all-enterprises-need-to-scale-seo-efforts/","urlToImage":"https://thumbor.forbes.com/thumbor/fit-in/1200x0/filters%3Aformat%28jpg%29/https%3A%2F%2Fspecials-images.forbesimg.com%2Fimageserve%2F60fec5b3bb71d2a64d956655%2F0x0.jpg","publishedAt":"2021-12-16T12:30:00Z","content":"Founder of 2020 \\"SEO Agency of the Year\\" finalist LSEO.com. Serial Entrepreneur. Best-Selling Author (over 100,000 books sold).\\r\\ngetty\\r\\nIn the world of SEO, it\'s important to remember that there can … [+5164 chars]"},{"source":{"id":null,"name":"Sans.edu"},"author":null,"title":"Custom Python RAT Builder, (Fri, Jan 7th)","description":"This week I already wrote a diary about \\"code reuse\\" in the malware landscape&&#x23;x26;&#x23;x5b;1&&#x23;x26;&#x23;x5d; but attackers also have plenty of tools to generate new samples on the fly. When you received a malicious Word documents, it has not been …","url":"https://isc.sans.edu/diary.html?storyid=28224","urlToImage":"https://isc.sans.edu/diaryimages/images/isc-20220107-1.PNGCustom Python RAT Builder, Author: Xavier MertensCustom Python RAT Builder, Author: Xavier MertensSANS Internet Storm Centerisc, sans, internet, security, threat, worm, virus, phishing, hacking, vulnerability","publishedAt":"2022-01-07T10:22:05Z","content":"This week I already wrote a diary about \\"code reuse\\" in the malware landscape[1] but attackers also have plenty of tools to generate new samples on the fly. When you received a malicious Word documen… [+5888 chars]"},{"source":{"id":null,"name":"MakeUseOf"},"author":"Unnati Bamania","title":"How to Use Call, Apply, and Bind in JavaScript","description":"JavaScript call(), apply(), and bind() stand a decent chance of showing up in your web dev interview. Are you prepared?","url":"https://www.makeuseof.com/call-apply-bind-javascript/","urlToImage":"https://static1.makeuseofimages.com/wordpress/wp-content/uploads/2021/11/laptop,-coffee-mug,-and-javascript.jpg","publishedAt":"2021-12-24T17:16:12Z","content":"You may have come across various built-in functions like those for arrays and strings while practicing JavaScript. While you might use these more common methods in your day-to-day programming tasks, … [+2953 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Matt Southern","title":"Is The Quantity Of Images On Your Webpage A Google Ranking Factor? via @sejournal, @MattGSouthern","description":"You may have heard or read that the number of images on your webpage can impact your Google search rankings. But is it true?The post Is The Quantity Of Images On Your Webpage A Google Ranking Factor? appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/ranking-factors/image-quantity/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/12/chapter-44-61b3a92e660b4-sej.png","publishedAt":"2021-12-12T17:00:57Z","content":"Adding images to written content can help add context for readers and keep them engaged for longer periods.\\r\\nIn turn, that could lead to more time on site, which increases the potential for more page… [+2969 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Navah Hopkins","title":"How To Think More Creatively About PPC via @sejournal, @navahf","description":"Using bold and crazy ideas for your next PPC campaign could pay off huge if you get it right. Here\'s what you need to know.The post How To Think More Creatively About PPC appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/how-to-think-creatively-ppc/428761/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/06/ask-ppc-featured-60c33a60c512d.png","publishedAt":"2021-12-13T12:45:32Z","content":"It’s easy to fall into a strategic rut in PPC.\\r\\nMaybe you’re just sticking to proven tactics instead of testing.\\r\\nYou could be accustomed to using formulaic creative instead of adapting it to differe… [+3512 chars]"},{"source":{"id":null,"name":"Forbes"},"author":"Vahe Tirakyan, Forbes Councils Member, \\n Vahe Tirakyan, Forbes Councils Member\\n https://www.forbes.com/sites/forbesbusinesscouncil/people/vahetirakyan/","title":"Six Ways To Improve Your ROI With Google Ads","description":"Even if its characteristics aren\'t always intuitive, I have seen how Google Ads is an essential and powerful tool for digital marketing departments across industries and sectors.","url":"https://www.forbes.com/sites/forbesbusinesscouncil/2022/01/07/six-ways-to-improve-your-roi-with-google-ads/","urlToImage":"https://thumbor.forbes.com/thumbor/fit-in/1200x0/filters%3Aformat%28jpg%29/https%3A%2F%2Fspecials-images.forbesimg.com%2Fimageserve%2F61d6041741b3225c95034ea8%2F0x0.jpg","publishedAt":"2022-01-07T12:45:00Z","content":"CEO at MD Logica, as well as a speaker and author covering business, marketing and strategy.\\r\\ngetty\\r\\nWhile Google Ads is one of the most convenient ways to bring traffic to your website, you should t… [+6337 chars]"},{"source":{"id":null,"name":"Jeffbullas.com"},"author":"Ankit Thakor","title":"20 Free Chrome Extensions to Fine-Tune Your Digital Marketing Strategies","description":"How much time does it take: To perform keyword research To find well-performing keywords and generate content ideas To A/B test your content ideas To confirm whether your content is worth creating And finally, give it approval for writing. It swallows the ent…","url":"https://www.jeffbullas.com/free-digital-marketing-chrome-extensions/","urlToImage":"https://www.jeffbullas.com/wp-content/uploads/2021/12/20-Free-Chrome-Extensions-to-Fine-Tune-Your-Digital-Marketing-Strategies.jpg","publishedAt":"2021-12-27T15:00:00Z","content":"How much time does it take:\\r\\n<ol><li>To perform keyword research</li><li>To find well-performing keywords and generate content ideas</li><li>To A/B test your content ideas</li><li>To confirm whether … [+16420 chars]"},{"source":{"id":null,"name":"Blogspot.com"},"author":"Per Minborg","title":"Why general inheritance is flawed and how to finally fix it","description":"A blog about Java","url":"http://minborgsjavapot.blogspot.com/2021/12/why-general-inheritance-is-flawed-and.html","urlToImage":null,"publishedAt":"2021-12-11T23:09:54Z","content":"By leveraging composition and the final keyword in the right way, you can improve your programming skills and become a better Java programmer.  \\r\\nGeneral inheritance, whereby a public class is extend… [+14216 chars]"},{"source":{"id":null,"name":"Niemanlab.org"},"author":"Gordon Crovitz","title":"The year advertisers stop boycotting news","description":"When I was publisher of The Wall Street Journal, we would give an airline advertiser a free substitute ad in the next issue of the newspaper if its ad happened to run alongside a news story about an airline crash. Airline marketers were happy to continue to s…","url":"https://www.niemanlab.org/2021/12/the-year-advertisers-stop-boycotting-news/","urlToImage":"https://www.niemanlab.org/images/gordon-crovitz-2021.jpeg","publishedAt":"2021-12-16T19:31:40Z","content":"When I was publisher of The Wall Street Journal, we would give an airline advertiser a free substitute ad in the next issue of the newspaper if its ad happened to run alongside a news story about an … [+3632 chars]"},{"source":{"id":null,"name":"Livedoor.jp"},"author":"kinisoku","title":"ワイ菜食主義者、いきなりステーキから出るところを同志に見られる","description":"※5年前の今日の記事からおすすめを再掲しています \\n\\n1：風吹けば名無し＠＼(^o^)／：\\n2017/01/08(日) 22:00:13.37ID:VfLaBfSG0.net\\n\\n月一度の楽しみなんや…堪忍してや… ちな、ラインはブロックされた模様\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n3：風吹けば名無し＠＼(^o^)／：\\n2017/01/08(日) 2...","url":"http://blog.livedoor.jp/kinisoku/archives/4734536.html","urlToImage":"https://livedoor.blogimg.jp/kinisoku/imgs/3/8/389562c4.jpg","publishedAt":"2022-01-08T14:30:18Z","content":"http://d.hatena.ne.jp/keyword/%A5%D3%A1%BC%A5%AC%A5%F3"},{"source":{"id":null,"name":"Android Community"},"author":"Rei Padla","title":"New Android features made known at CES 2022","description":"During the CES week, Google has announced several new Android features slated for release this 2022. The tech giant presented the upcoming improvements that are expected to enhance the whole Android experience not only on smartphones but on other mobile devic…","url":"https://androidcommunity.com/new-android-features-made-known-at-ces-2022-20220106/","urlToImage":"https://androidcommunity.com/wp-content/uploads/2022/01/Android-12-2022-Features-Update-CES-2022.jpg","publishedAt":"2022-01-06T08:30:28Z","content":"During the CES week, Google has announced several new Android features slated for release this 2022. The tech giant presented the upcoming improvements that are expected to enhance the whole Android … [+2767 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Miranda Miller","title":"Are Outbound Links A Google Search Ranking Factor? via @sejournal, @mirandalmwrites","description":"Many believe outbound links aren’t a ranking factor at all and have no SEO benefit to the linking party (the source). Are they right?The post Are Outbound Links A Google Search Ranking Factor? appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/ranking-factors/outbound-links/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2022/01/chapter-57-61d85495917ee-sej.png","publishedAt":"2022-01-10T13:45:43Z","content":"You can’t throw a stone in SEO without hitting a link builder.\\r\\nSince Google’s earliest days, links are – and have always been – an integral part of search optimization.\\r\\nBut what about outbound link… [+11219 chars]"},{"source":{"id":null,"name":"Ericlippert.com"},"author":"ericlippert","title":"Persistence, façades and Roslyn’s red-green trees","description":"We decided early in the Roslyn design process that the primary data structure that developers would use when analyzing code via Roslyn is the syntax tree. And thus one of the hardest parts of the e…","url":"https://ericlippert.com/2012/06/08/red-green-trees/","urlToImage":"https://s0.wp.com/i/blank.jpg","publishedAt":"2021-12-25T05:21:03Z","content":"We decided early in the Roslyn design process that the primary data structure that developers would use when analyzing code via Roslyn is the syntax tree. And thus one of the hardest parts of the ear… [+5937 chars]"},{"source":{"id":null,"name":"Digital Trends"},"author":"Mark Coppock","title":"This tiny 2-in-1 was my most surprising laptop of 2021","description":"I reviewed over 45 laptops in 2021, and some are the I’ve used in recent memory. Those include powerful laptops like the or portable wonders like the . But one laptop surprised me the most: The Surface Go 3. It’s Microsoft’s smallest and least expensive Surfa…","url":"https://www.digitaltrends.com/computing/the-microsoft-surface-go-3-was-the-most-surprising-laptop-of-2021/","urlToImage":"https://icdn.digitaltrends.com/image/digitaltrends/microsoft-surface-go-3-tablet.jpg","publishedAt":"2021-12-30T14:00:10Z","content":"I reviewed over 45 laptops in 2021, and some are the best laptops I’ve used in recent memory. Those include powerful laptops like the Dell XPS 15 OLED or portable wonders like the HP Spectre x360 14.… [+5866 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Ruth Everett","title":"An Introduction To Python & Machine Learning For Technical SEO via @sejournal, @rvtheverett","description":"Start learning Python and explore how it can help you with automating tasks and analyzing complex data to improve your technical SEO.The post An Introduction To Python & Machine Learning For Technical SEO appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/python-machine-learning-technical-seo/430000/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/12/python-and-machine-learning-61ba01f5079b1-sej.png","publishedAt":"2021-12-16T14:45:49Z","content":"Since I first started talking about how Python is being used in the SEO space two years ago, it has gained even more popularity and a lot of people have started to utilize and see the benefits of usi… [+18577 chars]"},{"source":{"id":null,"name":"Gigasheet.co"},"author":"Luciana Obregon","title":"AWS Account Takeover via Log4Shell","description":"We installed Log4j on AWS, and then hacked it. Here\'s what we learned. Apache\'s Log4j logging utility has received widespread media attention weeks due to a critical (and easily exploitable) zero-day vulnerability (CVE-2021-44228).","url":"https://www.gigasheet.co/post/aws-account-takeover-via-log4shell","urlToImage":"https://static.wixstatic.com/media/1fea66_8b79ff110cc3430bb79663bfc1a7ca35~mv2.jpg/v1/fit/w_1000%2Ch_1000%2Cal_c%2Cq_80/file.jpg","publishedAt":"2021-12-22T20:38:41Z","content":"We installed Log4j on AWS, and then hacked it. Here\'s what we learned.\\r\\nApache\'s Log4j logging utility has received widespread media attention in the last few weeks due to a critical (and easily expl… [+6849 chars]"},{"source":{"id":null,"name":"Napi.rs"},"author":null,"title":"NAPI-RS v2","description":" NAPI-RS v2 - Faster  , Easier to use, and compatible improvements.","url":"https://napi.rs/blog/announce-v2","urlToImage":"https://napi.rs/img/favicon.png","publishedAt":"2022-01-03T12:43:37Z","content":"NAPI-RS v2 - Faster , Easier to use, and compatible improvements.\\r\\n 2021/12/17\\r\\nWe are proudly announcing the release of NAPI-RS v2. This is the biggest release of NAPI-RS ever.\\r\\n- Aminimal library f… [+8071 chars]"},{"source":{"id":null,"name":"Reverberate.org"},"author":null,"title":"Thread Safety in C++ and Rust","description":"Parsing, performance, and low-level programming.","url":"https://blog.reverberate.org/2021/12/18/thread-safety-cpp-rust.html","urlToImage":"","publishedAt":"2021-12-18T21:11:57Z","content":"Lately Ive been experimenting with Rust, and I want to report some of what\\r\\nIve learned about thread-safety. I am an enthusiastic dabbler in Rust: I\\r\\nspend most of my time in C and C++, but Im always… [+7978 chars]"},{"source":{"id":null,"name":"Convinceandconvert.com"},"author":"Kim Corak","title":"6 Ways to Integrate SEO Across Teams","description":"When I started in digital marketing, I splattered meta-data and keywords into content like Pollock. I am not proud of this because not only does this date me, but it is also horrifically against best practices as we see them today. If you ever read anything a…","url":"https://www.convinceandconvert.com/?p=159260","urlToImage":"https://www.convinceandconvert.com/wp-content/uploads/2021/12/6-Ways-to-Integrate-SEO-Across-Teams.jpg","publishedAt":"2021-12-23T12:00:32Z","content":"When I started in digital marketing, I splattered meta-data and keywords into content like Pollock. I am not proud of this because not only does this date me, but it is also horrifically against best… [+6770 chars]"},{"source":{"id":null,"name":"Stefanjudis.com"},"author":"@stefanjudis","title":"The surprising behavior of “important CSS custom properties”","description":"The ’!important` keyword is removed when using custom properties as CSS property values.","url":"https://www.stefanjudis.com/today-i-learned/the-surprising-behavior-of-important-css-custom-properties/","urlToImage":"https://res.cloudinary.com/dfcwuxv3l/image/upload/w_1280,h_669,c_fill,q_auto,f_auto/w_900,c_fit,co_rgb:232129,g_south_west,x_70,y_160,l_text:oswald_84_bold_line_spacing_-34:The%20surprising%20behavior%20of%20%22important%20CSS%20custom%20properties%22/w_900,c_fit,co_rgb:232129,g_north_west,x_70,y_540,l_text:ubuntu_38:%40stefanjudis/stefan-judis-website/social-image-with-new-dude","publishedAt":"2021-12-23T06:17:42Z","content":"CSS custom properties are flexible, make code DRY (\\"don\'t repeat yourself\\"), and can keep a codebase maintainable. The larger a CSS codebase, the more critical your CSS is easy to handle. CSS code be… [+923 chars]"},{"source":{"id":null,"name":"Highsnobiety"},"author":"Sam Cole","title":"Jordan Brand is Going All Out With its Spring 2022 Retro Collection","description":"Brand: Nike Model: Air Jordan I, III, IV, V, V Low, VI, VII, IX, and XIII Release Date: Spring 2022 Price: TBC Buy: Nike SNKRS Editor’s Notes: It feels like only yesterday that Nike unveiled Jordan Brand‘s Holiday 2021 collection. As quickly as the lineup was…","url":"https://www.highsnobiety.com/p/nike-jordan-brand-spring-2022-retro-collection/","urlToImage":"https://www.highsnobiety.com/static-assets/thumbor/DKu2tTxaJub-7rx58K9oEfZd6Sc=/1200x800/www.highsnobiety.com/static-assets/wp-content/uploads/2021/12/20154308/Nike-Jordan-Brand-SS22_0007_NikeNews_JordanBrand_SP22Retros_AJ1_HI_OG_Reverse_Black_Royal_555088-404_A7_RightLateral_v05.jpg","publishedAt":"2021-12-20T16:42:00Z","content":"Brand:Nike\\r\\nModel:Air Jordan I, III, IV, V, V Low, VI, VII, IX, and XIII\\r\\nRelease Date: Spring 2022\\r\\nPrice: TBC\\r\\nBuy: Nike SNKRS\\r\\nEditor\'s Notes: It feels like only yesterday that Nike unveiled Jorda… [+2299 chars]"},{"source":{"id":null,"name":"Forbes"},"author":"YEC, Forbes Councils Member, \\n YEC, Forbes Councils Member\\n https://www.forbes.com/sites/theyec/","title":"How To Improve Your Business\'s Online Visibility In One Day","description":"There are changes you can make to your company’s website today to improve its visibility and start outranking your competitors.","url":"https://www.forbes.com/sites/theyec/2021/12/14/how-to-improve-your-businesss-online-visibility-in-one-day/","urlToImage":"https://thumbor.forbes.com/thumbor/fit-in/1200x0/filters%3Aformat%28jpg%29/https%3A%2F%2Fspecials-images.forbesimg.com%2Fimageserve%2F61b767d77f01d42b0fe84012%2F0x0.jpg","publishedAt":"2021-12-14T12:15:00Z","content":"By Tyler Gallagher, CEO and founder of Regal Assets, an international alternative assets firm with offices in Beverly Hills, Toronto, London and Dubai.\\r\\ngetty\\r\\nYou might\'ve heard about the mythologic… [+4484 chars]"},{"source":{"id":null,"name":"MarketingProfs.com"},"author":"Manick Bhan","title":"Five Ways to Improve Content Quality Signals on Landing Pages","description":"Quality is a nebulous concept that can be difficult to define. Not for Google: high-quality content for better search rank depends on specific factors that can be optimized. Here\'s how to do so for five of them. Read the full article at MarketingProfs","url":"https://www.marketingprofs.com/articles/2021/46377/five-ways-to-improve-content-quality-signals-on-landing-pages","urlToImage":"https://i.marketingprofs.com/assets/images/articles/lg/211221-rose-petals-lg.jpg","publishedAt":"2021-12-21T15:00:00Z","content":"Listen\\r\\nSign in or sign up to access this feature!\\r\\nGoogle considers over 200 ranking factors when promoting webpages in SERPs, but almost all of them fall under one primary category: quality.\\r\\nThat\'… [+7313 chars]"},{"source":{"id":null,"name":"Yahoo Entertainment"},"author":"TipRanks","title":"2 “Strong Buy” Dividend Stocks Yielding at Least 7%","description":"The market’s keyword heading into the last few weeks of 2021 is ‘volatility.’ Since the beginning of November, we’ve more pronounced swings, both up and down...","url":"https://finance.yahoo.com/news/2-strong-buy-dividend-stocks-005734759.html","urlToImage":"https://s.yimg.com/uu/api/res/1.2/INHudD5L5jz0LHFn8HQPwA--~B/aD01MTc7dz0xMDI0O2FwcGlkPXl0YWNoeW9u/https://media.zenfs.com/en/tipranks_452/4a58a6f32ec2491df6eb1b0aef4588bf","publishedAt":"2021-12-15T00:57:34Z","content":"The markets keyword heading into the last few weeks of 2021 is volatility. Since the beginning of November, weve more pronounced swings, both up and down, especially on the NASDAQ index.\\r\\nWatching th… [+5826 chars]"},{"source":{"id":null,"name":"Moz.com"},"author":"Miriam Ellis","title":"Ecom, Locom, or Informational: Google Tracks Locally and so Should You","description":"Local SERP tracking has historically been seen as challenging for any business type, but today, we’ll take a look at the lay of the competitive landscape and offer some helpful solutions.","url":"https://moz.com/blog/local-serp-tracking","urlToImage":"https://moz.com/images/blog/MDES-1264_StratsForLocalSERPTracking_1200x628.png?w=1200&h=630&q=82&auto=format&fit=clip&dm=1639130291&s=965b0661d7b1f2ecac2d72b36ac326e0","publishedAt":"2021-12-13T08:00:00Z","content":"The author\'s views are entirely his or her own (excluding the unlikely event of hypnosis) and may not always reflect the views of Moz.\\r\\n The majority of surveyed consumers say that about half of thei… [+8785 chars]"},{"source":{"id":null,"name":"MakeUseOf"},"author":"Jack Slater","title":"How to Add Classic XP Screensavers to Windows 11","description":"Do you miss the old 3D Maze screensaver? Here\'s how to get it back.","url":"https://www.makeuseof.com/windows-11-classic-xp-screensavers/","urlToImage":"https://static1.makeuseofimages.com/wordpress/wp-content/uploads/2021/10/windows-screensaver-fix-featured.jpg","publishedAt":"2021-12-20T18:15:12Z","content":"Do you remember the good old days of Windows 95 or XP? Windows 95 was an important time for Microsoft\'s OS and established the Start menu as a reoccurring feature in future versions. Meanwhile, Windo… [+4720 chars]"},{"source":{"id":null,"name":"MakeUseOf"},"author":"Emma Garofalo","title":"5 Free Methods to Schedule Facebook Updates","description":"Whether you\'re managing a small business or a casual Facebook page, here are free tools that let you schedule Facebook posts...","url":"https://www.makeuseof.com/tag/5-free-methods-schedule-facebook-updates/","urlToImage":"https://static1.makeuseofimages.com/wordpress/wp-content/uploads/2021/10/laptop-with-facebook-icon-on-screen.jpg","publishedAt":"2021-12-29T12:30:24Z","content":"There are many ways that you can schedule social media updates on Facebook; even if you\'re not at your computer, you can continue to send gags, links and posts with your audience.\\r\\nIf you\'re running … [+5408 chars]"},{"source":{"id":null,"name":"Search Engine Journal"},"author":"Heather Campbell","title":"Landing Page SEO Best Practices & Tips For Success via @sejournal, @hethr_campbell","description":"Discover the ways you can improve your ranking with landing page optimization and how the landscape has changed.The post Landing Page SEO Best Practices & Tips For Success appeared first on Search Engine Journal.","url":"https://www.searchenginejournal.com/landing-page-best-practices-webinar/430890/","urlToImage":"https://cdn.searchenginejournal.com/wp-content/uploads/2021/12/featured-copy-61c34a9965872-sej.jpg","publishedAt":"2022-01-06T11:45:38Z","content":"Google constantly updates its algorithm. This year alone, they’ve announced 12 significant updates.\\r\\nBut, of course, it doesn’t include the hundreds of minor updates Google has made to its search eng… [+6078 chars]"},{"source":{"id":null,"name":"Forbes"},"author":"Expert Panel, Forbes Councils Member, \\n Expert Panel, Forbes Councils Member\\n https://www.forbes.com/sites/theyec/people/expertpanel/","title":"Limited Business Experience? 10 Tips To Build A Successful E-Commerce Site","description":"Like any business, creating an e-commerce site isn\'t as easy as paying for a domain and letting the website sit.","url":"https://www.forbes.com/sites/theyec/2022/01/05/limited-business-experience-10-tips-to-build-a-successful-e-commerce-site/","urlToImage":"https://thumbor.forbes.com/thumbor/fit-in/1200x0/filters%3Aformat%28jpg%29/https%3A%2F%2Fspecials-images.forbesimg.com%2Fimageserve%2F61d4b26f3c5be2c048554665%2F0x0.jpg","publishedAt":"2022-01-05T13:15:00Z","content":"E-commerce has steadily risen in popularity among aspiring entrepreneurs who want a simple business model with less overhead than a traditional retail store. Selling online is a great way for inexper… [+7390 chars]"},{"source":{"id":null,"name":"Convinceandconvert.com"},"author":"Ann Smarty","title":"SEO for a New Site: Checklist","description":"Starting SEO for a new site is overwhelming, especially if you haven’t done it dozens of times already. In fact, the process can be quite intimidating, as there are so many technical tasks involved. SEO for a new site is one of those most intimidating tasks n…","url":"https://www.convinceandconvert.com/?p=159217","urlToImage":"https://www.convinceandconvert.com/wp-content/uploads/2021/12/SEO-for-a-New-Site-Checklist.jpg","publishedAt":"2021-12-15T12:00:26Z","content":"Starting SEO for a new site is overwhelming, especially if you havent done it dozens of times already.\\r\\nIn fact, the process can be quite intimidating, as there are so many technical tasks involved.\\r… [+7149 chars]"},{"source":{"id":null,"name":"Chromium.org"},"author":"Chromium Blog","title":"Chrome 98 Beta: Color Gradient Vector Fonts, Region Capture Origin Trial, and More","description":"Unless otherwise noted, changes described below apply to the newest Chrome beta channel release for Android, Chrome OS, Linux, macOS, and Wi...","url":"https://blog.chromium.org/2022/01/chrome-98-beta-color-gradient-vector.html","urlToImage":"http://1.bp.blogspot.com/-vkF7AFJOwBk/VkQxeAGi1mI/AAAAAAAARYo/57denvsQ8zA/s1600-r/logo_chromium.png","publishedAt":"2022-01-10T17:41:00Z","content":"Unless otherwise noted, changes described below apply to the newest Chrome beta channel release for Android, Chrome OS, Linux, macOS, and Windows. Learn more about the features listed here through th… [+9367 chars]"},{"source":{"id":null,"name":"Forbes"},"author":"John Hall, Senior Contributor, \\n John Hall, Senior Contributor\\n https://www.forbes.com/sites/johnhall/","title":"4 Ways Readers Have Adapted To Filter Out Irrelevant Content","description":"Savvy readers have grown weary of irrelevant content landing on page one of their searches, so they tune it out. Businesses that commit to creating top-notch content could re-energize their audience—and themselves.","url":"https://www.forbes.com/sites/johnhall/2021/12/12/4-ways-readers-have-adapted-to-filter-out-irrelevant-content/","urlToImage":"https://thumbor.forbes.com/thumbor/fit-in/1200x0/filters%3Aformat%28jpg%29/https%3A%2F%2Fspecials-images.forbesimg.com%2Fimageserve%2F61b390a428929ea901b3b691%2F0x0.jpg%3FcropX1%3D134%26cropX2%3D1157%26cropY1%3D0%26cropY2%3D681","publishedAt":"2021-12-12T13:00:00Z","content":"Searching the internet concept\\r\\ngetty\\r\\nOnly quality content is king. The rest is a court jester, distracting the audience but failing miserably to entertain or inform it.  The internet features a pro… [+5706 chars]"},{"source":{"id":null,"name":"Bleeding Cool News"},"author":"Jude Terror","title":"Future State: Gotham #8 Preview: In This Issue… Everyone WILL DIE?!","description":"Friday night is upon us once again, and that means it\'s time for another round of Friday Night Previews, the Bleeding Cool feature where we goose our article quota by auto-generating these mostly complete previews articles and then finish them off with a clic…","url":"https://bleedingcool.com/comics/future-state-gotham-8-preview-in-this-issue-everyone-will-die/","urlToImage":"https://bleedingcool.com/wp-content/uploads/2021/12/1021DC088-1200x628.jpg","publishedAt":"2021-12-11T04:26:12Z","content":"Friday night is upon us once again, and that means it\'s time for another round of Friday Night Previews, the Bleeding Cool feature where we goose our article quota by auto-generating these mostly com… [+3172 chars]"},{"source":{"id":null,"name":"Bleeding Cool News"},"author":"Jude Terror","title":"Batgirls #1 Preview: Now With Three Batgirls","description":"Welcome, dear readers, to Friday Night Previews, North Korea\'s favorite weekly comic book preview column. In Friday Night Previews, we take all of the Marvel and DC previews coming out next week, lovingly construct articles out of them using state-of-the-art …","url":"https://bleedingcool.com/comics/batgirls-1-preview-now-with-three-batgirls/","urlToImage":"https://bleedingcool.com/wp-content/uploads/2021/12/1021DC012-1200x628.jpg","publishedAt":"2021-12-11T00:29:11Z","content":"Welcome, dear readers, to Friday Night Previews, North Korea\'s favorite weekly comic book preview column. In Friday Night Previews, we take all of the Marvel and DC previews coming out next week, lov… [+4136 chars]"},{"source":{"id":null,"name":"Paulbricman.com"},"author":null,"title":"Decontextualizer","description":"A pipeline for making highlighted text stand-alone.","url":"https://paulbricman.com/thoughtware/decontextualizer","urlToImage":"https://paulbricman.com/assets/img/decontextualizer_featured.png","publishedAt":"2021-12-13T03:55:57Z","content":"back\\r\\nAs a second step in improving our content consumption workflows, I investigated a new approach to extracting fragments from a content item before saving them for subsequent surfacing. While the… [+9766 chars]"},{"source":{"id":null,"name":"Bleeding Cool News"},"author":"Jude Terror","title":"Black Manta #4 Preview: It\'s Always a Wizard\'s Fault","description":"Welcome, dear readers, to Friday Night Previews, North Korea\'s favorite weekly comic book preview column. In Friday Night Previews, we take all of the Marvel and DC previews coming out next week, lovingly construct articles out of them using state-of-the-art …","url":"https://bleedingcool.com/comics/black-manta-4-preview-its-always-a-wizards-fault/","urlToImage":"https://bleedingcool.com/wp-content/uploads/2021/12/1021DC073-1200x628.jpg","publishedAt":"2021-12-11T03:27:12Z","content":"Welcome, dear readers, to Friday Night Previews, North Korea\'s favorite weekly comic book preview column. In Friday Night Previews, we take all of the Marvel and DC previews coming out next week, lov… [+3343 chars]"},{"source":{"id":null,"name":"Bleeding Cool News"},"author":"Jude Terror","title":"Demon Days: Rising Storm #1 Preview: A Penultimate Preview","description":"Welcome, dear readers, to Friday Night Previews, North Korea\'s favorite weekly comic book preview column. In Friday Night Previews, we take all of the Marvel and DC previews coming out next week, lovingly construct articles out of them using state-of-the-art …","url":"https://bleedingcool.com/comics/demon-days-rising-storm-1-preview-a-penultimate-preview/","urlToImage":"https://bleedingcool.com/wp-content/uploads/2021/12/DEMONDAYSRSTORM2021001_Preview-1200x628.jpeg","publishedAt":"2021-12-11T02:57:11Z","content":"Welcome, dear readers, to Friday Night Previews, North Korea\'s favorite weekly comic book preview column. In Friday Night Previews, we take all of the Marvel and DC previews coming out next week, lov… [+2814 chars]"},{"source":{"id":null,"name":"Bleeding Cool News"},"author":"Jude Terror","title":"Teen Titans Academy #9 Preview: Wally West Redeemed?! Again?!","description":"Friday night is upon us once again, and that means it\'s time for another round of Friday Night Previews, the Bleeding Cool feature where we goose our article quota by auto-generating these mostly complete previews articles and then finish them off with a clic…","url":"https://bleedingcool.com/comics/teen-titans-academy-9-preview-wally-west-redeemed-again/","urlToImage":"https://bleedingcool.com/wp-content/uploads/2021/12/0921DC179-1200x628.jpg","publishedAt":"2021-12-11T08:43:12Z","content":"Friday night is upon us once again, and that means it\'s time for another round of Friday Night Previews, the Bleeding Cool feature where we goose our article quota by auto-generating these mostly com… [+2973 chars]"},{"source":{"id":null,"name":"Bleeding Cool News"},"author":"Jude Terror","title":"Robin & Batman #2 Preview: Dick Grayson, Problem Child?","description":"Friday night is upon us once again, and that means it\'s time for another round of Friday Night Previews, the Bleeding Cool feature where we goose our article quota by auto-generating these mostly complete previews articles and then finish them off with a clic…","url":"https://bleedingcool.com/comics/robin-batman-2-preview-dick-grayson-problem-child/","urlToImage":"https://bleedingcool.com/wp-content/uploads/2021/12/0921DC044-1200x628.jpg","publishedAt":"2021-12-11T08:13:12Z","content":"Friday night is upon us once again, and that means it\'s time for another round of Friday Night Previews, the Bleeding Cool feature where we goose our article quota by auto-generating these mostly com… [+2708 chars]"},{"source":{"id":null,"name":"Bleeding Cool News"},"author":"Jude Terror","title":"Miles Morales: Spider-Man #33 Preview: Spider-Man No More?!","description":"Friday night is upon us once again, and that means it\'s time for another round of Friday Night Previews, the Bleeding Cool feature where we goose our article quota by auto-generating these mostly complete previews articles and then finish them off with a clic…","url":"https://bleedingcool.com/comics/miles-morales-spider-man-33-preview-spider-man-no-more/","urlToImage":"https://bleedingcool.com/wp-content/uploads/2021/12/MMSM2018033_Preview-1200x628.jpeg","publishedAt":"2021-12-11T07:57:10Z","content":"Friday night is upon us once again, and that means it\'s time for another round of Friday Night Previews, the Bleeding Cool feature where we goose our article quota by auto-generating these mostly com… [+2557 chars]"},{"source":{"id":null,"name":"Bleeding Cool News"},"author":"Jude Terror","title":"Legends of the Dark Knight #8 Preview: Batman vs… A Little Girl?!","description":"Welcome, dear readers, to Friday Night Previews, North Korea\'s favorite weekly comic book preview column. In Friday Night Previews, we take all of the Marvel and DC previews coming out next week, lovingly construct articles out of them using state-of-the-art …","url":"https://bleedingcool.com/comics/legends-of-the-dark-knight-8-preview-batman-vs-a-little-girl/","urlToImage":"https://bleedingcool.com/wp-content/uploads/2021/12/1021DC119-1200x628.jpg","publishedAt":"2021-12-18T04:26:15Z","content":"Welcome, dear readers, to Friday Night Previews, North Korea\'s favorite weekly comic book preview column. In Friday Night Previews, we take all of the Marvel and DC previews coming out next week, lov… [+3352 chars]"},{"source":{"id":null,"name":"Marketingdirecto.com"},"author":"Berta Jiménez","title":"¿Se puede posicionar una marca en el primer puesto de Google en tan solo unos segundos? Esta herramienta lo hace posible","description":"Las marcas pueden lograr el primer puesto en el buscador de Google incluso para las keywords de su competencia con esta acción diseñada por la agencia especializada en SEO Oorganika.\\nLa entrada ¿Se puede posicionar una marca en el primer puesto de Google en t…","url":"https://www.marketingdirecto.com/anunciantes-general/anunciantes/colocarse-primer-puesto-internet","urlToImage":"https://www.marketingdirecto.com/wp-content/uploads/2021/12/Medalla.jpg","publishedAt":"2021-12-28T07:20:00Z","content":"Las marcas pueden lograr el primer puesto en el buscador de Google incluso para las keywords de su competencia con esta acción diseñada por la agencia especializada en SEO Oorganika.¿Es posible que P… [+2360 chars]"}]}
"""
