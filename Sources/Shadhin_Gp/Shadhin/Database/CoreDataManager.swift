//
//  CoreDataManager.swift
//  Shadhin_Gp
//
//  Created by Maruf on 11/6/24.
//

import Foundation
import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()
    
    // Model name
    private let modelName: String = "MusicDataModel"
    
    // Persistent Container Lazy Initialization
    lazy var persistentContainer: NSPersistentContainer = {
        // Access the bundle for the Swift package target
        let frameworkBundle = Bundle.module
        
        // Find the model URL in the bundle
        guard let modelURL = frameworkBundle.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("❌ Unable to find data model \(self.modelName) in bundle.")
        }
        
        // Create the managed object model
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("❌ Unable to create NSManagedObjectModel from \(modelURL).")
        }
        
        // Initialize the persistent container with the model
        let container = NSPersistentContainer(name: self.modelName, managedObjectModel: managedObjectModel)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("❌ Loading of store failed: \(error)")
            } else {
                Log.info("✅ persistentContainer loaded successfully")
            }
        }
        
        return container
    }()
    
    // Function to reset the persistent store
    func reset() throws {
        let storeContainer = persistentContainer.persistentStoreCoordinator
        
        // Delete each existing persistent store
        for store in storeContainer.persistentStores {
            try storeContainer.destroyPersistentStore(at: store.url!, ofType: store.type, options: nil)
        }
        
        // Reload persistent stores after reset
        try persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: storeContainer.persistentStores.first!.type, configurationName: nil, at: storeContainer.persistentStores.first!.url, options: nil)
        
        Log.info("✅ persistentContainer reset successfully")
    }
}

