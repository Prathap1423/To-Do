//
//  ViewControllerExtension.swift
//  Zoho Task
//
//  Created by prathap on 09/07/24.
//

import UIKit

private var activityIndicator: UIActivityIndicatorView?

extension UIViewController {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showLoadingIndicator() {
        // Ensure the indicator is not already visible
        if activityIndicator == nil {
            activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator?.color = .gray
            activityIndicator?.center = view.center
            activityIndicator?.startAnimating()
            view.addSubview(activityIndicator!)
        }
    }
    
    func hideLoadingIndicator() {
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }
}
