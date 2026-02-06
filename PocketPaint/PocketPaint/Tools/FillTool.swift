//
//  FillTool.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

final class FillTool: Tool {
    private let settings: ToolSettings

    init(settings: ToolSettings) {
        self.settings = settings
    }

    func begin(at point: CGPoint, in canvas: CanvasView) {
        canvas.floodFill(at: point, with: settings.primaryColor)
    }

    func move(to point: CGPoint, in canvas: CanvasView) {
    }

    func end(at point: CGPoint, in canvas: CanvasView) {
    }
}
