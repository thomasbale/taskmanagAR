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

let MARKER_SIZE_IN_METERS : CGFloat = 0.03; //set this to size of physically printed marker in meters

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    private var localizedContentNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)) //scene node positioned at marker to hold scene contents. Likely should be replaced with setWorldOrigin() in ios 11.3.
    
    private var isLocalized = true
    
    private var captureNextFrameForCV = true; //when set to true, frame is processed by opencv for marker

    @IBOutlet var sceneView: ARSCNView!
    
    // Button press used to prevent 
    @IBOutlet var buttonpress: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

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
            updateCameraPose(frame: frame)
            self.captureNextFrameForCV = false
        }
}
    
    private func updateCameraPose(frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        //this this is matrix from camera to target

        
        let transMatrix = OpenCVWrapper.transformMatrix(from: pixelBuffer, withIntrinsics: frame.camera.intrinsics, andMarkerSize: Float64(MARKER_SIZE_IN_METERS));
        //If it's an identity matrix no marker was found.
        //Returns a Boolean value that indicates whether the specified matrix is equal to the identity matrix.
        if(SCNMatrix4IsIdentity(transMatrix)) {
            print("no marker found")
            return;
        }
        // If the matrix is not identity there must be a marker
        let cameraTransform = SCNMatrix4.init(frame.camera.transform);
        let targTransform = SCNMatrix4Mult(transMatrix, cameraTransform);
        //strange behavior leads me to believe that the scene updates should occur in main dispatch que. (or perhaps I should be using anchors)
        DispatchQueue.main.async {
            self.updateContentNode(targTransform: targTransform)
        }
        isLocalized = true;
        //we want to use transMatrix to position arWaypoint anchor on marker.
    }
    
    private func updateContentNode(targTransform: SCNMatrix4) {
        // Is there already a localised content node?
        if !sceneView.scene.rootNode.childNodes.contains(localizedContentNode) {
            // Position is derived from Aruco matrix requires transformation from 4x4 matrix to 3vector
            localizedContentNode.position = positionFromTransform(float4x4.init(targTransform))
            sceneView.scene.rootNode.addChildNode(localizedContentNode);
            print("added localised content node")
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
}
