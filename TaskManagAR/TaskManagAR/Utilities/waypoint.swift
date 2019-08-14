//
//  waypoint.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 13/08/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import UIKit

class WaypointModel: SCNNode {
    
    
    func GetWaypoint()->SCNNode{
        let Node = self.GetModel(model_name: "pin", scene_name: "art.scnassets/Base.lproj/pin.scn")
        Node.scale = SCNVector3Make(0.04, 0.04, 0.04)
        Node.eulerAngles = SCNVector3Make(Float(Double.pi/2), 0, Float(Double.pi))
        Node.position = SCNVector3(0, 0, 0.1)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.green
        Node.geometry?.materials = [mat]
        //let yFreeConstraint = SCNBillboardConstraint()
        //yFreeConstraint.freeAxes = .Y // optionally
        //Node.constraints = [yFreeConstraint] // apply the constraint to the parent node
        
        //Node.eulerAngles.y = Float(Double.pi/3)
        let action : SCNAction = SCNAction.rotate(by: 20, around: SCNVector3(0, 0, 1), duration: 3)
        let forever = SCNAction.repeatForever(action)
        Node.runAction(forever)
       
        return Node
    }
    
    func GetEndPoint()->SCNNode{
        let Node = self.GetModel(model_name: "pin", scene_name: "art.scnassets/Base.lproj/pin.scn")
        Node.scale = SCNVector3Make(0.04, 0.04, 0.04)
        Node.eulerAngles = SCNVector3Make(Float(Double.pi/2), 0, Float(Double.pi))
        Node.position = SCNVector3(0, 0, 0)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.green
        Node.geometry?.materials = [mat]
        //let yFreeConstraint = SCNBillboardConstraint()
        //yFreeConstraint.freeAxes = .Y // optionally
        //Node.constraints = [yFreeConstraint] // apply the constraint to the parent node
        
        //Node.eulerAngles.y = Float(Double.pi/3)
        //let action : SCNAction = SCNAction.rotate(by: 20, around: SCNVector3(0, 0, 1), duration: 3)
        //let forever = SCNAction.repeatForever(action)
        //Node.runAction(forever)
        
        return Node
    }

    func GetModel(model_name: String, scene_name: String) -> SCNNode{
        var node = SCNNode()
        // Try to load the node assets from the scene
        if let assetScene = SCNScene(named: scene_name) {

            if let node_ = assetScene.rootNode.childNode(withName: model_name, recursively: true) {
                node.name = "waypoint"
                node = node_
            }
            
        }
        return node
    }

}
