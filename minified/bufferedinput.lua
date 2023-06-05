local e=require("cc.expect")local function t(a)e(1,a,"table")local o=""while
true do local i,n=os.pullEventRaw()if i=="terminate"and
a.allowKeyboardInterrupt then error("terminated",0)elseif i=="key"and
n==keys.backspace then o=o:sub(1,#o-1)if a.callback then a.callback(o)end
elseif i=="key"and n==keys.enter then return o elseif i=="char"then if limit
then if#o<a.limit then o=o..n end else o=o..n end if a.callback then
a.callback(o)end end end end
return{read=t,}