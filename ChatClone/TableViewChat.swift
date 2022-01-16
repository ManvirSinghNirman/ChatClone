//
//  TableViewChat.swift
//  ChatClone
//
//  Created by Manvir Nirmaan on 2022-01-15.
//  Copyright © 2022 Manvir Singh. All rights reserved.
//

import UIKit
import AVFoundation

class TableViewChat: UITableViewController {

    var arrayChat = [Chat]()
    var imagePicker: ImagePicker!
    @IBOutlet weak var lblUserName :UILabel!
    @IBOutlet weak var imgViewUser :UIImageView!
    var userInfo :User? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.largeTitleDisplayMode = .never
        setUserInfo()
        setHeaderView()
        addDummyMessages()
        setPickerView()

    }
    
    func setUserInfo(){
        
           lblUserName.text = userInfo?.name
           imgViewUser.image = userInfo?.image
        
    }
    
    func setPickerView(){
        self.imagePicker = ImagePicker(presentationController: self, delegate: self, allowEdit: true)
    }
    
    
    func setHeaderView(){
        let nib = UINib(nibName: "TableViewHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TableViewHeader")
    }
    
    func addDummyMessages(){
        
        var arrayMessages = [Messages]()
        
        for i in 0...20 {
            
            arrayMessages.append(Messages(type: .text,
                                          message: "Hey There this is the Dummy Text Message",
                                          image: nil,
                                          time: Date.randomDate(range: 5),
                                          senderID: i % 2 == 0 ? "my" : "other"))
            
            
        }
        
        let cal = Calendar.current
        
        let grouped = Dictionary(grouping: arrayMessages, by: {cal.startOfDay(for: $0.time)})
        
        grouped.forEach { (key,value) in
            
            arrayChat.append(Chat(date: key, messages: value))
            
        }
        
        arrayChat = arrayChat.sorted(by: {$0.date < $1.date})
        
        tableView.reloadData()
        
    }

    
    
    //MARK: Bottom Bar Setup
    override public var inputAccessoryView: UIView? {
        get {
            return newInputContainerView//inputContainerView
        }
    }
    
    override public var canBecomeFirstResponder: Bool{
        get {
            return true
        }
    }
    
    lazy var newInputContainerView: Empty = {
        if let rootView = Bundle.main.loadNibNamed("Empty", owner: self, options: nil) {
            if let view = rootView.first as? Empty {
                view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
                view.btnSend.addTarget(self, action: #selector(btnSendAct(_:)), for: UIControl.Event.touchUpInside)
                view.btnAttachnent.addTarget(self, action: #selector(btnAttachment), for: UIControl.Event.touchUpInside)
                return view
            }
        }
        return Empty()
    }()
    
    @objc func btnSendAct(_ sender: UIButton){
        
        
        let data = Messages(type: .text,
                            message: newInputContainerView.txtView.text,
                            image: nil,
                            time: Date(),
                            senderID: "my")
        
        self.addRow(withData: data)
    }
    
    func addRow(withData data:Messages){
        
        guard let row = self.arrayChat.last?.messages else {return}
        self.arrayChat[self.arrayChat.count - 1].messages.append(data)
        let indexPath = IndexPath(row: row.count, section: self.arrayChat.count - 1)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.tableView.performBatchUpdates({
            
         //   self.collectionView.insertItems(at: [indexPath])
            
            self.tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
        }) { (Finished) in
            
            self.scrollWithDelay(time: 0, indexPath: indexPath)
            AudioServicesPlaySystemSound (1004)
            self.newInputContainerView.txtView.text = ""
            self.newInputContainerView.txtView.textDidChange()
        }
        
        CATransaction.commit()
        
        
    }
    
    func scrollWithDelay(time :Double,indexPath:IndexPath) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            
        }
        
    }
    
    
     @objc func btnAttachment(_ sender: UIButton){
        
        newInputContainerView.txtView.resignFirstResponder()
        imagePicker.present(from: sender)
    
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return arrayChat.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let view = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeader")  as! TableViewHeader
          view.lblDate.text = "  \(dateCoveter(date: arrayChat[section].date) ?? "")  "
          return view
      }
    

    func dateCoveter(date:Date) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        if Calendar.autoupdatingCurrent.isDateInToday(date){
            return "Today"
        }else if Calendar.autoupdatingCurrent.isDateInYesterday(date){
            return "Yesterday"
        }else{
            return dateFormatter.string(from: date)
            
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayChat[section].messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let info = arrayChat[indexPath.section].messages[indexPath.row]
        
        switch info.type {
            
        case .text:
            
            return TextCell(data: info, indexPath: indexPath)
            
        case .image:
            
            return ImageCell(data: info, indexPath: indexPath)
            
        }
        
        
        
    }
    
    func TextCell(data:Messages,indexPath:IndexPath)->UITableViewCell{
        
        if data.senderID == "my"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "myTextCell", for: indexPath) as! MyTextCell

            // Configure the cell...
            cell.configCell(data: data)

            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "otherTextCell", for: indexPath) as! OtherTextCell

            // Configure the cell..
            cell.configCell(data: data)
            return cell
            
        }
                
    }
    
    func ImageCell(data:Messages,indexPath:IndexPath)->UITableViewCell{
        
        if data.senderID == "my"{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "myImageCell", for: indexPath) as? TableImageMessageCell {
                cell.configMyCell(data: data)
                return cell
            }

        }else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "otherImageCell", for: indexPath) as? TableImageMessageCell {
                cell.configMyCell(data: data)
                return cell
            }

        }
        
        
        return UITableViewCell()
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let info = arrayChat[indexPath.section].messages[indexPath.row]
        
        switch info.type {
            
        case .text:
            
            return UITableView.automaticDimension

        case .image:
            
            return 200
            
        }
        
    }

}
//MARK: Image Picker
extension TableViewChat :ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
       
        if let img = image {
            
            let data = Messages(type: .image,
                                message: "",
                                image: img,
                                time: Date(),
                                senderID: "my")
            
            addRow(withData: data)

        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.sendDummyImageMessage()
        }
    
        
    }
    
    
    func sendDummyImageMessage(){
        
        
        if let img = UIImage(named: "dummyUser") {
            
            let data = Messages(type: .image,
                                message: "",
                                image: img,
                                time: Date(),
                                senderID: "other")
            
            addRow(withData: data)

        }
        
        
    }
    
    
}


class MyTextCell :UITableViewCell {
    
    @IBOutlet weak var txtView :UITextView!
    @IBOutlet weak var bgView :UIView!

    
    func configCell(data:Messages){
        txtView.text = data.message
        bgView.layer.cornerRadius = 5
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    }

}

class OtherTextCell :UITableViewCell {
    
    @IBOutlet weak var txtView :UITextView!
    @IBOutlet weak var bgView :UIView!
    
    
    func configCell(data:Messages){
        txtView.text = data.message
        bgView.layer.cornerRadius = 5
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }

}

class TableImageMessageCell: UITableViewCell {
    
    @IBOutlet weak var imgView :UIImageView!
    @IBOutlet weak var bgView :UIView!
    
    func configMyCell(data:Messages){
        
        imgView.image = data.image
        
    }
    
}
