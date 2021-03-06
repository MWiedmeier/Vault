//
//  VaultViewController.swift
//  Vault
//
//  Created by Matthew Wiedmeier on 7/4/16.
//  Copyright © 2016 Matthew Wiedmeier. All rights reserved.
//

import UIKit

class VaultViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let reuseIdentifier = "MediaCell"
    let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let cellSpacing = 5.0
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var thumbnails: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth / 4, height: screenWidth / 4)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func openLibrary(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func getCurrentTime() -> NSString{
        
        return String(Int64(NSDate().timeIntervalSince1970 * 1000))
        
    }
    
    func clearFilesFromDocuments(){
        
        do{
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentsPath = paths[0]
            
            let manager = NSFileManager.defaultManager()
            let files = try manager.contentsOfDirectoryAtPath(documentsPath)
        
            for file in files {
            
                let fullPath = documentsPath.stringByAppendingString("/" + file)
                try manager.removeItemAtPath(fullPath)

            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }

    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        dismissViewControllerAnimated(true, completion: nil)

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dismissViewControllerAnimated(true, completion: nil)

            thumbnails.append(pickedImage)
            NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
            
            // Save Image
            do {
                
                clearFilesFromDocuments()
                let fileName = (getCurrentTime() as String) + ".png"
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let documentsPath = paths[0]
                let filePath = documentsPath.stringByAppendingString("/" + fileName)
                
                if let data = UIImagePNGRepresentation(pickedImage){
                    data.writeToFile(filePath, atomically:true)
                }
                
                let manager = NSFileManager.defaultManager()
                let allItems = try manager.contentsOfDirectoryAtPath(documentsPath)
                print(allItems)
                
            }catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.thumbnails.count
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ThumbnailViewController
        
        cell.imageThumbnail.image = self.thumbnails[indexPath.item]
        cell.imageThumbnail.contentMode = UIViewContentMode.ScaleAspectFill
        
        
        return cell
    }


    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    //
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        return CGSize(width: screenWidth/4, height: screenWidth/4);
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1;
    }
    
}


