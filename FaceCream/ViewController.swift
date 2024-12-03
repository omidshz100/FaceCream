//
//  ViewController.swift
//  FaceCream
//
//  Created by Omid Shojaeian Zanjani on 03/12/24.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    func setupCamera() {
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No camera available")
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: camera) else {
            print("Cannot access camera input")
            return
        }
        
        captureSession.addInput(input)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(output)
        
        // Start the session on a background thread
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceLandmarksRequest { (request, error) in
            guard let observations = request.results as? [VNFaceObservation] else { return }
            DispatchQueue.main.async {
                self.view.layer.sublayers?.removeSubrange(1...)
                for face in observations {
                    self.highlightPoints(on: face)
                }
            }
        }
        
        // Define options for the Vision handler
           var options: [VNImageOption: Any] = [:]

           // Add camera intrinsics if available
           if let cameraIntrinsicData = CMGetAttachment(pixelBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
               options[.cameraIntrinsics] = cameraIntrinsicData
           }

           // Add custom metadata (optional)
           options[.properties] = [
               "PixelBufferType": CVPixelBufferGetPixelFormatType(pixelBuffer),
               "Width": CVPixelBufferGetWidth(pixelBuffer),
               "Height": CVPixelBufferGetHeight(pixelBuffer)
           ]
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: options)
        do {
            try handler.perform([request])
        } catch {
            print("Error performing Vision request: \(error.localizedDescription)")
        }

    }
    
    
    func highlightPoints(on faceObservation: VNFaceObservation) {
        guard let landmarks = faceObservation.landmarks else { return }

        // Get the face bounding box (relative to screen size)
        let boundingBox = faceObservation.boundingBox
        let faceRect = CGRect(
            x: boundingBox.minX * view.bounds.width,
            y: (1 - boundingBox.maxY) * view.bounds.height,
            width: boundingBox.width * view.bounds.width,
            height: boundingBox.height * view.bounds.height
        )

        // Draw rectangle around the face bounding box
            let boundingBoxLayer = CAShapeLayer()
            let boundingBoxPath = UIBezierPath(rect: faceRect)
            boundingBoxLayer.path = boundingBoxPath.cgPath
            boundingBoxLayer.strokeColor = UIColor.red.cgColor // Color of the rectangle
            boundingBoxLayer.lineWidth = 2.0
            boundingBoxLayer.fillColor = UIColor.clear.cgColor // No fill, only stroke
            view.layer.addSublayer(boundingBoxLayer)
        
        
        if let allPoints = landmarks.allPoints?.normalizedPoints {
            for (index, point) in allPoints.enumerated() {
                // Transform points to fit directly on the face bounding box
                let faceMappedPoint = CGPoint(
                    x: faceRect.origin.x + point.x * faceRect.width,
                    y: faceRect.origin.y + (1 - point.y) * faceRect.height
                )

                // Apply rotation (90 degrees clockwise)
                let rotatedPoint = CGPoint(
                    x: faceRect.origin.x + (1 - point.y) * faceRect.width,
                    y: faceRect.origin.y + point.x * faceRect.height
                )

                // Draw a small circle at each transformed and rotated landmark point
                let pointLayer = CAShapeLayer()
                let pointPath = UIBezierPath(
                    arcCenter: rotatedPoint,
                    radius: 3.0, // Adjust the radius for larger/smaller points
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true
                )
                pointLayer.path = pointPath.cgPath
                pointLayer.fillColor = UIColor.green.cgColor // Set the point color
                pointLayer.strokeColor = UIColor.clear.cgColor
                view.layer.addSublayer(pointLayer)

                // Add a label on top of each circle
                let label = UILabel()
                label.text = "\(index + 1)" // Number starts from 1
                label.textColor = .white
                label.font = UIFont.boldSystemFont(ofSize: 12)
                label.textAlignment = .center
                label.frame = CGRect(
                    x: rotatedPoint.x - 10, // Center the label horizontally
                    y: rotatedPoint.y - 20, // Position the label above the circle
                    width: 20,
                    height: 15
                )
                label.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Optional: Add background for better visibility
                label.layer.cornerRadius = 3
                label.clipsToBounds = true
                view.addSubview(label)
            }
        }
    }

    
    
    
    
//    func highlightPoints(on faceObservation: VNFaceObservation) {
//        guard let landmarks = faceObservation.landmarks else { return }
//
//        // Create a variable to count total landmarks
//        var totalPoints = 0
//
//        // Iterate over all points in the face landmarks
//        if let allPoints = landmarks.allPoints?.normalizedPoints {
//            totalPoints = allPoints.count // Count total points
//
//            for point in allPoints {
//                // Transform normalized points to screen space
//                let transformedPoint = CGPoint(
//                    x: point.x * view.bounds.width,
//                    y: (1 - point.y) * view.bounds.height
//                )
//                
//                // Draw a small circle at each landmark point
//                let pointLayer = CAShapeLayer()
//                let pointPath = UIBezierPath(
//                    arcCenter: transformedPoint,
//                    radius: 3.0, // Adjust the radius for larger/smaller points
//                    startAngle: 0,
//                    endAngle: CGFloat.pi * 2,
//                    clockwise: true
//                )
//                pointLayer.path = pointPath.cgPath
//                pointLayer.fillColor = UIColor.green.cgColor // Set the point color
//                pointLayer.strokeColor = UIColor.clear.cgColor
//                view.layer.addSublayer(pointLayer)
//            }
//        }
//
//        // Display the total number of landmarks on the screen
//        displayLandmarkCount(totalPoints)
//    }

    // Function to display the total number of landmarks
    func displayLandmarkCount(_ count: Int) {
        // Check if a label already exists and remove it
        if let existingLabel = view.viewWithTag(999) as? UILabel {
            existingLabel.removeFromSuperview()
        }

        // Create a new label
        let countLabel = UILabel()
        countLabel.tag = 999 // Set a unique tag to identify the label later
        countLabel.text = "Landmarks: \(count)"
        countLabel.textColor = .white
        countLabel.font = UIFont.boldSystemFont(ofSize: 16)
        countLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
        countLabel.textAlignment = .center
        countLabel.layer.cornerRadius = 8
        countLabel.clipsToBounds = true

        // Set the frame and position of the label
        countLabel.frame = CGRect(x: 10, y: 100, width: 150, height: 30) // Top-left corner
        view.addSubview(countLabel)
    }

    
    
    

}

