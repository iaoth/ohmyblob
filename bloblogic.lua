-- bloblogic

blobtypes={"green","blue","grey","yellow","pink","red","shadow","glow"}

blobdefaults = {
	move=1,
	attack=1,
	aggro=2,
	split=true,
	col={}
}

blobtraits = {
	green={
		tier=1,
	},
	blue={
		tier=0,
		attack=0,
		spawner=true,
		split=false,
		col={[11]=12,[3]=13}
	},
	grey={
		tier=0,
		attack=0,
		invincible=true,
		col={[11]=6,[3]=7}
	},
	yellow={
		tier=1,
		move=2,
		col={[11]=10,[3]=9}
	},
	pink={
		tier=2,
		grow=true,
		split=false,
		attack=0,
		move=0,
		dmgchange="red",
		col={[11]=14,[3]=8}
	},
	red={
		tier=2,
		aggro=1,
		split=false,
		dmgchange="pink",
		col={[11]=8,[3]=2}
	},
	shadow={
		tier=3,
		attack=2,
		col={t=2,[0]=2,[11]=0,[3]=1}
	},
	glow={
		col={[11]=7,[3]=7}
	}
}

mergetier = {[0]="blue", [1]="green", [2]="red", [3]="shadow", [4]="shadow", [5]="blue"}

function gettrait(b,trait)
	if b and b.t and blobtraits[b.t][trait]!=nil then
		return blobtraits[b.t][trait]
	end
	return blobdefaults[trait]
end

blobid=0

function spawnblob(x,y,s,t,status)
	if (grid_bounds({x,y})) return
	local size=s
	local b=grid[x][y]
	if b then
		if (b.typ!="blob") return
		size+=b.s
	end

	local nb=b or status or {}
	if (b and status) orall(nb,status)
	orall(nb,{s=size,t=t,o={0,0},typ="blob"})
	if not nb.id then
		blobid+=1
		nb.id=blobid
	end
	grid[x][y]=nb

	if size>3 then
		if (b and b.s<4) or s>3 then
			queue_event("explode",{x,y},nb)
		end
		nb.s=size
		nb.stun=1
	elseif size>s then
		nb.s=max(nb.s,s)
		event_funcs.transform(nb,nb.s,size,b.t,addtypes(b.t,t))
		nb.stun=1
	end
end

function addtypes(t1,t2)
	if (blobtraits[t1].tier>blobtraits[t2].tier) return t1
	return t2
end

function test_blob_collision(c,b)
	if grid_bounds(c) or equals(c,knight) then
		return true
	end
	local obj=getgrid(c)
	if (not obj) return false
	if not gettrait(b,"spawner") and obj.typ=="blob" and obj.s+b.s<=3 then
		return false
	end
	return true
end

function test_pos_list(x,y,list,p)
	-- return/add unblocked positions
	local pos=p or {}
	for i=1,#list do
		if not test_blob_collision({x+list[i][1],y+list[i][2]},{s=0}) then
			add(pos,list[i])
		end
	end

	return pos
end

function getblob(c)
	local obj=getgrid(c)
	if (not obj or obj.typ!="blob") return nil
	return obj
end


event_funcs.enemyturn = function()
	yield()
	if (blobcount!=0) knightmoving=false
	processblobs()

	for x=1,7 do
		for y=1,8 do
			local obj=getgrid({x,y})
			if obj then
				if (obj.age) obj.age+=1
				if obj.typ=="heart" then
					if (obj.age>1) then
						grid[x][y]=nil
						start_event("heartfall",(x-1)*16+1,(y-1)*16+3,true)
						start_event("heartfall",(x-1)*16+9,(y-1)*16+3,false)
					end
				end
				if obj.stun then
					obj.stun-=1
					if (obj.stun==0) obj.stun=nil
				end
			end
		end
	end
end

function processblobs()
	for r=1,7 do
		local blobs=collectblobs(r)
		for m in all(blobs) do
			local c,b=m[1],m[2]
