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
    
    func requestArticle(urlstring:String ,  onSuccess: @escaping()->Void ){
        
        let urlRequest = URLRequest(url: URL(string: urlstring)!)
        
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





var articlesState =  ArticlesState()

