//
//  utilities.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 28/02/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import Foundation

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
