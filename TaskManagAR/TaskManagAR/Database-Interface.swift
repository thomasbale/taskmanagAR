//
//  Database-Interface.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 28/02/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import Foundation
import CoreData

let delegate = UIApplication.shared.delegate as! AppDelegate
let container = delegate.persistentContainer
let context = delegate.persistentContainer.viewContext



func runDatabase(){
    
  let entity = NSEntityDescription.entity(forEntityName: "user", in: context)
  //  let newUser = NSManagedObject(entity: entity!, insertInto: context)
    
   // newUser.setValue("Shashikant", forKey: "username")
   // newUser.setValue("1234", forKey: "password")
   // newUser.setValue("1", forKey: "age")
    
    do {
        try context.save()
    } catch {
        print("Failed saving")
    }
}


