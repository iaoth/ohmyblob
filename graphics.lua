fadeout=
{[7]={7,6,13,5,1,0},
 [10]={10,9,8,4,5,0},
 [15]={15,9,14,4,2,0},
 [11]={11,3,5,1,0,0},
 [6]={6,13,5,1,0,0},
 [9]={9,8,4,2,0,0},
 [12]={12,13,5,1,0,0},
 [14]={14,8,4,2,0,0},
 [13]={13,5,1,0,0,0},
 [3]={3,5,1,0,0,0},
 [8]={8,4,2,0,0,0},
 [4]={4,2,0,0,0,0},
 [5]={5,1,0,0,0,0},
 [2]={2,1,0,0,0,0},
 [1]={1,1,0,0,0,0},
 [0]={0,0,0,0,0,0}}

firecol={
    {[8]=8,[9]=9,[10]=10,[7]=7},
    {[8]=9,[9]=10,[10]=7,[7]=7},
    {[8]=8,[9]=9,[10]=10,[7]=7},
    {[8]=2,[9]=8,[10]=9,[7]=10},
    {[8]=0,[9]=2,[10]=8,[7]=9},
    {[8]=2,[9]=8,[10]=9,[7]=10}
}

function center(str,y,col,wide)
	local x=64-#str*2-(wide or 0)*2
	print(str,x-1,y,0)
	print(str,x+1,y,0)
	print(str,x,y-1,0)
	print(str,x,y+1,0)
	print(str,x,y,col)
end

spritefire={}
fireframe=0

function firebucket(s,x,y)
    return s*8+(flr(x/16))*8+flr(y/16)
end

function sprt(s,x,y,...)
    local fire,fi=fget(s,4),0
    if fire then
        local fb=firebucket(s,x,y)
        if (time())%0.12<0.017 then
            spritefire[fb]=1+flr(fb+time()*2+rnd(0.8))%#firecol
        end
        fi=spritefire[fb] or 1
    end
	if fget(s,6) then
		palt(14,true)
		palt(0,false)
	end
    if (fire) palswap(firecol[fi])
	spr(s,x,y,...)
    if (fire) palswaprevert(firecol[fi])
	palt()
end

function drawbackground(width,height)
	local w=width or 96
	local h=height or 112
	palt(0,false)
	for x=0,w,16 do
		for y=0,h,16 do
			spr(64,x+8,y,2,2)
		end
	end
	palt()
end

function drawobject(obj,x,y)
	if (not obj) return
	if obj.typ=="blob" then
		drawblob(x,y,obj)
	elseif obj.typ=="heart" then
		spr(32,
			(x-1)*16+13+sin(musictick/160)*3,
			(y-1)*16+2+sin(musictick/80)*1,
			1,1)
	elseif obj.spr then
		sprt(obj.spr,(x-1)*16+8,(y-1)*16,2,2)
	end
	if obj.hat then
		sprt(obj.hat,(x-1)*16+8,(y-2)*16,2,2)
	end
end

function drawknight_alive()
	local s=42
	if (knightmoving) s=12+frame
	spr(s,
		(knight[1]-1)*16+knightofs[1]+8,
		(knight[2]-1)*16+knightofs[2]-4,
		2, 2
	)
end

function drawknight_dead()
	local s=44
	if (musictick>130 or musictick<0) s=46
	spr(s,(knight[1]-1)*16+knightofs[1]+8,
		(knight[2]-1)*16+knightofs[2]-4,2,2)
end

function drawportal()
    local f=flr(time()*7)%4
	spr(96+2*f,(portal[1]-1)*16+8,(portal[2]-1)*16,2,2)
end

function fadepal(index)
	for i=1,15 do
		pal(i,fadeout[i][index or fadeindex])
	end
end

function palswap(p)
	if (not p) return
	for k,v in pairs(p) do
		if k=="t" then
			palt(v)
		else
			pal(k,fadeout[v][fadeindex])
		end
	end
end

function palswaprevert(p)
	if (not p) return
	for k,v in pairs(p) do
		if k!="t" then
			pal(k,fadeout[k][fadeindex])
		end
	end
end

function drawblob(x,y,b)
	local o=b.o or {0,0}
	local sx,sy=(x-1)*16+o[1]+8,(y-1)*16+o[2]-4
	palswap(gettrait(b,"col"))
	if b.s>3 then
		if (frame1==0) palswap(blobtraits.glow.col)
		spr(10,sx,sy,2,2)
		if (frame1==0) palswaprevert(blobtraits.glow.col)
	else
		local f=4*(b.s-1)
		if (not b.stun) f+=frame
		spr(f,sx,sy,2,2)
	end
	palswaprevert(gettrait(b,"col"))
end
