//
//  LanguageSelectTableViewController.swift
//  
//
//  Created by James Scherer on 11/8/17.
//

import UIKit

protocol langSelectProtocol {
    func setLanguage(lang: String, synthLang: String, transLang: String)
}

class LanguageSelectTableViewController: UITableViewController {

    var delegate: langSelectProtocol?
    
    var availableLanguages = [["language": "Arabic", "avSpeechCode" : "ar-SA", "transCode" : "ar"],
                              ["language" : "Chinese", "avSpeechCode" : "zh-CN", "transCode" : "zh-CN"],
                              ["language" : "Czech", "avSpeechCode" : "cs-CZ", "transCode" : "cs"],
                              ["language" : "Danish", "avSpeechCode" : "da-DK", "transCode" : "da"],
                              ["language" : "Dutch", "avSpeechCode" : "nl-BE", "transCode" : "nl"],
                              ["language" : "English", "avSpeechCode" : "en-US", "transCode" : "en"],
                              ["language" : "Finnish", "avSpeechCode" : "fi-FA", "transCode" : "fi"],
                              ["language" : "French", "avSpeechCode" : "fa-FR", "transCode" : "fr"],
                              ["language" : "German", "avSpeechCode" : "de-DE", "transCode" : "de"],
                              ["language" : "Greek", "avSpeechCode" : "el-GR", "transCode" : "el"],
                              ["language" : "Hebrew", "avSpeechCode" : "he-IL", "transCode" : "iw"],
                              ["language" : "Hindi", "avSpeechCode" : "hi-IN", "transCode" : "hi"],
                              ["language" : "Hungarian", "avSpeechCode" : "hu-HU", "transCode" : "hu"],
                              ["language" : "Indonesian", "avSpeechCode" : "id-ID", "transCode" : "id"],
                              ["language" : "Italian", "avSpeechCode" : "it-IT", "transCode" : "it"],
                              ["language" : "Japanese", "avSpeechCode" : "ja-JP", "transCode" : "ja"],
                              ["language" : "Korean", "avSpeechCode" : "ko-KR", "transCode" : "ko"],
                              ["language" : "Norwegian", "avSpeechCode" : "no-NO", "transCode" : "no"],
                              ["language" : "Polish", "avSpeechCode" : "pl-PL", "transCode" : "pl"],
                              ["language" : "Portuguese", "avSpeechCode" : "pt-PL", "transCode" : "pt"],
                              ["language" : "Romanian", "avSpeechCode" : "ro-RO", "transCode" : "ro"],
                              ["language" : "Russian", "avSpeechCode" : "ru-RU", "transCode" : "ru"],
                              ["language" : "Slovak", "avSpeechCode" : "sk-SK", "transCode" : "sk"],
                              ["language" : "Spanish", "avSpeechCode" : "es-ES", "transCode" : "es"],
                              ["language" : "Swedish", "avSpeechCode" : "sv_SE", "transCode" : "sv"],
                              ["language" : "Thai", "avSpeechCode" : "th-TH", "transCode" : "th"],
                              ["language" : "Turkish", "avSpeechCode" : "tr-TR", "transCode" : "tr"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let test = availableLanguages[0]
        
        print(test)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return availableLanguages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath)

        // Configure the cell...
        
        let temp = availableLanguages[indexPath.row]
        
        cell.textLabel!.text = temp["language"]

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLang = availableLanguages[indexPath.row]
        
        delegate?.setLanguage(lang: selectedLang["language"]!, synthLang: selectedLang["avSpeechCode"]!, transLang: selectedLang["transCode"]!)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
