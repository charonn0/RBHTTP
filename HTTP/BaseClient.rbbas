#tag Class
Protected Class BaseClient
Inherits TCPSocket
	#tag Event
		Sub DataAvailable()
		  Do Until InStr(Me.Lookahead, CRLF + CRLF) = 0
		    Dim raw As String = Me.Read(InStr(Me.Lookahead, CRLF + CRLF) + 3)
		    Dim reply As New HTTP.Response(raw)
		    RaiseEvent HeadersReceived(reply)
		    raw = ""
		    If reply.HasHeader("Content-Length") Then
		      Dim contentlength As Integer = Val(reply.GetHeader("Content-Length"))
		      While raw.LenB < contentlength And Me.BytesAvailable > 0
		        'RaiseEvent ReceiveProgress(Me.Lookahead.LenB, contentlength, Me.LookAhead)
		        raw = raw + Me.ReadAll
		        App.YieldToNextThread
		      Wend
		      Reply.MessageBody = Me.Read(contentlength)
		    End If
		    RaiseEvent Response(reply)
		  Loop
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub ClearRequestHeaders()
		  RequestMessage.Headers.DeleteAllHeaders
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Get(URL As String, TimeoutSeconds As Integer = - 1)
		  Me.SendRequest("GET", URL, TimeoutSeconds)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetHeaders(URL As String, TimeoutSeconds As Integer = -1)
		  Me.SendRequest("HEAD", URL, TimeoutSeconds)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendRequest(Method As String, URL As String, TimeoutSeconds As Integer = - 1)
		  Dim URI As New HTTP.URI(URL)
		  Me.RequestMessage.MethodName = Method
		  Me.RequestMessage.SetHeader("Host") = URI.FQDN
		  Me.RequestMessage.SetHeader("Connection") = "close"
		  Me.Address = URI.FQDN
		  Me.Port = URI.Port
		  
		  If TimeoutSeconds > 0 Then
		    TimeOutTimer = New Timer
		    AddHandler TimeOutTimer.Action, WeakAddressOf Me.TimeOutHandler
		    TimeOutTimer.Period = TimeoutSeconds * 1000
		    TimeOutTimer.Mode = Timer.ModeSingle
		  Else
		    TimeOutTimer = Nil
		  End If
		  
		  Me.Connect
		  
		  Me.Write(RequestMessage.ToString)
		  Me.Flush
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetFormData(Form As Dictionary)
		  RequestMessage.MessageBody = EncodeFormData(Form)
		  SetRequestHeader("Content-Length", Format(RequestMessage.MessageBody.LenB, "##################0"))
		  SetRequestHeader("Content-Type", "application/x-www-form-URLEncoded")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetRequestContent(Content As String, ContentType As String)
		  RequestMessage.MessageBody = Content
		  SetRequestHeader("Content-Type", ContentType)
		  SetRequestHeader("Content-Length", Format(RequestMessage.MessageBody.LenB, "##################0"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetRequestHeader(Name As String, Value As String)
		  RequestMessage.Headers.SetHeader(Name, Value)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TimeOutHandler(Sender As Timer)
		  #pragma Unused Sender
		  Me.Disconnect
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event HeadersReceived(HeadersResponse As HTTP.Response)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Response(ServerResponse As HTTP.Response)
	#tag EndHook


	#tag Property, Flags = &h21
		Private mRequest As HTTP.Request
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mRequest = Nil Then
			    mRequest = New HTTP.Request("GET / HTTP/1.0" + EndOfLine.Windows + EndOfLine.Windows)
			  End If
			  return mRequest
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mRequest = value
			End Set
		#tag EndSetter
		RequestMessage As HTTP.Request
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
