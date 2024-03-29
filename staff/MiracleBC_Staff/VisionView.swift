//
//  VisionView.swift
//  MiracleBC_Staff
//
//  Created by LEV POLYAKOV on 16.06.2019.
//  Copyright © 2019 Lev Polyakov. All rights reserved.
//

import SwiftUI
import VisionKit
import Vision
import AVFoundation

struct VisionView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<VisionView>) -> VisionViewController {
        let viewController = VisionViewController(nibName: nil, bundle: nil)
        viewController.coordinator = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VisionViewController, context: UIViewControllerRepresentableContext<VisionView>) {
        
    }
    
    typealias UIViewControllerType = VisionViewController
    
    @Binding var image: UIImage?
    @Binding var lastDate: Date?
    @Binding var skipFirstFrames: Int
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        
        var parent: VisionView
        var sequenceHandler = VNSequenceRequestHandler()
        var oldBuffer = [VNRequest: CMSampleBuffer]()
        init(_ visionView: VisionView) {
            self.parent = visionView
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            
            let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
            oldBuffer[detectFaceRequest] = sampleBuffer
            do {
                try sequenceHandler.perform(
                    [detectFaceRequest],
                    on: imageBuffer,
                    orientation: .left)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        func detectedFace(request: VNRequest, error: Error?) {
            guard let sampleBuffer = oldBuffer[request] else { return }
            oldBuffer[request] = nil
            guard
                let results = request.results as? [VNFaceObservation],
                let result = results.first
                else {
                    guard parent.lastDate?.timeIntervalSinceNow ?? 0 < -2 else { return }
                    DispatchQueue.main.async {
                        self.parent.image = nil
                    }
                    parent.lastDate = nil
                    parent.skipFirstFrames = 0
                    return
            }
            
            parent.skipFirstFrames += 1
            guard  parent.skipFirstFrames > 30, parent.image == nil else {
                return
            }
            print("Update face")
            guard let cvImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
            let ciImage = CIImage(cvImageBuffer: cvImageBuffer, options: attachments as! [CIImageOption : Any]?)
            let image = UIImage(ciImage: ciImage)
            let fullImage = UIImage(data: image.jpegData(compressionQuality: 0.8)!)!
 
            DispatchQueue.main.async {
                self.parent.image = fullImage                
            }
            parent.lastDate = Date()
        }
    }
}


class VisionViewController: UIViewController {
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var coordinator: VisionView.Coordinator?
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCaptureSession()
        session.startRunning()
    }
    
    func configureCaptureSession() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back) else {
                                                    fatalError("No front video camera available")
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(coordinator, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        session.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
}
