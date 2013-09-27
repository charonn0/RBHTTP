#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  Client = New HTTP.BaseClient
		  Dim req As New HTTP.Request
		  req.MethodName = "GET"
		  req.Path = New HTTP.URI("http://www.godaddy.com/")
		  req.ProtocolVersion = 1.0
		  AddHandler Client.Response, WeakAddressOf App.ResponseHandler
		  Dim s As String = req.ToString
		  Client.SendRequest(req)
		  While True
		    DoEvents
		  Wend
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h1
		Protected Sub ResponseHandler(Sender As HTTP.BaseClient, ResponseObject As HTTP.Response)
		  Break
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected Client As HTTP.BaseClient
	#tag EndProperty


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
