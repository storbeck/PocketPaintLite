# PRD.md

**Project:** Pocket Paint
**Platform:** iOS (Native)
**Language:** Swift
**UI Framework:** UIKit
**Rendering:** Core Graphics (bitmap-backed canvas)

---

## 1. Problem Statement

Modern iOS drawing apps are optimized for illustration, not **simple drawing**. They are:

* Overloaded with features
* Gesture-heavy
* Difficult for casual users and children

Classic **MS Paint succeeded because it was obvious**:

* Visible tools
* Immediate feedback
* No abstraction layers

There is a gap on iOS for a **simple, faithful, low-friction paint app**.

---

## 2. Product Goal

Build a **native iOS MS Paint–style app** that:

* Feels instant and predictable
* Uses visible, always-available tools
* Requires no onboarding
* Matches classic Paint behavior as closely as possible

**Success metric:**
A user can open the app and start drawing in under 2 seconds without instructions.

---

## 3. Target Audience

Primary:

* Kids
* Parents
* Teachers
* Casual users
* Developers sketching ideas

Secondary:

* Nostalgia-driven users

Explicitly not targeting:

* Professional illustrators
* Designers
* AI art users

---

## 4. Core Design Principles

1. **Fidelity over modern polish**
2. **Pixel-first rendering**
3. **No hidden gestures**
4. **One tool active at a time**
5. **Discoverable without help**

---

## 5. Core Features (MVP)

### 5.1 Canvas

* White bitmap-backed canvas
* Fixed default size (Paint-like)
* Scrollable when zoomed
* Pinch-to-zoom
* Two-finger pan
* One-finger draw

Rendering rules:

* All drawing modifies a bitmap
* No vector persistence
* No layer system

---

### 5.2 Drawing Tools (Paint Parity)

Required tools:

* Pencil
* Brush
* Straight line
* Rectangle (outline + filled)
* Ellipse (outline + filled)
* Eraser (white paint)
* Fill bucket (flood fill)
* Color picker (eyedropper)
* Text tool (basic)

Behavior should mimic classic MS Paint, even if imperfect.

---

### 5.3 Tool Properties

* Stroke sizes:

  * Small
  * Medium
  * Large
* Shared size selector
* No opacity control
* No pressure sensitivity (Apple Pencil treated as finger input)

---

### 5.4 Color System

* Fixed MS Paint–style palette
* Primary color
* Secondary color
* Tap to select
* Visual indicator for active colors

No gradients. No color wheels.

---

### 5.5 UI Layout

#### Top Toolbar

* Tool icons
* Undo / Redo

#### Bottom Bar

* Color palette
* Primary / secondary indicators

UI constraints:

* Flat icons
* Large hit targets
* Utility look
* No shadows or animation-heavy UI

---

## 6. Undo / Redo

* Action-based undo stack
* Minimum 20 actions
* Each completed tool interaction = one undo step
* Redo stack clears on new action

---

## 7. File Handling

### Save

* Export bitmap as PNG
* Save to Files / Photos

### Open

* Import image from Photos
* Draw directly on imported bitmap

### Share

* iOS share sheet
* PNG export only

---

## 8. Performance Requirements

* Touch-to-draw latency < 16ms
* No dropped frames during drawing
* Canvas operations must remain responsive on older devices
* Memory usage bounded by canvas size

---

## 9. Accessibility

* All controls labeled for VoiceOver
* Color names announced when selected
* Large tap targets
* High-contrast mode compatible

---

## 10. App Store Compliance

* No private APIs
* No code execution
* Clear, honest marketing
* Privacy policy included (no data collection)

---

## 11. Out of Scope (Anti-Goals)

* Layers
* AI tools
* Filters
* Accounts
* Cloud sync
* Ads in v1

---

## 12. Launch Criteria

App is ready when:

* Drawing feels instant
* Tools behave predictably
* UI requires no explanation
* A child can use it unaided
