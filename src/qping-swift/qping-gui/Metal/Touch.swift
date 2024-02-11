//
//  Touch.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 9/2/24.
//

import Foundation



class Touch {
    private static var MOUSE_BUTTON_COUNT = 12
    private static var mouseButtonList = [Bool].init(repeating: false, count: MOUSE_BUTTON_COUNT)
    
    private static var overallMousePosition = SIMD2(repeating:Float(0.0))
    private static var mousePositionDelta = SIMD2(repeating:Float(0.0))
    
    private static var scrollWheelPosition: Float = 0.0
    private static var lastWheelPosition: Float = 0.0
    private static var scrollWheelChange: Float = 0.0
    
    public static var overrallPosX: Float {
        return overallMousePosition.x
    }
    
}
