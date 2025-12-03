//
//  MainWindowController.swift
//  NagradaList
//
//  Created by Auto on 01.12.2025.
//

import Cocoa

class MainWindowController: NSWindowController, NSComboBoxDelegate {
    
    var tabView: NSTabView?
    
    // Tab 1: Export to Word
    @IBOutlet weak var checkRules: NSButton!
    @IBOutlet weak var checkOpredeleniya: NSButton!
    @IBOutlet weak var labelStatus: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var buttonMake: NSButton!
    
    // Tab 2: Table View
    @IBOutlet weak var buttonOpenBase: NSButton!
    @IBOutlet weak var comboGroup: NSComboBox!
    @IBOutlet weak var listGroup: NSTableView!
    @IBOutlet weak var grid: NSTableView!
    @IBOutlet weak var buttonAdd: NSButton!
    @IBOutlet weak var buttonOpenNagradaForm: NSButton!
    @IBOutlet weak var textSearch: NSTextField!
    @IBOutlet weak var textDrugieIst: NSTextField!
    @IBOutlet weak var buttonChangeDrugieIst: NSButton!
    
    // Tab 3: Service
    @IBOutlet weak var listReqFields: NSTableView!
    @IBOutlet weak var buttonFillReqFields: NSButton!
    @IBOutlet weak var buttonSaveReqFields: NSButton!
    @IBOutlet weak var buttonClearReqFields: NSButton!
    @IBOutlet weak var textOperatorName: NSTextField!
    @IBOutlet weak var buttonSetOperatorName: NSButton!
    @IBOutlet weak var textFilePath: NSTextField!
    
    // Tab 4: Number Conditions
    @IBOutlet weak var gridNomerConditions: NSTableView!
    @IBOutlet weak var buttonLoadNomerCond: NSButton!
    @IBOutlet weak var buttonSaveNomerCond: NSButton!
    
    // Tab 5: Group Replacement
    @IBOutlet weak var comboPole: NSComboBox!
    @IBOutlet weak var comboSravnenieType: NSComboBox!
    @IBOutlet weak var textZnachenie: NSTextView!
    @IBOutlet weak var checkBoxUchitivatRegistr: NSButton!
    @IBOutlet weak var buttonFillList: NSButton!
    @IBOutlet weak var listSelectedMedals: NSTableView!
    @IBOutlet weak var buttonSelectAll: NSButton!
    @IBOutlet weak var buttonUnselectAll: NSButton!
    @IBOutlet weak var buttonOpenMedal: NSButton!
    @IBOutlet weak var comboChangeType: NSComboBox!
    @IBOutlet weak var comboFieldToChange: NSComboBox!
    @IBOutlet weak var textChange1: NSTextView!
    @IBOutlet weak var textChange2: NSTextView!
    @IBOutlet weak var buttonMakeChanges: NSButton!
    
    // Tab 6: Unload
    @IBOutlet weak var textCheckStatus: NSTextField!
    @IBOutlet weak var buttonEnded: NSButton!
    @IBOutlet weak var buttonNotEnded: NSButton!
    @IBOutlet weak var textUnloadStat: NSTextView!
    @IBOutlet weak var buttonUnloadData: NSButton!
    @IBOutlet weak var textUnloadLog: NSTextView!
    
    var nagradaList: [Nagrada] = []
    var filteredNagradaList: [Nagrada] = []
    var awardDetailWindowController: AwardDetailWindowController?
    
    // Group replacement
    var selectedMedals: [SelectedMedal] = []
    var groupItems: [String] = []
    
