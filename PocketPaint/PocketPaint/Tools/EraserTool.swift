//
//  EraserTool.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

final class EraserTool: Tool {
    private let settings: ToolSettings
    private var lastPoint: CGPoint?

    init(settings: ToolSettings) {
        self.settings = settings
    }

    func begin(at point: CGPoint, in canvas: CanvasView) {
        lastPoint = point
        let width = settings.strokeSize.lineWidth
        canvas.drawLine(from: point, to: point, color: .white, width: width, lineCap: .square)
    }

    func move(to point: CGPoint, in canvas: CanvasView) {
        guard let lastPoint else {
            self.lastPoint = point
            return
        }
        let width = settings.strokeSize.lineWidth
        canvas.drawLine(from: lastPoint, to: point, color: .white, width: width, lineCap: .square)
        self.lastPoint = point
    }

    func end(at point: CGPoint, in canvas: CanvasView) {
        guard let lastPoint else { return }
        let width = settings.strokeSize.lineWidth
        canvas.drawLine(from: lastPoint, to: point, color: .white, width: width, lineCap: .square)
        self.lastPoint = nil
    }
}
