//
//  ViewController.swift
//  Draw App
//
//  Created by Bogdan Redkin on 29/04/2023.
//

import MetalKit
import UIKit

class ViewController: UIViewController {
    
    private var drawingView: DrawingView? {
        return self.view as? DrawingView
    }
    
    private var renderer: Renderer?

    override func loadView() {
        super.loadView()
        self.view = DrawingView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let drawingView else { return }
        renderer = Renderer(metalKitView: drawingView)
    }
}
