If WScript.Arguments.Count > 0 Then
	Main(WScript.Arguments(0))
Else
	WScript.Echo "Error: No arguments were given!"
End If

Function Main(a_path)
	Set shell = CreateObject("WScript.Shell")
	Set shortcut = shell.CreateShortcut(a_path)
	If UCase(Right(a_path, 4)) = ".LNK" Then
		WScript.StdOut.WriteLine "	Target=" & shortcut.TargetPath
		WScript.StdOut.WriteLine "	Arguments=" & shortcut.Arguments
	ElseIf UCase(Right(a_path, 4)) = ".URL" Then
		WScript.StdOut.WriteLine "	Target=" & shortcut.TargetPath
		WScript.StdOut.WriteLine "	Arguments="
	End If
	Set shortcut = Nothing
	Set shell = Nothing
End Function
