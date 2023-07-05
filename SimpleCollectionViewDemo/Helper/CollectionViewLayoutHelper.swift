
import UIKit

public final class UpDownCollectionViewLayout: UICollectionViewFlowLayout {
    
    private var firstSetupDone = false
    /// SeeAlso: UICollectionViewFlowLayout
    public override func prepare() {
        super.prepare()
        guard !firstSetupDone else { return }

        firstSetupDone = true
    }
    /// SeeAlso: UICollectionViewFlowLayout
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    /// SeeAlso: UICollectionViewFlowLayout
    public override class var layoutAttributesClass: AnyClass {
        return UpDownLayoutAttributes.self
    }
    
    /// SeeAlso: UICollectionViewFlowLayout
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView, let allAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        for attributes in allAttributes {
            let collectionCenter = collectionView.bounds.size.width / 2
            let offset = collectionView.contentOffset.x
            let normalizedCenter = attributes.center.x - offset
            
            let maxDistance = itemSize.width + minimumLineSpacing
            let distanceFromCenter = min(collectionCenter - normalizedCenter, maxDistance)
            let ratio = (maxDistance - abs(distanceFromCenter)) / maxDistance
            let normalizedRatio = min(1, max(0, ratio))
            
            guard let attributes = attributes as? UpDownLayoutAttributes else { continue }
            attributes.progress = Double(normalizedRatio)
        }
        return allAttributes
    }
    
    /// SeeAlso: UICollectionViewFlowLayout
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView, let layoutAttributes = layoutAttributesForElements(in: collectionView.bounds) else {
            return .init(x: 0, y: 0)
        }
        // Snapping closest cell to the center
        let centerOffset = collectionView.bounds.size.width / 2
        let offsetWithCenter = proposedContentOffset.x + (proposedContentOffset.x * velocity.x) + centerOffset
        let closestAttribute = layoutAttributes
            .sorted { abs($0.center.x - offsetWithCenter) < abs($1.center.x - offsetWithCenter) }
            .first ?? UICollectionViewLayoutAttributes()
        return CGPoint(x: closestAttribute.center.x - centerOffset, y: 0)
    }
}

final class UpDownLayoutAttributes: UICollectionViewLayoutAttributes {
    
    /// Progress towards the center of the screen, value between 0 and 1.
    var progress = 0.0
    
    /// SeeAlso: UICollectionViewLayoutAttributes
    override func copy(with zone: NSZone?) -> Any {
        let attributes = super.copy(with: zone)
        (attributes as? UpDownLayoutAttributes)?.progress = progress
        return attributes
    }
    
    /// SeeAlso: UICollectionViewLayoutAttributes
    override func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? UpDownLayoutAttributes,
            attributes.progress == progress else { return false }
        return super.isEqual(object)
    }
}
