//
//  ViewController.swift
//  PuzzleGameTask
//
//  Created by Nikolay Budai on 31/01/25.
//

import UIKit

final class PuzzleViewController: UIViewController {
    
    var viewModel: PuzzleViewModelProtocol
    
    var puzzleCollectionView: UICollectionView!
    var loadNewPuzzleButton: UIButton = UIButton()
    
    var draggingView: UIView?
    var startIndexPath: IndexPath?
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    //MARK: Init
    init(viewModel: PuzzleViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupViews()
        setupConstraints()
        
        Task {
            await viewModel.loadImage()
        }

        viewModel.onPuzzleUpdated = { [weak self] in
            self?.puzzleCollectionView.reloadData()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateConstraints),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    //MARK: Gestures Handling Methods
    
    /**
     Handles the pan gesture used for dragging puzzle pieces.
     Is responsible for managing the dragging state of the puzzle pieces,
     initiating the swap of tiles, and cleaning up the dragging state when the gesture ends.
     - Parameters:
       - gesture: The pan gesture recognizer  to detect dragging actions.
     */
    @objc private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: puzzleCollectionView)
        
        switch gesture.state {
        case .began:
            handleGestureBegan(location)
            
        case .changed:
            draggingView?.center = location
            
        case .ended:
            handleGestureEnded(location)
            
        default:
            cleanupDragging()
        }
    }
    
    /// Handles the beggining of the gesture of dragging the tile.
    private func handleGestureBegan(_ location: CGPoint) {
        guard let selectedIndexPath = puzzleCollectionView.indexPathForItem(at: location),
              let cell = puzzleCollectionView.cellForItem(at: selectedIndexPath) else {
            return
        }
        
        let puzzlePiece = viewModel.puzzleTiles[selectedIndexPath.item]
        guard !puzzlePiece.isFixed else {
            cleanupDragging()
            return
        }
        
        startIndexPath = selectedIndexPath
        cell.contentView.alpha = 0.0

        if let snapshot = cell.snapshotView(afterScreenUpdates: false) {
            snapshot.center = cell.center
            snapshot.alpha = 0.8
            puzzleCollectionView.addSubview(snapshot)
            draggingView = snapshot
        }
    }
    
    /// Handles the end of the gesture of dragging the tile.
    private func handleGestureEnded(_ location: CGPoint) {
        guard let startIndexPath = startIndexPath,
              let targetIndexPath = puzzleCollectionView.indexPathForItem(at: location),
              startIndexPath != targetIndexPath else {
            cleanupDragging()
            return
        }

        viewModel.swapTiles(at: startIndexPath.item, with: targetIndexPath.item)

        self.viewModel.onPuzzleUpdated?()
        self.cleanupDragging()

        let targetTileIndex = targetIndexPath.item

        if self.viewModel.isAtCorrectPosition(at: targetTileIndex) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let cell = self.puzzleCollectionView.cellForItem(
                    at: IndexPath(item: targetTileIndex, section: 0)
                ) as? PuzzleCollectionViewCell {
                    self.animateCellBorder(cell)
                }
            }
        }
        
        checkPuzzleCompletion()

    }
    
    //MARK: Helper Methods
    
    /**
     Animates the border of a collection view cell to highlight it when the puzzle piece is placed in the correct position.
     - Parameters:
        - cell: The UICollectionViewCell to animate the border of.
                This is typically the cell that has been correctly placed in the puzzle.
     */
    private func animateCellBorder(_ cell: UICollectionViewCell) {
        UIView.animate(withDuration: 0.3) {
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 3.0
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
            }
        }
    }
    
    /**
     Cleans up the dragging view once the gesture has ended or if dragging needs to be cancelled.
     Ensures that the dragging view is removed from the collection view
     and that `draggingView` and `startIndexPath` properties are reset.
     */
    private func cleanupDragging() {
        draggingView?.removeFromSuperview()
        draggingView = nil
        startIndexPath = nil
    }
    
    /**
     Checks if the puzzle has been completed.
     If the puzzle is complete, shows  the button to load a new puzzle
     and shows a completion alert if the puzzle is completed.
     */
    private func checkPuzzleCompletion() {
        if viewModel.isPuzzleComplete() {
            loadNewPuzzleButton.isHidden = false
            showCompletionAlert()
        }
    }
    
    /// Displays an alert informing the user that they have completed the puzzle.
    private func showCompletionAlert() {
        let alertController = UIAlertController(title: "Congratulations!",
                                                message: "You have completed the puzzle.",
                                                preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.present(alertController, animated: true)
        }
    }
    
    /// Calls the method in the view model to load a new image and starts a new puzzle.
    @objc private func loadNewPuzzle() {
        Task {
            await viewModel.loadImage()
        }
        loadNewPuzzleButton.isHidden = true
    }

    @objc private func updateConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints + landscapeConstraints)
        NSLayoutConstraint.activate(UIDevice.current.orientation.isLandscape ?
                                    landscapeConstraints : portraitConstraints)

    }
}

//MARK: UI Setup
private extension PuzzleViewController {
    func setupViews() {
        setupPuzzleCollectionView()
        setupReloadPuzzleButton()
    }
    
    func setupPuzzleCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let itemWidth = view.bounds.width / 3
        let itemHeight = itemWidth
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        puzzleCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        puzzleCollectionView.backgroundColor = .systemBackground
        puzzleCollectionView.dataSource = self
        puzzleCollectionView.register(PuzzleCollectionViewCell.self,
                                      forCellWithReuseIdentifier: PuzzleCollectionViewCell.identifier)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        
        puzzleCollectionView.addGestureRecognizer(gesture)
        
        view.addSubview(puzzleCollectionView)
    }
    
    func setupReloadPuzzleButton() {
        loadNewPuzzleButton.isHidden = true
        loadNewPuzzleButton.setTitle("Load new puzzle", for: .normal)
        loadNewPuzzleButton.setTitleColor(.blue, for: .normal)
        loadNewPuzzleButton.titleLabel?.font = .systemFont(ofSize: 18)
        loadNewPuzzleButton.contentHorizontalAlignment = .trailing
        loadNewPuzzleButton.addTarget(self, action: #selector(loadNewPuzzle), for: .touchUpInside)
        
        view.addSubview(loadNewPuzzleButton)
    }
    
    //MARK: Constraints
    func setupConstraints() {
        puzzleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        loadNewPuzzleButton.translatesAutoresizingMaskIntoConstraints = false
        
        portraitConstraints = [
            puzzleCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            puzzleCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            puzzleCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            puzzleCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            puzzleCollectionView.heightAnchor.constraint(equalTo: puzzleCollectionView.widthAnchor),
            
            loadNewPuzzleButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            loadNewPuzzleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            loadNewPuzzleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            loadNewPuzzleButton.heightAnchor.constraint(equalToConstant: 40),
        ]
        
        landscapeConstraints = [
            puzzleCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            puzzleCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            puzzleCollectionView.widthAnchor.constraint(equalTo: view.heightAnchor),
            puzzleCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor),
            
            loadNewPuzzleButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            loadNewPuzzleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loadNewPuzzleButton.leadingAnchor.constraint(equalTo: puzzleCollectionView.leadingAnchor, constant: 10),
            loadNewPuzzleButton.heightAnchor.constraint(equalToConstant: 40),
        ]
        
        updateConstraints()
    }
}
