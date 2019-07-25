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
    
    // how to get from one node to the other
    func nodeTonodePath(candidate: SCNNode, target: SCNNode) -> validationState{
        
        var relative_position = SCNNode()
        
        relative_position.transform = SCNMatrix4Mult(SCNMatrix4Invert(target.worldTransform),candidate.worldTransform)
        // calculate the distance
        let distance = SCNVector3.distanceFrom(vector: target.worldPosition, toVector: candidate.worldPosition)
        // flip axis as per openGL issue
        relative_position.rotation = SCNVector4(relative_position.rotation.y, relative_position.rotation.x, relative_position.rotation.z, relative_position.rotation.w)
        
        var degree_rot = eulerToDegrees(euler: relative_position.eulerAngles.x)
        
        print("distance",distance)
        print("rotation:",degree_rot)
        
        if (degree_rot > 360.0 - rotation_deg_tollerance || degree_rot < rotation_deg_tollerance) {
            // accurate
            candidate.addChildNode(tickDone())
            return validationState.aligned
        }
        
        if (degree_rot > 180.0 && degree_rot > rotation_deg_tollerance) {
            // left turn
            candidate.addChildNode(leftArrow())
            return validationState.turn_left
        }
        candidate.addChildNode(rightArrow())
        return validationState.turn_right
    }
    
    
    
    
    
    
    func AllObjectsValidated(currentTask: Task) -> Bool{
        
        for object_state in currentTask.validation?.objectStates as! [validationState] {
            if object_state != validationState.aligned{
                return false
            }
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
    
}
