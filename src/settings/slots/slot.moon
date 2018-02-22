class Slot
	new: (index) =>
		@index = index

	update: (setting) =>
		return SKIN\Bang(('[!HideMeterGroup "Slot%d"]')\format(@index)) if setting == nil
		SKIN\Bang(('[!SetOption "Slot%dTitle" "Text" "%s"]')\format(@index, setting.title))
		SKIN\Bang(('[!SetOption "Slot%dToolTip" "ToolTipText" "%s"]')\format(@index, setting.tooltip))
		SKIN\Bang(('[!ShowMeterGroup "Slot%d"]')\format(@index))
		SKIN\Bang(('[!HideMeterGroup "Slot%dSettings"]')\format(@index))
		switch setting.type
			when ENUMS.SETTING_TYPES.ACTION
				SKIN\Bang(('[!SetOption "Slot%dAction" "Text" "%s"]')\format(@index, setting.label))
				SKIN\Bang(('[!ShowMeterGroup "Slot%dSettingAction"]')\format(@index))
			when ENUMS.SETTING_TYPES.BOOLEAN
				if setting\getState()
					SKIN\Bang(('[!SetOption "Slot%dBoolean" "ImageName" "#@#settings\\gfx\\boolean_true.png"]')\format(@index))
				else
					SKIN\Bang(('[!SetOption "Slot%dBoolean" "ImageName" "#@#settings\\gfx\\boolean_false.png"]')\format(@index))
				SKIN\Bang(('[!ShowMeterGroup "Slot%dSettingBoolean"]')\format(@index))
			when ENUMS.SETTING_TYPES.FOLDER_PATH
				SKIN\Bang(('[!SetOption "Slot%dFolderPathValue" "Text" "%s"]')\format(@index, setting\getValue()))
				SKIN\Bang(('[!ShowMeterGroup "Slot%dSettingFolderPath"]')\format(@index))
			when ENUMS.SETTING_TYPES.SPINNER
				SKIN\Bang(('[!SetOption "Slot%dSpinnerValue" "Text" "%s"]')\format(@index, setting\getValues()[setting\getIndex()].displayValue))
				SKIN\Bang(('[!ShowMeterGroup "Slot%dSettingSpinner"]')\format(@index))
			when ENUMS.SETTING_TYPES.INTEGER
				SKIN\Bang(('[!SetOption "Slot%dIntegerValue" "Text" "%d"]')\format(@index, setting\getValue()))
				SKIN\Bang(('[!ShowMeterGroup "Slot%dSettingInteger"]')\format(@index))
			when ENUMS.SETTING_TYPES.FOLDER_PATH_SPINNER
				SKIN\Bang(('[!SetOption "Slot%dFolderPathSpinnerValue" "Text" "%s"]')\format(@index, setting\getValues()[setting\getIndex()]))
				SKIN\Bang(('[!ShowMeterGroup "Slot%dSettingFolderPathSpinner"]')\format(@index))
			else
				assert(nil, ('"Slot.update" does not yet support setting type "%s".')\format(setting.__class.__name))

return Slot
