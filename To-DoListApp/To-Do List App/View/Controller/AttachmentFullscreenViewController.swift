//
//  AttachmentFullscreenViewController.swift
//  Zoho Task
//
//  Created by prathap on 08/07/24.
//

import UIKit
import PDFKit

class AttachmentFullscreenViewController: UIViewController {
    
    var attachmentImage: UIImage?
    var attachmentPDF: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        showAttachment()
    }
    
    func showAttachment() {
                
        if let savedImage = attachmentImage {
            let imageView = UIImageView(frame: self.view.bounds)
            imageView.contentMode = .scaleAspectFit
            imageView.image = savedImage
            self.view.addSubview(imageView)
        } else {
            if let attachmentPDF {
                let pdfView = PDFView(frame: self.view.bounds)
                pdfView.autoScales = true
                pdfView.document = PDFDocument(data: attachmentPDF)
                self.view.addSubview(pdfView)
            }
        }
    }
}
