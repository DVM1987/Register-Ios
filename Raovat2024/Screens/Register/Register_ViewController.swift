    //
    //  Register_ViewController.swift
    //  Raovat2024
    //
    //  Created by muoidv on 07/04/2023.
    //

    import UIKit

    class Register_ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        
        @IBOutlet weak var txt_Username: UITextField!
        @IBOutlet weak var txt_Password: UITextField!
        @IBOutlet weak var txt_HoTen: UITextField!
        @IBOutlet weak var txt_Email: UITextField!
        @IBOutlet weak var txt_DiaChi: UITextField!
        @IBOutlet weak var txt_DienThoai: UITextField!
        
        
        @IBOutlet weak var imgAvatar: UIImageView!
        
        
        @IBOutlet weak var mySpinner: UIActivityIndicatorView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            mySpinner.isHidden = true
             
        }
        
        
        @IBAction func RegisterUser(_ sender: Any) {
            
            mySpinner.isHidden = false
            mySpinner.startAnimating()
            
            
            
            // upload data
            var url = URL(string:Config.ServerURL + "/uploadFile")
            let boundary = UUID().uuidString
            let session = URLSession.shared
            
            var urlRequest = URLRequest(url: url!)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var data = Data()
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"avatar.png\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            data.append((imgAvatar.image?.pngData())!)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
                if error == nil {
                    let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                    if let json  = jsonData as? [String: Any]{
                        if(json["kq"] as! Int == 1){
                            let urlFile = json["urlFile"] as? [String:Any]
                            
                            let fileName = urlFile!["filename"] as! String
                            
                            DispatchQueue.main.async {
                                
                                url = URL(string: Config.ServerURL + "/register")
                                var request = URLRequest(url: url!)
                                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                                request.setValue("application/json", forHTTPHeaderField: "Accept")
                                request.httpMethod = "POST"
                                
                                
                                let postData = "Username=\(self.txt_Username.text!)&Password=\(self.txt_Password.text!)&Name=\(self.txt_HoTen.text!)&Image=\(fileName)&Email=\(self.txt_Email.text!)&Address=\(self.txt_DiaChi.text!)&PhoneNumber=\(self.txt_DienThoai.text!)".data(using: .utf8)
                                request.httpBody = postData
                                
                                let taskUserRegister = URLSession.shared.dataTask(with: request, completionHandler: { data , response, error in
                                    guard error == nil else { print("error"); return }
                                    guard let data = data else { return }
                                    
                                    do{
                                        guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] else { return }
                                        
                                        DispatchQueue.main.async {
                                                                               self.mySpinner.isHidden = true
                                                                           }
                                        
                                        if( json["kq"] as! Int == 1 ){
                                           // Thanh Cong
                                            // Push to Login Scene
                                        }else{
                                            
                                            DispatchQueue.main.async {
                                                let alertView = UIAlertController(title: "Thông Báo", message: (json["errMsg"] as! String), preferredStyle: .alert)
                                                alertView.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                                self.present(alertView, animated: true, completion: nil)
                                            }
                                            
                                        }
                                        
                                    }catch let error { print(error.localizedDescription) }
                                })
                                taskUserRegister.resume()
                            }
                            
                            
                        }else {
                            print("Upload failed")
                        }
                        
                        
                    }
                    
                    
                }
            }).resume()
        }
        
        @IBAction func ChooseImageFRomPhoto(_ sender: Any) {
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = .photoLibrary
            image.allowsEditing = false
            self.present(image, animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
                imgAvatar.image = image
            }else {
                
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        @IBAction func UploadImageToServer(_ sender: Any) {
            
        }
        
        
        
    }
