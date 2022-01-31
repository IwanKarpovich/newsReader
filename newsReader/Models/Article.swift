//
//  Article.swift
//  newsReader
//
//  Created by Ivan Karpovich on 7.01.22.
//

import Foundation

class Article : NSObject{
    var headline: String?
    var desc: String?
    var author: String?
    var url: String?
    var imageUrl: String?
    var marker: Bool = false
    
}

class ArticlesState {
    var articles:[Article] = []
    
    
    func parseJson(_ data: Data?) ->([Article]) {
        var articles: [Article] = []
        do{
            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
            if let articlesFromJson = json["articles"] as? [[String:AnyObject]] {
                for articleFromJson in articlesFromJson{
                    let article = Article()
                    let title = articleFromJson["title"] as? String
                    let author = articleFromJson["publishedAt"] as? String
                    let desc = articleFromJson["description"] as? String
                    let url = articleFromJson["url"] as? String
                    let urlToImage = articleFromJson["urlToImage"] as? String
                    
              
                   

                    let dateFormatter = ISO8601DateFormatter()
                    var date = dateFormatter.date(from:author!)
                    
                    let dateFormatter2 = DateFormatter()

                    // Set Date Format
                    dateFormatter2.dateFormat = "dd.MM.y, HH:mm:ss "

                    // Convert Date to String
                    
                    if let date = date{
                        article.author = dateFormatter2.string(from: date)
                        
                    }else{
                        article.author = ""
                    }
                    article.desc = desc
                    article.headline = title
                    article.url = url
                    article.imageUrl = urlToImage
                    
                    articles.append(article)
                }
                
            }
        }
        catch{
            
        }
        return articles
    }
    
    func setArticles(newArticles:[Article],  onSuccess: @escaping()->Void ){
        articles = newArticles
        DispatchQueue.main.async {
            onSuccess()
        }
    }
    
    func requestArticle(urlstring:String ,  onSuccess: @escaping ()->Void ){
        
        let urlRequest = URLRequest(url: URL(string: urlstring.encodeUrl)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest){
            (data,response,error) in
            
            if error != nil {
                return
            }
            
            
            do{
                let newArticles = self.parseJson(data)
                self.setArticles(newArticles:newArticles,onSuccess: onSuccess)
            }
        }
        
        task.resume()
    }
    
}

extension String{
    var encodeUrl : String
    {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    var decodeUrl : String
    {
        return self.removingPercentEncoding!
    }
}



var articlesState =  ArticlesState()


class NextView {
    var userNames = ""
    var name = "online"
    var typeOfFunc = "top"
    var categoryName: String = "none"
    var searchByCountry: String = ""
    var wordSearch: String = "none"
    var selectedArticle: Article?
    var sourcesName: String = "none"
    var markerArticles: [Article]? = []
    var url: String?
}

var nextView = NextView()
