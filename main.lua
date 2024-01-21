
function love.load()

	local bgcolor= {r=200,g=100,b=100}

	splash= "splash"
	size=80
    	prob=0.2

	Rule={[0]=0,[1]=0,[2]=1,[3]=1,[4]=1,[5]=1,[6]=0,[7]=0,[8]=0}
	Cells = ARRAY2D(size,size)
	Cells = Init(Cells,prob)
	DisplayCells = ARRAY2D(size,size)

end

function love.draw()

	love.graphics.setColor(255,255,255)

	for i,v in ipairs(DisplayCells) do
		for j,w in ipairs(v) do
			x=i/size *800
			y=j/size *600

			if w==1 then
				love.graphics.setColor(255,0,0)
			elseif w==2 then
				love.graphics.setColor(0,255,0)
			elseif w==3 then
				love.graphics.setColor(0,0,255)
			elseif w==0 then
				love.graphics.setColor(0,0,0)
			end
			love.graphics.rectangle("fill",x,y,800/size,600/size)
		end
	end

end

function love.keypressed(key)

	if key=="escape" then
		love.event.push('quit')
	end
	if key=="return" then
		Cells = Init(Cells,prob)
	end

	if key=="kp+" then
		local oldCells=Cells
		size=math.floor(size*1.5)
		print("resize "..size)
		NewCells = ARRAY2D(size,size)
		for i,v in ipairs(oldCells) do
			for j,w in ipairs(v) do
				NewCells[i][j]=w	
			end
		end
		
		Cells=NewCells


	elseif key=="kp-" then
		local oldCells=Cells
		size=math.floor(size/1.5)
		print("resize "..size)
		NewCells = ARRAY2D(size,size)
		for i,v in ipairs(NewCells) do
			for j,w in ipairs(v) do
				NewCells[i][j]=oldCells[i][j]
			end
		end
		Cells=NewCells
	end

	if 	key =="0" or
		key =="1" or
		key =="2" or
		key =="3" or
		key =="4" or
		key =="5" or
		key =="6" or
		key =="7" or
		key =="8" then

		print("-Rule")
		Rule[tonumber(key)]= 1-Rule[tonumber(key)]
		for i,v in ipairs(Rule) do print(i,v) end
		print("-")
	end

	DisplayCells = ARRAY2D(size,size)
end




function love.quit()
	print("The End")
	return false
end

function love.update(dt)


	if not(love.keyboard.isDown("space")) then
		UpdateCells(Cells,Rule)
		UpdateDisplayCells(DisplayCells,Cells)
	else
		local x = love.mouse.getX()
		local y = love.mouse.getY()
		local r = love.mouse.isDown(1)
		local l = love.mouse.isDown(2)
		local m = love.mouse.isDown(3)
		local typ=0
		local i = x/800 * size
		local j = y/600 * size
		i = math.floor(i)
		j = math.floor(j)

		if r then typ=1
		elseif l then typ=2
		elseif m then typ=3
		end

		Cells[i][j] =typ
		Cells[i-1][j] =typ
		Cells[i+1][j] =typ
		Cells[i][j-1] =typ
		Cells[i][j+1] =typ
	end

end


-----------------------------------------------


function ARRAY2D(w,h)
  local Cells = {w=w,h=h}
  local mt ={}

  mt.__index= function (table, key)
					local r
					if key < 1 then r= table[#table]
					else r= table[1]	end
					return r
				end
  setmetatable(Cells,mt)
  for y=1,h do
    Cells[y] = {}
	setmetatable(Cells[y],mt)
    for x=1,w do
      Cells[y][x]=0
    end
  end

  return Cells
end

function Init(t,p)
	local w,h = t["w"],t["h"]
	for i = 1,h do
		for j =1,w do
			v = math.random()
			if v<p then t[i][j]=1 end
			if v>1-p then t[i][j]=2 end
			if v<0.5+0.5*p and v>0.5-0.5*p then t[i][j]=3 end
		end
	end
	return t
end



function UpdateCells(t,Rule)
	local width,height = t["w"],t["h"]
	local temp = {w,h}
	--positions
	local a,b,c,d,e,f,g,h = 0,0,0,0,0,0,0,0
	--
	local Sel1 = {[1]=1}
	local Sel2 = {[2]=1}
	local Sel3 = {[3]=1}
	local mt ={}
	local s,typ, d1 ,d2 ,d3 =0,0,0,0,0

	for y=1,height do
		temp[y] = {}
		for x=1,width do
			temp[y][x]={typ=0,s=0}
		end
	end

	mt.__index = function (table,key) return 0 end
	setmetatable(Sel1,mt)
	setmetatable(Sel2,mt)
	setmetatable(Sel3,mt)

	for i =1,height do
		for j =1,width do
			a=t[i-1][j]
			b=t[i+1][j]
			c=t[i][j-1]
			d=t[i][j+1]
			e=t[i-1][j-1]
			f=t[i+1][j+1]
			g=t[i+1][j-1]
			h=t[i-1][j+1]

			d1=Sel1[a]+	Sel1[b]+ Sel1[c]+ Sel1[d] +
				Sel1[e]+ Sel1[f]+ Sel1[g]+ Sel1[h]
			d2=Sel2[a]+	Sel2[b]+ Sel2[c]+ Sel2[d] +
				Sel2[e]+ Sel2[f]+ Sel2[g]+ Sel2[h]
			d3=Sel3[a]+ Sel3[b]+ Sel3[c]+ Sel3[d] +
				Sel3[e]+ Sel3[f]+ Sel3[g]+ Sel3[h]

			if d1>2  then
				s=d1
				typ=1
				if d3>2  then
					s=d3
					typ=3
				end
			elseif d2>2 then
				s=d2
				typ=2
				if d1>2  then
					s=d1
					typ=1
				end
			elseif d3>2 then
				s=d3
				typ=3
				if d2>2 then
					s=d2
					typ=2
				end
			else
					s=0
					typ=0
			end
			temp[i][j].typ=typ
			temp[i][j].s=s
		end
	end

	for i =1,height do
		for j =1,width do
			t[i][j]=Rule[temp[i][j].s]*temp[i][j].typ
		end
	end


end



function UpdateDisplayCells(D,C)
	local width,height = C["w"],C["h"]


	for i =1,height do
		for j =1,width do
			if C[i][j] ~= 0 then
				D[i][j]=C[i][j]
			end
		end
	end

	

end


