import AppKit
let size = 1024.0
let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()
let rect = NSRect(x: 0, y: 0, width: size, height: size)
let path = NSBezierPath(roundedRect: rect.insetBy(dx: 60, dy: 60), xRadius: 220, yRadius: 220)
let grad = NSGradient(starting: NSColor(calibratedRed: 0.20, green: 0.52, blue: 0.98, alpha: 1),
                      ending:   NSColor(calibratedRed: 0.10, green: 0.30, blue: 0.80, alpha: 1))!
grad.draw(in: path, angle: -90)
let cfg = NSImage.SymbolConfiguration(pointSize: 560, weight: .bold)
let sym = NSImage(systemSymbolName: "arrow.turn.down.right", accessibilityDescription: nil)!
    .withSymbolConfiguration(cfg)!
let tinted = NSImage(size: sym.size, flipped: false) { r in
    sym.draw(in: r); NSColor.white.set(); r.fill(using: .sourceAtop); return true
}
let s = tinted.size
tinted.draw(in: NSRect(x: (size - s.width)/2, y: (size - s.height)/2 + 10, width: s.width, height: s.height))
img.unlockFocus()
let tiff = img.tiffRepresentation!
let png = NSBitmapImageRep(data: tiff)!.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
