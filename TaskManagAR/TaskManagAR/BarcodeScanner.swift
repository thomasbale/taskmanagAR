//
//  BarcodeScanner.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 11/03/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import Foundation
import VideoToolbox
import Vision

extension CGImage {
    /**
     Creates a new CGImage from a CVPixelBuffer.
     - Note: Not all CVPixelBuffer pixel formats support conversion into a
     CGImage-compatible pixel format.
     */
    public static func create(pixelBuffer: CVPixelBuffer) -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        return cgImage
    }
}

func detectBarcode(pixelbffer: CVPixelBuffer) -> String{
    
    // for testing
    /*
    if let testingImage = UIImage(pixelBuffer: pixelbffer){
        if let data = testingImage.pngData() {
            let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
            try? data.write(to: filename)
        }
    }
    */

    // Create a request handler.
    /*let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                    orientation: .up,
                                                    options: [:])*/
    var returnVal = ""
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelbffer, options: [:])
    let barcoderequest = VNDetectBarcodesRequest()
    
    barcoderequest.symbologies = [VNBarcodeSymbology.QR]
    var barcodeDetect: [VNRequest] = Array()
    barcodeDetect.append(barcoderequest)

    
    do {
        try imageRequestHandler.perform(barcodeDetect)
    } catch let error as NSError {
        print("Failed to perform image request: \(error)")
        return returnVal
    }
    
    returnVal = handleBarcodes(request: barcoderequest)
    return returnVal

}

func handleBarcodes(request: VNRequest) -> String {
    
    var barcodevalue = ""
    
    guard let observations = request.results as? [VNBarcodeObservation]
        else { fatalError("unexpected result type from VNBarcodeRequest") }
    guard observations.first != nil else {
        DispatchQueue.main.async {
            print("No barcode detected")

        }
        return barcodevalue
    }
    
    // Loop through the found results
    for result in request.results! {
        // Cast the result to a barcode-observation
        if let barcode = result as? VNBarcodeObservation {
            barcodevalue = barcode.payloadStringValue!
            
        }
}
    return barcodevalue
}
