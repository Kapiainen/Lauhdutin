class Signal
	new: () =>
		@signals = {}

	register: (sig, funcs) =>
		assert(type(sig) == 'string' and sig ~= '', 'shared.signal.Signal.register')
		registeredFuncs = @signals[sig]
		if registeredFuncs == nil
			registeredFuncs = {}
		if type(funcs) == 'table'
			for f in *funcs
				assert(type(f) == 'function', 'shared.signal.Signal.register')
				table.insert(registeredFuncs, f)
		else
			assert(type(funcs) == 'function', 'shared.signal.Signal.register')
			table.insert(registeredFuncs, funcs)
		@signals[sig] = registeredFuncs

	emit: (sig, ...) =>
		assert(type(sig) == 'string', 'shared.signal.Signal.emit')
		registeredFuncs = @signals[sig]
		return if registeredFuncs == nil or #registeredFuncs == 0
		for func in *registeredFuncs
			func(...)

	remove: (sig, funcs) =>
		assert(type(sig) == 'string', 'shared.signal.Signal.remove')
		registeredFuncs = @signals[sig]
		return if registeredFuncs == nil or #registeredFuncs == 0
		if type(funcs) == 'table'
			for f in *funcs
				assert(type(f) == 'function', 'shared.signal.Signal.remove')
				i = table.find(registeredFuncs, f)
				table.remove(registeredFuncs, i) if i ~= nil
		else
			assert(type(funcs) == 'function', 'shared.signal.Signal.remove')
			i = table.find(registeredFuncs, funcs)
			table.remove(registeredFuncs, i) if i ~= nil

	clear: (sig) =>
		assert(type(sig) == 'string', 'shared.signal.Signal.clear')
		@signals[sig] = nil

	emitPattern: (pattern, ...) =>
		assert(type(pattern) == 'string', 'shared.signal.Signal.emitPattern')
		for signal, funcs in pairs(@signals)
			if signal\match(pattern) ~= nil
				for func in *funcs
					func(...)

	removePattern: (pattern, funcs) =>
		assert(type(pattern) == 'string', 'shared.signal.Signal.removePattern')
		if type(funcs) == 'table'
			for signal, registeredFuncs in pairs(@signals)
				if signal\match(pattern) ~= nil
					continue if #registeredFuncs == 0
					for f in *funcs
						i = table.find(registeredFuncs, f)
						table.remove(registeredFuncs, i) if i ~= nil
		else
			assert(type(funcs) == 'function', 'shared.signal.Signal.removePattern')
			for signal, registeredFuncs in pairs(@signals)
				if signal\match(pattern) ~= nil
					continue if #registeredFuncs == 0
					i = table.find(registeredFuncs, funcs)
					table.remove(registeredFuncs, i) if i ~= nil

	clearPattern: (pattern) =>
		assert(type(pattern) == 'string', 'shared.signal.Signal.clearPattern')
		for signal, registeredFuncs in pairs(@signals)
				if signal\match(pattern) ~= nil
					@signals[signal] = nil

return Signal
