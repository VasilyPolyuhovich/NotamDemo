//
//  ViewController.swift
//  RocketRouteDemo
//
//  Created by Vasyl Polyukhovych on 10/17/16.
//  Copyright © 2016 Vasyl Polyukhovych. All rights reserved.
//

import UIKit
import MapKit

class  CustomPointAnnotation: MKPointAnnotation {
    public var notamObject:Notam!
}

class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    let limitLength = 4
    let apiClient = APIRequesManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchBar.delegate = self
        mapView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let string = searchBar.text{
            let regex = re.compile("^[a-zA-Z]{4}$")
            let res = regex.findall(string)
            if res.count != 0 {
                apiClient.getNotam(codeICAO: searchBar.text){ [weak self] result in
                    guard let strongSelf = self else { return }
                    if result.count > 0{
                        if strongSelf.mapView.annotations.count != 0{
                            strongSelf.mapView.removeAnnotations(strongSelf.mapView.annotations)
                        }
                        var an = Array<CustomPointAnnotation>()
                        for item in result{
                            let a = CustomPointAnnotation()
                            a.coordinate = item.notamLocation
                            a.title = item.itemA
                            a.notamObject = item
                            an.append(a)
                        }
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            let span = MKCoordinateSpanMake(10, 10)
                            let region = MKCoordinateRegion(center: result[0].notamLocation, span: span)
                            strongSelf.mapView.setRegion(region, animated: true)
                            strongSelf.mapView.showAnnotations(an, animated: true)
                        }
                    }else{
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.showAlert(message: "No NOTAMs for the \(string)")
                        }
                    }
                }
            }else{
                showAlert(message: "Please enter correct 4 letter ICAO code")
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "warning")
            formatAnnotation(pinView: annotationView, forMapView: mapView)
        }
        
        return annotationView
    }
    
    
    func formatAnnotation(pinView: MKAnnotationView, forMapView: MKMapView) {
        let zoomLevel = forMapView.region.span
        let scale = 0.05263158 * zoomLevel.latitudeDelta
        pinView.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! CustomPointAnnotation
        showAlert(message: annotation.notamObject.notamMessage)
    }
    
    fileprivate func showAlert(message:String?){
        let alertController = UIAlertController(title: NSLocalizedString("RocketRouteDemo", comment: "RocketRouteDemo app name") , message: message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title"), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
}

