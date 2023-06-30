//
//  Renderer.swift
//  Draw App
//
//  Created by Bogdan Redkin on 29/04/2023.
//

import Foundation
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    private var device: MTLDevice
    private var metalKitView: MTKView

    // The current size of the view, used as an input to the vertex shader.
    private var viewportSize: vector_uint2?

    // The command queue used to pass commands to the device.
    private var commandQueue: MTLCommandQueue?

    // The render pipeline generated from the vertex and fragment shaders in the .metal shader file.
    private var pipelineState: MTLRenderPipelineState?

    init?(metalKitView mtkView: MTKView) {
        self.device = MTLCreateSystemDefaultDevice()!
        mtkView.device = self.device
        mtkView.preferredFramesPerSecond = 120
        self.metalKitView = mtkView
        super.init()

        createRenderPipelineState()
        
        // Set MTKView background color to white
        metalKitView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        
        // Create the command queue
        commandQueue = device.makeCommandQueue()
        
        // Set MTKViewDelegate
        metalKitView.delegate = self
    }

    /// Create the render pipeline state for the point.
    private func createRenderPipelineState() {
        // Load all the shader files with a .metal file extension in the project.
        let defaultLibrary = device.makeDefaultLibrary()

        // Load functions from the library.
        let vertexFunction = defaultLibrary?.makeFunction(name: "pointShaderVertex")
        let fragmentFunction = defaultLibrary?.makeFunction(name: "pointShaderFragment")

        // Configure a pipeline descriptor that is used to create a pipeline state.
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.rasterSampleCount = metalKitView.sampleCount
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true

        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha

        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            // Pipeline State creation could fail if the pipeline descriptor isn't set up properly.
            //  If the Metal API validation is enabled, you can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode.)
            assert(pipelineState == nil, "Failed to create pipeline state: \(error)")
        }
    }

    /// Called whenever view changes orientation or is resized
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Scale size with contentScaleFactor to fit viewPort into the bounds of DrawingView
        let scale = view.contentScaleFactor
        let size = size * scale

        // Save the size of the drawable to pass to the vertex shader.
        viewportSize = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
    }

    /// Called whenever the view needs to render a frame.
    func draw(in view: MTKView) {
        guard
            let pipelineState,
            // Create a new command buffer for each render pass to the current drawable.
            let commandBuffer = commandQueue?.makeCommandBuffer(),
            // Obtain a renderPassDescriptor generated from the view's drawable textures
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            // Create a render command encoder.
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else { return }

        if let viewportSize, let points = (view as? DrawingView)?.points, !points.isEmpty {
            
            renderEncoder.setRenderPipelineState(pipelineState)
            
            // Set the region of the drawable to draw into.
            renderEncoder.setViewport(MTLViewport(
                originX: .zero,
                originY: .zero,
                width: Double(viewportSize.x),
                height: Double(viewportSize.y),
                znear: .zero,
                zfar: 1.0
            ))

            let pointsBuffer = device.makeBuffer(
                bytes: points,
                length: MemoryLayout<Point>.stride * points.count,
                options: .storageModeShared
            )
            // Pass in the parameter data.
            renderEncoder.setVertexBuffer(pointsBuffer, offset: 0, index: 0)
            
            // Draw the points primitives
            renderEncoder.drawPrimitives(type: .point, vertexStart: .zero, vertexCount: points.count)
        }
        renderEncoder.endEncoding()
        
        // Schedule a present once the framebuffer is complete using the current drawable.
        commandBuffer.present(view.currentDrawable!)
        
        // Finalize rendering here & push the command buffer to the GPU.
        commandBuffer.commit()
    }
}
