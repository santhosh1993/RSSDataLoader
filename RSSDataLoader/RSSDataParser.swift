//
//  RSSDataParser.swift
//  RSSDataLoader
//
//  Created by Santhosh Nampally on 09/07/19.
//  Copyright © 2019 Santhosh Nampally. All rights reserved.
//

import UIKit

private enum ElementKeys:String {
    case title = "title"
    case link = "link"
    case description = "description"
    case pubDate = "pubDate"
    case content = "content"
    case author = "author"
    case creator = "dc:creator"
    case encoded = "content:encoded"
    case guid = "guid"
    
    func getKey() -> String {
        switch self {
        case .description:
            return "feedDescription"
        case .link:
            return "redirectionUrl"
        default:
            return self.rawValue
        }
    }
}

class RSSDataParser: NSObject,XMLParserDelegate {
    var parser = XMLParser()
    var currentElement =  ""
    var foundCharacters = ""
    var currentData:[String:String] = [:]
    var parsedData:[[String:String]] = []
    var isHeader = true
    
    func startParsingWithContentsOfUrl(rssUrl: URL, with completion: (Bool)->Void) {
        let parser = XMLParser(contentsOf: rssUrl)
        parser?.delegate = self
        if let flag = parser?.parse() {
            parsedData.append(currentData)
            completion(flag)
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = ElementKeys(rawValue: elementName)?.getKey() ?? elementName
        
        if currentElement  == "item"  || currentElement == "entity" {
            if !isHeader {
                parsedData.append(currentData)
            }
            
            isHeader = false
        }
        
        if !isHeader {
            if currentElement == "media:thumbnail" || currentElement == "media:content" {
                foundCharacters += attributeDict["url"]!
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !isHeader {
            if ["title","link","description","pubDate","content","author","dc:creator","content:encoded","guid"].contains(currentElement) {
                foundCharacters += string
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if !foundCharacters.isEmpty {
            foundCharacters = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
            currentData[currentElement] = foundCharacters
            foundCharacters = ""
        }
    }
}
