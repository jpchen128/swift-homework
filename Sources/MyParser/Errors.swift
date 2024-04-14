import Foundation

// Error type for specs parsing
public enum SpecsParserError: Error {
    case invalidDataType
    case invalidCSVColumnName
    case duplicateSpecColumnName
}

extension SpecsParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidDataType:
            return "Invalid data type."
        case .invalidCSVColumnName:
            return "Invalid CSV column name."
        case .duplicateSpecColumnName:
            return "Duplicate spec column name."
        }
    }
}

// Error type for data parsing
public enum DataParserError: Error {
    case invalidDataLength
    case invalidLineEnd
    case unexpectedNewline
    case invalidBooleanValue
    case invalidIntegerValue
}

extension DataParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidDataLength:
            return "Data length cannot be divided by line length."
        case .invalidLineEnd:
            return "A line should end with a newline character."
        case .unexpectedNewline:
            return "Unexpected newline character in a field."
        case .invalidBooleanValue:
            return "Invalid boolean value, neither '0' nor '1'."
        case .invalidIntegerValue:
            return "Invalid integer value."
        }
    }
}
