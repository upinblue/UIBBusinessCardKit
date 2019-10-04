# UIBBusinessCardKit

UIBBusinessCardKit is an iOS Framework for detecting and reading business cards. Based on Apples Vision Framework.

You simply create an UIBBusinessCardRecognitionViewController, present it and - if successfull - it returns a UIBBusinessCard object back to the delegate.

```swift
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
```

It is also compatible with Objective-C.
