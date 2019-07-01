//
//  utilities.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 28/02/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import Foundation
import ARKit

struct TupletoArray {
    var tuple: (Int32, Int32, Int32, Int32, Int32, Int32, Int32, Int32, Int32, Int32)
    var array: [Int32] {
        var tmp = self.tuple
        return [Int32](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func outputImage(name:String,image:UIImage){
    let fileManager = FileManager.default
    let pngdata = image.pngData()
    fileManager.createFile(atPath: "/Users/thomasbale/Desktop/\(name)", contents: pngdata, attributes: nil)
    
}

func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
    // This function performs the following conversion:
    //    column 0  column 1  column 2  column 3
    //         1        0         0       X    
    //         0        1         0       Y    
    //         0        0         1       Z    
    //         0        0         0       1    
    
    return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
}


/// Returns The Status Of The Current ARSession
func sessionStatus(frame: ARFrame) -> String? {

    var status = "Preparing Device.."
    
    //1. Return The Current Tracking State & Lighting Conditions
    switch frame.camera.trackingState {
        
    case .normal:                                                   status = ""
    case .notAvailable:                                             status = "Tracking Unavailable"
    case .limited(.excessiveMotion):                                status = "Please Slow Your Movement"
    case .limited(.insufficientFeatures):                           status = "Try To Point At A Flat Surface"
    case .limited(.initializing):                                   status = "Initializing"
    case .limited(.relocalizing):                                   status = "Relocalizing"
        
    }
    
    guard let lightEstimate = frame.lightEstimate?.ambientIntensity else { return nil }
    
    if lightEstimate < 100 { status = "Lighting Is Too Dark" }
    
    return status
    
}

func getLightNode() -> SCNNode {
    let light = SCNLight()
    light.type = .omni
    light.intensity = 0.5
    light.temperature = 0.0

    
    let lightNode = SCNNode()
    lightNode.light = light
    lightNode.position = SCNVector3(0,1,0)
    
    return lightNode
}

func addLightNodeTo(_ node: SCNNode) {
    let lightNode = getLightNode()
    node.addChildNode(lightNode)
    //lightNodes.append(lightNode)
}

func leftArrow()-> SCNNode {
    let tempScene = SCNScene(named: "art.scnassets/Base.lproj/arrow_scaled.dae")!
    let modelNode = tempScene.rootNode
    modelNode.scale = SCNVector3(0.1, 0.1, 0.1)
    modelNode.eulerAngles = SCNVector3Make(0,0,0)
    return modelNode
}

func rightArrow()-> SCNNode {
    let tempScene = SCNScene(named: "art.scnassets/Base.lproj/arrow_scaled.dae")!
    let modelNode = tempScene.rootNode
    modelNode.scale = SCNVector3(0.1, 0.1, 0.1)
    modelNode.eulerAngles = SCNVector3Make(Float(Double.pi),0,0)
    print("arrow called")
    
    return modelNode
}

