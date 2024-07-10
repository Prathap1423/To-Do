//
//  CompletedTasksViewController.swift
//  Zoho Task
//
//  Created by prathap on 05/07/24.
//

import UIKit

class CompletedTasksViewController: UIViewController {

    @IBOutlet weak var completedTasksTableView: UITableView!
    @IBOutlet weak var noResultFoundLabel: UILabel!
    
    private var viewModel = TaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadAllTasksData()
        completedTasksTableView.separatorStyle = .none
    }

    func bindViewModel() {
        viewModel.reloadTableViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.completedTasksTableView.reloadData()
            }
        }
        
        viewModel.noResultsClosure = { [weak self] isNoResults in
            DispatchQueue.main.async {
                self?.noResultFoundLabel.isHidden = !isNoResults
            }
        }
    }
    
    func loadAllTasksData() {
        viewModel.completedTask()
    }
    
}

extension CompletedTasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.completedTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.completedTasksTableViewCell.rawValue) as! AllTasksTableViewCells
        cell.cellView.layer.cornerRadius = 10
        cell.configureForCompletedTak(viewModel: viewModel, index: indexPath.row)
        cell.selectionClosure = { [weak self] in
            self?.didPressedCompletedBtn(selectedRow: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: StoryboardIdentifier.main.rawValue, bundle: .main).instantiateViewController(withIdentifier: ViewControllerIdentifier.taskDetailViewController.rawValue) as! TaskDetailViewController
        vc.viewModel = TaskDetailsViewModel(task: viewModel.filteredTasks[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didPressedCompletedBtn(selectedRow: Int) {
        var task = viewModel.completedTasks[selectedRow]
        task.isCompleted = !task.isCompleted
        viewModel.updateTask(task)
        loadAllTasksData()
        completedTasksTableView.reloadData()
    }
}
