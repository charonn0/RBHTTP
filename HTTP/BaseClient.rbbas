#tag Class
Protected Class BaseClient
Inherits TCPSocket
	#tag Event
		Sub DataAvailable()
		  Do Until InStr(Me.Lookahead, CRLF + CRLF) = 0
		    Dim raw As String = Me.Read(InStr(Me.Lookahead, CRLF + CRLF) + 3)
		    Dim headers As New InternetHeaders
		    Dim statusline As String = NthField(raw, CRLF, 1) ' extract the first line
		    raw = Replace(raw, statusline + CRLF, "")
		    Dim contentlength As Integer
		    Dim content As String
		    ' Parse Headers
		    Dim lines() As String = raw.Split(CRLF)
		    Dim lcount As Integer = UBound(lines)
		    For i As Integer = 0 To lcount
		      Dim line As String = lines(i)
		      If Instr(line, ": ") <= 1  Or line.Trim = "" Then Continue
		      Dim n, v As String
		      n = NthField(line, ": ", 1)
		      v = Right(line, line.Len - (n.Len + 2)).Trim
		      headers.SetHeader(n, v)
		      raw = Replace(raw, line + CRLF, "")
		      If n = "Content-Length" Then
		        contentlength = Val(v)
		      ElseIf n = "Transfer-Encoding" And  v = "chunked" Then ' chunked message
		        contentlength = -1
		      End If
		    Next
		    Dim statuscode As Integer = Val(NthField(statusline, " ", 2))
		    Dim proto As Single = CDbl(Replace(NthField(statusline, " ", 1).Trim, "HTTP/", ""))
		    
		    RaiseEvent HeadersReceived(headers, statuscode, proto)
		    
		    Dim data As String
		    If contentlength > 0 Then
		      While data.LenB < contentlength
		        'RaiseEvent ReceiveProgress(Me.Lookahead.LenB, contentlength, Me.LookAhead)
		        data = data + Me.ReadAll
		        App.YieldToNextThread
		      Wend
		      content = Me.Read(contentlength)
		    ElseIf contentlength = -1 Then ' chunked
		      While InStr(Me.Lookahead.Trim, CRLF) > 0
		        Dim chunkdef As String = Me.Read(InStr(Me.Lookahead, CRLF))
		        Dim csz As Integer = Val("&h" + chunkdef)
		        If data.LenB + Me.Lookahead.LenB < csz Then
		          data = data + Me.ReadAll
		        Else
		          Dim sz As Integer = Min(Me.Lookahead.LenB, csz - data.LenB)
		          data = data + Me.Read(sz)
		        End If
		        'App.YieldToNextThread
		        RaiseEvent ReceiveProgress(data.LenB, csz, data)
		      Wend
		      content = content +  data 'Me.Read(csz + 2)
		    End If
		    
		    RaiseEvent ContentReceived(Me.Address, statuscode, headers, content, proto)
		  Loop
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub ClearRequestHeaders()
		  RequestHeaders.DeleteAllHeaders
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Get(URL As String, TimeoutSeconds As Integer = - 1)
		  If TimeoutSeconds > 0 Then
		    TimeOutTimer = New Timer
		    AddHandler TimeOutTimer.Action, WeakAddressOf Me.TimeOutHandler
		    TimeOutTimer.Period = TimeoutSeconds * 1000
		    TimeOutTimer.Mode = Timer.ModeSingle
		  Else
		    TimeOutTimer = Nil
		  End If
		  Me.SendRequest("GET", URL)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetHeaders(URL As String)
		  Me.SendRequest("HEAD", URL)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendRequest(Method As String, URL As String)
		  Dim URI As New HTTP.URI(URL)
		  Dim request As String = Uppercase(Method) + " " + URI.ServerPath + " HTTP/1.0" + CRLF
		  SetRequestHeader("Host", URI.FQDN)
		  SetRequestHeader("Connection", "close")
		  request = request + RequestHeaders.Source + CRLF + CRLF
		  If RequestBody.Trim <> "" Then
		    request = request + RequestBody
		  End If
		  Me.Address = URI.FQDN
		  Me.Port = URI.Port
		  Me.Connect
		  
		  Me.Write(request)
		  Me.Flush
		  RequestBody = ""
		  RequestHeaders.DeleteAllHeaders
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetFormData(Form As Dictionary)
		  RequestBody = EncodeFormData(Form)
		  SetRequestHeader("Content-Length", Format(RequestBody.LenB, "##################0"))
		  SetRequestHeader("Content-Type", "application/x-www-form-URLEncoded")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( deprecated = "WebClient.SetRequestContent", hidden )  Sub SetPostContent(Content as String, ContentType as String)
		  SetRequestContent(Content, ContentType)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetRequestContent(Content As String, ContentType As String)
		  RequestBody = Content
		  SetRequestHeader("Content-Type", ContentType)
		  SetRequestHeader("Content-Length", Format(RequestBody.LenB, "##################0"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetRequestHeader(Name As String, Value As String)
		  RequestHeaders.SetHeader(Name, Value)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TimeOutHandler(Sender As Timer)
		  #pragma Unused Sender
		  Me.Disconnect
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event AuthenticationRequired()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ContentReceived(URL as String, HTTPStatus as Integer, Headers as InternetHeaders, Content as String, HTTPVersion As Single)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event HeadersReceived(Headers as InternetHeaders, HTTPStatus as Integer, HTTPVersion As Single)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ReceiveProgress(BytesReceived as Integer, TotalBytes as Integer, NewData as String)
	#tag EndHook


	#tag Property, Flags = &h21
		Private mRequestHeaders As InternetHeaders
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected RequestBody As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mRequestHeaders = Nil Then mRequestHeaders = New InternetHeaders
			  return mRequestHeaders
			End Get
		#tag EndGetter
		RequestHeaders As InternetHeaders
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private TimeOutTimer As Timer
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Address"
			Visible=true
			Group="Behavior"
			Type="String"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HTTPVersion"
			Group="Behavior"
			InitialValue="1.1"
			Type="Single"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PipeLining"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Port"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
