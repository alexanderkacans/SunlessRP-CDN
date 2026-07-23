KVS = KVS or { }
KVS.TOAST_SEVERITIES = KVS.TOAST_SEVERITIES or { }

local config = KVS.GetConfig

if CLIENT then
	KVS.TOAST_QUEUE = { }
	KVS.PENDING_TOAST = { }

	-- Function used to register any severity for an easier way to call toast
	function KVS:RegisterToastSeverity( severity, color, icon )
		if ( KVS.TOAST_SEVERITIES[ severity ] ) then
			error( 'errors.toast.severity_alleady_register' .. tostring( severity ) )
			return
		end

		if ( not IsColor( color ) ) then
			error( 'errors.toast.bad_type_color' .. tostring( color ) )
			return
		end

		if ( not istable( icon ) and not icon.font and not icon.unicode ) then
			error( 'errors.toast.invalid_icon' )
			return
		end
		KVS.TOAST_SEVERITIES[ severity ] = { color = color, icon = icon }
	end

	-- Internal function used to display toast or sending in pending queue if not enought space on the screen
	function KVS:ShowToastOnScreen( toast )
		if ( KVS:GetNextToastPosition( ) + toast:GetTall( ) > ScrH( ) ) then
			table.insert( KVS.PENDING_TOAST, toast )
		else
			toast:SetPosition( ScrW() - ( config( 'vgui.toast.default_margin', true ) or 15 ) - toast:GetWide( ), KVS:GetNextToastPosition( ) )
			toast:Display( )
			table.insert( KVS.TOAST_QUEUE, toast )
			KVS:MoveToTop( )
		end
	end

	-- Internal functions used to handle pending toast
	function KVS:HandlePendingToasts( )
		for _, toast in pairs( KVS.PENDING_TOAST ) do
			table.RemoveByValue( KVS.PENDING_TOAST, toast )
			KVS:ShowToastOnScreen( toast )
		end
	end

	-- Internal function used to get the next available position on screen for a toast
	function KVS:GetNextToastPosition( )
		if ( #KVS.TOAST_QUEUE > 0 ) then
			local last_toast = KVS.TOAST_QUEUE[ #KVS.TOAST_QUEUE ]
			return last_toast:GetTall( ) + last_toast.OriginalY + ( config( 'vgui.toast.default_margin', true ) or 15 )
		else
			return config( 'vgui.toast.default_margin', true ) or 15
		end
	end

	-- Internal function used to move to top all toast if some other disapear 
	function KVS:MoveToTop( )
		if ( #KVS.TOAST_QUEUE > 0 ) then
			local next_y = config( 'vgui.toast.default_margin', true ) or 15
			for _, toast in pairs( KVS.TOAST_QUEUE ) do
				if ( next_y ~= toast.OriginalY ) then
					toast.OriginalY = next_y
					toast:MoveTo( toast.OriginalX, next_y, 1 )
				end
				next_y = next_y + toast:GetTall( ) + ( config( 'vgui.toast.default_margin', true ) or 15 )
			end
		end
	end

	-- Internal function used to validate toast's data
	function KVS:_IsValidToast( severity, message, duration, color, icon, target )
		if ( target and isstring( target ) and target ~= 'ALL' or target and isentity( target ) and not target:IsPlayer( ) or target and not isstring( target ) and not istable( target ) ) then
			error( 'errors.toast.invalid_target' )
			return false
		end

		if ( not severity or not KVS.TOAST_SEVERITIES[ severity ] ) then
			error( 'errors.toast.invalid_severity' .. tostring( severity ) )
			return false
		end

		if ( icon and ( not istable(icon) or not icon.font or not icon.size or not icon.unicode ) ) then
			error( 'errors.toast.invalid_icon' )
			return false
		end

		if ( not isstring( message ) ) then
			error( 'errors.toast.invalid_message' .. tostring( message ) )
			return false
		end

		return true
	end

	net.Receive( 'kvs.on.server.send.toast', function( len, ply ) -- TODO: Must be reviewed when doing a better net handler
		local data = util.JSONToTable( util.Decompress( net.ReadData( len / 8 ) ) )
		KVS.AddToast( data.severity, data.message, nil, data.duration or nil, data.color or nil, data.icon or nil )
	end)
end

-- Function used to add a toast on a player screen
function KVS.AddToast( severity, message, target, duration, color, icon )
	if ( SERVER ) then
		local data = util.TableToJSON( { severity = severity, message = message, duration = duration, color = color, icon = icon } )
		local compressed_data = util.Compress( data, string.len( data ) )

		if ( isentity( target ) and target:IsPlayer( ) or istable( target ) ) then
			net.Start( 'kvs.on.server.send.toast' )
				net.WriteData( compressed_data, string.len( compressed_data ) )
			net.Send( target )
		elseif ( target == 'ALL' ) then
			net.Start( 'kvs.on.server.send.toast' )
				net.WriteData( compressed_data, string.len( compressed_data ) )
			net.Broadcast( )
		end
	elseif ( CLIENT ) then
		if ( KVS:_IsValidToast( severity, message, duration, color, icon, target ) ) then
			local severity_config = KVS.TOAST_SEVERITIES[ severity ]
			local toast = vgui.Create( 'KVS.Toast' )
				:SetMainColor( color or severity_config.color )
				:SetDuration( duration or config( 'vgui.toast.default_duration', true ) or 10 )
				:SetIcon( severity_config.icon.font, severity_config.icon.unicode, color or severity_config.color )
				:SetContent( message )
			toast:SetVisible( false )

			if ( icon ) then
				toast:SetIcon( icon.font, icon.unicode, color or severity_config.color )
			end

			toast.PostClose = function ( )
				table.RemoveByValue( KVS.TOAST_QUEUE, toast )
				KVS:MoveToTop( )
				KVS:HandlePendingToasts( )
			end

			KVS:ShowToastOnScreen( toast )
			return toast
		end
	end
end
