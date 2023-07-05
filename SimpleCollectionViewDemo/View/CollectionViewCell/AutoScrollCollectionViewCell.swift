//
//  AutoScrollCollectionViewCell.swift
//  SimpleCollectionViewDemo
//
//  Created by kimleak on 2023/02/22.
//

import UIKit

class AutoScrollCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel               : UILabel!
    @IBOutlet weak var customBackgroundView     : UIView!

    /// Indicates if the cell is currently displayed as primary cell.
    public var isCurrentlyPrimary = false
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    //Apply updown animation
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? UpDownLayoutAttributes else { return }
        isCurrentlyPrimary = !(attributes.progress == 0)
        animateViews(toProgress: attributes.progress)
    }
    
    func configCell(titleStr : String) {
        self.titleLabel.text                            = titleStr
        self.contentView.layer.cornerRadius             = 20
        self.customBackgroundView.layer.cornerRadius    = 20
        self.customBackgroundView.layer.applySketchShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.1), alpha: 1.0, x: 0, y: 6, blur: 20, spread: 0)
    }
    private func animateViews(toProgress progress: Double) {
        let offset = 50.0 - (CGFloat(progress) * 50.0)
        self.customBackgroundView.transform = .init(translationX: 0, y: -offset)
    }
    
}
extension CALayer {
  func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.5,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0)
  {
    masksToBounds = false
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}
