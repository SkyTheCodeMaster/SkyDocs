local e=require("cc.expect").expect local t=require("cc.expect").field local
function a(o)e(o,"number","string")if type(o)=="number"then return
colours.toBlit(o)elseif type(o)=="string"then if#o==1 then return o else
error("Invalid argument: string too long")end end end local i={}local n={}local
s={}local h={}local r=math.random local function d()local
l='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'return
string.gsub(l,'[xy]',function(u)local c=(u=='x')and r(0,0xf)or r(8,0xb)return
string.format('%x',c)end)end local m={}function
m:new()self.children={}self.listeners={}self.id=d()self.parent=nil end function
m:test_hit(f)if#self.children==0 then return false end for w,y in
pairs(self.children)do if y:test_hit(f)then return y end end return false end
function m:_child_index(p)e(1,p,"table")local v if type(p)=="table"then v=p.id
elseif type(p)=="string"then v=p end for b,g in ipairs(self.children)do if
g.id==v then return b end end return-1 end function
m:append_child(k)e(1,k,"table")self.children[#self.children+1]=k k.parent=self
end function m:remove_child(q)e(1,q,"table")local j=self:_child_index(q)if
j==-1 then return false end table.remove(self.children,j)q.parent=nil return
true end function m:draw(x)e(1,x,"table")for z,E in pairs(self.children)do
E:draw(x)end end function m:real_origin()local
T,A=self.origin[1],self.origin[2]if self.parent then local
O,I=self.parent:real_origin()T=T+O A=A+I end return T,A end function
m:add_event_listener(N,S)e(1,N,"string")e(2,S,"function")if
self.listeners[N]then table.insert(self.listeners[N],S)else
self.listeners[N]={S}end end function
m:remove_event_listener(H,R)e(1,H,"string")e(2,R,"function")if
self.listeners[H]then for D,L in ipairs(self.listeners[H])do if L==R then
table.remove(self.listeners[H],D)end end end end function
m:call_event_listeners(U)e(1,U,"table")if self.disabled then return end local
C=U[1]if self.listeners[C]then for M,F in ipairs(self.listeners[C])do
F(self,U)end end end function m:mouse_loop(W)e(1,W,"boolean","nil")local Y if W
then
Y={"mouse_click","mouse_drag","mouse_scroll","mouse_up","monitor_touch"}else
Y={"mouse_click","mouse_drag","mouse_scroll","mouse_up"}end while true do local
P={os.pullEvent()}local V=false for B,G in ipairs(Y)do if P[1]==G then V=true
end end if V then local K,Q=P[3],P[4]local J=self:test_hit({K,Q})if J then
J:call_event_listeners(P)end end end end local
X=setmetatable({Super=m},{__index=m})function
i.new_polygon(Z,et,tt)error("Polygons not implemented")end function
X:draw()error("Polygons not implemented")end local
at=setmetatable({Super=m},{__index=m})function at.new(ot)local
it={size=ot.size,origin=ot.origin,border=a(ot.border),fill=a(ot.fill),pixel=ot.pixel}m.new(it)return
setmetatable(it,{__index=at})end function at:edit(nt)self.size=nt.size or
self.size self.origin=nt.origin or self.origin self.border=a(nt.border)or
self.border self.fill=a(nt.fill)or self.fill self.pixel=nt.pixel or self.pixel
end function at:_draw_chars(st)local ht,rt=st.getCursorPos()local
dt,lt=self:real_origin()local ut=self.size[2]local ct=self.size[1]if
self.border==self.fill then local mt=(" "):rep(ct)local ft=self.fill:rep(ct)for
wt=lt,ut+lt do st.setCursorPos(dt,wt)st.blit(mt,ft,ft)end else local
yt=(" "):rep(ct)for pt=lt,ut+lt-1 do local vt if(pt==lt)or(pt==ut+lt-1)then
vt=self.border:rep(ct)else vt=self.border..self.fill:rep(ct-2)..self.border end
st.setCursorPos(dt,pt)st.blit(yt,vt,vt)end end st.setCursorPos(ht,rt)end local
bt={"\x97","\x83","\x94","\x95","\x00","\x95","\x8A","\x8F","\x85"}local
gt={false,false,true,false,false,true,true,true,true}local function
kt(qt,jt,xt)local zt=bt[qt]local Et=gt[qt]if Et then return zt,xt,jt else
return zt,jt,xt end end function at:_draw_pixels(Tt)local
At,Ot=Tt.getCursorPos()local It,Nt=self:real_origin()local St=self.size[1]local
Ht=self.size[2]local Rt,Dt,Lt=kt(1,self.border,self.fill)local Ut=Rt local
Ct=Dt local Mt=Lt
Rt,Dt,Lt=kt(2,self.border,self.fill)Ut=Ut..Rt:rep(St-2)Ct=Ct..Dt:rep(St-2)Mt=Mt..Lt:rep(St-2)Rt,Dt,Lt=kt(3,self.border,self.fill)Ut=Ut..Rt
Ct=Ct..Dt Mt=Mt..Lt
Tt.setCursorPos(It,Nt)Tt.blit(Ut,Ct,Mt)Rt,Dt,Lt=kt(4,self.border,self.fill)Ut=Rt
Ct=Dt Mt=Lt
Rt,Dt,Lt=kt(5,self.border,self.fill)Ut=Ut..Rt:rep(St-2)Ct=Ct..Dt:rep(St-2)Mt=Mt..Lt:rep(St-2)Rt,Dt,Lt=kt(6,self.border,self.fill)Ut=Ut..Rt
Ct=Ct..Dt Mt=Mt..Lt for Ft=2,Ht-1 do
Tt.setCursorPos(It,Nt+Ft-1)Tt.blit(Ut,Ct,Mt)end
Rt,Dt,Lt=kt(7,self.border,self.fill)Ut=Rt Ct=Dt Mt=Lt
Rt,Dt,Lt=kt(8,self.border,self.fill)Ut=Ut..Rt:rep(St-2)Ct=Ct..Dt:rep(St-2)Mt=Mt..Lt:rep(St-2)Rt,Dt,Lt=kt(9,self.border,self.fill)Ut=Ut..Rt
Ct=Ct..Dt Mt=Mt..Lt
Tt.setCursorPos(It,Nt+self.size[2]-1)Tt.blit(Ut,Ct,Mt)Tt.setCursorPos(At,Ot)end
function at:test_hit(Wt)local Yt=self.Super.test_hit(self,Wt)if Yt then return
Yt end local Pt,Vt=self:real_origin()local Bt=Pt local Gt=Pt+self.size[1]local
Kt=Vt local Qt=Vt+self.size[2]if Bt<=Wt[1]and Wt[1]<=Gt and Kt<=Wt[2]and
Wt[2]<=Qt then return self end return false end function at:draw(Jt)if
self.pixel then self:_draw_pixels(Jt)else self:_draw_chars(Jt)end
self.Super.draw(self,Jt)end local
Xt=setmetatable({Super=m},{__index=m})function
Xt.new(Zt)t(Zt,"size","table")t(Zt,"origin","table")t(Zt,"text","string")t(Zt,"colour","string","number")t(Zt,"background","boolean","nil")if
Zt.background then
t(Zt,"border","string")t(Zt,"border_colour","string","number")end
t(Zt,"background_fill","string","number")t(Zt,"justify","string","nil")t(Zt,"alignment","string","nil")t(Zt,"wordwrap","string","nil")local
ea={size=Zt.size,origin=Zt.origin,text=Zt.text,colour=a(Zt.colour),background=Zt.background
or false,border=Zt.border,border_colour=a(Zt.border_colour or
colours.black),background_fill=a(Zt.background_fill or
colours.black),justify=Zt.justify or"center",alignment=Zt.alignment
or"center",wordwrap=Zt.wordwrap or"none",}m.new(ea)if ea.background then local
ta=false if ea.border=="none"then ea.border_colour=ea.background_fill elseif
ea.border=="pixel"then ta=true end
ea._bg_rectangle=i.new("rectangle",{origin={0,0},size=ea.size,border=ea.border_colour,fill=ea.background_fill,pixel=ta})ea._bg_rectangle.parent=ea
end return setmetatable(ea,{__index=Xt})end local function
aa(oa,ia)e(1,oa,"string")e(1,ia,"string","nil")ia=ia or","local na={}for sa in
oa:gmatch("([^"..ia.."]+)")do table.insert(na,sa)end return na end function
Xt:draw(ha)local ra,da=self:real_origin()local la=self.border~="none"local
ua={}local ca,ma=self.size[1],self.size[2]if la then ca=ca-2 ma=ma-2 end if
self.wordwrap=="none"then ua=aa(self.text,"\n")elseif
self.wordwrap=="space"then local fa=aa(self.text," ")local wa=""for ya,pa in
ipairs(fa)do if(#wa+#pa+1)>ca then ua[#ua+1]=wa wa=pa else wa=wa.." "..pa end
end ua[#ua+1]=wa else for va=1,#self.text,ca do
ua[#ua+1]=self.text:sub(va,va+ca-1)end end if self._bg_rectangle then
self._bg_rectangle:draw(ha)end local ba if self.alignment=="top"then ba=da if
la then ba=ba+1 end elseif self.alignment=="center"then
ba=math.floor((da+(self.size[2]/2))-(#ua/2))elseif self.alignment=="bottom"then
ba=da+self.size[2]-#ua if la then ba=ba-1 end end
ha.setTextColour(colours.fromBlit(self.colour))ha.setBackgroundColour(colours.fromBlit(self.background_fill))for
ga,ka in ipairs(ua)do if self.justify=="left"then local qa=ra if la then
qa=ra+1 end ha.setCursorPos(qa,ba+ga-1)ha.write(ka)elseif
self.justify=="center"then local
ja=math.floor((ra+(self.size[1]/2))-(#ka/2))ha.setCursorPos(ja,ba+ga-1)ha.write(ka)elseif
self.justify=="right"then local xa=ra+self.size[1]-#ka if la then xa=xa-1 end
ha.setCursorPos(xa,ba+ga-1)ha.write(ka)end end end function
Xt:test_hit(za)local Ea=self.Super.test_hit(self,za)if Ea then return Ea end
local Ta,Aa=self:real_origin()local Oa=Ta local Ia=Ta+self.size[1]local Na=Aa
local Sa=Aa+self.size[2]if Oa<=za[1]and za[1]<=Ia and Na<=za[2]and za[2]<=Sa
then return self end return false end local
Ha=setmetatable({Super=m},{__index=m})function
Ha.new(Ra)t(Ra,"size","table")t(Ra,"origin","table")t(Ra,"colour","number","string")t(Ra,"background","number","string")local
Da={size=Ra.size,origin=Ra.origin,colour=a(Ra.colour),background=a(Ra.background),border=Ra.border,focus=false,text="",_index=0,_text_offset=0,}if
Ra.border then Da.border_colour=Ra.border_colour or Da.colour
Da.border_pixel=Ra.border_pixel
Da._bg_rectangle=i.new("rectangle",{origin={0,0},size=Da.size,border=Da.border_colour,fill=Da.background,pixel=Da.border_pixel})Da._bg_rectangle.parent=Da
end m.new(Da)return setmetatable(Da,{__index=Ha})end function
Ha:add_char(La)local Ua=self.text:sub(0,self._index)local
Ca=self.text:sub(self._index+1)self.text=Ua..La..Ca self._index=self._index+#La
local Ma=not self.border and self.size[1]or self.size[1]-2 if#self.text>=Ma
then self._text_offset=#self.text-Ma end end function Ha:remove_char()local
Fa=self.text:sub(0,self._index-1)local
Wa=self.text:sub(self._index+1)self.text=Fa..Wa
self._text_offset=math.max(0,self._text_offset-1)self._index=self._index-1 end
function Ha:scroll(Ya)local Pa=not self.border and self.size[1]or
self.size[1]-2 if(0>Ya)then
self._text_offset=math.max(0,self._text_offset-Ya)else
self._text_offset=math.min(self._text_offset+Ya,Pa)end end function
Ha:draw(Va,Ba)local Ga=not self.border and self.size[1]or self.size[1]-2 local
Ka=self.text:sub(0+self._text_offset,Ga+self._text_offset)local
Qa,Ja=self:real_origin()local Xa=Qa+math.min(self._index,self.size[1])if
self.border then self._bg_rectangle:draw(Va)Va.setCursorPos(Qa+1,Ja+1)Xa=Xa+1
else Va.setCursorPos(Qa,Ja)end
Va.setTextColour(colours.fromBlit(self.colour))Va.setBackgroundColour(colours.fromBlit(self.background))Va.write(Ka)if
Ba then Va.setCursorPos(Xa,Ja+(self.border and 1 or
0))Va.setCursorBlink(true)else Va.setCursorPos(1,1)Va.setCursorBlink(false)end
end function Ha:test_hit(Za)local eo=self.Super.test_hit(self,Za)if eo then
return eo end local to,ao=self:real_origin()local oo=to local
io=to+self.size[1]local no=ao local so=ao+self.size[2]if oo<=Za[1]and Za[1]<=io
and no<=Za[2]and Za[2]<=so then return self end return false end function
Ha:loop(ho)while true do local ro={os.pullEvent()}if not self.disabled then if
ro[1]=="mouse_click"then local lo,uo=ro[3],ro[4]local
co=self:test_hit({lo,uo})if co==self then self.focus=true if
type(self.on_focus)=="function"then self:on_focus()end else self.focus=false
end end if ro[1]=="key"and ro[2]==28 and self.focus then if
type(self.on_enter)=="function"then self:on_enter()end if ho then
self.focus=false end end if ro[1]=="key"and ro[2]==14 and self.focus then
self:remove_char()if type(self.on_change)then self:on_change()end end if
ro[1]=="char"and self.focus then local mo=ro[2]self:add_char(mo)if
type(self.on_change)then self:on_change()end end end end end local
fo=setmetatable({Super=m},{__index=m})function
fo.new(wo)t(wo,"size","table")t(wo,"origin","table")t(wo,"colour","number","string")t(wo,"background","number","string")t(wo,"mode","string","nil")t(wo,"value","number","nil")local
yo={size=wo.size,origin=wo.origin,colour=a(wo.colour),background=a(wo.background),border=wo.border,mode=wo.mode
or"full",direction=wo.direction or"right",value=wo.value or 0}if wo.border then
yo.border_colour=wo.border_colour or yo.colour yo.border_pixel=wo.border_pixel
yo._bg_rectangle=i.new("rectangle",{origin={0,0},size=yo.size,border=yo.border_colour,fill=yo.background,pixel=yo.border_pixel})yo._bg_rectangle.parent=yo
end m.new(yo)return setmetatable(yo,{__index=fo})end function
fo:_blit_line_right(po,vo,bo)e(1,po,"number")e(2,vo,"number")e(3,bo,"string")if
bo=="full"then local go=(" "):rep(po)local ko=("f"):rep(po)local
qo=math.floor(vo*po)local jo=math.ceil((1-vo)*po)local
xo=self.colour:rep(qo)..self.background:rep(jo)return{go,ko,xo}elseif
bo=="half"then elseif bo=="sixth"then end end function fo:draw(zo)if
self._bg_rectangle then self._bg_rectangle:draw(zo)end local
Eo,To=self:real_origin()if self.direction=="right"then local Ao=self.border and
1 or 0 local Oo=To+Ao local Io=(To+self.size[2])-Ao-1 local
No=(self.size[1])-Ao*2 local So=(Eo)+Ao for Ho=Oo,Io do local
Ro=self:_blit_line_right(No,self.value,self.mode)zo.setCursorPos(So,Ho)zo.blit(Ro[1],Ro[2],Ro[3])end
end end local Do={rectangle=at,textbox=Xt,input=Ha,progress=fo,}function
i.new(Lo,Uo)if not Do[Lo]then error("Constructor not found!")end return
Do[Lo].new(Uo)end return
i