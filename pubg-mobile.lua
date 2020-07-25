local pubg = {}
local mouse = {}

mouse.BUTTON_NIL        = 0 
mouse.BUTTON_LEFT       = 1
mouse.BUTTON_RIGHT      = 2
mouse.BUTTON_MID        = 3
mouse.BUTTON_FORWARD    = 4
mouse.BUTTON_BACK       = 5
mouse.BUTTON_G          = 6
mouse.isDebug           = true

function mouse:outputLogMessage (message)
    if self.isDebug == true then
        OutputLogMessage(message .. '\n')
    end
end

pubg.keyShutdown    = mouse.BUTTON_G
pubg.keyWeaponM416  = mouse.BUTTON_BACK
pubg.keyWeaponAkm = mouse.BUTTON_FORWARD

pubg.currentWeapon      = 'NIL'
pubg.currentScope       = 'SCOPE_X1'
pubg.currentIncrement   = 0 
pubg.isGKeyPressed      = false
pubg.isOKeyPressed      = false
pubg.isMousePressed     = false
pubg.currentWeaponIndex = 0

pubg.weaponData = {
    AKM = {
        SHOOT_AUTO      = true,
        SHOOT_INTERVAL  = 30,
        OFFSET = 8,
    },
    M416 = {
        SHOOT_AUTO      = true,
        SHOOT_INTERVAL  = 20,
        OFFSET = 4,
    },
}


function pubg:antiShootAuto(event, arg, family)
    local offset = self.weaponData[self.currentWeapon]['OFFSET']
    local currentScope       = 'SCOPE_X1'
    local count = 0
    repeat
        Sleep(15)

        if (count > 0 and count == 10) then
            MoveMouseRelative(-1, offset)
        elseif (count > 0 and count == 20) then
            MoveMouseRelative(1, offset)
        else
            MoveMouseRelative(0, offset)
        end

        count = count +1
        mouse:outputLogMessage('OFFSET: '..tostring(offset))
    until not IsMouseButtonPressed(mouse.BUTTON_LEFT)
end

function pubg:antiShutdown(event, arg, family)
    pubg.currentWeapon = 'NIL'
    mouse:outputLogMessage('anti shutdown')
end


function pubg:onEvent(event, arg, family)
    --mouse:outputLogMessage('event='..tostring(event)..', arg='..tostring(arg)..', family='..tostring(family))
    if event == 'PROFILE_ACTIVATED' then
        EnablePrimaryMouseButtonEvents(true)
    elseif event == 'PROFILE_DEACTIVATED' then
        EnablePrimaryMouseButtonEvents(false)
        return
    end

    if event == 'MOUSE_BUTTON_PRESSED' and arg == mouse.BUTTON_G then
        self.isGKeyPressed = true
        self.isOKeyPressed = false
    elseif event == 'MOUSE_BUTTON_RELEASED' and arg == mouse.BUTTON_G then
        self.isGKeyPressed = false
    end

    if event == 'MOUSE_BUTTON_PRESSED' and arg ~= mouse.BUTTON_G then
        self.isOKeyPressed = true
    end

    if self.isGKeyPressed == true and self.isOKeyPressed == false then
        self:antiShutdown(event, arg, family)
    end

    if event == 'MOUSE_BUTTON_PRESSED' and arg == mouse.BUTTON_LEFT and self.isGKeyPressed == false then
        self.isMousePressed = true
    elseif event == 'MOUSE_BUTTON_RELEASED' and arg == mouse.BUTTON_LEFT then
        self.isMousePressed = false
    end

    if event == 'MOUSE_BUTTON_RELEASED' and arg == self.keyWeaponAkm and self.isGKeyPressed == false then
        self.currentScope  = 'SCOPE_X1'
        self.currentWeapon = 'AKM'
    elseif event == 'MOUSE_BUTTON_RELEASED' and arg == self.keyWeaponM416  and self.isGKeyPressed == false then
        self.currentScope  = 'SCOPE_X1'
        self.currentWeapon = 'M416'
    end

    if event == 'MOUSE_BUTTON_PRESSED' and arg == mouse.BUTTON_LEFT and self.currentWeapon ~= 'NIL' then
        mouse.outputLogMessage('Current Weapon: ' .. self.currentWeapon)
        self:antiShootAuto(event, arg, family)
    end
end


function OnEvent(event, arg, family)
    pubg:onEvent(event, arg, family)
end