//
//  ViewController.swift
//  BusinessCardKitDemo
//
//  Created by Bastian Wirth on 29.09.19.
//  Copyright © 2019 up in blue GmbH. All rights reserved.
//

import UIKit
import UIBBusinessCardKit

class ViewController: UIViewController, UIBBusinessCardRecognitionViewControllerDelegate {

    
    @IBOutlet var imageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func scanButtonPushed(_ sender: Any) {
        let businessCardRecognitionViewController = UIBBusinessCardRecognitionViewController()
        businessCardRecognitionViewController.delegate = self
        self.present(businessCardRecognitionViewController, animated: true, completion: nil)
    }
    func businessCardRecognitionViewControllerDidCancel(_ controller: UIBBusinessCardRecognitionViewController) {
        print("Cancelled")
    }
    
    func businessCardRecognitionViewController(_ controller: UIBBusinessCardRecognitionViewController, didFailWithError error: Error, for image: UIImage) {
        print(error)
    }
    
    func businessCardRecognitionViewController(_ controller: UIBBusinessCardRecognitionViewController, didRecognize businessCard: UIBBusinessCard?, from image: UIImage) {
        print(businessCard)
        imageView.image = image
    }
}

