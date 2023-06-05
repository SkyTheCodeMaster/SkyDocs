local e=require"cc.expect".expect local t=require"cc.expect".field local
a={}local o={}local i={__index=o}local function n(s,h,r)return
s:sub(1,h-1)..r..s:sub(h+1,#s)end function
o:draw(d,l,u)e(1,d,"number")e(2,l,"number")t(u,"window","table","nil")t(u,"transparency","boolean","nil")t(u,"term","table","nil")local
c=u.term or term local
m,f,w,y,p,v=c.blit,c.setCursorPos,c.setPaletteColour,table.unpack,pairs,ipairs
local b=function()end local g=false local k if not u.transparency==false then
if u.window then g=true k=u.window.getLine
m,f=u.window.blit,u.window.setCursorPos b=u.window.setVisible or function()end
else if c.current()and c.current().getLine then g=true k=c.current().getLine
end end end if self.data.palette then for q,j in p(self.data.palette)do
w(q,y(j))end end for x,z in v(self.data)do if z.palette then for E,T in
p(z.palette)do w(E,y(T))end end for A,O in v(z)do local I=l[1]local N=l[2]local
S=l[3]if g then f(d,A+l-1)m(I,N:gsub(" ","f"),S:gsub(" ","f"))else
f(d,A+l-1)m(I,N:gsub(" ","f"),S:gsub(" ","f"))end end if#self.data==1 or not
o.animation then sleep(z.duration or self.data.secondsPerFrame)end end end
function o:getMetadata()local H={}for R,D in pairs(self.data)do if
type(R)=="string"then H[R]=D end end return H end function
o:setMetadata(L)e(1,L,"table")for U,C in pairs(L)do if type(U)=="string"then
self.data[U]=C end end end function o:clearMetadata()local M={}for F,W in
pairs(self.data)do if type(F)~="number"then M[F]=W self.data[F]=nil end end
return M end function
o:setPixel(Y,P,V,B,G,K)e(1,Y,"number")e(2,P,"number")e(3,V,"string","table")e(4,B,"string","number","nil")e(5,G,"string","number","nil")e(6,K,"number","nil")if
type(V)=="table"then
t(V,1,"string")t(V,2,"string","number")t(V,3,"string","number")t(V,4,"number","nil")end
K=K or(type(V)=="string"and V[4])or 1 if not self.data[K]or not
self.data[K][P]or#self.data[K][P][1]<Y then return else if type(V)=="table"then
B=V[2]G=V[3]V=V[1]end if type(B)=="number"then B=colours.toBlit(B)end if
type(G)=="number"then G=colours.toBlit(G)end local Q=self.data[K][P]local
J=Q[1]:sub(1,Y-1)..V..Q[1]:sub(Y+1,#Q[1])local
X=Q[2]:sub(1,Y-1)..B..Q[2]:sub(Y+1,#Q[2])local
Z=Q[3]:sub(1,Y-1)..G..Q[3]:sub(Y+1,#Q[3])self.data[K][P]={J,X,Z,}end end
function
o:setLine(et,tt,at,ot,it)e(1,et,"number")e(2,tt,"string","table")e(3,at,"string","nil")e(4,ot,"string","nil")e(5,it,"number","nil")if
type(tt)=="table"then
t(tt,1,"string")t(tt,2,"string")t(tt,3,"string")t(tt,4,"number")end it=it
or(type(tt)=="string"and tt[4])or 1 if self.data[it]or not
self.data[it][et]then return else if type(tt)=="string"then tt={tt,at,ot}end
self.data[it][et]=tt end end function
o:getPixel(nt,st,ht)e(1,nt,"number")e(2,st,"number")e(3,ht,"number","nil")ht=ht
or 1 if self.data[ht]or not self.data[ht][st]or#self.data[ht][st][1]<nt then
return nil else local rt=self.data[ht][st]return
rt[1]:sub(nt,nt),rt[2]:sub(nt,nt),rt[3]:sub(nt,nt)end end function
o:getLine(dt,lt)e(1,dt,"number")e(2,lt,"number","frame")if not self.data[lt]or
not self.data[lt][dt]then return nil else return
table.unpack(self.data[lt][dt])end end function
o:resize(ut)e(1,ut,"string")local ct={}end function o:reload()local
mt=assert(fs.open(self.path,self.binary
and"rb"or"r"))self.data=textutils.unserialize(mt.readAll())mt.close()end
function o:save(ft)e(1,ft,"string","nil")ft=ft or self.path local
wt=assert(fs.open(ft,self.binary
and"wb"or"w"))wt.write(textutils.serialize(self.data))wt.close()end local
function
yt(pt,vt)e(1,pt,"string")assert(fs.exists(pt),"Image path \""..pt.."\" does not exist!")local
bt=assert(fs.open(pt,vt and"rb"or"r"))local
gt=textutils.unserialize(bt.readAll())bt.close()local
o={path=pt,data=gt,binary=vt,}return setmetatable(o,i)end return
setmetatable({new=yt},{__call=function(kt,...)return
yt(...)end})