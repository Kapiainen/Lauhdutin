class Slot
	new: (index) =>
		assert(type(index) == 'number' and index % 1 == 0, 'main.slots.slot.Slot')
		@index = index
		@game = nil

	getGame: () => return @game

	update: (game) =>
		@game = game
		if game == nil
			log(('Updating slot %d with nothing')\format(@index))
			SKIN\Bang(('[!SetOption "Slot%dText" "Text" ""]')\format(@index))
			SKIN\Bang(('[!SetOption "Slot%dImage" "ImageName" ""]')\format(@index))
			return
		log(('Updating slot %d with %s')\format(@index, game\getTitle()))
		banner = game\getBanner()
		if banner
			SKIN\Bang(('[!SetOption "Slot%dText" "Text" ""]')\format(@index))
			SKIN\Bang(('[!SetOption "Slot%dImage" "ImageName" "#@#%s"]')\format(@index, banner))
		else
			SKIN\Bang(('[!SetOption "Slot%dText" "Text" "%s"]')\format(@index, game\getTitle()))
			SKIN\Bang(('[!SetOption "Slot%dImage" "ImageName" ""]')\format(@index))

return Slot
