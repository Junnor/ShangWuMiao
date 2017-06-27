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

class WordsCell: UITableViewCell {
    @IBOutlet weak var wordsTextView: UITextView!
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
    
    fileprivate var words = "这个人很懒，什么都没有留下"
    
    
    private var canSave = false {
        didSet {
            editItem.tintColor = canSave ? UIColor.white : UIColor.clear
        }
    }
    
    private var editItem: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "修改资料"
        
        editItem = UIBarButtonItem(title: "保存",
                                   style: .done,
                                   target: self,
                                   action: #selector(save))
        editItem.tintColor = canSave ? UIColor.white : UIColor.clear
        
        self.navigationItem.rightBarButtonItem = editItem
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    @objc private func save() {
    }
    
    @objc private func tapAction() {
        if let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 2)) as? WordsCell {
            cell.wordsTextView.resignFirstResponder()
        }
    }
    
    @objc private func keyboardNotification(notification: NSNotification) {
        canSave = true
        if let userInfo = notification.userInfo {
            var endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                let contentInset:UIEdgeInsets = UIEdgeInsets.zero
                tableView.contentInset = contentInset
                tableView.contentOffset = .zero
            } else {
                endFrame = self.view?.convert(endFrame!, from: nil)
                var contentInset:UIEdgeInsets = tableView.contentInset
                contentInset.bottom = endFrame!.size.height
                tableView.contentInset = contentInset
                tableView.contentOffset = CGPoint(x: 0, y: endFrame!.size.height)
            }
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view?.layoutIfNeeded() },
                           completion: nil)
        }
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
            if let cell = cell as? WordsCell {
                cell.wordsTextView.text = words
            }
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
