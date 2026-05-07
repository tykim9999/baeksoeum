import SwiftUI
import AppKit

// Renders the iOS square icon, the tvOS 3-layer landscape icon (small + large),
// and the Top Shelf hero. Outputs to ./out/.
//
//   swift run RenderIcon

@MainActor
func render<Content: View>(_ view: Content, width: CGFloat, height: CGFloat) -> Data? {
    let renderer = ImageRenderer(content: view.frame(width: width, height: height))
    renderer.scale = 1.0
    guard let cgImage = renderer.cgImage else { return nil }
    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    return bitmap.representation(using: .png, properties: [:])
}

@MainActor
func write(_ data: Data?, to relativePath: String) {
    guard let data else {
        FileHandle.standardError.write("missing data for \(relativePath)\n".data(using: .utf8)!)
        return
    }
    let url = URL(fileURLWithPath: "out/\(relativePath)")
    try? FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    do {
        try data.write(to: url)
        print("wrote \(url.path)  (\(data.count) bytes)")
    } catch {
        FileHandle.standardError.write("write failed for \(url.lastPathComponent): \(error)\n".data(using: .utf8)!)
    }
}

@MainActor
func main() {
    // -- iOS square sizes (preview convenience + 1024 source for asset catalog)
    for size in [CGFloat(60), 120, 180, 512, 1024] {
        let v = AppIconView(size: size)
        write(render(v, width: size, height: size), to: "ios/Icon-\(Int(size)).png")
    }

    // -- tvOS layered icons (5:3 ratio, 3 layers each at 2 sizes)
    let tvSizes: [(label: String, w: CGFloat, h: CGFloat)] = [
        ("small", 400, 240),
        ("large", 1280, 768),
    ]
    let tvLayers: [(label: String, layer: IconLayer)] = [
        ("back",   .back),
        ("middle", .middle),
        ("front",  .front),
    ]
    for tvs in tvSizes {
        for tvl in tvLayers {
            let v = AppIconView(width: tvs.w, height: tvs.h, layer: tvl.layer, shape: .landscape)
            write(render(v, width: tvs.w, height: tvs.h), to: "tvos/\(tvs.label)_\(tvl.label).png")
        }
    }

    // -- tvOS Top Shelf
    let topShelf = TopShelfView(width: 1920, height: 720)
    write(render(topShelf, width: 1920, height: 720), to: "tvos/top_shelf.png")
}

main()
