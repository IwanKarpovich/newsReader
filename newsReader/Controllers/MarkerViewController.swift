//
//  MarkerViewController.swift
//  newsReader
//
//  Created by Ivan Karpovich on 14.01.22.
//

import UIKit
import Firebase
import LocalAuthentication


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
    
    var arrayHeadline: [String] = []
    var noteHeadline: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let db = Firestore.firestore()
        let userMarkers = db.collection("users").document(nameUsers).collection("markers")
        userMarkers.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let select = document.get("headline") as! String
                        let note = document.get("note") as! String
                        
                        self.arrayHeadline.append(select)
                        self.noteHeadline.append(note)
                    }
                }
            }
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {
        
        
        let swipeNote = UIContextualAction(style: .normal, title: "note")
        { [self]
            (action,view,success) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let context = LAContext()
             var error: NSError?

             if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {

                 let reason = "Идентифицируйте себя"
                 context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in

                     if success {
                         DispatchQueue.main.async { [unowned self] in
                             print("Успешная авторизация")
                             guard let secondViewController = storyboard.instantiateViewController(identifier: "note") as? NoteViewController else { return }
                             selectedArticle = markerArticles![indexPath.row]
                             secondViewController.name = name
                             secondViewController.typeOfFunc = typeOfFunc
                             secondViewController.categoryName = categoryName
                             secondViewController.searchByCountry = searchByCountry
                             secondViewController.wordSearch = wordSearch
                             secondViewController.selectedArticle = selectedArticle
                             secondViewController.markerArticles = markerArticles
                             secondViewController.nameUsers = nameUsers
                             secondViewController.sourcesName = sourcesName
                             show(secondViewController, sender: nil)
                             print("asdfsdf")
                         }
                     }
                 }

             } else {
                 print("Face/Touch ID не найден")
             }


        }
 
        
        
        let delete = UIContextualAction(style: .normal, title: "delete")
        { [self]
            (action,view,success) in
            let db = Firestore.firestore()
            let washingtonRef = db.collection("users").document(nameUsers).collection("markers")
            let selectedArticleUrl = markerArticles![indexPath.row].url
            let selectedArticleHeadline = markerArticles![indexPath.row].headline

            let articleIndex = (markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))
            if let articleIndex = articleIndex
            {
                washingtonRef.document("marker\(selectedArticleHeadline ?? "")").updateData(([
                    "note":" "
                ]))
                noteHeadline[indexPath.row] = " "
            }
            
   
        }

        var arrayActions = [swipeNote]
        
        let db = Firestore.firestore()
        let userMarkers = db.collection("users").document(nameUsers).collection("markers")
        let selectedArticleUrl = markerArticles![indexPath.row].url
        let selectedArticleHeadline = markerArticles![indexPath.row].headline!
        var note: String = " "
        let articleIndex = (markerArticles?.firstIndex(where: { $0.url == selectedArticleUrl }))

//        userMarkers.getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                } else {
//                    for document in querySnapshot!.documents {
//                        let select = document.get("headline") as! String
//                        if select == selectedArticleHeadline {
//                        note = document.get("note") as! String
//                            if note != " "{
//                                arrayActions.append(delete)
//                                return
//                            }
//                        }
//                    }
//                }
//            }
        
        for i in 0...(arrayHeadline.count-1) {
            if arrayHeadline[i] == selectedArticleHeadline {
                note = noteHeadline[i]
               if note != " "{
                        arrayActions.append(delete)
                            }
                    }
        }
         
        //arrayActions.append(delete)

        swipeNote.image = UIImage(systemName: "note.text")
        
        swipeNote.backgroundColor = UIColor.systemBlue
        delete.image = UIImage(systemName: "trash.fill")
        
        delete.backgroundColor = UIColor.systemRed
        
        
        let configure = UISwipeActionsConfiguration(actions: arrayActions)
        configure.performsFirstActionWithFullSwipe = false
        return configure
    }
    
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

