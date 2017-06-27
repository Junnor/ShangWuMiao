//
//  ProfileViewController.swift
//  ShangWuMiao
//
//  Created by nyato喵特 on 2017/6/27.
//  Copyright © 2017年 moelove. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
     @IBOutlet weak var avatarLabel: UILabel!
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    fileprivate let titles: Dictionary<Int, String> = [0: "昵称",
                                                       1: "性别",
                                                       2: "城市"]
    fileprivate let details: Dictionary<Int, String> = [0: User.shared.uname,
                                                        1: User.shared.gender,
                                                        2: User.shared.city]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "修改资料"
        
        NotificationCenter.default.addObserver(self.tableView,
                                               selector: #selector(self.tableView.nyato_keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }

}


extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 1
        if section == 1 {
            count = 3
        } else if section == 2 {
            count = 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var identifier = "textIdentifier"
        if indexPath.section == 0 {
            identifier = "avatarIdentifier"
        } else if indexPath.section == 2 {
            identifier = "wordsIdentifier"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if indexPath.section == 0 {
            if let cell = cell as? ProfileCell {
                cell.avatarImageView?.image = User.shared.avatar
                cell.avatarImageView?.layer.cornerRadius = 35
                cell.avatarImageView?.layer.masksToBounds = true
                cell.avatarLabel?.text = "修改头像"
            }
        } else if indexPath.section == 2 {
        } else {
            cell.textLabel?.text = titles[indexPath.row]
            cell.detailTextLabel?.text = details[indexPath.row]
        }
        
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    private func avatarEdit() {
        let alert = UIAlertController(title: "头像修改", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "拍照 ", style: .default) { (action) in
            // TODO: -
        }
        let photo = UIAlertAction(title: "从手机相册选择", style: .default) { (action) in
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.delegate = self
            imagePickerVC.allowsEditing = true
            self.present(imagePickerVC, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(camera)
        alert.addAction(photo)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            avatarEdit()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 44
        if indexPath.section == 0 {
            height = 100
        } else if indexPath.section == 2 {
            height = 200
        }
        
        return height
    }
}


extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            User.avatarUpload(image, completionHandler: { (success, info) in
                SVProgressHUD.showInfo(withStatus: info)
                if success {
                    DispatchQueue.main.async {
                        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileCell
                        cell?.avatarImageView.image = image
                        User.shared.avatar = image
                        self.tableView.reloadData()
                    }
                }
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
}
