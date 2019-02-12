//
//  OpenCvWrapper.m
//  throwaway-arucotest
//
//  Created by Thomas Bale on 18/12/2018.
//  Copyright © 2018 Thomas Bale. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/core.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/imgproc.hpp>
#include "opencv2/aruco.hpp"
#include "opencv2/aruco/dictionary.hpp"

#import <opencv2/imgcodecs/ios.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <CoreVideo/CoreVideo.h>
#include <opencv2/opencv.hpp>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <vector>
#include <sys/time.h>

#include  "OpenCVWrapper.h"
 #include "CVUtils.h"

@implementation OpenCVWrapper

//static vImage_Buffer dest_buffer = {NULL, 0, 0, 0};

// Utility function to check CV version number useful to error check headers
+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

// Returns ARUCO marker for id requested using specified dict
+(UIImage*) getMarkerForId:(int)id {
    cv::Mat markerImage;
    cv::Ptr<cv::aruco::Dictionary> dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_ARUCO_ORIGINAL);
    cv::aruco::drawMarker(dictionary, id, 400, markerImage);
    UIImage *finalImage = MatToUIImage(markerImage);
    return finalImage;
}

// Note that in openCV z goes away the camera (in openGL goes into the camera)
// and y points down and on openGL point up
+(cv::Mat) GetCVToGLMat {
    cv::Mat cvToGL = cv::Mat::zeros(4,4,CV_64FC1);
    cvToGL.at<double>(0,0) = 1.0f;
    //
    cvToGL.at<double>(1,1) = -1.0f; //invert y
    cvToGL.at<double>(2,2) = -1.0f; //invert z
    
    cvToGL.at<double>(3,3) = 1.0f;
    return cvToGL;
}

+(SCNMatrix4) transformToSceneKitMatrix:(cv::Mat&) openCVTransformation {
    SCNMatrix4 mat = SCNMatrix4Identity;
    
    //initialisation with zero out values - might not be necessary
    openCVTransformation = openCVTransformation.t();
    mat.m11 = (float) 0.0;
    mat.m12 = (float) 0.0;
    mat.m13 = (float) 0.0;
    // copy the shear
    mat.m14 = (float) 0.0;
    //copy the rotationRows
    mat.m21 = (float) 0.0;
    mat.m22 = (float) 0.0;
    mat.m23 = (float) 0.0;
    // copy the shear
    mat.m24 = (float) 0.0;
    //copy the rotationRows
    mat.m31 = (float) 0.0;
    mat.m32 = (float) 0.0;
    mat.m33 = (float) 0.0;
    // copy the shear
    mat.m34 = (float) 0.0;
    //copy the translation rows
    mat.m41 = (float) 0.0;
    mat.m42 = (float) 0.0;
    mat.m43 = (float) 0.0;
    mat.m44 = (float) 0.0;
    
    
    // copy the rotationRows
    mat.m11 = (float) openCVTransformation.at<double>(0, 0);
    mat.m12 = (float) openCVTransformation.at<double>(0, 1);
    mat.m13 = (float) openCVTransformation.at<double>(0, 2);
    // copy the shear
    mat.m14 = (float) openCVTransformation.at<double>(0, 3);
    //copy the rotationRows
    mat.m21 = (float)openCVTransformation.at<double>(1, 0);
    mat.m22 = (float)openCVTransformation.at<double>(1, 1);
    mat.m23 = (float)openCVTransformation.at<double>(1, 2);
    // copy the shear
    mat.m24 = (float)openCVTransformation.at<double>(1, 3);
    //copy the rotationRows
    mat.m31 = (float)openCVTransformation.at<double>(2, 0);
    mat.m32 = (float)openCVTransformation.at<double>(2, 1);
    mat.m33 = (float)openCVTransformation.at<double>(2, 2);
    // copy the shear
    mat.m34 = (float)openCVTransformation.at<double>(2, 3);
    //copy the translation rows
    mat.m41 = (float)openCVTransformation.at<double>(3, 0);
    mat.m42 = (float)openCVTransformation.at<double>(3, 1);
    mat.m43 = (float)openCVTransformation.at<double>(3, 2);
    mat.m44 = (float)openCVTransformation.at<double>(3, 3);
    
    
    return mat;
    
}

/// edited function which is called

