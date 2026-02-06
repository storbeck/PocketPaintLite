//
//  AirbrushTool.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

final class AirbrushTool: Tool {
    private let settings: ToolSettings
    private var lastPoint: CGPoint?
    private var timer: Timer?

    init(settings: ToolSettings) {
        self.settings = settings
    }

    func begin(at point: CGPoint, in canvas: CanvasView) {
        lastPoint = point
        startSpray(in: canvas)
    }

    func move(to point: CGPoint, in canvas: CanvasView) {
        lastPoint = point
    }

    func end(at point: CGPoint, in canvas: CanvasView) {
        lastPoint = nil
        stopSpray()
    }

    private func startSpray(in canvas: CanvasView) {
        stopSpray()
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self, weak canvas] _ in
            guard let self, let canvas else { return }
            self.spray(in: canvas)
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopSpray() {
        timer?.invalidate()
        timer = nil
    }

    private func spray(in canvas: CanvasView) {
        guard let center = lastPoint else { return }
        let radius: CGFloat
        let dotDiameter: CGFloat
        let count: Int

        switch settings.strokeSize {
        case .small:
            radius = 6
            dotDiameter = 1
            count = 10
        case .medium:
            radius = 10
            dotDiameter = 1.5
            count = 18
        case .large:
            radius = 14
            dotDiameter = 2
            count = 26
        case .extraLarge:
            radius = 18
            dotDiameter = 2.5
            count = 34
        }

        var points: [CGPoint] = []
        points.reserveCapacity(count)
        for _ in 0..<count {
            let (dx, dy) = randomPointInCircle(radius: radius)
            points.append(CGPoint(x: center.x + dx, y: center.y + dy))
        }
        canvas.drawDots(at: points, color: settings.primaryColor, diameter: dotDiameter)
    }

    private func randomPointInCircle(radius: CGFloat) -> (CGFloat, CGFloat) {
        let angle = CGFloat.random(in: 0..<(2 * .pi))
        let distance = sqrt(CGFloat.random(in: 0...1)) * radius
        return (cos(angle) * distance, sin(angle) * distance)
    }
}
