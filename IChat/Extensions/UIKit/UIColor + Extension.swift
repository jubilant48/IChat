//
//  UIColor + Extension.swift
//  IChat
//
//  Created by macbook on 14.12.2022.
//

import UIKit

extension UIColor {
    
    static func buttonRed() -> UIColor {
        return #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1)
    }
    
    static func mainWhite() -> UIColor {
        return #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9921568627, alpha: 1)
    }
    
    static func buttonDark() -> UIColor {
        return #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    }
    
    static func textFieldLight() -> UIColor {
        return #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
    }
    
    static func getPurpleColor() -> UIColor {
        return #colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.9411764706, alpha: 1)
    }
    
    static func getBlackCustomColor() -> UIColor {
        return #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2392156863, alpha: 1)
    }
    
    static func getGrayColor() -> UIColor {
        return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    static func getBackgroundAppColor() -> UIColor {
        return UIColor(named: "backgroundApp")!
    }
    
    static func getShadowColor() -> UIColor {
        return UIColor(named: "shadowColor")!
    }
    
    static func getTextFieldColor() -> UIColor {
        return UIColor(named: "textFieldColor")!
    }
}
                 
