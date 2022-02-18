--[[
	--------------------------- Changelog ---------------------------
	13.01.2020 - 1
	
	1.21.2 (2021-02-08)
- Добавлена версионность формы, отображение версии в заголовке окна
- Введена константа MAX_XML_RECORDS_TO_COLLECT_GARBAGE, устанавливающая количество записей XML-документа, 
  при достижении которого принудительно вызывается сборщик мусора (на некоторых банках достигается лимит
  выделенной памяти и Cronos падает в ошибку "Out of memory").
- Таблица со списком баз формируется при открытии формы.

	1.21.3 (2021-02-08)
- Ревизия, оптимизация кода.
- Константа MAX_XML_RECORDS_TO_COLLECT_GARBAGE исключена - потребление памяти снижено до ~100 Мб.
- Исправлен баг отказа повторного запуска выгрузки после ее отмены.

	1.21.4 (2021-02-11)
- Константа MAX_XML_RECORDS_TO_COLLECT_GARBAGE возвращена.
- Добавлена очистка мнемокода базы от всех небуквенных символов.

	1.21.5 (2021-02-12)
- Реализован модуль ProgressBar.
- Все прогрессбары переведены на класс ProgressBar.
- Визуализирована скорость выгрузки данных.
- Временный cmd-файл со случайным именем создается во временном каталоге.
- Уменьшен шрифт монитора выгрузки экспорта.
- Для баз, записи которых имеют поля типа "Файл" и эти поля имеют данные, время вызова cmd-файла
  увеличивается в два раза (константа CMD_CALL_INTERVAL * 2).
  
	1.21.6 (2021-02-24)
- К XML-тегу имени поля добавлен суффикс в виде номера для его уникализации в рамках одной базы данных.

	1.21.7 (2021-02-26)
- Добавлена возможность сохранения прогресса экспорта и его возобновления. Прогресс сохраняется автоматически 
  при прерывании экспорта пользователем нажатием на кнопку "Отменить". Системные номера экспортированных записей
  сохраняются в таблице ExportedRecordsSysNumbers и при прерывании записываются в именованнные переменные банка 
  по его мнемокоду с префиксом PROGRESS_BASE_PREFIX. Для определения факта сохранения используется переменная 
  PROGRESS_MARK со строковым значением '1'.
- Исправлена ошибка создания переименованного файла.
- Вместо счетчика в имени существующего файла генерируется случайная строка.

	1.21.8 (2021-03-01)
- Прогресс принудительно сохраняется при записи очередного XML-файла и удаляется после успешного завершения 
  выгрузки всего банка.
- Удаление данных прогресса вынесено в отдельную функцию DeleteSavedProgress.

	1.21.9 (2021-03-15)
-  Объединен код из двух форм.
-  Рефакторинг.
-  Добавлено логирование.
-  Изменены функции, формирующие набор записей с пустыми служебными полями и обрабатывающие этот набор.
-  В функцию "add_value_in_guid_and_status" добавил break в случае нажатия кнопки "Cancel"

	1.21.10 (2021-05-18)
-  В словарных полях теперь выгружаются коды, а не понятия
-  Для полей связей выгружаются guid, а не системные номера
-  Системные скрипты перенесены в скрипты банка

	1.21.11
-  Изменен порядок формирования таблицы list_recs_for_unloading. В качестве ключей используются целые 
   числа, чтобы дальнейшая обработка баз производилась в том же порядке, в котором они расположены в таблице.
-  Исправлена ошибка некорректного отображения дыты начала обработки бызы во время выгрузки в xml-файлы.
-  Изменена выгрузка значений словарных полей. Теперь код записывается в качестве аргумента тэга 
   (dictionary_code), а понятие в качестве значения тэга.
-  Добавлена очистка кода словаря (dictionary_code) от "ненужных" символов

    1.21.12
-  Обработка типов полей переведена на константы класса Field для исключения опечаток в текстовых значениях
   имен типов.
-  Переработан метод обработки сложных полей и исправлена ошибка экспорта данных из них.
-  Ссылки на номера полей "GUID" и "Статус записи" переведны на константы GUID_FIELD_NUMBER и STATUS_FIELD_NUMBER.
-  XML-файлы нумеруются с ведущими нулями (всего 6 числовых символов).

    1.21.13 (2021-09-15)
-  Путь выгрузки по умолчанию формируется относительно пути хранения текущего банка.
-  Форма не закрывается автоматически после завершения процедуры экспорта.

    1.21.14 (2021-09-29)
-  Изменен интерфейс формы - уменьшен шрифт и размер кнопок, заголовки монитора сделаны жирным шрифтом.
-  Добавлена возможность полной выгрузки данных - checkbox FullExportCheckBox.
-  Изменен порядок выдачи сообщений пользователю перед экспортом.
-  Перед экспортом рассчитыватся кол-во записей, подлежащих выгрузке, и проставляется в мониторе.
-  Рефакторинг кода.

    1.21.15 (2021-11-25)
-  Исправлена ошибка отображения времени.
-  Без регистрации банка выгрузка не сработает.

    1.21.16 (28.12.2021)
- Скрипты DB2XML и ProgressBar перенесены в скрипты банка.
- Исправлена ошибка получения данных о регистрации банка.

    1.21.17 (29.12.2021)
- Добавлена поддержка выгрузки из структуры "Титан".

    1.22.2 (13.01.2022)
- Технические поля Титана приведены к единой нумерации с Алмазом. 
- Исключена проверка типа банка по наличю словаря.
- Исключены события по клику на панель времени (функции в коде оставлены).

    1.22.2 (24.01.2022)
- Исправлена спутанность кода и значения при получении регистрационных данных.
]]

--[[
Tasks:
-  Добавить в guid дату создания записи в отдельный блок в шестнадцатеричном формате;
-  Добавить отображение в таблице на форме процесса обработки записей при заполнении служебных полей;
]]

local EDITION = 1
local SUBVERSION = 22
local RELEASE = 2
local VERSION = EDITION..'.'..SUBVERSION..'.'..RELEASE


local GUID_FIELD_NUMBER = 999
local STATUS_FIELD_NUMBER = 777

local STATUS_EXPORTED = 0
local STATUS_NEW = 1
local STATUS_MODIFIED = 2

local MAX_XML_RECORDS_TO_COLLECT_GARBAGE = 1000
local NODES_PER_XML_FILE = 5000
local CMD_CALL_INTERVAL = 1
local FORM_TITLE = 'Экспорт данных (ver.'..VERSION..') - '..CroApp.UserName

