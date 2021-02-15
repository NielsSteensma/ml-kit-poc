/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the main view controller for album navigation.
*/

import UIKit
import Photos

/**
 Shows a table of all PHAssetCollections retrieved from Apple Photos.
 */
class CollectionsViewController: UITableViewController {
    
    // MARK: Types for managing sections, cell, and segue identifiers
    enum Section: Int {
        case userCollections
        
        static let count = 1
    }
    
    enum CellIdentifier: String {
        case collection
    }
    
    enum SegueIdentifier: String {
        case showCollection
    }
    
    // MARK: Properties
    var userCollections: PHFetchResult<PHCollection>!
    let sectionLocalizedTitles = [NSLocalizedString("Albums", comment: "")]
    
    // MARK: UIViewController / Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a PHFetchResult object for each section in the table view.
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        PHPhotoLibrary.shared().register(self)
    }
    
    /// - Tag: UnregisterChangeObserver
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destination = (segue.destination as? UINavigationController)?.topViewController as? FaceClusteringViewController
            else { fatalError("Unexpected view controller for segue.") }
        guard let cell = sender as? UITableViewCell else { fatalError("Unexpected sender for segue.") }
        
        destination.title = cell.textLabel?.text
        
        switch SegueIdentifier(rawValue: segue.identifier!)! {
        case .showCollection:
            
            // Fetch the asset collection for the selected row.
            let indexPath = tableView.indexPath(for: cell)!
            let collection: PHCollection
            switch Section(rawValue: indexPath.section)! {
            case .userCollections:
                collection = userCollections.object(at: indexPath.row)
            }
            
            // configure the view controller with the asset collection
            guard let assetCollection = collection as? PHAssetCollection else {
                self.showAlert()
                return
            }
            destination.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
            destination.viewModel = FaceClusteringViewModel(phAssetCollection: assetCollection)
        }
    }

    private func showAlert(){
        let unsupportedCollectionAlert = UIAlertController(title: "Unsupported album",
                                                           message: "This type of cannot be analyzed",
                                                           preferredStyle: .alert)
        unsupportedCollectionAlert.addAction(UIAlertAction(title: "Okay", style: .default))
        present(unsupportedCollectionAlert, animated: false)
    }
    // MARK: Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .userCollections: return userCollections.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .userCollections:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
            let collection = userCollections.object(at: indexPath.row)
            cell.textLabel!.text = collection.localizedTitle
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionLocalizedTitles[section]
    }
    
}

// MARK: PHPhotoLibraryChangeObserver

extension CollectionsViewController: PHPhotoLibraryChangeObserver {
    /// - Tag: RespondToChanges
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        // Change notifications may originate from a background queue.
        // Re-dispatch to the main queue before acting on the change,
        // so you can update the UI.
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetails.fetchResultAfterChanges
                tableView.reloadSections(IndexSet(integer: Section.userCollections.rawValue), with: .automatic)
            }
        }
    }
}

