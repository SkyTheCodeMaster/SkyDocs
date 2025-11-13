local e=require("cc.expect").expect local t="wss://ccsql.skystuff.games"local
a={}local o={__index=a}function a:fetch(i,...)local
n=textutils.serializeJSON({i,...})self.ws.send(n)local
s=textutils.unserializeJSON(self.ws.receive())return s end function
a:fetchrow(h,...)local r=textutils.serializeJSON({h,...})self.ws.send(r)local
d=textutils.unserializeJSON(self.ws.receive())return d[1]end function
a:execute(l,...)local
u=textutils.serializeJSON({l,...})self.ws.send(u)self.ws.receive()end function
a:close()self.ws.close()local function
c()error("This connection is closed.",0)end self.fetch=c self.fetchrow=c
self.execute=c end function
open(m,f,w)e(1,m,"string")e(2,f,"string","nil")e(3,w,"string","nil")local
y=http.websocket(t)y.send(textutils.serializeJSON({url=m,username=f,password=w,connect=true}))local
p=y.receive()if p~="ok"then return false end local v={ws=y}return
setmetatable(v,o)end
return{open=open,}