//
//  ColorPickerTool.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

final class ColorPickerTool: Tool {
    private let settings: ToolSettings

    init(settings: ToolSettings) {
        self.settings = settings
    }

    func begin(at point: CGPoint, in canvas: CanvasView) {
        if let color = canvas.colorAt(point: point) {
            settings.primaryColor = color
            canvas.onColorPicked?(color)
        }
    }

    func move(to point: CGPoint, in canvas: CanvasView) {
    }

    func end(at point: CGPoint, in canvas: CanvasView) {
    }
}
