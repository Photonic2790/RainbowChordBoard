-- Rainbow Chord Board: By Photonic2790@github.com
--[[Description:
A cross platform port of Rainbow Chord Board - My summer 2024 guitar learning/Win32 coding project.
A string instrument chord finder with colour coding following a rainbow spectrum
Original concept from 'Optiks' - by Isaac Newton, 1706 
eg Major Key Tonic = Red, ii Orange, iii Yellow, IV Green, V Blue, vi Indigo, vii- Violet
Includes string tuning buttons for a multitude of tunings and instrument fretboards to display.
]]

local TITLE = "Rainbow Chord Board"
local width, height = love.window.getMode()
love.window.setMode(width, height, {fullscreen=true, resizable=true, vsync=0, minwidth=320, minheight=240})
width, height = love.window.getMode()
local WINDOWWIDTH  = width
local WINDOWHEIGHT = height
local BUTTONSIZE = height / 10
local IMAGESCALE = BUTTONSIZE / 48
-- eOOOOOOOOOOOO|     -- button size(48) * 13 + small string adjustment buttons(16) = WIDTH
-- BOOOOOOOOOOOO|
-- GOOOOOOOOOOOO|
-- AOOOOOOOOOOOO|
-- DOOOOOOOOOOOO|
-- EOOOOOOOOOOOO|
-- Ⓞ③ ⑤ ⑦ ⑨ ⑫
-- Koooooooooooo
-- MXXXXXXXXXXXX
-- ☷☷☷☷☷☷☷☷🜆
-- button size(48) * 10 = height

local BGCOLOR = { .6,  .55,  .45 }
local FGCOLOR = { .6,  .55,  .45 , 1}

local key = 3 -- +1 = half step, a variable to store the key. 3 = C, 0 = A, 11 = G sharp / A flat, marked with T
local root = 3 -- when choosing chords in a key this holds the root to the current chord, marked with R
local chord = 0 -- 1 major, 2 minor like MAJ ii, 3 minor like MAJ iii (1/2step to second) 
					-- for distinguishing between types of chords when adding a note (bottom row buttons math)

local n,o,p = 0 -- some math vars
local mx, my = 0
local mdelay = 0

-- individual string tunings // -1 == off
local OffsetOne = 7 		-- High e
local OffsetTwo = 2 		--      B
local OffsetThree = 10  	--      G
local OffsetFour = 5	 	--      D
local OffsetFive = 0	 	--      A
local OffsetSix = 7 		--      E
local stringOffset = 7      --  note to align with the left edge of the screen, open tuning of the guitar string

-- for readability these get individual variables, a boolean setting which interval steps to colour or gray out
local DrawMajMin = 1 -- set colours for major or minor scale intervals
local DrawFirst = 1
local DrawSecond = -1
local DrawThird = 1
local DrawFourth = -1
local DrawFifth = 1
local DrawSixth = 1
local DrawSeventh = -1
local DrawEighth = 1
local DrawNinth = -1
local DrawTenth = 1
local DrawEleventh = -1
local DrawTwelth = 1

local DialogWindow = 0

function SetDrawColours(first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelth)
	chord = 0
	root = key
							 --   Major 		Minor
	DrawFirst = first		 --    R-------------R
	DrawSecond = second	 	 --    _-------------O
	DrawThird = third		 --    O-------------_
	DrawFourth = fourth	 	 --    _-------------Y
	DrawFifth = fifth		 --    Y-------------_
	DrawSixth = sixth		 --    G-------------G
	DrawSeventh = seventh	 --    _-------------_
	DrawEighth = eighth      --    B-------------B
	DrawNinth = ninth		 --    _-------------I
	DrawTenth = tenth		 --    I-------------_
	DrawEleventh = eleventh  --    _-------------V
	DrawTwelth = twelth	 	 --    V-------------_

end

function SetChordAdjustment(n, a) -- n is the magic number depending on what key and chord combo is active
	while (n < 0) do n = n + 12 end
	while (n > 11) do n = n - 12 end
	if (n == 0) then  	    DrawFirst     = a
	elseif (n == 1) then  	DrawSecond    = a
	elseif (n == 2) then  	DrawThird     = a
	elseif (n == 3) then  	DrawFourth    = a
	elseif (n == 4) then  	DrawFifth     = a
	elseif (n == 5) then  	DrawSixth     = a
	elseif (n == 6) then  	DrawSeventh   = a
	elseif (n == 7) then  	DrawEighth    = a
	elseif (n == 8) then  	DrawNinth     = a
	elseif (n == 9) then  	DrawTenth     = a
	elseif (n == 10) then 	DrawEleventh  = a
	elseif (n == 11) then 	DrawTwelth    = a
	end
end

