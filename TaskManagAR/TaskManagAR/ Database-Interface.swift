//
//  Database-Interface.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 28/02/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//
// These methods a
import Foundation
import CoreData

let delegate = UIApplication.shared.delegate as! AppDelegate
let container = delegate.persistentContainer
let context = delegate.persistentContainer.viewContext

// Testing method to ensure that database contains necessary information
func runDatabase(){
    
    // Create the entity
    let entity = NSEntityDescription.entity(forEntityName: "AR_Users", in: context)
    let newUser = NSManagedObject(entity: entity!, insertInto: context)
        
        newUser.setValue("Testing-db", forKey: "username")
        newUser.setValue("1234", forKey: "password")

    do {
        
        try context.save()
        
    } catch {
        
        print("Failed saving")
    }
    

}

// Testing method to ensure that values are loading from database appropriately
func loadDatabase(){
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AR_Users")
    request.returnsObjectsAsFaults = false
    
    do {
        let result = try context.fetch(request)
        for data in result as! [NSManagedObject] {
            print(data.value(forKey: "username") as! String)
        }
        
    } catch {
        
        print("Failed")
    }
    deleteRecords()

}

func saveDatabase(){
   
}

func deleteRecords(){
    // Create Fetch Request
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AR_Users")
    
     // Create Batch Delete Request
     let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
     let moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
     
     do {
     let result = try context.execute(batchDeleteRequest)
     } catch {
     print("Cannot delete")
     //fatalError("Failed to execute request: \(error)")
     }
}

