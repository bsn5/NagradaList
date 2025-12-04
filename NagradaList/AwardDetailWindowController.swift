//
//  AwardDetailWindowController.swift
//  NagradaList
//
//  Created by Auto on 01.12.2025.
//

import Cocoa

class AwardDetailWindowController: NSWindowController, NSWindowDelegate, NSComboBoxDelegate {
    
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
    @IBOutlet weak var buttonEdit: NSButton!
    @IBOutlet weak var checkFormBlocked: NSButton!
    
    var nagrada: Nagrada?
    var isNew: Bool = false
    var edited: Bool = false
    private var noEvents: Bool = false
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        print("✅ windowDidLoad вызван")
        window?.delegate = self
        
        // Всегда создаем содержимое, если его нет (для программно созданных окон)
        // Проверяем, что contentView либо nil, либо пустой (нет subviews)
        let needsContent = window?.contentView == nil || (window?.contentView?.subviews.isEmpty ?? true)
        if needsContent {
            print("📝 windowDidLoad: создаем содержимое окна (subviews.count = \(window?.contentView?.subviews.count ?? 0))")
            createWindowContent()
        } else {
            print("📝 windowDidLoad: содержимое окна уже существует (subviews.count = \(window?.contentView?.subviews.count ?? 0))")
        }
        
        // Заполняем комбобоксы только если UI элементы созданы
        if !needsContent || window?.contentView?.subviews.count ?? 0 > 0 {
            fillCombos()
            setupNagradaCombo()
        }
        
        // Заполняем форму только если nagrada уже установлен (для редактирования существующей записи)
        // Для новой записи (isNew = true) форма будет заполнена позже в buttonAddClicked
        if let nagrada = nagrada, !isNew {
            fillForm(from: nagrada)
        } else if !isNew {
            // Если это не новая запись, но nagrada не установлен, очищаем форму
            clearForm()
        }
        // Если isNew = true, форма будет заполнена позже в buttonAddClicked
        
