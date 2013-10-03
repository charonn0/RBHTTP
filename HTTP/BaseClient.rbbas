#tag Class
Protected Class BaseClient
Inherits TCPSocket
	#tag Event
		Sub DataAvailable()
		  #If DebugBuild Then
		    Dim peek As String = Me.Lookahead
		  #endif
		  
		  If Me.BytesAvailable >= WaitForDataLen Then
		    Dim avail As Integer
		    If WaitForDataLen > 0 Then
		      avail = WaitForDataLen - Me.BytesAvailable
		    Else
		      avail = InStr(Me.Lookahead, CRLF + CRLF) + 3
		    End If
		    If avail = 0 Then Return
		    DataBuffer = LeftB(Me.Lookahead, avail)
		    'DataBuffer + Me.Read(avail)
		    '#If DebugBuild Then
		    'Peek = Me.Lookahead
		    '#endif
		    'WaitForDataLen = 0
		    Dim h As New HTTP.Response(DataBuffer)
		    
		    '
		    'DataBuffer = ""
		    If h.HasHeader("Content-Length") Then
		      Dim contentlength As Integer = Val(h.GetHeader("Content-Length"))
		      If contentlength + avail <= Me.BytesAvailable Then
		        Dim reply As New HTTP.Response(Me.Read(contentlength + avail))
		        RaiseEvent Response(reply, OutStandingRequests.Pop)
		      Else
		        WaitForDataLen = contentlength
		        
		      End If
		    ElseIf h.ProtocolVersion > 1.0 Then
		      Break
		    Else
		      Dim reply As New HTTP.Response(Me.ReadAll)
		      RaiseEvent Response(reply, OutStandingRequests.Pop)
		    End If
		  End If
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  'Try
		  'RaiseEvent Response(ActiveResponse, OutstandingRequests.Pop)
		  'Catch Err As OutOfBoundsException ' no request was pending!
		  'Me.Disconnect
		  'Return
		  'End Try
		  'ActiveResponse = Nil
		  'Else
		  'DataBuffer = DataBuffer + Me.ReadAll
		  'ActiveResponse.MessageBody = databuffer
		  '#If DebugBuild Then
		  'Peek = Me.Lookahead
		  '#endif
		  'Return
		  'End If
		  '
		  'Else
		  'Do Until InStr(Me.Lookahead, CRLF + CRLF) = 0
		  'DataBuffer = Me.Read(InStr(Me.Lookahead, CRLF + CRLF) + 3)
		  '#If DebugBuild Then
		  'Peek = Me.Lookahead
		  '#endif
		  'ActiveResponse = New HTTP.Response(DataBuffer)
		  'If ActiveResponse.HasHeader("Content-Length") Then
		  'Dim contentlength As Integer = Val(ActiveResponse.GetHeader("Content-Length"))
		  'If contentlength <= Me.Lookahead.LenB Then
		  'ActiveResponse.MessageBody = Me.Read(contentlength)
		  '#If DebugBuild Then
		  'Peek = Me.Lookahead
		  '#endif
		  'Else
		  'ActiveResponse.MessageBody = Me.ReadAll
		  '#If DebugBuild Then
		  'Peek = Me.Lookahead
		  '#endif
		  'WaitForDataLen = contentlength
		  'Return
		  'End If
		  'Else
		  'ActiveResponse.MessageBody = Me.ReadAll
		  '#If DebugBuild Then
		  'Peek = Me.Lookahead
		  '#endif
		  'End If
		  'Try
		  'RaiseEvent Response(ActiveResponse, OutstandingRequests.Pop)
		  'Catch Err As OutOfBoundsException ' no request was pending!
		  'Me.Purge
		  'Me.Disconnect
		  'Return
		  'End Try
		  'ActiveResponse = Nil
		  'Loop
		  'End If
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub SendRequest(HTTPRequest As HTTP.Request, TimeoutSeconds As Integer = - 1)
		  Dim URI As HTTP.URI = HTTPRequest.Path
		  HTTPRequest.SetHeader("Connection") = "close"
		  HTTPRequest.SetHeader("Host") = URI.FQDN
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
		  
		  Me.Write(HTTPRequest.ToString)
		  Me.Flush
		  OutstandingRequests.Insert(0, HTTPRequest)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TimeOutHandler(Sender As Timer)
		  #pragma Unused Sender
		  Me.Disconnect
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Response(ServerResponse As HTTP.Response, OriginalRequest As HTTP.Request)
	#tag EndHook


	#tag Property, Flags = &h21
		Private DataBuffer As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private OutStandingRequests() As HTTP.Request
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ResponseLength As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private TimeOutTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private WaitForDataLen As UInt64
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
