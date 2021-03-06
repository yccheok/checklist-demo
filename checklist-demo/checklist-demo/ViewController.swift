//
//  ViewController.swift
//  checklist-demo
//
//  Created by Yan Cheng Cheok on 02/10/2021.
//

import UIKit

class ViewController: UIViewController {
    enum SectionIdentifier: Hashable {
        case unchecked
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifier, Checklist>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, Checklist>
    
    private var checklists: [Checklist] = []
    
    private var dataSource: DataSource!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initKeyboardNotifications()
        
        initCollectionView()
        initDataSource()
        
        addChecklist(text: "hello", checked: false)
        addChecklist(text: "world", checked: false)
        
        applySnapshot(false)
    }

    private func addChecklist(text: String?, checked: Bool) {
        let id = Int64(checklists.count)
        let checklist = Checklist(id: id, text: text, checked: checked)
        checklists.append(checklist)
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, checklist) -> UICollectionViewCell? in
                guard let self = self else { return nil }
                
                guard let checklistCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "cell",
                    for: indexPath) as? ChecklistCell else {
                    return nil
                }
                
                checklistCell.delegate = self
                
                checklistCell.update(checklist)
                
                return checklistCell
            }
        )

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return nil }
            
            if kind == UICollectionView.elementKindSectionFooter {
                guard let checklistFooter = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "footer",
                    for: indexPath) as? ChecklistFooter else {
                    
                    return nil
                }
                
                checklistFooter.delegate = self
                
                return checklistFooter
                
            } else {
                precondition(false)
            }
            
            return nil
        }
        
        return dataSource
    }
    
    private func initDataSource() {
        self.dataSource = makeDataSource()
    }
    
    private func layoutConfig() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        return UICollectionViewCompositionalLayout (sectionProvider: { (sectionNumber, env) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(CGFloat(44))
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(CGFloat(44))
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            
            // https://lickability.com/blog/getting-started-with-uicollectionviewcompositionallayout/
            
            let sectionIdentifier = self.dataSource.snapshot().sectionIdentifiers[sectionNumber]
            
            switch(sectionIdentifier) {
            case .unchecked:
                let footerItemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(CGFloat(44))
                )
                
                let footerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerItemSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                
                section.boundarySupplementaryItems = [footerItem]
            }
            
            return section
        }, configuration: configuration)
    }
    
    private func initCollectionView() {
        collectionView.collectionViewLayout = layoutConfig()
        
        collectionView.register(ChecklistFooter.getUINib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        collectionView.register(ChecklistCell.getUINib(), forCellWithReuseIdentifier: "cell")
    }
    
    func applySnapshot(_ animatingDifferences: Bool, completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()

        snapshot.appendSections([
            .unchecked
        ])
        
        snapshot.appendItems(checklists, toSection: .unchecked)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    func checklistFooterClicked() {
        addChecklist(text: nil, checked: false)
        
        applySnapshot(true)
    }
    
    func textViewDidChange(_ checklistCell: ChecklistCell) {
        //
        // Critical code to ensure cell will resize based on cell content.
        //
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        //
        // Ensure our checklists data structure in sync with UI state.
        //
        guard let indexPath = collectionView.indexPath(for: checklistCell) else { return }
        let item = indexPath.item
        let text = checklistCell.textView.text
        self.checklists[item].text = text
    }
}

extension ViewController {
    func deinitKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    //
    // https://stackoverflow.com/a/41808338/72437
    //
    func initKeyboardNotifications() {
        // If your app targets iOS 9.0 and later or macOS 10.11 and later, you do not need to unregister an observer
        // that you created with this function.
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc private func keyboardWillShow(sender: NSNotification) {
        let i = sender.userInfo!
        let s: TimeInterval = (i[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let k = (i[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        bottomLayoutConstraint.constant = -k
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
    }
    
    @objc private func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let s: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomLayoutConstraint.constant = 0
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
    }
}