function SetPresetTuning(HighE,B,G,D,A,E)
	OffsetOne = HighE
	OffsetTwo = B
	OffsetThree = G
	OffsetFour = D
	OffsetFive = A
	OffsetSix = E
end

function love.load()

    love.window.setTitle(TITLE)
    love.window.setMode(WINDOWWIDTH, WINDOWHEIGHT, {resizable=true, vsync=0, minwidth=320, minheight=240})
    love.graphics.setBackgroundColor(BGCOLOR)
	font = love.graphics.newFont(14)
	
	-- fake cursor if needed eg. handheld devices
	RCB_cursor = love.graphics.newImage("gfx/rcb-cursor.png")
    love.mouse.setVisible(false)
	
	-- load highlight circle tiles 
	hbmString 		= love.graphics.newImage("gfx/string.png")
	hbmGray 		= love.graphics.newImage("gfx/gray.png")
	hbmRed 			= love.graphics.newImage("gfx/red.png")
	hbmRedOrange 	= love.graphics.newImage("gfx/red-orange.png")
	hbmOrange 		= love.graphics.newImage("gfx/orange.png")
	hbmOrangeYellow = love.graphics.newImage("gfx/orange-yellow.png")
	hbmYellow 		= love.graphics.newImage("gfx/yellow.png")
	hbmYellowGreen 	= love.graphics.newImage("gfx/yellow-green.png")
	hbmGreen 		= love.graphics.newImage("gfx/green.png")
	hbmGreenBlue 	= love.graphics.newImage("gfx/green-blue.png")
	hbmBlue 		= love.graphics.newImage("gfx/blue.png")
	hbmBlueIndigo 	= love.graphics.newImage("gfx/blue-indigo.png")
	hbmIndigo 		= love.graphics.newImage("gfx/indigo.png")
	hbmIndigoViolet = love.graphics.newImage("gfx/indigo-violet.png")
	hbmViolet 		= love.graphics.newImage("gfx/violet.png")
	hbmVioletRed 	= love.graphics.newImage("gfx/violet-red.png")
	
	hbmFrets 		= love.graphics.newImage("gfx/frets.png")
	hbmLeft 		= love.graphics.newImage("gfx/left.png")
	hbmRight 		= love.graphics.newImage("gfx/right.png")
	hbmUp 			= love.graphics.newImage("gfx/up.png")
	hbmDown 		= love.graphics.newImage("gfx/down.png")
	hbmMajor 		= love.graphics.newImage("gfx/major.png")
	hbmMinor 		= love.graphics.newImage("gfx/minor.png")
	--  hbmTile 		= love.graphics.newImage("gfx/tile.png")
	hbmKeyLabel 	= love.graphics.newImage("gfx/key.png")
	hbmPresets 		= love.graphics.newImage("gfx/presets.png")
	hbmOff 			= love.graphics.newImage("gfx/off.png")
	--  hbmTuning 		= love.graphics.newImage("gfx/tuning.png")
	hbmRoot 		= love.graphics.newImage("gfx/root.png")
	hbmTonic 		= love.graphics.newImage("gfx/tonic.png")
	--  hbmChords 		= love.graphics.newImage("gfx/chords.png")
	
end

function love.draw()
	width, height = love.window.getMode()
	BUTTONSIZE = width / 13.33
	if height < BUTTONSIZE * 10 then BUTTONSIZE = height / 10 end
	IMAGESCALE = BUTTONSIZE / 48
-- "[{[BUTTONS]}]" -- 
-- in a standard program this would be a function, on a page after a menu perhaps
-- but this is just a static button board one screen mode application, so I choose to simply write it all here in draw()
	mx, my = love.mouse.getPosition()
	mdelay = mdelay + 1 
	local bs = BUTTONSIZE -- 48 -- button size (same as image size)
    if (mdelay >= 20) and (love.mouse.isDown(1) or love.mouse.isDown(2) or love.mouse.isDown(3)) then
		mdelay = 0
		if (DialogWindow ~= 0) then DialogWindow = 0 -- disables all buttons (even close) while a dialog is open
-- KEY CHANGING BUTTONS
		elseif (mx < bs and my > bs * 7 and my < bs * 7.5) then -- KEY UP
			key = key + 1
			if (key > 11) then key = 0 end
			root = root + 1 -- keep chord root markers moving with key changes
			if (root > 11) then root = 0 end
		elseif (mx < bs and my > bs * 7.5 and my < bs * 8) then -- KEY DOWN
			key = key - 1
			if (key < 0) then key = 11 end
			root = root - 1 -- keep chord root markers moving with key changes
			if (root < 0) then root = 11 end
