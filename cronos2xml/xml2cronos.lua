--[[
	--------------------------- Changelog ---------------------------
    1.21.3 (16.09.2021)
- Добавлен ProgressWriter для сохранения прогресса загрузки и исключения загрузки 
  дублирующих GUID записией. По умолчанию хранятся в каталоге log и имеют расширение *.ps.
- Добавлен RelationsWriter для сохранения связок guid записей, между которыми 
  должны быть установлены связи. В процессе загрузки связки пишутся порциями в 
  файл и после успешного импорта всех данных считываются в переменную и создаются
  связи. После этого все временные файлы удаляются. По умолчанию хранятся в каталоге
  log и имеют расширение *.rel.
  
    1.21.4 (24.09.2021)
- Исключена проверка статуса записи при загрузке - каждая запись, поступающая на вход,
  проверяется в БД по guid.
  
    1.21.5 (26.11.2021)
- Исправлена ошибка визуализации текущей даты.

    1.21.6 (28.12.2021)
- Скрипты DB2XML и ProgressBar перенесены в скрипты банка.

    1.22.1 (24.01.2022)
- Исправлена ошибка загрузки файлов-приложений.
- Добавлена обработка ошибки получения списка имен баз из XML.
]]--


local DB2XML = require('DB2XML')
local ProgressBar = require('ProgressBar')

local EDITION = 1
local SUBVERSION = 22
local RELEASE = 1
local VERSION = EDITION..'.'..SUBVERSION..'.'..RELEASE

local MAX_XML_RECORDS_TO_COLLECT_GARBAGE = 1000
local CMD_CALL_INTERVAL = 1
local FORM_TITLE = 'Импорт данных (ver.'..VERSION..') - '..CroApp.UserName

local GUID_FIELD_NUMBER = 999

local STATUS_EXPORTED = 0
local STATUS_NEW = 1
local STATUS_MODIFIED = 2

local ExportedRecordsSysNumbers = {}
local ExportFilesNumbers = {}

local cancel = false	--	Статус данной переменной проверяется на каждой итерации во всех циклах for. В случае нажатия кнопки 'Отмена' значение этой переменной изменятеся на true и цикл прекращается

local CurrentBank = CroApp.GetBank()
local Bases = CurrentBank.Bases

local tempCmdFile = IO.Path.GetTempFileName()
tempCmdFile = IO.Path.ChangeExt(tempCmdFile, 'cmd')


local tmp_file = DateTime.Now:ToString('%x')..'.cmd'

local main_folder = ''
local log_folder = ''
local data_folder = ''
local structure_folder = ''
local progress_folder = ''


local ProgressWriterInstance = nil
local RelationsWriterInstance = nil


function extended(child, parent)
	setmetatable(child, {__index = parent})
end


ProgressWriter = {}

