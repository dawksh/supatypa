import Foundation

class StatsStore {

    static let shared = StatsStore()

    private let charsKey = "chars"
    private let wordsKey = "words"
    private let dateKey  = "date"

    private init() {}

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func load() -> (chars: Int, words: Int) {
        let savedDate = UserDefaults.standard.string(forKey: dateKey)

        // If date changed → reset
        if savedDate != todayString {
            reset()
        }

        let chars = UserDefaults.standard.integer(forKey: charsKey)
        let words = UserDefaults.standard.integer(forKey: wordsKey)
        return (chars, words)
    }

    func increment(chars: Int, words: Int) {
        let current = load()

        UserDefaults.standard.set(todayString, forKey: dateKey)
        UserDefaults.standard.set(current.chars + chars, forKey: charsKey)
        UserDefaults.standard.set(current.words + words, forKey: wordsKey)
    }
    
    func incrementChar() {
        let current = load()
        UserDefaults.standard.set(todayString, forKey: dateKey)
        UserDefaults.standard.set(current.chars + 1, forKey: charsKey)
    }
    
    func incrementWord() {
        let current = load()
        UserDefaults.standard.set(todayString, forKey: dateKey)
        UserDefaults.standard.set(current.words + 1, forKey: wordsKey)
    }

    func reset() {
        UserDefaults.standard.set(todayString, forKey: dateKey)
        UserDefaults.standard.set(0, forKey: charsKey)
        UserDefaults.standard.set(0, forKey: wordsKey)
    }
}
