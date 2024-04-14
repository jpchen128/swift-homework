import Foundation
import SwiftCSV

// Parsing specs in CSV string according to given specifications.
// It returns an array of Spec.
public func parseSpecs(_ csv: String) async throws -> [Spec] {
    let csv = try CSV<Named>(string: csv)
    guard csv.header == ["column name", "width", "datatype"] else {
        throw SpecsParserError.invalidCSVColumnName
    }
    _ = try csv.rows.reduce(Set<String>(), {
        if $0.contains($1["column name"]!) {
            throw SpecsParserError.duplicateSpecColumnName
        }
        return $0.union([$1["column name"]!])
    })
    return try csv.rows.map({ row in
        let width = Int(row["width"]!)!
        let dataType = try DataType(row["datatype"]!)
        return Spec(columnName: row["column name"]!, width: width, dataType: dataType)
    })
}
