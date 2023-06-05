//
//  DrawingView.swift
//  Draw App
//
//  Created by Bogdan Redkin on 29/04/2023.
//

import MetalKit

class DrawingView: MTKView {
    private var previousPreviousLocation: CGPoint?
    private var previousLocation: CGPoint?
    
    var brushSize = CGFloat(20)
    
    var points: [Point] = []
    
    override var frame: CGRect {
        didSet {
            delegate?.mtkView(self, drawableSizeWillChange: frame.size)
        }
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        setupGestureRecognizer()
    }

    @available(*, unavailable) required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGestureRecognizer() {
        let panGesture = DrawingGestureRecognizer()
        panGesture.maximumNumberOfTouches = 1
        panGesture.touchesBeganHandler = { [weak self] response in
            guard let self else { return }
            for touch in response.touches {
                let pos = touch.location(in: self) * self.contentScaleFactor
                self.draw(at: pos)
                let predicted = response.event.coalescedTouches(for: touch)
                for p in (predicted ?? []) {
                    let pos = p.location(in: self) * self.contentScaleFactor
                    self.draw(at: pos)
                }
            }
         }

        panGesture.touchesMovedHandler = { [weak self] response in
            guard let self else { return }
            for touch in response.touches {
                let pos = touch.location(in: self) * self.contentScaleFactor
                self.draw(at: pos)
            }
        }
        
        let gestureFinishedHandler: ((DrawingGestureRecognizer.touchesResponse) -> Void)? = { [weak self] _ in
            guard let self else { return }
            self.previousLocation = nil
            self.previousPreviousLocation = nil
        }
        
        panGesture.touchesEndedHandler = gestureFinishedHandler
        panGesture.touchesCancelledHandler = gestureFinishedHandler

        addGestureRecognizer(panGesture)
    }
    
    private func draw(at point: CGPoint) {
        let previousPreviousLocation = self.previousPreviousLocation ?? point
        let previousLocation = self.previousLocation ?? point
        self.previousPreviousLocation = self.previousLocation
        self.previousLocation = point

        let mid1 = (previousLocation + previousPreviousLocation) * 0.5
        let mid2 = (point + previousLocation) * 0.5

        let pl = SIMD2<Float>(Float(previousLocation.x), Float(previousLocation.y))
        let cl = SIMD2<Float>(Float(point.x), Float(point.y))
        let d = distance(pl, cl)
        
        for i in 0 ... Int(d) {
            let p = d <= 0 ? point : quadBezierPoint(t: CGFloat(i) / CGFloat(d), start: mid1, c1: previousLocation, end: mid2)
            let point = Point(location: p, parentSize: self.bounds.size * contentScaleFactor, color: .blue, size: brushSize * contentScaleFactor)
            points.append(point)
        }
    }

    private func quadBezierPoint(t: CGFloat, start: CGPoint, c1: CGPoint, end: CGPoint) -> CGPoint {
        let x = quadBezier(t: t, start: start.x, c1: c1.x, end: end.x)
        let y = quadBezier(t: t, start: start.y, c1: c1.y, end: end.y)
        return CGPoint(x: x, y: y)
    }

    private func quadBezier(t: CGFloat, start: CGFloat, c1: CGFloat, end: CGFloat) -> CGFloat {
        let t_ = (1.0 - t)
        let tt_ = t_ * t_
        let tt = t * t
        return start * tt_ + 2.0 * c1 * t_ * t + end * tt
    }
}
