//
//  main.swift
//  Day 08
//
//  Created by Stephen H. Gerstacker on 2019-12-08.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

struct Image {
    let width: Int
    let height: Int
    let layers: [ImageLayer]

    init(layer: ImageLayer) {
        self.width = layer.width
        self.height = layer.height

        layers = [layer]
    }

    init(string: String, width: Int, height: Int) {
        self.width = width
        self.height = height

        let area = width * height
        let numberOfLayers = string.count / area

        let layerInts = string.map { Int(String($0))! }

        layers = (0 ..< numberOfLayers).map {
            let minIdx = $0 * area
            let maxIdx = minIdx + area

            let layerData = layerInts[minIdx ..< maxIdx]
            return ImageLayer(data: layerData, width: width, height: height)
        }
    }

    func compressed() -> Image {
        var compressedData: [Int] = [Int](repeating: Int.max, count: width * height)

        for pixelIdx in 0 ..< (width * height) {
            for layer in layers {
                if layer.data[pixelIdx] == 2 {
                    continue
                }

                compressedData[pixelIdx] = layer.data[pixelIdx]
                break
            }
        }

        let layer = ImageLayer(data: compressedData, width: width, height: height)
        return Image(layer: layer)
    }

    func printColors() {
        for (layerIdx, layer) in layers.enumerated() {
            print("Layer \(layerIdx)")

            for row in 0 ..< layer.height {
                let minIdx = row * layer.width
                let maxIdx = minIdx + layer.width
                let range = minIdx ..< maxIdx

                let rowData = layer.data[range].map { (v: Int) -> String in
                    switch v {
                    case 0:
                        return "⬛️"
                    case 1:
                        return "⬜️"
                    case 2:
                        return "🟨"
                    default:
                        return "🟥"
                    }
                }

                print(rowData.joined())
            }

            print("")
        }
    }
    func printImage() {
        for (layerIdx, layer) in layers.enumerated() {
            print("Layer \(layerIdx)")

            for row in 0 ..< layer.height {
                let minIdx = row * layer.width
                let maxIdx = minIdx + layer.width

                print(layer.data[minIdx ..< maxIdx])
            }

            print("")
        }
    }
}

struct ImageLayer {
    let width: Int
    let height: Int
    let data: [Int]

    init(data: [Int], width: Int, height: Int) {
        self.width = width
        self.height = height
        self.data = data
    }

    init(data: ArraySlice<Int>, width: Int, height: Int) {
        self.width = width
        self.height = height

        self.data = Array(data)
    }
}

// let image = Image(string: Data.sampleData1, width: Data.sampleWidth1, height: Data.sampleHeight1)
// let image = Image(string: Data.sampleData2, width: Data.sampleWidth2, height: Data.sampleHeight2)
let image = Image(string: Data.inputData, width: Data.inputWidth, height: Data.inputHeight)
image.printImage()

var fewestZerosIndex = -1
var fewestZerosDigits: [Int] = [Int](repeating: Int.max, count: 10)

for (layerIdx, layer) in image.layers.enumerated() {
    var digitCount: [Int] = [Int](repeating: 0, count: 10)

    for digit in layer.data {
        digitCount[digit] += 1
    }

    if digitCount[0] < fewestZerosDigits[0] {
        fewestZerosIndex = layerIdx
        fewestZerosDigits = digitCount
    }
}

print("Fewest zeros (\(fewestZerosDigits[0])) @ \(fewestZerosIndex)")

let checksum = fewestZerosDigits[1] * fewestZerosDigits[2]
print("Checksum: \(checksum)")

let compressedImage = image.compressed()
compressedImage.printColors()
