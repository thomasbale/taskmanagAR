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
    let entity = NSEntityDescription.entity(forEntityName: "AR_User", in: context)
    let newUser = NSManagedObject(entity: entity!, insertInto: context)
        
        newUser.setValue("Testing-db", forKey: "username")
        newUser.setValue("1234", forKey: "password")

    do {
        
        try context.save()
        
    } catch {
        
        print("Failed saving")
    }
    

}

func testDatabase(){
    
    let space = NSEntityDescription.entity(forEntityName: "AR_Space", in: context)
    let sequence = NSEntityDescription.entity(forEntityName: "AR_Sequence", in: context)
    let object = NSEntityDescription.entity(forEntityName: "AR_Object", in: context)
    let location = NSEntityDescription.entity(forEntityName: "AR_Location", in: context)
    let marker = NSEntityDescription.entity(forEntityName: "AR_Marker", in: context)
    let event = NSEntityDescription.entity(forEntityName: "AR_Event", in: context)
    
    // create attributes
    
    let newSpace = NSManagedObject(entity: space!, insertInto: context)
    let newSequence = NSManagedObject(entity: sequence!, insertInto: context)
    let newObject = NSManagedObject(entity: object!, insertInto: context)
    let newLocation = NSManagedObject(entity: location!, insertInto: context)
    let newMarker = NSManagedObject(entity: marker!, insertInto: context)
    let newEvent = NSManagedObject(entity: event!, insertInto: context)
    
    // add values
    
    newSpace.setValue(123, forKey: "space_id")
    newSequence.setValue(234, forKey: "sequence_id")
    newObject.setValue(345, forKey: "object_id")
    newLocation.setValue(456, forKey: "location_id")
    newMarker.setValue(567, forKey: "marker_id")
    newEvent.setValue(890, forKey: "event_id")
    
    do {
        
        try context.save()
        
    } catch {
        
        print("Failed saving")
    }
    
    loadDatabase(entityName: "AR_Event", nameKey: "event_id")
    
}

// Testing method to ensure that values are loading from database appropriately
func loadDatabase(entityName: String, nameKey: String){
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    request.returnsObjectsAsFaults = false
    
    do {
        let result = try context.fetch(request)
        for data in result as! [NSManagedObject] {
            print(data.value(forKey: nameKey))
        }
        
    } catch {
        
        print("Failed")
    }

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

