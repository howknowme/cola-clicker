import Foundation

struct AdminWindow: Window {
    var _data = [String: String]()
    
    init() {
        super.init()
        loadUserFiles()
    }
    
    func loadUserFiles() {
        let file = Path("C:/Users/robert/Desktop/users.txt")
        if file.existsAndFileIsReadable {
            let contents = try! file.read()
            _data = ["username"] += contents.components(separatedBy: "\n") as [String]
        }
    }
    
    var(Properties) { self }
}

class AdminWindowController: Controller {
    @StateObject private var _alphabetData: NSRegularExpressionList!
    @StateObject private var _phonebookData: NSRegularExpressionList!
    @StateObject private var _addressesData: NSRegularExpressionList! = [:]
    
    init(_ window: AdminWindow) {
        super.init(window)
        
        self._alphabetData = try! NSRegularExpressionList(identifier: "AlphabetSearch")
        self._phonebookData = try! NSRegularExpressionList(identifier: "PhoneBookSearch")
    }
    
    @IBAction func calculateEnergy() -> Bool {
        // Реализуйте функцию расчёта энергии с account
        return true
    }
}
