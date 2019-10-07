//MIT License
//
//Copyright (c) 2019 up in blue GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.


import UIKit
import Vision
import VisionKit

@available(iOS 13, *)
@objc public class UIBBusinessCardRecognitionViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    public var delegate: UIBBusinessCardRecognitionViewControllerDelegate?
    
    private let documentCameraViewController = VNDocumentCameraViewController()
    
    public var displayErrorAlert = false
    
    private var recognizeTextRequest: VNRecognizeTextRequest!
    
    private var currentImage: UIImage?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        documentCameraViewController.delegate = self
        self.addChild(documentCameraViewController)
        documentCameraViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(documentCameraViewController.view)
        documentCameraViewController.didMove(toParent: self)
        
        recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
            
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    self.parse(requestResults)
                }
            } else {
                //self.delegate?.businessCardRecognitionViewController(self, didRecognize: nil, from: )
            }
        }
        recognizeTextRequest.recognitionLevel = .accurate
        recognizeTextRequest.usesLanguageCorrection = true
    }

    
    override private init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Image and Text Processing
    private func process(_ image: UIImage) {
        currentImage = image
        guard let cgImage = image.cgImage else {
            // Return an error if no CGImage can't be created.
            let error = NSError(domain: "", code: 500, userInfo: nil)
            self.delegate?.businessCardRecognitionViewController(self, didFailWithError: error, for: image)
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([recognizeTextRequest])
        } catch {
            let error = NSError(domain: "", code: 500, userInfo: nil)
            self.delegate?.businessCardRecognitionViewController(self, didFailWithError: error, for: image)
            
        }
    }
    
    
    
    private func parse(_ result: [VNRecognizedTextObservation]) {
        var allText = ""
        let maxCandidates = 1
        for observation in result {
            guard let candidate = observation.topCandidates(maxCandidates).first else { continue }
            allText.append(candidate.string + "\n")
        }

        let businessCard = UIBBusinessCard()
        // Go on, split the text and make the parsing.
        let lines = allText.components(separatedBy: .newlines)
        for line in lines {
            let lowercasedLine = line.lowercased()
            let words = line.components(separatedBy: " ")
            
            for word in words {
                if word.contains("@") { businessCard.mail = word } // Probably mail address
                if word.contains("www") { businessCard.homePage = word } // Probably home page address
                
            }
            
            // Check for company name with expressions like ltd., gmbh, etc...
            if lowercasedLine.contains(" ltd") || lowercasedLine.contains(" gmbh") || lowercasedLine.contains(" ag ") || lowercasedLine.contains(" inc") {
                businessCard.company = line
            }
        }
        do {
            // Any line could contain the name on the business card.
            var potentialNames = allText.components(separatedBy: .newlines)
            
            // Create an NSDataDetector to parse the text
            let detector = try NSDataDetector(types: NSTextCheckingAllTypes)
            let matches = detector.matches(in: allText, options: .init(), range: NSRange(location: 0, length: allText.count))
            for match in matches {
                let matchStartIdx = allText.index(allText.startIndex, offsetBy: match.range.location)
                let matchEndIdx = allText.index(allText.startIndex, offsetBy: match.range.location + match.range.length)
                let matchedString = String(allText[matchStartIdx..<matchEndIdx])
                
                // This line has been matched so it doesn't contain the name on the business card.
                while !potentialNames.isEmpty && (matchedString.contains(potentialNames[0]) || potentialNames[0].contains(matchedString)) {
                    potentialNames.remove(at: 0)
                }
            
                switch match.resultType {
                case .address:
                    businessCard.address = matchedString
                case .phoneNumber:
                    if businessCard.phone == nil { businessCard.phone = matchedString } else {if businessCard.mobilePhone == nil { businessCard.mobilePhone = matchedString } else {businessCard.fax = matchedString}}
                default:
                    print("Default implementation")
                }
            }
            
            // If there is no potential name, pick the first line with two fields. We assume that that is the name.
            if !potentialNames.isEmpty {
                for potential in potentialNames {
                    let splitted = potential.components(separatedBy: " ")
                    if splitted.count == 2 {
                        businessCard.firstName = splitted[0]
                        businessCard.lastName = splitted[1]
                        break
                    }
                }
            }
            
            self.delegate?.businessCardRecognitionViewController(self, didRecognize: businessCard, from: currentImage ?? UIImage())
        } catch {
            self.delegate?.businessCardRecognitionViewController(self, didFailWithError: error, for: currentImage ?? UIImage())
        }
        
    }
    
    

    // MARK: - VNDocumentCameraViewControllerDelegate
    public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        self.delegate?.businessCardRecognitionViewControllerDidCancel(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Error while scanning", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.delegate?.businessCardRecognitionViewController(self, didFailWithError: error, for: currentImage ?? UIImage())
        if displayErrorAlert == true {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        self.dismiss(animated: true) {
            for page in 0 ..< scan.pageCount {
                let image = scan.imageOfPage(at: page)
                self.process(image)
            }
        }
    }

}

@objc public protocol UIBBusinessCardRecognitionViewControllerDelegate {
    /// The delegate will receive this call when the user cancels.
    func businessCardRecognitionViewControllerDidCancel(_ controller: UIBBusinessCardRecognitionViewController)
    /// The delegate will receive this call when the user is unable to scan, with the following error.
    func businessCardRecognitionViewController(_ controller: UIBBusinessCardRecognitionViewController, didFailWithError error: Error, for image: UIImage)
    /// The delegate will receive this call when the user has successfully scanned a business card.
    func businessCardRecognitionViewController(_ controller: UIBBusinessCardRecognitionViewController, didRecognize businessCard: UIBBusinessCard?, from image: UIImage)
}
