import Foundation
import CoreData


extension CoreDataItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataItem> {
        return NSFetchRequest<CoreDataItem>(entityName: "CoreDataItem")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var title: String
    @NSManaged public var codeType: String
    @NSManaged public var content: String
    
    func toHistoryItem() -> HistoryItem {
        return HistoryItem(
            id: UUID(),
            title: title,
            content: content,
            codeType: CodeType.fromRawValue(codeType),
            timestamp: timestamp
        )
    }
    
}

extension CoreDataItem : Identifiable {

}