        setStatus(blocked: !isNew)
    }
    
    func createWindowContent() {
        guard let window = window else { return }
        
        // Создаем основной контейнер с увеличенной высотой для лучшего размещения
        // Увеличиваем высоту окна, чтобы все элементы поместились (кнопки на y=10, служебные отметки на y=750-770=негативно, нужно больше места)
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 680, height: 800))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        // Координаты в macOS идут снизу вверх, в VB.NET - сверху вниз
        // Нужно конвертировать координаты: macOS_y = window_height - VB_y - element_height
        
        let windowHeight: CGFloat = 800
        
        // ФИО (вверху)
        let labelF = NSTextField(labelWithString: "Фамилия:")
        labelF.frame = NSRect(x: 10, y: windowHeight - 30, width: 70, height: 17)
        contentView.addSubview(labelF)
        
        let textFField = NSTextField(frame: NSRect(x: 85, y: windowHeight - 30, width: 150, height: 22))
        textFField.font = NSFont.systemFont(ofSize: 13)
        textFField.target = self
        textFField.action = #selector(textFieldChanged(_:))
        textF = textFField
        contentView.addSubview(textFField)
        
        let labelI = NSTextField(labelWithString: "Имя:")
        labelI.frame = NSRect(x: 245, y: windowHeight - 30, width: 40, height: 17)
        contentView.addSubview(labelI)
        
        let textIField = NSTextField(frame: NSRect(x: 290, y: windowHeight - 30, width: 150, height: 22))
        textIField.font = NSFont.systemFont(ofSize: 13)
        textIField.target = self
        textIField.action = #selector(textFieldChanged(_:))
        textI = textIField
        contentView.addSubview(textIField)
        
        let labelO = NSTextField(labelWithString: "Отчество:")
        labelO.frame = NSRect(x: 450, y: windowHeight - 30, width: 70, height: 17)
        contentView.addSubview(labelO)
        
        let textOField = NSTextField(frame: NSRect(x: 525, y: windowHeight - 30, width: 145, height: 22))
        textOField.font = NSFont.systemFont(ofSize: 13)
        textOField.target = self
        textOField.action = #selector(textFieldChanged(_:))
        textO = textOField
        contentView.addSubview(textOField)
        
        // Кампания, Награда, Номер, Степень
        let labelKampania = NSTextField(labelWithString: "Кампания:")
        labelKampania.frame = NSRect(x: 10, y: windowHeight - 60, width: 80, height: 17)
        contentView.addSubview(labelKampania)
        
        let comboKampaniaField = NSComboBox(frame: NSRect(x: 10, y: windowHeight - 80, width: 210, height: 22))
        comboKampaniaField.font = NSFont.systemFont(ofSize: 13)
        comboKampaniaField.delegate = self
        comboKampania = comboKampaniaField
        contentView.addSubview(comboKampaniaField)
        
        let labelNagrada = NSTextField(labelWithString: "Награда:")
        labelNagrada.frame = NSRect(x: 230, y: windowHeight - 60, width: 70, height: 17)
        contentView.addSubview(labelNagrada)
        
        let comboNagradaField = NSComboBox(frame: NSRect(x: 230, y: windowHeight - 80, width: 210, height: 22))
        comboNagradaField.font = NSFont.systemFont(ofSize: 13)
        comboNagradaField.delegate = self
        comboNagrada = comboNagradaField
        contentView.addSubview(comboNagradaField)
        
        let labelNomer = NSTextField(labelWithString: "Номер:")
        labelNomer.frame = NSRect(x: 450, y: windowHeight - 60, width: 50, height: 17)
        contentView.addSubview(labelNomer)
        
        let textNomerField = NSTextField(frame: NSRect(x: 450, y: windowHeight - 80, width: 100, height: 22))
        textNomerField.font = NSFont.systemFont(ofSize: 13)
        textNomerField.target = self
        textNomerField.action = #selector(textFieldChanged(_:))
        textNomer = textNomerField
        contentView.addSubview(textNomerField)
        
        let labelStepen = NSTextField(labelWithString: "Степень:")
        labelStepen.frame = NSRect(x: 560, y: windowHeight - 60, width: 60, height: 17)
        contentView.addSubview(labelStepen)
        
        let textStepenField = NSTextField(frame: NSRect(x: 560, y: windowHeight - 80, width: 110, height: 22))
        textStepenField.font = NSFont.systemFont(ofSize: 13)
        textStepenField.target = self
        textStepenField.action = #selector(textFieldChanged(_:))
        textStepen = textStepenField
        contentView.addSubview(textStepenField)
        
        // Часть, Подразделения
        let labelChast = NSTextField(labelWithString: "Часть:")
        labelChast.frame = NSRect(x: 10, y: windowHeight - 120, width: 50, height: 17)
        contentView.addSubview(labelChast)
        
        let comboChastField = NSComboBox(frame: NSRect(x: 10, y: windowHeight - 140, width: 210, height: 22))
        comboChastField.font = NSFont.systemFont(ofSize: 13)
        comboChastField.delegate = self
        comboChast = comboChastField
        contentView.addSubview(comboChastField)
        
        let labelPodrazdel1 = NSTextField(labelWithString: "Подразделение 1:")
        labelPodrazdel1.frame = NSRect(x: 230, y: windowHeight - 120, width: 120, height: 17)
        contentView.addSubview(labelPodrazdel1)
        
        let comboPodrazdel1Field = NSComboBox(frame: NSRect(x: 230, y: windowHeight - 140, width: 210, height: 22))
        comboPodrazdel1Field.font = NSFont.systemFont(ofSize: 13)
        comboPodrazdel1Field.delegate = self
        comboPodrazdel1 = comboPodrazdel1Field
        contentView.addSubview(comboPodrazdel1Field)
        
        let labelPodrazdel2 = NSTextField(labelWithString: "Подразделение 2:")
        labelPodrazdel2.frame = NSRect(x: 450, y: windowHeight - 120, width: 120, height: 17)
        contentView.addSubview(labelPodrazdel2)
        
        let comboPodrazdel2Field = NSComboBox(frame: NSRect(x: 450, y: windowHeight - 140, width: 210, height: 22))
        comboPodrazdel2Field.font = NSFont.systemFont(ofSize: 13)
        comboPodrazdel2Field.delegate = self
        comboPodrazdel2 = comboPodrazdel2Field
        contentView.addSubview(comboPodrazdel2Field)
        
        // Чин, Должность
        let labelChin = NSTextField(labelWithString: "Чин:")
        labelChin.frame = NSRect(x: 10, y: windowHeight - 180, width: 40, height: 17)
        contentView.addSubview(labelChin)
        
        let comboChinField = NSComboBox(frame: NSRect(x: 10, y: windowHeight - 200, width: 210, height: 22))
        comboChinField.font = NSFont.systemFont(ofSize: 13)
        comboChinField.delegate = self
        comboChin = comboChinField
        contentView.addSubview(comboChinField)
        
        let labelDolzhnost = NSTextField(labelWithString: "Должность:")
        labelDolzhnost.frame = NSRect(x: 230, y: windowHeight - 180, width: 80, height: 17)
        contentView.addSubview(labelDolzhnost)
        
        let textDolzhnostField = NSTextField(frame: NSRect(x: 230, y: windowHeight - 200, width: 430, height: 22))
        textDolzhnostField.font = NSFont.systemFont(ofSize: 13)
        textDolzhnostField.target = self
        textDolzhnostField.action = #selector(textFieldChanged(_:))
        textDolzhnost = textDolzhnostField
        contentView.addSubview(textDolzhnostField)
        
        // Губерния, Уезд, Деревня
        let labelGubernia = NSTextField(labelWithString: "Губерния:")
        labelGubernia.frame = NSRect(x: 10, y: windowHeight - 240, width: 70, height: 17)
        contentView.addSubview(labelGubernia)
        
        let textGuberniaField = NSTextField(frame: NSRect(x: 85, y: windowHeight - 240, width: 150, height: 22))
        textGuberniaField.font = NSFont.systemFont(ofSize: 13)
        textGuberniaField.target = self
        textGuberniaField.action = #selector(textFieldChanged(_:))
        textGubernia = textGuberniaField
        contentView.addSubview(textGuberniaField)
        
        let labelUezd = NSTextField(labelWithString: "Уезд:")
        labelUezd.frame = NSRect(x: 245, y: windowHeight - 240, width: 50, height: 17)
        contentView.addSubview(labelUezd)
        
        let textUezdField = NSTextField(frame: NSRect(x: 300, y: windowHeight - 240, width: 150, height: 22))
        textUezdField.font = NSFont.systemFont(ofSize: 13)
        textUezdField.target = self
        textUezdField.action = #selector(textFieldChanged(_:))
        textUezd = textUezdField
        contentView.addSubview(textUezdField)
        
        let labelDer = NSTextField(labelWithString: "Деревня:")
        labelDer.frame = NSRect(x: 460, y: windowHeight - 240, width: 70, height: 17)
        contentView.addSubview(labelDer)
        
        let textDerField = NSTextField(frame: NSRect(x: 535, y: windowHeight - 240, width: 135, height: 22))
        textDerField.font = NSFont.systemFont(ofSize: 13)
        textDerField.target = self
        textDerField.action = #selector(textFieldChanged(_:))
        textDer = textDerField
        contentView.addSubview(textDerField)
        
        // Отличие (большое текстовое поле)
        let labelOtlichie = NSTextField(labelWithString: "Отличие:")
        labelOtlichie.frame = NSRect(x: 10, y: windowHeight - 380, width: 60, height: 17)
        contentView.addSubview(labelOtlichie)
        
        let scrollViewOtlichie = NSScrollView(frame: NSRect(x: 10, y: windowHeight - 400, width: 660, height: 80))
        scrollViewOtlichie.hasVerticalScroller = true
        scrollViewOtlichie.borderType = .bezelBorder
        let textOtlichieField = NSTextView(frame: scrollViewOtlichie.bounds)
        textOtlichieField.font = NSFont.systemFont(ofSize: 13)
        textOtlichie = textOtlichieField
        // Отслеживание изменений для NSTextView через NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange(_:)), name: NSText.didChangeNotification, object: textOtlichieField)
        scrollViewOtlichie.documentView = textOtlichieField
        contentView.addSubview(scrollViewOtlichie)
        
        // Комментарий
        let labelComment = NSTextField(labelWithString: "Комментарий:")
        labelComment.frame = NSRect(x: 10, y: windowHeight - 490, width: 100, height: 17)
        contentView.addSubview(labelComment)
        
        let scrollViewComment = NSScrollView(frame: NSRect(x: 115, y: windowHeight - 490, width: 555, height: 22))
        scrollViewComment.hasVerticalScroller = false
        scrollViewComment.borderType = .bezelBorder
        let textCommentField = NSTextView(frame: scrollViewComment.bounds)
        textCommentField.font = NSFont.systemFont(ofSize: 13)
        textCommentField.isEditable = true
        textComment = textCommentField
        // Отслеживание изменений для NSTextView через NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange(_:)), name: NSText.didChangeNotification, object: textCommentField)
        scrollViewComment.documentView = textCommentField
        contentView.addSubview(scrollViewComment)
        
        // Приказ, награждение
        let labelPrikaz = NSTextField(labelWithString: "Приказ, награждение:")
        labelPrikaz.frame = NSRect(x: 10, y: windowHeight - 520, width: 140, height: 17)
        contentView.addSubview(labelPrikaz)
        
        let textPrikazField = NSTextField(frame: NSRect(x: 10, y: windowHeight - 540, width: 210, height: 22))
        textPrikazField.font = NSFont.systemFont(ofSize: 13)
        textPrikazField.target = self
        textPrikazField.action = #selector(textFieldChanged(_:))
        textPrikaz = textPrikazField
        contentView.addSubview(textPrikazField)
        
        let labelNomerPrik = NSTextField(labelWithString: "Номер приказа:")
        labelNomerPrik.frame = NSRect(x: 10, y: windowHeight - 570, width: 110, height: 17)
        contentView.addSubview(labelNomerPrik)
        
        let textNomerPrikField = NSTextField(frame: NSRect(x: 10, y: windowHeight - 590, width: 210, height: 22))
        textNomerPrikField.font = NSFont.systemFont(ofSize: 13)
        textNomerPrikField.target = self
        textNomerPrikField.action = #selector(textFieldChanged(_:))
        textNomerPrik = textNomerPrikField
        contentView.addSubview(textNomerPrikField)
        
        let labelDataPrik = NSTextField(labelWithString: "Дата приказа:")
        labelDataPrik.frame = NSRect(x: 10, y: windowHeight - 620, width: 100, height: 17)
        contentView.addSubview(labelDataPrik)
        
        let textDataPrikField = NSTextField(frame: NSRect(x: 10, y: windowHeight - 640, width: 210, height: 22))
        textDataPrikField.font = NSFont.systemFont(ofSize: 13)
        textDataPrikField.target = self
        textDataPrikField.action = #selector(textFieldChanged(_:))
        textDataPrik = textDataPrikField
        contentView.addSubview(textDataPrikField)
        
        // Приказ, упоминание
        let labelOtnosh = NSTextField(labelWithString: "Приказ, упоминание:")
        labelOtnosh.frame = NSRect(x: 230, y: windowHeight - 520, width: 150, height: 17)
        contentView.addSubview(labelOtnosh)
        
        let textOtnoshField = NSTextField(frame: NSRect(x: 230, y: windowHeight - 540, width: 210, height: 22))
        textOtnoshField.font = NSFont.systemFont(ofSize: 13)
        textOtnoshField.target = self
        textOtnoshField.action = #selector(textFieldChanged(_:))
        textOtnosh = textOtnoshField
        contentView.addSubview(textOtnoshField)
        
        let labelNomerOtnosh = NSTextField(labelWithString: "Номер приказа:")
        labelNomerOtnosh.frame = NSRect(x: 230, y: windowHeight - 570, width: 110, height: 17)
        contentView.addSubview(labelNomerOtnosh)
        
        let textNomerOtnoshField = NSTextField(frame: NSRect(x: 230, y: windowHeight - 590, width: 210, height: 22))
        textNomerOtnoshField.font = NSFont.systemFont(ofSize: 13)
        textNomerOtnoshField.target = self
        textNomerOtnoshField.action = #selector(textFieldChanged(_:))
        textNomerOtnosh = textNomerOtnoshField
        contentView.addSubview(textNomerOtnoshField)
        
        let labelDataOtnosh = NSTextField(labelWithString: "Дата приказа:")
        labelDataOtnosh.frame = NSRect(x: 230, y: windowHeight - 620, width: 100, height: 17)
        contentView.addSubview(labelDataOtnosh)
        
        let textDataOtnoshField = NSTextField(frame: NSRect(x: 230, y: windowHeight - 640, width: 210, height: 22))
        textDataOtnoshField.font = NSFont.systemFont(ofSize: 13)
        textDataOtnoshField.target = self
        textDataOtnoshField.action = #selector(textFieldChanged(_:))
        textDataOtnosh = textDataOtnoshField
        contentView.addSubview(textDataOtnoshField)
        
        // Архив
        let labelArxiv = NSTextField(labelWithString: "Архив:")
        labelArxiv.frame = NSRect(x: 450, y: windowHeight - 520, width: 50, height: 17)
        contentView.addSubview(labelArxiv)
        
        let comboArxivField = NSComboBox(frame: NSRect(x: 450, y: windowHeight - 540, width: 210, height: 22))
        comboArxivField.font = NSFont.systemFont(ofSize: 13)
        comboArxivField.delegate = self
        comboArxiv = comboArxivField
        contentView.addSubview(comboArxivField)
        
        // Фонд, Опись, Дело, Лист
        let labelFond = NSTextField(labelWithString: "Фонд:")
        labelFond.frame = NSRect(x: 450, y: windowHeight - 570, width: 50, height: 17)
        contentView.addSubview(labelFond)
        
        let textFondField = NSTextField(frame: NSRect(x: 450, y: windowHeight - 590, width: 110, height: 22))
        textFondField.font = NSFont.systemFont(ofSize: 13)
        textFondField.target = self
        textFondField.action = #selector(textFieldChanged(_:))
        textFond = textFondField
        contentView.addSubview(textFondField)
        
        let labelOpis = NSTextField(labelWithString: "Опись:")
        labelOpis.frame = NSRect(x: 450, y: windowHeight - 620, width: 50, height: 17)
        contentView.addSubview(labelOpis)
        
        let textOpisField = NSTextField(frame: NSRect(x: 450, y: windowHeight - 640, width: 110, height: 22))
        textOpisField.font = NSFont.systemFont(ofSize: 13)
        textOpisField.target = self
        textOpisField.action = #selector(textFieldChanged(_:))
        textOpis = textOpisField
        contentView.addSubview(textOpisField)
        
        let labelDelo = NSTextField(labelWithString: "Дело:")
        labelDelo.frame = NSRect(x: 570, y: windowHeight - 570, width: 40, height: 17)
        contentView.addSubview(labelDelo)
        
        let textDeloField = NSTextField(frame: NSRect(x: 570, y: windowHeight - 590, width: 90, height: 22))
        textDeloField.font = NSFont.systemFont(ofSize: 13)
        textDeloField.target = self
        textDeloField.action = #selector(textFieldChanged(_:))
        textDelo = textDeloField
        contentView.addSubview(textDeloField)
        
        let labelList = NSTextField(labelWithString: "Лист:")
        labelList.frame = NSRect(x: 570, y: windowHeight - 620, width: 40, height: 17)
        contentView.addSubview(labelList)
        
        let textListField = NSTextField(frame: NSRect(x: 570, y: windowHeight - 640, width: 90, height: 22))
        textListField.font = NSFont.systemFont(ofSize: 13)
        textListField.target = self
        textListField.action = #selector(textFieldChanged(_:))
        textList = textListField
        contentView.addSubview(textListField)
        
        // Другие источники (размещаем выше служебных отметок, чтобы не наезжали)
        let labelDrugieIst = NSTextField(labelWithString: "Другие источники:")
        labelDrugieIst.frame = NSRect(x: 450, y: windowHeight - 680, width: 130, height: 17)
        contentView.addSubview(labelDrugieIst)
        
        let textDrugieIstField = NSTextField(frame: NSRect(x: 450, y: windowHeight - 700, width: 220, height: 22))
        textDrugieIstField.font = NSFont.systemFont(ofSize: 13)
        textDrugieIstField.target = self
        textDrugieIstField.action = #selector(textFieldChanged(_:))
        textDrugieIst = textDrugieIstField
        contentView.addSubview(textDrugieIstField)
        
        // Служебные отметки (размещаем выше кнопок, чтобы не наезжали)
        // Кнопки на y=10, высота кнопки 28, отступ 10 = 48, служебные отметки должны быть выше
        let labelSluzhOtm = NSTextField(labelWithString: "Служебные отметки:")
        labelSluzhOtm.frame = NSRect(x: 10, y: 60, width: 130, height: 17)
        contentView.addSubview(labelSluzhOtm)
        
        let scrollViewSluzhOtm = NSScrollView(frame: NSRect(x: 10, y: 40, width: 660, height: 22))
        scrollViewSluzhOtm.hasVerticalScroller = false
        scrollViewSluzhOtm.borderType = .bezelBorder
        let textSluzhOtmField = NSTextView(frame: scrollViewSluzhOtm.bounds)
        textSluzhOtmField.font = NSFont.systemFont(ofSize: 13)
        textSluzhOtm = textSluzhOtmField
        // Отслеживание изменений для NSTextView через NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange(_:)), name: NSText.didChangeNotification, object: textSluzhOtmField)
        scrollViewSluzhOtm.documentView = textSluzhOtmField
        contentView.addSubview(scrollViewSluzhOtm)
        
        // Кнопки в левом нижнем углу (как в VB.NET: ButtonSaveNagrada.Location = (8, 618), ButtonEdit.Location = (109, 618))
        let buttonSaveField = NSButton(title: "Сохранить", target: self, action: #selector(buttonSaveClicked(_:)))
        buttonSaveField.frame = NSRect(x: 10, y: 10, width: 100, height: 28)
        buttonSaveField.bezelStyle = .rounded
        buttonSaveField.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        buttonSaveField.isEnabled = false // По умолчанию неактивна, активируется только в режиме редактирования
        buttonSave = buttonSaveField
        contentView.addSubview(buttonSaveField)
        
        let buttonEditField = NSButton(title: "Изменить", target: self, action: #selector(buttonEditClicked(_:)))
        buttonEditField.frame = NSRect(x: 120, y: 10, width: 100, height: 28)
        buttonEditField.bezelStyle = .rounded
        buttonEditField.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        buttonEdit = buttonEditField
        contentView.addSubview(buttonEditField)
        
        // CheckBox для блокировки формы (скрыт, используется только для внутренней логики)
        checkFormBlocked = NSButton(checkboxWithTitle: "", target: self, action: #selector(checkFormBlockedClicked(_:)))
        checkFormBlocked?.frame = NSRect(x: 0, y: 0, width: 0, height: 0)
        checkFormBlocked?.isHidden = true
        
        window.contentView = contentView
    }
    
    @objc func checkFormBlockedClicked(_ sender: Any) {
        let blocked = checkFormBlocked?.state == .on
        setStatus(blocked: blocked)
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
    
    func fillForm(copy: Bool = false) {
        guard let nagrada = nagrada else {
            print("⚠️ fillForm: nagrada is nil")
            return
        }
        fillForm(from: nagrada, copy: copy)
    }
    
    func fillForm(from nagrada: Nagrada, copy: Bool = false) {
        print("📝 fillForm вызван для nagrada с id: \(nagrada.id), copy: \(copy)")
        noEvents = true
        
        // Если это не новая запись и не копирование, сохраняем ссылку на nagrada (как в VB.NET: If its_new = False Then pr = r)
        if !isNew && !copy {
            self.nagrada = nagrada
        }
        
        edited = false
        window?.title = "Редактор наград"
        
        // Кампания - ищем значение в списке и устанавливаем индекс (как в VB.NET)
        if let komp = nagrada.komp, !komp.isEmpty {
            if let combo = comboKampania {
                // Ищем значение в списке
                let index = combo.indexOfItem(withObjectValue: komp)
                if index != NSNotFound {
                    combo.selectItem(at: index)
                } else {
                    // Если не найдено, добавляем и выбираем (как в VB.NET)
                    combo.addItem(withObjectValue: komp)
                    combo.selectItem(at: combo.numberOfItems - 1)
                }
            }
        } else {
            comboKampania?.deselectItem(at: comboKampania?.indexOfSelectedItem ?? -1)
        }
        
        // Награда - устанавливаем индекс напрямую (как в VB.NET: ComboNagrada.SelectedIndex = r.Fields("nagrada").Value)
        if let nagradaType = nagrada.nagrada {
            comboNagrada?.selectItem(at: nagradaType)
        } else {
            comboNagrada?.deselectItem(at: comboNagrada?.indexOfSelectedItem ?? -1)
        }
        
        // Номер и Степень
        if let nomer = nagrada.nomer {
            textNomer?.stringValue = String(nomer)
        } else {
            textNomer?.stringValue = ""
        }
        
        if let stepen = nagrada.stepen {
            textStepen?.stringValue = String(stepen)
        } else {
            textStepen?.stringValue = ""
        }
        
        // ФИО
        textF?.stringValue = nagrada.фамилия ?? ""
        textI?.stringValue = nagrada.имя ?? ""
        textO?.stringValue = nagrada.отчество ?? ""
        
        // Часть, Подразделения, Чин - устанавливаем текст (как в VB.NET: ComboChast.Text = ...)
        comboChast?.stringValue = nagrada.chast ?? ""
        comboPodrazdel1?.stringValue = nagrada.podrazdel1 ?? ""
        comboPodrazdel2?.stringValue = nagrada.podrazdel2 ?? ""
        comboChin?.stringValue = nagrada.chin ?? ""
        
        // Должность
        textDolzhnost?.stringValue = nagrada.dolzhnost ?? ""
        
        // Губерния, Уезд, Деревня
        textGubernia?.stringValue = nagrada.Губерния ?? ""
        textUezd?.stringValue = nagrada.Уезд ?? ""
        textDer?.stringValue = nagrada.Деревня ?? ""
        
        // Отличие (большое текстовое поле)
        textOtlichie?.string = nagrada.otlichie ?? ""
        
        // Комментарий
        textComment?.string = nagrada.komment ?? ""
        
        // Приказ, награждение
        textPrikaz?.stringValue = nagrada.prikaz ?? ""
        textNomerPrik?.stringValue = nagrada.nomer_prik ?? ""
        textDataPrik?.stringValue = nagrada.data_prik ?? ""
        
        // Приказ, упоминание
        textOtnosh?.stringValue = nagrada.otnosh ?? ""
        textNomerOtnosh?.stringValue = nagrada.nomer_otnosh ?? ""
        textDataOtnosh?.stringValue = nagrada.data_otnosh ?? ""
        
        // Служебные отметки
        textSluzhOtm?.string = nagrada.sluzh_otm ?? ""
        
        // Архив - устанавливаем текст
        comboArxiv?.stringValue = nagrada.arxiv ?? ""
        
        // Фонд, Опись, Дело, Лист
        textFond?.stringValue = nagrada.fond ?? ""
        textOpis?.stringValue = nagrada.opis ?? ""
        textDelo?.stringValue = nagrada.delo ?? ""
        textList?.stringValue = nagrada.list ?? ""
        
        // Другие источники
        textDrugieIst?.stringValue = nagrada.drugie_ist ?? ""
        
        print("✅ fillForm завершен. Проверка значений:")
        print("   Фамилия: \(textF?.stringValue ?? "nil")")
        print("   Имя: \(textI?.stringValue ?? "nil")")
        print("   Кампания: \(comboKampania?.stringValue ?? "nil")")
        print("   Награда индекс: \(comboNagrada?.indexOfSelectedItem ?? -1)")
        
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
        
        edited = false
        window?.title = "Редактор наград"
        noEvents = false
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
        
        // Управление кнопкой Сохранить: активна только когда форма разблокирована и есть изменения
        buttonSave?.isEnabled = !blocked && edited
    }
    
    private func markAsEdited() {
        if !noEvents {
            edited = true
            buttonSave?.isEnabled = true
            window?.title = "Редактор наград (*)"
        }
    }
    
    @objc func textFieldChanged(_ sender: Any) {
        markAsEdited()
    }
    
    @objc func textViewDidChange(_ notification: Notification) {
        markAsEdited()
    }
    
    // NSComboBoxDelegate
    func comboBoxSelectionDidChange(_ notification: Notification) {
        markAsEdited()
    }
    
    @IBAction func buttonSaveClicked(_ sender: Any) {
        // Проверяем, что форма в режиме редактирования (как в VB.NET: If edited = False Then Exit Sub)
        guard edited else {
            return
        }
        
        saveData()
    }
    
    @IBAction func buttonEditClicked(_ sender: Any) {
        // Проверяем, что это не новая запись (как в VB.NET: If its_new = True Then MsgBox("Нельзя редактировать новую награду"))
        if isNew {
            showAlert(message: "Нельзя редактировать новую награду")
            return
        }
        
        // Разблокируем форму для редактирования (как в VB.NET: SetStatus(enumNagradaStatus.enabled))
        setStatus(blocked: false)
        edited = true
        buttonSave?.isEnabled = true
        
        // Обновляем заголовок окна (как в VB.NET: Me.Text = "Редактор наград (*)")
        window?.title = "Редактор наград (*)"
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
            
            // Блокируем форму после сохранения (как в VB.NET: SetStatus(enumNagradaStatus.blocked))
            setStatus(blocked: true)
            buttonSave?.isEnabled = false
            
            // Обновляем объект nagrada из базы данных
            if let results = DatabaseManager.shared.executeQuery("SELECT * FROM nagrada WHERE id = '\(id.replacingOccurrences(of: "'", with: "''"))'"),
               let firstRow = results.first {
                nagrada = Nagrada(from: firstRow)
            }
            
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
        // Загружаем настройки обязательных полей из базы данных
        guard let requiredFieldsSettings = getRequiredFieldsSettings() else {
            // Если не удалось загрузить настройки, используем все поля как обязательные
            return validateAllFields()
        }
        
        var missingFields: [String] = []
        
        // Маппинг названий полей в UI на элементы формы
        let fieldMapping: [String: (() -> Bool)] = [
            "Кампания": { [weak self] in
                guard let value = self?.comboKampania?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Вид": { [weak self] in
                guard let index = self?.comboNagrada?.indexOfSelectedItem else { return false }
                return index >= 0
            },
            "Номер": { [weak self] in
                guard let value = self?.textNomer?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty && Int(value) != nil && Int(value)! > 0
            },
            "Степень": { [weak self] in
                guard let value = self?.textStepen?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty && Int(value) != nil && Int(value)! > 0
            },
            "Фамилия": { [weak self] in
                guard let value = self?.textF?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Имя": { [weak self] in
                guard let value = self?.textI?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Отчество": { [weak self] in
                guard let value = self?.textO?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Часть": { [weak self] in
                guard let value = self?.comboChast?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Подразделение1": { [weak self] in
                guard let value = self?.comboPodrazdel1?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Подразделение2": { [weak self] in
                guard let value = self?.comboPodrazdel2?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Чин": { [weak self] in
                guard let value = self?.comboChin?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Должность": { [weak self] in
                guard let value = self?.textDolzhnost?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Отличие": { [weak self] in
                guard let value = self?.textOtlichie?.string else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Комментарий": { [weak self] in
                guard let value = self?.textComment?.string else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Приказ": { [weak self] in
                guard let value = self?.textPrikaz?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Номер приказа": { [weak self] in
                guard let value = self?.textNomerPrik?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Дата приказа": { [weak self] in
                guard let value = self?.textDataPrik?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Отношение": { [weak self] in
                guard let value = self?.textOtnosh?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Номер отношения": { [weak self] in
                guard let value = self?.textNomerOtnosh?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Дата отношения": { [weak self] in
                guard let value = self?.textDataOtnosh?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Архив": { [weak self] in
                guard let value = self?.comboArxiv?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Фонд": { [weak self] in
                guard let value = self?.textFond?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Дело": { [weak self] in
                guard let value = self?.textDelo?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Опись": { [weak self] in
                guard let value = self?.textOpis?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Лист": { [weak self] in
                guard let value = self?.textList?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Другие источники": { [weak self] in
                guard let value = self?.textDrugieIst?.stringValue else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            },
            "Служебные отметки": { [weak self] in
                guard let value = self?.textSluzhOtm?.string else { return false }
                return !value.trimmingCharacters(in: .whitespaces).isEmpty
            }
        ]
        
        // Проверяем каждое обязательное поле
        for (fieldName, isRequired) in requiredFieldsSettings {
            if isRequired {
                if let validator = fieldMapping[fieldName] {
                    if !validator() {
                        missingFields.append(fieldName)
                    }
                }
            }
        }
        
        // Если есть незаполненные обязательные поля, показываем ошибку
        if !missingFields.isEmpty {
            let fieldsList = missingFields.joined(separator: ", ")
            showAlert(message: "Не заполнены обязательные поля:\n\(fieldsList)")
            return false
        }
        
        return true
    }
    
    func validateAllFields() -> Bool {
        // Валидация всех полей по умолчанию (если настройки не загружены)
        var missingFields: [String] = []
        
        // Базовые обязательные поля
        if comboNagrada?.indexOfSelectedItem ?? -1 < 0 {
            missingFields.append("Вид")
        }
        if textNomer?.stringValue.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
            missingFields.append("Номер")
        }
        if textStepen?.stringValue.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
            missingFields.append("Степень")
        }
        if textF?.stringValue.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
            missingFields.append("Фамилия")
        }
        if textI?.stringValue.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
            missingFields.append("Имя")
        }
        
        if !missingFields.isEmpty {
            let fieldsList = missingFields.joined(separator: ", ")
            showAlert(message: "Не заполнены обязательные поля:\n\(fieldsList)")
            return false
        }
        
        return true
    }
    
    func getRequiredFieldsSettings() -> [String: Bool]? {
        // Создаем таблицу, если её нет
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Обязательные_поля (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            поле TEXT UNIQUE NOT NULL,
            обязательное INTEGER NOT NULL DEFAULT 1
        )
        """
        DatabaseManager.shared.executeUpdate(createTableQuery)
        
        // Загружаем настройки обязательных полей из базы данных
        guard let results = DatabaseManager.shared.executeQuery("SELECT поле, обязательное FROM Обязательные_поля") else {
            return nil
        }
        
        var settings: [String: Bool] = [:]
        for row in results {
            if let fieldName = row["поле"] as? String,
               let isRequired = (row["обязательное"] as? Int64).map({ $0 == 1 }) {
                settings[fieldName] = isRequired
            }
        }
        
        // Если настройки не найдены, возвращаем nil (будет использована валидация по умолчанию)
        return settings.isEmpty ? nil : settings
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

