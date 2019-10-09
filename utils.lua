function center(str,y,col,wide)
	local x=64-#str*2-(wide or 0)*2
	print(str,x-1,y,0)
	print(str,x+1,y,0)
	print(str,x,y-1,0)
	print(str,x,y+1,0)
	print(str,x,y,col)
end

function poll_input()
	if (btn(0)) return {-1,0}
	if (btn(1)) return {1,0}
	if (btn(2)) return {0,-1}
	if (btn(3)) return {0,1}
end

function sgn0(num)
	if (num==0) return 0
	return sgn(num)
end

function idiv(num,div)
	local q,r=0,num
	while r>=div do
		r-=div
		q+=1
	end
	return q,r
end

function sortby(a,key)
	for i=1,#a do
		local j=i
		while j>1 and a[j-1][key]>a[j][key] do
			a[j],a[j-1] = a[j-1],a[j]
			j=j-1
		end
	end
end

function equals(o1,o2)
	if (type(o1)!=type(o2)) return false
	if (type(o1)!="table") return o1==o2
	for k,v in pairs(o1) do
		if (not o2[k] or o2[k]!=v) return false
	end
	return true
end

function copy(obj)
	if (type(obj)!='table') return obj
	local res = {}
	for k,v in pairs(obj) do res[copy(k)] = copy(v) end
	return res
end

function addall(t1,t2)
	for k,v in pairs(t2) do t1[k]=v end
end

function orall(t1,t2)
	for k,v in pairs(t2) do t1[k]=t1[k] or v end
end

function pad(s,len,ch)
	local str=tostr(s)
	while #str<len do
		str=(ch or "0")..str
	end
	return str
end
