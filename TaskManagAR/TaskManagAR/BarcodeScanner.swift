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

func detectBarcode(pixelbffer: CVPixelBuffer) {
    
    let image = CGImage.create(pixelBuffer: pixelbffer)!
    // Save foe debugging
    if let testingImage = UIImage(pixelBuffer: pixelbffer){
        if let data = testingImage.pngData() {
            let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
            try? data.write(to: filename)
        }
    }
    

    // Create a request handler.
    /*let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                    orientation: .up,
                                                    options: [:])*/
    
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelbffer, options: [:])

    let request = VNDetectBarcodesRequest()
    

    let request2 = VNDetectTextRectanglesRequest()

    var barcodeDetect: [VNRequest] = Array()

    barcodeDetect.append(request)
    barcodeDetect.append(request2)
    
    do {
        try imageRequestHandler.perform(barcodeDetect)
    } catch let error as NSError {
        print("Failed to perform image request: \(error)")
        return
    }
    
    guard let barcodes = request.results else {
        print("No barcodes found...")
        return
    }
    
    print(barcodes.count)
    handleBarcodes(request: request)

}

func handleBarcodes(request: VNRequest) {
    guard let observations = request.results as? [VNBarcodeObservation]
        else { fatalError("unexpected result type from VNBarcodeRequest") }
    guard observations.first != nil else {
        DispatchQueue.main.async {
            print("No barcode detected")

        }
        return
    }
    
    // Loop through the found results
    for result in request.results! {
        
        // Cast the result to a barcode-observation
        if let barcode = result as? VNBarcodeObservation {
            
            // Print barcode-values
            print("Symbology: \(barcode.symbology.rawValue)")
            
            if let desc = barcode.barcodeDescriptor as? CIQRCodeDescriptor {
                let content = String(data: desc.errorCorrectedPayload, encoding: .utf8)
                
                // FIXME: This currently returns nil. I did not find any docs on how to encode the data properly so far.
                print("Payload: \(String(describing: content))\n")
                print("Error-Correction-Level: \(desc.errorCorrectedPayload)\n")
                print("Symbol-Version: \(desc.symbolVersion)\n")
            }
        }
}
}

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        if let cgImage = cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
}