--			printh("blob "..b.id.." "..b.t.." "..b.s)
			if b.stun then
				goto nextblob
			end
			if gettrait(b,"grow") and b.s<3 then
				event_funcs.transform(b,b.s,b.s+1)
			end
			if r==1 and (c[1]==knight[1] or c[2]==knight[2]) then
				for i=1,gettrait(b,"attack") do
					blobattack(b,c)
					if (hp<1) return
				end
			else
				for i=1,gettrait(b,"move") do
					if (not c or b.stun or b!=getblob(c)) break
					c=moveblob(b,c)
				end
			end
			::nextblob::
		end
	end
end

function collectblobs(r)
	local blobs={}
	local ids={}
	for i=0,r do
		for j=-r,r,2*r do
			local coords={
				{knight[1]+j,knight[2]-i},
				{knight[1]+j,knight[2]+i},
				{knight[1]-i,knight[2]+j},
				{knight[1]+i,knight[2]+j}
			}
			for c in all(coords) do
				local obj=getblob(c)
				if obj and not ids[obj.id] then
					add(blobs,{c,obj})
					ids[obj.id]=true
				end
			end
		end
	end
	return blobs
end

function moveblob(b,f) --blob,from
	local d={knight[1]-f[1],knight[2]-f[2]}

	local v,t = {0,0},nil
	for i=1,2 do
		if (d[i]==0) goto nextaxis
		local dir=sgn(d[i])

		local test=copy(f)
		test[i]+=dir
		if not test_blob_collision(test,b) then
			v[i]=dir
			t=test
			break
		end
		::nextaxis::
	end
	if (not t) return

	local mb,ob=b,nil
	if gettrait(b,"spawner") then
		if (getblob(t)) return
		if b.s==1 then
			return
		elseif b.s==2 then
			ob={typ="blob",s=1,t=b.t}
		elseif b.s==3 then
			ob={typ="blob",s=2,t=b.t}
		end
	end

	slideblob(mb,f,t,v,ob)
	return t
end

function slideblob(b,f,t,v,ob)
	anim[f[1]][f[2]]=ob
	for i=2,16,1.5 do
		b.o={i*v[1],i*v[2]}
		yield()
	end
	b.o={0,0}
	grid[f[1]][f[2]]=nil
	spawnblob(t[1],t[2],b.s,b.t,b)
	anim[f[1]][f[2]]=nil
	if (ob) spawnblob(f[1],f[2],ob.s,ob.t,ob)
end

function blobattack(b,c)
	if (b.s<gettrait(b,"aggro")) return

	local v={knight[1]-c[1],knight[2]-c[2]}

	sfx(3)
	for i=0.5,1,0.1 do
		b.o={-v[1]*sin(i)*5,
			-v[2]*sin(i)*5}
		yield()
	end
	for i=0.5,0.7,0.1 do
		b.o={v[1]*sin(i)*7,
			v[2]*sin(i)*7}
		yield()
	end
	for i=0.8,1,0.1 do
		b.o={v[1]*sin(i)*7,
			v[2]*sin(i)*7}
		if hp>1 then
			knightofs={v[1]*sin(i-0.3)*7,
				v[2]*sin(i-0.3)*7}
		end
		yield()
	end
	hp-=1
	start_event("heartfall",114+(hp%2)*5,flr(hp/2)*8,hp%2==0)
	if hp>0 then
		for i=6,0,-1 do
			knightofs={v[1]*i,v[2]*i}
			yield()
		end
	else
		clear_events()
	end
end

event_funcs.attack = function(c,v)
	local b=getblob(c)
	if gettrait(b,"invincible") then
		next_event("ding",c,b)
	elseif gettrait(b,"split")==true then
		local e="destroyblob"
		if b.s==2 then
			e="split"
		elseif b.s==3 then
			e="explode"
		end
		next_event(e,c,b,v,gettrait(b,"dmgchange"))
	elseif b.s>1 then
		next_event("transform",b,b.s,b.s-1,b.t,gettrait(b,"dmgchange"))
	else
		next_event("destroyblob",c,b,v)
	end
	yield()

	for i=0.5,1,0.05 do
		knightofs={v[1]*sin(i)*5,v[2]*sin(i)*5}
		yield()
	end
	knightofs={0,0}
	if (blobcount!=0) knightmoving=false
