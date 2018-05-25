class Toolbar
	new: (settings) =>
		assert(type(settings) == 'table', 'main.toolbar.init.Toolbar')
		unless settings\getLayoutToolbarAtTop()
			SKIN\Bang('[!SetOption "ToolbarBackground" "Y" "(#SkinHeight# - #ToolbarHeight#)]')
			SKIN\Bang('[!SetOption "ToolbarEnabler" "Y" "(#SkinHeight# - 1)]')
			SKIN\Bang('[!UpdateMeterGroup "Toolbar"]')

	hide: () => SKIN\Bang('[!HideMeterGroup "Toolbar"]')

	show: () => SKIN\Bang('[!ShowMeterGroup "Toolbar"]')

return Toolbar
