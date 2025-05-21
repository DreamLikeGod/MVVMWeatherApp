//
//  UIImageView+Extension.swift
//  MVVMRTestWeather
//
//  Created by Егор Ершов on 21.05.2025.
//

import UIKit

extension UIImageView {
    
    func downloadImage(from url: String) {
        
        guard let url = URL(string: "https:\(url)") else {
            self.image = UIImage(systemName: "xmark.seal")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error {
                    self.image = UIImage(systemName: "xmark.seal")
                    return
                }
                guard let data else {
                    self.image = UIImage(systemName: "xmark.seal")
                    return
                }
                
                self.image = UIImage(data: data)
            }
        }.resume()
    }
    
}
