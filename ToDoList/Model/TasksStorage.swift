import CoreData

let firstPosition = 0

class TasksStorage {
    private let context: NSManagedObjectContext
    private(set) var items: [Task]
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        items = []
        items = try fetchTasks()
    }
    
    func add(withName: String) throws -> Task {
        let task = createTask()
        task.name = withName
        task.order = Int16(items.endIndex - 1)
        items.append(task)
        try save()
        return task
    }
    
    func delete(task: Task) throws {
        task.is_deleted = true
        try save()
    }
    
    func done(task: Task) throws {
        task.is_done = true
        try save()
    }
    
    private func save() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    private func createTask() -> Task {
        let task = Task(context: context)
        task.is_deleted = false
        task.is_done = false
        
        return task
    }
    
    private func createFetchRequest() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: false)]
        return request
    }
    
    private func fetchTasks() throws -> [Task] {
        return try context.fetch(createFetchRequest())
    }
}
