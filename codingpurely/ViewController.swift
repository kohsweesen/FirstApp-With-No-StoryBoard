//
//  ViewController.swift
//  codingpurely
//
//  Created by Koh Sweesen on 5/5/18.
//  Copyright © 2018 Koh Sweesen. All rights reserved.
//

import UIKit
import os.log

class ViewController: UITableViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "To Do List"
        
        //NAVIGATION TITLE
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white] //NOTE
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes//NOTE: TWO TYPES LARGE OR NO LARGE TITLE
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor.red
        
        //NAVIGTION RIGHT
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButton))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        //NAVIGATION LEFT
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white

       
        
        tableView.register(MainCell.self, forCellReuseIdentifier: cellId)
       
        if let savedData = loadMeals(){
        randomArray += savedData
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //this reload data here is important
    override func viewWillAppear(_ animated: Bool) {//NOTE
        tableView.reloadData()
        
      
    }
    
    func saveMeals() {
        _ = NSKeyedArchiver.archiveRootObject(randomArray, toFile: ToDoItem.ArchiveURL.path)
    }
    
    private func loadMeals() -> [ToDoItem]?  {
    return NSKeyedUnarchiver.unarchiveObject(withFile: ToDoItem.ArchiveURL.path) as? [ToDoItem]
    }
    
    //VARIABLES
    
    let cellId = "cellId"
    var randomArray = [ToDoItem]()
    

    
    
    
    
    //CONFIGURATION OF ALERT CONTROLLER WHEN "ADD" BAR BUTTON IS PRESSED
    
    @objc func addBarButton(){
        
        tableView.isEditing = false
        
        let popUpWindow = UIAlertController(title: "Add New Item", message: "Type in the name below", preferredStyle: .alert)
      
        popUpWindow.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in self.dismiss(animated: true, completion: nil)}))
        popUpWindow.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in alertDonebutton() }))
        popUpWindow.isSpringLoaded = false
    
        func alertDonebutton(){
           
            let textfield = popUpWindow.textFields![0]
            
            if textfield.text == ""{
                self.dismiss(animated: true, completion: nil)
            }else{
                
                let text = textfield.text
                let item = ToDoItem(listItem: text!)
                self.randomArray.append(item!)
                saveMeals()
                
                
                //thisreload data below is important
                self.tableView.reloadData()
        
            }        }
        
        
        func createTextField(textfield: UITextField){
            
            textfield.textColor = UIColor.red
            textfield.placeholder = "just type its ok"
        }
        
        
        popUpWindow.addTextField(configurationHandler: createTextField)
        present(popUpWindow, animated: true, completion: nil)
        
    }
    
    
    
    
    //TABLEVIEW FUNCTIONS
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return randomArray.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MainCell
        let item = loadMeals()![indexPath.row]
        cell.cellLabel.text = item.listItem
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            randomArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .none)
            tableView.reloadData() //apparently the app crashed if this line doesnt exist i have no idea why
            
        }
    }
    
    
    
    
    
    
    //WHEN THE CELL IS SELECTED, PRESENT THe second CView CONTROLLER
   
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let destination = secondVC()
        let each = randomArray[indexPath.row]
        destination.myTextField.text = each.listItem
        destination.cellNumber = indexPath.row
        navigationController?.pushViewController(destination, animated: true)
       
   //

    }
    
    //this function exists so that the second view controller can pass back some data by calling this function. when popViewController is called and this func below is called, the viewwillappear func will reload the data with new elements in the array. Theres probablyu a better way of pass data between view controllers....
    
    func goBackToFirstVC(data: String, integer: Int){
        
        let realInt = integer
        randomArray.remove(at: realInt)
        let newItem = ToDoItem(listItem: data)
        randomArray.insert(newItem!, at: integer)
        print(randomArray)
        tableView.reloadData()
    }
}




    //CUSTOM CLASS FOR TABLEVIEW CELL


class MainCell: UITableViewCell {


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "cellId")
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        setupView()
    }

    
   
    
    func setupView(){
        addSubview(cellLabel)
        cellLabel.frame = CGRect(x: 42, y: 0, width: 700, height: 50)
    }
    
    
    
    let cellLabel : UILabel = {
        let cellLabel = UILabel()
        cellLabel.textColor = UIColor.black
        return cellLabel
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





    //CUSTOM CLASS FOR THE SECOND VIEW CONTROLLER


class secondVC: UIViewController,UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        myTextField.delegate = self
        setupLabel()
        setupBackButton()
        setupTextField()
        setupDonebutton()
        
        
    }

    //this cell number is used to keep track of which cell was pressed, so that the array elemnent can be edited accordingly
    
    var cellNumber:Int?
    
    //Navigation bar setup:

    
    func setupBackButton(){
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonFunction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func setupDonebutton(){
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonFunction))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.tintColor = UIColor.white
        
        if myTextField.text == ""{
            doneButton.isEnabled = false
        }else{
            doneButton.isEnabled = true
        }
        print("setup button again")
        
    }
    
    @objc func doneButtonFunction(){
        
        //prevent done button to function when the textfield is empty...
        if myTextField.text == ""{labelSecondVC.text = "Please Write Something..."} else{
    
        let a = self.navigationController?.viewControllers[0] as! ViewController //NOTE
        a.goBackToFirstVC(data: myTextField.text!, integer: cellNumber!)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.popViewController(animated: true)
        a.saveMeals()

        }
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        myTextField.resignFirstResponder()
        return true
    }
    
    @objc func backButtonFunction(){
       navigationController?.popViewController(animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
        
    
    
    func setupLabel(){
        self.view.addSubview(labelSecondVC)
    }
    
    
    
    let labelSecondVC: UILabel = {
        let label = UILabel()
        label.text = "Please Edit The Text Below"
        label.frame = CGRect(x: 100, y: 100, width: 300, height: 100)
        return label
    }()
    
    
    func setupTextField(){
        self.view.addSubview(myTextField)
    }
    
    let myTextField:UITextField = {
        let newTextField = UITextField()
        newTextField.frame = CGRect(x: 50, y: 250, width: 300, height: 40)
        newTextField.borderStyle = UITextBorderStyle.roundedRect
        return newTextField
    }()
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


class ToDoItem: NSObject,NSCoding{

    
    var listItem: String!
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("listItem")
    
    init?(listItem: String){
        
        self.listItem = listItem
    }
    
    struct PropertyKey {
        static let listItem = "listItem"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(listItem,forKey: PropertyKey.listItem)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.listItem) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(listItem:name)
        
    }
    
    
}


