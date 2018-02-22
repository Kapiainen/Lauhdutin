'Must be executed with "cscript" or there will be an error message
If WScript.Arguments.Count = 0 Then
	Call Main("Select a folder:", "")
ElseIf WScript.Arguments.Count = 1 Then
	Call Main(WScript.Arguments(0), "")
ElseIf WScript.Arguments.Count > 1 Then
	Call Main(WScript.Arguments(0), WScript.Arguments(1))
End If

Function Main(a_message, a_root)
	Set shell = CreateObject("Shell.Application")
	Set folder = shell.BrowseForFolder(0, a_message, 0, a_root)
	If folder Is Nothing Then
		WScript.StdOut.WriteLine "Path="""""
	Else
		WScript.StdOut.WriteLine "Path=""" & folder.Self.Path & """"
	End If
	Set shell = Nothing
	Set folder = Nothing
End Function
