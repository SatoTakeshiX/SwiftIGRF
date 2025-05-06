extension Array where Element: RandomAccessCollection {
    public var transpose: [[Element.Element]] {
        guard !isEmpty else { return [] }

        // 各列の要素数を確認
        let columnCount = self[0].count
        guard allSatisfy({ $0.count == columnCount }) else {
            fatalError("All rows must have the same number of columns")
        }

        // 転置行列の作成
        var transposed: [[Element.Element]] = []
        for columnIndex in 0..<columnCount {
            let column = self.map { $0[$0.index($0.startIndex, offsetBy: columnIndex)] }
            transposed.append(column)
        }

        return transposed
    }
}