-- STRING TUNING / TOGGLE
		elseif (mx > bs * 13 and my < 16) then -- High e String tune left			
			OffsetOne = OffsetOne + 1
			if (OffsetOne > 11) then OffsetOne = 0 end
		elseif (mx > bs * 13 and my > 16 and my < 32) then -- High e String tune right			
			OffsetOne = OffsetOne - 1
			if (OffsetOne < 0) then OffsetOne = 11 end
		elseif (mx > bs * 13 and my > 32 and my < bs) then -- High e String tune off			
			OffsetOne = - 1
		elseif (mx > bs * 13 and my > bs and my < bs + 16) then -- B String tune left			
			OffsetTwo = OffsetTwo + 1
			if (OffsetTwo > 11) then OffsetTwo = 0 end
		elseif (mx > bs * 13 and my > bs + 16 and my < bs + 32) then -- B String tune right			
			OffsetTwo = OffsetTwo - 1
			if (OffsetTwo < 0) then OffsetTwo = 11 end
		elseif (mx > bs * 13 and my > bs + 32 and my < bs * 2) then -- B String tune off			
			OffsetTwo = - 1
		elseif (mx > bs * 13 and my > bs * 2 and my < bs * 2 + 16) then -- G String tune left			
			OffsetThree = OffsetThree + 1
			if (OffsetThree > 11) then OffsetThree = 0 end
		elseif (mx > bs * 13 and my > bs * 2 + 16 and my < bs * 2 + 32) then -- G String tune right			
			OffsetThree = OffsetThree - 1
			if (OffsetThree < 0) then OffsetThree = 11 end
		elseif (mx > bs * 13 and my > bs * 2 + 32 and my < bs * 3) then -- G String tune off			
			OffsetThree = - 1
		elseif (mx > bs * 13 and my > bs * 3 and my < bs * 3 + 16) then -- D String tune left			
			OffsetFour = OffsetFour + 1
			if (OffsetFour > 11) then OffsetFour = 0 end
		elseif (mx > bs * 13 and my > bs * 3 + 16 and my < bs * 3 + 32) then -- D String tune right			
			OffsetFour = OffsetFour - 1
			if (OffsetFour < 0) then OffsetFour = 11 end
		elseif (mx > bs * 13 and my > bs * 3 + 32 and my < bs * 4) then -- D String tune off			
			OffsetFour = - 1
		elseif (mx > bs * 13 and my > bs * 4 and my < bs * 4 + 16) then -- A String tune left			
			OffsetFive = OffsetFive + 1
			if (OffsetFive > 11) then OffsetFive = 0 end
		elseif (mx > bs * 13 and my > bs * 4 + 16 and my < bs * 4 + 32) then -- A String tune right			
			OffsetFive = OffsetFive - 1
			if (OffsetFive < 0) then OffsetFive = 11 end
		elseif (mx > bs * 13 and my > bs * 4 + 32 and my < bs * 5) then -- A String tune off			
			OffsetFive = - 1
		elseif (mx > bs * 13 and my > bs * 5 and my < bs * 5 + 16) then -- LOW E String tune left			
			OffsetSix = OffsetSix + 1
			if (OffsetSix > 11) then OffsetSix = 0 end
		elseif (mx > bs * 13 and my > bs * 5 + 16 and my < bs * 5 + 32) then -- LOW E String tune right			
			OffsetSix = OffsetSix - 1
			if (OffsetSix < 0) then OffsetSix = 11 end
		elseif (mx > bs * 13 and my > bs * 5 + 32 and my < bs * 6) then -- LOW E String tune off			
			OffsetSix = - 1
			
-- INDIVIDUAL COLOUR TOGGLE BUTTONS
		elseif (mx > bs and mx < bs * 2 and my > bs * 7 and my < bs * 8) then -- RED toggle button
			DrawFirst = DrawFirst * -1
		elseif (mx > bs * 2 and mx < bs * 3 and my > bs * 7 and my < bs * 8) then
			DrawSecond = DrawSecond * -1
		elseif (mx > bs * 3 and mx < bs * 4 and my > bs * 7 and my < bs * 8) then
			DrawThird = DrawThird * -1
		elseif (mx > bs * 4 and mx < bs * 5 and my > bs * 7 and my < bs * 8) then
			DrawFourth = DrawFourth * -1
		elseif (mx > bs * 5 and mx < bs * 6 and my > bs * 7 and my < bs * 8) then
			DrawFifth = DrawFifth * -1
		elseif (mx > bs * 6 and mx < bs * 7 and my > bs * 7 and my < bs * 8) then
			DrawSixth = DrawSixth * -1
		elseif (mx > bs * 7 and mx < bs * 8 and my > bs * 7 and my < bs * 8) then
			DrawSeventh = DrawSeventh * -1
		elseif (mx > bs * 8 and mx < bs * 9 and my > bs * 7 and my < bs * 8) then
			DrawEighth = DrawEighth * -1
		elseif (mx > bs * 9 and mx < bs * 10 and my > bs * 7 and my < bs * 8) then
			DrawNinth = DrawNinth * -1
		elseif (mx > bs * 10 and mx < bs * 11 and my > bs * 7 and my < bs * 8) then
			DrawTenth = DrawTenth * -1
		elseif (mx > bs * 11 and mx < bs * 12 and my > bs * 7 and my < bs * 8) then
			DrawEleventh = DrawEleventh * -1
		elseif (mx > bs * 12 and mx < bs * 13 and my > bs * 7 and my < bs * 8) then
			DrawTwelth = DrawTwelth * -1
			
