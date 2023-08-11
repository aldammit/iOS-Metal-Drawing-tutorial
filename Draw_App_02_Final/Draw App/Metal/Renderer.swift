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
    private var renderToTextureRenderPipeline: MTLRenderPipelineState?
    private var renderToTextureRenderPassDescriptor: MTLRenderPassDescriptor?
    private var currentLineTexture: MTLTexture?

    private var backgroundTexture: MTLTexture?
    private var compiledTexture: MTLTexture?
    private var erasedTexture: MTLTexture?
    private var computePipeline: MTLComputePipelineState?
    private var eraserComputePipeline: MTLComputePipelineState?
    
    var textureDescriptor: MTLTextureDescriptor?

    
    init?(metalKitView mtkView: MTKView) {
        self.device = MTLCreateSystemDefaultDevice()!
        mtkView.device = self.device
        mtkView.preferredFramesPerSecond = 120
//        mtkView.framebufferOnly = false
        self.metalKitView = mtkView
        super.init()

        createRenderPipelineState()
        
        // Set MTKView background color to white
        metalKitView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        
        // Create the command queue
        commandQueue = device.makeCommandQueue()
        
        // Set MTKViewDelegate
        metalKitView.delegate = self
        
        setupTexturesUpdate()
    }

    /// Create the render pipeline state for the point.
    private func createRenderPipelineState() {
        // Load all the shader files with a .metal file extension in the project.
        let defaultLibrary = device.makeDefaultLibrary()

        // Load functions from the library.
        let vertexFunction = defaultLibrary?.makeFunction(name: "textureVertexShader")
        let fragmentFunction = defaultLibrary?.makeFunction(name: "textureFragmentShader")

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
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha


        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            computePipeline = try device.makeComputePipelineState(function: defaultLibrary!.makeFunction(name: "alphaBlend")!)
            eraserComputePipeline = try device.makeComputePipelineState(function: defaultLibrary!.makeFunction(name: "maskingBlend")!)
        } catch {
            // Pipeline State creation could fail if the pipeline descriptor isn't set up properly.
            //  If the Metal API validation is enabled, you can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode.)
            assert(pipelineState == nil, "Failed to create pipeline state: \(error)")
        }
    }
    
    private func setupTexturesUpdate() {
        guard let drawingView = self.metalKitView as? DrawingView else { return }
         
        drawingView.drawBegin = { [weak self] in
            guard
                let self,
                let textureDescriptor = self.textureDescriptor
            else { return }

            if let newTextureDescriptor = textureDescriptor.copy() as? MTLTextureDescriptor {
                newTextureDescriptor.usage = [.shaderRead, .renderTarget, .shaderWrite]
                self.compiledTexture = self.device.makeTexture(descriptor: newTextureDescriptor)
                self.compiledTexture?.label = "compiled_texture"
            }
        }
        
        drawingView.clear = { [weak self] in
            guard
                let self,
                let drawingView = self.metalKitView as? DrawingView,
                let textureDescriptor = self.textureDescriptor
            else { return }
            drawingView.points.removeAll()
            self.backgroundTexture = self.makeWhiteTexture(label: "background_texture", descriptor: textureDescriptor)
            self.backgroundTexture?.label = "background_texture"
            
            self.currentLineTexture = self.device.makeTexture(descriptor: textureDescriptor)
            self.currentLineTexture?.label = "current_line_texture"
            self.renderToTextureRenderPassDescriptor?.colorAttachments[0].texture = self.currentLineTexture
            drawingView.drawBegin?()
        }

        drawingView.drawEnd = { [weak self] in
            guard
                let self,
                let drawingView = self.metalKitView as? DrawingView,
                let outputBackgroundTexture = self.backgroundTexture,
                let compiledTexture = self.compiledTexture,
                let textureDescriptor = self.textureDescriptor
            else { return }
            self.backgroundTexture = compiledTexture.makeTextureView(pixelFormat: outputBackgroundTexture.pixelFormat)
            self.backgroundTexture?.label = "background_texture"

            self.currentLineTexture = self.device.makeTexture(descriptor: textureDescriptor)
            self.currentLineTexture?.label = "current_line_texture"
            self.renderToTextureRenderPassDescriptor?.colorAttachments[0].texture = self.currentLineTexture
            drawingView.points.removeAll()
        }
    }

    /// Called whenever view changes orientation or is resized
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Scale size with contentScaleFactor to fit viewPort into the bounds of DrawingView
        let scale = view.contentScaleFactor
        let size = size * scale

        // Save the size of the drawable to pass to the vertex shader.
        viewportSize = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
        
        textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: metalKitView.colorPixelFormat, width: size.width.int, height: size.height.int, mipmapped: false)
        guard let textureDescriptor else { return }
        textureDescriptor.usage = [.shaderRead, .renderTarget]
        currentLineTexture = device.makeTexture(descriptor: textureDescriptor)
        currentLineTexture?.label = "current_line_texture"
        renderToTextureRenderPassDescriptor = MTLRenderPassDescriptor()
        renderToTextureRenderPassDescriptor?.colorAttachments[0].texture = currentLineTexture
        renderToTextureRenderPassDescriptor?.colorAttachments[0].loadAction = .load
        renderToTextureRenderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        renderToTextureRenderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let defaultLibrary = device.makeDefaultLibrary()

        // Load functions from the library.
        let vertexFunction = defaultLibrary?.makeFunction(name: "pointShaderVertex")
        let fragmentFunction = defaultLibrary?.makeFunction(name: "pointShaderFragment")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.rasterSampleCount = 1
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = textureDescriptor.pixelFormat
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha

        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        renderToTextureRenderPipeline = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        backgroundTexture = makeWhiteTexture(label: "background_texture", descriptor: textureDescriptor)

        if let newTextureDescriptor = textureDescriptor.copy() as? MTLTextureDescriptor {
            newTextureDescriptor.usage = [.shaderRead, .renderTarget, .shaderWrite]
            compiledTexture = device.makeTexture(descriptor: newTextureDescriptor)
            compiledTexture?.label = "compiled_texture"
            erasedTexture = device.makeTexture(descriptor: newTextureDescriptor)
            erasedTexture?.label = "erased_texture"
        }
    }
    
    private func makeWhiteTexture(label: String, descriptor: MTLTextureDescriptor) -> MTLTexture? {
        guard let texture = device.makeTexture(descriptor: descriptor) else { return nil }
        texture.label = label
        let origin = MTLOrigin(x: 0, y: 0, z: 0)
        let tSize = MTLSize(width: texture.width, height: texture.height, depth: texture.depth)
        let region = MTLRegion(origin: origin, size: tSize)
        let mappedColor = simd_uchar4(UIColor.white.vectorFloat4 * 255)
        Array<simd_uchar4>(repeating: mappedColor, count: tSize.width * tSize.height).withUnsafeBytes { ptr in
            texture.replace(region: region, mipmapLevel: 0, withBytes: ptr.baseAddress!, bytesPerRow: tSize.width * 4)
        }
        return texture
    }
    
    /// Called whenever the view needs to render a frame.
    func draw(in view: MTKView) {
        guard
            let pipelineState,
            // Create a new command buffer for each render pass to the current drawable.
            let commandBuffer = commandQueue?.makeCommandBuffer(),
            // Obtain a renderPassDescriptor generated from the view's drawable textures
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let drawingView = view as? DrawingView
        else { return }
        
        let points = drawingView.points
        
        if
            let descriptor = self.renderToTextureRenderPassDescriptor,
            let renderPipeline = self.renderToTextureRenderPipeline,
            let viewportSize = self.viewportSize, !points.isEmpty,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) {
            
            renderEncoder.setRenderPipelineState(renderPipeline)
            renderEncoder.setViewport(MTLViewport(
                originX: .zero,
                originY: .zero,
                width: Double(viewportSize.x),
                height: Double(viewportSize.y),
                znear: .zero,
                zfar: 1.0
            ))

            let pointsBuffer = self.device.makeBuffer(
                bytes: points,
                length: MemoryLayout<Point>.stride * points.count,
                options: .storageModeShared
            )

            // Pass in the parameter data.
            renderEncoder.setVertexBuffer(pointsBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .point, vertexStart: .zero, vertexCount: points.count)
            renderEncoder.endEncoding()
        }

        let isEraser = drawingView.selectedBrush.style == .eraser
        let pipeline = isEraser ? self.eraserComputePipeline : self.computePipeline
        let texture = isEraser ? self.erasedTexture : self.compiledTexture
        
        if
            let pipeline, let texture = texture,
            !points.isEmpty,
            let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        {
            let w = pipeline.threadExecutionWidth
            let h = pipeline.maxTotalThreadsPerThreadgroup / w

            let threadsPerThreadgroup = MTLSize(width: w, height: h, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (texture.width + w - 1) / w,
                                              height: (texture.height + h - 1) / h,
                                              depth: 1)

            
            commandEncoder.setComputePipelineState(pipeline)
            
            if !isEraser {
                var alpha = points[0].color.w
                commandEncoder.setBytes(&alpha, length: MemoryLayout<Float>.size(ofValue: alpha), index: 0)
                commandEncoder.setTexture(texture, index: 0)
            } else {
                commandEncoder.setTexture(texture, index: 0)
            }
            commandEncoder.setTexture(self.backgroundTexture, index: 1)
            commandEncoder.setTexture(self.currentLineTexture, index: 2)

            commandEncoder.dispatchThreadgroups(threadgroupsPerGrid,
                                                threadsPerThreadgroup: threadsPerThreadgroup)
            commandEncoder.endEncoding()
            
            if isEraser, let pipeline = self.computePipeline, let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
                commandEncoder.setComputePipelineState(pipeline)
                var alpha = points[0].color.w
                commandEncoder.setBytes(&alpha, length: MemoryLayout<Float>.size(ofValue: alpha), index: 0)
                commandEncoder.setTexture(self.compiledTexture, index: 0)
                
                guard let newTextureDescriptor = self.textureDescriptor?.copy() as? MTLTextureDescriptor else { return }
                newTextureDescriptor.usage = [.shaderRead, .renderTarget]
                let bgTexture = self.makeWhiteTexture(label: "white_background", descriptor: newTextureDescriptor)

                commandEncoder.setTexture(bgTexture, index: 1)

                commandEncoder.setTexture(texture, index: 2)

                commandEncoder.dispatchThreadgroups(threadgroupsPerGrid,
                                                    threadsPerThreadgroup: threadsPerThreadgroup)
                commandEncoder.endEncoding()

            }
        }
        
        // Create a render command encoder.
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        if let compiledTexture {
            
            renderEncoder.setRenderPipelineState(pipelineState)
                        
            let textureVertices: [TextureVertex] = [
                .init(corner: .bottomRight),
                .init(corner: .bottomLeft),
                .init(corner: .topLeft),
                .init(corner: .bottomRight),
                .init(corner: .topRight),
                .init(corner: .topLeft)
            ].compactMap({ $0 })
            
            let buffer = device.makeBuffer(
                bytes: textureVertices,
                length: MemoryLayout<TextureVertex>.stride * textureVertices.count,
                options: .storageModeShared
            )
            
            renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
            renderEncoder.setFragmentTexture(compiledTexture, index: 0)

            renderEncoder.drawPrimitives(type: .triangle, vertexStart: .zero, vertexCount: textureVertices.count)
        }
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)

        commandBuffer.commit()
    }
}
