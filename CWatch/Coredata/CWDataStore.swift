//
//  CWCoredata.swift
//  CWatch
//
//  Created by J Manuel Zaragoza on 12/7/22.
//

import Foundation
import CoreData

final class CWDataStore {
    // MARK: -  Properties
    private var modelName: String
    
    public var managedContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    private lazy var persistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            
            print(storeDescription)
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        return container
    }()
    
    
    // MARK: - Life cycle
    public  init(modelName: String) {
        self.modelName = modelName
    }
    
  
    // MARK: - Methods
    public func save() throws -> Bool {
        guard managedContext.hasChanges else { return false }
        
        do {
            let startSaveTime = CFAbsoluteTimeGetCurrent()
            try managedContext.save()
            let endSaveTime = CFAbsoluteTimeGetCurrent()
            print("Saving the context took: \((endSaveTime - startSaveTime) * 1000) ms")
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    
    }
}
