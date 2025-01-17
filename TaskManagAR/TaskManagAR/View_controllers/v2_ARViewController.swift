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
import CoreVideo

//let MARKER_SIZE_IN_METERS : CGFloat = 0.0282; //set this to size of physically med marker in meters

protocol DisplayViewController2Delegate : NSObjectProtocol{
    func updateEvent(activeEvents: [Task])
}

class ARViewController2: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    weak var delegate : DisplayViewControllerDelegate?
    var detectionQueue = DispatchQueue(label: "detection", qos: .default, autoreleaseFrequency: .workItem)
    
    // UI interface for marker detection work
    @IBOutlet weak var completeTick: UIImageView!
    @IBOutlet weak var findMarkerLayer: UIImageView!
    @IBOutlet weak var markerFound1: UIImageView!
    @IBOutlet weak var markerFound2: UIImageView!
    @IBOutlet weak var markerFound3: UIImageView!
    
    // All the tasks in the set - this allows progression backwards and forwards
    var activeTasks = [Task()]
    var currentTask = Task()
    // instructions
    var vc = InstructionViewController()
    // The index of the current task
    var taskIndex = Int()
    // Localised nodes for this session based on marker target transformation
    private var localizedContentNode = SCNNode()
    // localsed from the space
    private var TrayCentrepoint = SCNNode()
    // status variables
    private var isLocalized = false
    private var captureNextFrameForCV = true; //when set to true, frame is processed by opencv for marker
    private var dispatchProcesscomplete = true; //for threading main que
    // Framerate limiting and localisations settings
    private var frameCounter = 0
    private var MarkerframeRate = 3 // runs every n frames
    private var NumberofMarkersFound = 0 // Total for a confidence level on the scene
    private var ConfirmationMarkerLevel = 18 // how many times do I need to markers?
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
    private var visibleSpaceIds = [Int32]()
    private var visibleSpacePos = [SCNMatrix4]()
    // Space localisation
    private var visibleSpaceTarget = [SCNVector3]()
    // Activity indicator for the validation process
    @IBOutlet weak var activityWait: UIActivityIndicatorView!
    // Validation class object
    let valid = Validator()
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
    
    
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    
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
        
        // render based on task
        let node0 = RenderNode() // returns the model within the task as a node
        node0.position = SCNVector3(0.15, 0, activeTasks[taskIndex].objects.first?.height as! Float)
        TrayCentrepoint.addChildNode(node0)
        
        
        
    }
    
    // function called on validate request from user
    @IBAction func Validate(_ sender: Any) {
        //self.segue() //debugging
        // if not ready return
        if(isLocalized == false) || (self.activeTasks[self.taskIndex].validation == nil){
            print("Not localised or no validation available for this task")
            return
        }
        // capture a frame
        self.activityWait.startAnimating()
        self.validateTask(task: &self.activeTasks[self.taskIndex])
        //self.captureNextFrameForCV = true
        // check whether the ID is present & orientation
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // pass by reference
            if self.valid.AllObjectsValidated(currentTask: self.activeTasks[self.taskIndex]){
                // Check the task as complete
                self.activeTasks[self.taskIndex].complete = true
                self.completeTick.isHidden = false
                self.completeTick.alpha = 1.0
                // Fade the tick
                UIView.animate(withDuration: 1.5, delay: 1.5, options: [], animations: {
                    self.completeTick.alpha = 0.0
                }) { (finished: Bool) in
                    self.completeTick.isHidden = true
                }
            }
            self.activityWait.stopAnimating()
        })
    }
    // function called on back request (unwind segue)
    @IBAction func backToPrevious(_ sender: Any) {
        if let delegate = delegate{
            delegate.updateEvent(activeEvents: activeTasks)
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func nextTask(_ sender: Any) {
        
        if (taskIndex < activeTasks.count-1) {
            taskIndex = taskIndex + 1
            // Load in current space
            //buttonloadmodel(self)
        }
        
    }
    @IBOutlet weak var Debuggingop: UILabel!
    
    
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    
    @IBAction func pressed(_ sender: Any) {
        //self.reset()
        // to slow down processing only activated on button press
        //self.captureNextFrameForCV = true
        
        //testDatabase()
    }
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        self.sceneView.scene.rootNode.addChildNode(getLightNode())
        
        // Hide the completion tick
        self.completeTick.isHidden = true
        //self.findMarkerLayer.isHidden = false
        self.findMarkerLayer.alpha = 0.7
        self.currentTask = activeTasks[taskIndex]
        // Limit FPS
        //sceneView.preferredFramesPerSecond = 30
        Debuggingop.text = "localising"
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        if (sceneView.session.currentFrame != nil){
            updateCameraPose(frame: sceneView.session.currentFrame!)
        }
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [.showWireframe, .showBoundingBoxes, .showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration and apply debug options
        reset()
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
        
        // This should probably only be called when a plane is detected?
        if (self.frameCounter % self.MarkerframeRate == 0 && isLocalized == true)
        {
            detectionQueue.sync {
                self.updateCameraPose(frame: frame)
            }
        }
        self.frameCounter = self.frameCounter + 1
    }
    
    
    // Main calling functiondelay: updates pose and id array from passed frame
    func updateCameraPose(frame: ARFrame) {
        
        // Current status contains a string as to the tracking status of the world
        let currentstatus = sessionStatus(frame: frame)
        
        // If ready go ahead and pass
        if (currentstatus == "") {
            let pixelBuffer = frame.capturedImage
            
            // Create a new frame struct for detection
            var newframe = OpenCVWrapper.arucodetect(pixelBuffer, withIntrinsics: frame.camera.intrinsics, andMarkerSize: Float64(activeTasks[taskIndex].space.marker_height_m))
            // Save the transform from camera to world space
            newframe.cameratransform = frame.camera.transform
            //quick break
            if(newframe.no_markers == 0) {
                return;
            }
            
            self.visibleObjectIds.removeAll()
            self.visibleObjectPos.removeAll()
            // Copy the found markers in via a tuple due to Cpp conversion
            let tempTuple = TupletoArray(tuple: newframe.ids).array
            
            let tempNumber = String(newframe.no_markers)
            let tempIntNumber = Int(tempNumber)
            
            if(tempIntNumber != nil){
                self.visibleObjectIds = Array(tempTuple.prefix(tempIntNumber!))
                
                print(self.visibleObjectIds)
                
                // Copy the transform matrix to the master // note can only track 9 markers in a scene at once
                self.visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.0.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
                self.visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.1.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
                self.visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.2.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
                self.visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.3.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
                self.visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.4.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
                self.visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.5.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
                self.visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.6.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
                self.visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.7.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
                self.visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.8.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
                self.visibleObjectPos.append(SCNMatrix4Mult(newframe.all_extrinsics.9.extrinsics, SCNMatrix4.init(newframe.cameratransform)))
                
            }
            
            
            
            // Is this a first localisation? Can a space marker be seen in shot?
            if(self.isLocalized == false && frameIncludesSpaceMarker() ){
                
                var id = self.visibleObjectIds.first!
                if self.isSpaceMarker(id: id){
                    
                    if !(self.visibleSpaceIds.contains(id)){
                        self.visibleSpaceIds.append(id)
                    }
                    
                    self.targTransform = self.visibleObjectPos.first!
                    // create a localised tray at the first location found:
                    
                    self.updateContentNode(targTransform: self.targTransform, markerid: Int(id))
                    
                }
            }
            
            self.dispatchProcesscomplete = true
            return
            
        }
    }
    
    // is a space localisation marker in shot?
    private func frameIncludesSpaceMarker() -> Bool {
        for id in self.visibleObjectIds{
            if isSpaceMarker(id: id){return true}
        }
        return false
    }
    
    private func isSpaceMarker(id: Int32) -> Bool {
        
        if id == self.currentTask.space.boom_id || id == self.currentTask.space.datum_id || id == self.currentTask.space.boom_face_id || id == self.currentTask.space.datum_face_id{
            return true
            
        }
        return false
    }
    
    
    private func updateContentNode(targTransform: SCNMatrix4, markerid: Int) {
        localizedContentNode.opacity = 0.5
        localizedContentNode.transform = targTransform // apply new transform to node
        // Calculate the centre of the tray and make child of marker
        
        
        var marker = SCNNode()
        var node = SCNNode()
        
        marker.transform = targTransform
        var box = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        box.materials = [material]
        
        marker.addChildNode(node)
        node.position = loadedtray.CentrePoint(withid: markerid, task: self.currentTask)
        self.sceneView.scene.rootNode.addChildNode(marker)
        
        var transform = simd_float4x4(node.worldTransform)
        
        self.visibleSpaceTarget.append(SCNVector3(transform.columns.3.x,transform.columns.3.y,transform.columns.3.z))
        
        
        if (self.visibleSpaceTarget.count > 10) {
            
            // find the total distance between the current and last 4 points and add them together
            var variance =
                
                SCNVector3.distanceFrom(vector: self.visibleSpaceTarget[self.visibleSpaceTarget.count-2], toVector: self.visibleSpaceTarget[self.visibleSpaceTarget.count-1])
                    
                    +
                    
                    SCNVector3.distanceFrom(vector: self.visibleSpaceTarget[self.visibleSpaceTarget.count-3], toVector: self.visibleSpaceTarget[self.visibleSpaceTarget.count-1])
                    
                    +
                    
                    SCNVector3.distanceFrom(vector: self.visibleSpaceTarget[self.visibleSpaceTarget.count-4], toVector: self.visibleSpaceTarget[self.visibleSpaceTarget.count-1])
            
            // if variance is less than 10mm :
            if variance < 0.01{
                self.NumberofMarkersFound = self.NumberofMarkersFound + 1
                // original marker position is good
                self.localizedContentNode.transform = marker.transform
            }
        }
        
        TrayCentrepoint = loadedtray.TrayCentreNode()
        localizedContentNode.addChildNode(TrayCentrepoint)
        TrayCentrepoint.position = loadedtray.CentrePoint(withid: markerid, task: self.currentTask)
        
        self.activityWait.startAnimating()
        
        if (self.NumberofMarkersFound >= self.ConfirmationMarkerLevel/3){
            self.markerFound1.isHidden = false
        }
        
        if (self.NumberofMarkersFound >= self.ConfirmationMarkerLevel/2){
            self.markerFound2.isHidden = false
        }
        
        if (self.NumberofMarkersFound >= (self.ConfirmationMarkerLevel/2 + self.ConfirmationMarkerLevel/4)){
            self.markerFound3.isHidden = false
        }
        
        if self.NumberofMarkersFound >= self.ConfirmationMarkerLevel && (self.visibleSpaceIds.count > 1)
        {
            
            sceneView.scene.rootNode.addChildNode(localizedContentNode)
            self.activityWait.stopAnimating()
            // Fade the UI
            DispatchQueue.main.async{
                UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                    self.findMarkerLayer.alpha = 0.0
                    self.markerFound1.alpha = 0.0
                    self.markerFound2.alpha = 0.0
                    self.markerFound3.alpha = 0.0
                    
                }) { (finished: Bool) in
                    self.findMarkerLayer.isHidden = true
                    self.markerFound1.isHidden = true
                    self.markerFound2.isHidden = true
                    self.markerFound3.isHidden = true
                }
            }
            self.isLocalized = true
            // load the model
            //self.buttonloadmodel(self)
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {
            
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.8
            
            /*
             `SCNPlane` is vertically oriented in its local coordinate space, but
             `ARImageAnchor` assumes the image is horizontal in its local space, so
             rotate the plane to match.
             */
            planeNode.eulerAngles.x = -.pi / 2
            
            //self.targTransform = planeNode.transform
            //self.updateContentNode(targTransform: self.targTransform, markerid: Int(0))
            
            // Add the plane visualization to the scene.
            print("target detected")
            
            
            self.isLocalized = true
            self.TrayCentrepoint = self.loadedtray.TrayCentreNode()
            
            planeNode.addChildNode(self.TrayCentrepoint)
            
            self.TrayCentrepoint.position = self.loadedtray.CentrePoint(withid: 0, task: self.currentTask)
            
            node.addChildNode(planeNode)
        }
        
    }
    
    func validateTask(task: inout Task){
        var validatedStates = [validationState]()
        // Check validation needs to occur
        if (task.validation == nil) {
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
        
        // need to create copies to prevent issues with frame sync
        
        var cpy_visibleObjectIds = self.visibleObjectIds
        var cpy_visibleObjectPos = self.visibleObjectPos
        
        // is the object already aligned? Assumed that once validated not checked again
        if(self.ObjectsPlacedDone.contains(object.object_marker.id)){
            return validationState.aligned
        }
        
        
        if(cpy_visibleObjectIds.contains(Int32(object.object_marker.id))){
            // array position of the visible object
            let position = cpy_visibleObjectIds.firstIndex(of: Int32(object.object_marker.id))!
            
            let object_position = SCNNode()
            var direction_line = SCNNode()
            
            object_position.name = "object_position" + String(object.object_marker.id)
            direction_line.name = "direction_line" + String(object.object_marker.id)
            
            // remove prevoius instruction
            sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                if (node.name == object_position.name || node.name == direction_line.name) {
                    node.removeFromParentNode()
                }
            }
            
            sceneView.scene.rootNode.addChildNode(object_position)
            object_position.transform = cpy_visibleObjectPos[position]
            sceneView.scene.rootNode.addChildNode(direction_line)
            direction_line.geometry = addLineBetween(start: object_position.worldPosition, end: TrayCentrepoint.worldPosition)
            
            return valid.nodeTonodePath(candidate: object_position, target: TrayCentrepoint, object: object)
        }
        return validationState.not_visible
    }
    
    
    func eulerToDegrees(euler: Float) -> Float{
        var euler_deg = euler * 180 / Float.pi
        if( euler_deg < 0 ){
            euler_deg = euler_deg + 360.0
        }
        return euler_deg
    }
    
    
    
    
    func reset(){
        
        resetTracking()
        
        // Is there already a localised content node? Destroy it:
        
        self.NumberofMarkersFound = 0
        self.isLocalized = false
        self.captureNextFrameForCV = false
        
        // validation poperties
        self.visibleObjectIds.removeAll()
        self.visibleObjectPos.removeAll()
        self.ObjectsPlacedDone.removeAll()
    }
    
    func resetTracking() {
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        sceneView.debugOptions = [ ARSCNDebugOptions.showFeaturePoints ]
        
        let configuration = ARWorldTrackingConfiguration()
        
        // Create a session configuration and apply debug options
        configuration.planeDetection = .horizontal
        configuration.maximumNumberOfTrackedImages = 0
        configuration.detectionImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    
    
    func RenderNode() -> SCNNode{
        // If there is nothing to render don't
        if activeTasks[taskIndex].objects.count == 0 {
            return SCNNode()
        }
        
        let asset_name = activeTasks[taskIndex].objects.first?.file_name as! String
        
        var node1 = SCNNode()
        
        // Try to load the node assets from the scene
        if let assetScene = SCNScene(named: activeTasks[taskIndex].objects.first?.parent_scene as! String) {
            
            
            if let l_node = assetScene.rootNode.childNode(withName: asset_name, recursively: true) {
                
                let anchor = ARAnchor(transform: simd_float4x4(targTransform))
                sceneView.session.add(anchor:anchor)
                l_node.transform = TrayCentrepoint.transform
                node1 = l_node
                node1.eulerAngles = activeTasks[taskIndex].objects.first?.apply_rotation as! SCNVector3
                
                // scale using object properties
                
                node1.scale = activeTasks[taskIndex].objects.first?.scale as! SCNVector3
                
                
                // add lighting *todo make this ambient based on lighting sensor
                
                //addLightNodeTo(node1)
            }
            
        }
        return node1
    }
    
    func addLineBetween(start: SCNVector3, end: SCNVector3) -> SCNGeometry {
        let lineGeometry = SCNGeometry.lineFrom(vector: start, toVector: end)
        
        return lineGeometry
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is InstructionViewController
        {
            self.vc = segue.destination as! InstructionViewController
            // pass over all the tasks and the reference to the one selected
            //vc?.delegate = self
            
            self.vc.activeTask = activeTasks[taskIndex]
        }
    }
    
    
    // method to run when table view cell is tapped
    func segue (){
        // Segue to the second view controller after updating
        vc.activeTask = activeTasks[taskIndex]
        vc.update()
        self.performSegue(withIdentifier: "showInstruction", sender: self)
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("shaken")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

