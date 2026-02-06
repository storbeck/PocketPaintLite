//
//  CanvasView.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

final class CanvasView: UIView {
    private let toolManager: ToolManager
    private var bitmapContext: CGContext?
    private var bitmapImage: CGImage?
    private var bitmapData: UnsafeMutableRawPointer?
    private var bitmapSize: CGSize = .zero
    private var bitmapScale: CGFloat = 1
    private var bitmapWidth: Int = 0
    private var bitmapHeight: Int = 0
    private var bitmapBytesPerRow: Int = 0
    private var previewPath: CGPath?
    private var previewColor: UIColor = .black
    private var previewWidth: CGFloat = 1
    private var previewLineCap: CGLineCap = .square

    var onColorPicked: ((UIColor) -> Void)?
    var onRequestText: ((CGPoint) -> Void)?

    init(toolManager: ToolManager) {
        self.toolManager = toolManager
        super.init(frame: .zero)
        isMultipleTouchEnabled = false
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        return nil
    }

    deinit {
        bitmapData?.deallocate()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let scale = window?.screen.scale ?? UIScreen.main.scale
        if bounds.size != bitmapSize || scale != bitmapScale {
            createBitmap(size: bounds.size, scale: scale)
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(UIColor.white.cgColor)
        context.fill(bounds)
        if let image = bitmapImage {
            context.interpolationQuality = .none
            context.draw(image, in: bounds)
        }
        if let previewPath {
            context.addPath(previewPath)
            context.setStrokeColor(previewColor.cgColor)
            context.setLineWidth(previewWidth)
            context.setLineCap(previewLineCap)
            context.strokePath()
        }
    }

    func drawLine(from start: CGPoint, to end: CGPoint, color: UIColor, width: CGFloat, lineCap: CGLineCap) {
        guard let context = bitmapContext else { return }
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(width)
        context.setLineCap(lineCap)
        context.move(to: start)
        context.addLine(to: end)
        context.strokePath()
        bitmapImage = context.makeImage()
        setNeedsDisplay()
    }

    func drawPath(_ path: CGPath, color: UIColor, width: CGFloat, lineCap: CGLineCap) {
        guard let context = bitmapContext else { return }
        context.addPath(path)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(width)
        context.setLineCap(lineCap)
        context.strokePath()
        bitmapImage = context.makeImage()
        setNeedsDisplay()
    }

    func drawDots(at points: [CGPoint], color: UIColor, diameter: CGFloat) {
        guard let context = bitmapContext, !points.isEmpty else { return }
        context.setFillColor(color.cgColor)
        let half = diameter * 0.5
        for point in points {
            let rect = CGRect(x: point.x - half, y: point.y - half, width: diameter, height: diameter)
            context.fill(rect)
        }
        bitmapImage = context.makeImage()
        setNeedsDisplay()
    }

    func drawText(_ text: String, at point: CGPoint, color: UIColor, font: UIFont) {
        guard let context = bitmapContext else { return }
        context.saveGState()
        UIGraphicsPushContext(context)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        (text as NSString).draw(at: point, withAttributes: attributes)
        UIGraphicsPopContext()
        context.restoreGState()
        bitmapImage = context.makeImage()
        setNeedsDisplay()
    }

    func currentImage() -> UIImage? {
        guard let image = bitmapImage else { return nil }
        return UIImage(cgImage: image, scale: bitmapScale, orientation: .up)
    }

    func colorAt(point: CGPoint) -> UIColor? {
        guard let data = bitmapData else { return nil }
        let x = Int(point.x * bitmapScale)
        let y = Int(point.y * bitmapScale)
        let flippedY = (bitmapHeight - 1) - y
        guard x >= 0, flippedY >= 0, x < bitmapWidth, flippedY < bitmapHeight else { return nil }
        let offset = flippedY * bitmapBytesPerRow + x * 4
        let bytes = data.assumingMemoryBound(to: UInt8.self)
        let b = bytes[offset]
        let g = bytes[offset + 1]
        let r = bytes[offset + 2]
        let a = bytes[offset + 3]
        return UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    func floodFill(at point: CGPoint, with color: UIColor) {
        guard let data = bitmapData else { return }
        let startX = Int(point.x * bitmapScale)
        let startY = Int(point.y * bitmapScale)
        let flippedStartY = (bitmapHeight - 1) - startY
        guard startX >= 0, flippedStartY >= 0, startX < bitmapWidth, flippedStartY < bitmapHeight else { return }

        let bytes = data.assumingMemoryBound(to: UInt8.self)
        let startOffset = flippedStartY * bitmapBytesPerRow + startX * 4
        let target = (
            bytes[startOffset],
            bytes[startOffset + 1],
            bytes[startOffset + 2],
            bytes[startOffset + 3]
        )
        let replacement = rgbaBytes(for: color)
        if target.0 == replacement.b && target.1 == replacement.g && target.2 == replacement.r && target.3 == replacement.a {
            return
        }

        var stack: [(Int, Int)] = [(startX, flippedStartY)]
        while let (x, y) = stack.popLast() {
            let offset = y * bitmapBytesPerRow + x * 4
            if bytes[offset] != target.0 ||
                bytes[offset + 1] != target.1 ||
                bytes[offset + 2] != target.2 ||
                bytes[offset + 3] != target.3 {
                continue
            }

            bytes[offset] = replacement.b
            bytes[offset + 1] = replacement.g
            bytes[offset + 2] = replacement.r
            bytes[offset + 3] = replacement.a

            if x > 0 { stack.append((x - 1, y)) }
            if x + 1 < bitmapWidth { stack.append((x + 1, y)) }
            if y > 0 { stack.append((x, y - 1)) }
            if y + 1 < bitmapHeight { stack.append((x, y + 1)) }
        }

        bitmapImage = bitmapContext?.makeImage()
        setNeedsDisplay()
    }

    func setPreview(path: CGPath?, color: UIColor, width: CGFloat, lineCap: CGLineCap) {
        previewPath = path
        previewColor = color
        previewWidth = width
        previewLineCap = lineCap
        setNeedsDisplay()
    }

    func clearPreview() {
        previewPath = nil
        setNeedsDisplay()
    }

    private func createBitmap(size: CGSize, scale: CGFloat) {
        bitmapData?.deallocate()
        bitmapData = nil

        bitmapSize = size
        bitmapScale = scale

        let width = max(Int(size.width * scale), 1)
        let height = max(Int(size.height * scale), 1)
        let bytesPerRow = width * 4
        let data = UnsafeMutableRawPointer.allocate(byteCount: bytesPerRow * height, alignment: 64)
        data.initializeMemory(as: UInt8.self, repeating: 255, count: bytesPerRow * height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let context = CGContext(
            data: data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )
        context?.scaleBy(x: scale, y: scale)
        bitmapContext = context
        bitmapData = data
        bitmapWidth = width
        bitmapHeight = height
        bitmapBytesPerRow = bytesPerRow
        bitmapImage = context?.makeImage()
    }

    private func rgbaBytes(for color: UIColor) -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (
            r: UInt8(r * 255),
            g: UInt8(g * 255),
            b: UInt8(b * 255),
            a: UInt8(a * 255)
        )
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        toolManager.activeTool.begin(at: point, in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        toolManager.activeTool.move(to: point, in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        toolManager.activeTool.end(at: point, in: self)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        toolManager.activeTool.end(at: point, in: self)
    }
}
