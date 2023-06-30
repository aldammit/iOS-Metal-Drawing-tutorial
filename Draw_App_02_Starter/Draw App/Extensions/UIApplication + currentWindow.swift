//
//  UIApplication + currentWindow.swift
//  Draw App
//
//  Created by Bogdan Redkin on 06/06/2023.
//

import UIKit

extension UIApplication {
    
    var window: UIWindow? {
        // Get connected scenes
        let scene = UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap { $0 as? UIWindowScene }
        
        return scene?.keyWindow
    }
    
}
