# Face Landmark Detection and Visualization

This project is an iOS application that uses Apple's Vision Framework to detect facial landmarks in real-time video from the camera. The app processes frames, identifies facial landmarks, and visualizes them on the screen with numbered points and a bounding box around the detected face.

## Features
- Real-time face detection using Vision Framework's `VNDetectFaceLandmarksRequest`.
- Draws green circles for facial landmarks and labels each with a number.
- Displays a red bounding box around the detected face.

## Known Issue
- **Landmark Alignment**: The current implementation has minor inaccuracies, and the drawing does not fully fit the detected face. This issue is especially noticeable when the face is rotated or angled.

## Requirements
- iOS 14.0 or later.
- Xcode 14 or later.
- A device with a camera (e.g., iPhone or iPad).

## Installation
1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/your-username/face-landmark-detection.git

2. Open the project in Xcode:
   ```bash
   open FaceLandmarkDetection.xcodeproj
   ```
3. Connect your iOS device to your computer.
4. Build and run the app on your device.

## How It Works
1. The app uses `AVFoundation` to capture video frames from the camera.
2. Each frame is processed using `VNImageRequestHandler` and `VNDetectFaceLandmarksRequest` from the Vision Framework.
3. Detected landmarks are:
   - Rotated by 90 degrees clockwise.
   - Drawn as green circles with numbers on the screen.
4. A red bounding box is drawn around the detected face for visualization.

## Code Highlights
### Face Detection
```swift
let request = VNDetectFaceLandmarksRequest { (request, error) in
    if let observations = request.results as? [VNFaceObservation] {
        DispatchQueue.main.async {
            for face in observations {
                self.highlightPoints(on: face)
            }
        }
    }
}
```

### Landmark Visualization
```swift
let rotatedPoint = CGPoint(
    x: faceRect.origin.x + (1 - point.y) * faceRect.width,
    y: faceRect.origin.y + point.x * faceRect.height
)
```

### Bounding Box
```swift
let boundingBoxPath = UIBezierPath(rect: faceRect)
boundingBoxLayer.path = boundingBoxPath.cgPath
```

## Known Limitations
1. Landmark alignment could be improved for better fitting to the face.
2. Detection accuracy decreases with extreme angles or partially obscured faces.

## Future Improvements
- Enhance landmark alignment for more precise visualization.
- Add 3D face tracking for better results in dynamic environments.
- Support dynamic orientation adjustments for video feeds.

## License
This project is open-source under the MIT License.

## Contributions
Contributions are welcome! Feel free to fork the repository, make changes, and submit a pull request.

```

---

### Steps to Use It on GitHub
1. Save this content in a file named `README.md` in your project directory.
2. Add the file to your repository and push it to GitHub:
   ```bash
   git add README.md
   git commit -m "Add README file"
   git push origin main
   ```
   
Now your repository will display this `README.md` as the main documentation on GitHub. Let me know if you need further assistance!
