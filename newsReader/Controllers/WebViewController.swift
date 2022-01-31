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
    
//    var categoryName: String = ""
//    var typeOfFunc = ""
//    var name: String = ""
//    var searchByCountry: String = ""
//    var wordSearch: String = ""
//    var markerArticles: [Article]? = []
//    var selectedArticle: Article?
//    var userNames: String = ""
//    var sourcesName: String = ""
    
    
    var test: Bool = true
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var markerButton: UIButton!
    @IBOutlet weak var webview: WKWebView!
    
//    var url: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: [AnalyticsParameterScreenName: nextView.selectedArticle!.url!,
                                       AnalyticsParameterScreenClass: nextView.selectedArticle!.url!])
        webview.load(URLRequest(url: URL(string:nextView.url!)!))
        let selectedArticleUrl = nextView.selectedArticle!.url
        let articleIndex = (nextView.markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
        if articleIndex != nil
        {
            markerButton.isSelected.toggle()
            markerButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
            
        }
        
    }
    
    
    @IBAction func shareAction(_ sender: Any) {
        let items:[Any] = [URL(string:nextView.url!)!]
        
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }
    
    @IBAction func markerGoButton(_ sender: Any) {
        markerButton.isSelected.toggle()
        markerButton.setImage(UIImage(systemName: "star"), for: .normal)
        markerButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        let db = Firestore.firestore()
        let userMarkers = db.collection("users").document(nextView.userNames).collection("markers")
        if markerButton.isSelected == false {
            let selectedArticleUrl = nextView.selectedArticle!.url
            let selectedArticleHeadline = nextView.selectedArticle!.headline

            let articleIndex = (nextView.markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
            if let articleIndex = articleIndex
            {
                userMarkers.document("marker\(selectedArticleHeadline ?? "")").delete()
                nextView.markerArticles?.remove(at: articleIndex)
            }
        }
        if markerButton.isSelected == true {
            nextView.markerArticles?.append(nextView.selectedArticle!)
            userMarkers.document("marker\( nextView.markerArticles![nextView.markerArticles!.count - 1].headline ?? "")").setData([
                "headline":nextView.markerArticles![nextView.markerArticles!.count - 1].headline!,
                "desc": nextView.markerArticles![nextView.markerArticles!.count - 1].desc!,
                "author": nextView.markerArticles![nextView.markerArticles!.count - 1].author!,
                "url": nextView.markerArticles![nextView.markerArticles!.count - 1].url!,
                "imageUrl": nextView.markerArticles![nextView.markerArticles!.count - 1].imageUrl!,
                "marker": nextView.markerArticles![nextView.markerArticles!.count - 1].marker,
                "note":" "
            ])
        }
        
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? NewsViewController else { return }
        if nextView.name == "online"{
            nextView.name = "online"
        }
        else {
            nextView.name = "offline"
        }
//        secondViewController.typeOfFunc = typeOfFunc
//        secondViewController.categoryName = categoryName
//        secondViewController.searchByCountry = searchByCountry
//        secondViewController.wordSearch = wordSearch
//        secondViewController.markerArticles = markerArticles
//        secondViewController.sourcesName = sourcesName
      
        navigationController?.popViewController(animated: true)

        //  show(secondViewController, sender: nil)
        
    }
}