function ProgressWriter:new( LogPath, RecordsPerFile, FileNamePattern )

    local RECORDS_PER_FILE = 5000
	local TEXT_DELIMITER = '&&'
	local KEY_DELIMITER = '->'
	
	local obj = {}
	    obj.LogPath = IO.Path.AddSlash(LogPath)
		obj.RecordsPerFile = RecordsPerFile or RECORDS_PER_FILE
		obj.CurrentFileNumber = 1
		obj.CurrentRecordNumber = 1
		obj.FileNamePattern = FileNamePattern or '_GuidsList_%d%'
		obj.FileExtention = 'ps'
		obj.CurrentFileName = ''
		obj.IsEnabled = true
		obj.LogFiles = {}
	
	
	function obj:Init()
		return self:CreateLogPath(self.LogPath)
	end
	
	
	function obj:CreateLogPath(LogPath)
		while true do
			if not IO.Folder.Exists(LogPath) then
				local success, err = IO.Folder.Create(LogPath)
				if not success then
				    local answer = MsgBox('Невозможно создать каталог сохранения прогресса: '..err..'. Восстановление работы в случае прерывания процесса с места остановки будет невозможно. Повторить попытку?', BtnOkCancel, IconError)
					if answer == IdCancel then
						self.IsEnabled = false
						return false
					end
				end
			else
				return true
			end
		end
	end
	
	
	function obj:GetActualFileName()
		if self.CurrentFileName ~= '' then
			if self.CurrentRecordNumber < self.RecordsPerFile then
				return self.CurrentFileName
			end
			
			self.CurrentFileNumber = self.CurrentFileNumber + 1
			self.CurrentRecordNumber = 1
		end
		
		local NumberSuffix = string.format('%06d', self.CurrentFileNumber)
		self.CurrentFileName = self.FileNamePattern:swap('%d%', NumberSuffix)..'.'..self.FileExtention
		return self.CurrentFileName
	end
	
	
	function obj:WriteStringToFile( FilePath, ... )
		local arg = {...}
		
		local MemoryString = table.concat(arg[1], TEXT_DELIMITER)..'\r\n'
	
		if IO.File.Exists(FilePath) then
			appendfile(FilePath, MemoryString)
			self.CurrentRecordNumber = self.CurrentRecordNumber + 1
		else
			writefile(FilePath, MemoryString)
		end
	end
	
	
	function obj:SplitDataRow( DataRow )
		return DataRow
	end
	
	
	function obj:IsInterrupted()
		local LogFiles = {}
		local dirs, files = IO.Folder.DirsAndFiles(self.LogPath)
		if files then
			for _, file in ipairs(files) do
				local CurrentFile = self.LogPath..file
				if IO.Path.GetExt(CurrentFile) == self.FileExtention then
					table.insert(LogFiles, CurrentFile)
				end
			end
		end
		return #LogFiles > 0, LogFiles
	end
	
	
	function obj:Save(...)
		if not self.IsEnabled then
			return
		end
		
		local FilePath = self.LogPath..self:GetActualFileName()
		self:WriteStringToFile( FilePath, {...} )
		table.insert(self.LogFiles, FilePath)
	end
	
	
	function obj:Recover()
		if not self.IsEnabled then
			return {}
		end
		
		local progress = {}
		local length = 0
		local IsInterrupted, LogFiles = self:IsInterrupted()
		if IsInterrupted then
			for _, file in ipairs(LogFiles) do
				for row in io.lines(file) do
					local RowItems = row:split(TEXT_DELIMITER)
					if #RowItems == 1 then
						table.insert(progress, self:SplitDataRow(RowItems[1]))
					elseif #RowItems == 2 then
						progress[RowItems[1]] = self:SplitDataRow(RowItems[2])
					else
						local key = table.remove(RowItems, 1)
						local key_splitted = key:split(KEY_DELIMITER)
						if #key_splitted > 1 then
							local data = {}
							data[key_splitted[2]] = self:SplitDataRow(RowItems)
							progress[key_splitted[1]] = data
						else
							progress[key] = self:SplitDataRow(RowItems)
						end
					end
					length = length + 1
				end
			end
		end
		
		self.LogFiles = LogFiles
		return progress, length
	end
	
	
	function obj:Delete()
		local NotRemovedFiles = {}
		for _, file in ipairs(self.LogFiles) do
			if not IO.File.Delete(file) then
				table.insert(NotRemovedFiles, file)
			end
		end
		return #NotRemovedFiles == 0, NotRemovedFiles
	end
	
	
	setmetatable(obj, self)
	self.__index = self
	return obj
	
end



RelationsWriter = {}
extended(RelationsWriter, ProgressWriter)
function RelationsWriter:new( LogPath, RecordsPerFile, FileNamePattern )

	local RECORDS_PER_FILE = 5000
	local SN_GUID_DELIMITER = '#'
	local KEY_DELIMITER = '->'
	local TEXT_DELIMITER = '&&'

	local obj = ProgressWriter:new(LogPath, RecordsPerFile, FileNamePattern)
		obj.FileExtention = 'rel'
		
		
	function obj:SplitDataRow( DataRow )
		local RelData = {}
		for _, DataString in ipairs(DataRow) do
			table.insert(RelData, DataString:split(SN_GUID_DELIMITER))
		end
		return RelData
	end
	
	
	function obj:Save( ... )
		if not self.IsEnabled then
			return
		end
		
		local arg = {...}
		
		local field_number = arg[1]
		local record_1 = arg[2]..SN_GUID_DELIMITER..arg[3]
		local record_2 = arg[4]..SN_GUID_DELIMITER..arg[5]
		
		local FilePath = self.LogPath..self:GetActualFileName()
		
		self:WriteStringToFile(FilePath, {CreateGuid()..KEY_DELIMITER..field_number, record_1, record_2})
		
		table.insert(self.LogFiles, FilePath)
	end

	
	return obj
