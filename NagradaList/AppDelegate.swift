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
        // Basic implementation
        return view
    }
    
    func createUnloadView(windowController: MainWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 700))
        // Basic implementation
        return view
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}

