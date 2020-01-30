//
//  DemoTableViewController.swift
//  ImageInNavigationBarDemo
//
//  Created by Tung Fam on 11/14/17.
//  Copyright © 2017 Tung Fam. All rights reserved.
//

import UIKit

extension DemoTableViewController {
    /// WARNING: Change these constants according to your project's design
    private struct Const {
        /// Image height/width for Large NavBar state
        static let ImageSizeForLargeState: CGFloat = 40
        /// Margin from right anchor of safe area to right anchor of Image
        static let ImageRightMargin: CGFloat = 16
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
        static let ImageBottomMarginForLargeState: CGFloat = 12
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
        static let ImageBottomMarginForSmallState: CGFloat = 6
        /// Image height/width for Small NavBar state
        static let ImageSizeForSmallState: CGFloat = 32
        /// Height of NavBar for Small state. Usually it's just 44
        static let NavBarHeightSmallState: CGFloat = 44
        /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
        static let NavBarHeightLargeState: CGFloat = 96.5
        /// Image height/width for Landscape state
        static let ScaleForImageSizeForLandscape: CGFloat = 0.65
    }
}

final class DemoTableViewController: UITableViewController {

    private let imageView = UIImageView(image: UIImage(named: "image_name"))
    private var shouldResize: Bool?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showTutorialAlert()
        observeAndHandleOrientationMode()

        if UIDevice.current.orientation.isPortrait {
            shouldResize = true
        } else if UIDevice.current.orientation.isLandscape {
            shouldResize = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showImage(false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showImage(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let shouldResize = shouldResize
            else { assertionFailure("shouldResize wasn't set. reason could be non-handled device orientation state"); return }

        if shouldResize {
            moveAndResizeImageForPortrait()
        }
    }

    // MARK: - Scroll View Delegates

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let shouldResize = shouldResize
            else { assertionFailure("shouldResize wasn't set. reason could be non-handled device orientation state"); return }

        if shouldResize {
            moveAndResizeImageForPortrait()
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true

        title = "Resizing image 👉"

        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(imageView)
        imageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor,
                                             constant: -Const.ImageRightMargin),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor,
                                              constant: -Const.ImageBottomMarginForLargeState),
            imageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            ])
    }

    private func observeAndHandleOrientationMode() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIDeviceOrientationDidChange, object: nil, queue: OperationQueue.current) { [weak self] _ in
            
            if UIDevice.current.orientation.isPortrait {
                self?.title = "Resizing image 👉"
                self?.moveAndResizeImageForPortrait()
                self?.shouldResize = true
            } else if UIDevice.current.orientation.isLandscape {
                self?.title = "Non 🙅🏽‍♂️ resizing image"
                self?.resizeImageForLandscape()
                self?.shouldResize = false
            }
        }
    }
    
    private func moveAndResizeImageForPortrait() {
        guard let height = navigationController?.navigationBar.frame.height else { return }

        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()

        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState

        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()

        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()
            
        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        
        imageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }

    private func resizeImageForLandscape() {
        let yTranslation = Const.ImageSizeForLargeState * Const.ScaleForImageSizeForLandscape
        imageView.transform = CGAffineTransform.identity
            .scaledBy(x: Const.ScaleForImageSizeForLandscape, y: Const.ScaleForImageSizeForLandscape)
            .translatedBy(x: 0, y: yTranslation)
    }
    
    /// Show or hide the image from NavBar while going to next screen or back to initial screen
    ///
    /// - Parameter show: show or hide the image from NavBar
    private func showImage(_ show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.imageView.alpha = show ? 1.0 : 0.0
        }
    }

    private func showTutorialAlert() {
        let alert = UIAlertController(title: "Tutorial", message: "Scroll down and up to resize the image in navigation bar.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Got it!", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }

}

extension DemoTableViewController {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell", for: indexPath)
        cell.textLabel?.text = "row \(indexPath.row)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SegueID", sender: nil)
    }
}