local STRING_REQUEST_ALMAZ = 'ОТ RG01 1 РВ "РЕГИОН"'
local STRING_REQUEST_TITANIUM = 'ОТ ZZ01 10 РВ `КОД ПОДРАЗДЕЛЕНИЯ`'

local LOCK_SN_ID = 666
local LOCK_FILE_NUMBER_ID = 777
local PROGRESS_MARK = '_cronos2xml_progress_saved'
local PROGRESS_BASE_PREFIX = '_cronos2xml_progress_'
local FILE_NUMBER_VAR_NAME_BASE_PREFIX = '_cronos2xml_file_number_'
local ExportedRecordsSysNumbers = {}
local ExportFilesNumbers = {}

local DB2XML = require('DB2XML')
local ProgressBar = require('ProgressBar')

local cancel = false
local ContinueExport = nil
local CurrentBank = CroApp.GetBank()
local Bases = CurrentBank.Bases

local tempCmdFile = IO.Path.GetTempFileName()
tempCmdFile = IO.Path.ChangeExt(tempCmdFile, 'cmd')

local tmp_file = DateTime.Now:ToString('%x')..'.cmd'
local the_fields = 'are_not_exists'

local root_folder = ''
local log_folder = ''
local data_folder = ''
local total_recs_count = 0


function Форма_Load( form )
	local date = DateTime.Now
	local year = date.Year
	local month = string.format('%02d', date.Month)
	local day = string.format('%02d', date.Day)
	local hour = string.format('%02d', date:ToString('%H'))
	local minutes = string.format('%02d', date:ToString('%M'))
	
	Me.Text = FORM_TITLE
	Me.path.Text = CurrentBank.Path..date:ToString(year..'-'..month..'-'..day..'_'..hour..'-'..minutes)
	
	check_mnemo_codes(Bases)	--При импорте данных из Excel файлов в мнемокод базы может быть добавлен символ "$". Проверим наличие этих символов в структуре и заменим на букву.	
	create_monitor(Me.monitor, {'Код', 'Название базы', 'Обработано записей', 'Начало обработки', 'Затрачено времени'}) --Создается таблица на форме в которой будем отображать процесс обработки записей
	add_data_to_the_monitor()	

	Me.date.Text = date:ToString('%x')
	Me.timeH.Text = date:ToString('%H')
	Me.timeM.Text = date:ToString('%M')	
	
	timer = Me:CreateTimer()
	timer.Interval = 1000
	timer.Tick = function ( timer )
					
					Me.date.Text = DateTime.Now:ToString('%x')
					Me.timeH.Text = DateTime.Now:ToString('%H')
					Me.timeM.Text = DateTime.Now:ToString('%M')
					
					Me.sep.Visible = not Me.sep.Visible
					
				 end
				
	timer:Start()
end


function create_monitor(monitor, headers)
	monitor.NumberCols = #headers - 1
	local col_num = -1
	for _, header in ipairs(headers) do
		Me.monitor:SetCellText(col_num, -1, header)
		Me.monitor:SetRowHeight(-1, 20)
		col_num = col_num + 1
	end
end


function clear_the_monitor()
	for i = 1, Me.monitor.NumberRows do
		Me.monitor:DeleteRow(0)
	end
end


function add_data_to_the_monitor(list_recs_for_unloading)
	Me.monitor.Visible = false
	clear_the_monitor()
	for currBaseIndex, currBase in ipairs (Bases) do
		local code = currBase.Code
		if (code ~= _G.BasesTable[code]) then
			code = code..' ('.._G.BasesTable[code]..')'
		end
		Me.monitor:AppendRow()
		Me.monitor:SetCellText(-1, currBaseIndex-1, code)
		Me.monitor:SetCellText(0, currBaseIndex-1, currBase.Name)
		Me.monitor:SetCellText(1, currBaseIndex-1, '0 / 0')
		Me.monitor:SetCellTextAlign(0, currBaseIndex-1, ContentAlignment.MiddleLeft)
		if list_recs_for_unloading then
			local row_num, col_num = Me.monitor:Find(currBase.Name, 0, 0)
			if row_num then
				if list_recs_for_unloading[currBase.Code] then
					Me.monitor:SetCellText(1, row_num, '0 / '..list_recs_for_unloading[currBase.Code].Count)
				end
			end
		end
	end
	Me.monitor:BestFit(-1, Me.monitor.NumberCols-1)
	Me.monitor.Visible = true
end	


function IsProgressInterrupted()
	local formula = Formula()
	formula:SetValue('VarName', PROGRESS_MARK)
	formula:ExecuteString([[@@Progress := LOAD(@@VarName)]])
	return formula:GetValue('Progress', false) == '1'
end


