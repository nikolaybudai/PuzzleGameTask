//
//  PuzzleViewController+CollectionView.swift
//  PuzzleGameTask
//
//  Created by Nikolay Budai on 31/01/25.
//

import UIKit

//MARK: UICollectionViewDataSource
extension PuzzleViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.puzzleTiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = puzzleCollectionView.dequeueReusableCell(
            withReuseIdentifier: PuzzleCollectionViewCell.identifier,
            for: indexPath) as? PuzzleCollectionViewCell else {
            return UICollectionViewCell()
        }
               
        let tile = viewModel.puzzleTiles[indexPath.item]
        cell.configure(with: tile)
        
        return cell
    }
    
}
