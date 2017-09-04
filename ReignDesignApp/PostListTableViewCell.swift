//
//  PostListTableViewCell.swift
//  ReignDesignApp
//
//  Created by Israel on 04/09/17.
//  Copyright © 2017 IsraelGutierrez. All rights reserved.
//

import UIKit

class PostListTableViewCell: UITableViewCell {
    
    private var postCDData: PostCD! = nil
    
    func setData(newData: PostCD) {
        
        postCDData = newData
        self.changeLabelInfo()
        
    }
    
    private func changeLabelInfo() {
    
        if postCDData != nil {
            
            self.textLabel?.text = postCDData.title!
            
        }
    
    }
    
    
    
}
