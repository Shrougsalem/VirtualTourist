//
//  PhotosCollectionViewController.swift
//  VirtualTourist
//
//  Created by Shroog Salem on 24/12/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private let reuseIdentifier = "PhotoCell"

class PhotosCollectionViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    //MARK: Properties
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var photosExist: Bool {
        return (fetchedResultsController.fetchedObjects?.count ?? 0) != 0 ? true : false }
    var pin: Pin!
    var page: Int = 0
    var selectedPhotos = Set<Photo>()
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.delegate=self
        mapView.delegate=self
        configureCollectionView()
        configureMapView()
        fetch()
        collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: UIView Configuration
    func configureCollectionView() {
        let space:CGFloat = 5.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func configureUI(isLoading:Bool){
        isLoading ? showSpinner() : removeSpinner()
        noImageLabel.isHidden=self.photosExist
        newCollectionButton.isEnabled = !isLoading
        collectionView.isUserInteractionEnabled = !isLoading
    }
    
    func configureMapView(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinates
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: false)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)
    }
    
    func isSelected(selection: Bool){
        if selection {
            newCollectionButton.title="Remove the selected photos"
            newCollectionButton.tintColor =  #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        } else {
            newCollectionButton.title="New Collection"
            newCollectionButton.tintColor =  #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        }
    }
    
    //MARK: IBActions
    // Delete or Download New Collection Actions
    @IBAction func newCollectionPressed(_ sender: Any) {
        if newCollectionButton.title == "New Collection" {
            page+=1
            loadNewPhotosURLs()
        } else if newCollectionButton.title == "Remove the selected photos" {
            for cell in collectionView.visibleCells {
                cell.contentView.backgroundColor = nil
            }
            deleteSelectedPhotos()
        }
        
    }
    //MARK: Data core setup
    //(fetch request to download photos urls using Flickr API)
    func fetch(){
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        loadPhotosURLs()
    }
    
    //MARK: Load/Fetch Photos URLS
    fileprivate func loadPhotosURLs() {
        do {
            try fetchedResultsController.performFetch()
            if photosExist {
                configureUI(isLoading: false)
                newCollectionButton.title = "New Collection"
            } else {
                page+=1
                loadNewPhotosURLs()
            }
        } catch {
            fatalError("Fetch photos could not be performd: \(error.localizedDescription)")
        }
    }
    
    //MARK: Load New Photos URLs
    fileprivate func loadNewPhotosURLs() {
        debugPrint("loading new photos collection")
        
        configureUI(isLoading: true)
        if photosExist {
            fetchedResultsController.fetchedObjects?.forEach({DataController.deletePhoto($0)
            })
            DataController.saveContext()
        }
        
        FlickrAPI.getFlickrImagesURLs(coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), page: page) { (imagesURLs, errString) in
            guard errString == nil else {
                self.alert(title: "Metwork Failure", message: "Error \n \(String(describing: errString))")
                self.configureUI(isLoading: false)
                return
            }
            for url in imagesURLs! {
                let photo = Photo(context: DataController.viewContext)
                photo.url = url
                photo.pin = self.pin
            }
            DataController.saveContext()
            self.configureUI(isLoading: false)
            self.collectionView.reloadData()
        }
    }
    //MARK: Delete The Selected Photos
    fileprivate func deleteSelectedPhotos() {
        for photo in selectedPhotos  {
            DataController.deletePhoto(photo)
        }
        isSelected(selection: false)
        DataController.saveContext()
        self.collectionView.reloadData()
    }

    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }

    // MARK: UICollectionViewDataSource
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! CollectionViewCell
        //config cell
        cell.photo = fetchedResultsController.object(at: indexPath)
        return cell
    }
    
     //MARK: UICollectionViewDelegate
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isSelected(selection: true)
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        let photo = fetchedResultsController!.object(at: indexPath)
        if selectedPhotos.contains(photo){
            repeat{isSelected(selection: false)} while(selectedPhotos.isEmpty)
            selectedPhotos.remove(photo)
            cell.contentView.backgroundColor = nil
        } else {
            selectedPhotos.insert(photo)
            cell.contentView.backgroundColor =  #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
    }
    
    //MARK: NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            collectionView.reloadData()
        case .insert:
            collectionView.reloadData()
        case .move:
            collectionView.reloadData()
        case .update:
            collectionView.reloadData()
        @unknown default:
            return
        }
    }
}
