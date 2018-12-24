import AsyncDisplayKit

final class ExampleListViewController: ASViewController<ASDisplayNode> {
  
  let examples: [ExampleNode.Type]
  
  var tableNode: ASTableNode {
    return node as! ASTableNode
  }
  
  init() {
    examples = [
      TruncatableProfile.self
    ]
    
    super.init(node: ASTableNode())
    
    self.title = "Examples"
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    tableNode.delegate = self
    tableNode.dataSource = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let indexPath = tableNode.indexPathForSelectedRow {
      tableNode.deselectRow(at: indexPath, animated: true)
    }
  }
  
}

extension ExampleListViewController: ASTableDataSource {
  
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return examples.count
  }
  
  func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
    return ExampleListCellNode(exampleType: examples[indexPath.row])
  }
  
}

extension ExampleListViewController: ASTableDelegate {
  
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    let exampleType: ExampleNode.Type = (tableNode.nodeForRow(at: indexPath) as! ExampleListCellNode).exampleType
    let detailViewController: ExampleDetailViewController = ExampleDetailViewController(exampleType: exampleType)
    self.navigationController?.pushViewController(detailViewController, animated: true)
  }
  
}
