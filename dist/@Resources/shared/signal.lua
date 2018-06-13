local Signal
do
  local _class_0
  local _base_0 = {
    register = function(self, sig, funcs)
      assert(type(sig) == 'string' and sig ~= '', 'shared.signal.Signal.register')
      local registeredFuncs = self.signals[sig]
      if registeredFuncs == nil then
        registeredFuncs = { }
      end
      if type(funcs) == 'table' then
        for _index_0 = 1, #funcs do
          local f = funcs[_index_0]
          assert(type(f) == 'function', 'shared.signal.Signal.register')
          table.insert(registeredFuncs, f)
        end
      else
        assert(type(funcs) == 'function', 'shared.signal.Signal.register')
        table.insert(registeredFuncs, funcs)
      end
      self.signals[sig] = registeredFuncs
    end,
    emit = function(self, sig, ...)
      assert(type(sig) == 'string', 'shared.signal.Signal.emit')
      local registeredFuncs = self.signals[sig]
      if registeredFuncs == nil or #registeredFuncs == 0 then
        return 
      end
      for _index_0 = 1, #registeredFuncs do
        local func = registeredFuncs[_index_0]
        func(...)
      end
    end,
    remove = function(self, sig, funcs)
      assert(type(sig) == 'string', 'shared.signal.Signal.remove')
      local registeredFuncs = self.signals[sig]
      if registeredFuncs == nil or #registeredFuncs == 0 then
        return 
      end
      if type(funcs) == 'table' then
        for _index_0 = 1, #funcs do
          local f = funcs[_index_0]
          assert(type(f) == 'function', 'shared.signal.Signal.remove')
          local i = table.find(registeredFuncs, f)
          if i ~= nil then
            table.remove(registeredFuncs, i)
          end
        end
      else
        assert(type(funcs) == 'function', 'shared.signal.Signal.remove')
        local i = table.find(registeredFuncs, funcs)
        if i ~= nil then
          return table.remove(registeredFuncs, i)
        end
      end
    end,
    clear = function(self, sig)
      assert(type(sig) == 'string', 'shared.signal.Signal.clear')
      self.signals[sig] = nil
    end,
    emitPattern = function(self, pattern, ...)
      assert(type(pattern) == 'string', 'shared.signal.Signal.emitPattern')
      for signal, funcs in pairs(self.signals) do
        if signal:match(pattern) ~= nil then
          for _index_0 = 1, #funcs do
            local func = funcs[_index_0]
            func(...)
          end
        end
      end
    end,
    removePattern = function(self, pattern, funcs)
      assert(type(pattern) == 'string', 'shared.signal.Signal.removePattern')
      if type(funcs) == 'table' then
        for signal, registeredFuncs in pairs(self.signals) do
          local _continue_0 = false
          repeat
            if signal:match(pattern) ~= nil then
              if #registeredFuncs == 0 then
                _continue_0 = true
                break
              end
              for _index_0 = 1, #funcs do
                local f = funcs[_index_0]
                local i = table.find(registeredFuncs, f)
                if i ~= nil then
                  table.remove(registeredFuncs, i)
                end
              end
            end
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
      else
        assert(type(funcs) == 'function', 'shared.signal.Signal.removePattern')
        for signal, registeredFuncs in pairs(self.signals) do
          local _continue_0 = false
          repeat
            if signal:match(pattern) ~= nil then
              if #registeredFuncs == 0 then
                _continue_0 = true
                break
              end
              local i = table.find(registeredFuncs, funcs)
              if i ~= nil then
                table.remove(registeredFuncs, i)
              end
            end
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
      end
    end,
    clearPattern = function(self, pattern)
      assert(type(pattern) == 'string', 'shared.signal.Signal.clearPattern')
      for signal, registeredFuncs in pairs(self.signals) do
        if signal:match(pattern) ~= nil then
          self.signals[signal] = nil
        end
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.signals = { }
    end,
    __base = _base_0,
    __name = "Signal"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Signal = _class_0
end
return Signal
