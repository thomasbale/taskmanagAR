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
