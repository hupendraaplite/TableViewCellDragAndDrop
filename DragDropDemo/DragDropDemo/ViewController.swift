//
//  ViewController.swift
//  LongPress
//
//  Created by Apple on 25/11/22.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK:- IBOUTLet's of the Controller-
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var snapImgView: UIImageView!
    
    //MARK:- Class Variable's of the Controller-
    private var dragView: UIView?
    var viewArray:[UIView] = []
    var dataSource = ["Australia","Australia","Belarus","Canada","Dominica","Estonia","France","Germany","Hungary","India",]
    
    //MARK:- Views's Life-Cycle of the Controller-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.register(UINib(nibName: "DragDropCell", bundle: nil), forCellReuseIdentifier: "DragDropCell")
    }
    
    @IBAction func btnActionTakeSnapShot(_ sender: UIButton) {
        let img = viewTop.takeScreenshot()
        self.snapImgView.image = img
    }
}

//MARK:- Custom Function's of the Controller-
extension ViewController {
    func mooveViewss()  {
        for vie in viewArray {
            print(vie.layer.frame.size.height)
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture))
            vie.isUserInteractionEnabled = true
            vie.isUserInteractionEnabled = true
            vie.isMultipleTouchEnabled = true
            vie.addGestureRecognizer(panGesture)
        }
    }
    @objc func panGesture(sender: UIPanGestureRecognizer){
        let point = sender.location(in: view)
        let panGesture = sender.view
        panGesture?.center = point
        //print(point)
    }
}

//MARK:- UITableViewDelegate,UITableViewDataSource-
extension ViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DragDropCell", for: indexPath) as! DragDropCell
        cell.lbl1.text = dataSource[indexPath.row]
        cell.lbl2.text  = "\(indexPath.row + 1)"
        let lpGestureRecognizer = CustomLongPressGestureRecognizer(target: self, action: #selector(didLongPressCell))
        lpGestureRecognizer.indexPath = indexPath
        cell.contentView.addGestureRecognizer(lpGestureRecognizer)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    @objc func didLongPressCell(sender: CustomLongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if let cellView: UIView = sender.view {
                cellView.frame.origin = CGPoint.zero
                dragView = cellView
                view.addSubview(dragView!)
            }
        case .changed:
            dragView?.center = sender.location(in: view)
        case .ended:
            if (dragView == nil) {return}
            if (dragView!.frame.intersects(viewTop.frame)) {
                if let cellView = (dragView?.subviews[0]) {
                    let point = sender.location(in: view)
                    cellView.frame.origin = point
                    cellView.backgroundColor = UIColor.red
                    cellView.layer.frame.size = CGSize.init(width: 150, height: 50)
                    viewTop.addSubview(cellView)
                    self.viewArray.append(cellView)
                    mooveViewss()
                    if let index = sender.indexPath?.row {
                        DispatchQueue.main.async {
                            self.dataSource.remove(at: index)
                            self.tblView.reloadData()
                        }
                    }
                }
                dragView?.removeFromSuperview()
                dragView = nil
                //Delete row from UITableView if needed...
            } else {
                //DragView was not dropped in dropszone... Rewind animation...
            }
        default:
            print("Any other action?")
        }
    }
}
    
    




extension UIView {
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if (image != nil){
            return image!
        }
        return UIImage()
    }
}


class CustomLongPressGestureRecognizer: UILongPressGestureRecognizer {
    var indexPath: IndexPath?
}