+ (struct FrameCall) arucodetect:(CVPixelBufferRef)pixelBuffer withIntrinsics:(matrix_float3x3)intrinsics andMarkerSize:(Float64)markerSize{
    
    // Create a new struct
    struct FrameCall frame;
    frame.pixelBuffer = pixelBuffer;
    frame.intrinsics = intrinsics;
    frame.markerSize = markerSize;
    
    /*[OpenCVWrapper transformMatrixFromPixelBuffer:frame.pixelBuffer withIntrinsics:frame.intrinsics andMarkerSize:frame.markerSize];
    */
    
    cv::Mat intrinMat(3,3,CV_64FC1);
    cv::Mat distMat(3,3,CV_64FC1);
    
    intrinMat.at<Float64>(0,0) = intrinsics.columns[0][0];
    intrinMat.at<Float64>(0,1) = intrinsics.columns[1][0];
    intrinMat.at<Float64>(0,2) = intrinsics.columns[2][0];
    intrinMat.at<Float64>(1,0) = intrinsics.columns[0][1];
    intrinMat.at<Float64>(1,1) = intrinsics.columns[1][1];
    intrinMat.at<Float64>(1,2) = intrinsics.columns[2][1];
    intrinMat.at<Float64>(2,0) = intrinsics.columns[0][2];
    intrinMat.at<Float64>(2,1) = intrinsics.columns[1][2];
    intrinMat.at<Float64>(2,2) = intrinsics.columns[2][2];

    
    distMat.at<Float64>(0,0) = 0;
    distMat.at<Float64>(0,1) = 0;
    distMat.at<Float64>(0,2) = 0;
    distMat.at<Float64>(0,3) = 0;
    
    cv::Ptr<cv::aruco::Dictionary> dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_ARUCO_ORIGINAL);
    
    // The first plane / channel (at index 0) is the grayscale plane
    // See more infomation about the YUV format
    // http://en.wikipedia.org/wiki/YUV
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseaddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    CGFloat width = CVPixelBufferGetWidth(pixelBuffer);
    CGFloat height = CVPixelBufferGetHeight(pixelBuffer);
    cv::Mat mat(height, width, CV_8UC1, baseaddress, 0); //CV_8UC1
    
    std::vector<int> ids;
    std::vector<std::vector<cv::Point2f>> corners;
    cv::aruco::detectMarkers(mat,dictionary,corners,ids);
    
    frame.no_markers = 0;
    
    //Todo : somehow handle situation with multiple markers - interim solution only grab the last item in the list
    if(ids.size() > 0 && ids.size() < 10) {
        
        frame.no_markers = (int)ids.size();
        int i;
        for( i = 0; i < frame.no_markers; i++) {
            frame.ids[i] = (double)ids[i];
            
            std::vector<cv::Vec3d> rvecs, tvecs;
            cv::Mat distCoeffs = cv::Mat::zeros(8, 1, CV_64FC1); //zero out distortion for now
            cv::aruco::estimatePoseSingleMarkers(corners, markerSize, intrinMat, distCoeffs, rvecs, tvecs);
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
            
            // Need to consider an efficient approach as removing first element is inefficient
            cv::Mat rotMat, tranMat;
            
            cv::Rodrigues(rvecs[i], rotMat); //convert results rotation matrix
            
            
            cv::Mat extrinsics(4, 4, CV_64FC1);
            
            // Apply identity matrix before setting values .
            
            extrinsics.at<double>(3,3) = 1.0f;
            extrinsics.at<double>(3,2) = 0.0f;
            extrinsics.at<double>(3,1) = 0.0f;
            extrinsics.at<double>(3,0) = 0.0f;
            
            extrinsics.at<double>(2,3) = 0.0f;
            extrinsics.at<double>(2,2) = 1.0f;
            extrinsics.at<double>(2,1) = 0.0f;
            extrinsics.at<double>(2,0) = 0.0f;
            
            extrinsics.at<double>(1,3) = 0.0f;
            extrinsics.at<double>(1,2) = 0.0f;
            extrinsics.at<double>(1,1) = 1.0f;
            extrinsics.at<double>(1,0) = 0.0f;
            
            extrinsics.at<double>(0,3) = 0.0f;
            extrinsics.at<double>(0,2) = 0.0f;
            extrinsics.at<double>(0,1) = 0.0f;
            extrinsics.at<double>(0,0) = 1.0f;
            
            for( int row = 0; row < rotMat.rows; row++) {
                for (int col = 0; col < rotMat.rows; col++) {
                    extrinsics.at<double>(row,col) = rotMat.at<double>(row,col); //copy rotation matrix values
                }
                extrinsics.at<double>(row,3) = tvecs[0][row];
                
            }
            
            //The important thing to remember about the extrinsic matrix is that it describes how the world is transformed relative to the camera. This is often counter-intuitive, because we usually want to specify how the camera is transformed relative to the world.
            // Convert coordinate systems of opencv to openGL (ARKIT)
            
            extrinsics = [OpenCVWrapper GetCVToGLMat] * extrinsics;
            
            frame.extrinsics = [OpenCVWrapper transformToSceneKitMatrix:extrinsics];
            
            frame.all_extrinsics[i] = FoundMarker();
            
            frame.all_extrinsics[i].extrinsics = frame.extrinsics;
            
        }
        

        
        return frame;
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return frame;
}


@end
