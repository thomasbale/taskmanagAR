//
//  ViewController.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 18/12/2018.
//  Copyright © 2018 Thomas Bale. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import GLKit


let MARKER_SIZE_IN_METERS : CGFloat = 0.0282; //set this to size of physically printed marker in meters

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    private var localizedContentNode = SCNNode(geometry: SCNBox(width: 0.01, height: 0.005, length: 0.01, chamferRadius: 0))
    private var TrayCentrepoint = SCNNode()
    private var isLocalized = false
    private var captureNextFrameForCV = true; //when set to true, frame is processed by opencv for marker
    

    
    // use for testing accumilation of matricies - each one gets added in turn
    private var matricies = [SCNMatrix4]()
    private var targets = [SCNMatrix4]()
    
    let loadedtray = Tray()
    var targTransform = SCNMatrix4()
    
    @IBOutlet var sceneView: ARSCNView!
    
    // Button press used to prevent process overload & button for loading a tray scene
    @IBOutlet var buttonpress: [UIButton]!
    
    @IBOutlet weak var loadmodelbutton: UIButton!
    
    @IBAction func buttonloadmodel(_ sender: Any){
        // clean up to prevent issues
        //sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
        //    node.removeFromParentNode() }
        
        
        // Try to load the node assets from the scene
        if let assetScene = SCNScene(named: "art.scnassets/Base.lproj/Tiles_on_Tyne.scn") {
            
            print("loading 3d model")
    
            
            let geo = SCNPyramid(width: 0.2, height: 0.2, length: 0.2/2)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.blue
            geo.materials = [mat]
            let node = SCNNode(geometry: geo)
            //node.transform = targTransform
            // Transform moves from different coodinate spaces
            node.eulerAngles.y += GLKMathDegreesToRadians(90)
            node.eulerAngles.z += GLKMathDegreesToRadians(90)
            TrayCentrepoint.addChildNode(node)
            //sceneView.scene.rootNode.addChildNode(node)
            
            
            if let node1 = assetScene.rootNode.childNode(withName: "RX180-RXC080_Carrier_Subframe_W-Bulk_LBSRP_Adapter_without_Tool_ParkFBXASC032-FBXASC032Vessel_Left", recursively: true) {
                
                let anchor = ARAnchor(transform: simd_float4x4(targTransform))
                sceneView.session.add(anchor:anchor)

                node1.transform = targTransform
                //node1.eulerAngles.y += GLKMathDegreesToRadians(90)
                //node1.eulerAngles.z += GLKMathDegreesToRadians(90)
                sceneView.scene.rootNode.addChildNode(node1)
                
                print("loading 3d model node")
            }
        }
        
        
        
    }
    @IBOutlet weak var Debuggingop: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Limit FPS
        sceneView.preferredFramesPerSecond = 30
        Debuggingop.text = "localising"
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        if (sceneView.session.currentFrame != nil){
            updateCameraPose(frame: sceneView.session.currentFrame!)
        }
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showWireframe, .showBoundingBoxes, .showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration and apply debug options
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.maximumNumberOfTrackedImages = 0
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    @IBAction func pressed(_ sender: Any) {
        // to slow down processing only activated on button press
        self.captureNextFrameForCV = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // Calls every time a frame is updated in the session
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        // Only run if the button is pressed
                if(self.captureNextFrameForCV != false) {
                print("updating frame...")
                self.Debuggingop.text = "Find tray markers to start scene"
                self.updateCameraPose(frame: frame)
                self.captureNextFrameForCV = false // used to limit to button calling
            }
}
    // Main calling function: updates pose from passed frame
    private func updateCameraPose(frame: ARFrame) {
        // Current status contains a string as to the tracking status of the world
        let currentstatus = sessionStatus()
        // If ready go ahead and pass
        if (currentstatus == "") {
            let pixelBuffer = frame.capturedImage
            //Pixelbuffer is a rectified image. Instrinsics provides a transform from 2d camera space to 3d world coordinate space
            // Create a new frame struct for detection
            var newframe = OpenCVWrapper.arucodetect(pixelBuffer, withIntrinsics: frame.camera.intrinsics, andMarkerSize: Float64(MARKER_SIZE_IN_METERS))
            // Save the transform from camera to world space
            newframe.cameratransform = frame.camera.transform
            //quick break
            if(newframe.no_markers == 0) {
                print("no marker found. Keep looking.")
                self.Debuggingop.text = "no marker found. Keep looking."
                return;
            }
            
            // Need to convert tuple to iteratable type - c++ to swift conversion
            let tupleMirror = Mirror(reflecting: newframe.ids)
            let frameIDs = tupleMirror.children.map({ $0.value })
            
            print(frameIDs)
            
            //Some kind of loop in here through the markers in the frame & check whether they are plane markers
            var i = 0
            print("Found ", newframe.no_markers, " markers: ")
            while i <= newframe.no_markers - 1 {
                print(" markers: ", frameIDs[i], " ")
                
                i = i + 1
            }
            
            // IF a marker is found: transform in the main queue
            DispatchQueue.main.async {
                // Multipy the next transformation matrix by the original camera position at the frame capture point
                self.targTransform = SCNMatrix4Mult(newframe.extrinsics, SCNMatrix4.init(newframe.cameratransform));
                self.Debuggingop.text = "Found " + String(newframe.no_markers) + " markers: " + String(newframe.ids.0)
                self.updateContentNode(targTransform: self.targTransform, markerid: Int(newframe.ids.0))
                self.isLocalized = true;
                //we want to use transMatrix to position arWaypoint anchor on marker.
            }
            return
        }
        self.Debuggingop.text = currentstatus
        return
            }
    
    
    private func updateContentNode(targTransform: SCNMatrix4, markerid: Int) {
        //Basic error check before rendering
        if (applyMatrixThreshold(matrix: targTransform)){
        
        if self.isLocalized {
            // Is there already a localised content node? Destroy it:
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode() }
       
                localizedContentNode.opacity = 0.5
                localizedContentNode.transform = targTransform // apply new transform to node

            // Calculate the centre of the tray and make child of marker
            //var clean_centre = TrayAnchor()
            TrayCentrepoint = loadedtray.TrayCentreNode()
            
            // Get the offset to the centre of the tray
                localizedContentNode.addChildNode(TrayCentrepoint)
                TrayCentrepoint.position = loadedtray.CentrePoint(withid: markerid)
                sceneView.scene.rootNode.addChildNode(localizedContentNode);
            
            // Add centrepoint to the list
             //   targets.append(centrepoint.transform)
            // Pass centrepoints for analysis
            
            // mean centre calculation
            //clean_centre.initialise(targets: targets)
            
            //if clean_centre.ready{
             //   sceneView.scene.rootNode.addChildNode(centrepoint)
            //}
            
            // Create an anchor at this point
                //let target = ARAnchor(name: "Target", transform: simd_float4x4(centrepoint.transform))
                //sceneView.session.add(anchor: target)

                print("added localised content node for marker ")
                
            }
        }
        
        func renderer(_ renderer: SCNSceneRenderer,
                               nodeFor anchor: ARAnchor) -> SCNNode?{
            return SCNNode(geometry: SCNBox(width: 0.01, height: 0.005, length: 0.01, chamferRadius: 0))
        }
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
        func sessionStatus() -> String? {
            
            //1. Get The Current Frame
            guard let frame = sceneView.session.currentFrame else { return nil }
            
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
    
    // error checking function to make sure that detected marker is flat to the camera and not
    func applyMatrixThreshold(matrix: SCNMatrix4)->Bool{
        
        let throwawaynode = SCNNode()
        throwawaynode.transform = matrix
        let orientation = abs(throwawaynode.simdEulerAngles.x)
        if
            matrix.m31 < -1 || matrix.m32 < -5 || matrix.m24 > 10 || matrix.m34 > 5 || !(orientation > 1.3 && orientation < 1.8){
            print("*** Error caught ***")
            return false
        }
        
        return true
    }
    
        
    }
