--globals, update, draw

--[[
sprite flags
0: impassible block
1: 2 tall sprite (aka has a hat)
2: portal
3: blob
4: apply fire animation
6: transparency colour 14
7: knight
]]

grid = {{},{},{},{},{},{},{},{}}
anim = {{},{},{},{},{},{},{},{}}
hpmax = 12
level = 0
fadeindex=1

screens = {
	title={},
	victory={},
	gameover={},
	levelstart={},
	level={}
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

screens.levelstart.init=function()
	fadeindex=6
	fadeframe=55
	fadepal()
	readlevel()
	frame=2
	frame1=0
	musictick=0
	knightmoving=false
	coknightanim=cocreate(knightwarp)
	drawknight=function() coresume(coknightanim) end
	menuitem(1, "back to menu", function() changescreen("title") end)
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

screens.victory.init=function()
	music(16)
	musictick=0
	tick=0
end

screens.victory.update=function()
	musictick = stat(26)
	tick+=1
	if musictick>496 then
		if level==32 then
			load("gameover.p8")
		end
		level+=1
		changescreen("levelstart")
	end
end

screens.victory.draw=function()
	if musictick<80 then
		local f=6-flr(musictick/16)
		cls(fadeout[7][f])
		drawportal()
		drawknight_alive()
	elseif musictick<208 then
		cls(7)
		if (musictick<112 and tick%4!=0) or
			(musictick>=112 and musictick<144 and tick%2==0) or
			(musictick>=144 and tick%4==0) then
			drawportal()
			drawknight_alive()
		end
	elseif musictick<304 then
		local f=flr((musictick-208)/16)+1
		cls(fadeout[7][f])
	end
end

screens.gameover.init=function()
	fadeindex=1
	frame=0
	fadeframe=0
	musictick=0
	drawknight=drawknight_dead
	music(8)
end

screens.gameover.update=function()
	if musictick!=-1 then
		musictick = stat(26)
		if (stat(24)==-1) musictick=-1
	elseif fadeframe<120 then
		fadeframe+=1
		fadeindex=flr(fadeframe/20)+1
	elseif fadeframe==120 and btn()!=0 then
		fadeframe+=1
		fadeindex=1
	elseif fadeframe>120 and fadeframe<180 then
		fadeframe+=1
		fadeindex=flr((fadeframe-120)/10)+1
	elseif fadeframe==180 then
		changescreen("levelstart")
	end
end

screens.gameover.draw=function()
	if musictick>0 and musictick<260 then
		local t=musictick%130
		if t<30 then
			cls()
			local shake=(30-t)/2
			camera(rnd(shake)-shake/2,rnd(shake)-shake/2)
		else
			camera(0,0)
		end
	end

	if fadeframe<120 then
		if fadeframe>0 then
			fadepal()
		end
		screens.level.draw()
	end
	if fadeframe>0 then
		if fadeframe<121 then
			pal()
		else
			fadepal()
		end
		drawknight_dead()
	end
	if fadeframe>119 then
		center("press any button to try again",62,15)
	end
end

screens.level.init=function()
	frame=0
	fadeindex=1
	tick=0
	pal()
	music(lvlmusic,0,6)
	drawknight=drawknight_alive
end

screens.level.update=function()
	musictick = stat(26)
	frame = band(musictick/20,7)
	frame1 = band(frame,1)
	frame = band(frame/2,2)
	tick+=1

	if hp<1 then
		changescreen("gameover")
		return
	end

	if activeportal and equals(knight,portal) then
		changescreen("victory")
		return
	end

	if #event_queue==0 then
		knightmoving=true
		local v = poll_input()
		if v then
			if not test_knight_collision(v) then
				queue_event("moveknight",v)
			end
		end
		if v or btn(4) or btn(5) then
			queue_event("enemyturn")
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

	-- if knightmoving then
	-- 	spr(51,120,0,1,1)
	-- end

end

--game logic

function readlevel()
	local lvl=level

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
	printh(mx..";"..my)
	lvlmusic=mget(mx+1,my)
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

	menuitem(2, "restart level "..(lvl+1), readlevel)
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
		for j=1,2 do
			knightofs[j]=i*v[j]
		end
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
