//
//  LineTool.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

final class LineTool: Tool {
    private let settings: ToolSettings
    private var startPoint: CGPoint?

    init(settings: ToolSettings) {
        self.settings = settings
    }

    func begin(at point: CGPoint, in canvas: CanvasView) {
        startPoint = point
        canvas.setPreview(path: linePath(from: point, to: point), color: settings.primaryColor, width: settings.strokeSize.lineWidth, lineCap: .square)
    }

    func move(to point: CGPoint, in canvas: CanvasView) {
        guard let startPoint else { return }
        canvas.setPreview(path: linePath(from: startPoint, to: point), color: settings.primaryColor, width: settings.strokeSize.lineWidth, lineCap: .square)
    }

    func end(at point: CGPoint, in canvas: CanvasView) {
        guard let startPoint else { return }
        let path = linePath(from: startPoint, to: point)
        canvas.clearPreview()
        canvas.drawPath(path, color: settings.primaryColor, width: settings.strokeSize.lineWidth, lineCap: .square)
        self.startPoint = nil
    }

    private func linePath(from start: CGPoint, to end: CGPoint) -> CGPath {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
}
