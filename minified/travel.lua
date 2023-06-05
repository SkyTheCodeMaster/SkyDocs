local e=peripheral.wrap("back")local function t(a,o,i)return
math.deg(math.atan2(-a,i)),math.deg(-math.atan2(o,math.sqrt(a*a+i*i)))end local
function n(s)local h,r=gps.locate()if r and r<=s then e.launch(0,-90,1)end end
local function d(l,u,c)local m=false local
f={x=l-50,w=l+50,y=c-50,h=c+50,}while not m do local w=vector.new(l,300,c)local
y,p,v=gps.locate()local b=vector.new(y,300,v)local g=w:sub(b)local
k=t(g.x,g.y,g.z)e.launch(k,0,4)print(y,v)print(l,c)print(y>=f.x,y<=f.x+f.w-1)print(v>=f.y,v<=f.y+f.h-1)if
y and v and y>=f.x and y<=f.w and v>=f.y and v<=f.h then m=true end
n(u)sleep()end end return
setmetatable({travel=d},{__index=function(q,...)return
d(...)end})