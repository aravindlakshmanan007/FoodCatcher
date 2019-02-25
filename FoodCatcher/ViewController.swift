//
//  ViewController.swift
//  FoodCatcher
//
//  Created by Aravind on 17/02/19.
//  Copyright © 2019 Aravind. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagepicker = UIImagePickerController()
    let navigationcontrol = UINavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagepicker.delegate = self
        imagepicker.sourceType = .photoLibrary
        imagepicker.allowsEditing = false
        navigationcontrol.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            
            imageView.image = pickedimage
            guard let ciimage = CIImage(image: pickedimage) else{
                fatalError("Could not convert to UIImage to CIImage")
            }
            detect(image: ciimage)
        }
        
     imagepicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage){


        guard let model = try? VNCoreMLModel(for : Inceptionv3().model) else {
                fatalError("Loading CoreML Model Failed")
            }
        let request = VNCoreMLRequest(model: model){ (request,error) in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Error processing result")
            }
            if let firstresult = results.first{
                if firstresult.identifier.contains("hotdog"){
                    self.navigationItem.title = "Hotdog"
                }else{
                    self.navigationItem.title = "Not Hotdog"
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
        }catch{
            print("Error handling",error)
        }
    }
    
    @IBAction func CameraClicked(_ sender: UIBarButtonItem) {
        
        present(imagepicker, animated: true, completion: nil)
        
    }
}

