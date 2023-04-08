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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func RegisterUser(_ sender: Any) {
        
        var url = URL(string: "http://192.168.1.7:5000/uploadFile")
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
                            
                            url = URL(string: "http://192.168.1.7:5000/register")
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
                                    
                                    if( json["kq"] as! Int == 1 ){
                                        print(json["errMsg"] as Any )
                                    }else{
                                        
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
