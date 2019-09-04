//
//  ViewController.swift
//  AwsS3Project
//
//  Created by Chetan Rajauria on 26/05/19.
//  Copyright © 2019 Chetan Rajauria. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import AWSCognito
import AWSS3


class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    let bucketName = "messing-with-aws"
    var contentUrl: URL!
    var s3Url:URL!
    let fileArray = ["earth","neptune","saturn"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: USWest2, identityPoolId: "us-west-2:97")
        let configuration = AWSServiceConfiguration(region: USWest2, credentialsProvider: credentialProvider)
        AWSServiceManager.default()?.defaultServiceConfiguration = configuration
        
        AWSS3.default().configuration.endpoint.url
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func uploadFile(with resource: String, type: String){
        let key = "\(resource).\(type)"
        let localImagePath = Bundle.main.path(forResource: resource, ofType: type)
        let localImageURL = URL(fileURLWithPath: localImagePath ?? "www.ggogle.com")
        let request = AWSS3TransferManagerUploadRequest()
        request?.bucket = bucketName
        request?.key = key
        request?.body = localImageURL
        request?.acl = .publicReadWrite
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(request!).continueOnSuccessWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            
            if let error = task.error{
                print(error)
            }
            if task.result != nil {
                print("Uploaded \(key)")
                let contentUrl = self.s3Url.appendingPathComponent(self.bucketName).appendingPathComponent(key)
                self.contentUrl = contentUrl
            }
            return nil
        }
    }

    @IBAction func onUploadBTN(_ sender: UIButton) {
        uploadFile(with: "earth", type: "jpeg")
      //  uploadFile(with: "earth", type: "mov")
    }
    @IBAction func onBulkBT(_ sender: UIButton) {
        for fileName in fileArray
        {
            uploadFile(with: fileName, type: "jpeg")
        }
    }
    @IBAction func showContent(_ sender: Any) {
        if contentUrl.path.contains("mov") {
            let player = AVPlayer(url: contentUrl)
            let playerViewController = AVPlayerViewController()
            present(playerViewController, animated: true, completion: nil)
            
        } else {
            do {
                let data = try Data(contentsOf: contentUrl)
                self.imageView.image = UIImage(data: data)
            } catch {
                
            }
        }
    }
    
}

