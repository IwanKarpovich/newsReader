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
//struct Article: Codable {
//   // let message: Double
//      let articles : [inArticle]
//
//}
//
//struct inArticle: Codable {
//   // let message: Double
//    let author : String?
//    let description:String
//
//}
