grid = {{},{},{},{},{},{},{},{}}
anim = {{},{},{},{},{},{},{},{}}
hpmax = 12
fadeindex=1

screens = {
	title={},
	text={},
	level={},
	fadeout={},
	levelstart={}
}

function changescreen(scr)
	curscreen=nil
	screens[scr].init()
	curscreen=screens[scr]
end

function _update60()
	if (not curscreen) return
	curscreen.update()
end

function _draw()
	if (not curscreen) return
	curscreen.draw()
end

levels={2,13,20}
li=1
press={
	{2,2,2},
	{1},
	{2,2,2,2,2}
}
pri=1
texts={
	{
		t={
			"from the genius",
			"that brought you",
			"\"no rules chess\""
		},
		c={6,6,7}
	},
	{
		t={
			"comes an",
			"action-packed",
			"no holds barred",
			"experience"
		},
		c={6,10,8,6}
	},
	{
		t={
			"guaranteed to make",
			"you exclaim..."
		},
		c={6,6}
	}
}

function poll_input_t()
	if (btn_t(0)) return {-1,0}
	if (btn_t(1)) return {1,0}
	if (btn_t(2)) return {0,-1}
	if (btn_t(3)) return {0,1}
end

function btn_t(b)
	return b==press[li][pri]
end

screens.fadeout.init=function()
	fadet=t()
	foi=1
end

screens.fadeout.update=function()
	local dt=t()-fadet
	if dt>=0.5 then
		changescreen("text")
	else
		foi=flr(dt*12+1)
	end
end

screens.fadeout.draw=function()
	for i=1,15 do
		pal(i,fadeout[i][foi],1)
	end
end

screens.text.init=function()
	cls()
	foi=6
	local n=#texts[li-1].t
	local y=56-4*n
	for i=1,n do
		center(texts[li-1].t[i],y+i*8,texts[li-1].c[i])
	end
	txt0=t()
end

screens.text.update=function()
	local dt=t()-txt0
	if dt>3 then
		if li>#levels then
			changescreen("title")
		else
			changescreen("level")
		end
		return
	elseif dt<=0.5 then
		foi=flr(6-dt*10)
	elseif dt>2.5 then
		foi=flr(6-(3-dt)*10)
	end
end

screens.text.draw=screens.fadeout.draw

screens.levelstart.init=function()
	fadeindex=6
	fadeframe=55
	fadepal()
	readlevel(levels[1])
	frame=2
	frame1=0
	musictick=0
	knightmoving=false
	coknightanim=cocreate(knightwarp)
	drawknight=function() coresume(coknightanim) end
end

function knightwarp()
	while fadeframe>0 do yield() end
	local maxr=11
	sfx(34)
	local cx,cy=(knight[1]-1)*16+knightofs[1]+8,
		(knight[2]-1)*16+knightofs[2]+4
	for i=0,maxr,0.4 do
		circfill(cx,cy,i,7)
		yield()
	end
	for i=1,6,0.15 do
		circfill(cx,cy,maxr,7)
		for c=1,15 do pal(c,fadeout[7][flr(i)]) end
		drawknight_alive()
		pal()
		yield()
	end
	for i=6,1,-0.15 do
		circfill(cx,cy,maxr,7)
		fadepal(flr(i))
		drawknight_alive()
		pal()
		yield()
	end
	for i=maxr,0,-0.4 do
		circfill(cx,cy,i,7)
		drawknight_alive()
		yield()
	end

	drawknight_alive()
	drawknight=drawknight_alive
end

screens.levelstart.update=function()
	if (fadeframe>0) fadeframe-=1
	fadeindex=flr(fadeframe/10)+1
	if fadeframe<5 and drawknight==drawknight_alive then
		changescreen("level")
	end
end

screens.levelstart.draw=function()
	fadepal()
	screens.level.draw()
end

screens.level.init=function()
	if li>1 then
		printh(levels[li])
		readlevel(levels[li])
	end

	frame=0
	fadeindex=1
	tick=0
	pal()
	if li==1 then
		music(12,0,6)
	end
	drawknight=drawknight_alive

	pri=1
