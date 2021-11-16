import Foundation
import UIKit

typealias DownloadCompletion = ((_ image: UIImage?, _ urlString: String) -> ())?

class ImageProvider {
    private let networkService: NetworkService
    private let queue = DispatchQueue(label: "imageDownloading")
    static let cache = ImageCache()
    
    init(
        networkService: NetworkService = NetworkLayer.sharedInstance
    ) {
        self.networkService = networkService
    }
    
    func imageAsync(from urlString: String, completion: DownloadCompletion) {
        
        guard let url = URL(string: urlString) else {
            
            completion?(nil, urlString)
            return
        }
        
        let imageName = self.imageName(for: url)
        queue.async { [weak self] in
            
            self?.downloadImage(from: url, saveAs: imageName, completion: { (image, urlString) in
                
                DispatchQueue.main.async { () -> Void in
                    completion?(image, urlString)
                }
            })
        }
    }

    private func downloadImage(from url: URL, saveAs imageName: String, completion: DownloadCompletion) {
        networkService.downloadFile(from: url, completion: { (locationURL, response, error) in
            
            let urlString = url.absoluteString
            guard let location = locationURL else {
                
                completion?(nil, urlString)
                return
            }
            
            let name = Self.cache.imageName(for: url)
            let image = Self.cache.storeImageInCache(from: location, imageName: name)
            completion?(image, urlString)
        })
    }
    
    func imageName(for url: URL) -> String {
        
        var imageName = url.lastPathComponent
        if let size = url.query {
            imageName = imageName + size
        }
        return imageName
    }
}
























