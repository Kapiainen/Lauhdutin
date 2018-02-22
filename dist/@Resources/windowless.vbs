If WScript.Arguments.Count > 0 Then
	Main(WScript.Arguments(0))
Else
	WScript.Echo "Error: No arguments were given!"
End If

Function Main(a_path)
	Set shell = CreateObject("WScript.Shell")
	Dim arg
	arg = """" & a_path & """"
	Dim i
	i = 0
	For Each argument in WScript.Arguments
		If i > 0 Then
			arg = arg & " """ & argument & """"
		End If
		i = i + 1
	Next
	shell.Run(arg), 0, false
	Set shell = Nothing
End Function
