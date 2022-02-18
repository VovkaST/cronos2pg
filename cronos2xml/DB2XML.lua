module(... ,package.seeall) --Удалить объявление модуля, если скрипт вызывается из интернет-компонента или планировщика.

local Bases = CroApp.GetBank().Bases;

local LINKED_BASE_TAG_NAME = 'LINKED_BASE'


function CleanStr( Str )
    --[[ Очистка строки от некоторых небуквенных символов. ]]--
    local CleanStr = Str:gsub('%s+', ' ')
    CleanStr = CleanStr:gsub('^_+', '')
    CleanStr = CleanStr:gsub('_+$', '')
    
	local ASCII_SymbolsCode = {[0] = 31; [127] = 144; [149] = 183; [186] = 191};
	
	for FirstNumb, LastNumb in pairs (ASCII_SymbolsCode) do
		
		for symb = FirstNumb, LastNumb do
			
			CleanStr = string.trim(string.swap(CleanStr, string.char(symb), ""));
			
		end;
		
	end;
	
	return CleanStr
end


function CleanXmlTagName( Str )
    --[[ Очистка имени XML-тэга от запрещенных символов. ]]--
    local CleanStr = CleanStr(Str)
	CleanStr = CleanStr:gsub('%s', '_')
	CleanStr = CleanStr:gsub('%-+', ' ')
	CleanStr = CleanStr:gsub('%s+', '_')
	CleanStr = CleanStr:gsub('^_+', '')
    CleanStr = CleanStr:gsub('_+$', '')
    CleanStr = CleanStr:gsub('!', '')
	CleanStr = CleanStr:gsub('^%d', '_%1')
    return CleanStr:translit():upper()
end


function DatabaseStructureToXML( DataBase )
    --[[ Описание структуры базы данных в XML-формат.

    На вход принимает экземпляр базы данных (Base) соответствующего банка данных. 
    Возвращает экземпляр XML.DOM и строку, содержащую транслитерированное имя базы данных в верхнем регистре.
    
	]]--
	
	
		local DataBaseName = CleanXmlTagName(DataBase.Name)
		local BaseXML = XML.DOM.CreateXML(DataBaseName)
	--	local index = string.index(DataBase.Code, "$", 1)
		
	--[[
		if index > 0 then
			
			
			MsgBox("index="..index);
			
		end;
		_G.Test = "Test"
	--]]
		
--		BaseXML:SetAttribute('db_mnemo', CleanXmlTagName(DataBase.Code))
		BaseXML:SetAttribute('db_mnemo', CleanXmlTagName(_G.BasesTable[DataBase.Code]))
		BaseXML:SetAttribute('db_number', DataBase.Number)
		
		for _, CurrentField in ipairs(DataBase.Fields) do
			local FieldNodeName = CleanXmlTagName(CurrentField.Name)
			local FieldNode = ""
			if FieldNodeName ~= "" then
				FieldNode = BaseXML:AddNode(FieldNodeName)
				FieldNode:SetAttribute('type', CurrentField.Type)
				FieldNode:SetAttribute('type_name', CurrentField.TypeName)
				FieldNode:SetAttribute('number', CurrentField.Number)
				FieldNode:SetAttribute('name', CurrentField.Name:trim())
				FieldNode:SetAttribute('length', CurrentField.Length)
				FieldNode:SetAttribute('is_multiple', render(CurrentField:TestStatus(Field.Multiple)))
			else
				
				MsgBox("Название поля № "..CurrentField.Number.." базы '"..DataBase.Name.."' содержит недопустимые символы или пусто и будет исключено из выгрузки.", IconWarning)
				
			end;
			
			local LinkedBases = CurrentField.LinkedBases
			if table.count(LinkedBases) > 0 then
				for _, LinkedField in ipairs(LinkedBases) do
					local LinkedNode = FieldNode:AddNode(LINKED_BASE_TAG_NAME)
					local LinkedBase = LinkedField['Base']
					local LinkedField = LinkedField['Field']
					
					LinkedNode:SetAttribute('db_name', LinkedBase.Name:trim())
--					LinkedNode:SetAttribute('db_mnemo', CleanXmlTagName(LinkedBase.Code))
	                LinkedNode:SetAttribute('db_mnemo', CleanXmlTagName(_G.BasesTable[LinkedBase.Code]))
					LinkedNode:SetAttribute('db_number', LinkedBase.Number)
					LinkedNode:SetAttribute('field_number', LinkedField.Number)
					LinkedNode:SetAttribute('field_name', LinkedField.Name:trim())
					
				end;
				
			end;
			
		end;
		
    
    return BaseXML, DataBaseName
end

function CheckMnemoCode(Bases)
	local status = true;
	local BasesTable = {}
	local index = 0;
	local currBaseCode = "";

	for _, currBase in pairs (Bases) do
		
		BasesTable[currBase.Code] = currBase.Code;
		
	end;
	
	for key, currBaseCode in pairs (BasesTable) do
		
		if string.scount(currBaseCode, "$") > 0 then
			
			for i = 1, string.scount(currBaseCode, "$") do
				
				index = string.index(currBaseCode, "$", 1);
				currBaseCode = string.delete(string.insert(currBaseCode, index, "S"), index + 1, 1);
				
			end;
			
			local FindedKey = table.getkey(BasesTable, currBaseCode)
			
			local ABC = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
			local ABC_index_i = 0;
			local ABC_index_j = 1;
			local index = 1;
			
			while FindedKey ~= nil do
				
				ABC_index_i = ABC_index_i + 1;
				currBaseCode = string.sub(ABC, ABC_index_j, ABC_index_j)..string.sub(ABC, ABC_index_i, ABC_index_i);
				
				FindedKey = table.getkey(BasesTable, currBaseCode);
				
				if ABC_index_i >= string.len(ABC) then
					
					if ABC_index_j >= string.len(ABC) then
						
						MsgBox("Не удалось подобрать уникальный мнемокод");
						status = false;
						break
						
					end
					
					ABC_index_i = 0;
					ABC_index_j = ABC_index_j + 1;
					
				end;
				
			end;
			
			BasesTable[key] = currBaseCode;
			
		end;
		
	end;

	_G.BasesTable = BasesTable;
	
	return status;

end;
