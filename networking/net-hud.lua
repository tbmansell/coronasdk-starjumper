netHud = {
    created = false,
    text = "",
    statusCount = 0,
}


function netHud:create()
    self.group     = display.newGroup()
    self.statusBgr = display.newRect(self.group, 400,490, 700, 170)
    self.lblStatus = display.newText({parent=self.group, text="", x=420, y=500, width=500, height=150, fontSize=16, align="left"})
    
    self.statusBgr:setFillColor(0,0,0,0.5)
end


function netHud:destroy()
    if self.group then
        self.group:removeSelf()
        self.group = nil
    end
end


function netHud:status(status, lag)
    self.statusCount = self.statusCount + 1

    if lag == nil then lag = "" else lag = " (lag "..lag..")" end

    self.text = self.statusCount..". "..status..lag.."\n"..self.text

    print(self.statusCount..". "..status)

    if self.group then
        self.lblStatus.text = self.text
        self.statusBgr:toFront()
        self.lblStatus:toFront()
    end
end
