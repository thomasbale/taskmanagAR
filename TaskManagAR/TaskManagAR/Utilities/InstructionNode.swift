//
//  InstructionNode.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 13/08/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import UIKit

class InstructionNode: SCNNode {
    var validationstate = validationState.not_visible
    var target_marker = SCNNode()

    
    func addInstructionsForObject(transform: SCNMatrix4, task: Task, id: Int, target: SCNMatrix4, rootNode: SCNNode){
        // attach to self to attach to object
        self.name = "instruction" + String(id)
        self.geometry = SCNBox(width: 0.03, height: 0.03, length: 0.03, chamferRadius: 0)
        self.transform = transform
        let target_node = SCNNode()
        let valid = Validator()
        
        target_node.transform = target_node.convertTransform(target, to: nil)
        target_node.name = "instruction" + String(id)
        rootNode.addChildNode(target_node)
        
        validationstate = valid.nodeTonodePath(candidate: self, target: target_node)
    }
    
   
    
    
    
}
