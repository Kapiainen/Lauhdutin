local utility = require('shared.utility')
local migrators = {
  {
    version = 1,
    func = function(translations) end
  }
}
local Localization
do
  local _class_0
  local _base_0 = {
    load = function(self)
      log('Loading translation file')
      local translations = { }
      if not (io.fileExists(self.path)) then
        log('Translation file does not exist')
        self:save({ })
        return translations
      end
      local lines = io.readFile(self.path):splitIntoLines()
      local version = 0
      if #lines > 0 then
        version = table.remove(lines, 1)
        version = tonumber(version:match('^version%s(%d+)$')) or 0
      end
      assert(type(version) == 'number' and version % 1 == 0, 'Expected the translation strings version number to be an integer.')
      for _index_0 = 1, #lines do
        local _continue_0 = false
        repeat
          local line = lines[_index_0]
          local key, translation = line:match('^([^\t]+)\t(.+)$')
          if key == nil or translation == nil then
            _continue_0 = true
            break
          end
          translations[key] = utility.replaceUnsupportedChars(translation):gsub('\\n', '\n')
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      if self:migrate(translations, version) then
        self:save(translations)
      end
      return translations
    end,
    migrate = function(self, translations, version)
      assert(type(version) == 'number' and version % 1 == 0, 'Expected the translation strings version number to be an integer.')
      assert(version <= self.version, ('Unsupported translation strings version. Expected version %d or earlier.'):format(self.version))
      if version == self.version then
        return false
      end
      for _index_0 = 1, #migrators do
        local migrator = migrators[_index_0]
        if version < migrator.version then
          migrator.func(translations)
        end
      end
      log('Migrated translation file from version', version)
      return true
    end,
    save = function(self, translations)
      if translations == nil then
        translations = self.translations
      end
      log('Saving translation file')
      local contents = ('version %d\n'):format(self.version)
      for key, translation in pairs(translations) do
        contents = contents .. ('%s\t%s\n'):format(key, translation:gsub('\n', '\\n'))
      end
      return io.writeFile(self.path, contents)
    end,
    get = function(self, key, default)
      local translation = self.translations[key]
      if translation == nil then
        self.translations[key] = default
        if self.language == 'English' then
          log('Writing default translation for the key', key)
          io.writeFile(self.path, ('%s	%s\n'):format(key, (default:gsub('\n', '\\n'))), 'a')
        else
          log('Writing "TRANSLATION_MISSING" for the key', key)
          io.writeFile(self.path, ('%s	TRANSLATION_MISSING\n'):format(key), 'a')
        end
        return default
      elseif translation == 'TRANSLATION_MISSING' then
        return default
      end
      return translation
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, settings)
      assert(type(settings) == 'table', 'shared.localization.Localization')
      self.version = 1
      self.language = settings:getLocalization()
      self.path = ('Languages\\%s.txt'):format(self.language)
      self.translations = self:load()
    end,
    __base = _base_0,
    __name = "Localization"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Localization = _class_0
end
return Localization
