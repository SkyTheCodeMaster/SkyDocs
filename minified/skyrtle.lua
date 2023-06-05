local e={}local t=require("cc.expect").expect local a={0,0,0,0,}if
fs.exists(".skyrtle")then local o=fs.open(".skyrtle","r")local
i=o.readAll()o.close()a=textutils.unserialize(i)end local function n(s,h)local
r=fs.open(s,"w")r.write(h)r.close()end local function d(l)local u={}for c,m in
pairs(l)do if type(m)=="table"then u[c]=d(m)else u[c]=m end end return u end
local f=gps.locate local w=true local y,p,v=f()if not y then y,p,v=0,0,0
w=false end if not(w and a[1]~=y or a[2]~=p or a[3]~=v)then
a={y,p,v,0}n(".skyrtle",textutils.serialize(a))end local
b={[0]="north","east","south","west",north=0,east=1,south=2,west=3,oppo={[0]=2,3,0,1,},}local
function g(y,p,v,k)local q if type(k)=="number"then q=k elseif
type(k)=="string"then q=b[k]end if not q then
error("Direction lookup failed! facing contains an invalid value!")end if q==0
then v=v-1 elseif q==1 then y=y+1 elseif q==2 then v=v+1 elseif q==3 then y=y-1
end return y,p,v end function e.calcFacing()if not w then return false end
local j={f()}turtle.foward()local x={f()}turtle.back()if j[1]+1==x[1]then
return 1 elseif j[1]-1==x[1]then return 3 elseif j[3]+1==x[3]then return 2
elseif j[3]-1==x[3]then return 0 end end local z=d(turtle)function
e.forward(E)t(1,E,"number","nil")E=E or 1 local T for A=1,E do T=z.forward()if
not T then break end a[1],a[2],a[3]=g(a[1],a[2],a[3],a[4])end if not T and w
then local O={f()}if O[1]==a[1]and O[2]==a[2]and O[3]==a[3]then return true
else return false end else return true end return true end function
e.back(I)t(1,I,"number","nil")I=I or 1 local N for S=1,I do N=z.back()if not N
then break end a[1],a[2],a[3]=g(a[1],a[2],a[3],b.oppo[a[4]])end if not N and w
then local H={f()}if H[1]==a[1]and H[2]==a[2]and H[3]==a[3]then
n(".skyrtle",textutils.serialize(a))return true else return false end else
return true end return true end function e.up(R)t(1,R,"number","nil")R=R or 1
local D for L=1,R do D=z.up()if not D then break end a[2]=a[2]+1 end if not D
and w then local U={f()}if U[1]==a[1]and U[2]==a[2]and U[3]==a[3]then
n(".skyrtle",textutils.serialize(a))return true else return false end else
return true end return true end function e.down(C)t(1,C,"number","nil")C=C or 1
local M for F=1,C do M=z.down()if not M then break end a[2]=a[2]-1 end if not M
and w then local W={f()}if W[1]==a[1]and W[2]==a[2]and W[3]==a[3]then
n(".skyrtle",textutils.serialize(a))return true else return false end else
return true end return true end function e.turnLeft(Y)t(1,Y,"number","nil")Y=Y
or 1 for P=1,Y do local V=z.turnLeft()a[4]=(a[4]-1)%4 if not V then
n(".skyrtle",textutils.serialize(a))return false end end
n(".skyrtle",textutils.serialize(a))end function
e.turnRight(B)t(1,B,"number","nil")B=B or 1 for G=1,B do local
K=z.turnRight()a[4]=(a[4]+1)%4 if not K then
n(".skyrtle",textutils.serialize(a))return false end end
n(".skyrtle",textutils.serialize(a))end function e.getFacing()return
a[4],b[a[4]]end function e.setFacing(Q)t(1,Q,"number","string")if
type(Q)=="string"then Q=b[Q:lower()]end a[4]=Q
n(".skyrtle",textutils.serialize(a))end function e.getPosition()return
a[1],a[2],a[3]end function
e.setPosition(y,p,v)t(1,y,"number")t(1,p,"number")t(1,v,"number")a={y,p,v,a[4]}n(".skyrtle",textutils.serialize(a))end
local function J(X,Z)if w then return f(X,Z)else return e.getPosition()end end
function e.hijack(et)turtle.forward=e.forward turtle.back=e.back turtle.up=e.up
turtle.down=e.down turtle.turnLeft=e.turnLeft turtle.turnRight=e.turnRight if
et then gps.locate=J end return turtle.forward==e.forward and
turtle.back==e.back and turtle.up==e.up and turtle.down==e.down and
turtle.turnLeft==e.turnLeft and turtle.turnRight==e.turnRight end function
e.restore()turtle=z gps.locate=f end local tt={}function tt.check()local
at,ot=turtle.inspectDown()if ot and ot.name=="minecraft:wheat"and
ot.state.age==7 then return true,"minecraft:wheat_seeds"end end function
tt.farm(it,nt,st)t(1,it,"number")t(1,nt,"number")st=st or tt.check local
function ht()local rt,dt=st()if rt then turtle.digDown()turtle.suckDown()for
lt=1,16 do local ut=turtle.getItemDetail(lt)if ut and ut.name==dt then
turtle.select(lt)turtle.placeDown()break end end end end ht()for p=1,nt do for
y=1,it do if y~=it then turtle.forward()end ht()end if p~=nt then if p%2==0
then turtle.turnLeft()turtle.forward()ht()turtle.turnLeft()else
turtle.turnRight()turtle.forward()ht()turtle.turnRight()end end end if nt%2==1
then turtle.turnLeft()turtle.turnLeft()end if nt%2==1 then for ct=1,it-1 do
turtle.forward()end end turtle.turnRight()for mt=1,nt-1 do turtle.forward()end
turtle.turnRight()turtle.select(1)end local ft={}function
ft.generate(y,p,v)local wt,yt,pt=0,0,0 if w then wt,yt,pt=gps.locate()else
wt,yt,pt=e.getPosition()end local vt={}while yt~=p do if yt>p then
table.insert(vt,"down")yt=yt-1 else table.insert(vt,"up")yt=yt+1 end end end
e.farm=tt return
e