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
        //material.lightingModel = .physicallyBased
    
        let newGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        newGeometry.materials = [material]
        let newGeometry2 = SCNTorus(ringRadius: 0.1, pipeRadius: 0.03)
        let newObject = SCNNode(geometry:newGeometry)
        let newObject2 = SCNNode(geometry:newGeometry2)
        
        /* Plane coordinates //
        based on the SCNVector3(x,y,z) in metres
        Positive values move up and away from the boom on the tray
         x = horizontal axis
         y = vertical axis
         z = height and depth above and below tray
         
         0,0 position is boom
         
        */
        
        newObject.position = SCNVector3(0.15,0.15, 0)
        newObject2.position = SCNVector3(0.05,0.05, 0)
        newObject.addChildNode(newObject2)
        
        localnode.addChildNode(newObject)

        return newScene
    }
    
    
}