end

event_funcs.explode=function(c,b,v,ct)
	local x,y,t=c[1],c[2],(ct or b.t)
	local ri=1+abs((knight[1]-c[1])-(knight[2]-c[2]))%2
	yield()
	local ps,bs={0,0,0,0,0},b.s
	local rot={{{1,0},{-1,0},{0,-1},{0,1}},
		{{1,1},{-1,-1},{-1,1},{1,-1}}}

	local pos=test_pos_list(x,y,rot[ri])

	-- sliding to another position 1) is not an explosion
	-- 2) looks weird and 3) might get us stuck in a loop
	if #pos<=1 then
		test_pos_list(x,y,rot[3-ri],pos)
	end

	if bs>4 then
		add(pos,{0,0})
	end

	if #pos<=1 then -- we're stuck!
		event_funcs.transform(b,b.s,b.s-1,b.t,t)
		return
	end

	if (v and bs==3) bs=4  -- attacks against a 3 blob embiggens it

	-- split up blob mass over the target positions
	while bs>0 do
		for i=1,#pos do
			ps[i]+=1
			bs-=1
			if (bs==0) break
		end
	end
	sfx(0)
	if v then --called from attack()
		grid[x][y]={typ="heart",age=0}
	else
		grid[x][y]=nil
	end
	split_to_pos(x,y,pos,ps,t)
end

event_funcs.split = function(c,b,v,ct)
	local x,y,t=c[1],c[2],(ct or b.t)
	yield()
	local pos=test_pos_list(x,y,{{v[2],v[1]},{-v[2],-v[1]}})
	if #pos==0 then
		pos=test_pos_list(x,y,{{v[1],v[2]},{0,0}})
		if #pos<2 then
			start_event("transform",b,b.s,b.s-1,b.t,t)
			return
		end
	elseif #pos==1 then
		add(pos,{0,0})
	end

	sfx(0)
	grid[x][y]=nil
	split_to_pos(x,y,pos,{1,1},t)
end

function split_to_pos(x,y,pos,ps,t)
	for j=1,#pos do
		anim[x+pos[j][1]][y+pos[j][2]] =
			{typ="blob",s=ps[j],t=t,stun=1,o={-16*pos[j][1],-16*pos[j][2]}}
	end
	for i=16,0,-2 do
		for j=1,#pos do
			anim[x+pos[j][1]][y+pos[j][2]].o={-i*pos[j][1],-i*pos[j][2]}
		end
		yield()
	end
	for j=1,#pos do
		local bx,by=x+pos[j][1],y+pos[j][2]
		local b
		b,anim[bx][by]=anim[bx][by],nil
		b.o={0,0}
		spawnblob(bx,by,b.s,b.t,b)
	end
end

event_funcs.destroyblob = function(c,b)
	local t=b.t
	yield()
	grid[c[1]][c[2]]=nil
	anim[c[1]][c[2]]=b
	sfx(1)
	b.t="glow"
	for i=1,3 do
		yield()
	end
	for i=1,3 do
		b.t="glow"
		yield()
		b.t=t
		yield()
	end
	for i=1,3 do
		anim[c[1]][c[2]]=b
		yield()
		anim[c[1]][c[2]]=nil
		yield()
	end
end

event_funcs.ding = function(c,b)
	local t=b.t
	yield()
	sfx(7,-1,14)
	for i=1,4 do
		b.t="glow"
		yield()
		b.t=t
		yield()
	end
end

event_funcs.transform = function(b,s1,s2,t1,t2)
	local t
	if (t1 and t2) t={t1,t2}
	yield()

	if s2>s1 then
		sfx(2)
	else
		sfx(0)
	end
	b.s=s2
	if (t) b.t=t[2]
	for i=1,6 do yield() end
	b.s=s1
	if (t) b.t=t[1]
	for i=1,6 do yield() end
	b.s=s2
	if (t) b.t=t[2]
end
