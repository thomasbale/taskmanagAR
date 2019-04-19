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

// Main datamodel: parent references the event that the task belongs

enum validationState{
    case aligned, turn_right, turn_left, flip_180, misaligned, not_visible
}

struct Validation{
    // a validation ensures that the correct objects and spaces are present
    var isValidated = false
    // array with corrections needed by object from Task array
    var objectStates: [validationState]?
}

struct Marker{
    var id = Int()
}

struct Space{
    var spaceId: Int?
    // physical dimensions
    var width = Double()
    var height = Double()
    var depth = Double()
    // marker properties
    var marker_height_m = CGFloat()
    var anchor_marker_id = Int()
    var boom_marker_id = Int()
    var left_top_marker_id = Int()
    var right_top_marker_id = Int()
    var datum_marker_id = Int()
}

struct Object{
    var object_marker = Marker()
    var name = String()
    var file_name = String()
    var description = String()
    var parent_scene = String()
    var apply_rotation = SCNVector3()
    var scale = SCNVector3()
    var height = Float()
}

struct Task{
    var name = String()
    var description = String()
    var objects = [Object]()
    var space = Space()
    var complete = Bool()
    // validation applies to object & space within task
    var validation: Validation?
}

struct Event{
    var name = String()
    var description = String()
    var tasks = [Task]()
    var location = Int()
}


func getEventsForLocation(locationID: Int) -> [Event]{
    
    // possibly need to create all tasks as subset of events?
    
    
    var eventArray = [Event()]
    /// Create the event
    var testTCFevent = Event(name: "Load LBSRP plate", description: "Tile Carrier Facility", tasks: [Task()], location: 000)
    /// Here the tasks and events are defined
    let taskModuleTray = Space(spaceId: 1, width: 0.84, height: 0.01, depth: 0.297, marker_height_m: 0.0282, anchor_marker_id: 4, boom_marker_id: 0, left_top_marker_id: 1, right_top_marker_id: 2, datum_marker_id: 3)
    
    // create the tasks
    var findTray = Task(name: "Find Tray", description: "Locate correct task module tray", objects: [Object()], space: taskModuleTray, complete: false, validation: nil)
    
    var findPlate = Task(name: "Find Plate", description: "Locate LBSRP Plate", objects: [Object(object_marker: Marker(id: 6), name: "LBSRP_Adapter", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.0)], space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil))
    
    var placePlate = Task(name: "Place Plate", description: "Locate correct task module tray", objects: [Object(object_marker: Marker(id: 6), name: "LBSRP_Adapter", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.0)], space: taskModuleTray, complete: false, validation: nil)
    
    var fineSubFrame = Task(name: "Find Sub-Frame", description: "Locate correct task module tray", objects: [Object(object_marker: Marker(id: 6), name: "Rx1800 Carrier Sub Frame", file_name: "Carrier_Subframe", description: "Rx1800 Carrier Sub Frame", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.0)], space: taskModuleTray, complete: false, validation: nil)
    
    var addSubFrame = Task(name: "Place Sub-Frame", description: "Locate correct task module tray", objects: [Object(object_marker: Marker(id: 6), name: "Rx1800 Carrier Sub Frame", file_name: "Carrier_Subframe", description: "Rx1800 Carrier Sub Frame", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.0)], space: taskModuleTray, complete: false, validation: nil)
    
    var placeSextant = Task(name: "Place Sextant", description: "Place Sextant on marker", objects: [Object(object_marker: Marker(id: 265), name: "Historic Sextant", file_name: "sextant", description: "Sextant", parent_scene: "art.scnassets/sextant.scn", apply_rotation: SCNVector3Make(Float(Double.pi/2), Float(Double.pi/2), Float(Double.pi/2)), scale: SCNVector3(0.001, 0.001, 0.001), height: 0.2)], space: taskModuleTray, complete: true, validation: nil)
    
    var placeKitchen = Task(name: "Place Kitchen", description: "Place Kitchen on marker", objects: [Object(object_marker: Marker(id: 265), name: "Kitchen", file_name: "model", description: "Kitchen", parent_scene: "art.scnassets/kitchen.scn", apply_rotation: SCNVector3Make(0,Float(Double.pi),0), scale: SCNVector3(0.1, 0.1, 0.1), height: 0.15)], space: taskModuleTray, complete: true, validation: nil)

    var placeKitchenRoomScale = Task(name: "Place Kitchen Room Scale", description: "Place Kitchen on marker Room Scale", objects: [Object(object_marker: Marker(id: 265), name: "Kitchen", file_name: "model", description: "Kitchen", parent_scene: "art.scnassets/kitchen.scn", apply_rotation: SCNVector3Make(0,Float(Double.pi),0), scale: SCNVector3(2, 2, 2), height: 0.15)], space: taskModuleTray, complete: true, validation: nil)

    
    // clean then add tasks to events
    testTCFevent.tasks.removeAll()
    
    // add each of the tasks to the event
    testTCFevent.tasks.append(findTray)
    testTCFevent.tasks.append(findPlate)
    testTCFevent.tasks.append(placePlate)
    testTCFevent.tasks.append(addSubFrame)
    testTCFevent.tasks.append(placeSextant)
    testTCFevent.tasks.append(placeKitchen)
    testTCFevent.tasks.append(placeKitchenRoomScale)

    eventArray.removeAll()
    eventArray.append(testTCFevent)
    return eventArray
}

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

