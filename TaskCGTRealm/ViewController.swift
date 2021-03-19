//
//  ViewController.swift
//  TaskCGTRealm
//
//  Created by mac on 17.03.2021.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    
    @IBOutlet weak var observerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private var notes: Results<Notes>!
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredNotes: Results<Notes>!
    
    private var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    private var observer = 0 {
        didSet {
            observerLabel.text = "Кол-во заметок \(notes.count)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notes = realm.objects(Notes.self)
        observerLabel.text = "Кол-во заметок \(notes.count)"
        creatingSearchController()
    }

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let detailViewController = segue.source as? DetailViewController else { return }
        detailViewController.saveNotes()
        observer += 1
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.currentNote = notes[indexPath.row]
        }
    }
    
    private func creatingSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Начните вводить для поиска нужной заметки"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering == true {
            return filteredNotes.count
        }
        return notes.isEmpty ? 0 : notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        var note = Notes()
        if isFiltering == true {
            note = filteredNotes[indexPath.row]
        } else {
            note = notes[indexPath.row]
        }
        cell.notesLabel.text = note.note
        cell.notesImage.image = UIImage(data: note.imageData!)
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        StorageManager.deleteObject(note)
        observer -= 1
        tableView.deleteRows(at: [indexPath], with: .top)
    }
}

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredNotes = notes.filter("note CONTAINS[c] %@", searchText)
        tableView.reloadData()
    }
    
}
