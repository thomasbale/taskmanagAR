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
    let ambientLight = SCNLight()
    ambientLight.type = .ambient
    ambientLight.intensity = 40
    
    let lightnode = SCNNode()
    lightnode.light = ambientLight
    return lightnode
}



func leftArrow()-> SCNNode {
    let tempScene = SCNScene(named: "art.scnassets/Base.lproj/arrow_scaled.dae")!
    let modelNode = tempScene.rootNode
    modelNode.scale = SCNVector3(0.1, 0.1, 0.1)
    modelNode.eulerAngles = SCNVector3Make(0,0,0)
    
    let action : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 0, 1), duration: 1.0)
    let forever = SCNAction.repeatForever(action)
    modelNode.runAction(forever)
    
    return modelNode
}

func tickDone()-> SCNNode {
    let modelNode = SCNNode()
    modelNode.geometry = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
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

func Arrow(degrees: Float, direction: String)-> SCNNode {
    let tempScene = SCNScene(named: "art.scnassets/Base.lproj/arrow_scaled.dae")!
    let modelNode = tempScene.rootNode
    modelNode.scale = SCNVector3(0.1, 0.1, 0.1)
    
    if direction == "right" {
        modelNode.eulerAngles = SCNVector3Make(Float(Double.pi),0,0)
    }else{
        modelNode.eulerAngles = SCNVector3Make(0,0,0)
    }
    
    let up :
        
        SCNAction = SCNAction.rotate(by: CGFloat(deg2rad(degrees)), around: SCNVector3(0, 0, 1), duration: 1.5)
    
    let down :
        
        SCNAction = SCNAction.rotate(by: -CGFloat(deg2rad(degrees)), around: SCNVector3(0, 0, 1), duration: 0.2)
    
    var sequence = [SCNAction]()
    
    sequence.append(up)
    sequence.append(down)
    
    let actions = SCNAction.sequence(sequence)
    
    let forever = SCNAction.repeatForever(actions)

    
    modelNode.runAction(forever)
    
    return modelNode
}


func TrayWaypoint(colour: UIColor)-> SCNNode{
    let waypoint = SCNNode()
    let torus = SCNTorus(ringRadius: 0.1, pipeRadius: 0.01)
    let material = SCNMaterial()
    waypoint.geometry = torus
    waypoint.eulerAngles = SCNVector3Make(Float(Double.pi/2), 0,0 )

    material.diffuse.contents = colour
    torus.materials = [material]
    
    return waypoint
}

func lineTowards(from: SCNNode, to: SCNNode) -> SCNNode{
    //from.addChildNode(to)
    let lineGeometry = SCNGeometry.lineFrom(vector: from.worldPosition, toVector: to.worldPosition)
    let lineNode = SCNNode(geometry: lineGeometry)
    return lineNode
}

func AddFloatingInstruction(message: String, parent: SCNNode){
    parent.addChildNode(createTextNode(string: message))
}

func createTextNode(string: String) -> SCNNode {
    let text = SCNText(string: string, extrusionDepth: 0.1)
    text.font = UIFont.systemFont(ofSize: 0.5)
    text.flatness = 0.01
    text.firstMaterial?.diffuse.contents = UIColor.white
    
    let textNode = SCNNode(geometry: text)
    
    let fontSize = Float(0.02)
    textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
    //textNode.position = SCNVector3Zero
    
    textNode.constraints = [SCNBillboardConstraint()]
    
    // apply the constraint to the parent node
    
    return textNode
}

func deg2rad(_ number: Float) -> Float {
    return number * .pi / 180
}
