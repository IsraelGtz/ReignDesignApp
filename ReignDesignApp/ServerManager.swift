//
//  ServerManager.swift
//  ReignDesignApp
//
//  Created by Israel on 03/09/17.
//  Copyright © 2017 IsraelGutierrez. All rights reserved.
//

import Foundation
import Alamofire

class ServerManager: NSObject {
    
    static let sharedInstance = ServerManager()
    
    static let developmentServer = ""
    static let productionServer  = "https://hn.algolia.com/api"
    let typeOfServer = productionServer
    
    let clientID = "b98414c6b2f43a2bca42"
    let clientSecret = "1ac759acd386cb4c7b1a246723a6ca2f41fbf89f"
    
    func getAllPosts(actionsToDoWhenSucceeded: @escaping (_ arrayOfPosts: Array<Post>) -> Void, actionsToDoWhenFailed: @escaping () -> Void ) {
     
                let urlToRequest = "\(typeOfServer)/v1/search_by_date?query=ios"
        
                var requestConnection = URLRequest.init(url: NSURL.init(string: urlToRequest)! as URL)
                requestConnection.httpMethod = "GET"
        
        
                Alamofire.request(requestConnection)
                    .validate(statusCode: 200..<400)
                    .responseJSON{ response in
                        if response.response?.statusCode == 200 {
        
                            do {
        
                                var arrayOfPosts: Array<Post> = Array<Post>()
        
                                let infoRawData = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: AnyObject]
                                
                                print(infoRawData)
                                
                                let rawPostList = infoRawData["hits"] as? Array<[String: AnyObject]> != nil ? infoRawData["hits"] as! Array<[String: AnyObject]> : Array<[String: AnyObject]>()
                                
                                for post in rawPostList {
                                    
                                    let dateOfCreationString = post["created_at"] as? String != nil ? post["created_at"] as! String : "1900-01-01T00:00:00.000Z"
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                    let dateOfPost = dateFormatter.date(from: dateOfCreationString)
                                    
                                    let postTitle = post["story_title"] as? String != nil ? post["story_title"] as! String : "No Title"
                                    let postId = post["objectID"] as? String != nil ? post["objectID"] as! String : "NoID"
                                    let postURL = post["story_url"] as? String != nil ? post["story_url"] as! String : ""
                                    
                                    let newPost = Post.init(newId: postId, newDate: dateOfPost!, newTitle: postTitle, newUrl: postURL)
                                    
                                    arrayOfPosts.append(newPost)
                                    
                                }
                                
                                actionsToDoWhenSucceeded(arrayOfPosts)
                                
        
                            } catch(_) {
        
                                let alertController = UIAlertController(title: "ERROR",
                                                                        message: "Connection error, try later",
                                                                        preferredStyle: UIAlertControllerStyle.alert)
        
                                let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        
                                    actionsToDoWhenFailed()
        
                                }
        
                                alertController.addAction(cancelAction)
        
                                let actualController = UtilityManager.sharedInstance.currentViewController()
                                actualController.present(alertController, animated: true, completion: nil)
        
                            }
        
                        } else {
        
                            let alertController = UIAlertController(title: "ERROR",
                                                                    message: "Connection error, try later",
                                                                    preferredStyle: UIAlertControllerStyle.alert)
        
                            let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                                
                                actionsToDoWhenFailed()
                                
                            }
                            
                            alertController.addAction(cancelAction)
                            
                            let actualController = UtilityManager.sharedInstance.currentViewController()
                            actualController.present(alertController, animated: true, completion: nil)
                            
                        }
                        
                }
        
    }
    
}


