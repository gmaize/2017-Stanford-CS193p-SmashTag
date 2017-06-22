//
//  TweetImageMentionTableViewCell.swift
//  SmashTag
//
//  Created by Gianni Maize on 6/18/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import UIKit

class TweetImageMentionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var imgURL: URL? {
        didSet {
            img = nil
            updateUI()
        }
    }
    
    private var img: UIImage? {
        get {
            return imgView.image
        }
        set {
            imgView.image = newValue
        }
    }
    
    private func updateUI() {
        if let url = imgURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let imageData = try? Data(contentsOf: url), url == self?.imgURL{
                    DispatchQueue.main.async {
                        self?.img = UIImage(data: imageData)
                    }
                } else if url == self?.imgURL {
                    DispatchQueue.main.async {
                        self?.img = nil
                    }
                }
            }
        }

    }
}
