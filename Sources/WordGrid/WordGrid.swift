public struct Chunk<Element>: Identifiable {
    public let id: String
    public var elements: [Element]
}

extension Array {
    func chunked(into size: Int) -> [Chunk<Element>] {
        stride(from: 0, to: count, by: size).map {
            Chunk(id: "\($0)", elements: Array(self[$0 ..< Swift.min($0 + size, count)]))
        }
    }
}

public enum LineAngle: Double, CaseIterable {
    case right = -0.0
    case downRight = -45.0
    case down = -90.0
    case downLeft = -135.0
    case left = -180.0
    case upLeft = 135.0
    case up = 90.0
    case upRight = 45.0
}

public struct Location: Hashable {
    public var row: Int
    public var col: Int
}

extension Location: Equatable {
    public static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.row == rhs.row && lhs.col == rhs.col
    }
}

public struct IterationOrder {
    let row: Int
    let col: Int

    init(_ angle: LineAngle) {
        switch angle {
        case .right:
            row = 0
            col = 1
        case .downRight:
            row = 1
            col = 1
        case .down:
            row = 1
            col = 0
        case .downLeft:
            row = 1
            col = -1
        case .left:
            row = 0
            col = -1
        case .upLeft:
            row = -1
            col = -1
        case .up:
            row = -1
            col = 0
        case .upRight:
            row = -1
            col = 1
        }
    }
}

struct Placement {
    let score: Int
    let locks: Set<Location>
    let start: Location
    let order: IterationOrder
}

func rad2deg(_ n: Double) -> Double {
    n * 180 / .pi
}

public final class WordGrid {
    public static func filledSquare(size: Int, wordCount: Int) -> WordGrid {
        let grid = WordGrid(rows: size, cols: size)
        let words = (0..<wordCount).map { _ in Dictionary.common.words.randomElement()! }
        grid.fill(with: words)
        return grid
    }

    static let fillLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static let emptyCell: Character = "·"

    // how many placement candidates to check before moving to the next word
    static let maxCandidates = 50

    // try to place words with a single overlap
    static let idealScore = 1

    public let rows: Int
    public let cols: Int
    public var letters: [Chunk<Character>]

    // these will be set once `fill()` is called
    public var words: [String] = []
    public var unplacedWords: [String] = []

    public var size: Int { get { rows * cols } }

    // when placing words, lock cells that contain letters for other words
    // to prevent placing words on top of others (that don't match)
    private var locked: Set<Location> = Set()

    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        self.letters = (0..<rows * cols).map { _ in WordGrid.emptyCell }.chunked(into: rows)
    }

    public func outlinedWord(start: Location, end: Location, order: IterationOrder) -> String {
        var word = "", loc = start
        while true {
            word.append(self[loc.row, loc.col])

            if loc == end {
                break
            }

            loc.row += order.row
            loc.col += order.col
        }

        return word
    }

    // place the given words and fill the remaining cells with random letters
    public func fill(with words: [String]) {
        var unplaced: [String] = []

        // place words (longest first, since they're the hardest to fit)
        for word in words.sorted(by: { ($0.count - $1.count) > 0 }) {
            // TODO: try matching all letters, not just first
            let letter = word[word.index(word.startIndex, offsetBy: 0)]

            var candidates: [Placement] = []
            // TODO: don't always start in the upper left
            search: for row in (0..<rows).shuffled() {
                for col in (0..<cols).shuffled() {
                    let have = self[row, col]
                    if have == WordGrid.emptyCell || have == letter {
                        for angle in LineAngle.allCases.shuffled() {
                            let loc = Location(row: row, col: col)
                            if fits(word, loc: loc, angle: angle) {
                                if let placement = tryPlace(word, start: loc, order: IterationOrder(angle)) {
                                    candidates.append(placement)
                                    if placement.score == WordGrid.idealScore || candidates.count > WordGrid.maxCandidates {
                                        break search
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if candidates.isEmpty {
                print("unable to place \(word)")
                unplaced.append(word)
            } else {
                let candidate = candidates.first(where: { $0.score == 1 }) ?? candidates.randomElement()!
                place(word, candidate)
            }
        }

        // fill in the remaining empty cells with random letters
        for row in 0..<rows {
            for col in 0..<cols {
                if self[row, col] == WordGrid.emptyCell {
                    self[row, col] = WordGrid.fillLetters.randomElement()!
                }
            }
        }

        // now that we're done placing, unlock everything
        locked.removeAll()

        self.words = words
        unplacedWords = unplaced
    }

    private func fits(_ word: String, loc: Location, angle: LineAngle) -> Bool {
        switch angle {
        case .right:
            word.count <= cols - loc.col
        case .downRight:
            word.count <= min(rows - loc.row, cols - loc.col)
        case .down:
            word.count <= rows - loc.row
        case .downLeft:
            word.count <= min(rows - loc.row, loc.col + 1)
        case .left:
            word.count <= loc.col + 1
        case .upLeft:
            word.count <= min(loc.row + 1, loc.col + 1)
        case .up:
            word.count <= loc.row + 1
        case .upRight:
            word.count <= min(loc.row + 1, cols - loc.col)
        }
    }

    // Returns the cells that would be locked if this word were placed, if it's possible to place;
    // if it's not possible to place, returns `nil`. This also returns a "placement score", which
    // describes the number of intersections this placement has with other words.
    private func tryPlace(_ word: String, start: Location, order: IterationOrder) -> Optional<Placement> {
        var locked: Set<Location> = Set()
        var loc = start, score = 0

        // make sure we're not going to overwrite any locked cells w/ different letters
        for c in word {
            if self.locked.contains(loc) {
                if self[loc.row, loc.col] == c {
                    score += 1
                } else {
                    return nil
                }
            }

            locked.insert(loc)
            loc.row += order.row
            loc.col += order.col
        }

        return Placement(score: score, locks: locked, start: start, order: order)
    }

    private func place(_ word: String, _ placement: Placement) {
        // register our locks
        self.locked.formUnion(placement.locks)

        // write letters into the grid!
        var loc = placement.start
        for c in word {
            self[loc.row, loc.col] = c
            loc.row += placement.order.row
            loc.col += placement.order.col
        }
    }

    public func debugPrint() {
        for chunk in letters {
            print(String(chunk.elements))
        }
    }

    private func indexIsValid(row: Int, col: Int) -> Bool {
        row >= 0 && row < rows && col >= 0 && col < cols
    }

    public subscript(row: Int, col: Int) -> Character {
        get {
            assert(indexIsValid(row: row, col: col), "Index out of range")
            return letters[row].elements[col]
        }
        set {
            assert(indexIsValid(row: row, col: col), "Index out of range")
            letters[row].elements[col] = newValue
        }
    }
}
