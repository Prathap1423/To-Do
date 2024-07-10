//
//  LayerExtensions.swift
//  Zoho Task
//
//  Created by prathap on 06/07/24.
//

import UIKit

extension CALayer {
    
    func applyShadow(color: UIColor) {
        
        self.shadowColor = color.cgColor
        self.shadowOpacity = 0.2
        self.shadowOffset = CGSize(width: 0, height: 5)
        self.shadowRadius = 10
        self.masksToBounds = false
    }
}
