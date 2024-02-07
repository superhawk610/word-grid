import Foundation
import WordGrid
import PlatformGraphics
import Utils
import Graphics

final class Renderer {
    static let common: Renderer = Renderer()

    func render(_ grid: WordGrid) throws {
        let fontSize = 20
        let ctx = try PlatformGraphicsContext(width: grid.cols * fontSize, height: grid.rows * fontSize)

        // ctx.draw(line: LineSegment(fromX: 20, y: 20, toX: 50, y: 30))
        // ctx.draw(rect: Rectangle(fromX: 80, y: 90, width: 10, height: 40, color: Color.yellow))
        // ctx.draw(text: Text("Test", at: Vec2(x: 0, y: 15)))
        // ctx.draw(ellipse: Ellipse(centerX: 150, y: 80, radius: 40))

        for row in 0..<grid.rows {
            for col in 0..<grid.cols {
                let text = String(grid[row, col])
                let x = Double(col * fontSize)
                let y = Double((row + 1) * fontSize)
                ctx.draw(text: Text(text, at: Vec2(x: x, y: y)))
            }
        }

        let image = try ctx.makeImage()
        let data = try image.pngEncoded()
        try data.write(to: URL(fileURLWithPath: "out.png"))
    }
}
