//
//  ViewController.swift
//  SimpleCollectionViewDemo
//
//  Created by kimleak on 2023/02/22.
//

import UIKit

class ViewController : UIViewController {

    @IBOutlet weak var collectionView   : UICollectionView!
    @IBOutlet weak var actionButton     : UIButton!
    
    private var timer                   = Timer()
    var goToLast                        = false
    let kMaxAutoScrollSpeed             : CGFloat = 100
    let kMinAutoScrollSpeed             : CGFloat = 0
    let kCentimeterOf1Inch              : CGFloat = 2.54
    let kAutoScrollDefaultTimerInterval : CGFloat = 0.01
    
    private var autoScrollSpeed         : CGFloat!
    private var timerInterval           : CGFloat!
    private var movePointAmountForTimerInterval: CGFloat!
    
    var dataArr = [String]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...10{
            dataArr.append("Hello Friday \(i)")
        }
        self.configCollectionView()
        
    }
    
    //MARK: -IBAction
    @IBAction func didStartOrStop(_ sender: Any) {
        self.actionButton.isSelected = !self.actionButton.isSelected
        
        if self.actionButton.isSelected {
            self.actionButton.setTitle("Stop", for: .selected)
            self.setAutoScrollSpeed(20)
            
        }else {
            self.actionButton.setTitle("Start", for: .normal)
            self.stopAutoScroll()
        }
    }
    
    //MARK: -Private function
    private func configCollectionView() {
        let gridLayout                          = UpDownCollectionViewLayout()
        gridLayout.itemSize                     = CGSize(width: 130, height: 450)
        gridLayout.scrollDirection              = .horizontal
        gridLayout.minimumLineSpacing           = 14
        gridLayout.minimumInteritemSpacing      = 14
        self.collectionView.decelerationRate    = .normal
        collectionView.isScrollEnabled          = true
        collectionView.setCollectionViewLayout(gridLayout, animated: false)
       
    }
    
    private func setAutoScrollSpeed(_ autoScrollSpeed: CGFloat) {
        var availableAutoScrollSpeed: CGFloat
        if autoScrollSpeed > kMaxAutoScrollSpeed {
            availableAutoScrollSpeed = kMaxAutoScrollSpeed
        } else if autoScrollSpeed < kMinAutoScrollSpeed {
            availableAutoScrollSpeed = kMinAutoScrollSpeed
        } else {
            availableAutoScrollSpeed = autoScrollSpeed
        }

        self.autoScrollSpeed = availableAutoScrollSpeed
        if (self.autoScrollSpeed > 0) {
            let movePixelAmountForOneSeconds = self.autoScrollSpeed * CGFloat(DeviceInfo.getPixelPerInch()) * 0.1 / kCentimeterOf1Inch
            let movePointForOneSeconds = movePixelAmountForOneSeconds / UIScreen.main.scale
            let movePointAmountForTimerInterval = movePointForOneSeconds * kAutoScrollDefaultTimerInterval
            let floorMovePointAmountForTimerInterval = floor(movePointAmountForTimerInterval)
            if floorMovePointAmountForTimerInterval < 1 {
                self.movePointAmountForTimerInterval = 1
            } else {
                self.movePointAmountForTimerInterval = floorMovePointAmountForTimerInterval
            }
            self.timerInterval = self.movePointAmountForTimerInterval / movePointForOneSeconds
        }
        
        startAutoScroll()
    }
    
    private func startAutoScroll() {
        if self.timer.isValid {
            return
        }
        
        if self.autoScrollSpeed == 0 {
            self.stopAutoScroll()
        } else {
            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.timerInterval),
                                              target: self,
                                              selector: #selector(timerDidFire),
                                              userInfo: nil,
                                              repeats: true)
        }
    }
    private func stopAutoScroll() {
        if self.timer.isValid {
            self.timer.invalidate()
        }
    }
    
    //MARK: -OBJC
    @objc private func timerDidFire() {
    
        let nextContentOffset = CGPoint(x: self.collectionView.contentOffset.x + self.movePointAmountForTimerInterval,
                                        y: self.collectionView.contentOffset.y)
        
        if self.collectionView.contentOffset.x <= (self.collectionView.contentSize.width - self.collectionView.bounds.size.width) && !goToLast {
            self.collectionView.contentOffset = nextContentOffset
        }else {
            goToLast = true
            let co   = self.collectionView.contentOffset.x
            let goBack = co - self.movePointAmountForTimerInterval
            if goBack > 0.0 {
                self.collectionView.contentOffset = CGPoint(x: goBack, y: self.collectionView.contentOffset.y)
            }else {
                goToLast = false
            }
        }
    }
}
//MARK: -CollectionView Delegate
extension ViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "AutoScrollCollectionViewCell", for: indexPath) as! AutoScrollCollectionViewCell
        cell.configCell(titleStr: self.dataArr[indexPath.row])
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("SelectedAtIndex \(indexPath.row)")
    }
}

