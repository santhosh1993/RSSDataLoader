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
    var isDone:Bool {get}
    var isOpened:Bool {get}
}

public protocol RSSFeedsProtocol {
    var title:String? {get}
    var url:String? {get}
    var feed:NSSet? {get}
}

public protocol RSSDataLoaderProtocol {
    func completion(status:Bool)
    func dataGotUpdated()
}

public class RSSDataLoader: NSObject {
    static let shared = RSSDataLoader()
    let dataHandler = CoreDataHandler()
    let parser = RSSDataParser()
    var callBack:RSSDataLoaderProtocol?
    
    private override init() {
        super.init()
    }
    
    public static func setTheCallBack(with inst:RSSDataLoaderProtocol) {
        self.shared.callBack = inst
    }
    
    public static func addNewRSSFeed(url:String, title:String, callBack:RSSDataLoaderProtocol){
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
    
    public static func updateTheState(for feed:RSSFeedProtocol,isDone :Bool? ,isOpened:Bool? ) {
        self.shared.dataHandler.updateTheFeedStatus(for: feed.guid ?? "", withStatusOf: isDone, and: isOpened) { (status) in
            self.shared.callBack?.dataGotUpdated()
        }
    }
    
    public static func getRSSFeeds() -> [RSSFeedsProtocol] {
        if let data = self.shared.dataHandler.fetchTheData(entity: "RSSFeedUrl", predicate: nil) as? [RSSFeedsProtocol]{
            return data
        }
        return []
    }
    
    public static func deleteFeedDate(before: Date) {
        shared.dataHandler.deleteTheOldFeed(beforeDate: before) {
            self.shared.callBack?.dataGotUpdated()
        }
    }

}
