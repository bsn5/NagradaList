//
//  MainWindowController.swift
//  NagradaList
//
//  Created by Auto on 01.12.2025.
//

import Cocoa

class MainWindowController: NSWindowController, NSComboBoxDelegate {
    
    var tabView: NSTabView?
    
    // Tab 1: Table View
    @IBOutlet weak var buttonOpenBase: NSButton!
    @IBOutlet weak var comboGroup: NSComboBox!
    @IBOutlet weak var listGroup: NSTableView!
    @IBOutlet weak var grid: NSTableView!
    @IBOutlet weak var buttonAdd: NSButton!
    @IBOutlet weak var buttonOpenNagradaForm: NSButton!
    @IBOutlet weak var textSearch: NSTextField!
    @IBOutlet weak var textDrugieIst: NSTextField!
    @IBOutlet weak var buttonChangeDrugieIst: NSButton!
    
    // Tab 2: Number Conditions
    @IBOutlet weak var gridNomerConditions: NSTableView!
    @IBOutlet weak var buttonLoadNomerCond: NSButton!
    @IBOutlet weak var buttonSaveNomerCond: NSButton!
    
    // Tab 3: Group Replacement
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
    
    // Number conditions
    struct NumberCondition {
        var type: Int  // Тип награды (0 - крест, 1 - медаль)
        var stepen: Int  // Степень
        var maxNomer: Int  // Максимальный номер
    }
    var nomerConditions: [NumberCondition] = []
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        setupUI()
        loadInitialData()
    }
    
    func setupUI() {
        window?.title = "Рабочее место оператора: \(DatabaseManager.shared.getUserName())"
        
        // Setup combo boxes
        setupComboGroup()
        setupComboPole()
        setupComboFieldToChange()
        setupComboChangeType()
        setupComboSravnenieType()
        
        // Setup table view
        setupTableView()
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
        // Проверяем, не открыта ли уже карточка и не редактируется ли она (как в VB.NET: If f2.edited = True Then)
        if let existingController = awardDetailWindowController,
           let existingWindow = existingController.window,
           existingWindow.isVisible,
           existingController.edited {
            showAlert(message: "Карточка уже открыта и редактируется")
            return
        }
        
        // Создаем контроллер окна (как в VB.NET: f2 - это уже существующая форма)
        let windowController = AwardDetailWindowController()
        awardDetailWindowController = windowController
        windowController.isNew = true
        
        // Создаем окно программно, если его нет (как в openNagradaFromGrid)
        if windowController.window == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 680, height: 800),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Редактор наград"
            window.center()
            windowController.window = window
        }
        
        // Загружаем окно, чтобы UI элементы были созданы (как в VB.NET: форма уже существует)
        // loadWindow() должен вызвать windowDidLoad, который создаст содержимое
        print("📝 Загружаем окно...")
        windowController.loadWindow() // Это вызовет windowDidLoad и создаст все UI элементы
        
        // Убеждаемся, что содержимое окна создано (на случай, если windowDidLoad не вызвался или не создал содержимое)
        // Для программно созданных окон windowDidLoad может не вызваться автоматически
        if let contentView = windowController.window?.contentView {
            let subviewCount = contentView.subviews.count
            print("📝 Проверка содержимого после loadWindow: subviews.count = \(subviewCount)")
            if subviewCount == 0 {
                print("⚠️ Содержимое окна пустое, вызываем createWindowContent() напрямую")
                windowController.createWindowContent()
                windowController.fillCombos()
                windowController.setupNagradaCombo()
            } else {
                print("✅ Содержимое окна создано, subviews.count = \(subviewCount)")
            }
        } else {
            print("⚠️ contentView отсутствует, создаем его")
            windowController.createWindowContent()
            windowController.fillCombos()
            windowController.setupNagradaCombo()
        }
        
        // Дополнительная проверка: если windowDidLoad не вызвался, вызываем его вручную
        // Это гарантирует, что все инициализации выполнены
        if windowController.window?.contentView?.subviews.count ?? 0 == 0 {
            print("⚠️ windowDidLoad не создал содержимое, вызываем его вручную")
            windowController.windowDidLoad()
        }
        
        // Проверяем, есть ли записи в базе (как в VB.NET: If RecordCount("nagrada") = 0 Then)
        let recordCount = DatabaseManager.shared.executeQuery("SELECT COUNT(*) as count FROM nagrada")
        let count = (recordCount?.first?["count"] as? Int64) ?? 0
        
        if count == 0 {
            // База пуста - просто очищаем форму (как в VB.NET: f2.ClearForm())
            windowController.clearForm()
        } else {
            // База не пуста - спрашиваем, заполнить по последним данным? (как в VB.NET: MsgBox)
            let alert = NSAlert()
            alert.messageText = "Заполнить по последним данным?"
            alert.addButton(withTitle: "Да")
            alert.addButton(withTitle: "Нет")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                // Да - загружаем последнюю запись (как в VB.NET: ORDER BY data_sozd, MoveLast, FillForm(r, True))
                if let results = DatabaseManager.shared.executeQuery("SELECT * FROM nagrada ORDER BY data_sozd DESC LIMIT 1"),
                   let firstRow = results.first {
                    let lastNagrada = Nagrada(from: firstRow)
                    windowController.nagrada = lastNagrada
                    // Заполняем форму данными последней записи (copy = True, как в VB.NET: FillForm(r, True))
                    // UI элементы уже созданы в windowDidLoad, поэтому можем заполнять форму
                    print("✅ Заполняем форму данными последней записи (copy = true)")
                    windowController.fillForm(copy: true)
                } else {
                    print("⚠️ Не удалось загрузить последнюю запись")
                    windowController.clearForm()
                }
            } else {
                // Нет - просто очищаем форму (как в VB.NET: f2.ClearForm())
                print("✅ Очищаем форму (пользователь выбрал 'Нет')")
                windowController.clearForm()
            }
        }
        
        // Разблокируем форму для редактирования (как в VB.NET: f2.SetStatus(FormNagradaNew.enumNagradaStatus.enabled))
        windowController.setStatus(blocked: false)
        windowController.edited = false // Сбрасываем флаг редактирования, так как это новая запись
        
        // Показываем окно (как в VB.NET: f2.Show())
        print("✅ Показываем окно детальной формы")
        guard let window = windowController.window else {
            print("❌ Окно не создано!")
            return
        }
        
        windowController.showWindow(nil)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print("✅ Окно должно быть видимо. isVisible: \(window.isVisible), isKeyWindow: \(window.isKeyWindow)")
    }
    
    @objc @IBAction func buttonOpenNagradaFormClicked(_ sender: Any) {
        guard let grid = grid else {
            showAlert(message: "Таблица не загружена")
            return
        }
        
        let selectedRow = grid.selectedRow
        print("🔍 buttonOpenNagradaFormClicked: selectedRow = \(selectedRow), filteredNagradaList.count = \(filteredNagradaList.count)")
        
        // Проверяем, что строка выбрана
        guard selectedRow >= 0 && selectedRow < filteredNagradaList.count else {
            showAlert(message: "Выберите строку в таблице")
            return
        }
        
        // Получаем выбранную запись
        let selectedNagrada = filteredNagradaList[selectedRow]
        let recordId = selectedNagrada.id
        print("🔍 recordId = \(recordId)")
        
        // Проверяем, что ID валидный
        guard !recordId.isEmpty else {
            print("❌ ID пустой")
            showAlert(message: "Ошибка: ID записи пустой")
            return
        }
        
        // Открываем форму детальной информации (аналогично openNagradaFromGrid)
        openAwardDetail(isNew: false, nagrada: selectedNagrada)
    }
    
    func openAwardDetail(isNew: Bool, nagrada: Nagrada? = nil) {
        // Проверяем, не открыта ли уже карточка и не редактируется ли она
        if let existingController = awardDetailWindowController,
           let existingWindow = existingController.window,
           existingWindow.isVisible,
           existingController.edited {
            showAlert(message: "Карточка уже открыта и редактируется")
            return
        }
        
        // Если передан объект nagrada, загружаем актуальные данные из базы
        var nagradaToShow: Nagrada? = nagrada
        if let nagrada = nagrada {
            let escapedId = nagrada.id.replacingOccurrences(of: "'", with: "''")
            print("🔍 Загружаем данные из базы для id = \(escapedId)")
            
            if let results = DatabaseManager.shared.executeQuery("SELECT * FROM nagrada WHERE id = '\(escapedId)'"),
               let firstRow = results.first {
                // Создаем новый объект Nagrada из актуальных данных базы
                nagradaToShow = Nagrada(from: firstRow)
                print("✅ Данные загружены из базы")
            } else {
                print("⚠️ Не удалось загрузить данные из базы, используем переданный объект")
            }
        }
        
        guard let finalNagrada = nagradaToShow else {
            print("❌ nagrada is nil")
            showAlert(message: "Ошибка: не удалось загрузить данные записи")
            return
        }
        
        // Создаем новое окно (как в VB.NET: Dim f As New FormNagradaNew)
        let windowController = AwardDetailWindowController()
        
        // Создаем окно программно, если его нет
        if windowController.window == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 680, height: 800),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Редактор наград"
            window.center()
            windowController.window = window
        }
        
        awardDetailWindowController = windowController
        
        // Устанавливаем параметры (как в VB.NET: f.edited = False, f.its_new = False)
        windowController.isNew = isNew
        windowController.edited = false
        windowController.nagrada = finalNagrada
        
        print("✅ Окно создано, загружаем содержимое...")
        
        // Загружаем окно, чтобы вызвать windowDidLoad
        // Если окно создано программно, создаем содержимое
        if windowController.window?.contentView == nil || (windowController.window?.contentView?.subviews.isEmpty ?? true) {
            windowController.createWindowContent()
        }
        
        // Загружаем окно (вызовет windowDidLoad)
        windowController.loadWindow()
        
        // Убеждаемся, что fillCombos и fillForm вызываются после загрузки окна
        // Вызываем явно, если windowDidLoad еще не отработал
        DispatchQueue.main.async {
            windowController.fillCombos()
            windowController.setupNagradaCombo()
            windowController.fillForm(from: finalNagrada)
            windowController.setStatus(blocked: !isNew) // blocked = true для существующих записей
        }
        
        // Показываем окно (как в VB.NET: f.Show())
        windowController.showWindow(nil)
        windowController.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print("✅ Окно должно быть видимо")
    }
    
    @objc func textSearchEnterPressed(_ sender: NSTextField) {
        let searchText = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if searchText.isEmpty {
            return
        }
        
        guard let grid = grid else { return }
        
        if filteredNagradaList.isEmpty {
            showAlert(message: "Таблица пуста")
            return
        }
        
        // Начинаем поиск с текущей выбранной строки + 1, или с начала
        let startIndex = grid.selectedRow >= 0 ? grid.selectedRow + 1 : 0
        let searchTextUpper = searchText.uppercased()
        
        // Ищем в таблице (во всех колонках кроме последней - ID)
        let columnIdentifiers = ["Type", "Stepen", "Nomer", "FIO", "Dolzhnost", "Chin", "Chast", "Podrazdel", "DataSozd", "DataIzm", "DrugieIst"]
        
        // Поиск с текущей позиции до конца
        for i in startIndex..<filteredNagradaList.count {
            let nagrada = filteredNagradaList[i]
            for columnId in columnIdentifiers {
                let cellValue: String
                switch columnId {
                case "Type":
                    cellValue = nagrada.getNagradaTypeShort()
                case "Stepen":
                    cellValue = nagrada.stepen != nil ? String(nagrada.stepen!) : ""
                case "Nomer":
                    cellValue = nagrada.nomer != nil ? String(nagrada.nomer!) : ""
                case "FIO":
                    cellValue = nagrada.getFullName()
                case "Dolzhnost":
                    cellValue = nagrada.dolzhnost ?? ""
                case "Chin":
                    cellValue = nagrada.chin ?? ""
                case "Chast":
                    cellValue = nagrada.chast ?? ""
                case "Podrazdel":
                    cellValue = nagrada.podrazdel1 ?? ""
                case "DataSozd":
                    cellValue = nagrada.data_sozd ?? ""
                case "DataIzm":
                    cellValue = nagrada.data_izm ?? ""
                case "DrugieIst":
                    cellValue = nagrada.drugie_ist ?? ""
                default:
                    cellValue = ""
                }
                
                if cellValue.uppercased().contains(searchTextUpper) {
                    // Найдено - выделяем строку
                    grid.selectRowIndexes(IndexSet(integer: i), byExtendingSelection: false)
                    grid.scrollRowToVisible(i)
                    return
                }
            }
        }
        
        // Если не найдено до конца, ищем с начала до текущей позиции
        if startIndex > 0 {
            for i in 0..<startIndex {
                let nagrada = filteredNagradaList[i]
                for columnId in columnIdentifiers {
                    let cellValue: String
                    switch columnId {
                    case "Type":
                        cellValue = nagrada.getNagradaTypeShort()
                    case "Stepen":
                        cellValue = nagrada.stepen != nil ? String(nagrada.stepen!) : ""
                    case "Nomer":
                        cellValue = nagrada.nomer != nil ? String(nagrada.nomer!) : ""
                    case "FIO":
                        cellValue = nagrada.getFullName()
                    case "Dolzhnost":
                        cellValue = nagrada.dolzhnost ?? ""
                    case "Chin":
                        cellValue = nagrada.chin ?? ""
                    case "Chast":
                        cellValue = nagrada.chast ?? ""
                    case "Podrazdel":
                        cellValue = nagrada.podrazdel1 ?? ""
                    case "DataSozd":
                        cellValue = nagrada.data_sozd ?? ""
                    case "DataIzm":
                        cellValue = nagrada.data_izm ?? ""
                    case "DrugieIst":
                        cellValue = nagrada.drugie_ist ?? ""
                    default:
                        cellValue = ""
                    }
                    
                    if cellValue.uppercased().contains(searchTextUpper) {
                        // Найдено - выделяем строку
                        grid.selectRowIndexes(IndexSet(integer: i), byExtendingSelection: false)
                        grid.scrollRowToVisible(i)
                        return
                    }
                }
            }
        }
        
        // Ничего не найдено
        showAlert(message: "Ничего не найдено")
    }
    
    @objc func gridDoubleClicked(_ sender: NSTableView) {
        print("🖱️ gridDoubleClicked вызван")
        openNagradaFromGrid()
    }
    
    func openNagradaFromGrid() {
        guard let grid = grid else {
            print("❌ grid is nil")
            return
        }
        
        let selectedRow = grid.selectedRow
        print("🔍 selectedRow = \(selectedRow), filteredNagradaList.count = \(filteredNagradaList.count)")
        
        // Проверяем, что строка выбрана
        guard selectedRow >= 0 && selectedRow < filteredNagradaList.count else {
            print("❌ Строка не выбрана или индекс вне диапазона")
            return
        }
        
        // Получаем ID выбранной записи
        let selectedNagrada = filteredNagradaList[selectedRow]
        let recordId = selectedNagrada.id
        print("🔍 recordId = \(recordId)")
        
        // Проверяем, что ID валидный
        guard !recordId.isEmpty else {
            print("❌ ID пустой")
            return
        }
        
        // Загружаем данные из базы по ID (как в VB.NET: SELECT * FROM nagrada WHERE id = ...)
        let escapedId = recordId.replacingOccurrences(of: "'", with: "''")
        print("🔍 Загружаем данные из базы для id = \(escapedId)")
        
        if let results = DatabaseManager.shared.executeQuery("SELECT * FROM nagrada WHERE id = '\(escapedId)'"),
           let firstRow = results.first {
            print("✅ Данные загружены из базы")
            print("🔍 Первая строка из базы: \(firstRow)")
            
            // Создаем новый объект Nagrada из актуальных данных базы
            let nagrada = Nagrada(from: firstRow)
            print("🔍 Создан объект Nagrada: id=\(nagrada.id), фамилия=\(nagrada.фамилия ?? "nil"), имя=\(nagrada.имя ?? "nil"), komp=\(nagrada.komp ?? "nil")")
            
            // Создаем новое окно (как в VB.NET: Dim f As New FormNagradaNew)
            let windowController = AwardDetailWindowController()
            
            // Создаем окно программно, если его нет
            if windowController.window == nil {
                let window = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 680, height: 680),
                    styleMask: [.titled, .closable, .miniaturizable, .resizable],
                    backing: .buffered,
                    defer: false
                )
                window.title = "Редактор наград"
                window.center()
                windowController.window = window
            }
            
            awardDetailWindowController = windowController
            
            // Устанавливаем параметры (как в VB.NET: f.edited = False, f.its_new = False)
            windowController.isNew = false
            windowController.edited = false
            windowController.nagrada = nagrada
            
            print("✅ Окно создано, показываем...")
            
            // Загружаем окно, чтобы вызвать windowDidLoad
            // Если окно создано программно, создаем содержимое
            if windowController.window?.contentView == nil || (windowController.window?.contentView?.subviews.isEmpty ?? true) {
                windowController.createWindowContent()
            }
            
            // Загружаем окно (вызовет windowDidLoad)
            windowController.loadWindow()
            
            // Убеждаемся, что fillCombos и fillForm вызываются после загрузки окна
            // Вызываем явно, если windowDidLoad еще не отработал
            DispatchQueue.main.async {
                windowController.fillCombos()
                windowController.setupNagradaCombo()
                windowController.fillForm(from: nagrada)
                windowController.setStatus(blocked: true) // blocked = true для существующих записей
            }
            
            // Статус blocked будет установлен в windowDidLoad через setStatus(blocked: !isNew)
            // fillCombos будет вызван в windowDidLoad
            
            // Показываем окно (как в VB.NET: ef.Visible = True)
            windowController.showWindow(nil)
            windowController.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            print("❌ Не удалось загрузить данные из базы")
            showAlert(message: "Не удалось загрузить данные записи из базы")
        }
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
    
    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }
    
    // MARK: - Group Replacement Actions
    
    @objc @IBAction func buttonFillListClicked(_ sender: Any) {
        // Получаем параметры поиска
        let fieldIndex = comboPole?.indexOfSelectedItem ?? 0
        let fieldName: String?
        
        if fieldIndex == 0 {
            // "Нет" - ищем по всем записям
            fieldName = nil
        } else {
            fieldName = GroupReplacementManager.shared.getFieldName(for: comboPole?.stringValue ?? "")
        }
        
        let comparisonType = comboSravnenieType?.indexOfSelectedItem ?? 0
        let value = textZnachenie?.string ?? ""
        let caseSensitive = checkBoxUchitivatRegistr?.state == .on
        
        // Заполняем список найденных наград
        selectedMedals = GroupReplacementManager.shared.fillList(
            fieldName: fieldName,
            comparisonType: comparisonType,
            value: value,
            caseSensitive: caseSensitive
        )
        
        listSelectedMedals?.reloadData()
        showAlert(message: "Найдено наград: \(selectedMedals.count)")
    }
    
    @objc @IBAction func buttonSelectAllClicked(_ sender: Any) {
        for i in 0..<selectedMedals.count {
            selectedMedals[i].isSelected = true
        }
        listSelectedMedals?.reloadData()
    }
    
    @objc @IBAction func buttonUnselectAllClicked(_ sender: Any) {
        for i in 0..<selectedMedals.count {
            selectedMedals[i].isSelected = false
        }
        listSelectedMedals?.reloadData()
    }
    
    @objc func checkboxClicked(_ sender: NSButton) {
        let row = sender.tag
        guard row >= 0 && row < selectedMedals.count else { return }
        selectedMedals[row].isSelected = sender.state == .on
    }
    
    @objc @IBAction func buttonOpenMedalClicked(_ sender: Any) {
        let selectedRow = listSelectedMedals?.selectedRow ?? -1
        guard selectedRow >= 0 && selectedRow < selectedMedals.count else {
            showAlert(message: "Выберите награду для открытия")
            return
        }
        
        let medalId = selectedMedals[selectedRow].id
        openAwardDetailWindow(awardId: medalId)
    }
    
    func openAwardDetailWindow(awardId: String) {
        // Загружаем данные награды из базы по ID
        let escapedId = awardId.replacingOccurrences(of: "'", with: "''")
        
        guard let results = DatabaseManager.shared.executeQuery("SELECT * FROM nagrada WHERE id = '\(escapedId)'"),
              let firstRow = results.first else {
            showAlert(message: "Не удалось загрузить данные награды")
            return
        }
        
        // Создаем объект Nagrada из данных базы
        let nagrada = Nagrada(from: firstRow)
        
        // Открываем окно детальной информации
        openAwardDetail(isNew: false, nagrada: nagrada)
    }
    
    @objc @IBAction func buttonMakeChangesClicked(_ sender: Any) {
        // Получаем параметры изменения
        let changeTypeIndex = comboChangeType?.indexOfSelectedItem ?? 0
        guard changeTypeIndex > 0 else {
            showAlert(message: "Выберите тип изменения")
            return
        }
        
        let fieldIndex = comboFieldToChange?.indexOfSelectedItem ?? 0
        guard fieldIndex > 0 else {
            showAlert(message: "Выберите поле для изменения")
            return
        }
        
        let fieldName = GroupReplacementManager.shared.getFieldName(for: comboFieldToChange?.stringValue ?? "")
        let textChange1 = textChange1?.string ?? ""
        let textChange2 = textChange2?.string ?? ""
        
        // Проверяем, что есть выбранные награды
        let selectedCount = selectedMedals.filter { $0.isSelected }.count
        guard selectedCount > 0 else {
            showAlert(message: "Выберите хотя бы одну награду для изменения")
            return
        }
        
        // Выполняем изменения
        let success = GroupReplacementManager.shared.makeChanges(
            selectedMedals: selectedMedals,
            changeType: changeTypeIndex,
            fieldName: fieldName,
            textChange1: textChange1,
            textChange2: textChange2
        )
        
        if success {
            showAlert(message: "Изменения применены к \(selectedCount) наградам")
            // Обновляем данные в основной таблице
            loadNagradaList()
        } else {
            showAlert(message: "Ошибка при применении изменений")
        }
    }
    
    // MARK: - Number Conditions Actions
    
    @objc @IBAction func buttonLoadNomerCondClicked(_ sender: Any) {
        loadNomerConditions()
    }
    
    @objc @IBAction func buttonSaveNomerCondClicked(_ sender: Any) {
        saveNomerConditions()
    }
    
    @objc @IBAction func buttonAddNomerCondRowClicked(_ sender: Any) {
        // Добавляем новую пустую строку (как в DataGridView)
        // Всегда добавляем только одну строку, независимо от того, пуста таблица или нет
        guard let grid = gridNomerConditions else { return }
        
        // Сохраняем текущее количество строк
        let oldCount = nomerConditions.count
        
        // Добавляем только одну строку
        nomerConditions.append(NumberCondition(type: 0, stepen: 0, maxNomer: 0))
        
        // Проверяем, что добавилась только одна строка
        guard nomerConditions.count == oldCount + 1 else {
            // Если что-то пошло не так, откатываем изменения
            if nomerConditions.count > oldCount {
                nomerConditions.removeLast()
            }
            return
        }
        
        let newRowIndex = nomerConditions.count - 1
        
        // Обновляем таблицу
        grid.reloadData()
        
        // Выделяем новую строку после обновления
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Проверяем, что строка все еще существует
            if newRowIndex < self.nomerConditions.count {
                grid.selectRowIndexes(IndexSet(integer: newRowIndex), byExtendingSelection: false)
                grid.scrollRowToVisible(newRowIndex)
                // Устанавливаем фокус на первую ячейку новой строки и начинаем редактирование
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if newRowIndex < self.nomerConditions.count {
                        grid.editColumn(0, row: newRowIndex, with: nil, select: true)
                    }
                }
            }
        }
    }
    
    @objc @IBAction func buttonDeleteNomerCondRowClicked(_ sender: Any) {
        guard let grid = gridNomerConditions else { return }
        
        // Определяем строку для удаления
        var rowToDelete: Int = -1
        
        // Сначала проверяем выбранные строки
        let selectedIndexes = grid.selectedRowIndexes
        if !selectedIndexes.isEmpty {
            // Берем первую выбранную строку (или последнюю, если выбрано несколько)
            rowToDelete = selectedIndexes.first ?? -1
        } else {
            // Если ничего не выбрано, проверяем clickedRow
            rowToDelete = grid.clickedRow
        }
        
        // Проверяем, что строка валидна (включая последнюю строку)
        guard rowToDelete >= 0 && rowToDelete < nomerConditions.count else {
            showAlert(message: "Выберите строку для удаления")
            return
        }
        
        // Удаляем строку (включая последнюю)
        nomerConditions.remove(at: rowToDelete)
        
        // Обновляем таблицу
        grid.reloadData()
        
        // Выделяем следующую строку или предыдущую, если удалили последнюю
        if nomerConditions.count > 0 {
            // Если удалили не последнюю строку, выделяем ту же позицию
            // Если удалили последнюю, выделяем новую последнюю строку
            let newSelection = min(rowToDelete, nomerConditions.count - 1)
            DispatchQueue.main.async {
                grid.selectRowIndexes(IndexSet(integer: newSelection), byExtendingSelection: false)
                grid.scrollRowToVisible(newSelection)
            }
        } else {
            // Если таблица стала пустой, снимаем выделение
            grid.deselectAll(nil)
        }
    }
    
    @objc func gridNomerConditionsDoubleClicked(_ sender: NSTableView) {
        // При двойном клике начинаем редактирование ячейки (как в DataGridView)
        let clickedRow = sender.clickedRow
        let clickedColumn = sender.clickedColumn
        
        // Не добавляем строки автоматически - только через кнопку "Добавить строку"
        if clickedRow >= 0 && clickedColumn >= 0 && clickedRow < nomerConditions.count {
            // Начинаем редактирование ячейки
            DispatchQueue.main.async {
                sender.editColumn(clickedColumn, row: clickedRow, with: nil, select: true)
            }
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }
        
        if tableView == gridNomerConditions {
            // При выборе строки в таблице условий автоматически начинаем редактирование первой ячейки (как в DataGridView)
            let selectedRow = tableView.selectedRow
            if selectedRow >= 0 && selectedRow < nomerConditions.count {
                // Небольшая задержка для корректной работы
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if tableView.selectedRow == selectedRow {
                        tableView.editColumn(0, row: selectedRow, with: nil, select: true)
                    }
                }
            }
        } else if tableView == listGroup {
            // Обработка для listGroup (существующий код)
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
    
    func loadNomerConditions() {
        // Заполняем таблицу данными из базы
        // Структура таблицы: [id] TEXT NOT NULL, [nagrada] INTEGER, [stepen] INTEGER, [nomer] INTEGER
        // Сначала пытаемся загрузить из таблицы "Условия на номера"
        if let results = DatabaseManager.shared.executeQuery("SELECT * FROM \"Условия на номера\"") {
            nomerConditions = []
            for row in results {
                // Используем правильные названия колонок: nagrada (вместо type), nomer (вместо max_nomer)
                let type = (row["nagrada"] as? Int64).map { Int($0) } ?? 0
                let stepen = (row["stepen"] as? Int64).map { Int($0) } ?? 0
                let maxNomer = (row["nomer"] as? Int64).map { Int($0) } ?? 0
                
                // Добавляем только если есть хотя бы одно непустое значение
                if type > 0 || stepen > 0 || maxNomer > 0 {
                    nomerConditions.append(NumberCondition(
                        type: type,
                        stepen: stepen,
                        maxNomer: maxNomer
                    ))
                }
            }
            print("✅ Загружено \(nomerConditions.count) условий из таблицы 'Условия на номера'")
        } else {
            // Если таблица пуста или не существует, заполняем из основной таблицы nagrada
            if let results = DatabaseManager.shared.executeQuery("""
                SELECT nagrada, stepen, MAX(nomer) as max_nomer 
                FROM nagrada 
                WHERE nagrada IS NOT NULL AND stepen IS NOT NULL AND nomer IS NOT NULL 
                GROUP BY nagrada, stepen 
                ORDER BY nagrada, stepen
                """) {
                nomerConditions = []
                for row in results {
                    let type = (row["nagrada"] as? Int64).map { Int($0) } ?? 0
                    let stepen = (row["stepen"] as? Int64).map { Int($0) } ?? 0
                    let maxNomer = (row["max_nomer"] as? Int64).map { Int($0) } ?? 0
                    
                    nomerConditions.append(NumberCondition(
                        type: type,
                        stepen: stepen,
                        maxNomer: maxNomer
                    ))
                }
                print("✅ Заполнено \(nomerConditions.count) условий из таблицы nagrada")
            } else {
                nomerConditions = []
                print("⚠️ Не удалось загрузить данные из базы")
            }
        }
        
        // Обновляем таблицу
        gridNomerConditions?.reloadData()
        showAlert(message: "Заполнено условий: \(nomerConditions.count)")
    }
    
    func saveNomerConditions() {
        // Сохраняем в базу данных
        // Структура таблицы: [id] TEXT NOT NULL, [nagrada] INTEGER, [stepen] INTEGER, [nomer] INTEGER
        // Сначала удаляем все существующие записи
        _ = DatabaseManager.shared.executeUpdate("DELETE FROM \"Условия на номера\"")
        
        // Фильтруем пустые строки (где все значения равны 0)
        let validConditions = nomerConditions.filter { condition in
            condition.type > 0 || condition.stepen > 0 || condition.maxNomer > 0
        }
        
        guard !validConditions.isEmpty else {
            showAlert(message: "Нет данных для сохранения. Заполните хотя бы одну строку.")
            return
        }
        
        // Затем вставляем новые записи
        var savedCount = 0
        var errorMessages: [String] = []
        
        for (index, condition) in validConditions.enumerated() {
            // Генерируем уникальный id для каждой записи
            let id = "\(condition.type)_\(condition.stepen)_\(index)_\(UUID().uuidString.prefix(8))"
            
            // Используем правильные названия колонок: nagrada (вместо type), nomer (вместо max_nomer)
            // Экранируем id для безопасности
            let escapedId = id.replacingOccurrences(of: "'", with: "''")
            let query = """
            INSERT INTO "Условия на номера" (id, nagrada, stepen, nomer)
            VALUES ('\(escapedId)', \(condition.type), \(condition.stepen), \(condition.maxNomer))
            """
            
            if DatabaseManager.shared.executeUpdate(query) {
                savedCount += 1
            } else {
                errorMessages.append("Строка \(index + 1): тип=\(condition.type), степень=\(condition.stepen), номер=\(condition.maxNomer)")
            }
        }
        
        if savedCount == validConditions.count {
            showAlert(message: "Сохранено условий: \(savedCount)")
        } else {
            let errorMsg = errorMessages.isEmpty ? "" : "\nНе удалось сохранить:\n\(errorMessages.joined(separator: "\n"))"
            showAlert(message: "Ошибка: сохранено \(savedCount) из \(validConditions.count)\(errorMsg)")
        }
    }
}

