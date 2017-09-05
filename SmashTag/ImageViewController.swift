//
//  ImageViewController.swift
//  SmashTag
//
//  Created by Gianni Maize on 6/22/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    // MARK: Model
    public var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil { // if we're on screen
                fetchImage()
            }
        }
    }
    
    // MARK: Private Implementation
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private func fetchImage() {
        if let url = imageURL {
            spinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                if url == self?.imageURL, let imageData = urlContents {
                    DispatchQueue.main.async {
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    // MARK: View Controller Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil { // we're about to appear on screen so, if needed,
            fetchImage()  // fetch image
        }
    }
    
    // MARK: User Interface
    
    @IBOutlet weak var scrollView: UIScrollView!  {
        didSet {
            // to zoom we have to handle viewForZooming(in scrollView:)
            scrollView.delegate = self
            // and we must set our minimum and maximum zoom scale
            scrollView.minimumZoomScale = 1
            scrollView.maximumZoomScale = 1
            // most important thing to set in UIScrollView is contentSize
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
        }
    }
    
    fileprivate var imageView =  UIImageView()
   
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            //update scroll view zoom settings
            updateScrollViewSettings()
            // now that we've set an image
            // stop any spinner that exists from spinning
            spinner?.stopAnimating()
        }
    }
    
    fileprivate var userZoomedImage = false
    
    private func updateScrollViewSettings() {
        if scrollView == nil || image == nil { return }
        var minZoom: CGFloat {
            return min(scrollView.bounds.size.width / imageView.bounds.size.width, scrollView.bounds.size.height / imageView.bounds.size.height)
        }
        var startZoom: CGFloat {
            return max(scrollView.bounds.size.width / imageView.bounds.size.width, scrollView.bounds.size.height / imageView.bounds.size.height)
        }
        scrollView?.minimumZoomScale = minZoom
        scrollView?.maximumZoomScale = 2 * startZoom
        if (!userZoomedImage) {
            scrollView?.zoomScale = startZoom
        } else if ((scrollView?.zoomScale)! > (scrollView?.maximumZoomScale)!) {
            scrollView?.zoomScale = (scrollView?.maximumZoomScale)!
        } else if ((scrollView?.zoomScale)! < (scrollView?.minimumZoomScale)!) {
            scrollView?.zoomScale = (scrollView?.minimumZoomScale)!
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollViewSettings()
    }
    
}

// MARK: UIScrollViewDelegate
// Extension which makes ImageViewController conform to UIScrollViewDelegate
// Handles viewForZooming(in scrollView:)
// by returning the UIImageView as the view to transform when zooming
extension ImageViewController : UIScrollViewDelegate
{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        userZoomedImage = true
    }
}
