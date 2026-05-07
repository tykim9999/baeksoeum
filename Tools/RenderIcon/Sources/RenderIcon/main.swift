import SwiftUI
import AppKit

// Renders AppIconView at multiple sizes and writes PNGs to ./out/.
//
//   swift run RenderIcon
//
// Outputs:
//   out/Icon-1024.png   (App Store + iOS asset catalog source)
//   out/Icon-512.png
//   out/Icon-180.png    (iPhone @3x for 60pt)
//   out/Icon-120.png    (iPhone @2x for 60pt)
//   out/Icon-60.png     (preview)

@MainActor
func render(size: CGFloat) -> Data? {
    let view = AppIconView(size: size).frame(width: size, height: size)
    let renderer = ImageRenderer(content: view)
    renderer.scale = 1.0
    guard let cgImage = renderer.cgImage else {
        FileHandle.standardError.write("Failed to render \(Int(size))\n".data(using: .utf8)!)
        return nil
    }
    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    return bitmap.representation(using: .png, properties: [:])
}

@MainActor
func main() {
    let outDir = URL(fileURLWithPath: "out", isDirectory: true)
    try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

    let sizes: [CGFloat] = [1024, 512, 180, 120, 60]
    for size in sizes {
        guard let data = render(size: size) else { continue }
        let url = outDir.appendingPathComponent("Icon-\(Int(size)).png")
        do {
            try data.write(to: url)
            print("wrote \(url.path)  (\(data.count) bytes)")
        } catch {
            FileHandle.standardError.write("write failed for \(url.lastPathComponent): \(error)\n".data(using: .utf8)!)
        }
    }
}

main()
