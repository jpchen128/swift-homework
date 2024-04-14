import Foundation

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

public enum DataParserError: Error {
    case invalidLineLength
    case invalidBooleanValue
    case invalidIntegerValue
}

extension DataParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidLineLength:
            return "Invalid line length."
        case .invalidBooleanValue:
            return "Invalid boolean value, not '0' or '1'."
        case .invalidIntegerValue:
            return "Invalid integer value."
        }
    }
}
