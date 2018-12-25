import AsyncDisplayKit

final class AnotherStoriesLayout: UICollectionViewFlowLayout {
  // see: https://developer.apple.com/documentation/uikit/uicollectionview/customizing_collection_view_layouts
  
  // MARK: - Helper Types
  
  struct SectionLimit {
    let top: CGFloat
    let bottom: CGFloat
  }
  
  // MARK: - Properties
  
  var itemAttributes: [[UICollectionViewLayoutAttributes]] = []
  var sectionAttributes: [UICollectionViewLayoutAttributes] = []
  var sectionLimits: [SectionLimit] = []

  var contentSize: CGSize = .zero
  var numberOfRows: CGFloat = 1
  let itemRatio: CGFloat = 4 / 3
  let sectionHeaderHeight: CGFloat = 44.0
  
  // MARK: - Preparation
  
  override init() {
    super.init()
    self.scrollDirection = .horizontal
    self.sectionHeadersPinToVisibleBounds = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  override func prepare() {
    super.prepare()
    prepareItemAttributes()
    prepareSectionHeaderAttributes()
  }
  
  private func prepareItemAttributes() {
    guard let collectionView = collectionView else { return }
    
    // Reset cached information
    itemAttributes.removeAll()
    contentSize = CGSize.zero
    
    // Calculate Dimensions
    var x: CGFloat = 0
    var y: CGFloat = 0
    
    for sectionIndex in 0..<collectionView.numberOfSections {
      let itemCount = collectionView.numberOfItems(inSection: sectionIndex)
      let sectionTop = y
      
      y += sectionHeaderHeight
      
      var attributesList: [UICollectionViewLayoutAttributes] = []
      for itemIndex in 0..<itemCount {
        let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let size = CGSize(
          width: itemHeight() / itemRatio,
          height: itemHeight()
        )
        
        attributes.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        
        attributesList.append(attributes)
        
        x += size.width
      }
      
      y += itemHeight()
      
      let sectionBottom = y
      sectionLimits.append(SectionLimit(top: sectionTop, bottom: sectionBottom))
      itemAttributes.append(attributesList)
    }
    
    contentSize = CGSize(width: x, height: y)
  }
  
  private func prepareSectionHeaderAttributes() {
    guard let collectionView = collectionView else { return }
    
    // Reset cached information
    sectionAttributes.removeAll()
    
    // Calculate Dimensions
    let width = collectionView.bounds.size.width
    
    let collectionViewTop = collectionView.contentOffset.y
    let aboveCollectionViewTop = collectionViewTop - sectionHeaderHeight
    
    for sectionIndex in 0..<collectionView.numberOfSections {
      let sectionLimit = sectionLimits[sectionIndex]
      
      let indexPath = IndexPath(item: 0, section: sectionIndex)
      
      let attributes = UICollectionViewLayoutAttributes(
        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
        with: indexPath)
      
      attributes.zIndex = 1
      attributes.frame = CGRect(x: 0, y: sectionLimit.top, width: width, height: sectionHeaderHeight)
      
      let sectionTop = sectionLimit.top
      let sectionBottom = sectionLimit.bottom - sectionHeaderHeight
      
      attributes.frame.origin.y = min(
        max(sectionTop, collectionViewTop),
        max(sectionBottom, aboveCollectionViewTop)
      )
      
      sectionAttributes.append(attributes)
    }
  }
  
  func itemHeight() -> CGFloat {
    return collectionView!.frame.height - sectionHeaderHeight / numberOfRows
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var attributes: [UICollectionViewLayoutAttributes] = []
    
    for sectionIndex in 0..<(collectionView?.numberOfSections ?? 0) {
      let currentSectionAttributes = sectionAttributes[sectionIndex]
      
      if rect.intersects(currentSectionAttributes.frame) {
        attributes.append(currentSectionAttributes)
      }
      
      for item in itemAttributes[sectionIndex] where rect.intersects(item.frame) {
        attributes.append(item)
      }
    }
    
    return attributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard indexPath.section < itemAttributes.count,
      indexPath.item < itemAttributes[indexPath.section].count
      else {
        return nil
    }
    return itemAttributes[indexPath.section][indexPath.item]
  }
  
  override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return sectionAttributes[indexPath.section]
  }
  
  override var collectionViewContentSize: CGSize {
    return contentSize
  }
  
  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
    return self.collectionView!.contentOffset
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    // return true so we're asked for layout attributes as the content is scrolled
    // print("shouldInvalidateLayout")
    return true
    // guard let collectionView = collectionView else { return false }
    // return !collectionView.bounds.size.equalTo(newBounds.size)
  }
}

final class AnotherStoriesLayoutInspector: NSObject, ASCollectionViewLayoutInspecting {
  
  func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
    let layout = collectionView.collectionViewLayout as! AnotherStoriesLayout
    // return ASSizeRange(min: CGSize.zero, max: layout.itemAttributes[indexPath.section][indexPath.item].size)
    let size = CGSize(
      width: layout.itemHeight() / layout.itemRatio,
      height: layout.itemHeight()
    )
    
    return ASSizeRange(min: CGSize.zero, max: size)
  }
  
  func scrollableDirections() -> ASScrollDirection {
    return ASScrollDirection.right
  }
  
  func collectionView(_ collectionView: ASCollectionView, constrainedSizeForSupplementaryNodeOfKind kind: String, at indexPath: IndexPath) -> ASSizeRange {
    let layout = collectionView.collectionViewLayout as! AnotherStoriesLayout
    // return ASSizeRange(min: CGSize.zero, max: layout.sectionAttributes[indexPath.section].size)
    let size = CGSize(
      width: collectionView.bounds.width,
      height: layout.sectionHeaderHeight
    )
    
    return ASSizeRange(min: CGSize.zero, max: size)
  }
  
  func collectionView(_ collectionView: ASCollectionView, supplementaryNodesOfKind kind: String, inSection section: UInt) -> UInt {
    if (kind == UICollectionView.elementKindSectionHeader) {
      return 1
    } else {
      return 0
    }
  }
}