    // Group list for filtering
    var groupListItems: [String] = []
    var selectedGroupValue: String? = nil
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        setupUI()
        loadInitialData()
    }
    
    func setupUI() {
        window?.title = "Рабочее место оператора: \(DatabaseManager.shared.getUserName())"
        textOperatorName?.stringValue = DatabaseManager.shared.getUserName()
        
        // Setup combo boxes
        setupComboGroup()
        setupComboPole()
        setupComboFieldToChange()
        setupComboChangeType()
        setupComboSravnenieType()
        
        // Setup table view
        setupTableView()
        
        // Setup checkboxes
        checkRules?.state = .on
        checkOpredeleniya?.state = .on
        
        // Setup file path
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        textFilePath?.stringValue = documentsPath.appendingPathComponent("base.db").path
    }
    
    // Список категорий для фильтрации
    private let groupCategories = [
        "Все записи", "Кампания", "Часть", "Подразделение 1",
        "Подразделение 2", "Чин", "Должность", "Приказ", "Номер приказа"
    ]
    
    func setupComboGroup() {
        comboGroup?.removeAllItems()
        comboGroup?.addItems(withObjectValues: groupCategories)
        comboGroup?.selectItem(at: 0)
    }
    
    func getSelectedGroupName() -> String {
        let selectedIndex = comboGroup?.indexOfSelectedItem ?? 0
        if selectedIndex >= 0 && selectedIndex < groupCategories.count {
            return groupCategories[selectedIndex]
        }
        return "Все записи"
    }
    
    func setupComboPole() {
        comboPole?.removeAllItems()
        comboPole?.addItems(withObjectValues: [
            "Нет", "Отличие", "Приказ", "Номер приказа", "Дата приказа",
            "Часть", "Подразделение 1", "Подразделение 2", "Архив", "Фонд",
            "Опись", "Дело", "Др. источники", "Чин", "Должность",
            "Оператор (создание)", "Кампания", "Лист", "Комментарий",
            "Губерния", "Уезд", "Деревня", "Служебные отметки",
            "Отношение", "Номер отношения", "Дата отношения"
        ])
        comboPole?.selectItem(at: 0)
    }
    
    func setupComboFieldToChange() {
        comboFieldToChange?.removeAllItems()
        comboFieldToChange?.addItems(withObjectValues: [
            "Нет", "Отличие", "Приказ", "Номер приказа", "Дата приказа",
            "Часть", "Подразделение 1", "Подразделение 2", "Архив", "Фонд",
            "Опись", "Дело", "Др. источники", "Чин", "Должность",
            "Оператор (создание)", "Кампания", "Лист", "Комментарий",
            "Губерния", "Уезд", "Деревня", "Служебные отметки",
            "Отношение", "Номер отношения", "Дата отношения"
        ])
        comboFieldToChange?.selectItem(at: 0)
    }
    
    func setupComboChangeType() {
        comboChangeType?.removeAllItems()
        comboChangeType?.addItems(withObjectValues: [
            "Нет", "Установить текст", "Замена части текста",
            "Добавление текста", "Очистить поле"
        ])
        comboChangeType?.selectItem(at: 0)
    }
    
    func setupComboSravnenieType() {
        comboSravnenieType?.removeAllItems()
        comboSravnenieType?.addItems(withObjectValues: ["Равно", "Включает"])
        comboSravnenieType?.selectItem(at: 0)
    }
    
    func setupTableView() {
        // Setup grid columns will be done in storyboard or programmatically
        grid?.delegate = self
        grid?.dataSource = self
    }
    
    func loadInitialData() {
        loadNagradaList()
    }
    
    func loadNagradaList() {
        // Загружаем все записи при открытии базы
        loadAllRecords()
        
        // Обновляем список групп при загрузке данных
        updateGroupList()
    }
    
    // MARK: - Actions
    
    @objc @IBAction func buttonOpenBaseClicked(_ sender: Any) {
        setupComboGroup()
        loadNagradaList()
        //        updateGroupList()
    }
    
    @objc @IBAction func comboGroupChanged(_ sender: Any) {
        updateGroupList()
    }
    
    // MARK: - NSComboBoxDelegate
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        guard let comboBox = notification.object as? NSComboBox else { return }
        if comboBox == comboGroup {
            print("comboGroup selection changed to index: \(comboBox.indexOfSelectedItem)")
            updateGroupList()
        }
    }
    
    func comboBoxSelectionIsChanging(_ notification: Notification) {
        // Можно обработать здесь, если нужно
    }
    
    func updateGroupList() {
        let selectedIndex = comboGroup?.indexOfSelectedItem ?? 0
        if selectedIndex == 0 {
            // "Все записи" - показываем все без фильтрации
            updateListGroup(items: ["Все"])
            loadAllRecords()
        } else {
            // Выбрана категория для фильтрации - загружаем уникальные значения этой категории с количеством
            let selectedGroupName = getSelectedGroupName()
            let fieldName = getFieldName(for: selectedGroupName)
            
            // Получаем уникальные значения с количеством записей для каждого значения
            // Формат: "значение (количество)" или "(количество)" для NULL/пустых значений
            let query: String
            if fieldName == "nomer_prik" {
                // Для числовых полей
                query = "SELECT CASE WHEN \(fieldName) IS NULL OR \(fieldName) = '' THEN '' ELSE CAST(\(fieldName) AS TEXT) END AS value, COUNT(*) AS count FROM nagrada GROUP BY value ORDER BY CASE WHEN value = '' THEN 1 ELSE 0 END, CAST(value AS INTEGER)"
            } else {
                // Для строковых полей
                query = "SELECT COALESCE(NULLIF(\(fieldName), ''), '') AS value, COUNT(*) AS count FROM nagrada GROUP BY value ORDER BY CASE WHEN value = '' THEN 1 ELSE 0 END, value"
            }
            
            if let results = DatabaseManager.shared.executeQuery(query) {
                var groupItems = ["Все"]
                for row in results {
                    let value: String
                    if let stringValue = row["value"] as? String {
                        value = stringValue
                    } else if let intValue = row["value"] as? Int64 {
                        value = String(intValue)
                    } else if let intValue = row["value"] as? Int {
                        value = String(intValue)
                    } else {
                        value = ""
                    }
                    
                    // Получаем количество
                    let count: Int
                    if let countInt64 = row["count"] as? Int64 {
                        count = Int(countInt64)
                    } else if let countInt = row["count"] as? Int {
                        count = countInt
                    } else {
                        count = 0
                    }
                    
                    // Форматируем: "значение (количество)" или "(количество)" для пустых значений
                    let displayValue: String
                    if value.isEmpty {
                        displayValue = "(\(count))"
                    } else {
                        displayValue = "\(value) (\(count))"
                    }
                    
                    groupItems.append(displayValue)
                }
                print("✅ Найдено \(groupItems.count - 1) уникальных значений для поля \(fieldName)")
                updateListGroup(items: groupItems)
            } else {
                // Если не удалось получить значения, показываем пустой список
                print("⚠️ Не удалось получить значения для поля \(fieldName)")
                updateListGroup(items: ["Все"])
            }
            
            // Сбрасываем выбранное значение и показываем все записи до выбора конкретного значения
            selectedGroupValue = nil
            loadAllRecords()
        }
    }
    
    func loadAllRecords() {
        // Загружаем все записи из базы данных
        if let results = DatabaseManager.shared.executeQuery("SELECT * FROM nagrada ORDER BY data_izm DESC LIMIT 50000") {
            nagradaList = results.compactMap { row in
                let nagrada = Nagrada(from: row)
                // Проверяем, что данные загрузились правильно
                if nagrada.id.isEmpty {
                    return nil
                }
                return nagrada
            }
            filteredNagradaList = nagradaList
            print("✅ Загружено \(nagradaList.count) записей из базы данных")
            if !nagradaList.isEmpty {
                let first = nagradaList[0]
                print("🔍 Первая запись: id=\(first.id), nagrada=\(first.nagrada?.description ?? "nil"), stepen=\(first.stepen?.description ?? "nil"), nomer=\(first.nomer?.description ?? "nil"), dolzhnost=\(first.dolzhnost ?? "nil")")
            }
            grid?.reloadData()
        } else {
            nagradaList = []
            filteredNagradaList = []
            print("❌ Не удалось загрузить данные из базы")
            grid?.reloadData()
        }
    }
    
    func updateListGroup(items: [String]) {
        groupListItems = items
        listGroup?.reloadData()
        
        // Если список не пустой, выбираем первый элемент ("Все")
        if !groupListItems.isEmpty {
            listGroup?.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            selectedGroupValue = nil // "Все" означает отсутствие фильтра
            // Не вызываем filterTableByGroup здесь, чтобы не загружать данные дважды
            // Фильтрация произойдет при выборе конкретного значения пользователем
        }
    }
    
    func filterTableByGroup() {
        let selectedIndex = comboGroup?.indexOfSelectedItem ?? 0
        print("🔍 filterTableByGroup вызван. selectedIndex = \(selectedIndex), selectedGroupValue = \(selectedGroupValue ?? "nil")")
        
        // Если выбрано "Все записи" или "Все" в списке значений
        if selectedIndex == 0 || selectedGroupValue == nil {
            // Показываем все записи из базы данных
            print("✅ Показываем все записи (нет фильтра)")
            loadAllRecords()
            return
        }
        
        // Получаем имя поля для текущей категории
        guard let fieldName = getFieldNameForCurrentGroup() else {
            print("⚠️ Не удалось получить имя поля для категории")
            loadAllRecords()
            return
        }
        
        guard let selectedValue = selectedGroupValue else {
            print("⚠️ selectedGroupValue = nil")
            loadAllRecords()
            return
        }
        
        print("🔍 Фильтруем по полю: \(fieldName), значение: '\(selectedValue)'")
        
        // Формируем запрос с фильтрацией по выбранному значению
        let query: String
        if selectedValue.isEmpty {
            // Пустое значение - фильтруем по NULL или пустой строке
            query = "SELECT * FROM nagrada WHERE (\(fieldName) IS NULL OR \(fieldName) = '') ORDER BY data_izm DESC LIMIT 50000"
            print("🔍 SQL запрос для пустого значения: \(query)")
        } else {
            // Непустое значение - обычная фильтрация
            let escapedValue = selectedValue.replacingOccurrences(of: "'", with: "''")
            query = "SELECT * FROM nagrada WHERE \(fieldName) = '\(escapedValue)' ORDER BY data_izm DESC LIMIT 50000"
            print("🔍 SQL запрос: \(query)")
        }
        
        // Загружаем отфильтрованные данные из базы данных
        if let results = DatabaseManager.shared.executeQuery(query) {
            filteredNagradaList = results.compactMap { Nagrada(from: $0) }
            let displayValue = selectedValue.isEmpty ? "(пустое)" : selectedValue
            print("✅ Загружено \(filteredNagradaList.count) записей с фильтром \(fieldName) = '\(displayValue)'")
            
            // Проверяем, что данные действительно отфильтрованы правильно
            if !filteredNagradaList.isEmpty {
                let first = filteredNagradaList[0]
                let firstValue = getFieldValue(from: first, fieldName: fieldName)
                print("🔍 Первая запись в отфильтрованном списке имеет значение поля \(fieldName) = '\(firstValue)'")
            }
        } else {
            filteredNagradaList = []
            print("❌ Ошибка загрузки данных с фильтром")
        }
        
        grid?.reloadData()
    }
    
    func getFieldValue(from nagrada: Nagrada, fieldName: String) -> String {
        switch fieldName {
        case "komp": return nagrada.komp ?? ""
        case "chast": return nagrada.chast ?? ""
        case "podrazdel1": return nagrada.podrazdel1 ?? ""
        case "podrazdel2": return nagrada.podrazdel2 ?? ""
        case "chin": return nagrada.chin ?? ""
        case "dolzhnost": return nagrada.dolzhnost ?? ""
        case "prikaz": return nagrada.prikaz ?? ""
        case "nomer_prik": return nagrada.nomer_prik ?? ""
        default: return ""
        }
    }
    
    func getFieldNameForCurrentGroup() -> String? {
        let selectedIndex = comboGroup?.indexOfSelectedItem ?? 0
        if selectedIndex == 0 {
            return nil // "Все записи"
        }
        let selectedGroupName = getSelectedGroupName()
        return getFieldName(for: selectedGroupName)
    }
    
    func getFieldName(for groupName: String) -> String {
        switch groupName {
        case "Кампания": return "komp"
        case "Часть": return "chast"
        case "Подразделение 1": return "podrazdel1"
        case "Подразделение 2": return "podrazdel2"
        case "Чин": return "chin"
        case "Должность": return "dolzhnost"
        case "Приказ": return "prikaz"
        case "Номер приказа": return "nomer_prik"
        default: return "id"
        }
    }
    
    func getNagradaTypeDisplay(_ nagrada: Nagrada) -> String {
        // В VB.NET: если nagrada = 0, то "крест", иначе "медаль"
        if let nagradaType = nagrada.nagrada {
            return nagradaType == 0 ? "крест" : "медаль"
        }
        return "-"
    }
    
    @objc @IBAction func buttonAddClicked(_ sender: Any) {
        openAwardDetail(isNew: true)
    }
    
    @objc @IBAction func buttonOpenNagradaFormClicked(_ sender: Any) {
        let selectedRow = grid?.selectedRow ?? -1
        if selectedRow >= 0 && selectedRow < filteredNagradaList.count {
            openAwardDetail(isNew: false, nagrada: filteredNagradaList[selectedRow])
        }
    }
    
    func openAwardDetail(isNew: Bool, nagrada: Nagrada? = nil) {
        // Create window programmatically if storyboard doesn't have it
        let windowController = AwardDetailWindowController()
        awardDetailWindowController = windowController
        windowController.isNew = isNew
        if let nagrada = nagrada {
            windowController.nagrada = nagrada
        }
        windowController.showWindow(nil)
    }
    
    @objc @IBAction func buttonSetOperatorNameClicked(_ sender: Any) {
        let name = textOperatorName?.stringValue ?? ""
        if name.isEmpty {
            showAlert(message: "Введите новое имя оператора")
            return
        }
        
        DatabaseManager.shared.setUserName(name)
        window?.title = "Рабочее место оператора: \(name)"
        showAlert(message: "Имя оператора изменено")
    }
    
    @objc @IBAction func buttonChangeDrugieIstClicked(_ sender: Any) {
        guard let grid = grid else { return }
        
        if filteredNagradaList.isEmpty {
            showAlert(message: "Таблица пуста")
            return
        }
        
        let selectedIndexes = grid.selectedRowIndexes
        if selectedIndexes.isEmpty {
            showAlert(message: "Выберите строки для изменения")
            return
        }
        
        // Собираем уникальные ID выбранных записей
        var idsToChange: Set<String> = []
        for index in selectedIndexes {
            if index >= 0 && index < filteredNagradaList.count {
                idsToChange.insert(filteredNagradaList[index].id)
            }
        }
        
        if idsToChange.isEmpty {
            showAlert(message: "Не удалось определить выбранные записи")
            return
        }
        
        let count = idsToChange.count
        let alert = NSAlert()
        alert.messageText = "Подтверждение"
        alert.informativeText = "Вы собираетесь изменить следующее количество карточек: \(count). Продолжить?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Да")
        alert.addButton(withTitle: "Нет")
        
        let response = alert.runModal()
        if response != .alertFirstButtonReturn {
            return
        }
        
        // Получаем значение из поля ввода и экранируем его для SQL
        let newValue = textDrugieIst?.stringValue ?? ""
        let escapedValue = newValue.replacingOccurrences(of: "'", with: "''")
        
        // Обновляем каждую выбранную запись
        var updatedCount = 0
        for id in idsToChange {
            let escapedId = id.replacingOccurrences(of: "'", with: "''")
            let query = "UPDATE nagrada SET drugie_ist = '\(escapedValue)' WHERE id = '\(escapedId)'"
            if DatabaseManager.shared.executeUpdate(query) {
                updatedCount += 1
            }
        }
        
        if updatedCount > 0 {
            // Обновляем данные в таблице
            // Сначала обновляем nagradaList
            loadNagradaList()
            
            // Затем обновляем filteredNagradaList в зависимости от текущего фильтра
            if let selectedValue = selectedGroupValue {
                // Если есть активный фильтр, применяем его снова
                filterTableByGroup()
            } else {
                // Если фильтра нет, просто обновляем filteredNagradaList из nagradaList
                filteredNagradaList = nagradaList
            }
            
            grid.reloadData()
            showAlert(message: "Готово. Обновлено записей: \(updatedCount)")
        } else {
            showAlert(message: "Ошибка при обновлении записей")
        }
    }
    
    @objc @IBAction func buttonMakeClicked(_ sender: Any) {
        let checkRules = checkRules?.state == .on
        let checkOpredeleniya = checkOpredeleniya?.state == .on
        
        WordExporter.exportToWord(
            checkRules: checkRules,
            checkOpredeleniya: checkOpredeleniya
        ) { [weak self] status, progress in
            DispatchQueue.main.async {
                self?.labelStatus?.stringValue = status
                self?.progressBar?.doubleValue = progress
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }
}

extension MainWindowController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == listGroup {
            return groupListItems.count
        } else if tableView == grid {
            return filteredNagradaList.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Обработка listGroup (список групп)
        if tableView == listGroup {
            guard row < groupListItems.count else { return nil }
            
            let cellIdentifier = tableColumn?.identifier ?? NSUserInterfaceItemIdentifier("Group")
            var cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            
            if cell == nil {
                cell = NSTableCellView()
                cell?.identifier = cellIdentifier
                
                let textField = NSTextField()
                textField.isEditable = false
                textField.isBordered = false
                textField.backgroundColor = .clear
                textField.font = NSFont.systemFont(ofSize: 13)
                textField.lineBreakMode = .byWordWrapping
                textField.maximumNumberOfLines = 0 // Неограниченное количество строк
                textField.preferredMaxLayoutWidth = 200 // Ширина для переноса текста
                cell?.textField = textField
                cell?.addSubview(textField)
                textField.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cell!.leadingAnchor, constant: 6),
                    textField.trailingAnchor.constraint(equalTo: cell!.trailingAnchor, constant: -6),
                    textField.topAnchor.constraint(equalTo: cell!.topAnchor, constant: 4),
                    textField.bottomAnchor.constraint(equalTo: cell!.bottomAnchor, constant: -4)
                ])
            }
            
            cell?.textField?.stringValue = groupListItems[row]
            return cell
        }
        
        // Обработка grid (основная таблица)
        if tableView == grid {
            guard let column = tableColumn, row < filteredNagradaList.count else { return nil }
            
            let nagrada = filteredNagradaList[row]
            let cellIdentifier = column.identifier.rawValue
            
            var cell = tableView.makeView(withIdentifier: column.identifier, owner: self) as? NSTableCellView
            
            if cell == nil {
                cell = NSTableCellView()
                cell?.identifier = column.identifier
                
                let textField = NSTextField()
                textField.isEditable = false
                textField.isBordered = false
                textField.backgroundColor = .clear
                textField.font = NSFont.systemFont(ofSize: 13)
                textField.lineBreakMode = .byTruncatingTail
                cell?.textField = textField
                cell?.addSubview(textField)
                textField.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cell!.leadingAnchor, constant: 6),
                    textField.trailingAnchor.constraint(equalTo: cell!.trailingAnchor, constant: -6),
                    textField.topAnchor.constraint(equalTo: cell!.topAnchor, constant: 4),
                    textField.bottomAnchor.constraint(equalTo: cell!.bottomAnchor, constant: -4)
                ])
            }
            
            switch cellIdentifier {
            case "Type":
                // В VB.NET: GetNagradaTypeShort(r) возвращает короткое название типа награды (ГК, ГМ, и т.д.)
                cell?.textField?.stringValue = nagrada.getNagradaTypeShort()
            case "Stepen":
                // Степень награды
                if let stepen = nagrada.stepen {
                    cell?.textField?.stringValue = String(stepen)
                } else {
                    cell?.textField?.stringValue = ""
                }
            case "Nomer":
                // Номер награды
                if let nomer = nagrada.nomer {
                    cell?.textField?.stringValue = String(nomer)
                } else {
                    cell?.textField?.stringValue = ""
                }
            case "FIO":
                cell?.textField?.stringValue = nagrada.getFullName()
            case "Dolzhnost":
                // Должность
                cell?.textField?.stringValue = nagrada.dolzhnost ?? ""
            case "Chin":
                cell?.textField?.stringValue = nagrada.chin ?? ""
            case "Chast":
                cell?.textField?.stringValue = nagrada.chast ?? ""
            case "Podrazdel":
                cell?.textField?.stringValue = nagrada.podrazdel1 ?? ""
            case "DataSozd":
                cell?.textField?.stringValue = nagrada.data_sozd ?? ""
            case "DataIzm":
                cell?.textField?.stringValue = nagrada.data_izm ?? ""
            case "DrugieIst":
                cell?.textField?.stringValue = nagrada.drugie_ist ?? ""
            case "ID":
                cell?.textField?.stringValue = nagrada.id
            default:
                cell?.textField?.stringValue = ""
            }
            return cell
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if tableView == grid {
            // Фиксированная высота для основной таблицы
            return 28.0
        } else if tableView == listGroup {
            // Автоматическая высота для списка групп на основе содержимого
            guard row < groupListItems.count else {
                return tableView.rowHeight
            }
            
            let text = groupListItems[row]
            let font = NSFont.systemFont(ofSize: 13)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            
            // Вычисляем размер текста с учетом ширины колонки
            let maxWidth: CGFloat = 200 // Ширина колонки минус отступы
            let textRect = attributedString.boundingRect(
                with: NSSize(width: maxWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading]
            )
            
            // Высота = высота текста + отступы сверху и снизу
            let height = textRect.height + 8 // 4px сверху + 4px снизу
            return max(height, 20.0) // Минимум 20px
        }
        return tableView.rowHeight
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }
        
        if tableView == listGroup {
            let selectedRow = tableView.selectedRow
            print("🔍 Выбрана строка в listGroup: \(selectedRow)")
            
            if selectedRow >= 0 && selectedRow < groupListItems.count {
                let selectedItem = groupListItems[selectedRow]
                print("🔍 Выбранный элемент: \(selectedItem)")
                
                if selectedItem == "Все" {
                    // Если выбрано "Все", показываем все записи
                    selectedGroupValue = nil
                    print("✅ Выбрано 'Все', загружаем все записи")
                    loadAllRecords()
                } else {
                    // Извлекаем значение из формата "значение (количество)" или "(количество)"
                    let actualValue: String
                    if selectedItem.hasPrefix("(") && selectedItem.hasSuffix(")") {
                        // Формат "(количество)" - это пустое значение
                        actualValue = ""
                        print("✅ Извлечено пустое значение из '\(selectedItem)'")
                    } else {
                        // Формат "значение (количество)" - извлекаем значение до скобки
                        if let range = selectedItem.range(of: " (") {
                            actualValue = String(selectedItem[..<range.lowerBound])
                            print("✅ Извлечено значение '\(actualValue)' из '\(selectedItem)'")
                        } else {
                            actualValue = selectedItem
                            print("✅ Используется значение как есть: '\(actualValue)'")
                        }
                    }
                    
                    selectedGroupValue = actualValue
                    print("🔍 Установлено selectedGroupValue = '\(actualValue)'")
                    filterTableByGroup()
                }
            }
        }
    }
}

