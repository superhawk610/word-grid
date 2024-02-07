import Foundation

final class Dictionary {
    static let common = Dictionary()
    static let lenRange = 3...6

    let words: [String]

    init() {
        let url = URL(fileURLWithPath: "words.txt")
        guard let str = try? String(contentsOf: url) else { fatalError("coudln't load words") }
        words = str.uppercased()
            .components(separatedBy: "\n")
            .filter { !$0.contains("'") }
            .filter { Dictionary.lenRange.contains($0.count) }
    }
}
