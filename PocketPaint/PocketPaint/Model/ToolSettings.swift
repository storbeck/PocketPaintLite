//
//  ToolSettings.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

enum StrokeSize: CaseIterable {
    case small
    case medium
    case large
    case extraLarge

    var lineWidth: CGFloat {
        switch self {
        case .small:
            return 1
        case .medium:
            return 3
        case .large:
            return 5
        case .extraLarge:
            return 8
        }
    }
}

final class ToolSettings {
    var primaryColor: UIColor = .black
    var secondaryColor: UIColor = .white
    var strokeSize: StrokeSize = .small
}