end

screens.level.update=function()
	musictick = stat(26)
	frame = band(musictick/20,7)
	frame1 = band(frame,1)
	frame = band(frame/2,2)
	tick+=1

	if #event_queue==0 then
		if pri>#press[li] then
			li+=1
			changescreen("fadeout")
			return
		end
		knightmoving=true
		local v = poll_input_t()
		if v then
			if not test_knight_collision(v) then
				queue_event("moveknight",v)
			end
		end
		if v or btn_t(4) or btn_t(5) then
			queue_event("enemyturn")
			pri+=1
		end

		if blobcount!=0 then
			blobcount=0
			for x=1,7 do
				for y=1,8 do
					if (grid[x][y] and grid[x][y].typ=="blob") blobcount+=grid[x][y].s
				end
			end
		end

		if not activeportal and blobcount==0 then
			start_event("openportal")
		end
	end
end

screens.level.draw=function()
	cls()

	rectfill(116,0,124,127,1)

	for i=0,8 do
		if (i*3>=blobcount) break
		local s=50
		if (i*3+3>blobcount) s=47+blobcount-i*3
		spr(s,117,120-i*9,1,1)
	end

	for i=0,hpmax-1,2 do
		local s=32
		if i>=hp then
			s=34
		elseif i+1==hp then
			s=33
		end
		spr(s,117,i*4,1,1)
	end

	rectfill(113,0,115,127,2)
	rectfill(114,0,114,127,4)
	rectfill(125,0,127,127,2)
	rectfill(126,0,126,127,4)

	drawbackground()

	event_update()

	for y=1,8 do
		for x=1,7 do
			if activeportal and equals(portal,{x,y}) then
				drawportal()
			end

			drawobject(anim[x][y],x,y)
			drawobject(grid[x][y],x,y)
		end
		if knight[2]==y then
			drawknight()
		end
	end
end

screens.title.init=function()
	music(-1,1000)
	ly={-70,-39,-36}
	blx=0
	blheight=40
	blwidth=112
	anim=1
	cologoanim=cocreate(logoanim[anim])
	textfade=6
end

screens.title.update=function()
	if cologoanim then
		coresume(cologoanim)
		if costatus(cologoanim)=="dead" then
			if anim<#logoanim then
				anim+=1
				cologoanim=cocreate(logoanim[anim])
			else
				cologoanim=nil
			end
		end
	end
end

screens.title.draw=function()
	palt()
	pal()
	cls(0)

	palt(0,false)
	palt(14,true)

	spr(128,29,15+ly[2],5,3) --oh
	spr(133,66,15+ly[3],5,3) --my
	sspr(0,88,112,40,      --blob!
		12+blx,31+ly[1],
		blwidth,blheight)

	center("play for free!",90,fadeout[flr(t()*10)%7+9][textfade])
	center("iaoth.itch.io/ohmyblob",100,fadeout[12][textfade])
end

logoanim={}

logoanim[1]=function()
	ly={-200,-39,-36}
	blx=0
	blheight=40
	blwidth=112

	while ly[1]<0 do
		ly[1]+=3
		yield()
	end
	ly[1]=0
	sfx(26)
	for i=0,0.5,0.04 do
		local h=sin(i)*12
		blheight=40+h
		blwidth=112-h*2
		ly[1]=-h
		blx=h
		yield()
	end
	for i=0.5,1,0.05 do
		local h=sin(i)*5
		blheight=40+h
		blwidth=112-h*2
		ly[1]=-h
		blx=h

		ly[2]+=3
		yield()
	end
	sfx(27)
	for i=0,0.5,0.02 do
		local h=sin(i)*12
		blheight=40+h
		blwidth=112-h*2
		ly[1]=-h
		blx=h
		ly[2]=-h

		if i>0.25 then
			ly[3]+=3
		end
		yield()
	end
	sfx(28)
	for i=0,0.5,0.03 do
		local h=sin(i)*20
		blheight=40+h
		blwidth=112-h*2
		ly={-h,-h,-h}
		blx=h
		yield()
	end

	for i=0.5,1,0.04 do
		local h=sin(i)*5
		blheight=40+h
		blwidth=112-h*2
		ly={-h,-h,-h}
		blx=h
		yield()
	end

	for i=0,1,0.05 do
		local h=sin(i)*5
		blheight=40+h
		blwidth=112-h*2
		ly={-h,-h,-h}
		blx=h
		yield()
	end

	for i=0,2,0.06 do
		local h=sin(i)*2
		blheight=40+h
		blwidth=112-h*2
		ly={-h,-h,-h}
		blx=h
		yield()
	end

	blheight=40
	blwidth=112
	ly={0,0,0}
