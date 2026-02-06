//
//  MainViewController.swift
//  PocketPaint
//
//  Created by Geoff Storbeck on 2/5/26.
//

import UIKit

final class MainViewController: UIViewController {
    private let toolSettings = ToolSettings()
    private lazy var toolManager = ToolManager(settings: toolSettings)
    private lazy var canvasView = CanvasView(toolManager: toolManager)

    private var toolButtons: [ToolType: UIButton] = [:]
    private var toolButtonsOrdered: [UIButton] = []
    private var sizeButtons: [StrokeSize: UIButton] = [:]
    private let primaryColorView = UIView()
    private let secondaryColorView = UIView()
    private var toolbarContainer: UIView?
    private var toolsGrid: UIStackView?
    private var widthStack: UIStackView?
    private var actionsStack: UIStackView?
    private var contentStack: UIStackView?
    private var toolbarHeightConstraint: NSLayoutConstraint?

    private let paletteColors: [(name: String, color: UIColor)] = [
        ("Black", UIColor(red: 0, green: 0, blue: 0, alpha: 1)),
        ("Dark Gray", UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)),
        ("Maroon", UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)),
        ("Olive", UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 1)),
        ("Dark Green", UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)),
        ("Teal", UIColor(red: 0, green: 0.5, blue: 0.5, alpha: 1)),
        ("Navy", UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)),
        ("Purple", UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)),
        ("White", UIColor(red: 1, green: 1, blue: 1, alpha: 1)),
        ("Light Gray", UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)),
        ("Red", UIColor(red: 1, green: 0, blue: 0, alpha: 1)),
        ("Yellow", UIColor(red: 1, green: 1, blue: 0, alpha: 1)),
        ("Green", UIColor(red: 0, green: 1, blue: 0, alpha: 1)),
        ("Cyan", UIColor(red: 0, green: 1, blue: 1, alpha: 1)),
        ("Blue", UIColor(red: 0, green: 0, blue: 1, alpha: 1)),
        ("Magenta", UIColor(red: 1, green: 0, blue: 1, alpha: 1))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureLayout()
        configureCallbacks()
        updateToolSelection()
        updateSizeSelection()
        updateColorIndicators()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateToolbarLayout()
    }

    private func configureCallbacks() {
        canvasView.onColorPicked = { [weak self] _ in
            self?.updateColorIndicators()
        }
        canvasView.onRequestText = { [weak self] point in
            self?.presentTextPrompt(at: point)
        }
    }

    private func configureLayout() {
        let toolbar = buildToolbar()
        let bottomBar = buildBottomBar()

        toolbarContainer = toolbar
        view.addSubview(toolbar)
        view.addSubview(bottomBar)
        view.addSubview(canvasView)

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false

        toolbarHeightConstraint = toolbar.heightAnchor.constraint(equalToConstant: 96)
        toolbarHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 100),

            canvasView.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
    }

    private func buildToolbar() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.9, alpha: 1.0)

        let toolsGrid = UIStackView()
        toolsGrid.axis = .vertical
        toolsGrid.spacing = 6
        toolsGrid.alignment = .leading
        self.toolsGrid = toolsGrid

        buildToolButtonsIfNeeded()
        layoutToolGrid(columns: preferredToolColumns())

        let widthStack = UIStackView()
        widthStack.axis = .vertical
        widthStack.spacing = 4
        widthStack.alignment = .fill
        widthStack.distribution = .fillEqually
        self.widthStack = widthStack

        StrokeSize.allCases.forEach { size in
            let button = makeWidthButton(size: size)
            button.addTarget(self, action: #selector(handleSizeTapped(_:)), for: .touchUpInside)
            button.tag = sizeTag(size)
            button.accessibilityLabel = "Line width \(widthLabel(for: size))"
            sizeButtons[size] = button
            widthStack.addArrangedSubview(button)
        }

        let spacer = UIView()
        spacer.widthAnchor.constraint(equalToConstant: 12).isActive = true

        let actionsStack = UIStackView(arrangedSubviews: [makeActionButton(symbol: "square.and.arrow.down", label: "Save", action: #selector(handleSaveTapped)), makeActionButton(symbol: "square.and.arrow.up", label: "Share", action: #selector(handleShareTapped))])
        actionsStack.axis = .vertical
        actionsStack.spacing = 6
        actionsStack.alignment = .center
        self.actionsStack = actionsStack

        let contentStack = UIStackView(arrangedSubviews: [toolsGrid, spacer, widthStack, spacer, actionsStack])
        contentStack.axis = .horizontal
        contentStack.spacing = 8
        contentStack.alignment = .center
        self.contentStack = contentStack

        container.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            contentStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            contentStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -8)
        ])

        return container
    }

    private func buildToolButtonsIfNeeded() {
        guard toolButtonsOrdered.isEmpty else { return }
        ToolType.allCases.forEach { type in
            let button = makeToolbarButton(symbolName: type.symbolName)
            button.addTarget(self, action: #selector(handleToolTapped(_:)), for: .touchUpInside)
            button.isEnabled = type.isSupported
            button.alpha = type.isSupported ? 1.0 : 0.4
            button.tag = typeTag(type)
            button.accessibilityLabel = "Tool: \(type.title)"
            toolButtons[type] = button
            toolButtonsOrdered.append(button)
        }
    }

    private func layoutToolGrid(columns: Int) {
        guard let toolsGrid else { return }
        toolsGrid.axis = .vertical
        toolsGrid.spacing = 6
        toolsGrid.alignment = .leading
        toolsGrid.arrangedSubviews.forEach { row in
            toolsGrid.removeArrangedSubview(row)
            row.removeFromSuperview()
        }

        let total = toolButtonsOrdered.count
        var index = 0
        while index < total {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 6
            rowStack.alignment = .center
            let end = min(index + columns, total)
            for i in index..<end {
                rowStack.addArrangedSubview(toolButtonsOrdered[i])
            }
            toolsGrid.addArrangedSubview(rowStack)
            index = end
        }
    }

    private func preferredToolColumns() -> Int {
        if traitCollection.verticalSizeClass == .compact {
            return toolButtonsOrdered.count
        }
        return 5
    }

    private func layoutToolsSingleRow() {
        guard let toolsGrid else { return }
        toolsGrid.arrangedSubviews.forEach { row in
            toolsGrid.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
        toolsGrid.axis = .horizontal
        toolsGrid.spacing = 6
        toolsGrid.alignment = .center
        toolButtonsOrdered.forEach { toolsGrid.addArrangedSubview($0) }
    }

    private func updateToolbarLayout() {
        let isCompact = traitCollection.verticalSizeClass == .compact
        if isCompact {
            toolbarHeightConstraint?.constant = 56
            layoutToolsSingleRow()
            widthStack?.axis = .horizontal
            widthStack?.spacing = 6
            actionsStack?.axis = .horizontal
            actionsStack?.spacing = 6
            contentStack?.spacing = 8
        } else {
            toolbarHeightConstraint?.constant = 96
            layoutToolGrid(columns: preferredToolColumns())
            widthStack?.axis = .vertical
            widthStack?.spacing = 4
            actionsStack?.axis = .vertical
            actionsStack?.spacing = 6
            contentStack?.spacing = 8
        }
    }

    private func buildBottomBar() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.9, alpha: 1.0)

        primaryColorView.layer.borderColor = UIColor.black.cgColor
        primaryColorView.layer.borderWidth = 1
        primaryColorView.isAccessibilityElement = true
        primaryColorView.accessibilityLabel = "Primary color"

        secondaryColorView.layer.borderColor = UIColor.black.cgColor
        secondaryColorView.layer.borderWidth = 1
        secondaryColorView.isAccessibilityElement = true
        secondaryColorView.accessibilityLabel = "Secondary color"

        let indicatorStack = UIStackView(arrangedSubviews: [primaryColorView, secondaryColorView])
        indicatorStack.axis = .vertical
        indicatorStack.spacing = 6
        indicatorStack.alignment = .fill
        indicatorStack.distribution = .fillEqually

        let paletteStack = UIStackView()
        paletteStack.axis = .vertical
        paletteStack.spacing = 6
        paletteStack.distribution = .fillEqually

        let rowSize = 8
        let firstRow = UIStackView()
        firstRow.axis = .horizontal
        firstRow.spacing = 6
        firstRow.distribution = .fillEqually

        let secondRow = UIStackView()
        secondRow.axis = .horizontal
        secondRow.spacing = 6
        secondRow.distribution = .fillEqually

        for (index, entry) in paletteColors.enumerated() {
            let button = UIButton(type: .system)
            button.backgroundColor = entry.color
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.tag = index
            button.accessibilityLabel = "Color \(entry.name)"
            button.addTarget(self, action: #selector(handleColorTapped(_:)), for: .touchUpInside)
            if index < rowSize {
                firstRow.addArrangedSubview(button)
            } else {
                secondRow.addArrangedSubview(button)
            }
        }

        paletteStack.addArrangedSubview(firstRow)
        paletteStack.addArrangedSubview(secondRow)

        container.addSubview(indicatorStack)
        container.addSubview(paletteStack)

        indicatorStack.translatesAutoresizingMaskIntoConstraints = false
        paletteStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            indicatorStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            indicatorStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            indicatorStack.widthAnchor.constraint(equalToConstant: 32),
            indicatorStack.heightAnchor.constraint(equalToConstant: 64),

            paletteStack.leadingAnchor.constraint(equalTo: indicatorStack.trailingAnchor, constant: 12),
            paletteStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            paletteStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            paletteStack.heightAnchor.constraint(equalToConstant: 72)
        ])

        return container
    }

    private func makeToolbarButton(symbolName: String) -> UIButton {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: symbolName)
        if let image {
            button.setImage(image, for: .normal)
            button.tintColor = .black
        } else {
            button.setTitle("?", for: .normal)
            button.setTitleColor(.black, for: .normal)
        }
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return button
    }

    private func makeActionButton(symbol: String, label: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: symbol)
        if let image {
            button.setImage(image, for: .normal)
            button.tintColor = .black
        } else {
            button.setTitle(label, for: .normal)
            button.setTitleColor(.black, for: .normal)
        }
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        button.accessibilityLabel = label
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeWidthButton(size: StrokeSize) -> UIButton {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 52).isActive = true

        let line = UIView()
        line.backgroundColor = .black
        line.isUserInteractionEnabled = false
        button.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            line.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            line.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.7),
            line.heightAnchor.constraint(equalToConstant: size.lineWidth)
        ])

        return button
    }

    private func typeTag(_ type: ToolType) -> Int {
        switch type {
        case .pencil: return 1
        case .brush: return 2
        case .airbrush: return 3
        case .line: return 4
        case .rectangle: return 5
        case .ellipse: return 6
        case .eraser: return 7
        case .fill: return 8
        case .picker: return 9
        case .text: return 10
        }
    }

    private func sizeTag(_ size: StrokeSize) -> Int {
        switch size {
        case .small: return 101
        case .medium: return 102
        case .large: return 103
        case .extraLarge: return 104
        }
    }

    private func toolType(from tag: Int) -> ToolType? {
        switch tag {
        case 1: return .pencil
        case 2: return .brush
        case 3: return .airbrush
        case 4: return .line
        case 5: return .rectangle
        case 6: return .ellipse
        case 7: return .eraser
        case 8: return .fill
        case 9: return .picker
        case 10: return .text
        default: return nil
        }
    }

    private func strokeSize(from tag: Int) -> StrokeSize? {
        switch tag {
        case 101: return .small
        case 102: return .medium
        case 103: return .large
        case 104: return .extraLarge
        default: return nil
        }
    }

    private func widthLabel(for size: StrokeSize) -> String {
        switch size {
        case .small: return "1"
        case .medium: return "3"
        case .large: return "5"
        case .extraLarge: return "8"
        }
    }

    private func colorName(for color: UIColor) -> String {
        if let match = paletteColors.first(where: { $0.color.isEqual(color) }) {
            return match.name
        }
        return "Custom"
    }

    @objc private func handleToolTapped(_ sender: UIButton) {
        guard let type = toolType(from: sender.tag) else { return }
        toolManager.setActiveTool(type)
        updateToolSelection()
    }

    @objc private func handleSizeTapped(_ sender: UIButton) {
        guard let size = strokeSize(from: sender.tag) else { return }
        toolSettings.strokeSize = size
        updateSizeSelection()
    }

    @objc private func handleColorTapped(_ sender: UIButton) {
        let index = sender.tag
        guard paletteColors.indices.contains(index) else { return }
        toolSettings.primaryColor = paletteColors[index].color
        updateColorIndicators()
    }

    private func updateToolSelection() {
        toolButtons.forEach { type, button in
            if type == toolManager.activeType {
                button.backgroundColor = .white
            } else {
                button.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            }
        }
    }

    private func updateSizeSelection() {
        sizeButtons.forEach { size, button in
            if size == toolSettings.strokeSize {
                button.backgroundColor = .white
            } else {
                button.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            }
        }
    }

    private func updateColorIndicators() {
        primaryColorView.backgroundColor = toolSettings.primaryColor
        secondaryColorView.backgroundColor = toolSettings.secondaryColor
        primaryColorView.accessibilityValue = colorName(for: toolSettings.primaryColor)
        secondaryColorView.accessibilityValue = colorName(for: toolSettings.secondaryColor)
    }

    @objc private func handleSaveTapped() {
        guard let image = canvasView.currentImage() else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(handleSaveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func handleShareTapped() {
        guard let image = canvasView.currentImage() else { return }
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let popover = controller.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.maxX - 40, y: view.safeAreaInsets.top + 20, width: 1, height: 1)
        }
        present(controller, animated: true)
    }

    @objc private func handleSaveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error {
            showSimpleAlert(title: "Save Failed", message: error.localizedDescription)
            return
        }
        showSimpleAlert(title: "Saved", message: "Image saved to Photos.")
    }

    private func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func presentTextPrompt(at point: CGPoint) {
        let alert = UIAlertController(title: "Text", message: nil, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter text"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            let text = alert.textFields?.first?.text ?? ""
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            let font = UIFont(name: "Courier", size: 16) ?? UIFont.systemFont(ofSize: 16)
            self.canvasView.drawText(trimmed, at: point, color: self.toolSettings.primaryColor, font: font)
        }))
        present(alert, animated: true)
    }
}
