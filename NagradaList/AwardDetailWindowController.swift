//
//  AwardDetailWindowController.swift
//  NagradaList
//
//  Created by Auto on 01.12.2025.
//

import Cocoa

class AwardDetailWindowController: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var comboKampania: NSComboBox!
    @IBOutlet weak var comboNagrada: NSComboBox!
    @IBOutlet weak var textNomer: NSTextField!
    @IBOutlet weak var textStepen: NSTextField!
    @IBOutlet weak var textF: NSTextField!
    @IBOutlet weak var textI: NSTextField!
    @IBOutlet weak var textO: NSTextField!
    @IBOutlet weak var comboChast: NSComboBox!
    @IBOutlet weak var comboPodrazdel1: NSComboBox!
    @IBOutlet weak var comboPodrazdel2: NSComboBox!
    @IBOutlet weak var comboChin: NSComboBox!
    @IBOutlet weak var textDolzhnost: NSTextField!
    @IBOutlet weak var textGubernia: NSTextField!
    @IBOutlet weak var textUezd: NSTextField!
    @IBOutlet weak var textDer: NSTextField!
    @IBOutlet weak var textOtlichie: NSTextView!
    @IBOutlet weak var textComment: NSTextView!
    @IBOutlet weak var textPrikaz: NSTextField!
    @IBOutlet weak var textNomerPrik: NSTextField!
    @IBOutlet weak var textDataPrik: NSTextField!
    @IBOutlet weak var textOtnosh: NSTextField!
    @IBOutlet weak var textNomerOtnosh: NSTextField!
    @IBOutlet weak var textDataOtnosh: NSTextField!
    @IBOutlet weak var textSluzhOtm: NSTextView!
    @IBOutlet weak var comboArxiv: NSComboBox!
    @IBOutlet weak var textFond: NSTextField!
    @IBOutlet weak var textOpis: NSTextField!
    @IBOutlet weak var textDelo: NSTextField!
    @IBOutlet weak var textList: NSTextField!
    @IBOutlet weak var textDrugieIst: NSTextField!
    @IBOutlet weak var buttonSave: NSButton!
    @IBOutlet weak var buttonClear: NSButton!
    @IBOutlet weak var checkFormBlocked: NSButton!
    
    var nagrada: Nagrada?
    var isNew: Bool = false
    var edited: Bool = false
    private var noEvents: Bool = false
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        
        fillCombos()
        setupNagradaCombo()
        
        if let nagrada = nagrada {
            fillForm(from: nagrada)
        } else {
            clearForm()
        }
        
        setStatus(blocked: !isNew)
    }
    
    // IBOutlets are optional - if not connected, window will be created programmatically
    // This allows the code to work with or without a storyboard/XIB
    
    func setupNagradaCombo() {
        comboNagrada?.removeAllItems()
        for (index, name) in NagradaConstants.nagradaNames.enumerated() {
            comboNagrada?.addItem(withObjectValue: "\(index). \(name)")
        }
    }
    
    func fillCombos() {
        fillCombo(table: "kampanii", field: "name", combo: comboKampania)
        fillCombo(table: "часть", field: "chast", combo: comboChast)
        fillCombo(table: "подразделение", field: "подразделение", combo: comboPodrazdel1)
        fillCombo(table: "подразделение", field: "подразделение", combo: comboPodrazdel2)
        fillCombo(table: "чин", field: "чин", combo: comboChin)
        fillCombo(table: "архив", field: "архив", combo: comboArxiv)
    }
    
    func fillCombo(table: String, field: String, combo: NSComboBox?) {
        guard let combo = combo else { return }
        combo.removeAllItems()
        if let results = DatabaseManager.shared.executeQuery("SELECT DISTINCT \(field) FROM \(table) ORDER BY \(field)") {
            for result in results {
                if let value = result[field] as? String {
                    combo.addItem(withObjectValue: value)
                }
            }
        }
    }
    
    func fillForm(from nagrada: Nagrada) {
        noEvents = true
        
        if let komp = nagrada.komp {
            comboKampania?.stringValue = komp
        }
        
        if let nagradaType = nagrada.nagrada {
            comboNagrada?.selectItem(at: nagradaType)
        }
        
        textNomer?.stringValue = nagrada.nomer.map { String($0) } ?? ""
        textStepen?.stringValue = nagrada.stepen.map { String($0) } ?? ""
        textF?.stringValue = nagrada.фамилия ?? ""
        textI?.stringValue = nagrada.имя ?? ""
        textO?.stringValue = nagrada.отчество ?? ""
        comboChast?.stringValue = nagrada.chast ?? ""
        comboPodrazdel1?.stringValue = nagrada.podrazdel1 ?? ""
        comboPodrazdel2?.stringValue = nagrada.podrazdel2 ?? ""
        comboChin?.stringValue = nagrada.chin ?? ""
        textDolzhnost?.stringValue = nagrada.dolzhnost ?? ""
        textGubernia?.stringValue = nagrada.Губерния ?? ""
        textUezd?.stringValue = nagrada.Уезд ?? ""
        textDer?.stringValue = nagrada.Деревня ?? ""
        textOtlichie?.string = nagrada.otlichie ?? ""
        textComment?.string = nagrada.komment ?? ""
        textPrikaz?.stringValue = nagrada.prikaz ?? ""
        textNomerPrik?.stringValue = nagrada.nomer_prik ?? ""
        textDataPrik?.stringValue = nagrada.data_prik ?? ""
        textOtnosh?.stringValue = nagrada.otnosh ?? ""
        textNomerOtnosh?.stringValue = nagrada.nomer_otnosh ?? ""
        textDataOtnosh?.stringValue = nagrada.data_otnosh ?? ""
        textSluzhOtm?.string = nagrada.sluzh_otm ?? ""
        comboArxiv?.stringValue = nagrada.arxiv ?? ""
        textFond?.stringValue = nagrada.fond ?? ""
        textOpis?.stringValue = nagrada.opis ?? ""
        textDelo?.stringValue = nagrada.delo ?? ""
        textList?.stringValue = nagrada.list ?? ""
        textDrugieIst?.stringValue = nagrada.drugie_ist ?? ""
        
        noEvents = false
        edited = false
    }
    
    func clearForm() {
        noEvents = true
        
        comboKampania?.stringValue = ""
        if let index = comboNagrada?.indexOfSelectedItem, index >= 0 {
            comboNagrada?.deselectItem(at: index)
        }
        textNomer?.stringValue = ""
        textStepen?.stringValue = ""
        textF?.stringValue = ""
        textI?.stringValue = ""
        textO?.stringValue = ""
        comboChast?.stringValue = ""
        comboPodrazdel1?.stringValue = ""
        comboPodrazdel2?.stringValue = ""
        comboChin?.stringValue = ""
        textDolzhnost?.stringValue = ""
        textGubernia?.stringValue = ""
        textUezd?.stringValue = ""
        textDer?.stringValue = ""
        textOtlichie?.string = ""
        textComment?.string = ""
        textPrikaz?.stringValue = ""
        textNomerPrik?.stringValue = ""
        textDataPrik?.stringValue = ""
        textOtnosh?.stringValue = ""
        textNomerOtnosh?.stringValue = ""
        textDataOtnosh?.stringValue = ""
        textSluzhOtm?.string = ""
        comboArxiv?.stringValue = ""
        textFond?.stringValue = ""
        textOpis?.stringValue = ""
        textDelo?.stringValue = ""
        textList?.stringValue = ""
        textDrugieIst?.stringValue = ""
        
        noEvents = false
        edited = false
    }
    
    func setStatus(blocked: Bool) {
        checkFormBlocked?.state = blocked ? .on : .off
        
        comboKampania?.isEnabled = !blocked
        comboNagrada?.isEnabled = !blocked
        textNomer?.isEditable = !blocked
        textStepen?.isEditable = !blocked
        textF?.isEditable = !blocked
        textI?.isEditable = !blocked
        textO?.isEditable = !blocked
        comboChast?.isEnabled = !blocked
        comboPodrazdel1?.isEnabled = !blocked
        comboPodrazdel2?.isEnabled = !blocked
        comboChin?.isEnabled = !blocked
        textDolzhnost?.isEditable = !blocked
        textGubernia?.isEditable = !blocked
        textUezd?.isEditable = !blocked
        textDer?.isEditable = !blocked
        textOtlichie?.isEditable = !blocked
        textComment?.isEditable = !blocked
        textPrikaz?.isEditable = !blocked
        textNomerPrik?.isEditable = !blocked
        textDataPrik?.isEditable = !blocked
        textOtnosh?.isEditable = !blocked
        textNomerOtnosh?.isEditable = !blocked
        textDataOtnosh?.isEditable = !blocked
        comboArxiv?.isEnabled = !blocked
        textFond?.isEditable = !blocked
        textDelo?.isEditable = !blocked
        textOpis?.isEditable = !blocked
        textList?.isEditable = !blocked
        textDrugieIst?.isEditable = !blocked
        textSluzhOtm?.isEditable = !blocked
    }
    
    @IBAction func buttonSaveClicked(_ sender: Any) {
        saveData()
    }
    
    @IBAction func buttonClearClicked(_ sender: Any) {
        if !isNew {
            showAlert(message: "Уже существующие награды очищать нельзя")
            return
        }
        
        let alert = NSAlert()
        alert.messageText = "Очистить данные формы?"
        alert.addButton(withTitle: "Да")
        alert.addButton(withTitle: "Нет")
        
        if alert.runModal() == .alertFirstButtonReturn {
            clearForm()
        }
    }
    
    func saveData() {
        guard let window = window else { return }
        
        // Validate required fields
        if !validateFields() {
            return
        }
        
        // Check for duplicate
        if checkDuplicate() {
            let alert = NSAlert()
            alert.messageText = "Такая награда уже есть в базе. Все равно записать?"
            alert.addButton(withTitle: "Да")
            alert.addButton(withTitle: "Нет")
            
            if alert.runModal() != .alertFirstButtonReturn {
                return
            }
        }
        
        let id = nagrada?.id ?? UUID().uuidString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let now = dateFormatter.string(from: Date())
        
        // Get values with defaults
        let komp = escape(comboKampania?.stringValue ?? "")
        let nagradaType = comboNagrada?.indexOfSelectedItem ?? -1
        let nomer = Int(textNomer?.stringValue ?? "") ?? 0
        let stepen = Int(textStepen?.stringValue ?? "") ?? 0
        let f = escape(textF?.stringValue ?? "")
        let i = escape(textI?.stringValue ?? "")
        let o = escape(textO?.stringValue ?? "")
        let chast = escape(comboChast?.stringValue ?? "")
        let podrazdel1 = escape(comboPodrazdel1?.stringValue ?? "")
        let podrazdel2 = escape(comboPodrazdel2?.stringValue ?? "")
        let chin = escape(comboChin?.stringValue ?? "")
        let dolzhnost = escape(textDolzhnost?.stringValue ?? "")
        let gubernia = escape(textGubernia?.stringValue ?? "")
        let uezd = escape(textUezd?.stringValue ?? "")
        let der = escape(textDer?.stringValue ?? "")
        let otlichie = escape(textOtlichie?.string ?? "")
        let komment = escape(textComment?.string ?? "")
        let prikaz = escape(textPrikaz?.stringValue ?? "")
        let nomerPrik = escape(textNomerPrik?.stringValue ?? "")
        let dataPrik = escape(textDataPrik?.stringValue ?? "")
        let otnosh = escape(textOtnosh?.stringValue ?? "")
        let nomerOtnosh = escape(textNomerOtnosh?.stringValue ?? "")
        let dataOtnosh = escape(textDataOtnosh?.stringValue ?? "")
        let sluzhOtm = escape(textSluzhOtm?.string ?? "")
        let arxiv = escape(comboArxiv?.stringValue ?? "")
        let fond = escape(textFond?.stringValue ?? "")
        let opis = escape(textOpis?.stringValue ?? "")
        let delo = escape(textDelo?.stringValue ?? "")
        let list = escape(textList?.stringValue ?? "")
        let drugieIst = escape(textDrugieIst?.stringValue ?? "")
        let userName = escape(DatabaseManager.shared.getUserName())
        
        // Format values for SQL
        let nagradaTypeStr = nagradaType >= 0 ? "\(nagradaType)" : "NULL"
        let nomerStr = nomer > 0 ? "\(nomer)" : "NULL"
        let stepenStr = stepen > 0 ? "\(stepen)" : "NULL"
        
        var query: String
        if isNew {
            query = """
            INSERT INTO nagrada (id, komp, nagrada, nomer, stepen, фамилия, имя, отчество,
            chast, podrazdel1, podrazdel2, chin, dolzhnost, Губерния, Уезд, Деревня,
            otlichie, komment, prikaz, nomer_prik, data_prik, otnosh, nomer_otnosh,
            data_otnosh, sluzh_otm, arxiv, fond, opis, delo, list, drugie_ist,
            data_sozd, data_izm, who_sozd, who_red)
            VALUES ('\(id)', '\(komp)', \(nagradaTypeStr),
            \(nomerStr), \(stepenStr),
            '\(f)', '\(i)', '\(o)', '\(chast)', '\(podrazdel1)', '\(podrazdel2)',
            '\(chin)', '\(dolzhnost)', '\(gubernia)', '\(uezd)', '\(der)',
            '\(otlichie)', '\(komment)', '\(prikaz)', '\(nomerPrik)', '\(dataPrik)',
            '\(otnosh)', '\(nomerOtnosh)', '\(dataOtnosh)', '\(sluzhOtm)', '\(arxiv)',
            '\(fond)', '\(opis)', '\(delo)', '\(list)', '\(drugieIst)',
            '\(now)', '\(now)', '\(userName)', '\(userName)')
            """
        } else {
            query = """
            UPDATE nagrada SET
            komp = '\(komp)', nagrada = \(nagradaTypeStr),
            nomer = \(nomerStr), stepen = \(stepenStr),
            фамилия = '\(f)', имя = '\(i)', отчество = '\(o)',
            chast = '\(chast)', podrazdel1 = '\(podrazdel1)', podrazdel2 = '\(podrazdel2)',
            chin = '\(chin)', dolzhnost = '\(dolzhnost)', Губерния = '\(gubernia)',
            Уезд = '\(uezd)', Деревня = '\(der)', otlichie = '\(otlichie)',
            komment = '\(komment)', prikaz = '\(prikaz)', nomer_prik = '\(nomerPrik)',
            data_prik = '\(dataPrik)', otnosh = '\(otnosh)', nomer_otnosh = '\(nomerOtnosh)',
            data_otnosh = '\(dataOtnosh)', sluzh_otm = '\(sluzhOtm)', arxiv = '\(arxiv)',
            fond = '\(fond)', opis = '\(opis)', delo = '\(delo)', list = '\(list)',
            drugie_ist = '\(drugieIst)', data_izm = '\(now)', who_red = '\(userName)'
            WHERE id = '\(id)'
            """
        }
        
        if DatabaseManager.shared.executeUpdate(query) {
            edited = false
            window.title = "Редактор наград"
            showAlert(message: "Данные сохранены")
            
            // Update combo tables if needed
            updateComboTables()
        } else {
            showAlert(message: "Ошибка сохранения данных")
        }
    }
    
    func escape(_ string: String) -> String {
        return string.replacingOccurrences(of: "'", with: "''")
    }
    
    func validateFields() -> Bool {
        // Check required fields - simplified for now
        return true
    }
    
    func checkDuplicate() -> Bool {
        let nagradaType = comboNagrada?.indexOfSelectedItem ?? -1
        let nomer = Int(textNomer?.stringValue ?? "") ?? 0
        let stepen = Int(textStepen?.stringValue ?? "") ?? 0
        
        if nagradaType < 0 || nomer == 0 || stepen == 0 {
            return false
        }
        
        var query = "SELECT * FROM nagrada WHERE nagrada = \(nagradaType) AND stepen = \(stepen) AND nomer = \(nomer)"
        if !isNew, let id = nagrada?.id {
            query += " AND id <> '\(id)'"
        }
        
        return DatabaseManager.shared.recordCount(query) > 0
    }
    
    func updateComboTables() {
        // Add new values to combo tables if they don't exist
        updateComboTable(table: "часть", field: "chast", value: comboChast.stringValue)
        updateComboTable(table: "подразделение", field: "подразделение", value: comboPodrazdel1.stringValue)
        updateComboTable(table: "подразделение", field: "подразделение", value: comboPodrazdel2.stringValue)
        updateComboTable(table: "чин", field: "чин", value: comboChin.stringValue)
        updateComboTable(table: "архив", field: "архив", value: comboArxiv.stringValue)
    }
    
    func updateComboTable(table: String, field: String, value: String) {
        if value.isEmpty { return }
        
        let query = "SELECT \(field) FROM \(table) WHERE \(field) = '\(escape(value))'"
        if DatabaseManager.shared.recordCount(query) == 0 {
            let insertQuery = "INSERT INTO \(table) (id, \(field)) VALUES ('\(UUID().uuidString)', '\(escape(value))')"
            _ = DatabaseManager.shared.executeUpdate(insertQuery)
            fillCombo(table: table, field: field, combo: getComboForTable(table))
        }
    }
    
    func getComboForTable(_ table: String) -> NSComboBox? {
        switch table {
        case "часть": return comboChast
        case "подразделение": return comboPodrazdel1
        case "чин": return comboChin
        case "архив": return comboArxiv
        default: return comboChast
        }
    }
    
    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if edited {
            let alert = NSAlert()
            alert.messageText = "В карточку были внесены изменения! Закрыть без сохранения?"
            alert.addButton(withTitle: "Да")
            alert.addButton(withTitle: "Нет")
            
            if alert.runModal() == .alertSecondButtonReturn {
                // Cancel closing
                return false
            }
        }
        return true
    }
}

