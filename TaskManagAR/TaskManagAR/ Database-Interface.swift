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
    var boom_id = Int()
    var boom_face_id = Int()
    var datum_id = Int()
    var datum_face_id = Int()
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
    let istool = Bool()
    // Object offset from the centre of the tray: defaults to centre
    var x_offset: Float?
    var y_offset: Float?
    var colour: UIColor?
    // instruction
    var instruction = InstructionNode()
    // this is the offset to the tray
    var offsetNode = SCNNode()
    // this is the offset to the marker
    // (0, left and right, up and down)
    var marker_offsetNode = SCNNode()
    var x_marker_offset = 0.0
    var y_marker_offset = 0.0
    var done_on_tray = false
}

struct Task{
    var name = String()
    var description = String()
    var objects = [Object]()
    var space = Space()
    var complete = Bool()
    // validation applies to object & space within task
    var validation: Validation?
    var instruction: String?
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
    let taskModuleTray = Space(spaceId: 1, width: 0.84, height: 0.01, depth: 0.297, marker_height_m: 0.0282, anchor_marker_id: 99, boom_id: 99, boom_face_id: 99, datum_id: 99, datum_face_id: 0)
    // create the tasks
    let findTray = Task(name: "Find Tray", description: "Locate correct task module tray", objects: [Object()], space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.001.png")
    
    // CREATE THE OBJECTS
    
    
    var object1 = Object(object_marker: Marker(id: 7), name: "Object 6", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.0, x_offset: 0.0, y_offset: 0.0, colour: UIColor.magenta, x_marker_offset: -0.051, y_marker_offset: 0.025)
    
    var object2 = Object(object_marker: Marker(id: 8), name: "Object 3", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.0, x_offset: 0.0, y_offset: 0.0, colour: UIColor.green, x_marker_offset: -0.035, y_marker_offset: 0.039)
    
    var object3 = Object(object_marker: Marker(id: 6), name: "Object 3", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.0, x_offset: 0.0, y_offset: 0.0, colour: UIColor.green)
    
    var object4 = Object(object_marker: Marker(id: 8), name: "Object 3", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.0, x_offset: 0.0, y_offset: 0.0, colour: UIColor.green)
    
    
    // Object to tray configs
    var tray1_Objects = [Object]()
    var tray2_Objects = [Object]()
    var tray3_Objects = [Object]()
    var tray4_Objects = [Object]()
    var tray5_Objects = [Object]()
    var tray6_Objects = [Object]()
    
    
    tray1_Objects += [object1,object2]
    calculateTrayOffset(objects: &tray1_Objects, space: taskModuleTray)
    tray2_Objects += [object1,object2,object3]
    calculateTrayOffset(objects: &tray2_Objects, space: taskModuleTray)
    tray3_Objects += [object1,object2]
    calculateTrayOffset(objects: &tray3_Objects, space: taskModuleTray)
    tray4_Objects += [object1,object2]
    calculateTrayOffset(objects: &tray4_Objects, space: taskModuleTray)
    tray5_Objects += [object1,object2]
    calculateTrayOffset(objects: &tray5_Objects, space: taskModuleTray)
    tray6_Objects += [object1,object2]
    calculateTrayOffset(objects: &tray6_Objects, space: taskModuleTray)
    
    // BUILD THE TRAYS WITH INSTRUCTIONS
    var tray1 = Task(name: "Tray 1", description: "Locate LBSRP Plate", objects: tray1_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray2 = Task(name: "Tray 2", description: "Locate LBSRP Plate", objects: tray2_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray3 = Task(name: "Tray 3", description: "Locate LBSRP Plate", objects: tray3_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray4 = Task(name: "Tray 4", description: "Locate LBSRP Plate", objects: tray4_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray5 = Task(name: "Tray 5", description: "Locate LBSRP Plate", objects: tray5_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray6 = Task(name: "Tray 6", description: "Locate LBSRP Plate", objects: tray6_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    
    
    
    // clean then add tasks to events
    testTCFevent.tasks.removeAll()
    // add each of the tasks to the event
    testTCFevent.tasks.append(findTray)
    testTCFevent.tasks.append(tray1)
    testTCFevent.tasks.append(tray2)
    testTCFevent.tasks.append(tray3)


    eventArray.removeAll()
    eventArray.append(testTCFevent)
    
    return eventArray
}

func calculateTrayOffset(objects: inout [Object], space: Space){
    
    if objects.count == 0 {
        return
    }
    
    let spacing = space.width / (Double(objects.count) + 1)
    let centrepoint = Float(space.width / 2)
    var positionOffset = Float(spacing)
    
    for index in objects.indices {
        objects[index].x_offset = positionOffset - centrepoint
        positionOffset = positionOffset + Float(spacing)
        objects[index].offsetNode.position = SCNVector3(0, objects[index].x_offset!, 0)
        // (0, left and right, up and down)
        
        // marker offset
        objects[index].marker_offsetNode.position = SCNVector3(0,objects[index].x_marker_offset,objects[index].y_marker_offset)
        
    }
    
    
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

