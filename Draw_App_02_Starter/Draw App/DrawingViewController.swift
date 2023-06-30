//
//  DrawingViewController.swift
//  Draw App
//
//  Created by Bogdan Redkin on 29/04/2023.
//

import MetalKit
import UIKit

class DrawingViewController: UIViewController {

    private var drawingView: DrawingView? {
        return self.view as? DrawingView
    }

    private var editorViewModel = EditorBottomViewModel()
    
    private lazy var bottomView: EditorBottomView = {
        return EditorBottomView(viewModel: editorViewModel)
    }()

    private var renderer: Renderer?

    override func loadView() {
        super.loadView()
        self.view = DrawingView(frame: UIScreen.main.bounds, brush: editorViewModel.selectedBrush, device: MTLCreateSystemDefaultDevice())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let drawingView else { return }
        renderer = Renderer(metalKitView: drawingView)
        view.addSubview(bottomView)
        
        editorViewModel.brushUpdated = { [weak self] brush in
            self?.drawingView?.selectedBrush = brush
        }
        bottomView.pinToSuperviewEdges(exclude: .top, respectingSafeArea: false)
        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: 88 + 33 + 25),
        ])
    }
}
