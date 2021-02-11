import UIKit

/**
 Shows the thumbnail of a PHAsset and a label withf the amount of found faces and first found faceId
 */
class FaceClusteringViewCell: UICollectionViewCell {
    static let identifier = "FaceClusteringViewCell"

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var faceId: UILabel!
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
        faceId.text = ""
        faces.text = ""
    }
}
