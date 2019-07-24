//
//  RSSAutoDiscovery.swift
//  RSSDataLoader
//
//  Created by Santhosh Nampally on 16/07/19.
//  Copyright © 2019 Santhosh Nampally. All rights reserved.
//

import Foundation

public class RSSAutoDiscovery {
    public init() {

    }
    
    public func getTheRSSFeed(for url:URL){
        let str = try! String.init(contentsOf: url)
       let ary = str.components(separatedBy: "type=\"application/rss+xml\"")
        print(ary.count)
    }
}
