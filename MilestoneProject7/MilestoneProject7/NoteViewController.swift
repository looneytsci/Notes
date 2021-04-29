//
//  NoteViewController.swift
//  MilestoneProject7
//
//  Created by Дмитрий Головин on 28.04.2021.
//

import UIKit

class NoteViewController: UIViewController {

    @IBOutlet weak var textOfNote: UITextView!
    
    var selectedNote: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let note = selectedNote else { return }
        
        title = note
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateData), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Меню", style: .plain, target: self, action: #selector(openMenu))
        
        let defaults = UserDefaults.standard
        
        if let savedNotes = defaults.object(forKey: "\(note)") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                textOfNote.text = try jsonDecoder.decode(String.self, from: savedNotes)
            } catch {
                print("Fail loading data screen 2")
            }
        }
    }
    
    @objc private func openMenu() {
        let ac = UIAlertController(title: "Choose action", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Share note", style: .default, handler: shareNote))
        ac.addAction(UIAlertAction(title: "Delete note", style: .destructive, handler: { [weak self] _ in
            self?.textOfNote.text = ""
            self?.save()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func shareNote(action: UIAlertAction) {
        guard let note = textOfNote.text, let noteName = title else { return }
        
        let vc = UIActivityViewController(activityItems: [noteName, note], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func updateData(notification: Notification) {
        
        if notification.name == UIResponder.keyboardDidHideNotification {
            save()
        }
        
    }
    
    private func save() {
        guard let note = selectedNote else { return }
        
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(textOfNote.text) {
            UserDefaults.standard.set(savedData, forKey: "\(note)")
        } else {
            print("Fail saving data screen 2")
        }
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboaredViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textOfNote.contentInset = .zero
        } else {
            textOfNote.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboaredViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textOfNote.scrollIndicatorInsets = textOfNote.contentInset
        
        let selectedRange = textOfNote.selectedRange
        textOfNote.scrollRangeToVisible(selectedRange)
    }
}
