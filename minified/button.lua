local e=require("cc.expect").expect local t=6 local a=false local o={}local
function i(n)local s=""for h=1,n do local r=math.random(48,109)if r>=58 then
r=r+7 end if r>=91 then r=r+6 end s=s..string.char(r)end return s end function
new(d,l,u,c,m,f,w)e(1,d,"number")e(1,l,"number")e(1,u,"number")e(1,c,"number")e(1,m,"function")e(1,f,"table","nil")e(1,w,"boolean","nil")w=w==nil
and true or false local y,p=term.getCursorPos()if f then if a then if#f~=c then
error("Image must be same height as button",2)end end for v=1,#f do
if#f[v][1]~=#f[v][2]or#f[v][1]~=#f[v][3]then
error("tDraw line"..tostring(v).."is not equal to other lines",2)end if a then
if#f[v][1]~=u then error("Image must be same width as button",2)end end end end
local b=i(t)o[b]={x=d,y=l,w=u,h=c,fFunc=m,tDraw=f,enabled=w,}if f then for
g=1,#f do local k=f[g]term.setCursorPos(d,l+g-1)term.blit(k[1],k[2],k[3])end
term.setCursorPos(y,p)end return b end function
delete(q)e(1,q,"string","nil")if o[q]then o[q]=nil end end function
enable(j,x)e(1,j,"string")e(2,x,"boolean")if not o[j]then
error("Button "..j.." does not exist.",2)end o[j].enabled=x end function
exec(z,E,T)e(1,z,"table")e(2,E,"boolean","nil")e(3,T,"boolean","nil")E=E or
false T=T or false if z[1]=="mouse_click"or E and z[1]=="mouse_drag"or T and
z[1]=="monitor_touch"then local A,O=z[3],z[4]for I,N in pairs(o)do if N.enabled
and A>=N.x and A<=N.x+N.w-1 and O>=N.y and O<=N.y+N.h-1 then
pcall(N.fFunc,A-N.x+1,O-N.y+1)end end end end function
drawButton(S)e(1,S,"string")if o[S]and o[S].tDraw then local H=o[S].tDraw local
R,D,L,U=o[S].x,o[S].y,o[S].w,o[S].h if a then if#H~=U then
error("image must be same height as button",2)end end for C=1,#H do
if#H[C][1]~=#H[C][2]or#H[C][1]~=#H[C][3]then
error("image line"..tostring(C).."is not equal to other lines",2)end if a then
if#H[C][1]~=L then error("Image must be same width as button",2)end end end
local M,F=term.getCursorPos()if H then for W=1,#H do local
Y=H[W]term.setCursorPos(R,D+W-1)term.blit(Y[1],Y[2],Y[3])end
term.setCursorPos(M,F)end end end function drawButtons()for P in pairs(o)do
drawButton(P)end end function
edit(V,B,G,K,Q,J,X)e(1,V,"string")e(2,B,"number","nil")e(3,G,"number","nil")e(4,K,"number","nil")e(5,Q,"number","nil")e(6,J"function","nil")e(7,X,"table","nil")if
not o[V]then error("Button "..V.." does not exist.",2)end B=B or o[V].x G=G or
o[V].y K=K or o[V].w Q=Q or o[V].h local Z=J or o[V].fFunc local et=X or
o[V].tDraw local tt=o[V].enabled
o[V]={x=B,y=G,w=K,h=Q,fFunc=Z,tDraw=et,enabled=tt,}end function
run(at,ot)return function()while true do exec({os.pullEvent()},at,ot)end end
end
return{new=new,delete=delete,enable=enable,exec=exec,drawButton=drawButton,drawButtons=drawButtons,edit=edit,run=run,}