//
//  Colors.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-10.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

func rgb(r: Float, g: Float, b: Float) -> UIColor {
    let red: CGFloat = CGFloat(r/255)
    let green: CGFloat = CGFloat(g/255)
    let blue: CGFloat = CGFloat(b/255)
    return UIColor.init(red: red, green: green, blue: blue, alpha: 1)
}

struct Colors {
    static let brandYellow = rgb(r: 255, g: 255, b: 125) // hex: #ffff7d
    static let brandBabyBlue = rgb(r: 116, g: 179, b: 206) // hex: #74b3ce
    static let brandTurquoiseBlue = rgb(r: 56, g: 145, b: 166) // hex: #3891A6
    
    static let textDarkBlue = rgb(r: 1, g: 65, b: 79) // hex: #01414f
    
    static let warningRed = rgb(r: 179, g: 58, b: 58) // hex: #b33a3a
    
    static let almostWhite = rgb(r: 248, g: 248, b: 248) // hex: #fafafa
    
}
