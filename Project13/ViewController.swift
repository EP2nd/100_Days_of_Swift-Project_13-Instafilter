//
//  ViewController.swift
//  Project13
//
//  Created by Edwin Przeźwiecki Jr. on 24/08/2022.
//

import CoreImage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    /// Challenge 3:
    @IBOutlet var intensity: UISlider!
    @IBOutlet var intensityLabel: UILabel!
    
    @IBOutlet var radius: UISlider!
    @IBOutlet var radiusLabel: UILabel!
    
    @IBOutlet var scale: UISlider!
    @IBOutlet var scaleLabel: UILabel!
    
    @IBOutlet var center: UISlider!
    @IBOutlet var centerLabel: UILabel!
    
    @IBOutlet var changeFilterButton: UIButton!
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
    var filters = ["CIBumpDistortion", "CIGaussianBlur", "CIPixellate", "CISepiaTone", "CITwirlDistortion", "CIUnsharpMask", "CIVignette"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        
        currentFilter = CIFilter(name: "CISepiaTone")
        
        /// Challenge 2:
        changeFilterButton.setTitle("\(currentFilter.name)", for: .normal)
    }
    
    @IBAction func changeFilter(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        
        for filter in filters {
            alertController.addAction(UIAlertAction(title: filter, style: .default, handler: setFilter))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        
        /// Challenge 1:
        guard let image = imageView.image else {
            
            let alertController = UIAlertController(title: "Error", message: "There is no image to save.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alertController, animated: true)
            
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    /// Challenge 3:
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func radiusChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func scaleChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func centerChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @objc func importPicture() {
        
        let picker = UIImagePickerController()
        
        picker.allowsEditing = true
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        currentImage = image
        
        /// Project 15, challenge 2:
        UIView.animate(withDuration: 1, animations: {
            self.imageView.alpha = 0
            self.imageView.alpha = 1
        })
        
        let beginImage = CIImage(image: currentImage)
        
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func applyProcessing() {
        
//      guard let image = currentFilter.outputImage else { return }
//      currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        
        let inputKeys = currentFilter.inputKeys
        
        /// Challenge 3:
        DispatchQueue.main.async {
            if inputKeys.contains(kCIInputIntensityKey) {
                self.intensity.isEnabled = true
                self.intensityLabel.isEnabled = true
                self.currentFilter.setValue(self.intensity.value, forKey: kCIInputIntensityKey)
            } else {
                self.intensity.isEnabled = false
                self.intensityLabel.isEnabled = false
            }
            
            if inputKeys.contains(kCIInputRadiusKey) {
                self.radius.isEnabled = true
                self.radiusLabel.isEnabled = true
                self.currentFilter.setValue(self.radius.value * 200, forKey: kCIInputRadiusKey)
            } else {
                self.radius.isEnabled = false
                self.radiusLabel.isEnabled = false
            }
            
            if inputKeys.contains(kCIInputScaleKey) {
                self.scale.isEnabled = true
                self.scaleLabel.isEnabled = true
                self.currentFilter.setValue(self.scale.value * 10, forKey: kCIInputScaleKey)
            } else {
                self.scale.isEnabled = false
                self.scaleLabel.isEnabled = false
            }
        
        if inputKeys.contains(kCIInputCenterKey) {
                self.center.isEnabled = true
                self.centerLabel.isEnabled = true
                self.currentFilter.setValue(CIVector(x: self.currentImage.size.width / 2, y: self.currentImage.size.height / 2), forKey: kCIInputCenterKey)
            } else {
                self.center.isEnabled = false
                self.centerLabel.isEnabled = false
            }
        }
        
        /* if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        } */
        
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            
            let processedImage = UIImage(cgImage: cgimg)
            
            self.imageView.image = processedImage
        }
    }
    
    func setFilter(action: UIAlertAction) {
        /// Making sure there is a valid image before continuing:
        guard currentImage != nil else { return }
        
        /// Safely read the alert action's title:
        guard let actionTitle = action.title else { return }
        
        /// Challenge 2:
        changeFilterButton.setTitle("\(actionTitle)", for: .normal)
        
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            /// We got back an error:
            let alertController = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alertController, animated: true)
        } else {
            
            let alertController = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photo library.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alertController, animated: true)
        }
    }
}

