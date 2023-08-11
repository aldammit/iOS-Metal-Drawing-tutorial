//
//  EditorBottomViewModel.swift
//  Draw App
//
//  Created by Bogdan Redkin on 16/10/2022.
//

import Combine
import UIKit

final class EditorBottomViewModel: NSObject {

    enum BottomViewPresentationState {
        case show
        case updated
        case hide
    }
        
    enum State {
        case draw(brush: Brush, presentationState: BottomViewPresentationState)
        case brushConfiguration(brush: Brush, presentationState: BottomViewPresentationState)
        case colorPicker(selectedColor: Color, source: ColorSource, presentationState: BottomViewPresentationState)
        case clear(presentationState: BottomViewPresentationState)
        
        var presentationState: BottomViewPresentationState {
            switch self {
            case .draw(_,let presentationState): return presentationState
            case .brushConfiguration(_,let presentationState): return presentationState
            case .colorPicker(_,_,let presentationState): return presentationState
            case .clear(let presentationState): return presentationState
            }
        }
        
        func updatedBy(presentationState: BottomViewPresentationState) -> State {
            switch self {
            case .draw(let c,let presentationState): return .draw(brush: c, presentationState: presentationState)
            case .brushConfiguration(let b,let presentationState): return .brushConfiguration(brush: b, presentationState: presentationState)
            case .colorPicker(let c, let s,let presentationState): return .colorPicker(selectedColor: c, source: s, presentationState: presentationState)
            case .clear(let presentationState): return .clear(presentationState: presentationState)
            }
        }
    }
    
    enum ColorSource: String {
        case grid
        case palette
        case rgbSlider
        case spectrum
    }
    
    @Published var state: State!
    
    var selectedColor: Color
    var selectedTextColor: Color
    var selectedBrushIndex: Int = 0
    var selectedBrush: Brush {
        return brushes[selectedBrushIndex]
    }
    var selectedColorSource: ColorSource = .palette
    
    var brushes = Brush.defaultBrushes()
    private var bindings = Set<AnyCancellable>()
        
    deinit {
        print("\(String(describing: self)) deinit")
    }
        
    
    override init() {
        let defaultColor = Color(uiColor: .white)
        let defaultBrush = Brush(style: .pen)
        self.selectedColor = defaultColor
        self.state = .draw(brush: defaultBrush, presentationState: .show)
        self.selectedTextColor = defaultColor
        super.init()
    }
    
    func selectDrawTab() {
        self.state = .draw(brush: selectedBrush, presentationState: .show)
    }
    
    func selectColorPicker() {
        self.state = .colorPicker(selectedColor: self.selectedColor, source: self.selectedColorSource, presentationState: .show)
    }
    
    func hideColorPicker() {
        brushes[selectedBrushIndex].color = selectedColor
        self.state = .draw(brush: selectedBrush, presentationState: .updated)
    }
    
    func cancelButtonPressed() {
        state = .brushConfiguration(brush: selectedBrush, presentationState: .hide)
    }
    
    func updateBrushWidth(_ percent: Float) {
        print("brush width percent: \(percent)")
        brushes[selectedBrushIndex].width = (selectedBrush.style.maxWidth - selectedBrush.style.minWidth) * percent
        state = .brushConfiguration(brush: selectedBrush, presentationState: .updated)
    }
    
    func updateValuesInColorPicker(color: Color, source: ColorSource) {
        selectedColor = color
        selectedColorSource = source
        brushes[selectedBrushIndex].color = color
        state = .colorPicker(selectedColor: selectedColor, source: selectedColorSource, presentationState: .updated)
    }
    
    func updateColorOpacity(opacity: Int) {
        selectedColor.alpha = opacity.cgFloat/100
        selectedColorSource = .palette
        brushes[selectedBrushIndex].color = selectedColor
        state = .colorPicker(selectedColor: selectedColor, source: selectedColorSource, presentationState: .updated)
    }
    
    func selectBrush(index: Int) {
        if index == selectedBrushIndex {
            let presentationState: BottomViewPresentationState = {
                switch self.state {
                case .brushConfiguration(_, let presentationState):
                    switch presentationState {
                    case .updated, .show: return .hide
                    case .hide: return .show
                    }
                default:
                    return .show
                }
            }()
            state = .brushConfiguration(brush: brushes[index], presentationState: presentationState)
        } else {
            state = .draw(brush: brushes[index], presentationState: .updated)
        }
        selectedBrushIndex = index
    }
}
