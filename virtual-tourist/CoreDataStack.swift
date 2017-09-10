//
//  CoreDataStack.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 08/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

// ******
// Code based on Udacity Sample

import UIKit
import CoreData

struct CoreDataStack {
    
    fileprivate let model: NSManagedObjectModel
    fileprivate let coordinator: NSPersistentStoreCoordinator
    fileprivate let modelUrl: URL
    fileprivate let databaseUrl: URL
    
    fileprivate let persistingContext: NSManagedObjectContext
    fileprivate let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext

    init?(){
        
        guard let modelUrl = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            print("Unable to find 'Model.momd' in the main bundle")
            return nil
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            print("unable to create a model from \(modelUrl)")
            return nil
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Creates 3 contexts
        // - Background for writing (Persisting)
        //   - Main for reading
        //     - Background for reading
        
        let persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        
        guard let databaseUrl = CoreDataStack.urlForDocumentsFolderWithFile("model.sqlite") else {
            print("Failed to create database url in documents folder.")
            return nil
        }
        
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                              configurationName: nil,
                                              at: databaseUrl,
                                              options: CoreDataStack.getMigrationOptions())
        } catch {
            print("Failed to add persistentStore at \(databaseUrl)")
            return nil
        }
        
        
        // Success!
        self.model = model
        self.coordinator = coordinator
        self.modelUrl = modelUrl
        self.databaseUrl = databaseUrl
        
        self.backgroundContext = backgroundContext
        self.persistingContext = persistingContext
        self.context = context
    }
    
    
    
    
    static func urlForDocumentsFolderWithFile(_ fileName : String) -> URL?{
        
        guard let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the documents folder")
            return nil
        }
        
        return docUrl.appendingPathComponent(fileName)
    }
    
    
    static func getMigrationOptions() -> [String : Any]{
        return [NSInferMappingModelAutomaticallyOption: true,
                NSMigratePersistentStoresAutomaticallyOption: true]
    }
    
    
    func dropAllData() throws {
        let options = CoreDataStack.getMigrationOptions()
        try coordinator.destroyPersistentStore(at: databaseUrl, ofType: NSSQLiteStoreType, options: options)
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                           configurationName: nil,
                                           at: databaseUrl, options: options)
    }

    func save() {
        
        context.performAndWait() {
            
            if self.context.hasChanges {
                // Save on the context #2
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // Save on the context #1
                self.persistingContext.perform() {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func performBackgroundBatchOperation(_ batch: @escaping (_ workerContext: NSManagedObjectContext) -> ()) {
        
        backgroundContext.perform() {
            
            batch(self.backgroundContext)
            
            do {
                try self.backgroundContext.save()
            } catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
    
    func autoSave(_ delayInSeconds: Int) {
        
        if delayInSeconds > 0 {
            print("Autosaving...")
            save()
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }

}
