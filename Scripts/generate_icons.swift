import AppKit

let outputDir = "GorzowBiz/Assets.xcassets/AppIcon.appiconset"
let sizes: [(String, Int)] = [
    ("Icon-20@2x.png", 40), ("Icon-20@3x.png", 60),
    ("Icon-29@2x.png", 58), ("Icon-29@3x.png", 87),
    ("Icon-40@2x.png", 80), ("Icon-40@3x.png", 120),
    ("Icon-60@2x.png", 120), ("Icon-60@3x.png", 180),
    ("Icon-1024.png", 1024)
]

func drawIcon(size: Int, path: String) {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    NSColor.white.setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()

    let s = CGFloat(size)
    let orange = NSColor(calibratedRed: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)
    orange.setFill()

    let cx = s * 0.5
    let cy = s * 0.55
    let r = s * 0.28
    let pin = NSBezierPath()
    pin.move(to: NSPoint(x: cx, y: s * 0.13))
    pin.curve(to: NSPoint(x: cx-r, y: cy), controlPoint1: NSPoint(x: cx-r*0.95, y: s*0.29), controlPoint2: NSPoint(x: cx-r, y: s*0.43))
    pin.curve(to: NSPoint(x: cx, y: s*0.91), controlPoint1: NSPoint(x: cx-r, y: s*0.72), controlPoint2: NSPoint(x: cx-r*0.30, y: s*0.84))
    pin.curve(to: NSPoint(x: cx+r, y: cy), controlPoint1: NSPoint(x: cx+r*0.30, y: s*0.84), controlPoint2: NSPoint(x: cx+r, y: s*0.72))
    pin.curve(to: NSPoint(x: cx, y: s*0.13), controlPoint1: NSPoint(x: cx+r, y: s*0.43), controlPoint2: NSPoint(x: cx+r*0.95, y: s*0.29))
    pin.close()
    pin.fill()

    NSColor.white.setFill()
    NSBezierPath(ovalIn: NSRect(x: cx-r*0.72, y: cy-r*0.72, width: r*1.44, height: r*1.44)).fill()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let font = NSFont.systemFont(ofSize: s * 0.27, weight: .black)
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black, .paragraphStyle: paragraph]
    let text = "G" as NSString
    let rect = NSRect(x: cx-r*0.72, y: cy-s*0.105, width: r*1.44, height: s*0.34)
    text.draw(in: rect, withAttributes: attrs)

    image.unlockFocus()
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else { fatalError("PNG generation failed") }
    try! png.write(to: URL(fileURLWithPath: path))
}

try! FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
for (name, size) in sizes { drawIcon(size: size, path: "\(outputDir)/\(name)") }
print("Generated \(sizes.count) gorzow.biz app icons")
