//
//  ViewController.swift
//  Draw App
//
//  Created by Bogdan Redkin on 29/04/2023.
//

import MetalKit
import Combine
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
    private var bindings = Set<AnyCancellable>()

    override func loadView() {
        super.loadView()
        self.view = DrawingView(frame: UIScreen.main.bounds, brush: editorViewModel.selectedBrush, device: MTLCreateSystemDefaultDevice())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let drawingView else { return }
        renderer = Renderer(metalKitView: drawingView)
        view.addSubview(bottomView)
        
        bottomView.pinToSuperviewEdges(exclude: .top, respectingSafeArea: false)
        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: 88 + 33 + 25),
        ])
        
        editorViewModel.$state.receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .draw(let brush, let presentationState):
                    switch presentationState {
                    case .updated:
                        self.drawingView?.selectedBrush = brush
                    case .show:
                        self.drawingView?.selectedBrush = brush
                    case .hide:
                        print("brush: \(brush) hide")
                    }
                case .brushConfiguration(let brush, let presentationState):
                    switch presentationState {
                    case .updated:
                        print("brushConfiguration updated, brush: \(brush)")
                    case .show:
                        print("brushConfiguration show, brush: \(brush)")
                    case .hide:
                        print("brushConfiguration hide, brush: \(brush)")
                    }
                    self.drawingView?.selectedBrush = brush
                case let .colorPicker(color, _, presentationState):
                    switch presentationState {
                    case .show:
                        print("color picker show")
                        CollorPickerBottomSheetController.buildAndPresent(
                            viewController: self,
                            viewModel: self.editorViewModel
                        )
                    case .hide:
                        print("color picker hide")
                    case .updated:
                        print("color picker updated")
                    }
                    self.drawingView?.selectedBrush.color = color
                case .clear(_):
                    self.drawingView?.clear?()
                default:
                    break
                }
            }.store(in: &bindings)
    }
}
