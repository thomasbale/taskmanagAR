//
//  OpenCvWrapper.h
//  throwaway-arucotest
//
//  Created by Thomas Bale on 18/12/2018.
//  Copyright © 2018 Thomas Bale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <simd/types.h>




typedef struct MarkerPose {
    bool found;
    SCNVector3 tvec;
    SCNVector3 rvec;
    SCNMatrix4 rotMat;
    int id;
} MarkerPose;

@interface OpenCVWrapper : NSObject

struct Matrix {
    // copy the rotationRows
    float matm11;
    float matm12;
    float matm13;
    // copy the shear
    float matm14;
    //copy the rotationRows
    float matm21;
    float matm22;
    float matm23;
    // copy the shear
    float matm24;
    //copy the rotationRows
    float matm31;
    float matm32;
    float matm33;
    // copy the shear
    float matm34;
    //copy the translation rows
    float matm41;
    float matm42;
    float matm43;
    float matm44;
};


struct FoundMarker {
    int id;
    SCNMatrix4 extrinsics;
    //struct Matrix _extrinsics;
    //struct simd_float4x4 extrinsics;
};


struct FrameCall {
    CVPixelBufferRef pixelBuffer;
    matrix_float3x3 intrinsics;
    Float64 markerSize;
    SCNMatrix4 rotation;
    simd_float4x4 cameratransform;
    struct FoundMarker all_extrinsics[10];
    int ids[10];
    int no_markers;
    // Need to have an array of all extrinsincs in here - to iterate through
};




+ (NSString *)openCVVersionString;
+ (SCNMatrix4) transformMatrixFromPixelBuffer:(CVPixelBufferRef)pixelBuffer withIntrinsics:(matrix_float3x3)intrinsics andMarkerSize:(Float64)markerSize;
+ (UIImage*) getMarkerForId:(int)id;
+ (struct FrameCall) arucodetect:(CVPixelBufferRef)pixelBuffer withIntrinsics:(matrix_float3x3)intrinsics andMarkerSize:(Float64)markerSize;

@end

