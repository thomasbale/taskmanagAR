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

let MARKER_SIZE_IN_METERS : CGFloat = 0.00858; //set this to size of physically printed marker in meters

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    private var localizedContentNode = SCNNode(geometry: SCNBox(width: 0.01, height: 0.01, length: 0.005, chamferRadius: 0))
    
    private var isLocalized = true
    
    private var captureNextFrameForCV = true; //when set to true, frame is processed by opencv for marker

    let loadedtray = Tray()
    
    var targTransform = SCNMatrix4()
    
    @IBOutlet var sceneView: ARSCNView!
    
    // Button press used to prevent process overload & button for loading a tray scene
    @IBOutlet var buttonpress: [UIButton]!
    
    @IBOutlet weak var loadmodelbutton: UIButton!
    
    @IBAction func buttonloadmodel(_ sender: Any){
        // clean up to prevent issues
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode() }
        // call the tray reference scene
        if isLocalized {
            sceneView.scene = self.loadedtray.GetObjects(withid: 0, localnode: self.localizedContentNode)
        }
    }
    @IBOutlet weak var Debuggingop: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration and apply debug options
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.maximumNumberOfTrackedImages = 0
        // Add feature points debug options (useful for tracking)
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showCameras]

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
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
                if(self.captureNextFrameForCV != false) {
                print("updating frame...")
                self.Debuggingop.text = "no markers..."
                self.updateCameraPose(frame: frame)
                self.captureNextFrameForCV = false // used to limit to button calling
            }
}
    
    private func updateCameraPose(frame: ARFrame) {
        let currentstatus = sessionStatus()
        if (currentstatus == "") {
            let pixelBuffer = frame.capturedImage
            //Pixelbuffer is a rectified image
            // Instrinsics provides a transform from 2d camera space to 3d world coordinate space
            
            // Create a new frame struct for detection
            var newframe = OpenCVWrapper.arucodetect(pixelBuffer, withIntrinsics: frame.camera.intrinsics, andMarkerSize: Float64(MARKER_SIZE_IN_METERS))
            // Save the transform from camera to world space
            newframe.cameratransform = frame.camera.transform
            //quick break
            if(newframe.no_markers == 0) {
                print("no marker found")
                self.Debuggingop.text = "no marker found"
                return;
            }
            
            DispatchQueue.main.async {
                // Multipy the next transformation matrix by the original camera position at the frame capture point
                self.targTransform = SCNMatrix4Mult(newframe.extrinsics, SCNMatrix4.init(frame.camera.transform));
                print(self.targTransform)
                // print to debug+
                print("Found ", newframe.no_markers, " markers: ", newframe.ids.0, " ", newframe.ids.1)
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
            if sceneView.scene.rootNode.childNodes.contains(localizedContentNode) {
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode() }
            }
            
            
            
                
                // Create new:
                localizedContentNode.opacity = 0.5
                localizedContentNode.transform = targTransform // apply new transform to node
                let centrepoint = SCNNode(geometry: SCNSphere(radius: 0.01))
                centrepoint.position = loadedtray.CentrePoint(withid: markerid)
                localizedContentNode.addChildNode(centrepoint)
                //localizedContentNode.position = loadedtray.CentrePoint(withid: markerid)
                sceneView.scene.rootNode.addChildNode(localizedContentNode);
                print("added localised content node for marker ")
                
            }
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
    
    func applyMatrixThreshold(matrix: SCNMatrix4)->Bool{
        
        if
            matrix.m31 < -1 || matrix.m32 < -5 || matrix.m24 > 10 || matrix.m34 > 5 {
            print("*** Error caught ***")
            return false
        }
        
        return true
    }
        
    }
