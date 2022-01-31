//
//  NoteViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 26.01.22.
//

import UIKit
import Firebase

class NoteViewController: UIViewController {
    var numberIndex: IndexPath = []
//    var categoryName: String = ""
//    var typeOfFunc = ""
//    var name: String = ""
//    var searchByCountry: String = ""
//    var wordSearch: String = ""
//    var markerArticles: [Article]? = []
//    var selectedArticle: Article?
//    var sourcesName: String = ""
//    var userNames: String = ""
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        let userMarkers = db.collection("users").document(nextView.userNames).collection("markers")
        let selectedArticleUrl = nextView.selectedArticle!.url
        let selectedArticleHeadline = nextView.selectedArticle!.headline
        var note: String = " "
        let articleIndex = (nextView.markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
        if let articleIndex = articleIndex
        {
            let wf =  userMarkers.document("marker\(selectedArticleHeadline ?? "")")
            
            userMarkers.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let select = document.get("headline") as! String
                        if select == selectedArticleHeadline {
                        note = document.get("note") as! String
                            self.textView.text = note
                        }
                    }
                
                }
            }
         
        }
        
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func goToMarker(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "marker") as? MarkerViewController else { return }
//        secondViewController.name = name
//        secondViewController.typeOfFunc = typeOfFunc
//        secondViewController.searchByCountry = searchByCountry
//        secondViewController.categoryName = categoryName
//        secondViewController.wordSearch = wordSearch
//        secondViewController.markerArticles = markerArticles
//        secondViewController.sourcesName = sourcesName
//        secondViewController.userNames = userNames
        let text = textView.text
        
        let db = Firestore.firestore()
        let washingtonRef = db.collection("users").document(nextView.userNames).collection("markers")
        let selectedArticleUrl = nextView.selectedArticle!.url
        let selectedArticleHeadline = nextView.selectedArticle!.headline

        let articleIndex = (nextView.markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
        if let articleIndex = articleIndex
        {
            washingtonRef.document("marker\(selectedArticleHeadline ?? "")").updateData(([
                "note":text
            ]))
        }
        print(text)
        navigationController?.popViewController(animated: true)

//        show(secondViewController, sender: nil)
    }
    
    
}
