//
//  ImageViewModel.swift
//  SCUP
//
//  Created by Althaf Nafi Anwar on 29/04/24.
//

import UIKit

class ImageViewModel: ObservableObject {
    @Published var image: UIImage?

    private var imageCache: NSCache<NSString, UIImage>?

    init(urlString: String?) {
        loadImage(urlString: urlString)
    }
    
    init(url1: String, url2: String) {
        loadCombinedImage(url1: url1, url2: url2)
    }
  
    private func loadCombinedImage(url1: String, url2: String) {
      guard let url1 = URL(string: url1) else { return }
      guard let url2 = URL(string: url2) else { return }

      DispatchQueue.global().async {
        guard let image1Data = try? Data(contentsOf: url1),
              let image2Data = try? Data(contentsOf: url2),
              var image1 = UIImage(data: image1Data),
              var image2 = UIImage(data: image2Data) else {
          return
        }
          
          image1 = image1.resize(512, 512)
          image2 = image2.resize(512, 512)

        // Target size for both cropping and final image
        let targetSize = CGSize(width: 256, height: 512)

        // Crop images directly to target size
        let image1Size = image1.size
        let image2Size = image2.size
        let cropWidth = min(image1Size.width, image2Size.width, targetSize.width)
        let cropHeight = min(image1Size.height, image2Size.height, targetSize.height)
        let originX1 = (image1Size.width - cropWidth) / 2.0
        let originY1 = (image1Size.height - cropHeight) / 2.0
        let rect1 = CGRect(x: originX1, y: originY1, width: cropWidth, height: cropHeight)
        let originX2 = (image2Size.width - cropWidth) / 2.0
        let originY2 = (image2Size.height - cropHeight) / 2.0
        let rect2 = CGRect(x: originX2, y: originY2, width: cropWidth, height: cropHeight)

        // Create CGImage from cropped portions
        guard let cgImage1 = image1.cgImage?.cropping(to: rect1),
              let cgImage2 = image2.cgImage?.cropping(to: rect2) else {
          return
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 512, height: 512), false, 0)
        UIImage(cgImage: cgImage1, scale: image1.scale, orientation: image1.imageOrientation).draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        UIImage(cgImage: cgImage2, scale: image2.scale, orientation: image2.imageOrientation).draw(in: CGRect(x: targetSize.width, y: 0, width: targetSize.width, height: targetSize.height))
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        DispatchQueue.main.async { [weak self] in
          self?.image = combinedImage
        }
      }
    }

    private func loadImage(urlString: String?) {
        guard let urlString = urlString else { return }

        if let imageFromCache = getImageFromCache(from: urlString) {
            self.image = imageFromCache
            return
        }

        loadImageFromURL(urlString: urlString)
    }

    private func loadImageFromURL(urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print(error ?? "unknown error")
                return
            }

            guard let data = data else {
                print("No data found")
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let loadedImage = UIImage(data: data) else { return }
                self?.image = loadedImage
                self?.setImageCache(image: loadedImage, key: urlString)
            }
        }.resume()
    }

    private func setImageCache(image: UIImage, key: String) {
        imageCache?.setObject(image, forKey: key as NSString)
    }

    private func getImageFromCache(from key: String) -> UIImage? {
        return imageCache?.object(forKey: key as NSString) as? UIImage
    }
}
