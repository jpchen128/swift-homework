import Foundation
import SwiftCSV

public func parseSpecs(_ csv: String) async throws -> [Spec] {
    let csv = try CSV<Named>(string: csv)
    _ = try csv.rows.reduce(Set<String>(), {
        if $0.contains($1["column name"]!) {
            throw SpecsParserError.duplicateColumnName
        }
        return $0.union([$1["column name"]!])
    })
    return try csv.rows.map({ row in
        let width = Int(row["width"]!)!
        let dataType = try DataType(row["datatype"]!)
        return Spec(columnName: row["column name"]!, width: width, dataType: dataType)
    })
}
