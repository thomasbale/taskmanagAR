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
    // Based on A3 dimensions
    private var markerVerticalSeparation = 0.2463 //metres
    private var markerHorizontalSeparation = 0.3616
    private var trayState = "pending" // pending or ready
    // Marker IDs
    private var marker_0 = 0
    private var marker_1 = 1
    private var marker_2 = 2
    private var marker_3 = 3
    
    // Returns the full tray plane relative to the fudicial marker
    func GetPlane () -> SCNNode {
        let plane = SCNNode(geometry: SCNBox(width: 0.05, height: 0.005, length: 0.05, chamferRadius: 0))
        return plane
    }
    // Returns the full tray plane relative to the fudicial marker
    func GetObjects (withid: Int, localnode: SCNNode) -> SCNScene {
        let newScene = SCNScene()
        
        //let plane = self.GetPlane()
        //plane.position = localnode.position
        newScene.rootNode.addChildNode(localnode)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
    
        let newGeometry = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
        newGeometry.materials = [material]
        
        let newObject = SCNNode(geometry:newGeometry)
        
        //let newObject2 = SCNNode(geometry:newGeometry2)
        
        /* Plane coordinates //
        based on the SCNVector3(x,y,z) in metres
        Positive values move up and away from the boom on the tray
         x = horizontal axis
         y = vertical axis
         z = height and depth above and below tray
         
         0,0 position is boom
         
        */
        
        newObject.position = CentrePoint(withid: 2)
        
        
        //newObject2.position = SCNVector3(0.05,0.05, 0)
        
        //newObject.addChildNode(newObject2)
        
        localnode.addChildNode(newObject)

        return newScene
    }
    
    func CentrePoint (withid: Int) -> SCNVector3 {
        // Function calculates the centrepoint based on tray size
        switch withid {
        case 3: // RightHand
            let vector = SCNVector3(self.markerVerticalSeparation/2,self.markerHorizontalSeparation/2, 0)
             return vector
        case 0: // boom
            let vector = SCNVector3(self.markerVerticalSeparation/2,0-(self.markerHorizontalSeparation/2), 0)
             return vector
        case 1: // TopLeft
            let vector = SCNVector3(0-(self.markerVerticalSeparation/2),0-(self.markerHorizontalSeparation/2), 0)
             return vector
        case 2: // TopRight
            let vector = SCNVector3(0-(self.markerVerticalSeparation/2),self.markerHorizontalSeparation/2, 0)
             return vector
        default:
            let vector = SCNVector3(0,0,0)
             return vector
        }
       return SCNVector3()
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
}
