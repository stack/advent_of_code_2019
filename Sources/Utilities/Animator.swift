//
//  Animator.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2019-12-10.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import AVFoundation
import Foundation

public class Animator {

    public typealias DrawCallback = (CGContext) -> ()

    let width: Int
    let height: Int
    let frameRate: CMTime

    let writer: AVAssetWriter
    let writerInput: AVAssetWriterInput
    let writerAdaptor: AVAssetWriterInputPixelBufferAdaptor

    var currentFrameTime = CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

    /**
     Initialize a new Animator with the given dimensions and frame rate.

     - Parameter width: The width of the canvas that is presented when drawing.
     - Parameter height: The height of the canvas that is presented when drawing.
     - Parameter frameRate: Supplied as a ratio, the frame rate the video will be produced at. For example, to achieve 30 FPS, you would supply `1.0 / 30.0`.
     - Parameter url: The file URL to store the resulting video in.
     */
    public init(width: Int, height: Int, frameRate: Double, url: URL) {
        precondition(width % 16 == 0)
        precondition(height % 16 == 0)

        self.width = width
        self.height = height
        self.frameRate = CMTime(seconds: frameRate, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        if FileManager.default.fileExists(atPath: url.path) {
            try! FileManager.default.removeItem(at: url)
        }

        writer = try! AVAssetWriter(url: url, fileType: .mov)

        let videoSettings: [String:Any] = [
            AVVideoCodecKey: AVVideoCodecType.hevc,
            AVVideoWidthKey: NSNumber(value: width),
            AVVideoHeightKey: NSNumber(value:height),
        ]

        writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)

        let sourceAttributes: [String:Any] = [
            String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)
        ]

        writerAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourceAttributes)

        if writer.canAdd(writerInput) {
            writer.add(writerInput)
        } else {
            fatalError("Could not add writer input")
        }

        guard writer.startWriting() else {
            let message = writer.error?.localizedDescription ?? "UNKNOWN"
            fatalError("Could not start writing: \(message)")
        }

        writer.startSession(atSourceTime: currentFrameTime)
    }

    /**
     Finalize the video file.

     All submitted video frames will be drawn, encoded, and stored in the video file.

     Adding new frames after calling complete is unsupported.

     This call will block until the file writing has completed.
     */
    public func complete() {
        writerInput.markAsFinished()

        var complete = false

        writer.finishWriting {
            if self.writer.status == .failed {
                let message = self.writer.error?.localizedDescription ?? "UNKNOWN"
                print("Failed to finish writing: \(message)")
            }

            complete = true
        }

        while !complete {
            sleep(1)
        }
    }

    /**
     Retreive a new `CGContext` to draw in.

     Once the callback is complete, but provided context is submitted for encoding and writing.

     - Parameter callback: The function that provides the `CGContext` to draw and submit a frame.
     */
    public func draw(callback: DrawCallback) {
        guard let pool = writerAdaptor.pixelBufferPool else {
            fatalError("No pixel buffer pool to pull from")
        }

        var nextPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &nextPixelBuffer)

        guard let pixelBuffer = nextPixelBuffer else {
            fatalError("Failed to get next pixel buffer for drawing")
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let stride = CVPixelBufferGetBytesPerRow(pixelBuffer)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: stride, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue + CGBitmapInfo.byteOrder32Little.rawValue) else {
            fatalError("Failed to create context")
        }

        context.translateBy(x: 0.0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)

        callback(context)

        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

        while !writerInput.isReadyForMoreMediaData {
            Thread.sleep(forTimeInterval: 0.05)
        }

        writerAdaptor.append(pixelBuffer, withPresentationTime: currentFrameTime)
        currentFrameTime = CMTimeAdd(currentFrameTime, frameRate)
    }

}
