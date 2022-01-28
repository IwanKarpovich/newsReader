//
//  WebViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 9.01.22.
//

import UIKit
import WebKit
import Firebase

class WebViewController: UIViewController {
    
    var categoryName: String = ""
    var typeOfFunc = ""
    var name: String = ""
    var searchByCountry: String = ""
    var wordSearch: String = ""
    var markerArticles: [Article]? = []
    var selectedArticle: Article?
    var userNames: String = ""
    var sourcesName: String = ""
    
    
    var test: Bool = true
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var markerButton: UIButton!
    @IBOutlet weak var webview: WKWebView!
    
    var url: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: [AnalyticsParameterScreenName: selectedArticle!.url!,
                                       AnalyticsParameterScreenClass: selectedArticle!.url!])
        webview.load(URLRequest(url: URL(string:url!)!))
        let selectedArticleUrl = selectedArticle!.url
        let articleIndex = (markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
        if articleIndex != nil
        {
            markerButton.isSelected.toggle()
            markerButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
            
        }
        
    }
    
    
    @IBAction func shareAction(_ sender: Any) {
        let items:[Any] = [URL(string:url!)!]
        
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }
    
    @IBAction func markerGoButton(_ sender: Any) {
        markerButton.isSelected.toggle()
        markerButton.setImage(UIImage(systemName: "star"), for: .normal)
        markerButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        let db = Firestore.firestore()
        let userMarkers = db.collection("users").document(userNames).collection("markers")
        if markerButton.isSelected == false {
            let selectedArticleUrl = selectedArticle!.url
            let selectedArticleHeadline = selectedArticle!.headline

            let articleIndex = (markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
            if let articleIndex = articleIndex
            {
                userMarkers.document("marker\(selectedArticleHeadline ?? "")").delete()
                markerArticles?.remove(at: articleIndex)
            }
        }
        if markerButton.isSelected == true {
            self.markerArticles?.append(self.selectedArticle!)
            userMarkers.document("marker\( markerArticles![markerArticles!.count - 1].headline ?? "")").setData([
                "headline":markerArticles![markerArticles!.count - 1].headline!,
                "desc": markerArticles![markerArticles!.count - 1].desc!,
                "author": markerArticles![markerArticles!.count - 1].author!,
                "url": markerArticles![markerArticles!.count - 1].url!,
                "imageUrl": markerArticles![markerArticles!.count - 1].imageUrl!,
                "marker": markerArticles![markerArticles!.count - 1].marker,
                "note":" "
            ])
        }
        
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? NewsViewController else { return }
        if name == "online"{
            secondViewController.name = "online"
        }
        else {
            secondViewController.name = "offline"
        }
        secondViewController.typeOfFunc = typeOfFunc
        secondViewController.categoryName = categoryName
        secondViewController.searchByCountry = searchByCountry
        secondViewController.wordSearch = wordSearch
        secondViewController.markerArticles = markerArticles
        secondViewController.sourcesName = sourcesName
        show(secondViewController, sender: nil)
        
    }
}
