//
//  RSSDataLoader.swift
//  RSSDataLoader
//
//  Created by Santhosh Nampally on 03/07/19.
//  Copyright © 2019 Santhosh Nampally. All rights reserved.
//

import Foundation

public protocol RSSFeedProtocol {
    var feedDescription:String? {get}
    var redirectionUrl:String? {get}
    var title:String? {get}
    var pubDate:Date? {get}
    var guid:String? {get}
}

public protocol RSSFeedsProtocol {
    var title:String? {get}
    var url:String? {get}
    var feed:NSSet? {get}
}

public protocol RSSDataLoaderCallback {
    func completion(status:Bool)
    func dataGotUpdated()
}

public class RSSDataLoader: NSObject {
    static let shared = RSSDataLoader()
    let dataHandler = CoreDataHandler()
    let parser = RSSDataParser()
    var callBack:RSSDataLoaderCallback?
    
    private override init() {
        super.init()
    }
    
    public static func addNewRSSFeed(url:String, title:String, callBack:RSSDataLoaderCallback){
        self.shared.callBack = callBack
        self.shared.dataHandler.addUrl(url: url, title: title) {(status) in
            if let requestUrl = URL(string: url){
                self.shared.parser.startParsingWithContentsOfUrl(rssUrl: requestUrl, with: { (status) in
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
    
    public static func updateTheFeed() {
        let feedUrls = getRSSFeeds()
        
        for feedUrl in feedUrls {
            if let urlStr = feedUrl.url,
                let requestUrl = URL(string: urlStr) {
                self.shared.parser.startParsingWithContentsOfUrl(rssUrl: requestUrl) { (status) in
                    self.shared.callBack?.dataGotUpdated()
                }
            }
        }
    }
    
    public static func updateTheState(for feed:RSSFeedProtocol,withStatusOf done:Bool,and opened:Bool) {
        self.shared.dataHandler.updateTheFeedStatus(for: feed.guid ?? "", withStatusOf: done, and: opened) { (status) in
            self.shared.callBack?.dataGotUpdated()
        }
    }
    
    public static func getRSSFeeds() -> [RSSFeedsProtocol] {
        if let data = self.shared.dataHandler.fetchTheData(entity: "RSSFeedUrl", predicate: nil) as? [RSSFeedsProtocol]{
            return data
        }
        return []
    }

}
