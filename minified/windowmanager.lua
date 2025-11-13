local e=require("cc.expect").expect local t=require("cc.require").make local
a=1 local o=0 local i={}local n=true local s=true local h=window local function
r(d,l)d=d or{}local u=setmetatable({},{__index=_G})for c,m in pairs(d)do u[c]=m
end u["term"]=l local f=_G.term.native and _G.term.native()or term local w=f
local function y(p)return function(...)return w[p](...)end end
u["term"]["current"]=function()return w end
u["term"]["redirect"]=function(v)e(1,v,"table")if v==u["term"]or v==_G.term
then
error("term is not a recommended redirect target, try term.current() instead",2)end
for b,g in pairs(f)do if type(b)=="string"and type(g)=="function"then if
type(v[b])~="function"then
v[b]=function()error("Redirect object is missing method "..b..".",2)end end end
end local k=w w=v return k end local q=u["term"]for j,x in pairs(f)do if
type(j)=="string"and type(x)=="function"and rawget(q,j)==nil then
u["term"][j]=y(j)end end u["term"]["native"]=function()return f end
u["SkyOS"]=setmetatable({["self"]={win=l},["close"]=function()end,["visible"]=function(z)return
z
end,["back"]=function()end,},{__index=_G.SkyOS})u["require"],u["package"]=t(u,"/")return
u end local function
E(T,A,O,I,...)e(1,T,"function","string")e(2,A,"string","nil")e(3,O,"boolean","nil")e(4,I,"table","nil")I=I
or _ENV A=A or fs.getName(T)if not fs.exists(T)then
error("Program not found",2)end local
N=h.create(term.current(),1,2,26,18,O)local S=r(I,N)local
H=table.pack(...)local R=fs.open(T,"r")local D=R.readAll()R.close()local
L=load(D,"="..A,"t",S)local function U()L(table.unpack(H,1,H.n))end local
C=SkyOS.coro.newCoro(U,A)S["SkyOS"]["self"]["pid"]=C
S["SkyOS"]["self"]["winid"]=a S["SkyOS"]["self"]["path"]=function()return
fs.getDir(T)end local M={win=N,env=S,pid=C,}i[a]=M a=a+1 return a-1 end local
function F(W)e(1,W,"table")if W.env.SkyOS.close then W.env.SkyOS.close()end
SkyOS.coro.killCoro(W.env.SkyOS.self.pid)i[W.env.SkyOS.self.winid]=nil end
local function Y(P)local V if type(P)=="table"then local B=false for G,K in
pairs(i)do if not B and K==P then V=G B=true end end if not B then
error("Window not found!",2)end elseif type(P)=="number"and i[P]then V=P else
error("Window not found!",2)end if i[o]then local Q=o
SkyOS.coro.activeCoros[i[Q].pid]=false
i[Q].env.SkyOS.visible(false)i[Q].env.term.setVisible(false)end o=V
SkyOS.coro.activeCoros[i[V].pid]=true
i[V].env.SkyOS.visible(true)i[V].env.term.setVisible(true)end
return{wins=i,activeWindow=o,bottombarOpen=s,topbarOpen=n,newWindow=E,closeWindow=F,foreground=Y,}