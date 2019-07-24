//
//  CoreDataHandler.swift
//  RSSDataLoader
//
//  Created by Santhosh Nampally on 04/07/19.
//  Copyright © 2019 Santhosh Nampally. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHandler {
    
    let queue = DispatchQueue.init(label: "CoreDataQueue")
    
    lazy var persistentContainer: NSPersistentContainer? = {
        let dataLoaderBundle = Bundle(for: type(of: self))
        
        if let modelURL = dataLoaderBundle.url(forResource: "RSSDataLoader", withExtension: "momd"),
            let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL) {
            
            let container = NSPersistentContainer.init(name: "RSSDataLoader", managedObjectModel: managedObjectModel)
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            
            return container
        }
        
        return nil
    }()
    
    func getContext() -> NSManagedObjectContext {
        return persistentContainer!.viewContext
    }
    
    func saveContext () {
        let context = getContext()
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension CoreDataHandler {
    func fetchTheData(entity:String, predicate: NSPredicate?) -> Array<Any>{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        if let predicate = predicate{
            fetchRequest.predicate = predicate
        }
        
        do{
            let feedUrlAry = try getContext().fetch(fetchRequest)
            return feedUrlAry
        }
        catch {
            return []
        }
    }
    
    func createManagedObject<T:NSManagedObject>(entity:T.Type) -> T {
        return T.init(context: getContext())
    }
}

extension CoreDataHandler {
    func addUrl(url:String, title:String, completion:@escaping (Bool)->Void) {
        
        queue.async { [weak self] in
            let feedUrls = self?.fetchTheData(entity: "RSSFeedUrl", predicate: NSPredicate(format: "url == %@", url))
            let feedUrl:RSSFeedUrl? = (feedUrls?.first as? RSSFeedUrl) ?? (self?.createManagedObject(entity: RSSFeedUrl.self))
            
            if let feedUrl = feedUrl {
                feedUrl.title = title
                feedUrl.url = url
                self?.saveContext()
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    func addFeedData(for url:String, data:[[String:String]], completion: @escaping (Bool)->Void) {
        queue.async { [weak self] in
            let feedUrls = self?.fetchTheData(entity: "RSSFeedUrl", predicate: NSPredicate(format: "url == %@", url))
            
            if let feedUrl:RSSFeedUrl = feedUrls?.first as? RSSFeedUrl {
                for each in data {
                    if let feed = self?.createOrUpdateFeedData(for: each){
                        feed.addToFeedUrl(feedUrl)
                        feedUrl.addToFeed(feed)
                        self?.saveContext()
                    }
                }
                completion(true)
            }
            else {
                completion(false)
            }
            
        }
    }
    
    func updateTheFeedStatus(for guid:String,withStatusOf done:Bool? ,and opened:Bool? ,completion: @escaping (Bool) -> Void) {
        queue.async { [weak self] in
            let feeds = self?.fetchTheData(entity: "RSSFeed", predicate: NSPredicate(format: "guid == %@",guid))
            if let feed = feeds?.first as? RSSFeed {
                feed.isDone = done ?? feed.isDone
                feed.isOpened = opened ?? feed.isOpened
                
                self?.saveContext()
                completion(true)
            }
            else{
                completion(false)
            }
        }
    }
    
    func deleteTheOldFeed(beforeDate: Date, completion: @escaping (()-> Void)){
        queue.async { [weak self] in
            if let feeds = self?.fetchTheData(entity: "RSSFeed", predicate: NSPredicate(format: "pubDate < %@",beforeDate as NSDate)) as? [RSSFeed] {
                for each in feeds {
                    self?.getContext().delete(each)
                    self?.saveContext()
                }
                completion()
            }
        }
    }
    
    private func createOrUpdateFeedData(for data:[String:String]) -> RSSFeed {
        let feeds = self.fetchTheData(entity: "RSSFeed", predicate: NSPredicate(format: "guid == %@",data["guid"] ?? data["redirectionUrl"] ?? ""))
        let feed = feeds.first as? RSSFeed ?? self.createManagedObject(entity: RSSFeed.self)
        
        feed.title = data["title"]
        feed.guid = data["guid"]
        feed.feedDescription = data["feedDescription"]
        feed.guid = data["guid"]
        
        do {
            feed.pubDate = try RSSDateFormatter.shared.stringToDate(for: .descriptiveDate, dateStr: data["pubDate"] ?? "")
        }
        catch FormattingError.errorOccuredWhileStringToDateTransformation(let dateStr){
            assertionFailure("Error Occurred while transformation \(dateStr)")
        }
        catch {
            assertionFailure("Unknown error occurred")
        }
        
        feed.redirectionUrl = data["redirectionUrl"]
        
        return feed
    }
}

//MARK:- Managed Objects Extensions

extension RSSFeed:RSSFeedProtocol {
    
}

extension RSSFeedUrl:RSSFeedsProtocol {
    
}
