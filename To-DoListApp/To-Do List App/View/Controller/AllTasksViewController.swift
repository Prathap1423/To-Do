//
//  AllTasksViewController.swift
//  Zoho Task
//
//  Created by prathap on 05/07/24.
//

import UIKit
import CoreLocation

class AllTasksViewController: UIViewController, UISearchControllerDelegate {
    
    @IBOutlet weak var noResultFoundLabel: UILabel!
    @IBOutlet weak var allTasksTableView: UITableView!
    @IBOutlet weak var bottomSheetHeight: NSLayoutConstraint!
    @IBOutlet weak var inputTaskField: UITextField!
    @IBOutlet weak var dueDateBtn: UIButton!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var priorityButtonCollections: [UIButton]!
    @IBOutlet weak var addTaskView: UIView! {
        didSet {
            addTaskView.layer.cornerRadius = 10
        }
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    var taskPriority: TaskPriority = .low
    var keyboardHeight: CGFloat?
    var selectedDate: Date?
    let locationManager = CLLocationManager()
    private var viewModel = TaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureSearchController()
        configureNavigationButtonItems()
        configLocation()
        bindViewModel()
        UIConfigure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.loadAllTasksData()
    }
    
    private func UIConfigure() {
        dueDateBtn.layer.cornerRadius = 10
        allButton.backgroundColor = .white
        allButton.layer.applyShadow(color: .black)
        allButton.layer.borderWidth = 1
        allButton.layer.borderColor = UIColor.black.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        priorityButtonCollections.forEach{ $0.layer.cornerRadius = 10 }
    }
    
    private func configLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            if inputTaskField.isFirstResponder {
                didPressedAddBtn(UIButton())
            }
        }
    }
    
    func configureNavigationButtonItems() {
        let sortByNameMenu = UICommand(title: SortType.name.rawValue, action: #selector(sortByNameMenuAction(_:)))
        let sortByDueDateMenu = UICommand(title: SortType.dueDate.rawValue, action: #selector(sortByDueDateMenuAction(_:)))
        sortByNameMenu.state = .on
        let menu = UIMenu(title: "Filter", children: [sortByNameMenu, sortByDueDateMenu])
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "FilterIcon"), style: .plain, target: self, action: nil)
        barButtonItem.menu = menu
        barButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc func sortByNameMenuAction(_ sender: UICommand) {
        viewModel.selectedSortType = .name

        let sortByNameMenu = navigationItem.rightBarButtonItem?.menu?.children.first as? UICommand
        let sortByDueDateMenu = navigationItem.rightBarButtonItem?.menu?.children.last as? UICommand

        sortByNameMenu?.state = .on
        sortByDueDateMenu?.state = .off
    }

    @objc func sortByDueDateMenuAction(_ sender: UICommand) {
        viewModel.selectedSortType = .dueDate

        let sortByNameMenu = navigationItem.rightBarButtonItem?.menu?.children.first as? UICommand
        let sortByDueDateMenu = navigationItem.rightBarButtonItem?.menu?.children.last as? UICommand

        sortByNameMenu?.state = .off
        sortByDueDateMenu?.state = .on
    }
    
    func configureSearchController() {
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.delegate = self
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.delegate = self
        }
        
        searchController.searchBar.tintColor = .black
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    func bindViewModel() {
        viewModel.reloadTableViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.allTasksTableView.reloadData()
            }
        }
        
        viewModel.noResultsClosure = { [weak self] isNoResults in
            DispatchQueue.main.async {
                self?.noResultFoundLabel.isHidden = !isNoResults
            }
        }
    }
    
    @IBAction func addTaskBtnAction(_ sender: UIButton) {
        guard let taskName = inputTaskField.text, !taskName.isEmpty else {
            showAlert(title: "", message: "Task name field is required")
            return
        }
        addTask()
        inputTaskField.text = ""
        dueDateBtn.setTitle(Date().userFormat(), for: .normal)
        segmentedControl.selectedSegmentIndex = 0
        inputTaskField.resignFirstResponder()
        blurView.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetHeight.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func addTask() {
        
        if let taskName = inputTaskField.text, !taskName.isEmpty {
            
            let task = Task(id: UUID(), name: taskName, description: "", isCompleted: false, priority: taskPriority, dueDate: selectedDate ?? Date(), attachment: [])
            viewModel.addTask(task)
        }
    }
    
    @IBAction func didPressedDueDate(_ sender: UIButton) {
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        let alertController = UIAlertController(title: "Select Due Date", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        alertController.view.addSubview(datePicker)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 8).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -8).isActive = true
        datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let selectAction = UIAlertAction(title: "Select", style: .default) { _ in
            self.selectedDate = datePicker.date
            self.dueDateBtn.setTitle(datePicker.date.userFormat(), for: .normal)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        if isIpad {
            // Configure the popover presentation controller for iPad
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = dueDateBtn
                popoverController.sourceRect = dueDateBtn.bounds
                popoverController.permittedArrowDirections = .down
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func didPressedChoosePriority(_ sender: UIButton) {
        
        priorityButtonCollections.forEach { $0.backgroundColor = .systemGray6 }
        priorityButtonCollections.forEach { $0.layer.shadowColor = UIColor.white.cgColor }
        priorityButtonCollections.forEach { $0.layer.borderWidth = 0 }
        sender.backgroundColor = .white
        sender.layer.applyShadow(color: .black)
        sender.layer.borderWidth = 1
        sender.layer.borderColor = UIColor.black.cgColor
        switch sender.tag {
        case 0:
            viewModel.selectedPriority = .all
        case 1:
            viewModel.selectedPriority = .low
        case 2:
            viewModel.selectedPriority = .medium
        case 3:
            viewModel.selectedPriority = .high
        default:
            break
        }
    }
    
    @IBAction func didPressedAddBtn(_ sender: UIButton) {
        
        inputTaskField.becomeFirstResponder()
        blurView.isHidden = false
        dueDateBtn.setTitle(Date().userFormat(), for: .normal)
        print(isLandscape)
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetHeight.constant = (self.keyboardHeight ?? 100) + (isIpad ? 80 : isLandscape ? 80 : 50)
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            taskPriority = .low
        case 1:
            taskPriority = .medium
        case 2:
            taskPriority = .high
        default:
            break
        }
    }
    
    @IBAction func closeBtnAction(_ sender: UIButton) {
        inputTaskField.text = ""
        dueDateBtn.setTitle(Date().userFormat(), for: .normal)
        segmentedControl.selectedSegmentIndex = 0
        inputTaskField.resignFirstResponder()
        blurView.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetHeight.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

extension AllTasksViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.isSearching = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchedText = searchBar.searchTextField.text ?? ""
        viewModel.isSearching = true
        viewModel.searchQuery = searchedText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewModel.isSearching = true
    }
}

extension AllTasksViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        viewModel.searchQuery = newText
        return true
    }
}

extension AllTasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.allTasksTableViewCell.rawValue, for: indexPath) as! AllTasksTableViewCells
        cell.configure(viewModel: viewModel, index: indexPath.row)
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

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.deleteTask(selectedRow: indexPath.row)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func didPressedCompletedBtn(selectedRow: Int) {
        guard selectedRow < viewModel.filteredTasks.count else { return }
        var task = viewModel.filteredTasks[selectedRow]
        task.isCompleted = !task.isCompleted
        viewModel.updateTask(task)
    }
    
    func deleteTask(selectedRow: Int) {
        let task = viewModel.filteredTasks[selectedRow]
        viewModel.deleteTask(task.id)
    }
}
