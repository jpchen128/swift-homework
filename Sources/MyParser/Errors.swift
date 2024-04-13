import Foundation

public enum SpecsParserError: Error {
    case invalidDataType
    case duplicateColumnName
}

extension SpecsParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidDataType:
            return "Invalid data type"
        case .duplicateColumnName:
            return "Duplicate column name"
        }
    }
}

public enum DataParserError: Error {
    case invalidLineEnd
}

extension DataParserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidLineEnd:
            return "Invalid line end"
        }
    }
}