extension MainWindowController: NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == listGroup {
            return groupListItems.count
        } else if tableView == grid {
            return filteredNagradaList.count
        } else if tableView == gridNomerConditions {
            // Показываем только реальные строки, без дополнительных пустых
            return nomerConditions.count
        } else if tableView == listSelectedMedals {
            return selectedMedals.count
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
        
        // Обработка listSelectedMedals (таблица найденных наград для групповой замены)
        if tableView == listSelectedMedals {
            guard let column = tableColumn, row < selectedMedals.count else { return nil }
            
            let medal = selectedMedals[row]
            let cellIdentifier = column.identifier.rawValue
            
            if cellIdentifier == "Check" {
                // Ячейка с чекбоксом
                var cell = tableView.makeView(withIdentifier: column.identifier, owner: self) as? NSView
                
                if cell == nil {
                    cell = NSView()
                    cell?.identifier = column.identifier
                    
                    let checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(checkboxClicked(_:)))
                    checkbox.frame = NSRect(x: 8, y: 2, width: 20, height: 20)
                    checkbox.tag = row
                    cell?.addSubview(checkbox)
                }
                
                // Обновляем состояние чекбокса
                if let checkbox = cell?.subviews.first as? NSButton {
                    checkbox.state = medal.isSelected ? .on : .off
                    checkbox.tag = row
                }
                
                return cell
            } else if cellIdentifier == "Info" {
                // Ячейка с информацией о награде
                var cell = tableView.makeView(withIdentifier: column.identifier, owner: self) as? NSTableCellView
                
                if cell == nil {
                    cell = NSTableCellView()
                    cell?.identifier = column.identifier
                    
                    let textField = NSTextField()
                    textField.isEditable = false
                    textField.isBordered = false
                    textField.backgroundColor = .clear
                    textField.font = NSFont.systemFont(ofSize: 12)
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
                
                cell?.textField?.stringValue = medal.displayText
                return cell
            }
        }
        
        // Обработка gridNomerConditions (таблица условий на номера) - DataGridView-подобная таблица
        if tableView == gridNomerConditions {
            // Не добавляем строки автоматически - только через кнопку "Добавить строку"
            guard let column = tableColumn, row < nomerConditions.count else { return nil }
            
            let condition = nomerConditions[row]
            let cellIdentifier = column.identifier.rawValue
            
            // Пытаемся переиспользовать существующую ячейку
            var cell = tableView.makeView(withIdentifier: column.identifier, owner: self) as? NSTableCellView
            
            if cell == nil {
                // Создаем новую ячейку с редактируемым полем
                cell = NSTableCellView()
                cell?.identifier = column.identifier
                
                let textField = NSTextField()
                textField.isEditable = true
                textField.isBordered = true
                textField.bezelStyle = .squareBezel
                textField.backgroundColor = .textBackgroundColor
                textField.font = NSFont.systemFont(ofSize: 13)
                textField.isSelectable = true
                textField.drawsBackground = true
                textField.focusRingType = .exterior
                textField.controlSize = .regular
                
                // Обработка изменений через делегат
                textField.delegate = self
                
                cell?.textField = textField
                cell?.addSubview(textField)
                textField.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cell!.leadingAnchor, constant: 4),
                    textField.trailingAnchor.constraint(equalTo: cell!.trailingAnchor, constant: -4),
                    textField.topAnchor.constraint(equalTo: cell!.topAnchor, constant: 2),
                    textField.bottomAnchor.constraint(equalTo: cell!.bottomAnchor, constant: -2)
                ])
            }
            
            // Убеждаемся, что textField редактируемый и настроен правильно
            cell?.textField?.isEditable = true
            cell?.textField?.delegate = self
            cell?.textField?.tag = row * 1000 + columnIndex(for: cellIdentifier)
            
            // Заполняем данными
            switch cellIdentifier {
            case "Type":
                // Тип награды: 0 - крест, 1 - медаль
                let typeNames = ["Крест", "Медаль"]
                let typeName = condition.type >= 0 && condition.type < typeNames.count ? typeNames[condition.type] : String(condition.type)
                cell?.textField?.stringValue = typeName
            case "Stepen":
                cell?.textField?.stringValue = condition.stepen > 0 ? String(condition.stepen) : ""
            case "MaxNomer":
                cell?.textField?.stringValue = condition.maxNomer > 0 ? String(condition.maxNomer) : ""
            default:
                cell?.textField?.stringValue = ""
            }
            
            return cell
        }
        
        return nil
    }
    
    func columnIndex(for identifier: String) -> Int {
        guard let grid = gridNomerConditions else { return 0 }
        for (index, column) in grid.tableColumns.enumerated() {
            if column.identifier.rawValue == identifier {
                return index
            }
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        // Обработка клика по колонке - не требуется для редактирования
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if tableView == grid {
            // Фиксированная высота для основной таблицы
            return 28.0
        } else if tableView == gridNomerConditions {
            // Фиксированная высота для таблицы условий
            return 24.0
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
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        // Разрешаем выбор строки для всех таблиц
        return true
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        // Возвращаем стандартный row view, но можем переопределить для обработки событий
        return nil
    }
    
    // MARK: - NSTableViewDelegate для редактирования
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        if tableView == gridNomerConditions {
            return true // Разрешаем редактирование всех ячеек
        }
        return false
    }
    
    // MARK: - NSTextFieldDelegate для обработки изменений
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField,
              let tableView = gridNomerConditions else {
            return
        }
        
        // Извлекаем строку и колонку из tag
        let tag = textField.tag
        let row = tag / 1000
        let colIndex = tag % 1000
        
        // Не добавляем строки автоматически - только через кнопку "Добавить строку"
        // Проверяем, что строка существует
        guard row >= 0 && row < nomerConditions.count,
              colIndex >= 0 && colIndex < tableView.tableColumns.count else {
            print("⚠️ Выход за пределы массива: row=\(row), count=\(nomerConditions.count), colIndex=\(colIndex)")
            return
        }
        
        let column = tableView.tableColumns[colIndex]
        let columnId = column.identifier.rawValue
        let newValue = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Обновляем данные в массиве
        switch columnId {
        case "Type":
            // Преобразуем название типа обратно в число
            let typeNames = ["Крест", "Медаль"]
            if let typeIndex = typeNames.firstIndex(of: newValue) {
                nomerConditions[row].type = typeIndex
                print("✅ Обновлено: строка \(row), колонка Type = \(typeIndex)")
            } else if let typeRaw = Int(newValue), typeRaw >= 0 && typeRaw <= 1 {
                nomerConditions[row].type = typeRaw
                print("✅ Обновлено: строка \(row), колонка Type = \(typeRaw)")
            } else {
                print("⚠️ Неверное значение Type: '\(newValue)'")
            }
        case "Stepen":
            if let newStepen = Int(newValue) {
                nomerConditions[row].stepen = newStepen
                print("✅ Обновлено: строка \(row), колонка Stepen = \(newStepen)")
            } else if newValue.isEmpty {
                nomerConditions[row].stepen = 0
                print("✅ Обновлено: строка \(row), колонка Stepen = 0 (пусто)")
            } else {
                print("⚠️ Неверное значение Stepen: '\(newValue)'")
            }
        case "MaxNomer":
            if let newMaxNomer = Int(newValue) {
                nomerConditions[row].maxNomer = newMaxNomer
                print("✅ Обновлено: строка \(row), колонка MaxNomer = \(newMaxNomer)")
            } else if newValue.isEmpty {
                nomerConditions[row].maxNomer = 0
                print("✅ Обновлено: строка \(row), колонка MaxNomer = 0 (пусто)")
            } else {
                print("⚠️ Неверное значение MaxNomer: '\(newValue)'")
            }
        default:
            print("⚠️ Неизвестная колонка: \(columnId)")
            break
        }
        
        // Автоматическое добавление новой строки при заполнении последней строки отключено
        // Пользователь должен использовать кнопку "Добавить строку"
    }
}