end


function create_table(monitor, headers)
	monitor.NumberCols = #headers-1
	local col_num = -1
	for _, header in ipairs(headers) do
		Me.monitor:SetCellText(col_num, -1, header)
		col_num = col_num + 1
	end
	Me.monitor:RowBestFit(-1, Me.monitor.NumberRows-1)
	Me.monitor:BestFit(-1, Me.monitor.NumberCols-1)
end


function add_data_to_the_monitor(xml_files)
	Me.monitor.Visible = false
	clear_the_monitor()
	for db_mnemo, files in pairs (xml_files) do
		Me.monitor:AppendRow()
		Me.monitor:SetCellText(-1, Me.monitor.NumberRows-1, db_mnemo)
		local db_name_in_bank = CurrentBank:GetBase(db_mnemo).Name
		if db_name_in_bank then
			Me.monitor:SetCellText(0, Me.monitor.NumberRows-1, db_name_in_bank)
		else
			Me.monitor:SetCellText(0, Me.monitor.NumberRows-1, 'С таким мнемокодом таблиц нет')
		end
		if files then
			Me.monitor:SetCellText(1, Me.monitor.NumberRows-1, '0 / '..#files)
		else
			Me.monitor:SetCellText(1, Me.monitor.NumberRows-1, '0 / 0')
		end
		Me.monitor:SetCellTextAlign(0, Me.monitor.NumberRows-1, ContentAlignment.MiddleLeft)
	end
	
	Me.monitor:RowBestFit(-1, Me.monitor.NumberRows-1)
	Me.monitor:BestFit(-1, Me.monitor.NumberCols-1)
	Me.monitor.Visible = true
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


function collect_names_of_bases()
	write_to_log('processed', 'Вызов функции обработки файлов структуры.')
	local last_time = DateTime.Now
	local root_elements = {}
	local folders, files = IO.Folder.DirsAndFiles(structure_folder)
	if folders then
		for indx, file in ipairs(files) do
			if cancel then break end
			if (DateTime.Now - last_time).Seconds >= CMD_CALL_INTERVAL then last_time = run_cmd_file() end
			write_to_log('processed', 'Обработка файла "'..file..'"')
			local base_name = string.delete(string.delete(file, 1, string.find(file, '_')), -4, -1)
			local dom, err = XML.DOM.ParseFile(structure_folder..file)
			if err then
				MsgBox('Ошибка разбора структуры БД: '..err..'.')
				return 
			end
			local db_mnemo = dom'$a'.db_mnemo
			root_elements[db_mnemo] = base_name
		end
	end
	return root_elements
end


function collect_xml_files( root_elements )
	local last_time = DateTime.Now
	local xml_files = {}
	local total_count_of_files = 0
	for db_mnemo, db_name in pairs(root_elements) do
		if cancel then break end
		if (DateTime.Now - last_time).Seconds >= CMD_CALL_INTERVAL then last_time = run_cmd_file() end
		local xml_data_files = get_xml_data_files(data_folder, db_mnemo, db_name)
		if #xml_data_files > 0 then
			xml_files[db_mnemo] = xml_data_files
			total_count_of_files = total_count_of_files + #xml_data_files
		end
	end
	return xml_files, total_count_of_files
end


function get_xml_data_files(data_folder, db_mnemo, element)
	local last_time = DateTime.Now
	local folders, files = IO.Folder.DirsAndFiles(data_folder..db_mnemo)
	local xml_files = {}
	if folders then
		for _, file in ipairs(files) do	
			if cancel then break end
			if (DateTime.Now - last_time).Seconds >= CMD_CALL_INTERVAL then last_time = run_cmd_file() end
			table.insert(xml_files, file)
		end
	end
	return xml_files
end


function length(value)
	local len = 0
	if type(value) == 'table' then
		for key, value in pairs(value) do
			len = len + 1
		end
	end
	return len
end


function create_records(xml_files, root_elements, total_count_of_bases, total_count_of_files)
	write_to_log('processed', 'Вызов функции добавления записей в банк данных.')
	
	local last_time = DateTime.Now
	local BasesProgress = ProgressBar.ProgressBar:new(Me.BasesProgressBar, total_count_of_bases)
	local TotalProgress = ProgressBar.ProgressBar:new(Me.TotalProgressBar, total_count_of_files)
	BasesProgress:InitBar()
	TotalProgress:InitBar()
	
	write_to_log('processed', 'Попытка восстановления прогресса из каталога "'..ProgressWriterInstance.LogPath..'"...')
	local guid_sn, guids_count = ProgressWriterInstance:Recover()
	if guids_count > 0 then
		write_to_log('processed', 'Сохраненный прогресс восстановлен. Всего записей - '..#guid_sn..'.')
	else
		write_to_log('processed', 'Сохраненный прогресс не найден.')
	end
	
	local base_i = 1
	local files_i = 1
	for db_mnemo, files in pairs(xml_files) do
--		if db_mnemo == 'AA' then
		if cancel then break end
		local time_start_base_processing = DateTime.Now
		local row_num, col_num = Me.monitor:Find(CurrentBank:GetBase(db_mnemo).Name, 0, 0)
		if row_num then
			Me.monitor:SetCellText(2, row_num, time_start_base_processing:ToString('%c'))
			Me.monitor:SetCellText(3, row_num, '00:00:00')
			Me.monitor:BestFit(-1, Me.monitor.NumberCols-1)
		end
		
		if files then
			local DataBaseDataDir = IO.Path.AddSlash(data_folder..db_mnemo)
			
			for indx_file, file in ipairs(files) do
				if cancel then break end
				
				local xml_dom, _error = XML.DOM.ParseFile(DataBaseDataDir..file)
				
				if (not xml_dom) then
					write_to_log('errors', 'Ошибка обработки файла '..file..'. '..tostring(_error))
					
				else
					write_to_log('processed', 'Обработка файла '..file..' базы '..db_mnemo)
					local base = CurrentBank:GetBase(db_mnemo)
					local nodes = xml_dom[root_elements[db_mnemo]]'$c'
					
					for _, node in ipairs(nodes) do
						if cancel then break end
						local guid_value = node'$a'.guid
						
						if not guid_sn[guid_value] then  -- Проверяем, не выгружен ли GUID
							
							--[[
							local status = node'$a'.status
							if status == STATUS_MODIFIED then		--Если статус записи равняется 2 значит запись ранее уже выгружалась. В этом случае есть смысл искать ее. Иначе просто создаем новую запись.
								rec = get_record(db_mnemo, guid_value)
							end
							]]--
							local rec = get_record(db_mnemo, guid_value)
							
							if not rec then
								rec = Record(base)
								base:AddRecord(rec)
							end
							
							for _, element in ipairs(node'$c') do		--В последствии при построении связей между записями будем напрямую получать системный номер по guid-у
								if cancel then break end
								if (DateTime.Now - last_time).Seconds >= CMD_CALL_INTERVAL then last_time = run_cmd_file() end
								
								local field_name_number = string.delete(string.field(element:ToString(), ">", 1), 1, 1)
								if (not string.ends(field_name_number, "/")) then
									local field_number = get_field_number(field_name_number)
									local field_name = get_field_name(field_name_number)
									local field_values = get_field_values(element)
									local field_type = base:GetField(field_number).Type
									
									if (Field.Numeric <= field_type) and (field_type <= Field.Time) then
										if not add_data_to_simple_field(rec, field_number, field_name, field_values) then
											MsgBox('Проблема с добавлением данных в банк. Подробности записаны в log\\errors', IconError)
										end
										
									elseif field_type == Field.File then
										if not add_file_in_database(db_mnemo, rec, field_number, field_name, field_values) then
											MsgBox('Проблема с загрузкой файла в банк. Подробности записаны в log\\errors', IconError)
										end
										
									elseif ((Field.DirectLink <= field_type) and (field_type <= Field.DirectBackLink)) or (field_type == Field.FieldLink) then
									
										for _, value in ipairs(field_values) do
											local mnemo, guid = value[1], value[2]
											RelationsWriterInstance:Save(field_number, db_mnemo, guid_value, mnemo, guid)
										end
									end
									
								else
									write_to_log('errors', 'file_name: '..file..' '..field_name_number..' - пустой тег')
								end
								
							end
							
							if row_num then
								Me.monitor:SetCellText(3, row_num, (DateTime.Now-time_start_base_processing):ToString('%c'))
							--	Me.monitor:BestFit(-1, Me.monitor.NumberCols-1)
							end
							
							guid_sn[guid_value] = rec.SN				--Здесь сохраняем в таблицу соотвествие системных номеров созданных записей их guid-ам.
							ProgressWriterInstance:Save(guid_value, rec.SN)
							
						end
					end
				end
				
				if row_num then
					Me.monitor:SetCellText(1, row_num, indx_file..' / '..#files)
				end
				Me.label_recs.Text = 'Обработано файлов '..files_i..' из '..total_count_of_files
				files_i = files_i + 1
				TotalProgress:NextStep()
			end
		else
			write_to_log('errors', 'Каталог базы "'..db_mnemo..'" пуст.')
		end
		Me.label_bases.Text = 'Обработано баз '..base_i..' из '..total_count_of_bases
		base_i = base_i + 1
		BasesProgress:NextStep()
--	end
	end
	return guid_sn
end


function create_links(xml_files, root_elements, total_count_of_bases, total_count_of_files, guid_sn)
	write_to_log('processed', 'Вызов функции создания связей в банке данных')
	local last_time = DateTime.Now
	--add_data_to_the_monitor(xml_files)
	
	write_to_log('processed', 'Поиск дампа связей объектов в каталоге "'..RelationsWriterInstance.LogPath..'"...')
	local relations, relations_count = RelationsWriterInstance:Recover()
	
	if not relations then
		write_to_log('processed', 'Дамп не найден. Нет данных для установления связей.')
		return
	end
	
	write_to_log('processed', 'Обнаружен дамп. Связей для установления - '..relations_count..'.')
	
	local TotalProgress = ProgressBar.ProgressBar:new(Me.TotalProgressBar, relations_count)
	TotalProgress:InitBar()
	
	Me.label_recs.Text = [[Построение связей между объектами...]]
	
	Me.monitor:AppendRow()
	
	local row_num = Me.monitor.NumberRows - 1
	local time_start_base_processing = DateTime.Now
	
	Me.monitor:SetCellText(0, row_num, 'Связи объектов')
	Me.monitor:SetCellText(1, row_num, '0 / '..relations_count)
	Me.monitor:SetCellText(2, row_num, time_start_base_processing:ToString('%c'))
	Me.monitor:SetCellText(3, row_num, '00:00:00')
	Me.monitor:RowBestFit(-1, row_num)
	Me.monitor:BestFit(-1, row_num)
	
	local relation_i = 0
	
	for _, RelationsData in pairs(relations) do
	
		if cancel then break end
		if (DateTime.Now - last_time).Seconds >= CMD_CALL_INTERVAL then last_time = run_cmd_file() end
		
		relation_i = relation_i + 1
		local SystemNumberPair = {}
		
		for FieldNumber, RelationPairs in pairs(RelationsData) do
			--[[ Всегда один элемент таблицы, где ключ - это номер поля связи, значение - таблица с двумя элементами вида {мнемокод_базы = guid_записи} ]]--
			for _, RelationPair in pairs(RelationPairs) do
				--[[
					Таблица guid_sn формируется в ходе загрузки в банк записей текущей выгрузки и содержит соответствие guid-ов и системных номеров
					созданных в ходе загрузки записей. При построении связей в банке из этой таблицы  Если нужного guid-а нет в таблице -> будем искать 
					его в банке запросом и добавим в таблицу соответствия.
				]]--
				local mnemo, guid = RelationPair[1], RelationPair[2]
				local SystemNumber = guid_sn[guid]
				if not SystemNumber then
					local rec = get_record(mnemo, guid)
					if rec then
						SystemNumber = rec.SN
						guid_sn[guid] = SystemNumber
					else
						write_to_log('errors', 'Не удалось найти запись базы '..mnemo..' с guid: '..guid)
					end
				end
				if SystemNumber then
					table.insert(SystemNumberPair, {mnemo, SystemNumber})
				end
			end
			
			if length(SystemNumberPair) == 2 then
				local mnemo_1, sn_1 = SystemNumberPair[1][1], SystemNumberPair[1][2]
				local mnemo_2, sn_2 = SystemNumberPair[2][1], SystemNumberPair[2][2]
				local base_1 = CurrentBank:GetBase(mnemo_1)
				local base_2 = CurrentBank:GetBase(mnemo_2)
				if not base_1:AddLink(sn_1, tonumber(FieldNumber), base_2, sn_2, Base.LockWait, Base.LockWait) then
					write_to_log('errors', 'Не удалось установить связь записи '..sn_1..' ('..mnemo_1..') с записью '..sn_2..' ('..mnemo_2..') по полю '..FieldNumber..'.')
				end
			end
		end
		
		Me.monitor:SetCellText(1, row_num, relation_i..' / '..relations_count)
		Me.monitor:SetCellText(3, row_num, (DateTime.Now-time_start_base_processing):ToString('%c'))
		TotalProgress:NextStep()
	
	end
	
end


function get_field_number(field_name_number)
	local field_number = tonumber(string.field(string.split(field_name_number, ' ')[1], '_', (string.scount(string.split(field_name_number, ' ')[1],'_'))+1))
	if field_number then
		return field_number
	end
	return false
end


function get_field_name(field_name_number)
	local field_name = string.delete(field_name_number, string.index(field_name_number, '_', string.scount(field_name_number, '_')), -1)
	if field_name then
		return field_name
	end
	return false
end


function get_field_values(element)
	local last_time = DateTime.Now
	local fields_data = {}

	local value = element'$v'
	if value then
		--Обработка простого немножественного поля
		local dictionary_code = element'$a'.dictionary_code
		if dictionary_code then
			fields_data[1] = dictionary_code
		else
			fields_data[1] = value
		end
	else
		for idx, sub_element in ipairs(element'$c') do
			if cancel then break end
			if (DateTime.Now - last_time).Seconds >= CMD_CALL_INTERVAL then last_time = run_cmd_file() end
			local MnemoDB = string.delete(string.field(sub_element:ToString(), ">", 1), 1, 1)
			if string.starts(MnemoDB, 'value') then
				--Обработка множественного поля
				local dictionary_code = sub_element'$a'.dictionary_code
				if dictionary_code then
					fields_data[idx] = dictionary_code
				else
					fields_data[idx] = sub_element'$v'
				end
			else
				--Обработка специального поля
				fields_data[idx] = {MnemoDB, sub_element'$v'}
			end
		end
	end

	return fields_data
end


function add_data_to_simple_field(rec, field_number, field_name, field_values)
	if rec then
		local succes, errMsg = rec:SetValue(field_number, field_values)
		if succes then
			if rec:Update(true) then
				return true
			else
				write_to_log('errors', 'Ошибка сохранения изменений записи SN: '..rec.SN..' базы: '..rec.Base.Code)
				return false
			end
		else
			write_to_log('errors', 'Ошибка добавления данных в поле: '..field_number..' записи SN: '..rec.SN..' базы: '..rec.Base.Code)
			return false
		end
	end
end


function add_file_in_database(db_mnemo, rec, field_number, field_name, files)
	local FilesDirectory = main_folder..[[Data\]]..db_mnemo..[[\Files\]]
	if rec then
		for _, file in ipairs(files) do
			local succes, errMsg = rec:SetValue(field_number, FilesDirectory..file, 0, IO.Path.GetFileName(file), IO.Path.GetExt(file), true)
			if succes then
				return true
			else
				MsgBox(errMsg)
				write_to_log('errors', 'Ошибка загрузки файла '..file..' в запись SN: '..rec.SN..' базы: '..rec.Base.Code..'\n'..errMsg)
				return false
			end
		end
	end
end


function get_record(db_mnemo, guid_value)
	local RequestString = 'ОТ '..db_mnemo..'01 '..GUID_FIELD_NUMBER..' РВ '..guid_value
	local record_set = CurrentBank:StringRequest(RequestString)
	if record_set then
		if record_set.Count == 1 then
			return record_set:GetRecordByIndex(1)
		elseif record_set.Count > 1 then
			write_to_log('errors', 'Запрос "'..RequestString..'" вернул '..record_set.Count..' записей')
			MsgBox('Запрос вернул несколько записей - проблема дублирования GUID. Сообщите администратору.', IconError)
		end
	end
	return false
end


function change_folder_Click( control, event )
	local new_destination = BrowseForFolder('Укажите каталог для выгрузки')
	if new_destination then
		Me.path.Text = new_destination
	end
end


function run_cmd_file()
	if not IO.File.Exists(tempCmdFile) then
		writefile(tempCmdFile, '1')
	end
	ShellExecute(tempCmdFile, '', true, 'open', '', 0)
	return DateTime.Now
end


function clear_the_monitor()
	for i = 1, Me.monitor.NumberRows do
		Me.monitor:DeleteRow(0)
	end
end


function main()
	Formula.SetGlobal('disabled_formula', true)			--Создаем формулу для того, чтобы иметь возможность отключить пользовательские формулы на время выгрузки
	Me.cancel.Enabled = true
	Me.close.Enables = false
	
	local program_start_time = DateTime.Now
	write_to_log('processed', 'Запуск загрузчика.')
	local root_elements = collect_names_of_bases()
	
	if not root_elements then
		write_to_log('errors', 'Ошибка обращения к файлам структуры '..tostring(files))
	else
		local xml_files, total_count_of_files = collect_xml_files(root_elements)	--{AC={[1]="part_1.xml", [2]="part_2.xml"}}
		local bases_count = length(xml_files)
		add_data_to_the_monitor(xml_files)
		
		ProgressWriterInstance = ProgressWriter:new( progress_folder )
		ProgressWriterInstance:Init()
		
		RelationsWriterInstance = RelationsWriter:new( progress_folder )
		RelationsWriterInstance:Init()
		
		local guid_sn = create_records(xml_files, root_elements, bases_count, total_count_of_files)
		create_links(xml_files, root_elements, bases_count, total_count_of_files, guid_sn)
		
		ProgressWriterInstance:Delete()
		RelationsWriterInstance:Delete()
	end
	
	write_to_log('processed', 'Работа загрузчика корректно завершена.')
	Me.cancel.Enabled = false
	Me.close.Enables = true
	Formula.SetGlobal('disabled_formula', false)
	MsgBox('Работа загрузчика завершена.\nЗатрачено времени: '..(DateTime.Now - program_start_time):ToString('%c'), IconInformation)
end


function Форма_Load( form )
	
	Me.Text = FORM_TITLE
	Me.path.Text = ''
	
	create_table(Me.monitor, {'Код', 'Название базы', 'Обрабатывается файл', 'Начало загрузки', 'Затрачено времени'}) --Создается таблица на форме в которой будем отображать процесс обработки записей
	
	Me.date.Text = DateTime.Now:ToString('%x')
	Me.timeH.Text = DateTime.Now:ToString('%H')
	Me.timeM.Text = DateTime.Now:ToString('%M')	
	
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


function upload_from_xml_Click( control, event )
	cancel = false
	
	main_folder = IO.Path.AddSlash(Me.path.Text)
	if not IO.Folder.Exists(main_folder) then
		MsgBox('Путь "'..main_folder..'" не существует.\nПроверьте правильность указания пути и повторите попытку.', IconWarning)
		return
	end
	
	data_folder = IO.Path.AddSlash(main_folder..'Data')
	if not IO.Folder.Exists(data_folder) then
		MsgBox('Не найден каталог данных "'..data_folder..'"', IconWarning)
		return
	end
	
	structure_folder = IO.Path.AddSlash(main_folder..'Structure')
	if not IO.Folder.Exists(structure_folder) then
		MsgBox('Не найден каталог структуры данных "'..structure_folder..'"', IconWarning)
		return
	end
	
	log_folder = IO.Path.AddSlash(main_folder..'Log')
	progress_folder = IO.Path.AddSlash(log_folder..'.progress')
	
	main()
end


function close_Click( control, event ) Me:CloseForm() end


function cancel_Click( control, event ) if MsgBox('Прервать операцию?', IconQuestion + BtnYesNo) == IdYes then cancel = true end end


function path_Click( control, event ) control.Focused = true end
