screens.title.init=function()
	music(-1)
	cologoanim=cocreate(logoanim)
	grid={{},{},{},{},{},{},{},{},{}}
	mx=0
	ly={-70,-39,-36}
	blx=0
	blheight=40
	blwidth=112
	lastknight=0
	level=level or 0
	levelmax=32
	selected=nil
	frame=0
	menuitem(1)
end

screens.title.update=function()
	frame+=1
	mx-=1/3
	if mx<=-16 then
		mx+=16
		del(grid,grid[1])
		add(grid,{})
		lastknight+=1
		if not cologoanim then
			local sq=10-flr(sqrt(rnd(100)))
			local objs=flr(sq/3)
			for i=1,objs do
				local obj
				if rnd(1)>0.7 then
					obj={typ="blob",t=blobtypes[flr(rnd(6)+1)],s=flr(rnd(3)+1),stun=true}
				elseif rnd(1)>0.9 and lastknight>24 then
					obj={spr=12}
					lastknight=0
				elseif rnd(1)>0.95 and lastknight>24 then
					obj={spr=46}
					lastknight=0
				else
					obj={spr=106,hat=74}
					obj.hat=obj.spr-32
				end
				grid[9][flr(rnd(7)+2)]=obj
			end
		end
	end

	if selected then
		selected+=1
		if selected>60 then
			changescreen("levelstart")
		end
	end

	if cologoanim then
		coresume(cologoanim)
		if costatus(cologoanim)=="dead" then
			cologoanim=nil
		end
	else
		if (btnp(4) or btnp(5)) then
			selected=0
			sfx(30)
		elseif btnp(1) and level<levelmax then
			level+=1
			sfx(7,-1,0,7)
		elseif btnp(0) and level>0 then
			level-=1
			sfx(7,-1,0,7)
		end
	end
end

screens.title.draw=function()
	if selected then
		fadeindex=flr(selected/10)+1
		fadepal()
	end

	palt(0,false)
	palt(1,false)

	camera(-mx,0)
	drawbackground(128)

	palt()

	for x=1,9 do
		for y=1,9 do
			drawobject(grid[x][y],x,y)
		end
	end

	camera(0,0)
	palt(0,false)
	palt(14,true)

	spr(128,29,15+ly[2],5,3) --oh
	spr(133,66,15+ly[3],5,3) --my
	sspr(0,88,112,40,      --blob!
		12+blx,31+ly[1],
		blwidth,blheight)

	if not cologoanim then
		drawmenu(selected)
	end
end

function drawmenu(start)
	local fade={0,5,13,6,7,7,7,6,13,5}
	center("❎/🅾️ start game",85,7,2)
	center("⬅️/➡️  level "..pad(level+1,2).." ",93,12,2)
	center("DESIGN,GFX&MUSIC:joakim almgren",112,9)
	center("ADD.GFX:jim almgren&rica march",120,9)
end

function logoanim()
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
