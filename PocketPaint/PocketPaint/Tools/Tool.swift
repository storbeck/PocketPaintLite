//
//  Tool.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

protocol Tool: AnyObject {
    func begin(at point: CGPoint, in canvas: CanvasView)
    func move(to point: CGPoint, in canvas: CanvasView)
    func end(at point: CGPoint, in canvas: CanvasView)
}
