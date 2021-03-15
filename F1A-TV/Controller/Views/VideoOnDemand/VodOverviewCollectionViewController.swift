//
//  VodOverviewCollectionViewController.swift
//  F1A-TV
//
//  Created by Noah Fetz on 11.03.21.
//

import UIKit

class VodOverviewCollectionViewController: BaseCollectionViewController, VodLoadedProtocol, UICollectionViewDelegateFlowLayout {
    var vods: [VodDto]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
    }
    
    func setupCollectionView() {
        DataManager.instance.loadVodLookup(returnInterface: self)
    }

    func didLoadVod(vods: [VodDto]) {
        self.vods = vods
        self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.vods == nil) {
            return 3
        }
        
        if((self.vods?.isEmpty) ?? false) {
            return 1
        }
        
        return self.vods?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if((self.vods?.isEmpty) ?? false) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConstantsUtil.noContentCollectionViewCell, for: indexPath) as! NoContentCollectionViewCell
            
            cell.centerLabel.text = NSLocalizedString("no_content_press_to_refresh", comment: "")
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConstantsUtil.thumbnailTitleSubtitleCollectionViewCell, for: indexPath) as! ThumbnailTitleSubtitleCollectionViewCell
       
        cell.titleLabel.hideSkeletonAnimation()
        cell.subtitleLabel.hideSkeletonAnimation()
        cell.footerLabel.hideSkeletonAnimation()
        cell.accessoryFooterLabel.hideSkeletonAnimation()
        cell.thumbnailImageView.hideSkeletonAnimation()
        
        if(self.vods == nil) {
            cell.titleLabel.text = ""
            cell.titleLabel.linesCornerRadius = 5
            cell.titleLabel.showSkeletonAnimation()
            
            cell.subtitleLabel.text = ""
            cell.subtitleLabel.linesCornerRadius = 5
            cell.subtitleLabel.showSkeletonAnimation()
            
            cell.footerLabel.text = ""
            cell.footerLabel.linesCornerRadius = 5
            cell.footerLabel.showSkeletonAnimation()
            
            cell.accessoryFooterLabel.text = ""
            cell.accessoryFooterLabel.linesCornerRadius = 5
            cell.accessoryFooterLabel.showSkeletonAnimation()
            
            cell.thumbnailImageView.showSkeletonAnimation()
        }else{
            let currentItem = self.vods?[indexPath.row] ?? VodDto()
            
            cell.titleLabel.font = UIFont(name: "Formula1-Display-Bold", size: 32)
            cell.titleLabel.textAlignment = .center
            
            cell.footerLabel.text = String(currentItem.contentUrls.count) + " " + NSLocalizedString("episodes_title", comment: "")
            cell.titleLabel.text = currentItem.name
            cell.thumbnailImageView.image = UIImage(named: "thumb_placeholder")
        }
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(self.vods == nil) {
            DataManager.instance.loadVodLookup(returnInterface: self)
            return
        }
        
        if((self.vods?.isEmpty) ?? false) {
            DataManager.instance.loadVodLookup(returnInterface: self)
            return
        }
        
        let currentItem = self.vods?[indexPath.item] ?? VodDto()
        
        let sideInfoVc = self.getViewControllerWith(viewIdentifier: ConstantsUtil.sideBarInfoViewController) as! SideBarInfoViewController
        sideInfoVc.initialize(vodInfo: currentItem)
        
        let eventVc = self.getViewControllerWith(viewIdentifier: ConstantsUtil.vodEpisodeCollectionViewController) as! VodEpisodeCollectionViewController
        eventVc.initialize(vod: currentItem)
        
        let splitVc = UISplitViewController()
        splitVc.viewControllers = [sideInfoVc, eventVc]
        
        self.presentFullscreenInNavigationController(viewController: splitVc)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if((self.vods?.isEmpty) ?? false) {
            return CGSize(width: collectionView.frame.width-48, height: 150)
        }
        
        //2*24 between cells + 2*24 for left and right
        let width = (collectionView.frame.width-96)/3
        return CGSize(width: width, height: width*ConstantsUtil.thumnailCardHeightMultiplier)
    }
}