//
//  ViewController.swift
//  Firebase Notes
//
//  Created by KELSEY COLLINS on 1/4/23.
//
class Student{
    var name: String
    var age: Int
    var key = ""
    
    //creating a reference to firebase(add)
    var ref = Database.database().reference()
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    // read from Firebase
    init(dict: [String: Any]){
        //go though Dict and find name to store it to n
        if let n = dict["name"] as? String{
            name = n
        }
        else{
            name = "No Name"
        }
        if let a = dict["age"] as? Int{
            age = a
        }
        else{
            age = 0
        }
        
        
    }
    
    func saveToFirebase(){
        var dict = ["name": name, "age": age] as [String: Any]
        //.childByAutoId() is the key
        key = ref.child("student2").childByAutoId().key ?? "0"
        ref.child("student2").child("key").setValue(dict)
    }
    
    func deleteFromFirebase(){
        //find the key and remove the value(value=names and age)
        ref.child("student2").child(key).removeValue()
    }
    func editOnFirebase(){
        //dict key is the sting name"name" and age"age"
        let dict = ["name": name, "age": age] as! [String: Any]
        ref.child("students").child(key).updateChildValues(dict)
    }
    
    func equals(stu: Student)-> Bool{
        if stu.name == name && stu.age == age{
            return true
        }
        else{
            return false
        }
        
      
    }
    
    
}



import UIKit
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var ageTextFieldOutlet: UITextField!
    
    var ref: DatabaseReference!
    var names=[String]()
    var students = [Student]()
    var lastStudent = Student(name: "", age: 0)
    var selectedIndex = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //need these 2 lines to connecet to tableView
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        
        
        
        //ref is now reference to Database
        ref = Database.database().reference()
        //reading from a database
        //automatilly called at start amd for every child is added
        ref.child("students").observe(.childAdded) { snapshot in
            let name = snapshot.value as! String
            self.names.append(name)
            self.tableViewOutlet.reloadData()
        }
        //when adding people, it will show on another phone
        ref.child("student2").observe(.childAdded) { snapshot in
            var dict = snapshot.value as! [String: Any]
            var student = Student(dict: dict)
            //takes the snapshots(with all information like key and value) and set it to object key
            student.key = snapshot.key
            if !(self.lastStudent.equals(stu: student)){
                self.students.append(student)
                self.tableViewOutlet.reloadData()
            }
            
        }
        //when removing on one phone will show on the other phone
        ref.child("student2").observe(.childRemoved) { snapshot in
            for i in 0..<self.students.count{
                if self.students[i].key == snapshot.key{
                    self.students.remove(at: i)
                    self.tableViewOutlet.reloadData()
                    break
                }
            }
        }
        
        
        //when removing on one phone will show on the other phone
        ref.child("student2").observe(.childChanged) { snapshot in
            let value = snapshot.value as! [String: Any]
            for i in 0..<self.students.count{
                if self.students[i].key == snapshot.key{
                    self.students[i].name = value["name"] as! String
                    self.students[i].age = value["age"] as! Int
                    self.tableViewOutlet.reloadData()
                    break
                }
            }
            
            
        }
    }
        
        
        
        @IBAction func saveButton(_ sender: UIButton) {
            let name = textFieldOutlet.text!
            //names.append(name)
            ref.child("students").childByAutoId().setValue(name)
        }
        
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return students.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "myCell")!
            
            cell.textLabel?.text = students[indexPath.row].name
            cell.detailTextLabel?.text =  String(students[indexPath.row].age)
            
            return cell
        }
        
        
        @IBAction func saveStudentButton(_ sender: UIButton) {
            let name = textFieldOutlet.text!
            let age = Int(ageTextFieldOutlet.text!)!
            let stew = Student(name: name, age: age)
            stew.saveToFirebase()
            students.append(stew)
            tableViewOutlet.reloadData()
        }
        
        //swipe to delete
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
            
        }
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete{
                students[indexPath.row].deleteFromFirebase()
                //remove from array
                students.remove(at: indexPath.row)
                tableViewOutlet.reloadData()
            }
        }
        
        //selecting a row
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedIndex = indexPath.row
            
        }
        
        
        
        //make the change on the selected row
        
        
        
        
        
    @IBAction func editAction(_ sender: UIButton) {
        students[selectedIndex].name = textFieldOutlet.text!
        students[selectedIndex].age = Int(ageTextFieldOutlet.text!)!
        students[selectedIndex].editOnFirebase()
        tableViewOutlet.reloadData()
    }
    
        
        
        
    }

