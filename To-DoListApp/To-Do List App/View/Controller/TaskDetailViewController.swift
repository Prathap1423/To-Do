//
//  TaskDetailViewController.swift
//  Zoho Task
//
//  Created by prathap on 06/07/24.
//

import UIKit
import WebKit
import PDFKit
import MobileCoreServices
import UniformTypeIdentifiers

class TaskDetailViewController: UIViewController {
    
    @IBOutlet weak var attachmentCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UIView!
    @IBOutlet weak var taskDescriptionView: UIView!
    @IBOutlet weak var otherOptionsView: UIView!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var dueDateSelectedView: UIView!
    @IBOutlet weak var selectedDueDateLabel: UILabel!
    @IBOutlet weak var prioritySelectedView: UIView!
    @IBOutlet weak var selectedPriorityLabel: UILabel!
    @IBOutlet weak var attachmentAddedView: UIView!
    @IBOutlet weak var addedAttachmentLabel: UILabel!
    @IBOutlet weak var attachmentButton: UIButton!
    
    private var selectedPriority: TaskPriority?
    private var selectedDate: Date?
    
    var viewModel: TaskDetailsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureNavigationButtonItems()
        updateTaskInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.isHidden = viewModel?.selectedTask?.attachment.count == 0
    }
    
    private func configureNavigationButtonItems() {
        title = "Task detail info"
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTask(_:)))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func saveTask(_ sender: UIBarButtonItem) {
        
        guard var task = viewModel?.selectedTask else { return }
        
        guard let taskName = taskNameTextField.text, !taskName.isEmpty else {
            showAlert(title: "", message: "Task name field is required")
            return
        }
        
        task.name = taskName
        task.description = descriptionTextView.text
        task.dueDate = selectedDate ?? task.dueDate
        task.priority = selectedPriority ?? task.priority
        viewModel?.updateTask(task)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupView() {
        taskDescriptionView.layer.cornerRadius = 10
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.separator.cgColor
        descriptionTextView.layer.cornerRadius = 10
        otherOptionsView.layer.cornerRadius = 10
        selectedPriorityLabel.layer.cornerRadius = 10
        selectedPriorityLabel.layer.masksToBounds = true
        selectedDueDateLabel.layer.masksToBounds = true
        selectedDueDateLabel.layer.cornerRadius = 10
        addedAttachmentLabel.layer.cornerRadius = 10
        taskDescriptionView.layer.applyShadow(color: .black)
        otherOptionsView.layer.applyShadow(color: .black)
    }
    
    private func updateTaskInfo() {
        guard let task = viewModel?.selectedTask else { return }
        
        taskNameTextField.text = task.name
        descriptionTextView.text = task.description
        selectedDueDateLabel.text = task.dueDate.userFormat()
        selectedPriorityLabel.text = task.priority.title
    }
    
    @IBAction func dueDateButtonPressed(_ sender: UIButton) {
        showDatePicker()
    }
    
    @IBAction func priorityButtonPressed(_ sender: UIButton) {
        showPriorityOptions()
    }
    
    @IBAction func attachmentButtonPressed(_ sender: UIButton) {
        showAttachmentFormatOptions()
    }
    
    private func getImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: { [weak self] in
            self?.hideLoadingIndicator()
        })
    }
    
    private func getPDF() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: {  [weak self] in
            self?.hideLoadingIndicator()
        })
    }
}

extension TaskDetailViewController {
    
