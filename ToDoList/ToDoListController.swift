//
//  TableViewController.swift
//  ToDoList
//
//  Created by Анна on 07.09.2020.
//  Copyright © 2020 ar2041@bk.ru. All rights reserved.
//

import UIKit
import CoreData

class ToDoListController: UITableViewController {
    
    enum ListMode {
        case new, done, deleted
    }
    
    private lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var tasksStorate: TasksStorage!
    private var newTasks = [Task]()
    private var doneTasks = [Task]()
    private var deletedTasks = [Task]()
    private var listMode = ListMode.new
    private var tasks: [Task] {
        switch listMode {
        case .new:
            return newTasks
        case.done:
            return doneTasks
        case .deleted:
            return deletedTasks
        }
    }
    
    @IBAction func actionAddTask(_ sender: Any) {
        let alertController = UIAlertController(title: "New task", message: "Enter task name", preferredStyle: .alert)
        alertController.addTextField()
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let field = alertController.textFields?.first
            if let newTaskName = field?.text {
                self.addTask(withName: newTaskName)
            }
        }
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func addTask(withName: String){
        do {
            let task = try tasksStorate.add(withName: withName)
            newTasks.insert(task, at: 0)
            self.tableView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func doneTask(byIndex index: Int){
        do {
            let task = listMode == .new ? newTasks.remove(at: index) : deletedTasks.remove(at: index)
            try tasksStorate.done(task: task)
            doneTasks.insert(task, at: 0)
            tableView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func deleteTask(byIndex index: Int){
        do {
            let task = listMode == .new ? newTasks.remove(at: index) : doneTasks.remove(at: index)
            try tasksStorate.delete(task: task)
            deletedTasks.insert(task, at: 0)
            tableView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initTaskLists()
    }
    
    private func initTaskLists() {
        do {
            tasksStorate = try TasksStorage(context: context)
            for task in tasksStorate.items {
                if task.is_done {
                    doneTasks.append(task)
                } else if task.is_deleted {
                    deletedTasks.append(task)
                } else {
                    newTasks.append(task)
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard listMode != .done else {
            return nil
        }
        return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .normal, title: "Done", handler: { (action, view, completionHandler) in
            self.doneTask(byIndex: indexPath.row)
            completionHandler(true)
        })])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard listMode != .deleted else {
            return nil
        }
        return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completionHandler) in
            self.deleteTask(byIndex: indexPath.row)
            completionHandler(true)
        })])
    }
}
