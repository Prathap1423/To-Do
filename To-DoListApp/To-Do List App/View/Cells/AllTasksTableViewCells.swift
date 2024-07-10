//
//  AllTasksTableViewCells.swift
//  Zoho Task
//
//  Created by prathap on 06/07/24.
//

import UIKit

class AllTasksTableViewCells: UITableViewCell {
    
    @IBOutlet var taskNameLabel: UILabel!
    @IBOutlet var priorityLabel: UILabel!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var selectionButton: UIButton!
    @IBOutlet var cellView: UIView!
    
    var selectionClosure : (() -> Void)?
    
    @IBAction func didPressedSelectBtn(_ sender: UIButton) {
        selectionClosure?()
    }
    
    func configure(viewModel: TaskViewModel, index: Int) {
        taskNameLabel.attributedText = viewModel.attributedTaskName(index: index)
        priorityLabel.text = viewModel.priorityTitle(index: index)
        dueDateLabel.text = viewModel.dueDateString(index: index).userFormat()
        selectionButton.setImage(viewModel.completionImage(index: index), for: .normal)
        dueDateLabel.textColor = viewModel.isOverdue(index: index) ? .red : .black
        setupViewStyling()
    }
    
    func configureForCompletedTak(viewModel: TaskViewModel, index: Int) {
        taskNameLabel.attributedText = viewModel.attributedCompletedTaskName(index: index)
        priorityLabel.text = viewModel.priorityTitleForCompletedTask(index: index)
        dueDateLabel.text = viewModel.dueDateStringForCompletedTask(index: index).userFormat()
        selectionButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        dueDateLabel.textColor = .black
        setupViewStyling()
    }
    
    private func setupViewStyling() {
        cellView.layer.cornerRadius = 10
        priorityLabel.layer.cornerRadius = 8
        priorityLabel.layer.masksToBounds = true
        dueDateLabel.layer.cornerRadius = 8
        dueDateLabel.layer.masksToBounds = true
    }
}
