import Foundation
import WordGrid
import PlatformGraphics
import Utils
import Graphics
import GIF

final class Renderer {
    static let common: Renderer = Renderer()

    let fontSize: Double = 16
    let cellPadding: Int = 2
    var cellSize: Int { Int(fontSize) + cellPadding * 2 }

    func renderFill(_ grid: WordGrid, words: [String]) throws {
        assert(!words.isEmpty, "must fill with at least one word")

        var gif = GIF(width: grid.cols * cellSize, height: grid.rows * cellSize)
        var workingOn: Optional<String> = nil
        var i = 0

        grid.fill(with: words,
            fillLetters: [WordGrid.emptyCell],
            onPlacementCandidateFound: { word, placement in
                if workingOn != word {
                    i += 1
                    workingOn = word
                    print("placing \"\(word)\" (\(i) of \(words.count))...")
                }

                let snapshot = WordGrid(rows: grid.rows, cols: grid.cols)
                snapshot.letters = grid.letters
                snapshot.place(word, placement)
                let data = try render(snapshot)
                gif.frames.append(.init(image: try CairoImage(pngData: data)))
            })

        // hold on the last frame for a bit (3s)
        let lastFrame = gif.frames.last!
        let frame = Frame(image: lastFrame.image, delayTime: 300)
        gif.frames.append(frame)

        print("rendering to GIF...")
        let data = try gif.encoded()
        try data.write(to: URL(fileURLWithPath: "out.gif"))
    }

    func render(_ grid: WordGrid, to url: Optional<URL> = URL(fileURLWithPath: "out.png")) throws -> Data {
        let width = grid.cols * cellSize
        let height = grid.rows * cellSize
        let ctx = try PlatformGraphicsContext(width: width, height: height)

        // fill background w/ black
        ctx.draw(rect: Rectangle(fromX: 0, y: 0, width: Double(width), height: Double(height), color: Color.black))

        // ctx.draw(line: LineSegment(fromX: 20, y: 20, toX: 50, y: 30))
        // ctx.draw(rect: Rectangle(fromX: 80, y: 90, width: 10, height: 40, color: Color.yellow))
        // ctx.draw(text: Text("Test", at: Vec2(x: 0, y: 15)))
        // ctx.draw(ellipse: Ellipse(centerX: 150, y: 80, radius: 40))

        for row in 0..<grid.rows {
            for col in 0..<grid.cols {
                let text = String(grid[row, col])
                let x = Double(col * cellSize)
                let y = Double((row + 1) * cellSize)
                ctx.draw(text: Text(text, withSize: fontSize,
                    at: Vec2(x: x, y: y - Double(cellPadding * 2))))
            }
        }

        let image = try ctx.makeImage()
        let data = try image.pngEncoded()

        if let url = url {
            try data.write(to: url)
        }

        return data
    }
}
