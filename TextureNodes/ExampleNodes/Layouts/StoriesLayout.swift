import AsyncDisplayKit

final class StoriesLayout: UICollectionViewFlowLayout {
  
  let numRows: CGFloat = 1
  let preferredRatio: CGFloat = 4 / 3
  
  let headerHeight: CGFloat = 44.0
  
  override init() {
    super.init()
    self.setupLayout()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout() {
    self.minimumInteritemSpacing = 0
    self.minimumLineSpacing = 0
    self.sectionInset = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    // self.headerReferenceSize = someSize
    self.scrollDirection = .horizontal
  }
  
  private func itemHeight() -> CGFloat {
    // return collectionView!.frame.height - headerHeight - sectionInset.top - sectionInset.bottom / numRows
    return collectionView!.frame.height / numRows
  }
  
  override var itemSize: CGSize {
    set {
      self.itemSize = CGSize(width: (itemHeight() / preferredRatio), height: itemHeight())
    }
    get {
      return CGSize(width: (itemHeight() / preferredRatio), height: itemHeight())
    }
  }
  
  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
    return self.collectionView!.contentOffset
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return !self.collectionView!.bounds.size.equalTo(newBounds.size)
  }
  
  func widthForSection(section: Int) -> CGFloat {
    return self.collectionView!.bounds.width - sectionInset.left - sectionInset.right
  }
  
  func headerSizeForSection(section: Int) -> CGSize {
    return CGSize(width: widthForSection(section: section), height: headerHeight)
  }
}

final class StoriesLayoutInspector: NSObject, ASCollectionViewLayoutInspecting {
  
  func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
    let layout = collectionView.collectionViewLayout as! StoriesLayout
    return ASSizeRange(min: CGSize.zero, max: layout.itemSize)
  }
  
  func scrollableDirections() -> ASScrollDirection {
    return ASScrollDirection.right
  }
  
  func collectionView(_ collectionView: ASCollectionView, constrainedSizeForSupplementaryNodeOfKind kind: String, at indexPath: IndexPath) -> ASSizeRange {
    let layout = collectionView.collectionViewLayout as! StoriesLayout
    return ASSizeRange(min: CGSize.zero, max: layout.headerSizeForSection(section: indexPath.section))
  }
  
  func collectionView(_ collectionView: ASCollectionView, supplementaryNodesOfKind kind: String, inSection section: UInt) -> UInt {
    if (kind == UICollectionView.elementKindSectionHeader) {
      return 1
    } else {
      return 0
    }
  }
}
