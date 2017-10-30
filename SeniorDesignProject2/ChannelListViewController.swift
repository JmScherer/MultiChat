//
//  ChannelListViewController.swift
//  SeniorDesignProject2
//
//  Created by James Scherer on 10/20/17.
//  Copyright © 2017 James Scherer. All rights reserved.
//

import Firebase

enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}

class ChannelListViewController : UITableViewController {
    
    // MARK: Properties
    
    var senderDisplayName: String?
    var newChannelTextField: UITextField?
    private var channels: [Channel] = [] // 3
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    private var channelRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RW RIC"
        observeChannels()
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        channels.append(Channel(id: "1", name: "Channel 1"))
        channels.append(Channel(id: "2", name: "Channel 2"))
        channels.append(Channel(id: "3", name: "Channel 3"))
        self.tableView.reloadData()

    }*/
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .createNewChannelSection:
                return 1;
            case .currentChannelsSection:
                return channels.count
            }
        }
        else { return 0 }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue ? "NewChannel" : "ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if(indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue {
            if let createNewChannelCell = cell as? CreateChannelCell {
                newChannelTextField = createNewChannelCell.newChannelNameField
            }
        } else if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            cell.textLabel?.text = channels[(indexPath as NSIndexPath).row].name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.currentChannelsSection.rawValue {
            let channel = channels[(indexPath as NSIndexPath).row]
            self.performSegue(withIdentifier: "ShowChannel", sender: channel)
        }
    }
    
    // MARK: Actions
    
    @IBAction func createChannelButtonPressed(_ sender: Any) {
        
        if let name = newChannelTextField?.text {
            let newChannelRef = channelRef.childByAutoId()
            let channelItem = [
                "name": name
            ]
            newChannelRef.setValue(channelItem)
        }
        
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for:segue, sender: sender)
        
        if let channel = sender as? Channel {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = senderDisplayName
            chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
        }
    }
    
    // MARK: Firebase related methods
    
    private func observeChannels() {
        // Use the observe method to listen for new
        // Channels being written to the Firebase DB
        
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = channelData["name"] as! String!, name.characters.count > 0 {
                self.channels.append(Channel(id: id, name: name))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data!!")
            }
            
        })
    }
    
}
