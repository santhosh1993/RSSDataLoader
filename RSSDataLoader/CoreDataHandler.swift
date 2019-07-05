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
    func addUrl(url:String, title:String, completion:(Bool)->Void) {
        
        queue.sync { [weak self] in
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
}
