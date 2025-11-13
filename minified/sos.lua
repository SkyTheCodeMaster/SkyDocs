local e=require("cc.expect").expect local function
t(a,o)e(1,a,"string")e(2,o,"string")local
i=fs.open(a,"w")i.write(o)i.close()end local function n(s,h)local
r=textutils.serialize(h)t(s,r)end local function
d()return{{{{},{},{},{},},{{},{},{},{},},{{},{},{},{},},{{},{},{},{},},},}end
local function l(u)for c,m in ipairs(u)do for f,w in ipairs(m)do for y,p in
ipairs(w)do if not p.name then return c,f,y end end end end return#u+1,1,1 end
local function v(b,...)local g={...}local k if type(g[1])=="table"then
k=g[1]e(2,k["name"],"string")e(3,k["image"],"string")e(4,k["program"],"string")elseif
type(g[1])=="string"then
e(2,g[2],"string")e(3,g[3],"string")e(4,g[4],"string")k={name=g[1],image=g[2],program=g[3]}end
local q,j,x=l()if b[q]then b[q][j][x]=k else b[q]={y={}}b[q][j][x]=k end end
local function z()local E if SkyOS and SkyOS.settings and
SkyOS.settings.timezone then E=SkyOS.settings.timezone else E=0 end local
T=math.floor(os.epoch("utc")/1000)+3600*E local A=os.date("!*t",T)local
O={sec=A.sec,min=A.min,hour=A.hour,day=A.day,month=A.month,year=A.year,}for I,N
in pairs(O)do local S=tostring(N)if S:len()==1 then S="0"..S end O[I]=S end
local
H="screenshots/"..O.hour..O.min..O.sec.."-"..O.day..O.month..O.year..".skimg"return
H end local function R()if not term.current().getLine then return end local
D,L=term.getSize()local U={}for C=1,L do local
M,F,W=term.current().getLine(C)U[C]={M,F,W,C}end local
Y=os.getComputerLabel()or"SkyOS"local
P={x=D,y=L,creator=Y,locked=false,type=1,}local V={attributes=P,data=U}local
B=z()n(B,V)end
return{screenshot=R,desktop={nextAvailable=l,insertApp=v,genDesktop=d,},}