    func showDatePicker() {
        
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
            self.selectedDueDateLabel.text = datePicker.date.userFormat()
            self.dueDateSelectedView.isHidden = false
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        if isIpad {
            // Configure the popover presentation controller for iPad
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = selectedDueDateLabel
                popoverController.sourceRect = selectedDueDateLabel.bounds
                popoverController.permittedArrowDirections = .up
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showPriorityOptions() {
        
        let alertController = UIAlertController(title: "Select Priority", message: nil, preferredStyle: .actionSheet)
        let highAction = UIAlertAction(title: "High", style: .default) { _ in
            self.setPriority(.high)
        }
        let mediumAction = UIAlertAction(title: "Medium", style: .default) { _ in
            self.setPriority(.medium)
        }
        let lowAction = UIAlertAction(title: "Low", style: .default) { _ in
            self.setPriority(.low)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(highAction)
        alertController.addAction(mediumAction)
        alertController.addAction(lowAction)
        alertController.addAction(cancelAction)
        
        if isIpad {
            // Configure the popover presentation controller for iPad
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = selectedPriorityLabel
                popoverController.sourceRect = selectedPriorityLabel.bounds
                popoverController.permittedArrowDirections = .up
            }
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showAttachmentFormatOptions() {
        
        let alertController = UIAlertController(title: "Select Format", message: nil, preferredStyle: .actionSheet)
        let imageAction = UIAlertAction(title: "Image", style: .default) { _ in
            self.showLoadingIndicator()
            self.getImage()
        }
        let pdfAction = UIAlertAction(title: "PDF", style: .default) { _ in
            self.showLoadingIndicator()
            self.getPDF()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(imageAction)
        alertController.addAction(pdfAction)
        alertController.addAction(cancelAction)
        
        if isIpad {
            // Configure the popover presentation controller for iPad
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = attachmentButton
                popoverController.sourceRect = attachmentButton.bounds
                popoverController.permittedArrowDirections = .up
            }
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func setPriority(_ priority: TaskPriority) {
        self.selectedPriorityLabel.text = " \(priority.title) "
        self.selectedPriorityLabel.layer.cornerRadius = 10
        self.prioritySelectedView.isHidden = false
        self.selectedPriority = priority
    }
    
    func showAttachment(attachmentData: String) {
        let fullImageViewController = AttachmentFullscreenViewController()
        fullImageViewController.attachmentImage = viewModel?.loadImageFromDocumentsDirectory(filename: attachmentData)
        fullImageViewController.attachmentPDF = viewModel?.loadPDFFromDocumentsDirectory(filename: attachmentData)
        self.present(fullImageViewController, animated: true, completion: nil)
    }
    
    private func updateCollectionViewUI() {
        self.collectionView.isHidden = viewModel?.selectedTask?.attachment.count == 0
    }
}

extension TaskDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.selectedTask?.attachment.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.attachmentCollectionViewCell.rawValue, for: indexPath) as! AttachmentCollectionViewCell
        if let attachment = viewModel?.selectedTask?.attachment[indexPath.row] {
            if let viewModel {
                cell.configure(with: attachment,viewModel: viewModel)
                cell.deleteClosure = {
                    self.deleteAttachment(index: indexPath.row)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let attachment = viewModel?.selectedTask?.attachment[indexPath.row] {
            showAttachment(attachmentData: attachment)
        }
    }
    
    func deleteAttachment(index: Int) {
        viewModel?.selectedTask?.attachment.remove(at: index)
        if let task = viewModel?.selectedTask {
            viewModel?.updateTask(task)
        }
        attachmentCollectionView.reloadData()
        updateCollectionViewUI()
    }
}

extension TaskDetailViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        // Handle the selected file
        
        if selectedFileURL.pathExtension == "pdf" {
            do {
                let pdfData = try Data(contentsOf: selectedFileURL)
                
                if let filename = savePDFToDocumentsDirectory(pdfData) {
                    viewModel?.selectedTask?.attachment.append(filename)
                    if let task = viewModel?.selectedTask {
                        viewModel?.updateTask(task)
                    }
                    updateCollectionViewUI()
                    attachmentCollectionView.reloadData()
                }
            } catch {
                print("Error reading PDF data: \(error.localizedDescription)")
            }
        } else {
            print("Selected file is not a PDF")
            // Handle if the selected file is not a PDF
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Handle the cancel action
        print("Document picker was cancelled")
    }
    
    func savePDFToDocumentsDirectory(_ pdfData: Data) -> String? {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = paths.first else {
            return nil
        }
        
        let filename = UUID().uuidString + ".pdf"
        let fileURL = documentDirectory.appendingPathComponent(filename)
        
        do {
            try pdfData.write(to: fileURL)
            return filename
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }

}

extension TaskDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // UIImagePickerControllerDelegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Handle the selected image
            print("Selected image: \(selectedImage)")
            
            if let filename = saveImageToDocumentsDirectory(selectedImage) {
                viewModel?.selectedTask?.attachment.append(filename)
                if let task = viewModel?.selectedTask {
                    viewModel?.updateTask(task)
                }
                updateCollectionViewUI()
                attachmentCollectionView.reloadData()
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Handle the cancel action
        picker.dismiss(animated: true, completion: nil)
    }
    
    func saveImageToDocumentsDirectory(_ image: UIImage) -> String? {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = paths.first else {
            return nil
        }
        
        let filename = UUID().uuidString + ".jpg"
        let fileURL = documentDirectory.appendingPathComponent(filename)
        
        if let data = image.jpegData(compressionQuality: 0.5) {
            do {
                try data.write(to: fileURL)
                return filename
            } catch {
                print("Error saving image: \(error)")
                return nil
            }
        }
        
        return nil
    }
    
}
