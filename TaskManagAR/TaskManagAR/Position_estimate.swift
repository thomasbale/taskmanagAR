//
//  Find_Anchor.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 29/01/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import Foundation


class TrayAnchor{
    //Based on A3 dimensions 29.7 x 42.0cm // 0.297 x 0.84
    var ready = false
    var transform = SCNMatrix4()
    var geometry = SCNBox(width: 0.297, height: 0.84, length: 0.005, chamferRadius: 0)
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
        //node.transform = self.transform
        node.geometry = geometry
        colour.diffuse.contents = UIColor.blue
        colour.transparency = 0.5
        geometry.materials = [colour]
        return node
    }
    
    
}
