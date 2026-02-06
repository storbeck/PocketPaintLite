//
//  TextTool.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

final class TextTool: Tool {
    func begin(at point: CGPoint, in canvas: CanvasView) {
        canvas.onRequestText?(point)
    }

    func move(to point: CGPoint, in canvas: CanvasView) {
    }

    func end(at point: CGPoint, in canvas: CanvasView) {
    }
}
