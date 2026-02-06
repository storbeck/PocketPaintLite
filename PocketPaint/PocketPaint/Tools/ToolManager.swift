//
//  ToolManager.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

enum ToolType: CaseIterable {
    case pencil
    case brush
    case airbrush
    case line
    case rectangle
    case ellipse
    case eraser
    case fill
    case picker
    case text

    var title: String {
        switch self {
        case .pencil:
            return "Pencil"
        case .brush:
            return "Brush"
        case .airbrush:
            return "Airbrush"
        case .line:
            return "Line"
        case .rectangle:
            return "Rect"
        case .ellipse:
            return "Ellipse"
        case .eraser:
            return "Eraser"
        case .fill:
            return "Fill"
        case .picker:
            return "Picker"
        case .text:
            return "Text"
        }
    }

    var symbolName: String {
        switch self {
        case .pencil:
            return "pencil.tip"
        case .brush:
            return "paintbrush.pointed"
        case .airbrush:
            return "dot.radiowaves.left.and.right"
        case .line:
            return "line.diagonal"
        case .rectangle:
            return "rectangle"
        case .ellipse:
            return "oval"
        case .eraser:
            return "eraser"
        case .fill:
            return "paintbrush.fill"
        case .picker:
            return "eyedropper"
        case .text:
            return "textformat"
        }
    }

    var isSupported: Bool {
        switch self {
        case .pencil, .brush, .airbrush, .line, .rectangle, .ellipse, .eraser, .fill, .picker, .text:
            return true
        }
    }
}

final class ToolManager {
    let settings: ToolSettings
    private(set) var activeTool: Tool
    private(set) var activeType: ToolType

    init(settings: ToolSettings) {
        self.settings = settings
        let pencil = PencilTool(settings: settings)
        self.activeTool = pencil
        self.activeType = .pencil
    }

    func setActiveTool(_ type: ToolType) {
        guard type.isSupported else { return }
        activeType = type
        switch type {
        case .pencil:
            activeTool = PencilTool(settings: settings)
        case .brush:
            activeTool = BrushTool(settings: settings)
        case .airbrush:
            activeTool = AirbrushTool(settings: settings)
        case .line:
            activeTool = LineTool(settings: settings)
        case .rectangle:
            activeTool = RectangleTool(settings: settings)
        case .ellipse:
            activeTool = EllipseTool(settings: settings)
        case .eraser:
            activeTool = EraserTool(settings: settings)
        case .fill:
            activeTool = FillTool(settings: settings)
        case .picker:
            activeTool = ColorPickerTool(settings: settings)
        case .text:
            activeTool = TextTool()
        }
    }
}
