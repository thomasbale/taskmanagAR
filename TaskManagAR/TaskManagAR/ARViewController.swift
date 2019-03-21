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
import CoreData

let MARKER_SIZE_IN_METERS : CGFloat = 0.0282; //set this to size of physically printed marker in meters

protocol DisplayViewControllerDelegate : NSObjectProtocol{
     func updateEvent(activeEvents: [Task])
}

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    weak var delegate : DisplayViewControllerDelegate?
    
    @IBOutlet weak var completeTick: UIImageView!
    // All the tasks in the set
    var activeTasks = [Task()]
    // The index of the current task
    var taskIndex = Int()
    // Localised nodes for this session
    private var localizedContentNode = SCNNode()
    // localsed from the space
    private var TrayCentrepoint = SCNNode()
    // status variables
    private var isLocalized = false
    private var captureNextFrameForCV = false; //when set to true, frame is processed by opencv for marker
    
    // for the validation process
    private var status_0 = UIColor.red
    private var status_1 = UIColor.red
    private var status_2 = UIColor.red
    
    // running session log of objects that are marked as validated in the current scene
    private var ObjectsPlacedDone = [Int]()
    
    // Object properties
    private var assetMark_0 = 6
    private var assetMark_1 = 6
    private var assetMark_2 = 6
    
    // validation poperties
    private var visibleObjectIds = [Int32]()
    private var visibleObjectPos = [SCNMatrix4]()
    // Activity indicator for the validation process
    @IBOutlet weak var activityWait: UIActivityIndicatorView!
    
    // holds target tray properties
    let loadedtray = Tray()
    // transform to detected target
    var targTransform = SCNMatrix4()
    
    @IBOutlet var sceneView: ARSCNView!
    
    // Button press used to prevent process overload & button for loading a tray scene
    @IBOutlet var buttonpress: [UIButton]!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var loadmodelbutton: UIButton!
    @IBOutlet weak var ValidateButton: UIButton!
    
    // function called when a 'load model' request from user
    @IBAction func buttonloadmodel(_ sender: Any){
        if(isLocalized == false){
            return}
        // remove existing nodes from tray
       TrayCentrepoint.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode() }
        // add an anchor to the scene for stablisation
        let anchor = ARAnchor(transform: simd_float4x4(targTransform))
        sceneView.session.add(anchor:anchor)
        
        let mat_0 = SCNMaterial()
        mat_0.diffuse.contents = status_0
        mat_0.transparency = 0.8
        
        // For testing creating three demo boxes and applying global materials
        let node0 = RenderNode()

        // centre
        node0.position = SCNVector3(0.15, 0, 0)
        node0.geometry?.materials = [mat_0]
       
        TrayCentrepoint.addChildNode(node0)
    
    }

    
    
    @IBAction func Validate(_ sender: Any) {
        // if not ready return
        if(isLocalized == false) || (self.activeTasks[self.taskIndex].validation == nil){
            print("Not localised or no validation available for this task")
            return
        }
        // capture a frame
       self.captureNextFrameForCV = true
        self.activityWait.startAnimating()
        // check whether the ID is present & orientation
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            // pass by reference
            self.validateTask(task: &self.activeTasks[self.taskIndex])
            if self.AllObjectsValidated(currentTask: self.activeTasks[self.taskIndex]){
                
                self.completeTick.isHidden = false
                self.completeTick.alpha = 1.0
                
                UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                    
                    self.completeTick.alpha = 0.0
                    
                }) { (finished: Bool) in
                    
                    self.completeTick.isHidden = true
                }
                
            }
            self.activityWait.stopAnimating()
            //self.completeTick.isHidden = true
        })
    }
    @IBAction func backToPrevious(_ sender: Any) {
        activeTasks[taskIndex].complete = true
        if let delegate = delegate{
            delegate.updateEvent(activeEvents: activeTasks)
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func nextTask(_ sender: Any) {

        if (taskIndex < activeTasks.count-1) {
            taskIndex = taskIndex + 1
        }
    }
    @IBOutlet weak var Debuggingop: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Activity wait indicator
        //self.activityWait.hidesWhenStopped = true
        self.completeTick.isHidden = true
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
        self.reset()
        // to slow down processing only activated on button press
        self.captureNextFrameForCV = true
        //status = UIColor.red
    
        //testDatabase()
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
                self.updateCameraPose(frame: frame)
                //status = self.ValidateScene()
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
            // Barcode detection function
            //detectBarcode(pixelbffer: pixelBuffer)

            //Pixelbuffer is a rectified image. Instrinsics provides a transform from 2d camera space to 3d world coordinate space
            // Create a new frame struct for detection
            var newframe = OpenCVWrapper.arucodetect(pixelBuffer, withIntrinsics: frame.camera.intrinsics, andMarkerSize: Float64(MARKER_SIZE_IN_METERS))
            // Save the transform from camera to world space
            newframe.cameratransform = frame.camera.transform
            //quick break
            if(newframe.no_markers == 0) {
                self.Debuggingop.text = "no marker found. Keep looking."
                return;
            }
            
            self.visibleObjectIds.removeAll()
            self.visibleObjectPos.removeAll()
            // Copy the found markers in via a tuple due to Cpp conversion
            let tempTuple = TupletoArray(tuple: newframe.ids).array
            let tempNumber = String(newframe.no_markers)
            let tempIntNumber = Int(tempNumber)

            if(tempIntNumber != nil){
                visibleObjectIds = Array(tempTuple.prefix(tempIntNumber!))
            }
        
            // Copy the transform matrix to the master
            visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.0.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
            visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.1.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
            visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.2.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
            visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.3.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
            visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.4.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
            visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.5.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
            visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.6.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
            visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.7.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
            visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.8.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
            visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.9.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
            
            
            // IF a marker is found: transform in the main queue
            
            if(self.isLocalized == false){
                    DispatchQueue.main.async {
                    self.targTransform = self.visibleObjectPos.first!
                    self.updateContentNode(targTransform: self.targTransform, markerid: Int(newframe.ids.0))
                return
            }
            }
            
        }
        self.Debuggingop.text = currentstatus
        return
    }
    
    
    private func updateContentNode(targTransform: SCNMatrix4, markerid: Int) {
        //Basic error check before rendering
        
        /*if self.isLocalized {
            // Is there already a localised content node? Destroy it:
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode() }}*/
       
            localizedContentNode.opacity = 0.5
            localizedContentNode.transform = targTransform // apply new transform to node

            // Calculate the centre of the tray and make child of marker
            //var clean_centre = TrayAnchor()
            TrayCentrepoint = loadedtray.TrayCentreNode()
            
            // Get the offset to the centre of the tray
                localizedContentNode.addChildNode(TrayCentrepoint)
                TrayCentrepoint.position = loadedtray.CentrePoint(withid: markerid)
                sceneView.scene.rootNode.addChildNode(localizedContentNode);
            self.isLocalized = true
        }
        
        func renderer(_ renderer: SCNSceneRenderer,
                               nodeFor anchor: ARAnchor) -> SCNNode?{
            return SCNNode()
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
            return false
        }
        
        return true
    }
    
    //
    
    func validateTask(task: inout Task){
        var validatedStates = [validationState]()
        // Check validation needs to occur
        if (task.validation == nil) || (isLocalized == false) {
            print("No validation requirement attached to task or not yet localised")
            return
        }
        // Check validation for each object in turn
        for object in task.objects {
            // Add the result of each object validation to the array
            validatedStates.append(validateObject(object: object)!)
        }
        // Record the validation state back against the task
        task.validation?.objectStates = validatedStates
        return
    }
    
    
    // Validates an object relative to the current scene
    func validateObject(object: Object) -> validationState?{
        
        // is the object already aligned? Assumed that once validated not checked again
        if(self.ObjectsPlacedDone.contains(object.object_marker.id)){
            return validationState.aligned
        }
        // Is the object present in the view?
        if(self.visibleObjectIds.contains(Int32(object.object_marker.id))){
            // array position of the visible object
            let position = self.visibleObjectIds.firstIndex(of: Int32(object.object_marker.id))!
            
            let relative_position = SCNNode()
            let object_position = SCNNode()
            
            object_position.transform = visibleObjectPos[position]
            // Node for position analysis
            relative_position.transform = SCNMatrix4Mult(SCNMatrix4Invert(targTransform),object_position.transform)
            // Print position analysis for debugging
            NodeToBoardPosition(Quaternion: relative_position.orientation)
            // If the object is correctly aligned:
            if(ObjectOrientatedToTray(Quaternion: relative_position.orientation)){
                // record as placed
                self.ObjectsPlacedDone.append(object.object_marker.id)
                return validationState.aligned
            }
            // Need to have method in here for working out rotation
            return validationState.misaligned
        }
        return validationState.misaligned
    }
    
    func reset(){
        
        // Is there already a localised content node? Destroy it:
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode() }
        
        self.targTransform = SCNMatrix4()
        
        self.localizedContentNode = SCNNode(geometry: SCNBox(width: 0.01, height: 0.005, length: 0.01, chamferRadius: 0))
        self.TrayCentrepoint = SCNNode()
        self.isLocalized = false
        
        
        self.captureNextFrameForCV = false; //when set to true, frame is processed by opencv for marker
        
        self.status_0 = UIColor.red
        self.status_1 = UIColor.red
        self.status_2 = UIColor.red
        
        // validation poperties
        
        self.visibleObjectIds = [Int32]()
        self.visibleObjectPos = [SCNMatrix4]()
        self.ObjectsPlacedDone = [Int]()
    }
    
    // debugging function
    func NodeToBoardPosition(Quaternion: SCNQuaternion){
        
        if(Quaternion.w > 0.9 && Quaternion.y < 0.1){
            print("^^") // aligned
            return
        }
        if(Quaternion.w < 0.75 && Quaternion.y < -0.6){
            print("->")
            return
        }
        if(Quaternion.w < 0.1 && Quaternion.y > 0.9){
            print("||") // 180 degrees misaligned
            return
        }
        if(Quaternion.w > 0.7 && Quaternion.y > 0.7){
            print("<-")
            return
        }
        
        print(" ? ? ?")
        return
        
    }
    
    func ObjectOrientatedToTray(Quaternion: SCNQuaternion) -> Bool{
        

        // working on w and y axis
        if(Quaternion.w > 0.9 && Quaternion.y < 0.1){
            return true
        }
        
        return false
    }
    
    func AllObjectsValidated(currentTask: Task) -> Bool{
        return true
    }
    
    func RenderNode() -> SCNNode{
        // If there is nothing to render don't
        if activeTasks[taskIndex].objects.count == 0 {
            return SCNNode()
        }
        
        let asset_name = activeTasks[taskIndex].objects.first?.file_name as! String

        var node1 = SCNNode(geometry: SCNPyramid(width: 0.1, height: 0.1, length: 0.1))
        
        // Try to load the node assets from the scene
        if let assetScene = SCNScene(named: activeTasks[taskIndex].objects.first?.parent_scene as! String) {
            print("Loaded scene assets")
            
            if let l_node = assetScene.rootNode.childNode(withName: asset_name, recursively: true) {
                print("Loaded scene node")
                let anchor = ARAnchor(transform: simd_float4x4(targTransform))
                sceneView.session.add(anchor:anchor)
                l_node.transform = TrayCentrepoint.transform
                node1 = l_node
                node1.eulerAngles = activeTasks[taskIndex].objects.first?.apply_rotation as! SCNVector3
                
            }
            
        }
        return node1
    }
    
 
    

    
    }

