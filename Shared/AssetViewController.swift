import UIKit
import Photos
import PhotosUI

/**
 * Shows a single photo asset to the user.
 */
class AssetViewController: UIViewController {
    
    var asset: PHAsset!
    var assetCollection: PHAssetCollection!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var progressView: UIProgressView!

    private var image: UIImage!
    private let faceDetection = FaceDetection()

    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make sure the view layout happens before requesting an image sized to fit the view.
        view.layoutIfNeeded()
        updateImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    // MARK: Image display
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale, height: imageView.bounds.height * scale)
    }
    
    func updateImage() {
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .none
        options.progressHandler = { progress, _, _, _ in
            // The handler may originate on a background queue, so
            // re-dispatch to the main queue for UI work.
            DispatchQueue.main.sync {
                self.progressView.progress = Float(progress)
            }
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options,
                                              resultHandler: { image, _ in
                                                self.progressView.isHidden = true

                                                guard let image = image else { return }
                                                self.image = image
                                                self.imageView.image = image
        })
    }

    @IBAction func showMLKitResults(_ sender: UIBarButtonItem) {
        let imageToAnalyze = MLKitImage(uiImage: image, asset: asset)
        faceDetection.detect(for: imageToAnalyze) { [weak self] results in
            var faceIds = ""
            results.trackingIds.forEach{faceIds = faceIds + String($0)}
            let alertController = UIAlertController(title: "MLKit results",
                                                    message: "Amount of detected faces: \(results.amountOfFaces) \n \(faceIds)",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default))
            self?.present(alertController, animated: false, completion: {})
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension AssetViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // The call might come on any background queue. Re-dispatch to the main queue to handle it.
        DispatchQueue.main.sync {
            // Check if there are changes to the displayed asset.
            guard let details = changeInstance.changeDetails(for: asset) else { return }
            
            // Get the updated asset.
            asset = details.objectAfterChanges
            updateImage()
        }
    }
}
