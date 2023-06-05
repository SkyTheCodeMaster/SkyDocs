local e=require("cc.expect").expect local function t(a,o,i)i=i or" "return
a:sub(1,o)..i:rep(o-#a)end local
n={"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",}for
s,h in pairs(n)do n[h]=s end local function
r(d,l)e(1,d,"string")e(2,l,"number")if d==" "then return" "end local
u=n[d]local c=u+l return n[c%26]end local function
m(f,w)e(1,f,"string")e(2,w,"number","nil")w=w or-3 f=f:gsub("%A","")local
y={}for p in f:lower():gmatch(".")do local v=r(p,w)table.insert(y,v)end local
b=table.concat(y)return b end local function
g(k,q)e(1,k,"string")e(2,k,"string")local j if q:len()<k:len()then local
x=math.ceil(k:len()/q:len())j=t(q:rep(x),k:len())elseif q:len()>k:len()then
j=t(q,k:len())else j=q end local z={}local E={}local T={}for A in
k:gmatch(".")do if A==" "then table.insert(z," ")else local
O=n[A]table.insert(z,O)end end for I in j:gmatch(".")do if I==" "then
table.insert(z," ")else local N=n[I]table.insert(E,N)end end for S=1,#z do if
z[S]==" "then table.insert(T," ")else local H=z[S]-1 local R=E[S]-1 local D=H+R
local L=n[D%26+1]table.insert(T,L)end end local U=table.concat(T)return U end
local function C(M,F)e(1,M,"string")e(2,M,"string")local W if
F:len()<M:len()then local
Y=math.ceil(M:len()/F:len())W=t(F:rep(Y),M:len())elseif F:len()>M:len()then
W=t(F,M:len())else W=F end local P={}local V={}local B={}for G in
M:gmatch(".")do local K=n[G]table.insert(P,K)end for Q in W:gmatch(".")do local
J=n[Q]table.insert(V,J)end for X=1,#P do local Z=P[X]-1 local et=V[X]-1 local
tt=Z-et if tt<0 then tt=tt+26 end local at=n[tt%26+1]table.insert(B,at)end
local ot=table.concat(B)return ot end local function it(nt)return m(nt,13)end
return{letterTable=n,shiftLetter=r,caesar=m,viginere=g,viginereDecode=C,rot13=it,}