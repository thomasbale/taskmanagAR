//
//  tray265.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 09/01/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

// ToDo define the marker size and dictionary here

class Tray{
    // Based on A3 dimensions 29.7 x 42.0cm
    private var markerVerticalSeparation = 0.297 //metres
    private var markerHorizontalSeparation = 0.84
    private var trayState = "pending" // pending or ready
    // Marker IDs
    private var marker_0 = 0
    private var marker_1 = 1
    private var marker_2 = 2
    private var marker_3 = 3
    
    var geometry = SCNBox(width: 0.297, height: 0.84, length: 0.005, chamferRadius: 0)
    var colour = SCNMaterial()
    private var node = SCNNode()
    
    // Returns the full tray plane relative to the fudicial marker
    func GetPlane () -> SCNNode {
        let plane = SCNNode(geometry: SCNBox(width: 0.05, height: 0.005, length: 0.05, chamferRadius: 0))
        return plane
    }
    // Returns the full tray plane relative to the fudicial marker
    func GetObjects (withid: Int, localnode: SCNNode) -> SCNScene {
        let newScene = SCNScene()
        
        newScene.rootNode.addChildNode(localnode)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        material.transparency = 0.5
    
        let newGeometry = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
        newGeometry.materials = [material]
        
        let newObject = SCNNode(geometry:newGeometry)
        

        
        //newObject2.position = SCNVector3(0.05,0.05, 0)
        
        //newObject.addChildNode(newObject2)
        
        localnode.addChildNode(newObject)

        return newScene
    }
    
    func CentrePoint (withid: Int, task: Task) -> SCNVector3 {
        // Function calculates the centrepoint based on tray size
        switch withid {
        case task.space.datum_marker_id: // datum
            let vector = SCNVector3(self.markerVerticalSeparation/2,self.markerHorizontalSeparation/2, 0)
             return vector
        case task.space.boom_marker_id: // boom
            let vector = SCNVector3(self.markerVerticalSeparation/2,0-(self.markerHorizontalSeparation/2), 0)
             return vector
        case task.space.left_top_marker_id: // TopLeft
            let vector = SCNVector3(0-(self.markerVerticalSeparation/2),0-(self.markerHorizontalSeparation/2), 0)
             return vector
        case task.space.right_top_marker_id: // TopRight
            let vector = SCNVector3(0-(self.markerVerticalSeparation/2),self.markerHorizontalSeparation/2, 0)
             return vector
        default:
            let vector = SCNVector3(0,0,0)
             return vector
        }
    }
    
    func isTrayMarker (withid: Int) -> Bool{
        // Is the ID a valid tray plane marker?
        switch withid {
        case marker_0: // RH
            return true
        case marker_1: // boom
            return true
        case marker_2: // TL
            return true
        case marker_3: // TR
            return true
        default:
            return false
        }
    
    }
    
    func TrayCentreNode () -> SCNNode{
        //node.transform = self.transform
        node.geometry = geometry
        colour.diffuse.contents = UIColor.blue
        colour.transparency = 0.1
        geometry.materials = [colour]
        return node
    }
}
