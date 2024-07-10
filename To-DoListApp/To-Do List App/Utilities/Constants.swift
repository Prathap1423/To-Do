//
//  Constants.swift
//  Offline App
//
//  Created by Hendry Christopher on 06/04/24.
//

import UIKit

var isIpad: Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

var isLandscape: Bool {
    return UIDevice.current.orientation.isLandscape
}

enum StoryboardIdentifier: String {
    case main = "Main"
}

enum ViewControllerIdentifier: String {
    
    case taskDetailViewController = "TaskDetailViewController"
}

enum CellIdentifier: String {
    
    case attachmentCollectionViewCell = "AttachmentCollectionViewCell"
    case allTasksTableViewCell = "AllTasksTableViewCell"
    case completedTasksTableViewCell = "CompletedTasksTableViewCell"
}
