import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct CalendarEventPayload: Codable, Transferable {
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: CalendarEventPayload.self, contentType: .data)
    }
}
