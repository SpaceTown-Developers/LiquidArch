/*====================================================================================
	Util Timers
====================================================================================*/
timer.Create( "Rusketh_Second", 1, 0, function( )
	hook.Call( "EverySecond", GAMEMODE, SysTime( ) )
end )

timer.Create( "Rusketh_Minute", 60, 0, function( )
	hook.Call( "EveryMinute", GAMEMODE, SysTime( ) )
end )

timer.Create( "Rusketh_HalfHour", 60 * 30, 0, function( )
	hook.Call( "EveryHalfHour", GAMEMODE, SysTime( ) )
end )

timer.Create( "Rusketh_Hour", 60 * 60, 0, function( )
	hook.Call( "EveryHour", GAMEMODE, SysTime( ) )
end )

timer.Create( "Rusketh_Day", 60 * 60 * 24, 0, function( )
	hook.Call( "EveryDay", GAMEMODE, SysTime( ) )
end )

timer.Create( "Rusketh_Week", 60 * 60 * 24 * 7, 0, function( )
	hook.Call( "EveryWeek", GAMEMODE, SysTime( ) )
end )


/*====================================================================================
	Time Functions
====================================================================================*/
function LA:FormatTime( Time ) -- Source: Evolve - Overv
	if Time < 0 then
		return "Forever"
	
	elseif Time < 60 then
		if T == 1 then
			return "one second"
		else
			return Time .. " seconds"
		end
		
	elseif Time < 3600 then
		local Mins = math.ceil( Time / 60 )
		if Mins == 1 then 
			return "one minute"
		else
			return Mins .. " minutes"
		end
		
	elseif Time < 24 * 3600 then
		local Hours = math.ceil( Time / 3600 )
		if Hours == 1 then
			return "one hour"
		else
			return Hours .. " hours"
		end
		
	elseif Time < 24 * 3600 * 7 then
		local Days = math.ceil( Time / ( 24 * 3600 ) )
		if Days == 1 then
			return "one day"
		else
			return Days .. " days"
		end
		
	elseif Time < 24 * 3600 * 30 then
		local Weeks = math.ceil( Time / ( 24 * 3600 * 7 ) )
		if Weeks == 1 then
			return "one week"
		else
			return Weeks .. " weeks"
		end
	else
		local Months = math.ceil( Time / ( 24 * 3600 * 30 ) )
		if Months == 1 then
			return "one month"
		else
			return Months  .. " months"
		end
	end
end

function LA:TableToTime( Table )
	return os.time( {
		year =  Table.Years or 0,
		month = Table.Months or 0,
		day =   Table.Days or 0,
		hour =  Table.Hours or 0,
		min =   Table.Minutes or 0,
		sec =   Table.Seconds or 0,
	} )
end

local Times = {
        s = 1, -- Second
        m = 60, -- Minute
        h = 3600, -- Hour
        d = 86400, -- Day
        w = 604800, -- Week
		-- n = 2419200, -- Month
		y = 29030400 -- Year
		
}

function LA:StringToTime( Message )
	local Time = tonumber( Message )
	
	if ( !Time ) then
		Time = 0
		
		string.gsub( Message, "([a-zA-Z])([0-9]+)", function( Unit, Duration )
			local Mul = Times[Unit]
			
			if ( Mul ) then
				Time = Time + ( Mul * tonumber( Duration ) )
			else
				return false
			end
		end )
	end
	
	return Time
end
 