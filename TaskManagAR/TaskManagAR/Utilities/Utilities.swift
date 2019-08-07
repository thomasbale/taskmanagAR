//
//  utilities.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 28/02/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import Foundation
import ARKit

//extension to return line geometry between two vectors
extension SCNGeometry {
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
}
// ectension to calculate distance between two vector points in the same coordinate space
extension SCNVector3 {
    static func distanceFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> Float {
        let x0 = vector1.x
        let x1 = vector2.x
        let y0 = vector1.y
        let y1 = vector2.y
        let z0 = vector1.z
        let z1 = vector2.z
        
        return sqrtf(powf(x1-x0, 2) + powf(y1-y0, 2) + powf(z1-z0, 2))
    }
}


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

func tranformCoordinate(_ latitude: Double, _ longitude: Double, zoom: Int) -> (x: Int, y: Int) {
    let tileX = Int(floor((longitude + 180) / 360.0 * pow(2.0, Double(zoom))))
    let tileY = Int(floor((1 - log( tan( latitude * Double.pi / 180.0 ) + 1 / cos( latitude * Double.pi / 180.0 )) / Double.pi ) / 2 * pow(2.0, Double(zoom))))
    
    return (tileX, tileY)
}

func tileToLatLon(tileX : Int, tileY : Int, mapZoom: Int) -> (lat_deg : Double, lon_deg : Double) {
    let n : Double = pow(2.0, Double(mapZoom))
    let lon = (Double(tileX) / n) * 360.0 - 180.0
    let lat = atan( sinh (.pi - (Double(tileY) / n) * 2 * Double.pi)) * (180.0 / .pi)
    
    return (lat, lon)
}

func tupleIdToArray(tuple: (Int32, Int32, Int32, Int32, Int32, Int32, Int32, Int32, Int32, Int32), no: Int32)->[Int]{
    
    var newArray = TupletoArray(tuple: tuple).array
    var retarray = [Int]()

    var i = 0
    while (i < no) {
        retarray.append(Int(newArray[i]))
        
        i = i+1
    }
    return retarray
}


func tupleMatrixToDict(tuple: (FoundMarker, FoundMarker, FoundMarker, FoundMarker, FoundMarker, FoundMarker, FoundMarker, FoundMarker, FoundMarker, FoundMarker), camera: SCNMatrix4, last_frame: [Int: marker_seen], count: Int)->[Int: marker_seen]{

    var previous = last_frame
    
    var mat = [SCNMatrix4]()
    var mark_ids = [Int]()
    
    mat.append(SCNMatrix4Mult(tuple.0.extrinsics, camera))
    mark_ids.append(Int(tuple.0.id))
    
    mat.append(SCNMatrix4Mult(tuple.1.extrinsics, camera))
    mark_ids.append(Int(tuple.1.id))
    
    mat.append(SCNMatrix4Mult(tuple.2.extrinsics, camera))
    mark_ids.append(Int(tuple.2.id))
    
    mat.append(SCNMatrix4Mult(tuple.3.extrinsics, camera))
    mark_ids.append(Int(tuple.3.id))
    
    mat.append(SCNMatrix4Mult(tuple.4.extrinsics, camera))
    mark_ids.append(Int(tuple.4.id))
    
    mat.append(SCNMatrix4Mult(tuple.5.extrinsics, camera))
    mark_ids.append(Int(tuple.5.id))
    
    mat.append(SCNMatrix4Mult(tuple.6.extrinsics, camera))
    mark_ids.append(Int(tuple.6.id))
    
    mat.append(SCNMatrix4Mult(tuple.7.extrinsics, camera))
    mark_ids.append(Int(tuple.7.id))
    
    mat.append(SCNMatrix4Mult(tuple.8.extrinsics, camera))
    mark_ids.append(Int(tuple.8.id))
    
    mark_ids = number_of_markers(array: mark_ids, no: count)
    
    previous.keys.forEach { previous[$0]?.visible_in_frame = false }
    
    var i = 0
    while (i < mark_ids.count) {

        // if it's in the previous frame
        if previous[mark_ids[i]] != nil {
            previous[mark_ids[i]]?.transform = mat[i]
            previous[mark_ids[i]]?.visible_in_frame = true
            //print("id " + String(mark_ids[i]) + "position updated")
        }else{
        // else add it as new
            let _t = marker_seen(transform: mat[i], visible_in_frame: true)
            previous.updateValue(_t, forKey: mark_ids[i])
            //print("id " + String(mark_ids[i]) + "position added as new")
            }
        i = i + 1
        }
    //print(previous.count)
    return previous
    }

func number_of_markers(array: [Int], no: Int)-> [Int]{
    var newarray = [Int]()
    
    var i = 0
    while i < no {
        newarray.append(array[i])
        i = i + 1
    }
    
    return newarray
}

// remove nodes with specific name
func removeChildrenNamed(name: String, parent: SCNNode){
    parent.enumerateChildNodes { (node, stop) in
        if (node.name == name) {
            node.removeFromParentNode()
        }
    }
    
}

// helper func to check whether ID is a location marker
func isSpaceMarker(id: Int, current_task: Task) -> Bool {
    if id == current_task.space.boom_id || id == current_task.space.datum_id || id == current_task.space.boom_face_id || id == current_task.space.datum_face_id{
        return true
        
    }
    return false
}

// work out the variance in estimations on the same model. Returns the number of estimates within 1mm

func varianceTonorm(vectorEstimates: [SCNVector3])-> Float{
    if (vectorEstimates.count > 10) {
        
        // find the total distance between the current and last 4 points and add them together
        let variance =
            
            SCNVector3.distanceFrom(vector: vectorEstimates[vectorEstimates.count-2], toVector: vectorEstimates[vectorEstimates.count-1])
                +
                SCNVector3.distanceFrom(vector: vectorEstimates[vectorEstimates.count-3], toVector: vectorEstimates[vectorEstimates.count-1])
                +
                SCNVector3.distanceFrom(vector: vectorEstimates[vectorEstimates.count-4], toVector: vectorEstimates[vectorEstimates.count-1])
        
        return variance
    }
    return 1.0
}

func markersFoundAimateDisplay(found: Int, level: Int, mark1: UIImageView, mark2: UIImageView, mark3: UIImageView )->Bool{
    
    if (found >= level/3){mark1.isHidden = false}
    if (found >= level/2){mark2.isHidden = false}
    if (found >= (level/2 + level/4)){mark3.isHidden = false}
    if found >= level
    {
        return true}
    return false
}
    
func updateMarkerPositions(rootNode: SCNNode, markers: [Int: marker_seen]){
    
    for id in markers {
        rootNode.enumerateChildNodes { (node, stop) in
            if (node.name == String(id.key)) {
                print("updating scene")
                node.transform = id.value.transform
            }
        }
    }
    
}


