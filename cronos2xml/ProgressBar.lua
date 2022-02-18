module(... ,package.seeall) --Удалить объявление модуля, если скрипт вызывается из интернет-компонента или планировщика.

local PROGRESS_LINE_ELEMENT_NAME = 'ProgressLine'


ProgressBar = {}

function ProgressBar:new( ProgressControl, MaxValue )
	
	local obj = {}
		obj.ProgressControl = ProgressControl
		obj.ProgressLine = nil
		obj.ProgressLineWidth = 0
		obj.MaxValue = MaxValue
		obj.CurrentPosition = 0
		obj.ProgressStep = 0
		
	function obj:InitBar()
		local ProgressLineText = ''
		local ProgressLineX = 0
		local ProgressLineY = 0
		local ProgressLineWidth = 0
		local ProgressLineHeight = self.ProgressControl.Height
		local ProgressLine = ProgressControl:FindControl(PROGRESS_LINE_ELEMENT_NAME)
		if ProgressLine == nil then
			ProgressLine = Panel.new(PROGRESS_LINE_ELEMENT_NAME, ProgressLineText, ProgressLineX, ProgressLineY, ProgressLineWidth, ProgressLineHeight)
			self.ProgressLine = self.ProgressControl:AddControl(ProgressLine)
		else
			self.ProgressLine = ProgressLine
			self.ProgressLine.Width = 0
		end
		self.ProgressLine.BackColor = Color.SlateGray
	end
	
	function obj:NextStep()
		self.CurrentPosition = self.CurrentPosition + 1
		local proc = math.ceil(self.CurrentPosition / self.MaxValue * 100)
		self.ProgressLine.Width = self.ProgressControl.Width / 100 * proc
	end
	
	setmetatable(obj, self)
	self.__index = self
	return obj
	
end