end

logoanim[2]=function()
	for f=5,1,-1 do
		textfade=f
		for i=0,10 do yield() end
	end
end

function readlevel(larg)
	local lvl=larg-1
	blobid=0
	musictick=0
	frame=0
	frame1=0
	knight={}
	knightofs={0,0}
	event_queue={}
	hp=hpmax
	activeportal=false
	portal={0,0}
	blobcount=0

	local my,mx=idiv(lvl,9)
	mx*=14
	my*=8
	for x=1,7 do
		for y=1,8 do
			grid[x][y]=nil
			local spr=mget(mx+(x-1)*2,my+y-1)
			local spr2=mget(mx+(x-1)*2+1,my+y-1)
			local flag=fget(spr)
			local flag2=fget(spr2)

			if band(flag2,4)!=0 then
				portal={x,y}
				if band(flag,4)!=0 then
					activeportal=true
				end
			end

			if (flag==0) goto nexty

			if band(flag,8)!=0 then
				local s=flr((spr%16)/4)+1
				local t=spr2+1
				if (t>#blobtypes or blobtypes[t]=="glow") t=1
				spawnblob(x,y,s,blobtypes[t])
				blobcount+=s
			elseif band(flag,128)!=0 then
				knight={x,y}
				if spr2==33 then
					hp=hpmax/2+1
				elseif spr2==34 then
					hp=2
				end
			elseif band(flag,1)!=0 then
				grid[x][y]={typ="block",spr=band(spr,0xFE)}
				if band(flag,2)!=0 then
					grid[x][y].hat=spr-32
				end
			end
			::nexty::
		end
	end
end

function grid_bounds(c)
	if c[1]<1 or c[1]>7 or
	   c[2]<1 or c[2]>8 then
	   return true
	end
end

function test_knight_collision(v)
	local c={knight[1]+sgn0(v[1]),
	         knight[2]+sgn0(v[2])}

	if (grid_bounds(c)) return true

	local obj=getgrid(c)
	if (not obj) return false

	if obj.typ=="blob" then
		next_event("attack",c,v)
		return true
	elseif obj.typ=="block" then
		return true
	end
end

function getgrid(c)
	if grid_bounds(c) then
	   return nil
	end
	return grid[c[1]][c[2]]
end

--event functions and coroutines

event_funcs.moveknight = function(v)
	yield()
	for i=1,16 do
		knightofs={i*v[1],i*v[2]}
		yield()
	end
	knightofs={0,0}
	knight[1]+=v[1]
	knight[2]+=v[2]

	local obj=getgrid({knight[1],knight[2]})
	if obj and obj.typ=="heart" then
		sfx(7)
		grid[knight[1]][knight[2]]=nil
		hp+=2
		if (hp>hpmax) hp=hpmax
		for i=1,6 do yield() end
	end
end

event_funcs.heartfall = function(x,y,flip)
	yield()
	for i=1,8,0.5 do
		spr(35,x,y+i,1,1,flip)
		yield()
	end
end

event_funcs.openportal = function()
	yield()
	for i=1,2 do
		drawportal()
		for j=1,4 do yield() end
	end
	for i=1,4 do
		drawportal()
		yield()
		yield()
	end
	for i=1,2 do
		for j=1,3 do
			drawportal()
			yield()
		end
		yield()
	end
	activeportal=true
end
