//
//  PencilTool.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

final class PencilTool: Tool {
    private let settings: ToolSettings
    private var lastPoint: CGPoint?

    init(settings: ToolSettings) {
        self.settings = settings
    }

    func begin(at point: CGPoint, in canvas: CanvasView) {
        lastPoint = point
        canvas.drawLine(from: point, to: point, color: settings.primaryColor, width: 1, lineCap: .square)
    }

    func move(to point: CGPoint, in canvas: CanvasView) {
        guard let lastPoint else {
            lastPoint = point
            return
        }
        canvas.drawLine(from: lastPoint, to: point, color: settings.primaryColor, width: 1, lineCap: .square)
        self.lastPoint = point
    }

    func end(at point: CGPoint, in canvas: CanvasView) {
        guard let lastPoint else { return }
        canvas.drawLine(from: lastPoint, to: point, color: settings.primaryColor, width: 1, lineCap: .square)
        self.lastPoint = nil
    }
}
