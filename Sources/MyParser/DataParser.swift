import Foundation

// Struct for parsing data according to given specifications
public struct DataParser {
    let specs: [Spec]

    public init(_ specs: [Spec]) {
        self.specs = specs
    }

    // Function to parse data according to the specifications
    // It takes a string of data to parse and a callback function for output
    // It returns a string of parsed data
    public func parseData(_ data: String, callback: OutputCallback = ndjsonOutput) async throws -> String {
        var results: [LineResultType] = []
        var currentStart = data.startIndex
        while currentStart < data.endIndex {
            results.append(
                try specs.map({ spec in
                    let currentEnd = data.index(currentStart, offsetBy: spec.width)
                    let data = data[currentStart..<currentEnd]
                    currentStart = currentEnd
                    return (spec.columnName, try spec.convert(String(data)))
                })
            )
            if data[currentStart].isNewline {
                currentStart = data.index(after: currentStart)
            } else {
                throw DataParserError.invalidLineLength
            }
        }
        return try callback(results)
    }
}

// Callback function to output parsed data in NDJSON format
// It is the default output callback for DataParser
// It takes an array of line results and returns a string in NDJSON format
public func ndjsonOutput(_ results: [LineResultType]) throws -> String {
    let output = results.reduce("") { output, rowResult in
        output + "{" + (rowResult.reduce("") { output, columnResult in
            output + "\"\(columnResult.0)\": \(columnResult.1), "
        }).dropLast(2) + "}\n"
    }
    return output
}
