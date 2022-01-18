//
//  WebViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 9.01.22.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    

  //  var articles: [Article]? = []
  
    var categoryName: String = ""
    var typeOfFunc = ""
    var name: String = ""
    var searchByCountry: String = ""
    var wordSearch: String = ""
    var markerArticles: [Article]? = []
    var selectedArticle: Article?


    var test: Bool = true
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var markerButton: UIButton!
    @IBOutlet weak var webview: WKWebView!
    //  @IBOutlet weak var df: WKWebView!
    
    // @IBOutlet weak var webview: WKWebView!
    
    var url: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        print(name)
        webview.load(URLRequest(url: URL(string:url!)!))
        let selectedArticleUrl = selectedArticle!.url
        let articleIndex = (markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
        print(articleIndex)
        if let articleIndex = articleIndex
        {
            markerButton.isSelected.toggle()
            markerButton.setImage(UIImage(systemName: "star.fill"), for: .selected)

        }
        
    }
    
    
    @IBAction func shareAction(_ sender: Any) {
        print("toychButton")
        let items:[Any] = [URL(string:url!)]
       
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }
    
    @IBAction func markerGoButton(_ sender: Any) {
        print("sf")
        markerButton.isSelected.toggle()
        markerButton.setImage(UIImage(systemName: "star"), for: .normal)
        markerButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
        if markerButton.isSelected == false {
            let selectedArticleUrl = selectedArticle!.url
           let articleIndex = (markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
            if let articleIndex = articleIndex
            {
                markerArticles?.remove(at: articleIndex)
            }
         }
        if markerButton.isSelected == true {
            print("print true")
            self.markerArticles?.append(self.selectedArticle!)

        }

    }
    
    
    @IBAction func goBack(_ sender: Any) {
        print("sf")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let secondViewController = storyboard.instantiateViewController(identifier: "newsMenu") as? ViewController else { return }
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

   //     secondViewController.articles = articles

        show(secondViewController, sender: nil)
        
    }
    
    
    
    
}
