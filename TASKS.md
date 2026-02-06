**Project:** Pocket Paint (Native iOS)
**Goal:** App Store–ready MVP

---

## 1. Project Setup

* [ ] Create Xcode project (UIKit, Swift)
* [ ] Set bundle ID
* [ ] Add `PRD.md`
* [ ] Add `TASKS.md`
* [ ] Configure app icon placeholders
* [ ] Configure launch screen

---

## 2. Canvas Architecture

* [ ] Create `CanvasView : UIView`
* [ ] Back canvas with bitmap (`CGContext` / `UIImage`)
* [ ] Implement draw loop for bitmap updates
* [ ] Render bitmap efficiently in `draw(_:)`
* [ ] Clear canvas functionality

**Exit criteria:**
Bitmap redraws are fast and visually stable.

---

## 3. Touch Handling

* [ ] Handle single-touch drawing
* [ ] Track touch begin / move / end
* [ ] Two-finger pan gesture
* [ ] Pinch-to-zoom gesture
* [ ] Prevent gesture interference with drawing

---

## 4. Tool System

* [ ] Define `Tool` protocol (begin / move / end)
* [ ] Tool manager for active tool
* [ ] Shared tool settings (size, color)
* [ ] Ensure only one tool active at a time

---

## 5. Drawing Tools

### Pencil

* [ ] Pixel-style freehand strokes
* [ ] No smoothing

### Brush

* [ ] Thicker freehand strokes

### Line

* [ ] Tap-drag-preview
* [ ] Commit on release

### Rectangle

* [ ] Outline mode
* [ ] Filled mode
* [ ] Drag preview

### Ellipse

* [ ] Outline mode
* [ ] Filled mode
* [ ] Drag preview

### Eraser

* [ ] Paints white
* [ ] Uses stroke sizes

### Fill Bucket

* [ ] Flood fill algorithm
* [ ] Color tolerance
* [ ] Bounds safety

### Color Picker

* [ ] Sample pixel color from bitmap
* [ ] Set active color

### Text Tool

* [ ] Tap to place text
* [ ] Single system font
* [ ] Fixed size
* [ ] Bitmap render on commit

---

## 6. Tool Properties

* [ ] Stroke size selector (S / M / L)
* [ ] Shared size across tools
* [ ] Visual size indicator

---

## 7. Color System

* [ ] Define fixed color palette
* [ ] Primary color selection
* [ ] Secondary color selection
* [ ] Swap primary/secondary
* [ ] Active color indicators

---

## 8. UI Implementation

### Toolbar

* [ ] Tool buttons
* [ ] Active tool highlight
* [ ] Undo button
* [ ] Redo button

### Bottom Bar

* [ ] Color palette UI
* [ ] Color selection feedback

---

## 9. Undo / Redo

* [ ] Action snapshot strategy (bitmap snapshots or command-based)
* [ ] Undo stack (min 20)
* [ ] Redo stack
* [ ] Clear redo on new action

---

## 10. File Handling

### Save

* [ ] Export bitmap to PNG
* [ ] Save to Files / Photos
* [ ] Handle permission prompts

### Open

* [ ] Import image from Photos
* [ ] Scale to canvas safely

### Share

* [ ] Share sheet integration

---

## 11. Performance & Stability

* [ ] No frame drops during drawing
* [ ] Handle memory warnings
* [ ] Background / foreground stability
* [ ] Stress-test large drawings

---

## 12. Accessibility

* [ ] VoiceOver labels for all controls
* [ ] Color names announced
* [ ] Minimum tap target sizes
* [ ] High-contrast support

---

## 13. App Store Readiness

* [ ] Privacy policy
* [ ] App Store description
* [ ] Screenshots
* [ ] No prohibited APIs
* [ ] Pass TestFlight review

---

## 14. Pre-Submit Checklist

* [ ] All tools functional
* [ ] Drawing latency acceptable
* [ ] No crashes
* [ ] UI is self-explanatory
* [ ] App meets original Paint spirit

---

## 15. Explicit Do-Not-Add List

* [ ] Layers
* [ ] AI
* [ ] Filters
* [ ] Accounts
* [ ] Cloud sync

