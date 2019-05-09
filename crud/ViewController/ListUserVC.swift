//
//  ViewController.swift
//  crud
//
//  Created by Claudio Sepúlveda Huerta on 5/8/19.
//  Copyright © 2019 csh. All rights reserved.
//

import UIKit
import RealmSwift
import MGSwipeTableCell

class ListUserVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var barTitle: UINavigationItem!
    @IBOutlet weak var barAdd: UIBarButtonItem!
    
    var users : Results<User>!
    var user: User!
    let userDataManager = UserDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        usersTable.delegate = self
        usersTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.loadUsers()
        
        //set title to NavigationItem
        barTitle.title = NSLocalizedString("users", comment:"")
        barAdd.title = NSLocalizedString("add", comment: "")
    }
    
    //Carga los usuarios desde la BBDD
    func loadUsers() {
        self.users = userDataManager.loadUsers()
        self.usersTable.reloadData()
    }
    
    //Agregar usuario al presionar el botón
    @IBAction func addUserNavBar(_ sender: Any) {
        self.addUser()
    }
    
    //Con un Alert Dialog, se pide el nombre del usuario
    @objc func addUser() {
        let alertController = UIAlertController(title: NSLocalizedString("saveUser", comment:""),
                                                message: NSLocalizedString("enterNewUserName", comment:""),
                                                preferredStyle: .alert)
        alertController.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.delegate = self
                textField.placeholder = NSLocalizedString("newUser", comment:"")
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment:""),
                                         style: UIAlertAction.Style.cancel,
                                         handler: nil
        )
        let saveAction = UIAlertAction(title: NSLocalizedString("accept", comment:""),
                                       style: UIAlertAction.Style.default,
                                       handler: {[weak self] _ in
                                        if let textName = alertController.textFields?.first?.text {
                                            let character = textName.replacingOccurrences(of: " ", with: "")
                                            if character.count > 0 {
                                                self!.userDataManager.saveUser(textName)
                                                self!.usersTable.reloadData()
                                            } else {
                                                self?.errorAlert(self!.user)
                                            }
                                        }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "userCell"
        var cell = self.usersTable.dequeueReusableCell(withIdentifier: reuseIdentifier) as! UserCell?
        
        if cell == nil {
            cell = UserCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        }
        cell?.delegate = self //optional
        
        let currentPositionUsers = self.users[(indexPath as NSIndexPath).row]
        cell?.userName.text = currentPositionUsers.name
        
        //Configure right buttons from library MGSwipeTable
        
        //Delete User Button
        let deleteAction = MGSwipeButton(title: NSLocalizedString("delete", comment:""), backgroundColor: UIColor.red, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.dialogDeleteSample(currentPositionUsers)
            return true
        })
        
        //Edit User Button
        let editAction = MGSwipeButton(title: NSLocalizedString("edit", comment:""), backgroundColor: UIColor.blue, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.dialogEditSample(currentPositionUsers)
            return true
        })
        cell?.rightButtons = [deleteAction, editAction]
        cell?.rightSwipeSettings.transition = .static
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    //A través de un Alert Dialog, se edita el nombre del usuario
    func dialogEditSample(_ user : User){
        let alertController = UIAlertController(title: NSLocalizedString("editUser", comment:""),
                                                message: NSLocalizedString("enterNewUserName", comment:""),
                                                preferredStyle: .alert)
        alertController.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.delegate = self
                textField.placeholder = NSLocalizedString("editUser",comment:"")
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment:""),
                                         style: UIAlertAction.Style.cancel,
                                         handler: nil
        )
        let saveAction = UIAlertAction(title: NSLocalizedString("accept", comment:""),
                                       style: UIAlertAction.Style.default,
                                       handler: {[weak self] _ in
                                        if let textName = alertController.textFields?.first?.text {
                                            let character = textName.replacingOccurrences(of: " ", with: "")
                                            if character.count > 0 {
                                                self!.userDataManager.updateUser(user, newName: textName)
                                                self!.usersTable.reloadData()
                                            } else {
                                                self?.errorAlert(user)
                                            }
                                        }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Se manda un Alert Dialog, para confirmar el borrado del usuario
    func dialogDeleteSample(_ user : User){
        let alertController = UIAlertController(title: NSLocalizedString("deleteUser", comment:""),
                                                message: "",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment:""),
                                         style: UIAlertAction.Style.cancel,
                                         handler: nil)
        let deleteAction = UIAlertAction(title: NSLocalizedString("delete", comment:""),
                                         style: UIAlertAction.Style.default,
                                         handler: {[weak self] _ in
                                            self?.userDataManager.deleteUser(user)
                                            self?.usersTable.reloadData()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func errorAlert(_ user: User){
        let alertController = UIAlertController(title: NSLocalizedString("dialog.insert.valid.character", comment: ""), message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive) { (action) in
            self.dialogEditSample(user)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Comprobar carácteres válidos
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let inverseSet = CharacterSet(charactersIn:"abcdefghijklmnñopqrstuvwxyzABCDFGHIJKLMNÑPQRSTUVWXYZ/&@.-0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: " ")
        
        // limit to 4 characters
        let characterCountLimit = 20
        
        // We need to figure out how many characters would be in the string after the change happens
        let startingLength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return string == filtered && newLength <= characterCountLimit
    }
}
