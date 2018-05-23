utility = require('shared.utility')

migrators = {
	{
		version: 1
		func: (translations) -> return
	}
}

-- Localization files should have the following format:
-- First line: "version\sN"
-- Subsequent lines: "key\ttranslation"

class Localization
	new: (settings) =>
		assert(type(settings) == 'table', 'shared.localization.Localization')
		@version = 1
		@language = settings\getLocalization()
		@path = ('Languages\\%s.txt')\format(@language)
		@translations = @load()

	load: () =>
		log('Loading translation file')
		translations = {}
		unless io.fileExists(@path)
			log('Translation file does not exist')
			@save({})
			return translations
		lines = io.readFile(@path)\splitIntoLines()
		version = 0
		if #lines > 0
			version = table.remove(lines, 1)
			version = tonumber(version\match('^version%s(%d+)$')) or 0
		assert(type(version) == 'number' and version % 1 == 0, 'Expected the translation strings version number to be an integer.')
		for line in *lines
			key, translation = line\match('^([^\t]+)\t(.+)$')
			continue if key == nil or translation == nil
			translations[key] = utility.replaceUnsupportedChars(translation)\gsub('\\n', '\n')
		if @migrate(translations, version)
			@save(translations)
		return translations

	migrate: (translations, version) =>
		assert(type(version) == 'number' and version % 1 == 0, 'Expected the translation strings version number to be an integer.')
		assert(version <= @version, ('Unsupported translation strings version. Expected version %d or earlier.')\format(@version))
		return false if version == @version
		for migrator in *migrators
			if version < migrator.version
				migrator.func(translations)
		log('Migrated translation file from version', version)
		return true

	save: (translations = @translations) =>
		log('Saving translation file')
		contents = ('version %d\n')\format(@version)
		for key, translation in pairs(translations)
			contents ..= ('%s\t%s\n')\format(key, translation\gsub('\n', '\\n'))
		io.writeFile(@path, contents)

	get: (key, default) =>
		translation = @translations[key]
		if translation == nil
			@translations[key] = default
			if @language == 'English'
				log('Writing default translation for the key', key)
				io.writeFile(@path, ('%s	%s\n')\format(key, (default\gsub('\n', '\\n'))), 'a')
			else
				log('Writing "TRANSLATION_MISSING" for the key', key)
				io.writeFile(@path, ('%s	TRANSLATION_MISSING\n')\format(key), 'a')
			return default
		elseif translation == 'TRANSLATION_MISSING'
			return default
		return translation

return Localization
