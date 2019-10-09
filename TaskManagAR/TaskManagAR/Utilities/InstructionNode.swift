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

    
    func addInstructionsForObject(transform: SCNMatrix4, task: Task, id: Int, target: SCNMatrix4, rootNode: SCNNode, object: Object){
        
        if validationstate == validationState.aligned {
            return
        }
        
        // attach to self to attach to object
        self.name = "instruction" + String(id)
        //self.geometry = SCNBox(width: 0.03, height: 0.03, length: 0.03, chamferRadius: 0)
        
        self.transform = transform
        
        self.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        // calculate marker offset
        self.addChildNode(object.marker_offsetNode)

        AddFloatingInstruction(message: object.name, parent: self)
        let target_node = SCNNode()
        let valid = Validator()
        
        
        target_node.transform = target_node.convertTransform(target, to: nil)
        target_node.name = "instruction" + String(id)
        
        
        rootNode.enumerateChildNodes { (node, stop) in
            
            if node.name == "instruction" + String(id){
                node.removeFromParentNode()
            }
        }
        
        rootNode.addChildNode(target_node)
        
        validationstate = valid.nodeTonodePath(candidate: object.marker_offsetNode, target: target_node, object: object)
        
        
    }
    
}
