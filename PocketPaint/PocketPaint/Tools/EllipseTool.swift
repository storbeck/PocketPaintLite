//
//  EllipseTool.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

final class EllipseTool: Tool {
    private let settings: ToolSettings
    private var startPoint: CGPoint?

    init(settings: ToolSettings) {
        self.settings = settings
    }

    func begin(at point: CGPoint, in canvas: CanvasView) {
        startPoint = point
        let rect = rectFrom(start: point, end: point)
        let path = UIBezierPath(ovalIn: rect).cgPath
        canvas.setPreview(path: path, color: settings.primaryColor, width: settings.strokeSize.lineWidth, lineCap: .square)
    }

    func move(to point: CGPoint, in canvas: CanvasView) {
        guard let startPoint else { return }
        let rect = rectFrom(start: startPoint, end: point)
        let path = UIBezierPath(ovalIn: rect).cgPath
        canvas.setPreview(path: path, color: settings.primaryColor, width: settings.strokeSize.lineWidth, lineCap: .square)
    }

    func end(at point: CGPoint, in canvas: CanvasView) {
        guard let startPoint else { return }
        let rect = rectFrom(start: startPoint, end: point)
        let path = UIBezierPath(ovalIn: rect).cgPath
        canvas.clearPreview()
        canvas.drawPath(path, color: settings.primaryColor, width: settings.strokeSize.lineWidth, lineCap: .square)
        self.startPoint = nil
    }

    private func rectFrom(start: CGPoint, end: CGPoint) -> CGRect {
        let origin = CGPoint(x: min(start.x, end.x), y: min(start.y, end.y))
        let size = CGSize(width: abs(end.x - start.x), height: abs(end.y - start.y))
        return CGRect(origin: origin, size: size)
    }
}
