//
//  Find_Anchor.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 29/01/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import Foundation


class TrayAnchor{
    
    var ready = false
    var transform = SCNMatrix4()
    var geometry = SCNBox(width: 0.01, height: 0.005, length: 0.01, chamferRadius: 0)
    var colour = SCNMaterial()
    private var node = SCNNode()
    
    func initialise (targets:[SCNMatrix4]){
        if targets.count<3 {
            return
        }
        ready = true
        transform = targets.randomElement()!
        print("render ready...")
        return
    }
    
    func TrayCentreNode () -> SCNNode{
        node.transform = self.transform
        node.geometry = geometry
        colour.diffuse.contents = UIColor.red
        geometry.materials = [colour]
        return node
    }
    
    
}
