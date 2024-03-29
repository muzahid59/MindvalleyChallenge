//
//  ChannelCell.swift
//  Mindvalley-Challenge
//
//  Created by Muzahidul Islam on 24/5/20.
//  Copyright © 2020 Muzahid. All rights reserved.
//

import UIKit

struct TableViewCourseCellViewModel {
    let channel: Channel
    
    func getTextHeight(for media: Media) -> CGFloat {
        var totalHeight: CGFloat = 0
        let titleFont = UIFont(name: "Roboto-Regular", size: 17)!
        let titleHeight = media.title.getHeight(for: SingleCourseCell.itemWidth , font: titleFont)
        totalHeight += titleHeight
        
        return totalHeight
    }
   
    
    func itemMaxHeight() -> CGFloat {
        let photoHeight: CGFloat = 228.0
        let spacing: CGFloat = 10.0
        let textHeight = channel.latestMedia.map { getTextHeight(for: $0) }.max() ?? 22
        return photoHeight + spacing + textHeight
    }
    
    var mediaList: [Media] {
        channel.latestMedia
    }
    var itemCount: Int {
        return min(mediaList.count, 6)
    }
    var iconUrl: URL? {
        channel.iconUrl
    }
    var title: String? {
        channel.title
    }
    var episodes: String? {
        "\(channel.mediaCount ?? 0)  episodes"
    }
    
}


final class TableViewCourseCell: UITableViewCell {
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var channelImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            let nib = UINib(nibName: "SingleCourseCell", bundle: Bundle(for: SingleCourseCell.self))
            collectionView.register(nib, forCellWithReuseIdentifier:
                SingleCourseCell.reuseID())
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    private var loadingCount = 5
    private var viewModel: TableViewCourseCellViewModel?
    private var layout: HorizontalFlowLayout?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureLayout()
        channelImage.layer.cornerRadius = 25.0
    }
    
    private func configureLayout() {
        let layout = HorizontalFlowLayout()
        let height = collectionView.bounds.height
        layout.itemSize = CGSize(width: SingleCourseCell.itemWidth, height: height)
        collectionView.collectionViewLayout = layout
        self.layout = layout
    }
    
    private func updateItemSize(_ height: CGFloat) {
        collectionViewHeight.constant = height
        layout?.itemSize.height = height
        layout?.invalidateLayout()
        setNeedsUpdateConstraints()
    }
    
}

// MARK: - CellConfigurable
extension TableViewCourseCell: CellConfigurable {
    typealias ModelType = TableViewCourseCellViewModel

    func configure(model: TableViewCourseCellViewModel) {
        self.viewModel = model
        if let url = model.iconUrl {
            channelImage.loadImage(url)
        }
        
        channelTitle.text = model.title
        countLabel.text = model.episodes
        updateItemSize(model.itemMaxHeight())
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension TableViewCourseCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.itemCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleCourseCell.reuseID(),
                                                      for: indexPath) as! SingleCourseCell
        if let media = viewModel?.mediaList[indexPath.row] {
            let viewModel = SingleCourseCellViewModel(media: media)
            cell.configure(model: viewModel)
        }
        
        return cell
    }
    
}
