//
//  DetailViewController.swift
//  TaskTrainee
//
//  Created by mac on 15.03.2021.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    private var imageNote = UIImageView()
    private var notesTextView = UITextView()
    var currentNote: Notes?
    var observerImage: UIImage?
    var imageIsChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(notesTextView)
        view.addSubview(imageNote)
        self.saveButton.isEnabled = false
        editNotes()
        createNotesTextView()
        createImageNote()
        creatingToolBar()
        workingWithImage()
    }
    
    func saveNotes() {
        
        var image: UIImage?
        
        if imageIsChanged == true {
            image = imageNote.image
        } else {
            image = UIImage(systemName: "photo")
        }
        
        let imageData = image?.pngData()
        
        let newNote = Notes(note: notesTextView.text, imageData: imageData)
        
        if currentNote != nil {
            try! realm.write {
                currentNote?.note = newNote.note
                currentNote?.imageData = newNote.imageData
            }
        } else {
            StorageManager.saveObject(newNote)
        }
    }
    
    func editNotes() {
        if currentNote != nil {
            guard let data = currentNote?.imageData, let image = UIImage(data: data) else { return }
            notesTextView.text = currentNote?.note
            imageNote.image = image
        }
    }
    
    func workingWithImage() {
        if imageNote.image != nil {
            let supportingButtonForImage = UIButton()
            view.addSubview(supportingButtonForImage)
            supportingButtonForImage.alpha = 0.1
            supportingButtonForImage.translatesAutoresizingMaskIntoConstraints = false
            supportingButtonForImage.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 20).isActive = true
            supportingButtonForImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            supportingButtonForImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            supportingButtonForImage.heightAnchor.constraint(equalToConstant: view.frame.size.height/2 - 30).isActive = true
            
            supportingButtonForImage.addTarget(self, action: #selector(buttonActionPhoto), for: .touchUpInside)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    func createNotesTextView() {
        view.addSubview(notesTextView)
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        notesTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        notesTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        notesTextView.heightAnchor.constraint(equalToConstant: view.frame.size.height/2 - 30 ).isActive = true
        
        if observerImage != nil {
            createImageNote()
            imageNote.image = observerImage
        }
    }
    
    func createImageNote() {
        view.addSubview(imageNote)
        imageNote.translatesAutoresizingMaskIntoConstraints  = false
        imageNote.sizeToFit()
        imageNote.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 20).isActive = true
        imageNote.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        imageNote.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        imageNote.heightAnchor.constraint(equalToConstant: view.frame.size.height/2 - 30).isActive = true
    }
    
    func creatingToolBar() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        let photoButton = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .done, target: self, action: #selector(didTapPhoto))
        let boldButton = UIBarButtonItem(image: UIImage(systemName: "bold"), style: .done, target: self, action: #selector(didTapBold))
        let sizeOfTextButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSize))
        toolBar.items  = [space,sizeOfTextButton, boldButton, photoButton, doneButton]
        notesTextView.inputAccessoryView = toolBar
    }
    
    // MARK: - objc func
    @objc func didTapDone() {
        notesTextView.resignFirstResponder()
    }
    
    @objc func didTapPhoto() {
        view.addSubview(imageNote)
        
        createImageNote()
        if observerImage != nil {
            imageNote.image = observerImage
        } else {
            imageNote.image = UIImage(systemName: "photo")
        }

        let supportingButtonForImage = UIButton()
        view.addSubview(supportingButtonForImage)
        supportingButtonForImage.alpha = 0.1
        supportingButtonForImage.translatesAutoresizingMaskIntoConstraints = false
        supportingButtonForImage.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 20).isActive = true
        supportingButtonForImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        supportingButtonForImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        supportingButtonForImage.heightAnchor.constraint(equalToConstant: view.frame.size.height/2 - 30).isActive = true
        
        supportingButtonForImage.addTarget(self, action: #selector(buttonActionPhoto), for: .touchUpInside)
        
    }
    
    @objc private func buttonActionPhoto() {
        let alertController = UIAlertController(title: "Хотите добавить новое фото?", message: nil, preferredStyle: .alert)
        let photo = UIAlertAction(title: "Фото", style: .default) { [weak self] _ in
            self?.chooseImagePicker(source: .photoLibrary)
        }
        let camera = UIAlertAction(title: "Камера", style: .default) { [weak self] _ in
            self?.chooseImagePicker(source: .camera)
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel) { [weak self] _ in
            self?.imageNote.removeFromSuperview()
        }
        alertController.addAction(photo)
        alertController.addAction(camera)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }

    @objc private func didTapBold() {
        notesTextView.font = UIFont.boldSystemFont(ofSize: 20)
    }

    @objc private func didTapSize() {
    }
}

//MARK: - Working with image
extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageNote.image = info[.editedImage] as? UIImage
        imageNote.contentMode = .scaleAspectFill
        imageNote.clipsToBounds = true
        imageIsChanged = true
        dismiss(animated: true)
    }
}
