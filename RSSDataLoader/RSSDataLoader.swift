//
//  RSSDataLoader.swift
//  RSSDataLoader
//
//  Created by Santhosh Nampally on 03/07/19.
//  Copyright © 2019 Santhosh Nampally. All rights reserved.
//

import Foundation

public class RSSDataLoader {
    static let shared = RSSDataLoader()
    let dataHandler = CoreDataHandler()
    
    public static func addNewRSSFeed(url:String, title:String,completion:(Bool)->Void){
        self.shared.dataHandler.addUrl(url: url, title: title) { (status) in
            completion(status)
        }
    }
}


