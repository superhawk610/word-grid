import WordGrid

// let grid = WordGrid.filledSquare(size: 9, wordCount: 15)
// grid.debugPrint()
// try Renderer.common.render(grid)

// let words = [
//     "BANANA",
//     "SPLIT",
//     "ICECREAM",
//     "CHOCOLATE",
//     "PANCAKES",
//     "WAFFLES",
//     "STRAWBERRY",
//     "CINNAMON",
//     "SUGAR",
//     "SYRUP"
// ]

let words = [
    "PUZZLE",
    "WORD",
    "CLUE",
    "OOPS",
    "FIND",
    "MISS",
    "SPOOKY",
    "GHOST"
]

let grid = WordGrid(rows: 9, cols: 9)
try Renderer.common.renderFill(grid, words: words)
grid.debugPrint()
