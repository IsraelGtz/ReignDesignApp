//
//  Post.swift
//  ReignDesignApp
//
//  Created by Israel on 03/09/17.
//  Copyright © 2017 IsraelGutierrez. All rights reserved.
//

import Foundation

class Post {
    
    var id: String! = nil
    var date: Date! = nil
    var title: String! = nil
    var url: String! = nil
    
    init(newId: String, newDate: Date, newTitle: String, newUrl: String) {
        
        id = newId
        date = newDate
        title = newTitle
        url = newUrl
        
    }
    
}
