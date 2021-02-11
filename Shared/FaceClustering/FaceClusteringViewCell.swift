import UIKit

/**
 Shows the thumbnail of a PHAsset and a label with the amount of found faces and first found faceId
 */
class FaceClusteringViewCell: UICollectionViewCell {
    static let identifier = "FaceClusteringViewCell"

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var faces: UILabel!
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        faces.text = ""
    }
}
