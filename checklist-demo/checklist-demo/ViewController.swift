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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        print("footer clicked")
    }
    
    func textViewDidChange(_ checklistCell: ChecklistCell) {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
}

