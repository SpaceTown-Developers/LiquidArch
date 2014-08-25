----------------------------------------------------------------
-- Notify
----------------------------------------------------------------
notification._AddProgress = notification.AddProgress
vgui._Create = vgui.Create

function notification.AddProgress( ... )
	local Panel

	function vgui.Create( ... )
		Panel = vgui._Create( ... )
		return Panel
	end

	notification._AddProgress( ... )

	vgui.Create = vgui._Create

	return Panel
end