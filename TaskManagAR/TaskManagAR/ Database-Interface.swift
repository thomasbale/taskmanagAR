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
    
    var width = CGFloat()
    var depth = CGFloat()
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
    let taskModuleTray = Space(spaceId: 1, width: 0.84, height: 0.01, depth: 0.40, marker_height_m: 0.03289, anchor_marker_id: 99, boom_id: 99, boom_face_id: 99, datum_id: 99, datum_face_id: 1)
    // create the tasks
    let findTray = Task(name: "Find Tray", description: "Locate correct task module tray", objects: [Object()], space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.001.png")
    
    // CREATE THE OBJECTS
    
    
    var object1 = Object(object_marker: Marker(id: 34), name: "UTM/AE/035/41", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, 0), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.025, width: 0.12, depth: 0.1, x_offset: 0.0, y_offset: 0.0, colour: UIColor.magenta, x_marker_offset: -0.051, y_marker_offset: 0.025)

    
    var object2 = Object(object_marker: Marker(id: 35), name: "UTM/AC/035/44", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, 0), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.025, width: 0.12, depth: 0.1, x_offset: 0.0, y_offset: 0.0, colour: UIColor.systemPink, x_marker_offset: -0.051, y_marker_offset: 0.025)
    
    var object3 = Object(object_marker: Marker(id: 36), name: "UTM/XM/034/11", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, 0), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.025, width: 0.12, depth: 0.1, x_offset: 0.0, y_offset: 0.0, colour: UIColor.systemBlue, x_marker_offset: -0.051, y_marker_offset: 0.025)
    
    var object4 = Object(object_marker: Marker(id: 37), name: "UTM/UK/035/92", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, 0), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.025, width: 0.12, depth: 0.1, x_offset: 0.0, y_offset: 0.0, colour: UIColor.systemOrange, x_marker_offset: -0.051, y_marker_offset: 0.025)
    
    var object5 = Object(object_marker: Marker(id: 38), name: "UTM/XE/035/63", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, 0), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.025, width: 0.12, depth: 0.1, x_offset: 0.0, y_offset: 0.0, colour: UIColor.systemPurple, x_marker_offset: -0.051, y_marker_offset: 0.025)
    
    var object6 = Object(object_marker: Marker(id: 34), name: "UTM/AE/035/41", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.025, width: 0.12, depth: 0.1, x_offset: 0.0, y_offset: 0.0, colour: UIColor.magenta, x_marker_offset: -0.051, y_marker_offset: 0.025)

    
    var object7 = Object(object_marker: Marker(id: 35), name: "UTM/AC/035/44", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.025, width: 0.12, depth: 0.1, x_offset: 0.0, y_offset: 0.0, colour: UIColor.systemPink, x_marker_offset: -0.051, y_marker_offset: 0.025)
    
    var object8 = Object(object_marker: Marker(id: 36), name: "UTM/XM/034/11", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.025, width: 0.12, depth: 0.1, x_offset: 0.0, y_offset: 0.0, colour: UIColor.systemBlue, x_marker_offset: -0.051, y_marker_offset: 0.025)
    
    var object9 = Object(object_marker: Marker(id: 37), name: "UTM/UK/035/92", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.025, width: 0.12, depth: 0.1, x_offset: 0.0, y_offset: 0.0, colour: UIColor.systemOrange, x_marker_offset: -0.051, y_marker_offset: 0.025)
    
    var object10 = Object(object_marker: Marker(id: 38), name: "UMT/XE/035/63", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.03, width: 0.12, depth: 0.1, x_offset: 0.0, y_offset: 0.0, colour: UIColor.systemPurple, x_marker_offset: -0.031, y_marker_offset: 0.025)
    /// y marker offset is height
    
    var l_tile_1 = Object(object_marker: Marker(id: 39), name: "UMT/XR/035/42", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.04, width: 0.26, depth: 0.165, x_offset: 0, y_offset: 0.0, colour: UIColor.systemPurple, x_marker_offset: -0.02, y_marker_offset: 0.025)
    
    var m_tile_1 = Object(object_marker: Marker(id: 33), name: "UMT/XM/035/83", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.04, width: 0.245, depth: 0.15, x_offset: 0, y_offset: 0.0, colour: UIColor.systemPurple, x_marker_offset: -0.02, y_marker_offset: 0.025)
    
    var l_tile_2 = Object(object_marker: Marker(id: 10), name: "UMT/XM/035/01", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.04, width: 0.26, depth: 0.165, x_offset: 0, y_offset: 0.0, colour: UIColor.systemPurple, x_marker_offset: -0.02, y_marker_offset: 0.025)
    
    var l_tile_3 = Object(object_marker: Marker(id: 31), name: "UMT/XM/066/01R", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.04, width: 0.26, depth: 0.165, x_offset: 0, y_offset: 0.0, colour: UIColor.systemPurple, x_marker_offset: -0.02, y_marker_offset: 0.025)
    
    var l_tile_4 = Object(object_marker: Marker(id: 32), name: "UMT/XM/025/01", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, Float(Double.pi/2)), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.04, width: 0.26, depth: 0.165, x_offset: 0, y_offset: 0.0, colour: UIColor.systemPurple, x_marker_offset: -0.02, y_marker_offset: 0.025)
    
    var l_tile_4_R = Object(object_marker: Marker(id: 32), name: "UMT/XM/025/01", file_name: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", description: "LBSRP Adaptor Plate", parent_scene: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn", apply_rotation: SCNVector3Make(0, 0, 0), scale: SCNVector3(1.0, 1.0, 1.0), height: 0.04, width: 0.26, depth: 0.165, x_offset: 0, y_offset: 0.0, colour: UIColor.systemPurple, x_marker_offset: -0.02, y_marker_offset: 0.025)
    
    
    // Object to tray configs
    var tray1_Objects = [Object]()
    var tray2_Objects = [Object]()
    var tray3_Objects = [Object]()
    var tray4_Objects = [Object]()
    var tray5_Objects = [Object]()
    var tray6_Objects = [Object]()
    var tray7_Objects = [Object]()
    var tray8_Objects = [Object]()
    var tray9_Objects = [Object]()
    var tray10_Objects = [Object]()
    var tray11_Objects = [Object]()
    var tray12_Objects = [Object]()
    
    
    tray1_Objects += [object10,l_tile_1]
    calculateTrayOffset(objects: &tray1_Objects, space: taskModuleTray)
    tray2_Objects += [object2, l_tile_1,l_tile_2,l_tile_3]
    calculateTrayOffset(objects: &tray2_Objects, space: taskModuleTray)
    tray3_Objects += [object3,m_tile_1]
    calculateTrayOffset(objects: &tray3_Objects, space: taskModuleTray)
    tray4_Objects += [l_tile_3,l_tile_2,l_tile_1,l_tile_4]
    calculateTrayOffset(objects: &tray4_Objects, space: taskModuleTray)
    tray5_Objects += [l_tile_4_R]
    calculateTrayOffset(objects: &tray5_Objects, space: taskModuleTray)
    tray6_Objects += [object6]
    calculateTrayOffset(objects: &tray6_Objects, space: taskModuleTray)
    tray7_Objects += [object7]
    calculateTrayOffset(objects: &tray1_Objects, space: taskModuleTray)
    tray8_Objects += [object8]
    calculateTrayOffset(objects: &tray2_Objects, space: taskModuleTray)
    tray9_Objects += [object9]
    calculateTrayOffset(objects: &tray3_Objects, space: taskModuleTray)
    tray10_Objects += [object10]
    calculateTrayOffset(objects: &tray4_Objects, space: taskModuleTray)
    tray11_Objects += [object1]
    calculateTrayOffset(objects: &tray5_Objects, space: taskModuleTray)
    tray12_Objects += [object2]
    calculateTrayOffset(objects: &tray6_Objects, space: taskModuleTray)
    
    // BUILD THE TRAYS WITH INSTRUCTIONS
    var tray1 = Task(name: "Tray 1", description: "Locate LBSRP Plate", objects: tray1_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/ins.png")
    
    var tray2 = Task(name: "Tray 2", description: "Locate LBSRP Plate", objects: tray2_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray3 = Task(name: "Tray 3", description: "Locate LBSRP Plate", objects: tray3_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray4 = Task(name: "Tray 4", description: "Locate LBSRP Plate", objects: tray4_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray5 = Task(name: "Tray 5", description: "Locate LBSRP Plate", objects: tray5_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray6 = Task(name: "Tray 6", description: "Locate LBSRP Plate", objects: tray6_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray7 = Task(name: "Tray 7", description: "Locate LBSRP Plate", objects: tray7_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray8 = Task(name: "Tray 8", description: "Locate LBSRP Plate", objects: tray8_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray9 = Task(name: "Tray 9", description: "Locate LBSRP Plate", objects: tray9_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray10 = Task(name: "Tray 10", description: "Locate LBSRP Plate", objects: tray10_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray11 = Task(name: "Tray 11", description: "Locate LBSRP Plate", objects: tray11_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    var tray12 = Task(name: "Tray 12", description: "Locate LBSRP Plate", objects: tray12_Objects, space: taskModuleTray, complete: false, validation: Validation(isValidated: false, objectStates: nil), instruction: "art.scnassets/Base.lproj/demo/demo.002.png")
    
    
    
    
    // clean then add tasks to events
    testTCFevent.tasks.removeAll()
    // add each of the tasks to the event
    testTCFevent.tasks.append(findTray)
    testTCFevent.tasks.append(tray1)
    testTCFevent.tasks.append(tray2)
    testTCFevent.tasks.append(tray3)
    testTCFevent.tasks.append(tray4)
    testTCFevent.tasks.append(tray5)
    testTCFevent.tasks.append(tray6)
    testTCFevent.tasks.append(tray7)
    testTCFevent.tasks.append(tray8)
    testTCFevent.tasks.append(tray9)
    testTCFevent.tasks.append(tray10)
    testTCFevent.tasks.append(tray11)
    testTCFevent.tasks.append(tray12)
    
    


    eventArray.removeAll()
    eventArray.append(testTCFevent)
    
    return eventArray
}

func calculateTrayOffset(objects: inout [Object], space: Space){
    
    if objects.count == 0 || objects.count > 8 {
        return
    }
    
    var count = objects.count
    
    if count > 4{
        count = 4
    }
    
    let spacing = space.width / (Double(count) + 1)
    let verticalSpacing = space.depth / 3
    let centrepoint = Float(space.width / 2)
    var positionOffset = Float(spacing)
    
    
    // rack height / 3 = spacing
    // + half, - spacing (10 - 15 = -5) assume 30. 10, 20.
    // (15 - 10 = + 5)
    // R1 = verticalSpacing - half way
    // R2 = half way - vertical spacing
    
    let rack1 = Float(verticalSpacing - (space.depth / 2))
    let rack2 = Float((space.depth / 2) - verticalSpacing)
    
    if objects.count < 5 {
        
        for index in objects.indices {
            objects[index].x_offset = positionOffset - centrepoint
            objects[index].y_offset = 0
            positionOffset = positionOffset + Float(spacing)
            
            objects[index].offsetNode.position = SCNVector3(objects[index].y_offset!, objects[index].x_offset!, 0)
            // (0, left and right, up and down)
            
            // marker offset
            objects[index].marker_offsetNode.position = SCNVector3(0,objects[index].x_marker_offset,objects[index].y_marker_offset)
            
        }
        return
    }else{
        
        for index in objects.indices {
            
            
            // if there are more than 4 objects use two tacks
            
            if index > 3 {
                objects[index].y_offset = Float(rack1)
                
            }
            else{
                objects[index].y_offset = Float(rack2)
            }
            
            objects[index].x_offset = positionOffset - centrepoint
            positionOffset = positionOffset + Float(spacing)
            
            objects[index].offsetNode.position = SCNVector3(objects[index].y_offset!, objects[index].x_offset!, 0)
            
            
            // marker offset
            objects[index].marker_offsetNode.position = SCNVector3(0,objects[index].x_marker_offset,objects[index].y_marker_offset)
            
            if index == 3 {
                positionOffset = Float(spacing)
            }
            
        }
        
        // 5 or more objects
        
        
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

