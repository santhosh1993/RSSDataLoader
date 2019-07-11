//
//  RSSDataLoader.swift
//  RSSDataLoader
//
//  Created by Santhosh Nampally on 03/07/19.
//  Copyright © 2019 Santhosh Nampally. All rights reserved.
//

import Foundation

public protocol RSSDataLoaderCallback {
    func completion(status:Bool)
}

public class RSSDataLoader: NSObject {
    static let shared = RSSDataLoader()
    let dataHandler = CoreDataHandler()
    let parser = RSSDataParser()
    var callBack:RSSDataLoaderCallback?
    
    override init() {
        super.init()
    }
    
    public static func addNewRSSFeed(url:String, title:String, callBack:RSSDataLoaderCallback){
        self.shared.callBack = callBack
        self.shared.dataHandler.addUrl(url: url, title: title) {(status) in
            if let requestUrl = URL(string: url){
                self.shared.parser.startParsingWithContentsOfUrl(rssUrl: requestUrl, with: { (status) in
                    print(self.shared.parser.parsedData)
                    self.shared.dataHandler.addFeedData(for: url, data: self.shared.parser.parsedData, completion: { (status) in
                        callBack.completion(status: status)
                    })
                })
            }
            else {
                callBack.completion(status: status)
            }
        }
    }
}
