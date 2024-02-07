import WordGrid

let grid = WordGrid.filledSquare(size: 9, wordCount: 15)
grid.debugPrint()
try Renderer.common.render(grid)