-- Major / Minor scale toggle button		
		elseif (mx < bs and my > bs * 8 and my < bs * 9) then -- MAJ/MIN
			DrawMajMin = DrawMajMin * -1
			if (DrawMajMin == 1) then		-- Major Scale                  V the half step interval values to draw
				SetDrawColours(1, -1, 1, -1, 1, 1, -1, 1, -1, 1, -1, 1)  --  1 3 5 6 8 10 12
			else						    -- Minor Scale
				SetDrawColours(1, -1, 1, 1, -1, 1, -1, 1, 1, -1, 1, -1)  --  1 3 4 6 8 9 11
			end
			
-- Current key and scale chord drawing buttons
		elseif (mx > bs and mx < bs * 2 and my > bs * 8 and my < bs * 9) then 			-- first
			if (DrawMajMin == 1) then 			-- Major I
				SetDrawColours(1, -1, -1, -1, 1, -1, -1, 1, -1, -1, -1, -1) -- 1 5 8
				chord = 1
			else                  			-- Minor i
				SetDrawColours(1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, -1) -- 1 4 8
				chord = 2
			end
		elseif (mx > bs * 3 and mx < bs * 4 and my > bs * 8 and my < bs * 9) then 		-- third
			if (DrawMajMin == 1) then 			-- Major ii
				SetDrawColours(-1, -1, 1, -1, -1, 1, -1, -1, -1, 1, -1, -1) -- 3 6 10
				root = root + 2
				chord = 2
			else                  			-- Minor ii-
				SetDrawColours(-1, -1, 1, -1, -1, 1, -1, -1, 1, -1, -1, -1)  -- 3 6 9
				root = key + 2
				chord = 3
			end
		elseif (mx > bs * 4 and mx < bs * 5 and my > bs * 8 and my < bs * 9) then 		-- fourth
			if (DrawMajMin ~= 1) then			-- Minor III
				SetDrawColours(-1, -1, -1, 1, -1, -1, -1, 1, -1, -1, 1, -1)  -- 4 8 11
				root = root + 3
				chord = 1
			end
		elseif (mx > bs * 5 and mx < bs * 6 and my > bs * 8 and my < bs * 9) then 		-- fifth
			if (DrawMajMin == 1) then 			-- Major iii
				SetDrawColours(-1, -1, -1, -1, 1, -1, -1, 1, -1, -1, -1, 1)  -- 5 8 12
				root = root + 4
				chord = 2
			end
		elseif (mx > bs * 6 and mx < bs * 7 and my > bs * 8 and my < bs * 9) then 		-- sixth
			if (DrawMajMin == 1) then 			-- Major IV
				SetDrawColours(1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1) -- 6 10 1
				root = root + 5
				chord = 1
			else                  			-- Minor iv
				SetDrawColours(1, -1, -1, -1, -1, 1, -1, -1, 1, -1, -1, -1) -- 6 9 1
				root = root + 5
				chord = 2
			end
		elseif (mx > bs * 8 and mx < bs * 9 and my > bs * 8 and my < bs * 9) then 		-- eighth
			if (DrawMajMin == 1) then 			-- Major V
				SetDrawColours(-1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1, 1)  -- 8 12 3
				root = root + 7
				chord = 1
			else                  			-- Minor v
				SetDrawColours(-1, -1, 1, -1, -1, -1, -1, 1, -1, -1, 1, -1)  -- 8 11 3
				root = root + 7
				chord = 2
			end
		elseif (mx > bs * 9 and mx < bs * 10 and my > bs * 8 and my < bs * 9) then 		-- ninth
			if (DrawMajMin ~= 1) then 			-- Minor VI
				SetDrawColours(1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1) -- 9 1 4
				root = root + 8
				chord = 1
			end
		elseif (mx > bs * 10 and mx < bs * 11 and my > bs * 8 and my < bs * 9) then 	-- tenth
			if (DrawMajMin == 1) then 			-- Major vi
				SetDrawColours(1, -1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1) -- 10 1 5
				root = root + 9
				chord = 2
			end
		elseif (mx > bs * 11 and mx < bs * 12 and my > bs * 8 and my < bs * 9) then 	-- eleventh
			if (DrawMajMin ~= 1) then 			-- Minor VII
				SetDrawColours(-1, -1, 1, -1, -1, 1, -1, -1, -1, -1, 1, -1) -- 11 3 6
				root = root + 10
				chord = 1
			end
		elseif (mx > bs * 12 and mx < bs * 13 and my > bs * 8 and my < bs * 9) then 	-- twelth
			if (DrawMajMin == 1) then 			-- Major vii-
				SetDrawColours(-1, -1, 1, -1, -1, 1, -1, -1, -1, -1, -1, 1) -- 12 3 6
				root = root + 11
				chord = 3
			end
			
		-- PRESETS SCALES
		elseif (mx > bs and mx < bs * 2 and my > bs * 9 and my < bs * 9.5) then -- Pentatonic
			if (DrawMajMin == 1) then
				SetDrawColours(1, -1, 1, -1, 1, -1, -1, 1, -1, 1, -1, -1)
			else
				SetDrawColours(1, -1, -1, 1, -1, 1, -1, 1, -1, -1, 1, -1)
			end
		elseif (mx > bs * 2 and mx < bs * 3 and my > bs * 9 and my < bs * 9.5) then -- Harmonic
			if (DrawMajMin == 1) then
				SetDrawColours(1, -1, 1, -1, 1, 1, -1, 1, 1, -1, -1, 1)
			else
				SetDrawColours(1, -1, 1, 1, -1, 1, -1, 1, 1, 1, -1, -1)
			end
		elseif (mx > bs * 3 and mx < bs * 4 and my > bs * 9 and my < bs * 9.5) then -- Blues
			if (DrawMajMin == 1) then
				SetDrawColours(1, -1, 1, 1, 1, -1, -1, 1, -1, 1, -1, -1)
			else
				SetDrawColours(1, -1, -1, 1, -1, 1, 1, 1, -1, -1, 1, -1)
			end
		elseif (mx > bs * 4 and mx < bs * 5 and my > bs * 9 and my < bs * 9.5) then -- bebop
			if (DrawMajMin == 1) then	-- Major Scale
				SetDrawColours(1, -1, 1, -1, 1, 1, -1, 1, 1, 1, -1, 1)
			else						-- Minor Scale
				SetDrawColours(1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, -1)
			end
		elseif (mx > bs * 5 and mx < bs * 6 and my > bs * 9 and my < bs * 9.5) then -- Dorian
			SetDrawColours(1, -1, 1, 1, -1, 1, -1, 1, -1, 1, 1, -1)
		
		-- PRESET TUNINGS
		elseif (mx > bs * 7 and mx < bs * 8 and my > bs * 9 and my < bs * 9.5) then -- E Standard
			SetPresetTuning(7, 2, 10, 5, 0, 7) -- e B G D A E
		elseif (mx > bs * 8 and mx < bs * 9 and my > bs * 9 and my < bs * 9.5) then -- E Flat
			SetPresetTuning(6, 1, 9, 4, 11, 6) -- eb Bb Gb Db Ab Eb
		elseif (mx > bs * 9 and mx < bs * 10 and my > bs * 9 and my < bs * 9.5) then -- Drop D
			SetPresetTuning(7, 2, 10, 5, 0, 5) -- e B G D A D
		elseif (mx > bs * 10 and mx < bs * 11 and my > bs * 9 and my < bs * 9.5) then -- Open G
			SetPresetTuning(5, 2, 10, 5, 10, 5) -- d B G D G D
		elseif (mx > bs * 11 and mx < bs * 12 and my > bs * 9 and my < bs * 9.5) then -- Bass
			SetPresetTuning(-1, -1, 10, 5, 0, 7) -- OFF OFF G D A E
		elseif (mx > bs * 12 and mx < bs * 13 and my > bs * 9 and my < bs * 9.5) then -- Violin
			SetPresetTuning(-1, -1, 7, 0, 5, 10) -- OFF OFF G D A E

		elseif ( my > bs * 9.5 and my < bs * 10) then -- Chord Adjustments 

			-- this is where music theory meets math and calculates notes to draw
			if (mx < bs * 2) then -- Dom 7 button
				if (chord == 1 or chord == 2 or chord == 3) then
					n = root - key - 2 
					SetChordAdjustment(n,1)
					n = n + 1
					SetChordAdjustment(n,-1)
				end
			elseif (mx < bs * 3) then -- Maj 7 button
				if (chord == 1 or chord == 2 or chord == 3) then
					n = root - key - 2
					SetChordAdjustment(n,-1)
					n = n + 1
					SetChordAdjustment(n,1)
				end
			elseif (mx < bs * 4) then -- add 9 button
				if (chord == 1 or chord == 2 or chord == 3) then
					n = root - key + 2
					SetChordAdjustment(n,1)
				end
			elseif (mx < bs * 5) then -- add 11 button
				if (chord == 1 or chord == 2 or chord == 3) then
					n = root - key + 5
					SetChordAdjustment(n,1)
				end
			elseif (mx < bs * 6) then -- add 13 button
				if (chord == 1 or chord == 2 or chord == 3) then
					n = root - key + 8
					SetChordAdjustment(n,1)
				end
			elseif (mx < bs * 7) then -- sus4 button
				if (chord == 1) then -- major third
					n = root - key + 5
					SetChordAdjustment(n,1)
					n = n - 1
					SetChordAdjustment(n,-1)
				elseif (chord == 2 or chord == 3) then -- minor third
					n = root - key + 5
					SetChordAdjustment(n,1)
					n = n - 2
					SetChordAdjustment(n,-1)
				end
			elseif (mx < bs * 8) then -- sus2 button
				if (chord == 1) then -- major third
					n = root - key + 2
					SetChordAdjustment(n,1)
					n = n + 2
					SetChordAdjustment(n,-1)
				elseif (chord == 2 or chord == 3) then -- minor third
					n = root - key + 2
					SetChordAdjustment(n,1)
					n = n + 1
					SetChordAdjustment(n,-1)
				end
			elseif (mx < bs * 9) then -- aug4 button
				if (chord == 1) then -- major third
					n = root - key + 6
					SetChordAdjustment(n,1)
					n = n + 1
					SetChordAdjustment(n,-1)
				elseif (chord == 2) then -- minor third
					n = root - key + 6
					SetChordAdjustment(n,1)
					n = n + 1
					SetChordAdjustment(n,-1)
				elseif (chord == 3) then -- diminished 5th
					n = root - key + 5
					SetChordAdjustment(n,1)
					n = n + 1
					SetChordAdjustment(n,-1)
				end
			elseif (mx < bs * 10) then -- aug5 button
				if (chord == 1 or chord == 2) then -- major 5th
					n = root - key + 8
					SetChordAdjustment(n,1)
					n = n - 1
					SetChordAdjustment(n,-1)
				elseif (chord == 3) then -- diminished 5th
					n = root - key + 7
					SetChordAdjustment(n,1)
					n = n - 1
					SetChordAdjustment(n,-1)
				end
				
			elseif (mx > bs * 10 and mx < bs * 11) then -- ABOUT
				DialogWindow = 1
			elseif (mx > bs * 11 and mx < bs * 12) then -- HELP
				DialogWindow = 2				
			elseif (mx > bs * 12 and mx < bs * 13) then	-- CLOSE-- love.event.quit()
				love.event.quit()
			end -- end of my > 9.5bs buttons (bottom row)
			
		end
		if (root >= 12) then root = root - 12 end -- this cleans up any that got an octave too high
		
			-- end of "[{[BUTTONS]}]"
			
    end
	
	
	stringOffset = 1
	-- Main Rainbow Chord Board Drawing Loop
	love.graphics.setColor(1, 1, 1, 1)
	if (DialogWindow == 0) then
	for i = 0, 5 do -- a loop through for each string, the "vertical" loop, i moves along Y
		if (i == 0) then -- high e
			stringOffset = OffsetOne
		elseif (i == 1) then
			stringOffset = OffsetTwo
		elseif (i == 2) then
			stringOffset = OffsetThree
		elseif (i == 3) then
			stringOffset = OffsetFour
		elseif (i == 4) then
			stringOffset = OffsetFive
		elseif (i == 5) then-- low E
			stringOffset = OffsetSix
		end
		
		for c = 0, 12 do -- the "horizontal" note drawing loop, c moves along X	
			if (stringOffset == -1) then
				love.graphics.draw(hbmGray, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
			elseif (DrawFirst == 1 and (c == (key - stringOffset) or c == (key - stringOffset + 12) or c == (key - stringOffset - 12))) then
				love.graphics.draw(hbmRed, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
			elseif (DrawSecond == 1 and (c == (1 + key - stringOffset) or c == (1 + key - stringOffset + 12) or c == (1 + key - stringOffset - 12))) then
				love.graphics.draw(hbmRedOrange, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
			elseif (DrawThird == 1 and (c == (2 + key - stringOffset) or c == (2 + key - stringOffset + 12) or c == (2 + key - stringOffset - 12))) then
				love.graphics.draw(hbmOrange, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
			elseif (DrawFourth == 1 and (c == (3 + key - stringOffset) or c == (3 + key - stringOffset + 12) or c == (3 + key - stringOffset - 12))) then
				if (DrawMajMin == 1) then
					love.graphics.draw(hbmOrangeYellow, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				else
					love.graphics.draw(hbmYellow, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				end
			elseif (DrawFifth == 1 and (c == (4 + key - stringOffset) or c == (4 + key - stringOffset + 12) or c == (4 + key - stringOffset - 12))) then
				if (DrawMajMin == 1) then
					love.graphics.draw(hbmYellow, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				else
					love.graphics.draw(hbmYellowGreen, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				end				
			elseif (DrawSixth == 1 and (c == (5 + key - stringOffset) or c == (5 + key - stringOffset + 12) or c == (5 + key - stringOffset - 12))) then
				love.graphics.draw(hbmGreen, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
			elseif (DrawSeventh == 1 and (c == (6 + key - stringOffset) or c == (6 + key - stringOffset + 12) or c == (6 + key - stringOffset - 12))) then
				love.graphics.draw(hbmGreenBlue, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
			elseif (DrawEighth == 1 and (c == (7 + key - stringOffset) or c == (7 + key - stringOffset + 12) or c == (7 + key - stringOffset - 12))) then
				love.graphics.draw(hbmBlue, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
			elseif (DrawNinth == 1 and (c == (8 + key - stringOffset) or c == (8 + key - stringOffset + 12) or c == (8 + key - stringOffset - 12))) then
				if (DrawMajMin == 1) then
					love.graphics.draw(hbmBlueIndigo, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				else
					love.graphics.draw(hbmIndigo, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				end
			elseif (DrawTenth == 1 and (c == (9 + key - stringOffset) or c == (9 + key - stringOffset + 12) or c == (9 + key - stringOffset - 12))) then
				if (DrawMajMin == 1) then
					love.graphics.draw(hbmIndigo, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				else
					love.graphics.draw(hbmIndigoViolet, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				end
			elseif (DrawEleventh == 1 and (c == (10 + key - stringOffset) or c == (10 + key - stringOffset + 12) or c == (10 + key - stringOffset - 12))) then
				if (DrawMajMin == 1) then
					love.graphics.draw(hbmIndigoViolet, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				else
					love.graphics.draw(hbmViolet, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				end
			elseif (DrawTwelth == 1 and (c == (11 + key - stringOffset) or c == (11 + key - stringOffset + 12) or c == (11 + key - stringOffset - 12))) then
				if (DrawMajMin == 1) then
					love.graphics.draw(hbmViolet, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				else
					love.graphics.draw(hbmVioletRed, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				end
			else
				love.graphics.draw(hbmGray, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
			end
			
			
			if (stringOffset >= 0) then -- only draw these on active strings
			-- draw root marker, but not under tonic due to transparency
				if (root ~= key and (c == (root - stringOffset) or c == (root - stringOffset + 12) or c == (root - stringOffset - 12))) then
					love.graphics.draw(hbmRoot, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				end
	
			--	draw tonic, instead of root marker if both are equal
				if ((c == (key - stringOffset) or c == (key - stringOffset + 12) or c == (key - stringOffset - 12))) then
					love.graphics.draw(hbmTonic, c*BUTTONSIZE, i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
				end
			end
			
		end -- HORIZONTAL LOOP (0 to 12 notes, c)
		
		--Draw the transparent note text overlays 2 octaves each string
		if (stringOffset >= 0) then
			love.graphics.draw(hbmString		,-(BUTTONSIZE*stringOffset), i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
			love.graphics.draw(hbmString		,-(BUTTONSIZE*stringOffset)+(BUTTONSIZE*12), i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
		end
		
		--Draw the per string tuning controls (I use math for readability even with no variables sometimes)
		love.graphics.draw(hbmLeft		,(BUTTONSIZE*13), i*BUTTONSIZE, 0, IMAGESCALE, IMAGESCALE)
		love.graphics.draw(hbmRight		,(BUTTONSIZE*13), (i*BUTTONSIZE)+BUTTONSIZE/3, 0, IMAGESCALE, IMAGESCALE)
		love.graphics.draw(hbmOff		,(BUTTONSIZE*13), (i*BUTTONSIZE)+(BUTTONSIZE/3)*2, 0, IMAGESCALE, IMAGESCALE)		
		
	end -- VERTICAL LOOP (0 to 5 strings, i)
	elseif (DialogWindow == 1) then
		love.graphics.rectangle("fill", 0,0, BUTTONSIZE*13,BUTTONSIZE*6)
		love.graphics.setColor(.1, .1, .1)
		love.graphics.setFont(font)
		love.graphics.printf( "Rainbow Chord Board by Photonic2790@github.com", font, 10,10, BUTTONSIZE*12.5, "center" )
		love.graphics.printf( "This is a string instrument chord board calculator application, it highlights valid notes in the key a different colour based on numerical order, the starting view is C-Major on an E Standard tuned guitar. You can use it to learn chords and scales, teach transposing or simply help write new music. The fret board can be adjusted to look like many different instruments.", font, 10,30, BUTTONSIZE*12.5, "left" )
		love.graphics.setColor(1, 1, 1)
	elseif (DialogWindow == 2) then
		love.graphics.rectangle("fill", 0,0, BUTTONSIZE*13,BUTTONSIZE*6)
		love.graphics.setColor(.1, .1, .1)
		love.graphics.setFont(font)
		love.graphics.printf( "How to use", font, 10,10, BUTTONSIZE*12.5, "center" )
		love.graphics.printf( "Click key up/down arrows to set the current key highlighted as red. Click Maj/Min to change between the two common interval step modes. The I ii iii... buttons will show the selected chord in that key. If a chord is selected the bottom row of special chord adjustment buttons work. The arrows and X along the right can adjust the tuning of a string. Click anywhere to begin.", font, 10,30, BUTTONSIZE*12.5, "left" )
		love.graphics.setColor(1, 1, 1)
	end -- if dialogwindow == 0
	
	-- the fret numbering graphic
    love.graphics.draw(hbmFrets			, 0, BUTTONSIZE*6, 0, IMAGESCALE, IMAGESCALE)
		
	--Draw the key changing buttons
	love.graphics.draw(hbmKeyLabel		, 0, BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	love.graphics.draw(hbmUp			, BUTTONSIZE/2, BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	love.graphics.draw(hbmDown			, BUTTONSIZE/2, BUTTONSIZE*7.5, 0, IMAGESCALE, IMAGESCALE)
	
	-- Draw a row of each colour to use as buttons
	love.graphics.draw(hbmRed 		    , BUTTONSIZE*1 , BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	love.graphics.draw(hbmRedOrange     , BUTTONSIZE*2 , BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	love.graphics.draw(hbmOrange 	    , BUTTONSIZE*3 , BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	if (DrawMajMin == 1) then
		love.graphics.draw(hbmOrangeYellow	, BUTTONSIZE*4 , BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	else
		love.graphics.draw(hbmYellow		, BUTTONSIZE*4 , BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	end
	if (DrawMajMin == 1) then
		love.graphics.draw(hbmYellow 		, BUTTONSIZE*5 , BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	else
		love.graphics.draw(hbmYellowGreen   , BUTTONSIZE*5 , BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	end
	love.graphics.draw(hbmGreen 	    , BUTTONSIZE*6 , BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	love.graphics.draw(hbmGreenBlue     , BUTTONSIZE*7 , BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	love.graphics.draw(hbmBlue 		    , BUTTONSIZE*8 , BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	if (DrawMajMin == 1) then
		love.graphics.draw(hbmBlueIndigo    , BUTTONSIZE*9, BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	else
		love.graphics.draw(hbmIndigo    	, BUTTONSIZE*9, BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	end
	if (DrawMajMin == 1) then
		love.graphics.draw(hbmIndigo 	    , BUTTONSIZE*10, BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	else
		love.graphics.draw(hbmIndigoViolet  , BUTTONSIZE*10, BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	end
	if (DrawMajMin == 1) then
		love.graphics.draw(hbmIndigoViolet  , BUTTONSIZE*11, BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	else
		love.graphics.draw(hbmViolet 	    , BUTTONSIZE*11, BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	end
	if (DrawMajMin == 1) then
		love.graphics.draw(hbmViolet 	    , BUTTONSIZE*12, BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	else
		love.graphics.draw(hbmVioletRed	    , BUTTONSIZE*12, BUTTONSIZE*7, 0, IMAGESCALE, IMAGESCALE)
	end
	
	-- draw the major or minor interval marker
	if (DrawMajMin == 1) then
		love.graphics.draw(hbmMajor 	    , 0, BUTTONSIZE*8, 0, IMAGESCALE, IMAGESCALE)
	else
		love.graphics.draw(hbmMinor 	    , 0, BUTTONSIZE*8, 0, IMAGESCALE, IMAGESCALE)
	end
				
	-- drawing the preset buttons image at finally at the bottom of the screen
	love.graphics.draw(hbmPresets 	    , 0, BUTTONSIZE*9, 0, IMAGESCALE, IMAGESCALE)

	-- covers any overdrawn notes text (non 4:3 aspect ratio)
	love.graphics.setColor(FGCOLOR)
	love.graphics.rectangle("fill", BUTTONSIZE*13.3,0, width,height)
	
    -- Draw the "cursor" at the mouse position.
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(RCB_cursor, love.mouse.getX(), love.mouse.getY(), 0, IMAGESCALE, IMAGESCALE)

end

