//
//  Validation.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 21/03/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import Foundation

class Validator{
    
    let rotation_deg_tollerance = Float(10.0)
    let distance_m_tollerance = 0.05
    
    // how to get from one node to the other
    func nodeTonodePath(candidate: SCNNode, target: SCNNode, object: Object) -> validationState{
        
        var relative_position = calculate_relative_position(target: target, candidate: candidate)
        let degree_rot = eulerToDegrees(euler: relative_position.eulerAngles.x)
        let distance = SCNVector3.distanceFrom(vector: target.worldPosition, toVector: candidate.worldPosition)
        
        
        if distance < 0.05 {
            if degree_rot < 5 || degree_rot > 355 {
                // this is the complete state
                candidate.addChildNode(tickDone(object: object))
                return validationState.aligned
            }
            
        }
        
        if distance > 0.05 {
            AddFloatingInstruction(message: "Place Here", parent: target)
            
            let waypoint = addWaypoint(colour: object.colour!)
            candidate.addChildNode(waypoint)
            
            target.addChildNode(addDestination(colour: object.colour!))
            target.addChildNode(addLandingTarget(object: object, complete: false))
        }
        
        if degree_rot > 5 && degree_rot < 355 {
            candidate.addChildNode(Arrow(degrees: degree_rot))
        }
        
        return validationState.misaligned
    }
    
    func addDestination(colour: UIColor)->SCNNode{
        let way = WaypointModel()
        let dest = way.GetEndPoint(colour: colour)
        // dest position is an offset from the tray centrepoint
        dest.position = SCNVector3(0, 0, 0.1)
    
        return dest
    }
    
    func addWaypoint(colour: UIColor)->SCNNode{
        let way = WaypointModel()
        return way.GetWaypoint(colour: colour)
    }
    
    func addComplete()->SCNNode{
        let way = WaypointModel()
        return way.GetEndPoint(colour: UIColor.green)
    }
    
    func addLandingTarget(object: Object, complete: Bool)->SCNNode{
        // this is the zone of the tray
        var geometry = SCNBox(width: object.depth, height: object.width, length: 0.005, chamferRadius: 0)
        let node = SCNNode(geometry: geometry)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        
        if complete{
            material.diffuse.contents = UIColor.green
        }
        
        material.transparency = 0.8
        node.geometry?.materials = [material]
        return node
    }
    
    func tickDone(object: Object)-> SCNNode {
        
        return addLandingTarget(object: object, complete: true)
    }
    
    func Arrow(degrees: Float)-> SCNNode {
        var direction = String()
        let tempScene = SCNScene(named: "art.scnassets/Base.lproj/arrow_scaled.dae")!
        let modelNode = tempScene.rootNode
        
        var factor = Float()
        
        if degrees < 180 {
            factor = 180 - (180 - degrees)
            factor = factor / 180
            factor = factor/10
            modelNode.eulerAngles = SCNVector3Make(Float(Double.pi),0,0)
            modelNode.scale = SCNVector3Make(factor, factor, factor)
    
        }else{
            factor = 180 - (degrees - 180)
            factor = factor / 180
            factor = factor/10
            modelNode.eulerAngles = SCNVector3Make(0,0,0)
            modelNode.scale = SCNVector3Make(factor, factor, factor)
        }
        
        return modelNode
    }
    
    private func calculate_relative_position(target: SCNNode, candidate: SCNNode)->SCNNode{
        
        let relative_position = SCNNode()
        
        relative_position.transform = SCNMatrix4Mult(SCNMatrix4Invert(target.worldTransform),candidate.worldTransform)
        
        // flip axis as per openGL issue
        relative_position.rotation = SCNVector4(relative_position.rotation.y, relative_position.rotation.x, relative_position.rotation.z, relative_position.rotation.w)
        
        return relative_position
    }
    
    
    func AllObjectsValidated(currentTask: Task) -> Bool{
        
        for object_state in currentTask.validation?.objectStates as! [validationState] {
            if object_state != validationState.aligned{
                return false
            }
        }
        
        for object in currentTask.objects{
            object.instruction.validationstate = validationState.not_visible
        }
        
        return true
    }



func addArrowBetween(start: SCNVector3, end: SCNVector3) -> SCNNode {
    let lineGeometry = SCNGeometry.lineFrom(vector: start, toVector: end)
    let lineNode = SCNNode(geometry: lineGeometry)
    
    return lineNode
}
    
    func eulerToDegrees(euler: Float) -> Float{
        var euler_deg = euler * 180 / Float.pi
        if( euler_deg < 0 ){
            euler_deg = euler_deg + 360.0
        }
        return euler_deg
    }
    
    private func animatePath(from: SCNNode, to: SCNNode) {
        let line = CylinderLine(parent: from, v1: from.worldPosition, v2: to.worldPosition, radius: 0.01, radSegmentCount: 10, color: .red)
        from.addChildNode(line)
    }
    
    // return a suggested movement based on node relative to space
    func NodeToBoardPosition(Quaternion: SCNQuaternion) -> validationState{
        
        
        let rotation = GLKQuaternionMake(Quaternion.x, Quaternion.y, Quaternion.z, Quaternion.w)
        
        // print(Quaternion)
        
        if(Quaternion.w > 0.98 && Quaternion.y < 0.01){
            print("^Correct^") // aligned
            return validationState.aligned
        }
        if(Quaternion.w < 0.01 && Quaternion.y > 0.98){
            print("Flip 180") // 180 degrees misaligned
            return validationState.flip_180
        }
        if(Quaternion.w >= 0.01 && Quaternion.y <= 0.98 && Quaternion.y >= 0){
            print("Turn right")
            return validationState.turn_right
        }
        // else
        print("Turn left")
        return validationState.turn_left
    }
    
    // Quick function to find correct positioning
    func ObjectOrientatedToTray(Quaternion: SCNQuaternion) -> Bool{
        // working on w and y axis
        if(Quaternion.w > 0.98 && Quaternion.y < 0.01){
            return true
        }
        return false
    }
    
}
