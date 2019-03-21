//
//  Validation.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 21/03/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import Foundation

class Validator{
    

    
    

    // return a suggested movement based on node relative to space
    func NodeToBoardPosition(Quaternion: SCNQuaternion) -> validationState{
        
        if(Quaternion.w > 0.9 && Quaternion.y < 0.1){
            print("^Correct^") // aligned
            return validationState.aligned
        }
        if(Quaternion.w < 0.75 && Quaternion.y < -0.6){
            print("Turn left")
            return validationState.turn_left
        }
        if(Quaternion.w < 0.1 && Quaternion.y > 0.9){
            print("Flip 180") // 180 degrees misaligned
            return validationState.flip_180
        }
        if(Quaternion.w > 0.7 && Quaternion.y > 0.7){
            print("Turn right")
            return validationState.turn_right
        }
        
        // If we aren't sure
        print("Uncertain")
        return validationState.misaligned
        
    }
    
    // Quick function to find correct positioning
    func ObjectOrientatedToTray(Quaternion: SCNQuaternion) -> Bool{
        // working on w and y axis
        if(Quaternion.w > 0.9 && Quaternion.y < 0.1){
            return true
        }
        return false
    }
    
    func AllObjectsValidated(currentTask: Task) -> Bool{
        
        for object_state in currentTask.validation?.objectStates as! [validationState] {
            if object_state != validationState.aligned{
                return false
            }
        }
        
        return true
    }

}

