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
        let Node = self.GetModel(model_name: "waypoint", scene_name: "art.scnassets/Base.lproj/waypoint.scn")
        Node.scale = SCNVector3Make(0.1, 0.1, 0.1)
        return Node
    }

    func GetModel(model_name: String, scene_name: String) -> SCNNode{
        var node = SCNNode()
        // Try to load the node assets from the scene
        if let assetScene = SCNScene(named: scene_name) {

            if let node_ = assetScene.rootNode.childNode(withName: model_name, recursively: true) {
                print("loaded")
                node.name = "waypoint"
                node = node_
            }
            
        }
        return node
    }

}
