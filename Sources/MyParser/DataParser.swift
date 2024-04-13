import Foundation

// Struct for parsing data according to given specifications
public struct DataParser {
    let specs: [Spec]

    public init(specs: [Spec]) {
        self.specs = specs
    }

    // Function to parse data according to the specifications
    // It takes a string of data to parse and a callback function for output
    // It returns a string of parsed data
    public func parseData(_ data: String, callback: OutputCallback = ndjsonOutput) async throws -> String {
        var results: [RowResultType] = []
        var currentStart = data.startIndex
        while currentStart < data.endIndex {
            results.append(
                specs.map({ spec in
                    let currentEnd = data.index(currentStart, offsetBy: spec.width)
                    let data = data[currentStart..<currentEnd]
                    currentStart = currentEnd
                    return (spec.columnName, spec.convert(String(data)))
                })
            )
            if data[currentStart].isNewline {
                currentStart = data.index(after: currentStart)
            } else {
                throw DataParserError.invalidLineEnd
            }
        }
        return try callback(results)
    }
}

public func ndjsonOutput(_ results: [RowResultType]) throws -> String {
    let output = results.reduce("") { output, rowResult in
        output + "{" + (rowResult.reduce("") { output, columnResult in
            output + "\"\(columnResult.0)\": \(columnResult.1), "
        }).dropLast(2) + "}\n"
    }
    return output
}