function ProgressRecover()
	local formula = Formula()
	
	local KeysTable = {
		[LOCK_SN_ID] = PROGRESS_BASE_PREFIX,
		[LOCK_FILE_NUMBER_ID] = FILE_NUMBER_VAR_NAME_BASE_PREFIX,
	}
	
	for _, currBase in ipairs(Bases) do
		for LockId, BasePrefix in pairs(KeysTable) do
			local VarValue = nil
			formula:SetValue('LockID', LockId)
			formula:SetValue('VarName', BasePrefix.currBase.Code)
			formula:ExecuteString([[@@VarValue := LOADLOCK(@@VarName, @@LockID)]])
			if (BasePrefix == PROGRESS_BASE_PREFIX) then
				VarValue = formula:GetValue('VarValue', true)
				if (#VarValue > 0) then
					ExportedRecordsSysNumbers[currBase.Code] = table.invert(VarValue)
				end
			elseif (BasePrefix == FILE_NUMBER_VAR_NAME_BASE_PREFIX) then
				VarValue = formula:GetValue('VarValue', false)
				if (VarValue ~= '') then
					ExportFilesNumbers[currBase.Code] = tonumber(formula:GetValue('VarValue', false))
				end
			end
			formula:ExecuteString([[DISCARDUNLOCK(@@LockID)]])
		end
	end
end


function DeleteSavedProgress()
	local formula = Formula()
	local KeysTable = {
		[LOCK_SN_ID] = PROGRESS_BASE_PREFIX,
		[LOCK_FILE_NUMBER_ID] = FILE_NUMBER_VAR_NAME_BASE_PREFIX,
	}
	for _, currBase in ipairs(Bases) do
			for LockId, BasePrefix in pairs(KeysTable) do
			local VarValue = nil
			formula:SetValue('LockID', LockId)
			formula:SetValue('VarName', BasePrefix..currBase.Code)
			formula:ExecuteString([[DISCARDUNLOCK(@@LockID)]])
			formula:ExecuteString([[DELETE(@@VarName)]])
		end
	end
	formula:SetValue('VarName', PROGRESS_MARK)
	formula:ExecuteString([[DELETE(@@VarName)]])
end


function SaveProgress()
	local formula = Formula()
	local KeysTable = {
		[LOCK_SN_ID] = PROGRESS_BASE_PREFIX,
		[LOCK_FILE_NUMBER_ID] = FILE_NUMBER_VAR_NAME_BASE_PREFIX,
	}
	for _, currBase in ipairs(Bases) do
		if (ExportedRecordsSysNumbers[currBase.Code] ~= nil) or (ExportFilesNumbers[currBase.Code] ~= nil) then
			for LockId, BasePrefix in pairs(KeysTable) do
				formula:SetValue('LockID', LockId)
				formula:SetValue('VarName', BasePrefix..currBase.Code)
				if (BasePrefix == PROGRESS_BASE_PREFIX) then
					formula:SetValue('VarValue', table.invert(ExportedRecordsSysNumbers[currBase.Code]))
				elseif (BasePrefix == FILE_NUMBER_VAR_NAME_BASE_PREFIX) then
					formula:SetValue('VarValue', ExportFilesNumbers[currBase.Code])
				end
				formula:ExecuteString([[SAVEUNLOCK(@@VarName, @@VarValue, @@LockID)]])
			end
		end
	end
	formula:SetValue('VarName', PROGRESS_MARK)
	formula:SetValue('VarValue', '1')
	formula:ExecuteString([[SAVEUNLOCK(@@VarName, @@VarValue)]])
end


function folder_exists( folder )
	if  IO.Folder.Exists( folder ) then
		return true
	else
		if MsgBox('Каталог не существует.\nСоздать?', IconQuestion + BtnYesNo) == IdYes then
			if IO.Folder.Create( folder ) then
				if IO.Folder.Exists( folder ) then
					return true
				else
					MsgBox('Не удалось создать каталог. Попробуйте изменить имя или выбрать другую директорию.', IconError)
				end
			end
		end
	end
end


function export_data(base_recs_count, total_recs_count, list_recs_for_unloading)
	local start_time = DateTime.Now
	
	local ok, error = ExportToXMLPerform(root_folder)	--Вызов функции выгрузки структуры
	if not ok then
		write_to_log('unloading_process', 'В процессе выгрузки структуры были ошибки: '..tostring(error))
		MsgBox(tostring(error))
		cancel = true
	else
		databases_processing(base_recs_count, total_recs_count, list_recs_for_unloading)
	end
	Me.cancel.Enabled = false
end


function close_Click( control, event ) Me:CloseForm() end


function cancel_Click( control, event ) if MsgBox('Прервать операцию?', IconQuestion + BtnYesNo) == IdYes then cancel = true end end


function prepare_records_for_unloading()
	local time_start_function = DateTime.Now
	write_to_log('unloading_process', 'Производится выборка данных, подлежащих экспорту')
	Me.label_current_function.Text = 'Производится подготовка данных для экспорта'
	local BasesProgress = ProgressBar.ProgressBar:new(Me.BasesProgressBar, #Bases)
	BasesProgress:InitBar()
	local total_recs_count = 0
	local base_recs_count = 0
	local list_recs_for_unloading = {}
	for base_index, base in ipairs(Bases) do
		Me.label_bases.Text = 'Обрабатывается база '..base_index..' из '..#Bases
		local request = nil
		if not Me.FullExportCheckBox.Check then
			request = 'ОТ '..base.Code..'01 '..STATUS_FIELD_NUMBER..' БР '..STATUS_NEW
		else
			request = 'ОТ '..base.Code..'01'
		end
		local RS_for_unloading = base:StringRequest(request)
		if RS_for_unloading then
			if RS_for_unloading.Count > 0 then
				total_recs_count = total_recs_count + RS_for_unloading.Count
				base_recs_count = base_recs_count + 1
				list_recs_for_unloading[#list_recs_for_unloading + 1] = RS_for_unloading
			end
			Me.monitor:SetCellText(1, base_index-1, '0 / '..RS_for_unloading.Count)
		end
		if not cancel then
			BasesProgress:NextStep()
		end
	end
	write_to_log('unloading_process', 'Выборка завершена. Отобрано записей для экспорта: '..total_recs_count..'. Затрачено времени: '..calculate_the_time_spent(time_start_function, DateTime.Now))
	return base_recs_count, total_recs_count, list_recs_for_unloading
end


function databases_processing(base_recs_count, total_recs_count, list_recs_for_unloading)
	local time_start_function = DateTime.Now
	local root_folder = IO.Path.AddSlash(Me.path.Text)
	Me.label_current_function.Text = 'Производится экспорт данных в xml'
	local BasesProgress = ProgressBar.ProgressBar:new(Me.BasesProgressBar, base_recs_count)
	local TotalProgress = ProgressBar.ProgressBar:new(Me.TotalProgressBar, total_recs_count)
	BasesProgress:InitBar()
	TotalProgress:InitBar()
	
	if IsProgressInterrupted() then
		if (MsgBox('Обнаружен незавершенный процесс экспорта. Возобновить?', IconQuestion + BtnYesNo) == IdYes) then
			ProgressRecover()
		end
	end
	
	local Total_i = 0
	add_data_to_the_monitor(list_recs_for_unloading)
	for index_database, record_set in ipairs(list_recs_for_unloading) do
		Me.label_bases.Text = 'Выгружается база: '..index_database..' из '..base_recs_count
		if cancel then break end
		local start_base_time = DateTime.Now
		local last_time = DateTime.Now
		local SpeedLastTime = DateTime.Now
		local CmdCallIntervalWithFiles = nil
		local base_folder = IO.Path.AddSlash(data_folder..DB2XML.CleanXmlTagName(_G.BasesTable[record_set.Base.Code]))
		IO.Folder.Create(base_folder)
		local BaseXML = XML.DOM.CreateXML(DB2XML.CleanXmlTagName(record_set.Base.Name))
		local Local_i = 0
		local n = ExportFilesNumbers[record_set.Base.Code] or 1
		if ExportedRecordsSysNumbers[record_set.Base.Code] == nil then
			ExportedRecordsSysNumbers[record_set.Base.Code] = table.create(record_set.Count)
		end
		local RecordsPerSecond = 0
		local BaseXML = XML.DOM.CreateXML(DB2XML.CleanXmlTagName(record_set.Base.Name))
		local newNode, newNode2, newNode3 = nil, nil, nil
		
		local row_num, col_num = Me.monitor:Find(record_set.Base.Name, 0, 0)
		if row_num then
			Me.monitor:SetCellText(2, row_num, DateTime.Now:ToString('%c'))
			Me.monitor:SetCellText(3, row_num, '00:00:00')
			Me.monitor:BestFit(-1, Me.monitor.NumberCols-1)
		end
		
		local files_folder = IO.Path.AddSlash(base_folder..'Files')

		for rec in record_set.Records do
			--writefile(log_folder..'databases_processing.txt', 'Base '..rec.Base.Name..' rec SN '..rec.SN)
			local IsExported = (ExportedRecordsSysNumbers[rec.Base.Code][tostring(rec.SN)] ~= nil)
			if ((DateTime.Now - SpeedLastTime).Seconds >= 1) and (Local_i > 0) then
				local remainder = record_set.Count - Local_i
				local TimeSpan = DateTimeSpan()
				TimeSpan.Seconds = math.ceil(remainder / RecordsPerSecond)
				local endingTime = DateTime.Now + TimeSpan
				local TimeRemain = (endingTime - DateTime.Now):ToString('%c')
				Me.exportSpeedLabel.Text = 'Скорость: '..RecordsPerSecond..' записей/сек. Примерно осталось времени: '..TimeRemain
				RecordsPerSecond = 0
				SpeedLastTime = DateTime.Now
			end
			if (DateTime.Now - last_time).Seconds >= CMD_CALL_INTERVAL then
				if not IO.File.Exists(tempCmdFile) then
					writefile(tempCmdFile, '1')
				end
				ShellExecute(tempCmdFile, '', true, 'open', '', 0)
				last_time = DateTime.Now
			end
			if not IsExported then
				newNode = BaseXML:AddNode(_G.BasesTable[record_set.Base.Code])
				newNode:SetAttribute('guid', tostring(rec:GetValue(GUID_FIELD_NUMBER)))
				newNode:SetAttribute('status', tostring(rec:GetValue(STATUS_FIELD_NUMBER)))
				newNode2 = newNode:AddNode(DB2XML.CleanXmlTagName(rec.Base:GetField(0).Name)..'_0'):SetData(rec:GetValue(0))
				for _, field in ipairs(record_set.Base.Fields) do
					local CleanedFieldName = DB2XML.CleanXmlTagName(field.Name)
					if (CleanedFieldName ~= '') then
						CleanedFieldName = CleanedFieldName..'_'..field.Number
					end
					local value = string.trim(tostring(rec:GetValue(field.Number)))
					if (value ~= '') and (CleanedFieldName ~= '') then
						if (field.Type == Field.File) then
							export_a_file(rec, newNode, newNode2, newNode3, field, CleanedFieldName, files_folder)
						elseif (field.Type == Field.DirectLink) or (field.Type == Field.DirectBackLink) or (field.Type == Field.BackLink) or (field.Type == Field.FieldLink) then
							export_a_links(rec, newNode, newNode2, newNode3, field, CleanedFieldName)
						elseif (field.Type == Field.Coded) then
							export_a_dictionary_field(rec, newNode, newNode2, newNode3, field, CleanedFieldName)
						elseif (field.Type == Field.Text or field.Type == Field.Numeric or field.Type == Field.Date  or field.Type == Field.Time) then
							export_a_text_field(rec, newNode, newNode2, newNode3, field, CleanedFieldName)
						end
					end
				end
			end
			if (Local_i > 0) and (Local_i % MAX_XML_RECORDS_TO_COLLECT_GARBAGE == 0) then
				collectgarbage('collect')
			end
			Total_i = Total_i + 1
			Local_i = Local_i + 1
			RecordsPerSecond = RecordsPerSecond + 1
			TotalProgress:NextStep()
			Me.label_recs.Text = 'Обработано записей '..Total_i..' из '..total_recs_count..' во всём банке'
			Me.monitor:SetCellText(1, row_num, Local_i..' / '..record_set.Count)
			Me.monitor:SetCellText(3, row_num, (DateTime.Now - start_base_time):ToString('%c'))
			if (not IsExported) then
				if ((Local_i > 0) and ((Local_i % NODES_PER_XML_FILE == 0) or cancel)) or (Local_i == record_set.Count) then
					BaseXML:WriteXml(base_folder..'part_'..string.format('%06d', n)..'.xml')
					SaveProgress()
					n = n + 1
					ExportFilesNumbers[record_set.Base.Code] = n
					BaseXML = nil
					BaseXML = XML.DOM.CreateXML(DB2XML.CleanXmlTagName(record_set.Base.Name))
					newNode, newNode2, newNode3 = nil, nil, nil
				end
				ExportedRecordsSysNumbers[record_set.Base.Code][tostring(rec.SN)] = Local_i
			end
			if cancel then break end
			local result_of_changig_the_record = change_record_status(rec)
			if (CmdCallIntervalWithFiles ~= nil) then
				CMD_CALL_INTERVAL = CmdCallIntervalWithFiles
				CmdCallIntervalWithFiles = nil
			end
		end
		if not cancel then
			BasesProgress:NextStep()
		end
	end
	if not cancel then
		DeleteSavedProgress()
	end
	Me.exportSpeedLabel.Text = ''
	cancel = false
	ContinueExport = nil
	IO.File.Delete(tempCmdFile)
	Me.close.Enabled = true
	Me.cancel.Enabled = false
	write_to_log('unloading_process', 'Экспорт завершен. Затрачено времени: '..calculate_the_time_spent(time_start_function, DateTime.Now))
	return true
end


function export_a_file(rec, newNode, newNode2, newNode3, field, CleanedFieldName, FilesFolder)
	if (CmdCallIntervalWithFiles == nil) then
		CmdCallIntervalWithFiles = CMD_CALL_INTERVAL
		CMD_CALL_INTERVAL = CMD_CALL_INTERVAL * 2
	end
	local FilesCount = rec:GetValue(field.Number, 0)
	IO.Folder.Create(FilesFolder)
	newNode2 = newNode:AddNode(CleanedFieldName)
	for i = 1, #FilesCount do
		if cancel then break end
		folder_exists(FilesFolder)
		local FileData = rec:GetValue(field.Number, i)
		local FileName = rec:GetValue(field.Number, i, "name"):lower()
		local FileExtension = rec:GetValue(field.Number, i, "ext"):lower()
		local FilePath = FilesFolder..FileName..'.'..FileExtension
		if IO.File.Exists(string.lower(FilePath)) then
			while IO.File.Exists(string.lower(FilePath)) do
				FilePath = FilesFolder..FileName..'_'..IO.Path.GetRandomFileName()..'.'..FileExtension
			end
		end
		writefile(FilePath, FileData)
		newNode3 = newNode2:AddNode("value"):SetData(IO.Path.GetFileName(FilePath))
	end
end


function export_a_links(rec, newNode, newNode2, newNode3, field, CleanedFieldName)
	local isNodeAdded = false
	for _, link in ipairs(field.LinkedBases) do
		local linkedBase = link['Base']
		local RS_LinkedBase = rec:GetValue(field.Number, linkedBase)
 		if RS_LinkedBase.Count > 0 then
		    if not isNodeAdded then
				newNode2 = newNode:AddNode(CleanedFieldName)
				isNodeAdded = true
			end
			for relatedRecord in RS_LinkedBase.Records do
				newNode3 = newNode2:AddNode(_G.BasesTable[linkedBase.Code]):SetData(tostring(relatedRecord:GetValue(GUID_FIELD_NUMBER)))
			end
		end
	end
end


function export_a_dictionary_field(rec, newNode, newNode2, newNode3, field, CleanedFieldName)
	local Code = ''
	if field:TestStatus(Field.Multiple) then
		local Values = rec:GetValue(field.Number, 0)
		newNode2 = newNode:AddNode(CleanedFieldName)
		for ValueIndex, Value in ipairs (Values) do
			local RealFieldValue = ''
			Value = rec:GetValue(field.Number, ValueIndex, true)
			RealFieldValue = DB2XML.CleanStr(tostring(DB2XML.CleanStr(Value)))
			if (RealFieldValue ~= '') then
				newNode3 = newNode2:AddNode('value'):SetData(tostring(DB2XML.CleanStr(RealFieldValue)))
				newNode3:SetAttribute('dictionary_code', tostring(DB2XML.CleanStr(rec:GetValue(field.Number, ValueIndex, false))))
			end
		end
	else
		local RealFieldValue = ''
		local Value = rec:GetValue(field.Number, 1, true)
		local RealFieldValue = DB2XML.CleanStr(tostring(Value))
		if (RealFieldValue ~= '') then
			newNode2 = newNode:AddNode(CleanedFieldName)
			newNode2:SetData(RealFieldValue)
			newNode2:SetAttribute('dictionary_code', tostring(DB2XML.CleanStr(rec:GetValue(field.Number, 1, false))))
		end
	end
end


function export_a_text_field(rec, newNode, newNode2, newNode3, field, CleanedFieldName)
	if field:TestStatus(Field.Multiple) then
		newNode2 = newNode:AddNode(CleanedFieldName)
		local Values = rec:GetValue(field.Number, 0, true)
		for _, Value in ipairs(Values) do
			newNode3 = newNode2:AddNode('value'):SetData(DB2XML.CleanStr(tostring(Value)))
		end
	else
		newNode2 = newNode:AddNode(CleanedFieldName)
		newNode2:SetData(DB2XML.CleanStr(tostring(rec:GetValue(field.Number))))
	end
end


function change_record_status(rec)
	local succes, errMsg = rec:SetValue(STATUS_FIELD_NUMBER, STATUS_EXPORTED)
	if succes then
		if rec:Update() then
			return true
		else
			write_to_log('error', 'Проблема с сохранением изменений записи '..rec.SN..' базы '..rec.Base.Code..': '..errMsg)
			return false
		end
	else
		write_to_log('error', 'Проблема с изменением статуса записи '..rec.SN..' базы '..rec.Base.Code..': '..errMsg)
	end
end


function ExportToXMLPerform( ExportDir)
	local time_start_function = DateTime.Now
	write_to_log('unloading_process', 'Экспорт структуры банка данных')
	local ExportDir = IO.Path.AddSlash(ExportDir)
	for b, CurrentBase in ipairs(Bases) do
		local BaseXML, CurrentBaseName = DB2XML.DatabaseStructureToXML(CurrentBase)
		local TargetDir = IO.Path.AddSlash(ExportDir..'Structure')
		local ok, error = IO.Folder.Create(TargetDir)
		if ok then
			BaseXML:WriteXML(TargetDir..CurrentBase.Number..'_'..CurrentBaseName..'.xml')
		else
			return false, error
		end
	end
	write_to_log('unloading_process', 'Экспорт структуры банка данных завершен. Затрачено времени: '..calculate_the_time_spent(time_start_function, DateTime.Now))
	return true
end


function calculate_the_time_spent(time_start, time_end)
	local time_delta = time_end - time_start
	if time_delta:Format('%D') == '0' then
		return time_delta:ToString('%H ч. %M м. %S с.')
	else
		return time_delta:ToString('%D д. %H ч. %M м. %S с.')
	end
end


function write_to_log(file_name, text_message)
	local FilePath = log_folder..file_name..'.txt'
	local LogString = DateTime.Now:ToString('%c')..': '..text_message..'\r\n'
	
	if IO.Folder.Exists(log_folder) then
		if IO.File.Exists(FilePath) then
			if not appendfile(FilePath, LogString) then
				MsgBox('Проблема с записью в файл "'..FilePath..'"', IconError)
			end
		else
			if not writefile(FilePath, LogString) then
				MsgBox('Проблема с созданием файла "'..FilePath..'"', IconError)
			end
		end
	end
end


function add_value_in_guid_and_status(list_records_with_empty_value, count_base_with_empty_values, count_records_with_empty_values)
	local time_start_function = DateTime.Now
	
	Me.label_current_function.Text = 'Заполнение полей "guid" и "Статус записи"'
	write_to_log('unloading_process', Me.label_current_function.Text)
	
	local SpeedLastTime = DateTime.Now
	local last_time = DateTime.Now

	local BasesProgress = ProgressBar.ProgressBar:new(Me.BasesProgressBar, count_base_with_empty_values)
	local TotalProgress = ProgressBar.ProgressBar:new(Me.TotalProgressBar, count_records_with_empty_values)
	BasesProgress:InitBar()
	TotalProgress:InitBar()
	Total_i = 0
	for currBaseIndex, currBase in ipairs(Bases) do
		if cancel then break end
		local start_base_time = DateTime.Now
		local RecordsPerSecond = 0
		Local_i = 0
		Me.monitor:SetCellText(2, currBaseIndex-1, start_base_time:ToString('%c'))
		Me.monitor:SetCellText(3, currBaseIndex-1, '00:00:00')
		Me.monitor:BestFit(-1, Me.monitor.NumberCols-1)
		
		
		local currBase_is_included_in_the_list_records_with_empty_value = list_records_with_empty_value[currBase.Code]
		if currBase_is_included_in_the_list_records_with_empty_value then
			for rec_index, rec_num in ipairs(list_records_with_empty_value[currBase.Code]) do
				if cancel then break end
				Me.label_bases.Text = 'Обрабатывается база '..currBaseIndex..' из '..count_base_with_empty_values
				Me.label_recs.Text = 'Обработано записей '..Total_i..' из '..count_records_with_empty_values
				
				if ((DateTime.Now - SpeedLastTime).Seconds >= 1) and (Local_i > 0) then
					local remainder = #list_records_with_empty_value[currBase.Code] - Local_i
					local TimeSpan = DateTimeSpan()
					TimeSpan.Seconds = math.ceil(remainder / RecordsPerSecond)
					local endingTime = DateTime.Now + TimeSpan
					local TimeRemain = (endingTime - DateTime.Now):ToString('%X')
					Me.exportSpeedLabel.Text = 'Скорость: '..RecordsPerSecond..' записей/сек. Примерно осталось времени: '..TimeRemain
					RecordsPerSecond = 0
					SpeedLastTime = DateTime.Now
				end
				if (DateTime.Now - last_time).Seconds >= CMD_CALL_INTERVAL then
					if not IO.File.Exists(tempCmdFile) then
						writefile(tempCmdFile, '1')
					end
					ShellExecute(tempCmdFile, '', true, 'open', '', 0)
					last_time = DateTime.Now
				end
				
				local record = currBase:GetRecord(rec_num)
				if record then
					if record:GetValue(STATUS_FIELD_NUMBER) == '' then
						add_value_status, errors = record:SetValue(STATUS_FIELD_NUMBER, STATUS_NEW)
						if add_value_status then
							add_value_status = record:Update()
						else
							write_to_log('unloading_process', 'Ошибка: '..tostring(errors)..'. Запись : '..rec_num..' база: '..currBase.Code)
							return false
						end
					end
					if record:GetValue(GUID_FIELD_NUMBER) == '' then
						local prefix = get_department_code()
						if prefix then
							local guid = prefix..'-'..CreateGuid(true)
							add_value_status, errors = record:SetValue(GUID_FIELD_NUMBER, guid)
							if add_value_status then
								add_value_status = record:Update()
							else
								write_to_log('unloading_process', 'Ошибка: '..tostring(errors)..'. Запись : '..rec_num..' база: '..currBase.Code)
								return false
							end
						else
							write_to_log('unloading_process', 'Проблема с получением префикса для guid')
						end
					end
				else
					write_to_log('unloading_process', 'Запись с номером: '..rec_num..' в базе: '..currBase.Code..' не найдена')
				end
				TotalProgress:NextStep()
				Total_i = Total_i + 1
				Local_i = Local_i + 1
				RecordsPerSecond = RecordsPerSecond + 1
				Me.label_recs.Text = 'Обработано записей '..Total_i..' из '..count_records_with_empty_values..' во всём банке'
				Me.monitor:SetCellText(1, currBaseIndex-1, Local_i..' / '..#list_records_with_empty_value[currBase.Code])
				Me.monitor:SetCellText(3, currBaseIndex-1, (DateTime.Now - start_base_time):ToString('%c'))
			end
			if not cancel then
				BasesProgress:NextStep()
			end
		end
		if not cancel then
			DeleteSavedProgress()
		end
	end
	write_to_log('unloading_process', 'Заполнение завершено. Затрачено времени: '..calculate_the_time_spent(time_start_function, DateTime.Now))
	return true
end


function get_department_from_voc()
	local VocabRecs = CroApp.GetBank():GetVocabulary():StringRequest(STRING_REQUEST_ALMAZ)
	local department = ''
	if not VocabRecs then
		return get_department_from_voc_titanium()
	end
	if VocabRecs.Count == 1 then
		local VocabRec = VocabRecs:GetRecordByIndex(1)
		department = VocabRec:GetValue(1)
	else
		write_to_log('error', 'Проблема с получением кода органа из словаря "Сведения о регистрации"')
	end
	return department
end


function get_department_from_voc_titanium()
	local VocabRecs = CroApp.GetBank():GetVocabulary():StringRequest(STRING_REQUEST_TITANIUM)
	local department = ''
	if not VocabRecs then
		return department
	end
	if VocabRecs.Count == 1 then
		local VocabRec = VocabRecs:GetRecordByIndex(1)
		department = VocabRec:GetValue(20)
	else
		write_to_log('error', 'Проблема с получением кода органа из словаря "!Параметры"')
	end
	return department
end


function is_almaz_department(value)
	-- 230001001804
	return value:match('%d%d%d%d%d%d%d%d%d%d%d%d') ~= ''
end


function is_titanium_department(value)
	-- 7000-100003000503
	return value:match('%d%d%d%d-%d%d%d%d%d%d%d%d%d%d%d%d') ~= ''
end


function get_department_code()
	local code = get_department_from_voc()
	
	if code ~= '' then
		--if type(tonumber(code)) ~= 'number' then
		if not is_almaz_department(code) and not is_titanium_department(code) then
			MsgBox('В параметрах словарного банка содержатся некорректные значения или они не заполнены!\nНеобходимо произвести процедуру регистрации', IconError)
			CroApp.GetBank():OpenForm('reg', nil, Me, args)
			return get_department_from_voc()
		end
	else
		MsgBox('Необходимо выполнить регистрацию системы. Система работает некорректно!\nПосле регистрации процесс выгрузки продолжится.', IconInformation)
		CroApp.GetBank():OpenForm('reg', nil, Me, args)
		return get_department_from_voc()
	end
	return code
end


function timeH_Click( control, event )
	local new_status = 5
	if MsgBox('Изменить статус записей банка данных на "'..new_status..'"?', BtnYesNo) == IdYes then
		local count_of_records = 0
		Formula.SetGlobal ('disabled_formula', true)
		for ind_base, base in ipairs(CroApp.GetBank().Bases) do
			for rec in base.RecordSet.Records do
			--	count_of_records = count_of_records + 1
				rec:SetValue(STATUS_FIELD_NUMBER, new_status)
				rec:Update()
			end
		end
		Formula.SetGlobal ('disabled_formula', false)
		MsgBox('Работа завершена.\nОбработано записей: '..count_of_records..'.')
	else
		MsgBox('Отменено пользователем.')
	end
end


function change_folder_Click( control, event )
	local new_destination = BrowseForFolder('Укажите каталог для выгрузки')
	if new_destination then
		Me.path.Text = IO.Path.AddSlash(new_destination)..CroApp.GetBank().Name
	end
end


function path_Click( control, event ) control.Focused = true end


function check_mnemo_codes(Bases)
	local status = true
	local BasesTable = {}
	local index = 0
	local currBaseCode = ''
	for _, currBase in pairs (Bases) do
		BasesTable[currBase.Code] = currBase.Code
	end
	for key, currBaseCode in pairs (BasesTable) do
		if string.scount(currBaseCode, '$') > 0 then
			for i = 1, string.scount(currBaseCode, '$') do
				index = string.index(currBaseCode, '$', 1)
				currBaseCode = string.delete(string.insert(currBaseCode, index, 'S'), index + 1, 1)
			end
			local FindedKey = table.getkey(BasesTable, currBaseCode)
			local ABC = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
			local ABC_index_i = 0
			local ABC_index_j = 1
			while FindedKey ~= nil do
				ABC_index_i = ABC_index_i + 1
				currBaseCode = string.sub(ABC, ABC_index_j, ABC_index_j)..string.sub(ABC, ABC_index_i, ABC_index_i)
				FindedKey = table.getkey(BasesTable, currBaseCode)
				if ABC_index_i >= string.len(ABC) then
					if ABC_index_j >= string.len(ABC) then
						MsgBox('Не удалось подобрать уникальный мнемокод')
						status = false
						break
					end
					ABC_index_i = 0
					ABC_index_j = ABC_index_j + 1
				end
			end
			BasesTable[key] = currBaseCode
		end
	end
	_G.BasesTable = BasesTable
	return status
end


function checking_presence_fields_in_database( )
	local time_start_function = DateTime.Now			
	write_to_log('unloading_process', 'Проверка наличия и корректности полей "guid" и "Статус записи" в банке данных')
	local BasesProgress = ProgressBar.ProgressBar:new(Me.BasesProgressBar, #Bases)
	BasesProgress:InitBar()
	local list_of_fields_for_correction = {}
	local fields_numbers = {[STATUS_FIELD_NUMBER]='Статус записи', [GUID_FIELD_NUMBER]='guid'}
	local need_to_correct_the_name_of_fields = false
	for _, base in ipairs(Bases) do
		Me.label_bases.Text = 'Производится проверка наличия полей в базе '..base.Code
		for field_number, field_name in pairs (fields_numbers) do
			local existing_field = base:GetField(field_number)
			if not existing_field then
				create_field(field_number, base)
			else
				if existing_field.Name:lower() ~= field_name:lower() then
					need_to_correct_the_name_of_fields = true	--Если в структуре обнаружены поля с номером STATUS_FIELD_NUMBER или GUID_FIELD_NUMBER и их названия не совпадают с теми, которые нам нужны -> добавляем их в список, и потом выведем этот список в сообщение и запишем в файл.
					if list_of_fields_for_correction[base.Name] then
						list_of_fields_for_correction[base.Name][#list_of_fields_for_correction[base.Name] + 1] = existing_field.Name
					else
						list_of_fields_for_correction[base.Name] = {}
						list_of_fields_for_correction[base.Name][#list_of_fields_for_correction[base.Name] + 1] = existing_field.Name
					end
					write_to_log('unloading_process', 'В банке данных обнаружено поле "'..existing_field.Name..'" номер которого совпадает с номером: '..field_number)
				end
			end
		end
		if not cancel then
			BasesProgress:NextStep()
		end
	end
	write_to_log('unloading_process', 'Проверка наличия и корректности полей завершена. Затрачено времени '..calculate_the_time_spent(time_start_function, DateTime.Now))
	return need_to_correct_the_name_of_fields, list_of_fields_for_correction
end


function create_field(fieldNum, base)
	local time_start_function = DateTime.Now			

	
	local field_params = {
	    [STATUS_FIELD_NUMBER] = {
			['fieldName'] = 'Статус записи',
			['fieldType'] = 'Ц',
			['fieldLength'] = 1,
			--['fieldStatus'] = '64'
			['fieldStatus'] = 'НК'
		},
		[GUID_FIELD_NUMBER] = { 
			['fieldName'] = 'guid',
			['fieldType'] = 'Т',
			['fieldLength'] = 100,
			--['fieldStatus'] = '64',
			['fieldStatus'] = 'НК',
		},
	}
	--local formula = Formula(baseNum, fieldNum, fieldName, fieldType, fieldLength, fieldStatus)
	local formula = Formula(baseNum)
	formula:SetValue('baseNum', base.Number)
	formula:SetValue('fieldNum', fieldNum)
	formula:SetValue('fieldName', field_params[fieldNum]['fieldName'])
	formula:SetValue('fieldType', field_params[fieldNum]['fieldType'])
	formula:SetValue('fieldLength', field_params[fieldNum]['fieldLength'])
	formula:SetValue('fieldStatus', field_params[fieldNum]['fieldStatus'])
	formula:ExecuteString([[@@res := CREATEFIELD(@@baseNum,@@fieldNum,@@fieldName,@@fieldType,@@fieldLength,@@fieldStatus,@@vocNum)]])
	res = tostring(formula:GetValue('res'))
	if res == '36' then
		write_to_log('unloading_process', 'В базу: '..base.Code..' добавлено поле: '..field_params[fieldNum]['fieldName']..'. Затрачено времени: '..calculate_the_time_spent(time_start_function, DateTime.Now))
	end
end


function generating_a_message(list_of_fields_for_correction)
	local str_msg_for_user = 'В структуре банка необходимо изменить номера указанных полей:\n'
	for key, val in pairs(list_of_fields_for_correction) do
		str_msg_for_user = str_msg_for_user..'\n- база "'..key..'":\n'
		for _, ifield in ipairs(list_of_fields_for_correction[key]) do
			if _ == #list_of_fields_for_correction[key] then
				str_msg_for_user = str_msg_for_user..'\t- "'..ifield..'"\n'
			else
				str_msg_for_user = str_msg_for_user..'\t- "'..ifield..'",\n'
			end
		end
	end
	str_msg_for_user = str_msg_for_user..'\nНомера "'..STATUS_FIELD_NUMBER..'" и "'..GUID_FIELD_NUMBER..'" использовать нельзя.'
	write_to_log('list_of_fields_for_correction', str_msg_for_user)
	MsgBox(str_msg_for_user..'\nСписок полей сохранен в файл: '..log_folder..'list_of_fields_for_correction.txt')
end


function search_for_empty_values()
	local time_start_function = DateTime.Now
	local last_time = DateTime.Now
	Me.label_current_function.Text = 'Поиск записей с пустыми значениями "guid" и "Статус записи"'
	write_to_log('unloading_process', Me.label_current_function.Text)
	local there_are_some_records_with_empty_values = false
	local count_base_with_empty_values = 0
	local count_records_with_empty_values = 0
	local list_records_with_empty_value = {}
	for _, base in ipairs (Bases) do
		if cancel then break end
		Me.label_bases.Text = 'Обрабатывается база '..base.Name
		if (DateTime.Now - last_time).Seconds >= CMD_CALL_INTERVAL then
			if not IO.File.Exists(tempCmdFile) then
				writefile(tempCmdFile, '1')
			end
			ShellExecute(tempCmdFile, '', true, 'open', '', 0)
			last_time = DateTime.Now
		end
		local RS_with_empty_values = CroApp.GetBank():StringRequest('ОТ '..base.Code..' '..STATUS_FIELD_NUMBER..' РП ИЛИ '..GUID_FIELD_NUMBER..' РП')
		if RS_with_empty_values.Count ~= 0 then
			local row_num, col_num = Me.monitor:Find(base.Name, 0, 0)
			if row_num then
				Me.monitor:SetCellText(1, row_num, '0 / '..RS_with_empty_values.Count)
				Me.monitor:BestFit(-1, Me.monitor.NumberCols-1)
			end
			count_base_with_empty_values = count_base_with_empty_values + 1
			count_records_with_empty_values = count_records_with_empty_values + RS_with_empty_values.Count
			list_records_with_empty_value[base.Code] = RS_with_empty_values:ToTable()
			there_are_some_records_with_empty_values = true
		end
	end
	write_to_log('unloading_process', 'Проверка завершена. Затрачено времени: '..calculate_the_time_spent(time_start_function, DateTime.Now))
	return there_are_some_records_with_empty_values, list_records_with_empty_value, count_base_with_empty_values, count_records_with_empty_values
end


function timeM_Click( control, event )
	if MsgBox('Удалить поля с номерами "'..STATUS_FIELD_NUMBER..'" и "'..GUID_FIELD_NUMBER..'" во всем банке?', BtnYesNo + IconQuestion) == IdYes then
		local Bases = CroApp.GetBank().Bases
		for _, num in pairs({STATUS_FIELD_NUMBER, GUID_FIELD_NUMBER}) do
			for _, base in ipairs(Bases) do
				local formula = Formula(baseNum, fieldNum)
				formula:SetValue('baseNum', base.Number)
				formula:SetValue('fieldNum', num)
				formula:ExecuteString([[@@res := DELETEFIELD(@@baseNum, @@fieldNum)]])
			end
		end
		MsgBox('Поля удалены!', IconInformation)
	end
end


function run_Click( control, event )
	Me.run.Enabled, Me.close.Enabled, Me.change_folder.Enabled = false, false, false
	Me.cancel.Enabled = true
	local time_start_program = (DateTime.Now)
	
	root_folder = IO.Path.AddSlash(Me.path.Text)
	log_folder = IO.Path.AddSlash(root_folder..'Log')
	IO.Folder.Create(log_folder)
	data_folder = IO.Path.AddSlash(root_folder..'Data')
	IO.Folder.Create(data_folder)
	
	write_to_log('unloading_process', '-={ Запуск выгрузчика. Версия выгрузчика: '..VERSION..', пользователь:'..CroApp.UserName..'}=-')
	
	local department_code = get_department_code()
	if department_code == '' then
		MsgBox('Не удалось определить код подразделения. Продолжение невозможно.', IconError)
		write_to_log('unloading_process', 'Не удалось определить код подразделения.')
	else
		if folder_exists(root_folder) then
			write_to_log('unloading_process', 'Код органа: '..department_code)
			Formula.SetGlobal('disabled_formula', true)
			local need_to_correct_the_name_of_fields, list_of_fields_for_correction = checking_presence_fields_in_database( )
			if need_to_correct_the_name_of_fields then
				generating_a_message(list_of_fields_for_correction)
				cancel = true
			else
				local there_are_some_records_with_empty_values, list_records_with_empty_value, count_base_with_empty_values, count_records_with_empty_values = search_for_empty_values()
				if there_are_some_records_with_empty_values then
					write_to_log('unloading_process', 'В банке содержатся записи с пустыми значениями полей "guid" и/или "Статус записи"')
					add_value_in_guid_and_status(list_records_with_empty_value, count_base_with_empty_values, count_records_with_empty_values)
				end
				if not cancel then
					local base_recs_count, total_recs_count, list_recs_for_unloading = prepare_records_for_unloading()
					if total_recs_count == 0 then
						MsgBox('В банке данных нет записей для экспорта.', BtnOk + IconInformation)
						cancel = true
					else
						if MsgBox('Отобрано '..total_recs_count..' записей. Экспортировать данные?', BtnYesNo + IconQuestion) == IdYes then
							export_data(base_recs_count, total_recs_count, list_recs_for_unloading)
							local time_delta = (DateTime.Now - time_start_program)
							write_to_log('unloading_process', '-={ Выгрузка успешно завершена. Затрачено времени: '..calculate_the_time_spent(time_start_program, DateTime.Now)..' }=-')
						end
					end
					write_to_log('unloading_process', '-={Работа программы завершена. Затрачено времени: '..calculate_the_time_spent(time_start_program, DateTime.Now)..' }=-')
				end
			end
			Formula.SetGlobal('disabled_formula', false)	--Создаем формулу для того, чтобы иметь возможность отключить пользовательские формулы на время выгрузки
		else
			MsgBox(root_folder..'\nЭтот путь не существует.\nПроверьте правильность указания пути и повторите попытку.', IconWarning)
			cancel = true
		end
	end
	
	MsgBox('Работа программы завершена. Затрачено времени: '..calculate_the_time_spent(time_start_program, DateTime.Now))
	Me.cancel.Enabled = false
	Me.run.Enabled, Me.close.Enabled, Me.change_folder.Enabled = true, true, true
	
end