//
//  AttachmentCollectionViewCell.swift
//  Zoho Task
//
//  Created by prathap on 08/07/24.
//

import UIKit

class AttachmentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var attachmentImageView: UIImageView!
    
    var deleteClosure : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        layer.applyShadow(color: .black)
        layer.cornerRadius = 10
        
        attachmentImageView.layer.cornerRadius = 10
        
        closeButton.layer.cornerRadius = closeButton.frame.height / 2
        closeButton.layer.applyShadow(color: .white)
    }
    
    @IBAction func cellCloseButtonAction(_ sender: UIButton) {
        deleteClosure?()
    }
    
    func configure(with attachment: String, viewModel: TaskDetailsViewModel) {
        guard let image = viewModel.loadImageFromDocumentsDirectory(filename: attachment) else {
            attachmentImageView.image = UIImage(named: "PDF_Icon")
            return
        }
        attachmentImageView.image = image
    }
}
