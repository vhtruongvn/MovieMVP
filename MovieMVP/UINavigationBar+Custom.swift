//
//  UINavigationBar+Custom.swift
//  MovieMVP
//
//  Created by Truong Vo on 8/15/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func setGradientBackground(colors: [UIColor]) {
        var updatedFrame = bounds
        updatedFrame.size.height += 20
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors)
        
        setBackgroundImage(gradientLayer.creatGradientImage(), for: UIBarMetrics.default)
    }
    
}
