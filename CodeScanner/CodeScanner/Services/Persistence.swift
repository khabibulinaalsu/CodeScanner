import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    
    private var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    private func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    private init() {
        container = NSPersistentContainer(name: "CodeScanner")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func isExisting(_ item: HistoryItem) async -> Bool {
        let context = newBackgroundContext()
        
        return await context.perform {
            let fetchRequest = CoreDataItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "content == %@", item.content)
            fetchRequest.fetchLimit = 1
            
            do {
                let count = try context.count(for: fetchRequest)
                return count > 0
            } catch {
                print("Error checking if item exists: \(error)")
                return false
            }
        }
    }
    
    func fetchCodes() async -> [HistoryItem] {
        let context = newBackgroundContext()
        
        return await context.perform {
            let fetchRequest = CoreDataItem.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "timestamp", ascending: false)
            ]
            
            do {
                let entities = try context.fetch(fetchRequest)
                return entities.map { $0.toHistoryItem() }
            } catch {
                print("Error fetching codes: \(error)")
                return []
            }
        }
    }
    
    func save(code item: HistoryItem) async {
        let context = newBackgroundContext()
        
        await context.perform {
            let fetchRequest = CoreDataItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "content == %@", item.content)
            fetchRequest.fetchLimit = 1
            
            do {
                let existingEntities = try context.fetch(fetchRequest)
                
                if let existingEntity = existingEntities.first {
                    existingEntity.title = item.title
                } else {
                    let entity = CoreDataItem(context: context)
                    entity.title = item.title
                    entity.content =  item.content
                    entity.timestamp = item.timestamp
                    entity.codeType = item.codeType.rawValue
                }
                
                try self.saveContext(context)
                
            } catch {
                print("Error saving item: \(error)")
            }
        }
    }
    
    
    private func saveContext(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
