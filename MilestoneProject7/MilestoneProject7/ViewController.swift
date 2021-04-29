//
//  ViewController.swift
//  MilestoneProject7
//
//  Created by Дмитрий Головин on 28.04.2021.
//

import UIKit

class ViewController: UITableViewController {

    var notes = [Notes]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        
        let defaults = UserDefaults.standard
        
        if let savedNotes = defaults.object(forKey: "notes") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                notes = try jsonDecoder.decode([Notes].self, from: savedNotes)
            } catch {
                print("Fail loading data")
            }
        }
        
        
    }
    
    @objc private func addNote() {
        let ac = UIAlertController(title: "Add new note", message: "Enter name of note", preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        let okButton = UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let noteName = ac?.textFields?.first?.text else { return }
            let newNote = Notes()
            newNote.name = noteName
            self?.notes.append(newNote)
            self?.tableView.reloadData()
            self?.save()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(okButton)
        ac.addAction(cancelButton)
        present(ac, animated: true, completion: nil)
     }
    
    
    private func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(notes) {
            UserDefaults.standard.set(savedData, forKey: "notes")
        } else {
            print("Fail savind data")
        }
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell")
        
        cell?.textLabel?.text = notes[indexPath.row].name
        cell?.textLabel?.textAlignment = .left
        cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "DetailNoteVC") as? NoteViewController
        
        vc?.selectedNote = notes[indexPath.row].name
        navigationController?.pushViewController(vc!, animated: true)
    }
}

