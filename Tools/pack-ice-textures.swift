import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Usage: swift Tools/pack-ice-textures.swift <source directory> <asset catalog>
// Inputs are the book's rendered material previews, not screenshots with UI.
// Their RGB bytes encode numeric values (neutral normals are near 128).
// Preserve those values and tag the packed output as linear so SwiftUI does not
// gamma-decode height or normals when supplying the shader's image argument.
let source = URL(fileURLWithPath: CommandLine.arguments[1])
let destination = URL(fileURLWithPath: CommandLine.arguments[2])
let width = 360, height = 480
let linear = CGColorSpace(name: CGColorSpace.linearSRGB)!
let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!

func pixels(_ name: String, space: CGColorSpace) -> [UInt8] {
    let input = CGImageSourceCreateWithURL(source.appendingPathComponent(name) as CFURL, nil)!
    let image = CGImageSourceCreateImageAtIndex(input, 0, nil)!
    var bytes = [UInt8](repeating: 0, count: width * height * 4)
    bytes.withUnsafeMutableBytes { pointer in
        let context = CGContext(data: pointer.baseAddress, width: width, height: height,
                                bitsPerComponent: 8, bytesPerRow: width * 4, space: space,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    return bytes
}

func write(_ pixels: [UInt8], name: String, space: CGColorSpace) throws {
    let folder = destination.appendingPathComponent("\(name).imageset")
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    let provider = CGDataProvider(data: Data(pixels) as CFData)!
    let image = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32,
                        bytesPerRow: width * 4, space: space,
                        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                        provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)!
    let output = CGImageDestinationCreateWithURL(folder.appendingPathComponent("\(name).png") as CFURL,
                                               UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(output, image, nil)
    precondition(CGImageDestinationFinalize(output))
    let manifest: [String: Any] = ["images": [["filename": "\(name).png", "idiom": "universal"]],
                                  "info": ["author": "xcode", "version": 1]]
    try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys])
        .write(to: folder.appendingPathComponent("Contents.json"))
}

let heights = pixels("ice-h-map.png", space: sRGB)
let normals = pixels("ice-n-decode.png", space: sRGB)
for channel in 0..<3 {
    let mean = stride(from: channel, to: normals.count, by: 4).reduce(0.0) { $0 + Double(normals[$1]) } / Double(width * height * 255)
    print("Decoded normal channel \(channel) mean: \(mean)")
}
var packed = [UInt8](repeating: 255, count: width * height * 4)
for i in stride(from: 0, to: packed.count, by: 4) {
    packed[i] = heights[i]
    packed[i + 1] = normals[i]
    packed[i + 2] = normals[i + 1]
}
try write(packed, name: "IceRelief", space: linear)
try write(pixels("ice-original.png", space: sRGB), name: "IceColor", space: sRGB)
print("Packed \(width)×\(height) material maps into \(destination.path)")
