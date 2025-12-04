//
//  AppDelegate.swift
//  NagradaList
//
//  Created by MACbook on 01.12.2025.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Initialize database connection
        print("🚀 Инициализация DatabaseManager...")
        let dbManager = DatabaseManager.shared
        print("✅ DatabaseManager инициализирован, база открыта: \(dbManager.isDatabaseOpen())")
        
        // Close any windows opened by storyboard immediately
        for window in NSApplication.shared.windows {
            window.close()
        }
        
        // Create main window programmatically
        createMainWindowProgrammatically()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            createMainWindowProgrammatically()
        }
        return true
    }
    
    func createMainWindowProgrammatically() {
        // Don't create if already exists
        if let existingWindow = mainWindowController?.window, existingWindow.isVisible {
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }
        
        print("Creating main window programmatically...")
        
        let windowController = MainWindowController()
        mainWindowController = windowController
        
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Рабочее место оператора: \(DatabaseManager.shared.getUserName())"
        window.center()
        window.setFrameAutosaveName("MainWindow")
        window.isReleasedWhenClosed = false
        
        // Create content view with proper frame
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        // Create tab view
        let tabView = NSTabView(frame: contentView.bounds)
        tabView.autoresizingMask = [.width, .height]
        tabView.tabViewType = .topTabsBezelBorder
        
        // Create tabs
        createTabs(in: tabView, windowController: windowController)
        
        contentView.addSubview(tabView)
        window.contentView = contentView
        windowController.window = window
        
        // Setup window controller
        windowController.setupUI()
        windowController.loadInitialData()
        
        print("Window created, showing...")
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print("Window should be visible now. Window count: \(NSApplication.shared.windows.count)")
    }
    
    func createTabs(in tabView: NSTabView, windowController: MainWindowController) {
        // Tab 1: Table View (первая вкладка)
        let tab2 = NSTabViewItem(identifier: "Table")
        tab2.label = "Проверка в таблице"
        let view2 = createTableView(windowController: windowController)
        tab2.view = view2
        tabView.addTabViewItem(tab2)
        
        // Tab 2: Number Conditions
        let tab4 = NSTabViewItem(identifier: "NumberConditions")
        tab4.label = "Условия на номера"
        let view4 = createNumberConditionsView(windowController: windowController)
        tab4.view = view4
        tabView.addTabViewItem(tab4)
        
        // Tab 3: Group Replacement
        let tab5 = NSTabViewItem(identifier: "GroupReplacement")
        tab5.label = "Групповая замена"
        let view5 = createGroupReplacementView(windowController: windowController)
        tab5.view = view5
        tabView.addTabViewItem(tab5)
        
        // Tab 4: Unload
        let tab6 = NSTabViewItem(identifier: "Unload")
        tab6.label = "Сдача папки"
        let view6 = createUnloadView(windowController: windowController)
        tab6.view = view6
        tabView.addTabViewItem(tab6)
        
        // Tab 5: Service
        let tab7 = NSTabViewItem(identifier: "Service")
        tab7.label = "Служебная"
        let view7 = createServiceView(windowController: windowController)
        tab7.view = view7
        tabView.addTabViewItem(tab7)
        
        // Store tabView reference
        windowController.tabView = tabView
    }
    
    func createTableView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        
        // Buttons at top
        let buttonOpenBase = NSButton(title: "Открыть", target: windowController, action: #selector(MainWindowController.buttonOpenBaseClicked(_:)))
        buttonOpenBase.frame = NSRect(x: 20, y: 650, width: 100, height: 30)
        windowController.buttonOpenBase = buttonOpenBase
        view.addSubview(buttonOpenBase)
        
        let buttonAdd = NSButton(title: "Добавить", target: windowController, action: #selector(MainWindowController.buttonAddClicked(_:)))
        buttonAdd.frame = NSRect(x: 130, y: 650, width: 100, height: 30)
        windowController.buttonAdd = buttonAdd
        view.addSubview(buttonAdd)
        
        let buttonOpenNagradaForm = NSButton(title: "Подробно", target: windowController, action: #selector(MainWindowController.buttonOpenNagradaFormClicked(_:)))
        buttonOpenNagradaForm.frame = NSRect(x: 240, y: 650, width: 100, height: 30)
        windowController.buttonOpenNagradaForm = buttonOpenNagradaForm
        view.addSubview(buttonOpenNagradaForm)
        
        // Group box for filtering
        let groupBox2 = NSBox(frame: NSRect(x: 20, y: 50, width: 250, height: 600))
        groupBox2.title = "Группировка"
        groupBox2.boxType = .primary
        view.addSubview(groupBox2)
        
        // Выпадающий список для группировки - размещаем ниже заголовка NSBox
        let comboGroup = NSComboBox(frame: NSRect(x: 10, y: 535, width: 230, height: 25))
        comboGroup.target = windowController
        comboGroup.action = #selector(MainWindowController.comboGroupChanged(_:))
        comboGroup.delegate = windowController  // Устанавливаем делегат для отслеживания изменений
        windowController.comboGroup = comboGroup
        groupBox2.addSubview(comboGroup)
        
        // Список значений - размещаем ниже выпадающего списка
        let scrollView = NSScrollView(frame: NSRect(x: 10, y: 10, width: 230, height: 520))
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .bezelBorder
        
        let listGroup = NSTableView(frame: scrollView.bounds)
        listGroup.headerView = nil
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Group"))
        column.width = 210
        listGroup.addTableColumn(column)
        
        // Настройка для автоматической высоты строк
        listGroup.usesAutomaticRowHeights = true
        listGroup.rowHeight = 20.0 // Минимальная высота
        listGroup.intercellSpacing = NSSize(width: 4, height: 4)
        
        listGroup.delegate = windowController
        listGroup.dataSource = windowController
        
        scrollView.documentView = listGroup
        windowController.listGroup = listGroup
        groupBox2.addSubview(scrollView)
        
        // Group box for table
        let groupBox3 = NSBox(frame: NSRect(x: 280, y: 50, width: 700, height: 600))
        groupBox3.title = "Таблица"
        groupBox3.boxType = .primary
        view.addSubview(groupBox3)
        
        // Контейнер для элементов управления над таблицей
        // Размещаем ниже заголовка NSBox (который занимает ~25-30px сверху)
        let controlsContainer = NSView(frame: NSRect(x: 10, y: 525, width: 680, height: 50))
        groupBox3.addSubview(controlsContainer)
        
        // Метка "Изменить др. источн.:" - улучшенное оформление
        let labelDrugieIst = NSTextField(labelWithString: "Изменить др. источн.:")
        labelDrugieIst.frame = NSRect(x: 0, y: 28, width: 140, height: 20)
        labelDrugieIst.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        labelDrugieIst.textColor = .labelColor
        labelDrugieIst.alignment = .right
        controlsContainer.addSubview(labelDrugieIst)
        
        // Поле ввода для "др. источн." - улучшенное оформление
        let textDrugieIst = NSTextField(frame: NSRect(x: 150, y: 26, width: 280, height: 24))
        textDrugieIst.placeholderString = "Введите значение"
        textDrugieIst.font = NSFont.systemFont(ofSize: 13)
        textDrugieIst.isBordered = true
        textDrugieIst.bezelStyle = .roundedBezel
        textDrugieIst.focusRingType = .exterior
        windowController.textDrugieIst = textDrugieIst
        controlsContainer.addSubview(textDrugieIst)
        
        // Кнопка "Изменить" - улучшенное оформление
        let buttonChangeDrugieIst = NSButton(title: "Изменить", target: windowController, action: #selector(MainWindowController.buttonChangeDrugieIstClicked(_:)))
        buttonChangeDrugieIst.frame = NSRect(x: 440, y: 26, width: 100, height: 24)
        buttonChangeDrugieIst.bezelStyle = .rounded
        buttonChangeDrugieIst.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        windowController.buttonChangeDrugieIst = buttonChangeDrugieIst
        controlsContainer.addSubview(buttonChangeDrugieIst)
        
        // Поле поиска - улучшенное оформление
        let labelSearch = NSTextField(labelWithString: "Поиск:")
        labelSearch.frame = NSRect(x: 0, y: 2, width: 50, height: 20)
        labelSearch.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        labelSearch.textColor = .labelColor
        labelSearch.alignment = .right
        controlsContainer.addSubview(labelSearch)
        
        let textSearch = NSTextField(frame: NSRect(x: 60, y: 0, width: 220, height: 24))
        textSearch.placeholderString = "Найти в таблице"
        textSearch.font = NSFont.systemFont(ofSize: 13)
        textSearch.isBordered = true
        textSearch.bezelStyle = .roundedBezel
        textSearch.focusRingType = .exterior
        textSearch.target = windowController
        textSearch.action = #selector(MainWindowController.textSearchEnterPressed(_:))
        windowController.textSearch = textSearch
        controlsContainer.addSubview(textSearch)
        
        // Таблица - размещаем ниже элементов управления
        // Высота: 600 (общая) - 30 (заголовок) - 50 (элементы управления) - 10 (отступ снизу) = 510
        let scrollView2 = NSScrollView(frame: NSRect(x: 10, y: 10, width: 680, height: 510))
        scrollView2.hasVerticalScroller = true
        scrollView2.hasHorizontalScroller = true
        scrollView2.borderType = .bezelBorder
        
        let grid = DoubleClickTableView(frame: scrollView2.bounds)
        grid.mainController = windowController
        setupGridColumns(grid: grid)
        
        // Настройка внешнего вида таблицы
        grid.gridStyleMask = [.solidHorizontalGridLineMask, .solidVerticalGridLineMask]
        grid.intercellSpacing = NSSize(width: 1, height: 4)
        grid.rowHeight = 24.0
        grid.usesAlternatingRowBackgroundColors = true
        
        // Настройка границ
        grid.gridColor = NSColor.separatorColor
        grid.backgroundColor = NSColor.controlBackgroundColor
        
        grid.delegate = windowController
        grid.dataSource = windowController
        grid.doubleAction = #selector(MainWindowController.gridDoubleClicked(_:))
        grid.target = windowController
        
        scrollView2.documentView = grid
        windowController.grid = grid
        groupBox3.addSubview(scrollView2)
        
        return view
    }
    
    func setupGridColumns(grid: NSTableView) {
        let columns = [
            ("Type", "Тип", 65),
            ("Stepen", "Ст", 40),
            ("Nomer", "Номер", 75),
            ("FIO", "ФИО", 200),
            ("Dolzhnost", "Должность", 120),
            ("Chin", "Чин", 100),
            ("Chast", "Часть", 120),
            ("Podrazdel", "Подразделение", 150),
            ("DataSozd", "Дата создания", 130),
            ("DataIzm", "Дата изм.", 100),
            ("DrugieIst", "Другие ист.", 150),
            ("ID", "id", 0)
        ]
        
        for (identifier, title, width) in columns {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(identifier))
            column.title = title
            column.width = CGFloat(width)
            if identifier == "ID" {
                column.isHidden = true
            }
            grid.addTableColumn(column)
        }
    }
    
    func createNumberConditionsView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        
        // Кнопки управления - размещаем вверху с отступами
        let buttonFill = NSButton(title: "Заполнить", target: windowController, action: #selector(MainWindowController.buttonLoadNomerCondClicked(_:)))
        buttonFill.frame = NSRect(x: 20, y: 650, width: 120, height: 30)
        buttonFill.bezelStyle = .rounded
        windowController.buttonLoadNomerCond = buttonFill
        view.addSubview(buttonFill)
        
        let buttonSave = NSButton(title: "Сохранить", target: windowController, action: #selector(MainWindowController.buttonSaveNomerCondClicked(_:)))
        buttonSave.frame = NSRect(x: 150, y: 650, width: 120, height: 30)
        buttonSave.bezelStyle = .rounded
        windowController.buttonSaveNomerCond = buttonSave
        view.addSubview(buttonSave)
        
        // Кнопка для добавления новой строки
        let buttonAddRow = NSButton(title: "Добавить строку", target: windowController, action: #selector(MainWindowController.buttonAddNomerCondRowClicked(_:)))
        buttonAddRow.frame = NSRect(x: 280, y: 650, width: 130, height: 30)
        buttonAddRow.bezelStyle = .rounded
        view.addSubview(buttonAddRow)
        
        // Кнопка для удаления выбранной строки
        let buttonDeleteRow = NSButton(title: "Удалить строку", target: windowController, action: #selector(MainWindowController.buttonDeleteNomerCondRowClicked(_:)))
        buttonDeleteRow.frame = NSRect(x: 420, y: 650, width: 130, height: 30)
        buttonDeleteRow.bezelStyle = .rounded
        view.addSubview(buttonDeleteRow)
        
        // Group box для таблицы условий - размещаем ниже кнопок с достаточным отступом
        // Кнопки на y=650, высота 30, значит занимают от y=650 до y=680
        // GroupBox размещаем ниже, начиная с y=100, чтобы был достаточный отступ от кнопок
        // Высота view = 700, кнопки занимают 650-680, значит для groupBox остается 0-640
        // Размещаем groupBox на y=100, высота 540, значит занимает 100-640 - идеально
        let groupBox = NSBox(frame: NSRect(x: 20, y: 100, width: 520, height: 540))
        groupBox.title = "Условия на номера"
        groupBox.boxType = .primary
        groupBox.contentViewMargins = NSSize(width: 10, height: 10) // Отступы внутри box
        view.addSubview(groupBox)
        
        // Таблица условий - ширина = сумма ширин трех колонок (200 + 150 + 150 = 500)
        // Размещаем внутри groupBox с учетом заголовка (~25-30px) и отступов (10px сверху и снизу)
        // GroupBox высота 540, заголовок ~30px, отступы 10px сверху и снизу = 20px
        // Значит для таблицы остается: 540 - 30 - 20 = 490px по высоте
        let scrollView = NSScrollView(frame: NSRect(x: 10, y: 10, width: 500, height: 490))
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false // Отключаем горизонтальный скролл, так как ширина фиксирована
        scrollView.borderType = .bezelBorder
        scrollView.autohidesScrollers = true
        
        let grid = NSTableView(frame: scrollView.bounds)
        grid.gridStyleMask = [.solidHorizontalGridLineMask, .solidVerticalGridLineMask]
        grid.intercellSpacing = NSSize(width: 1, height: 4)
        grid.rowHeight = 24.0
        grid.usesAlternatingRowBackgroundColors = true
        grid.allowsColumnReordering = false
        grid.allowsColumnResizing = true
        grid.selectionHighlightStyle = .regular
        grid.allowsEmptySelection = true
        grid.allowsMultipleSelection = false
        // Настройка для редактирования ячеек как в DataGridView
        grid.doubleAction = #selector(MainWindowController.gridNomerConditionsDoubleClicked(_:))
        grid.target = windowController
        
        // Колонки таблицы
        let columns = [
            ("Type", "Тип", 200),
            ("Stepen", "Степень", 150),
            ("MaxNomer", "Макс. номер", 150)
        ]
        
        for (identifier, title, width) in columns {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(identifier))
            column.title = title
            column.width = CGFloat(width)
            column.minWidth = CGFloat(width)
            column.maxWidth = CGFloat(width) // Фиксируем ширину колонок
            column.resizingMask = [] // Запрещаем изменение размера (пустой массив опций)
            column.isEditable = true
            grid.addTableColumn(column)
        }
        
        // Устанавливаем фиксированную ширину таблицы (сумма ширин колонок)
        grid.columnAutoresizingStyle = .noColumnAutoresizing // Отключаем автоматическое изменение размера
        
        grid.delegate = windowController
        grid.dataSource = windowController
        
        scrollView.documentView = grid
        windowController.gridNomerConditions = grid
        groupBox.addSubview(scrollView)
        
        return view
    }
    
    func createGroupReplacementView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        
        // ========== ЛЕВАЯ ВЕРХНЯЯ ЧАСТЬ: ПОИСК ==========
        // GroupBox для поиска - слева вверху, элементы один под другим
        let searchGroupBox = NSBox(frame: NSRect(x: 20, y: 450, width: 460, height: 230))
        searchGroupBox.title = "Поиск наград"
        searchGroupBox.boxType = .primary
        searchGroupBox.contentViewMargins = NSSize(width: 15, height: -10) // Очень большие отступы сверху для заголовка
        view.addSubview(searchGroupBox)
        
        // Поле для поиска (сверху, с учетом отступа от заголовка)
        let labelPole = NSTextField(labelWithString: "Поле:")
        labelPole.frame = NSRect(x: 15, y: 185, width: 100, height: 20)
        labelPole.alignment = .right
        searchGroupBox.addSubview(labelPole)
        
        let comboPole = NSComboBox(frame: NSRect(x: 125, y: 183, width: 310, height: 24))
        comboPole.addItems(withObjectValues: [
            "Нет", "Отличие", "Приказ", "Номер приказа", "Дата приказа",
            "Часть", "Подразделение 1", "Подразделение 2", "Архив", "Фонд",
            "Опись", "Дело", "Др. источники", "Чин", "Должность",
            "Оператор (создание)", "Кампания", "Лист", "Комментарий",
            "Губерния", "Уезд", "Деревня", "Служебные отметки",
            "Отношение", "Номер отношения", "Дата отношения"
        ])
        comboPole.selectItem(at: 0)
        windowController.comboPole = comboPole
        searchGroupBox.addSubview(comboPole)
        
        // Тип сравнения (под полем)
        let labelSravnenie = NSTextField(labelWithString: "Тип сравнения:")
        labelSravnenie.frame = NSRect(x: 15, y: 150, width: 100, height: 20)
        labelSravnenie.alignment = .right
        searchGroupBox.addSubview(labelSravnenie)
        
        let comboSravnenieType = NSComboBox(frame: NSRect(x: 125, y: 148, width: 310, height: 24))
        comboSravnenieType.addItems(withObjectValues: ["Равно", "Включает"])
        comboSravnenieType.selectItem(at: 0)
        windowController.comboSravnenieType = comboSravnenieType
        searchGroupBox.addSubview(comboSravnenieType)
        
        // Значение для поиска (под типом сравнения)
        let labelZnachenie = NSTextField(labelWithString: "Значение:")
        labelZnachenie.frame = NSRect(x: 15, y: 115, width: 100, height: 20)
        labelZnachenie.alignment = .right
        searchGroupBox.addSubview(labelZnachenie)
        
        let scrollViewZnachenie = NSScrollView(frame: NSRect(x: 125, y: 55, width: 310, height: 55))
        scrollViewZnachenie.hasVerticalScroller = true
        scrollViewZnachenie.borderType = .bezelBorder
        scrollViewZnachenie.autohidesScrollers = true
        
        let textZnachenie = NSTextView(frame: scrollViewZnachenie.bounds)
        textZnachenie.isEditable = true
        textZnachenie.isSelectable = true
        textZnachenie.font = NSFont.systemFont(ofSize: 12)
        scrollViewZnachenie.documentView = textZnachenie
        windowController.textZnachenie = textZnachenie
        searchGroupBox.addSubview(scrollViewZnachenie)
        
        // Чекбокс "Учитывать регистр" и кнопка "Заполнить список" (внизу, ниже поля "Значение")
        let checkBoxUchitivatRegistr = NSButton(checkboxWithTitle: "Учитывать регистр", target: nil, action: nil)
        checkBoxUchitivatRegistr.frame = NSRect(x: 125, y: 20, width: 180, height: 20)
        checkBoxUchitivatRegistr.state = .off
        windowController.checkBoxUchitivatRegistr = checkBoxUchitivatRegistr
        searchGroupBox.addSubview(checkBoxUchitivatRegistr)
        
        let buttonFillList = NSButton(title: "Заполнить список", target: windowController, action: #selector(MainWindowController.buttonFillListClicked(_:)))
        buttonFillList.frame = NSRect(x: 315, y: 18, width: 120, height: 30)
        buttonFillList.bezelStyle = .rounded
        windowController.buttonFillList = buttonFillList
        searchGroupBox.addSubview(buttonFillList)
        
        // ========== ЛЕВАЯ НИЖНЯЯ ЧАСТЬ: ИЗМЕНЕНИЯ ==========
        // GroupBox для изменений - слева внизу
        let changeGroupBox = NSBox(frame: NSRect(x: 20, y: 20, width: 460, height: 420))
        changeGroupBox.title = "Изменения"
        changeGroupBox.boxType = .primary
        changeGroupBox.contentViewMargins = NSSize(width: 15, height: -30) // Очень большие отступы сверху для заголовка
        view.addSubview(changeGroupBox)
        
        // Тип изменения (сверху, с учетом отступа от заголовка)
        let labelChangeType = NSTextField(labelWithString: "Тип изменения:")
        labelChangeType.frame = NSRect(x: 15, y: 380, width: 100, height: 20)
        labelChangeType.alignment = .right
        changeGroupBox.addSubview(labelChangeType)
        
        let comboChangeType = NSComboBox(frame: NSRect(x: 125, y: 378, width: 310, height: 24))
        comboChangeType.addItems(withObjectValues: [
            "Нет", "Установить текст", "Замена части текста",
            "Добавление текста", "Очистить поле"
        ])
        comboChangeType.selectItem(at: 0)
        windowController.comboChangeType = comboChangeType
        changeGroupBox.addSubview(comboChangeType)
        
        // Поле для изменения (под типом изменения)
        let labelFieldToChange = NSTextField(labelWithString: "Поле:")
        labelFieldToChange.frame = NSRect(x: 15, y: 345, width: 100, height: 20)
        labelFieldToChange.alignment = .right
        changeGroupBox.addSubview(labelFieldToChange)
        
        let comboFieldToChange = NSComboBox(frame: NSRect(x: 125, y: 343, width: 310, height: 24))
        comboFieldToChange.addItems(withObjectValues: [
            "Нет", "Отличие", "Приказ", "Номер приказа", "Дата приказа",
            "Часть", "Подразделение 1", "Подразделение 2", "Архив", "Фонд",
            "Опись", "Дело", "Др. источники", "Чин", "Должность",
            "Оператор (создание)", "Кампания", "Лист", "Комментарий",
            "Губерния", "Уезд", "Деревня", "Служебные отметки",
            "Отношение", "Номер отношения", "Дата отношения"
        ])
        comboFieldToChange.selectItem(at: 0)
        windowController.comboFieldToChange = comboFieldToChange
        changeGroupBox.addSubview(comboFieldToChange)
        
        // Текст изменения 1 (под полем)
        let labelChange1 = NSTextField(labelWithString: "Текст 1:")
        labelChange1.frame = NSRect(x: 15, y: 310, width: 100, height: 20)
        labelChange1.alignment = .right
        changeGroupBox.addSubview(labelChange1)
        
        let scrollViewChange1 = NSScrollView(frame: NSRect(x: 125, y: 210, width: 310, height: 90))
        scrollViewChange1.hasVerticalScroller = true
        scrollViewChange1.borderType = .bezelBorder
        scrollViewChange1.autohidesScrollers = true
        
        let textChange1 = NSTextView(frame: scrollViewChange1.bounds)
        textChange1.isEditable = true
        textChange1.isSelectable = true
        textChange1.font = NSFont.systemFont(ofSize: 12)
        scrollViewChange1.documentView = textChange1
        windowController.textChange1 = textChange1
        changeGroupBox.addSubview(scrollViewChange1)
        
        // Текст изменения 2 (под текстом 1)
        let labelChange2 = NSTextField(labelWithString: "Текст 2:")
        labelChange2.frame = NSRect(x: 15, y: 185, width: 100, height: 20)
        labelChange2.alignment = .right
        changeGroupBox.addSubview(labelChange2)
        
        let scrollViewChange2 = NSScrollView(frame: NSRect(x: 125, y: 90, width: 310, height: 90))
        scrollViewChange2.hasVerticalScroller = true
        scrollViewChange2.borderType = .bezelBorder
        scrollViewChange2.autohidesScrollers = true
        
        let textChange2 = NSTextView(frame: scrollViewChange2.bounds)
        textChange2.isEditable = true
        textChange2.isSelectable = true
        textChange2.font = NSFont.systemFont(ofSize: 12)
        scrollViewChange2.documentView = textChange2
        windowController.textChange2 = textChange2
        changeGroupBox.addSubview(scrollViewChange2)
        
        // Кнопка "Выполнить изменения" (внизу)
        let buttonMakeChanges = NSButton(title: "Выполнить изменения", target: windowController, action: #selector(MainWindowController.buttonMakeChangesClicked(_:)))
        buttonMakeChanges.frame = NSRect(x: 125, y: 50, width: 310, height: 35)
        buttonMakeChanges.bezelStyle = .rounded
        windowController.buttonMakeChanges = buttonMakeChanges
        changeGroupBox.addSubview(buttonMakeChanges)
        
        // ========== ПРАВАЯ ЧАСТЬ: СПИСОК НАГРАД ==========
        // GroupBox для списка найденных наград - справа, занимает большую часть экрана по вертикали
        let listGroupBox = NSBox(frame: NSRect(x: 500, y: 20, width: 480, height: 660))
        listGroupBox.title = "Найденные награды"
        listGroupBox.boxType = .primary
        listGroupBox.contentViewMargins = NSSize(width: 15, height: -30) // Очень большие отступы сверху для заголовка
        view.addSubview(listGroupBox)
        
        // Таблица с найденными наградами (начинается ниже заголовка)
        let scrollViewList = NSScrollView(frame: NSRect(x: 15, y: 50, width: 450, height: 600))
        scrollViewList.hasVerticalScroller = true
        scrollViewList.hasHorizontalScroller = false
        scrollViewList.borderType = .bezelBorder
        scrollViewList.autohidesScrollers = true
        
        let listSelectedMedals = NSTableView(frame: scrollViewList.bounds)
        listSelectedMedals.gridStyleMask = [.solidHorizontalGridLineMask]
        listSelectedMedals.intercellSpacing = NSSize(width: 1, height: 2)
        listSelectedMedals.rowHeight = 22.0
        listSelectedMedals.usesAlternatingRowBackgroundColors = true
        listSelectedMedals.allowsColumnReordering = false
        listSelectedMedals.allowsColumnResizing = false
        listSelectedMedals.selectionHighlightStyle = .regular
        listSelectedMedals.allowsEmptySelection = true
        listSelectedMedals.allowsMultipleSelection = false
        
        // Колонка с чекбоксом
        let columnCheck = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Check"))
        columnCheck.title = ""
        columnCheck.width = 30
        columnCheck.minWidth = 30
        columnCheck.maxWidth = 30
        columnCheck.resizingMask = []
        listSelectedMedals.addTableColumn(columnCheck)
        
        // Колонка с информацией о награде
        let columnInfo = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Info"))
        columnInfo.title = "Награда"
        columnInfo.width = 410
        columnInfo.minWidth = 410
        columnInfo.maxWidth = 410
        columnInfo.resizingMask = []
        listSelectedMedals.addTableColumn(columnInfo)
        
        listSelectedMedals.delegate = windowController
        listSelectedMedals.dataSource = windowController
        scrollViewList.documentView = listSelectedMedals
        windowController.listSelectedMedals = listSelectedMedals
        listGroupBox.addSubview(scrollViewList)
        
        // Кнопки управления выбором
        let buttonSelectAll = NSButton(title: "Выбрать все", target: windowController, action: #selector(MainWindowController.buttonSelectAllClicked(_:)))
        buttonSelectAll.frame = NSRect(x: 15, y: 10, width: 100, height: 30)
        buttonSelectAll.bezelStyle = .rounded
        windowController.buttonSelectAll = buttonSelectAll
        listGroupBox.addSubview(buttonSelectAll)
        
        let buttonUnselectAll = NSButton(title: "Снять выбор", target: windowController, action: #selector(MainWindowController.buttonUnselectAllClicked(_:)))
        buttonUnselectAll.frame = NSRect(x: 125, y: 10, width: 100, height: 30)
        buttonUnselectAll.bezelStyle = .rounded
        windowController.buttonUnselectAll = buttonUnselectAll
        listGroupBox.addSubview(buttonUnselectAll)
        
        let buttonOpenMedal = NSButton(title: "Открыть награду", target: windowController, action: #selector(MainWindowController.buttonOpenMedalClicked(_:)))
        buttonOpenMedal.frame = NSRect(x: 235, y: 10, width: 120, height: 30)
        buttonOpenMedal.bezelStyle = .rounded
        windowController.buttonOpenMedal = buttonOpenMedal
        listGroupBox.addSubview(buttonOpenMedal)
        
        return view
    }
    
    func createUnloadView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        
        // ========== ЛЕВАЯ ЧАСТЬ: ПРОВЕРКА СТАТУСА ==========
        // GroupBox для проверки статуса
        let statusGroupBox = NSBox(frame: NSRect(x: 20, y: 450, width: 460, height: 230))
        statusGroupBox.title = "Проверка статуса"
        statusGroupBox.boxType = .primary
        statusGroupBox.contentViewMargins = NSSize(width: 15, height: -10)
        view.addSubview(statusGroupBox)
        
        // Текстовое поле для статуса проверки
        let labelCheckStatus = NSTextField(labelWithString: "Статус проверки:")
        labelCheckStatus.frame = NSRect(x: 15, y: 185, width: 120, height: 20)
        labelCheckStatus.alignment = .right
        statusGroupBox.addSubview(labelCheckStatus)
        
        let textCheckStatus = NSTextField(frame: NSRect(x: 145, y: 183, width: 290, height: 24))
        textCheckStatus.isEditable = false
        textCheckStatus.isBordered = true
        textCheckStatus.backgroundColor = .textBackgroundColor
        textCheckStatus.stringValue = ""
        windowController.textCheckStatus = textCheckStatus
        statusGroupBox.addSubview(textCheckStatus)
        
        // Кнопки "Завершено" и "Не завершено"
        let buttonEnded = NSButton(title: "Завершено", target: windowController, action: #selector(MainWindowController.buttonEndedClicked(_:)))
        buttonEnded.frame = NSRect(x: 145, y: 140, width: 140, height: 35)
        buttonEnded.bezelStyle = .rounded
        windowController.buttonEnded = buttonEnded
        statusGroupBox.addSubview(buttonEnded)
        
        let buttonNotEnded = NSButton(title: "Не завершено", target: windowController, action: #selector(MainWindowController.buttonNotEndedClicked(_:)))
        buttonNotEnded.frame = NSRect(x: 295, y: 140, width: 140, height: 35)
        buttonNotEnded.bezelStyle = .rounded
        windowController.buttonNotEnded = buttonNotEnded
        statusGroupBox.addSubview(buttonNotEnded)
        
        // ========== ПРАВАЯ ЧАСТЬ: СТАТИСТИКА И ВЫГРУЗКА ==========
        // GroupBox для статистики и выгрузки
        let unloadGroupBox = NSBox(frame: NSRect(x: 500, y: 450, width: 480, height: 230))
        unloadGroupBox.title = "Статистика и выгрузка"
        unloadGroupBox.boxType = .primary
        unloadGroupBox.contentViewMargins = NSSize(width: 15, height: -10)
        view.addSubview(unloadGroupBox)
        
        // Текстовое поле для статистики выгрузки
        let labelUnloadStat = NSTextField(labelWithString: "Статистика:")
        labelUnloadStat.frame = NSRect(x: 15, y: 185, width: 100, height: 20)
        labelUnloadStat.alignment = .right
        unloadGroupBox.addSubview(labelUnloadStat)
        
        let scrollViewUnloadStat = NSScrollView(frame: NSRect(x: 125, y: 50, width: 340, height: 140))
        scrollViewUnloadStat.hasVerticalScroller = true
        scrollViewUnloadStat.borderType = .bezelBorder
        scrollViewUnloadStat.autohidesScrollers = true
        
        let textUnloadStat = NSTextView(frame: scrollViewUnloadStat.bounds)
        textUnloadStat.isEditable = false
        textUnloadStat.isSelectable = true
        textUnloadStat.font = NSFont.systemFont(ofSize: 12)
        textUnloadStat.string = ""
        scrollViewUnloadStat.documentView = textUnloadStat
        windowController.textUnloadStat = textUnloadStat
        unloadGroupBox.addSubview(scrollViewUnloadStat)
        
        // Кнопка "Выгрузить данные"
        let buttonUnloadData = NSButton(title: "Выгрузить данные", target: windowController, action: #selector(MainWindowController.buttonUnloadDataClicked(_:)))
        buttonUnloadData.frame = NSRect(x: 125, y: 10, width: 340, height: 35)
        buttonUnloadData.bezelStyle = .rounded
        windowController.buttonUnloadData = buttonUnloadData
        unloadGroupBox.addSubview(buttonUnloadData)
        
        // ========== НИЖНЯЯ ЧАСТЬ: ЛОГ ВЫГРУЗКИ ==========
        // GroupBox для лога выгрузки
        let logGroupBox = NSBox(frame: NSRect(x: 20, y: 20, width: 960, height: 420))
        logGroupBox.title = "Лог выгрузки"
        logGroupBox.boxType = .primary
        logGroupBox.contentViewMargins = NSSize(width: 15, height: -30)
        view.addSubview(logGroupBox)
        
        // Текстовое поле для лога выгрузки
        let scrollViewUnloadLog = NSScrollView(frame: NSRect(x: 15, y: 50, width: 930, height: 360))
        scrollViewUnloadLog.hasVerticalScroller = true
        scrollViewUnloadLog.hasHorizontalScroller = true
        scrollViewUnloadLog.borderType = .bezelBorder
        scrollViewUnloadLog.autohidesScrollers = true
        
        let textUnloadLog = NSTextView(frame: scrollViewUnloadLog.bounds)
        textUnloadLog.isEditable = false
        textUnloadLog.isSelectable = true
        textUnloadLog.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        textUnloadLog.string = ""
        scrollViewUnloadLog.documentView = textUnloadLog
        windowController.textUnloadLog = textUnloadLog
        logGroupBox.addSubview(scrollViewUnloadLog)
        
        return view
    }
    
    func createServiceView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        
        // ========== ГРУППА: НАСТРОЙКИ ОПЕРАТОРА ==========
        // GroupBox для настроек оператора
        let operatorGroupBox = NSBox(frame: NSRect(x: 20, y: 500, width: 960, height: 180))
        operatorGroupBox.title = "Настройки оператора"
        operatorGroupBox.boxType = .primary
        operatorGroupBox.contentViewMargins = NSSize(width: 15, height: -10)
        view.addSubview(operatorGroupBox)
        
        // Метка для поля имени оператора
        let labelOperatorName = NSTextField(labelWithString: "Имя оператора:")
        labelOperatorName.frame = NSRect(x: 15, y: 135, width: 120, height: 20)
        labelOperatorName.alignment = .right
        operatorGroupBox.addSubview(labelOperatorName)
        
        // Текстовое поле для ввода имени оператора
        let textOperatorName = NSTextField(frame: NSRect(x: 145, y: 133, width: 400, height: 24))
        textOperatorName.isEditable = true
        textOperatorName.isBordered = true
        textOperatorName.backgroundColor = .textBackgroundColor
        textOperatorName.stringValue = DatabaseManager.shared.getUserName()
        textOperatorName.placeholderString = "Введите имя оператора"
        windowController.textOperatorName = textOperatorName
        operatorGroupBox.addSubview(textOperatorName)
        
        // Кнопка "Установить имя оператора"
        let buttonSetOperatorName = NSButton(title: "Установить имя оператора", target: windowController, action: #selector(MainWindowController.buttonSetOperatorNameClicked(_:)))
        buttonSetOperatorName.frame = NSRect(x: 560, y: 130, width: 200, height: 35)
        buttonSetOperatorName.bezelStyle = .rounded
        windowController.buttonSetOperatorName = buttonSetOperatorName
        operatorGroupBox.addSubview(buttonSetOperatorName)
        
        // Информационный текст
        let infoText = NSTextField(wrappingLabelWithString: "Имя оператора используется для отметки создателя и редактора записей в базе данных.")
        infoText.frame = NSRect(x: 145, y: 80, width: 800, height: 40)
        infoText.font = NSFont.systemFont(ofSize: 11)
        infoText.textColor = .secondaryLabelColor
        operatorGroupBox.addSubview(infoText)
        
        // Текущее имя оператора (только для отображения)
        let currentNameLabel = NSTextField(labelWithString: "Текущее имя оператора:")
        currentNameLabel.frame = NSRect(x: 15, y: 50, width: 150, height: 20)
        currentNameLabel.alignment = .right
        operatorGroupBox.addSubview(currentNameLabel)
        
        let currentNameValue = NSTextField(labelWithString: DatabaseManager.shared.getUserName())
        currentNameValue.frame = NSRect(x: 175, y: 48, width: 300, height: 24)
        currentNameValue.font = NSFont.boldSystemFont(ofSize: 13)
        currentNameValue.textColor = .systemBlue
        windowController.textCurrentOperatorName = currentNameValue
        operatorGroupBox.addSubview(currentNameValue)
        
        // ========== ГРУППА: ПУТЬ К БАЗЕ ДАННЫХ ==========
        // GroupBox для пути к базе данных
        let dbPathGroupBox = NSBox(frame: NSRect(x: 20, y: 420, width: 960, height: 60))
        dbPathGroupBox.title = "Путь к базе данных"
        dbPathGroupBox.boxType = .primary
        dbPathGroupBox.contentViewMargins = NSSize(width: 15, height: -10)
        view.addSubview(dbPathGroupBox)
        
        // Метка для пути к базе данных
        let labelDbPath = NSTextField(labelWithString: "Путь к базе данных:")
        labelDbPath.frame = NSRect(x: 15, y: 25, width: 120, height: 20)
        labelDbPath.alignment = .right
        dbPathGroupBox.addSubview(labelDbPath)
        
        let textDbPath = NSTextField(frame: NSRect(x: 145, y: 23, width: 650, height: 24))
        textDbPath.isEditable = false
        textDbPath.isBordered = true
        textDbPath.backgroundColor = .textBackgroundColor
        textDbPath.stringValue = DatabaseManager.shared.getDatabasePath()
        textDbPath.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        textDbPath.textColor = .labelColor
        windowController.textDbPath = textDbPath
        dbPathGroupBox.addSubview(textDbPath)
        
        // Кнопка "Изменить путь"
        let buttonChangeDbPath = NSButton(title: "Изменить путь", target: windowController, action: #selector(MainWindowController.buttonChangeDbPathClicked(_:)))
        buttonChangeDbPath.frame = NSRect(x: 805, y: 20, width: 140, height: 30)
        buttonChangeDbPath.bezelStyle = .rounded
        windowController.buttonChangeDbPath = buttonChangeDbPath
        dbPathGroupBox.addSubview(buttonChangeDbPath)
        
        // ========== ГРУППА: ОБЯЗАТЕЛЬНЫЕ ПОЛЯ ==========
        // GroupBox для обязательных полей
        let requiredFieldsGroupBox = NSBox(frame: NSRect(x: 20, y: 20, width: 960, height: 380))
        requiredFieldsGroupBox.title = "Обязательные поля"
        requiredFieldsGroupBox.boxType = .primary
        requiredFieldsGroupBox.contentViewMargins = NSSize(width: 15, height: -10)
        view.addSubview(requiredFieldsGroupBox)
        
        // ScrollView для чекбоксов обязательных полей
        // Увеличиваем отступ сверху, чтобы заголовок не перекрывал чекбоксы
        let scrollViewRequiredFields = NSScrollView(frame: NSRect(x: 15, y: 50, width: 930, height: 320))
        scrollViewRequiredFields.hasVerticalScroller = true
        scrollViewRequiredFields.borderType = .bezelBorder
        scrollViewRequiredFields.autohidesScrollers = true
        
        // Создаем чекбоксы для каждого обязательного поля
        let requiredFields = NagradaConstants.requiredFields
        let columns = 3
        let checkboxWidth: CGFloat = 280
        let checkboxHeight: CGFloat = 20
        let spacingX: CGFloat = 20
        let spacingY: CGFloat = 5
        let startX: CGFloat = 10
        let startY: CGFloat = 10
        
        // Рассчитываем количество строк
        let totalRows = (requiredFields.count + columns - 1) / columns
        let containerHeight = max(CGFloat(totalRows) * (checkboxHeight + spacingY) + startY * 2, 100)
        
        // Контейнер для чекбоксов (координаты в macOS идут снизу вверх)
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 900, height: containerHeight))
        
        var requiredFieldsCheckboxes: [NSButton] = []
        
        for (index, fieldName) in requiredFields.enumerated() {
            let column = index % columns
            let row = index / columns
            
            // Координаты: x - горизонтально, y - снизу вверх
            // Первая строка должна быть вверху контейнера
            let x = startX + CGFloat(column) * (checkboxWidth + spacingX)
            // Вычисляем y от верха контейнера (containerHeight - y от верха)
            let yFromTop = startY + CGFloat(row) * (checkboxHeight + spacingY)
            let y = containerHeight - yFromTop - checkboxHeight
            
            let checkbox = NSButton(checkboxWithTitle: fieldName, target: nil, action: nil)
            checkbox.frame = NSRect(x: x, y: y, width: checkboxWidth, height: checkboxHeight)
            checkbox.state = .on // По умолчанию все поля обязательные
            requiredFieldsCheckboxes.append(checkbox)
            containerView.addSubview(checkbox)
        }
        
        // Устанавливаем размер контейнера
        containerView.frame = NSRect(x: 0, y: 0, width: 900, height: containerHeight)
        
        scrollViewRequiredFields.documentView = containerView
        windowController.requiredFieldsCheckboxes = requiredFieldsCheckboxes
        requiredFieldsGroupBox.addSubview(scrollViewRequiredFields)
        
        // Кнопки управления
        let buttonSaveRequiredFields = NSButton(title: "Сохранить", target: windowController, action: #selector(MainWindowController.buttonSaveRequiredFieldsClicked(_:)))
        buttonSaveRequiredFields.frame = NSRect(x: 15, y: 10, width: 120, height: 30)
        buttonSaveRequiredFields.bezelStyle = .rounded
        windowController.buttonSaveRequiredFields = buttonSaveRequiredFields
        requiredFieldsGroupBox.addSubview(buttonSaveRequiredFields)
        
        let buttonLoadRequiredFields = NSButton(title: "Загрузить", target: windowController, action: #selector(MainWindowController.buttonLoadRequiredFieldsClicked(_:)))
        buttonLoadRequiredFields.frame = NSRect(x: 145, y: 10, width: 120, height: 30)
        buttonLoadRequiredFields.bezelStyle = .rounded
        windowController.buttonLoadRequiredFields = buttonLoadRequiredFields
        requiredFieldsGroupBox.addSubview(buttonLoadRequiredFields)
        
        let buttonSelectAllRequiredFields = NSButton(title: "Выбрать все", target: windowController, action: #selector(MainWindowController.buttonSelectAllRequiredFieldsClicked(_:)))
        buttonSelectAllRequiredFields.frame = NSRect(x: 275, y: 10, width: 120, height: 30)
        buttonSelectAllRequiredFields.bezelStyle = .rounded
        windowController.buttonSelectAllRequiredFields = buttonSelectAllRequiredFields
        requiredFieldsGroupBox.addSubview(buttonSelectAllRequiredFields)
        
        let buttonDeselectAllRequiredFields = NSButton(title: "Снять все", target: windowController, action: #selector(MainWindowController.buttonDeselectAllRequiredFieldsClicked(_:)))
        buttonDeselectAllRequiredFields.frame = NSRect(x: 405, y: 10, width: 120, height: 30)
        buttonDeselectAllRequiredFields.bezelStyle = .rounded
        windowController.buttonDeselectAllRequiredFields = buttonDeselectAllRequiredFields
        requiredFieldsGroupBox.addSubview(buttonDeselectAllRequiredFields)
        
        return view
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}

