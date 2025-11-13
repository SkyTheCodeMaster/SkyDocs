--- 2D Graphics Library
-- If any method asks for a colour, it will accept blit colours (`0123456789abcdef`), or `colours.black` colours.
-- @module[kind=misc] graphics

local expect = require("cc.expect").expect
local field = require("cc.expect").field

local function convert_colour(col)
  expect(col, "number", "string")
  if type(col) == "number" then
    return colours.toBlit(col)
  elseif type(col) == "string" then
    if #col == 1 then
      return col
    else
      error("Invalid argument: string too long")
    end
  end
end

local graphics = {}

-- type definitions
--- An X/Y coordinate for components.
--- @type Point table<number, number>
local Point = {}

--- A width and height for components.
--- @type Size table<number, number>
local Size = {}

--- @type Points table<Point>
local Points = {}

local random = math.random
local function generate_id()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

--- Object superclass
--- @type table Object
--- The field "children" is a list of other Object subclasses.
--- The field "listeners" is a list of string:array pairs, where the string is the event name, and the array is a list of functions to call.
---   The only arguments to the function is (object, event) where event is a numerical table of all of the event properties.
--- The field "disabled" is a boolean for whether or not listeners should be called.
--- The field "id" is the objects unique identifier, for use with the children attribute.
--- The field "parent" is another Object which is the parent of this. It is used for offsetting the origin in draw calls.
local Object = {}

function Object:new()
  self.children = {}
  self.listeners = {}
  self.id = generate_id()
  self.parent = nil
end

--- Test a hit point on the object, and its children.
-- In a normal Object, it just calls the test hit on its children, and return the child or false.
-- Other objects should implement this method with something like a bounding box test.
-- @tparam Point x/y coordinate to test.
function Object:test_hit(point)
  if #self.children == 0 then
    return false
  end

  for _,child in pairs(self.children) do
    if child:test_hit(point) then
      return child
    end
  end
  return false
end

-- find the objects ID in the children list.
function Object:_child_index(obj)
  expect(1, obj, "table")
  local object_id
  if type(obj) == "table" then
    object_id = obj.id
  elseif type(obj) == "string" then
    object_id = obj
  end

  for i,v in ipairs(self.children) do
    if v.id == object_id then
      return i
    end
  end
  return -1
end

--- Add a child to this object.
-- @tparam Object obj The child to add
function Object:append_child(obj)
  expect(1, obj, "table")
  self.children[#self.children+1] = obj
  obj.parent = self
end

function Object:remove_child(obj)
  expect(1, obj, "table")
  local idx = self:_child_index(obj)
  if idx == -1 then
    return false
  end
  table.remove(self.children, idx)
  obj.parent = nil
  return true
end

function Object:draw(win)
  expect(1, win, "table")
  for _,v in pairs(self.children) do
    v:draw(win)
  end
end

--- Recursively follows the parent origin, until we reach the top-most element. Returns the real coordinates of the relative origins.
function Object:real_origin()
  local ox, oy = self.origin[1], self.origin[2]
  if self.parent then
    local parent_x, parent_y = self.parent:real_origin()
    ox = ox + parent_x
    oy = oy + parent_y
  end
  return ox, oy
end

function Object:add_event_listener(event, listener)
  expect(1, event, "string")
  expect(2, listener, "function")

  if self.listeners[event] then
    table.insert(self.listeners[event], listener)
  else
    self.listeners[event] = {listener}
  end
end

function Object:remove_event_listener(event, listener)
  expect(1, event, "string")
  expect(2, listener, "function")

  if self.listeners[event] then
    for i,v in ipairs(self.listeners[event]) do
      if v == listener then
        table.remove(self.listeners[event], i)
      end
    end
  end
end


function Object:call_event_listeners(event)
  expect(1, event, "table")
  if self.disabled then
    return
  end
  local event_name = event[1]
  if self.listeners[event_name] then
    for _,v in ipairs(self.listeners[event_name]) do
      v(self, event)
    end
  end
end

--- An infinite loop that checks for `mouse_click`, `mouse_drag`, and `mouse_up` events, and passes them into the test_hit function.
function Object:mouse_loop(monitor)
  expect(1, monitor, "boolean", "nil")
  local filter
  if monitor then
    filter = {"mouse_click", "mouse_drag", "mouse_scroll", "mouse_up", "monitor_touch"}
  else
    filter = {"mouse_click", "mouse_drag", "mouse_scroll", "mouse_up"}
  end
  while true do
    local event = {os.pullEvent()}
    local ok = false
    for _,v in ipairs(filter) do
      if event[1] == v then
        ok = true
      end
    end

    if ok then
      local x,y = event[3],event[4]
      local result = self:test_hit({x,y})
      if result then
        result:call_event_listeners(event)
      end
    end
  end
end

-- Generic polygon object
--- @type Polygon
local Polygon = setmetatable({
  Super = Object
},{__index=Object})

--- Instantiate a new @{Polygon} object.
-- @tparam points Points a list of points that the polygon takes
-- @tparam edge_colour number The edge colour of the polygon
-- @tparam fill_colour number The fill colour of the polygon, -1 for transparent
-- @treturn Polygon the new polygon object.
function graphics.new_polygon(points, edge_colour, fill_colour)
  error("Polygons not implemented")
end

-- This is going to be expensive
--- Draw the polygon to the designated terminal object
-- @tparam table Terminal object
function Polygon:draw()
  error("Polygons not implemented")
end

--- Generic rectangle object
--- @type Rectangle
local Rectangle = setmetatable({
  Super = Object
},{__index=Object})

--- Instantiate a new @{Rectangle} object.
--  This is called through @{graphics.new}
--@tparam table Options
--@treturn Rectangle The instantiated @{Rectangle} object

-- `size`: @{Size} The width and height of the rectangle
-- `origin`: @{Point} The point where the top left of the rectangle is.
-- `border?`: number/string The colour of the border of the rectangle, defaults to white.
-- `fill?`: number/string The colour of the infill of the rectangle, defaults to the border colour.
-- `pixel?=false`: boolean Whether or not the rectangle should use the pixel characters, or full size characters.
function Rectangle.new(options)
  local rect = {
    size = options.size,
    origin = options.origin,
    border = convert_colour(options.border),
    fill = convert_colour(options.fill),
    pixel = options.pixel
  }

  Object.new(rect)
  return setmetatable(rect, {__index=Rectangle})
end

--- Edit a rectangle object; refer to @{Rectangle.new} for the options.
function Rectangle:edit(options)
  self.size = options.size or self.size
  self.origin = options.origin or self.origin
  self.border = convert_colour(options.border) or self.border
  self.fill = convert_colour(options.fill) or self.fill
  self.pixel = options.pixel or self.pixel
end

function Rectangle:_draw_chars(win)
  -- Get cursor pos to restore it to the original position
  local ox, oy = win.getCursorPos()
  local tx, ty = self:real_origin()
  -- Optimize drawing if inside and outside are the same
  local height = self.size[2]
  local width = self.size[1]
  if self.border == self.fill then
    local line = (" "):rep(width)
    local col = self.fill:rep(width)
    for y=ty,height+ty do
      win.setCursorPos(tx, y)
      win.blit(line, col, col)
    end
  else
    local line = (" "):rep(width)
    for y=ty,height+ty-1 do
      local col
      if (y == ty) or (y == height+ty-1) then
        col = self.border:rep(width)
      else
        col = self.border .. self.fill:rep(width-2) .. self.border
      end
      win.setCursorPos(tx, y)
      win.blit(line, col, col)
    end
  end

  -- Restore cursor position
  win.setCursorPos(ox, oy)
end

-- Topleft, Topmiddle, Topright, Middleleft, Middle, Middleright, Bottomleft, Bottommiddle, Bottomright
local rectangle_pixel_charset = {"\x97","\x83","\x94","\x95","\x00","\x95","\x8A","\x8F","\x85"}
local rectangle_pixel_flip = {false,false,true,false,false,true,true,true,true}

local function get_rectangle_pixel_character(position, fg, bg)
  local char = rectangle_pixel_charset[position]
  local flip = rectangle_pixel_flip[position]
  if flip then
    return char, bg, fg
  else
    return char, fg, bg
  end
end

function Rectangle:_draw_pixels(win)
  -- Get cursor pos to restore it to the original position
  local ox, oy = win.getCursorPos()
  local tx, ty = self:real_origin()
  -- Define the characters to use for the border
  -- Assemble the rectangle
  local width = self.size[1]
  local height = self.size[2]
  
  -- Build the first line
  local char, fg, bg = get_rectangle_pixel_character(1, self.border, self.fill)
  local linechar = char
  local linefg = fg
  local linebg = bg
  char, fg, bg = get_rectangle_pixel_character(2, self.border, self.fill)
  linechar = linechar .. char:rep(width-2)
  linefg = linefg .. fg:rep(width-2)
  linebg = linebg .. bg:rep(width-2)
  char, fg, bg = get_rectangle_pixel_character(3, self.border, self.fill)
  linechar = linechar .. char
  linefg = linefg .. fg
  linebg = linebg .. bg

  -- Draw the first line
  win.setCursorPos(tx,ty)
  win.blit(linechar,linefg,linebg)

  -- Assemble the second line
  char, fg, bg = get_rectangle_pixel_character(4, self.border, self.fill)
  linechar = char
  linefg = fg
  linebg = bg
  char, fg, bg = get_rectangle_pixel_character(5, self.border, self.fill)
  linechar = linechar .. char:rep(width-2)
  linefg = linefg .. fg:rep(width-2)
  linebg = linebg .. bg:rep(width-2)
  char, fg, bg = get_rectangle_pixel_character(6, self.border, self.fill)
  linechar = linechar .. char
  linefg = linefg .. fg
  linebg = linebg .. bg

  -- Draw the second line for the entire height of the rectangle
  for i=2, height-1 do
    win.setCursorPos(tx,ty+i-1)
    win.blit(linechar,linefg,linebg)
  end

  -- Assemble the third line
  char, fg, bg = get_rectangle_pixel_character(7, self.border, self.fill)
  linechar = char
  linefg = fg
  linebg = bg
  char, fg, bg = get_rectangle_pixel_character(8, self.border, self.fill)
  linechar = linechar .. char:rep(width-2)
  linefg = linefg .. fg:rep(width-2)
  linebg = linebg .. bg:rep(width-2)
  char, fg, bg = get_rectangle_pixel_character(9, self.border, self.fill)
  linechar = linechar .. char
  linefg = linefg .. fg
  linebg = linebg .. bg

  -- Draw the third line at the bottom of the rectangle
  win.setCursorPos(tx,ty+self.size[2]-1)
  win.blit(linechar,linefg,linebg)

  -- Return the cursor to its original position and return
  win.setCursorPos(ox, oy)
end

--- Test if a point falls within the bounds of the rectangle.
--- @tparam @{Point} point to test
--- @treturn @{Object} or false
function Rectangle:test_hit(point)
  local child_result = self.Super.test_hit(self, point)
  if child_result then
    return child_result
  end

  local ox, oy = self:real_origin()
  -- There was no child hit, lets check if this hits us.
  local left_bound = ox
  local right_bound = ox + self.size[1]
  local top_bound = oy
  local bottom_bound = oy + self.size[2]

  if left_bound <= point[1] and point[1] <= right_bound and
  top_bound <= point[2] and point[2] <= bottom_bound then
    return self
  end
  return false
end

--- Draw the rectangle onto the window object.
--- @tparam table the Terminal object to draw to.
function Rectangle:draw(win)
  if self.pixel then
    self:_draw_pixels(win)
  else
    self:_draw_chars(win)
  end

  self.Super.draw(self, win)
end

--- Rectangle textbox
--- @type TextBox
local TextBox = setmetatable({
  Super = Object
},{__index=Object})

--- Instantiate a new @{TextBox} object.
--@tparam table Options
-- `size`: @{Size} The width and height of the text box.
-- `origin`: @{Point} The point where the top left of the text box is.
-- `text`: string The initial text of the text box.
-- `colour`: string|number The colour of the text.
-- `background`: boolean Whether or not it renders a rectangle in the background of the text. Defaults to false.
-- `border`: string The style of border for the textbox. "full" uses full size characters, "pixel" uses the pixel characters, and "none" doesn't draw a border.
-- `border_colour`: string|number The colour of the border. This can not be set if the border is `none`.
-- `background_fill`: string|number The colour of the background.
-- `justify`: string "left", "center", "right". The justification of the text, defaults to center.
-- `alignment`: string "top", "center", "bottom". The alignment of the text, defaults to center.
-- `wordwrap`: string "none", "space", "character". The word wrap setting. If set to none, the only word wrapping will be from newline characters. If set to space, it will wrap on space characters. If set to character, it will split words to wrap.
function TextBox.new(options)
  field(options, "size", "table")
  field(options, "origin", "table")
  field(options, "text", "string")
  field(options, "colour", "string", "number")
  field(options, "background", "boolean", "nil")
  if options.background then
    field(options, "border", "string")
    field(options, "border_colour", "string", "number")
  end
  field(options, "background_fill", "string", "number")
  field(options, "justify", "string", "nil")
  field(options, "alignment", "string", "nil")
  field(options, "wordwrap", "string", "nil")

  local tb = {
    size = options.size,
    origin = options.origin,
    text = options.text,
    colour = convert_colour(options.colour),
    background = options.background or false,
    border = options.border,
    border_colour = convert_colour(options.border_colour or colours.black),
    background_fill = convert_colour(options.background_fill or colours.black),
    justify = options.justify or "center",
    alignment = options.alignment or "center",
    wordwrap = options.wordwrap or "none",
  }
  Object.new(tb)

  if tb.background then
    local border_mode = false
    if tb.border == "none" then
      tb.border_colour = tb.background_fill
    elseif tb.border == "pixel" then
      border_mode = true
    end
    tb._bg_rectangle = graphics.new("rectangle", {origin={0,0}, size=tb.size, border=tb.border_colour, fill=tb.background_fill, pixel=border_mode})
    tb._bg_rectangle.parent = tb
  end

  return setmetatable(tb, {__index=TextBox})
end

--- Split a string by it's separator.
--@tparam string inputstr String to split.
--@tparam string sep Separator to split the string by.
--@treturn table Table containing the split string.
local function split(inputstr, sep)
  expect(1,inputstr,"string")
  expect(1,sep,"string","nil")
  sep = sep or ","
  local t={}
  for str in inputstr:gmatch("([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

--- Draw the textbox
--@tparam table A window object
function TextBox:draw(win)
  local ox,oy = self:real_origin()
  local border = self.border ~= "none"
  -- First we should calculate word wrapping.
  local lines = {}
  local wrap_width,wrap_height = self.size[1],self.size[2]
  -- If we have a border, we should keep the text inside of the border.
  if border then
    wrap_width = wrap_width - 2
    wrap_height = wrap_height - 2
  end
  if self.wordwrap == "none" then
    lines = split(self.text, "\n")
  elseif self.wordwrap == "space" then
    local words = split(self.text, " ")
    local current_line = ""
    for _, word in ipairs(words) do
      if (#current_line + #word + 1) > wrap_width then
        lines[#lines+1] = current_line
        current_line = word
      else
        current_line = current_line .. " " .. word
      end
    end
    lines[#lines+1] = current_line
  else
    -- This is by character.
    for i=1, #self.text, wrap_width do
      lines[#lines+1] = self.text:sub(i,i+wrap_width-1)
    end
  end

  -- If we have a border, draw the rectangle.
  if self._bg_rectangle then
    self._bg_rectangle:draw(win)
  end
  -- Now figure out the justification and alignment and start writing text.
  local start_y
  if self.alignment == "top" then
    start_y = oy
    if border then
      start_y = start_y + 1
    end
  elseif self.alignment == "center" then
    start_y = math.floor((oy + (self.size[2]/2)) - (#lines/2))
  elseif self.alignment == "bottom" then
    start_y = oy + self.size[2] - #lines
    if border then
      start_y = start_y - 1
    end
  end

  -- Draw the text
  win.setTextColour(colours.fromBlit(self.colour))
  win.setBackgroundColour(colours.fromBlit(self.background_fill))
  for i, line in ipairs(lines) do
    if self.justify == "left" then
      local x = ox
      if border then
        x = ox + 1
      end
      win.setCursorPos(x, start_y+i-1)
      win.write(line)
    elseif self.justify == "center" then
      local x = math.floor((ox+(self.size[1]/2))-(#line/2))
      win.setCursorPos(x, start_y+i-1)
      win.write(line)
    elseif self.justify == "right" then
      local x = ox + self.size[1] - #line
      if border then
        x = x - 1
      end
      win.setCursorPos(x, start_y+i-1)
      win.write(line)
    end
  end
end

--- Test if a point falls within the bounds of the textbox.
--@tparam @{Point} point to test
--@treturn @{Object} or false
function TextBox:test_hit(point)
  local child_result = self.Super.test_hit(self, point)
  if child_result then
    return child_result
  end

  local ox, oy = self:real_origin()
  -- There was no child hit, lets check if this hits us.
  local left_bound = ox
  local right_bound = ox + self.size[1]
  local top_bound = oy
  local bottom_bound = oy + self.size[2]

  if left_bound <= point[1] and point[1] <= right_bound and
  top_bound <= point[2] and point[2] <= bottom_bound then
    return self
  end
  return false
end

--- Text input object
--- @type Input
local Input = setmetatable({
  Super = Object
},{__index=Object})

--- Instantiate a new @{Input} object.
--This is called through @{graphics.new}
--@tparam table Options
--@treturn Input The instantiated @{Input} object

-- `size`: @{Size} The width and height of the rectangle
-- `origin`: @{Point} The point where the top left of the rectangle is.
-- `colour`: number|string The colour of the text written.
-- `background`: number|string The colour of the background.
-- `border`: bool=true Whether or not a rectangle is rendered behind the text input.
-- `border_colour`: number|string=colour The colour of the border. Defaults to the text colour.
-- `border_pixel`: bool=true Whether or not the border is made of space characters or pixel characters
function Input.new(options)
  field(options, "size", "table")
  field(options, "origin", "table")
  field(options, "colour", "number", "string")
  field(options, "background", "number", "string")

  local input = {
    size = options.size,
    origin = options.origin,
    colour = convert_colour(options.colour),
    background = convert_colour(options.background),
    border = options.border,
    focus = false,
    text = "",
    _index = 0, -- Current character for the cursor
    _text_offset = 0, -- How far offset the text is, this is used for placing the cursor
  }

  if options.border then
    input.border_colour = options.border_colour or input.colour
    input.border_pixel = options.border_pixel

    input._bg_rectangle = graphics.new("rectangle", {origin={0,0}, size=input.size, border=input.border_colour, fill=input.background, pixel=input.border_pixel})
    input._bg_rectangle.parent = input
  end

  Object.new(input)
  return setmetatable(input, {__index=Input})
end

--- Add a character at the current cursor index
--- @tparam string char Character to insert.
function Input:add_char(char)
  local before = self.text:sub(0, self._index)
  local after = self.text:sub(self._index+1)
  self.text = before .. char .. after
  self._index = self._index + #char

  local input_width = not self.border and self.size[1] or self.size[1]-2
  if #self.text >= input_width then
    self._text_offset = #self.text - input_width
  end
end

--- Remove a character from the current cursor index
function Input:remove_char()
  local before = self.text:sub(0, self._index-1)
  local after = self.text:sub(self._index+1)
  self.text = before .. after

  self._text_offset = math.max(0, self._text_offset-1)
  self._index = self._index - 1
end

--- Scroll the input left or right
--@tparam number len The amount to scroll. negative number scrolls left, positive number scrolls right
function Input:scroll(len)
  local input_width = not self.border and self.size[1] or self.size[1]-2
  if (0>len) then
    self._text_offset = math.max(0, self._text_offset-len)
  else
    self._text_offset = math.min(self._text_offset+len, input_width)
  end
end

--- Draw the input.
--@tparam win table The terminal object to draw to.
--@tparam set_cursor boolean Whether or not to enable cursor blink, and position it at the correct index after drawing.
function Input:draw(win, set_cursor)
  local input_width = not self.border and self.size[1] or self.size[1]-2
  local text_window = self.text:sub(0+self._text_offset, input_width+self._text_offset)
  local ox,oy = self:real_origin()
  local cursor_x = ox + math.min(self._index, self.size[1])

  if self.border then
    self._bg_rectangle:draw(win)
    win.setCursorPos(ox+1, oy+1)
    cursor_x = cursor_x + 1
  else
    win.setCursorPos(ox, oy)
  end

  win.setTextColour(colours.fromBlit(self.colour))
  win.setBackgroundColour(colours.fromBlit(self.background))
  win.write(text_window)

  if set_cursor then
    win.setCursorPos(cursor_x, oy + (self.border and 1 or 0))
    win.setCursorBlink(true)
  else
    win.setCursorPos(1,1)
    win.setCursorBlink(false)
  end
end

--- Test if a point falls within the bounds of the input.
--@tparam @{Point} point to test
--@treturn @{Object} or false
function Input:test_hit(point)
  local child_result = self.Super.test_hit(self, point)
  if child_result then
    return child_result
  end

  local ox, oy = self:real_origin()
  -- There was no child hit, lets check if this hits us.
  local left_bound = ox
  local right_bound = ox + self.size[1]
  local top_bound = oy
  local bottom_bound = oy + self.size[2]

  if left_bound <= point[1] and point[1] <= right_bound and
  top_bound <= point[2] and point[2] <= bottom_bound then
    return self
  end
  return false
end

--- Run the event loop for an input.
--This will handle setting focus, running each callback, etc.
--@tparam boolean unfocus_on_enter Whether or not to set `focus` to false when enter is pressed.
function Input:loop(unfocus_on_enter)
  while true do
    local event = {os.pullEvent()}

    if not self.disabled then

      -- Handle mouse click, focussing on input
      if event[1] == "mouse_click" then
        local x, y = event[3], event[4]
        local hit_result = self:test_hit({x, y})
        if hit_result == self then
          self.focus = true

          -- If we have an on_focus callback, call it.
          if type(self.on_focus) == "function" then
            self:on_focus()
          end
        else
          self.focus = false
        end
      end

      -- Handle enter key
      if event[1] == "key" and event[2] == 28 and self.focus then
        if type(self.on_enter) == "function" then
          self:on_enter()
        end
        if unfocus_on_enter then
          self.focus = false
        end
      end

      -- Handle backspace key
      if event[1] == "key" and event[2] == 14 and self.focus then
        self:remove_char()

        if type(self.on_change) then
          self:on_change()
        end
      end

      -- Handle characters being added
      if event[1] == "char" and self.focus then
        local character = event[2]
        self:add_char(character)

        if type(self.on_change) then
          self:on_change()
        end
      end
    end
  end
end

--- Progress bar object
--@type progress
local Progress = setmetatable({
  Super = Object
},{__index=Object})

--- Instantiate a new @{Progress} object.
--  This is called through @{graphics.new}
--@tparam table options
--@treturn Input The instantiated @{Progress} object
--@tparam @{Size} options.size The width and height of the progress bar
--@tparam @{Point} options.origin The point where the top left of the progress bar is.
--@tparam number|string options.colour The foreground colour of the bar.
--@tparam number|string options.background The background colour of the bar.
--@tparam[opt=false] boolean options.border  Whether or not a rectangle is rendered behind the text input.
--@tparam[opt=options.colour] number|string border_colour The colour of the border. Defaults to the text colour.
--@tparam[opt=true] boolean border_pixel Whether or not the border is made of space characters or pixel characters.
--@tparam[opt=full] string mode The progress bar mode. It has 3 options.
--                   "full" uses space characters, so it has a resolution of `width`.
--                   "half" uses the half drawing character, so it has a resolution of `width*2`.
--                   "sixth" uses all the drawing characters, and the entire vertical height of the bar, filling top to bottom, left to right. It has a resolution of `width*height*6`.
--@tparam[opt=right] string direction The direction the progress bar flows.
--@tparam[opt=0] number value The percentage (from 0-1) of the progress bar that is filled.

--@changed 0.0.1 Only "full", and "right" is implemented.
---@diagnostic disable-next-line: duplicate-set-field
function Progress.new(options)
  field(options, "size", "table")
  field(options, "origin", "table")
  field(options, "colour", "number", "string")
  field(options, "background", "number", "string")
  field(options, "mode", "string", "nil")
  field(options, "value", "number", "nil")

  local progress = {
    size = options.size,
    origin = options.origin,
    colour = convert_colour(options.colour),
    background = convert_colour(options.background),
    border = options.border,
    mode = options.mode or "full",
    direction = options.direction or "right",
    value = options.value or 0
  }

  if options.border then
    progress.border_colour = options.border_colour or progress.colour
    progress.border_pixel = options.border_pixel

    progress._bg_rectangle = graphics.new("rectangle", {origin={0,0}, size=progress.size, border=progress.border_colour, fill=progress.background, pixel=progress.border_pixel})
    progress._bg_rectangle.parent = progress
  end

  Object.new(progress)
  return setmetatable(progress, {__index=Progress})
end

function Progress:_blit_line_right(width, value, mode)
  expect(1, width, "number")
  expect(2, value, "number")
  expect(3, mode, "string")

  if mode == "full" then
    local char = (" "):rep(width)
    local fg = ("f"):rep(width)
    local filled = math.floor(value*width)
    local unfilled = math.ceil((1-value)*width)
    local bg = self.colour:rep(filled) .. self.background:rep(unfilled)
    return {char,fg,bg}
  elseif mode == "half" then

  elseif mode == "sixth" then

  end
end

--- Draw the progress bar
--@tparam table win The window object to draw to.
function Progress:draw(win)
  if self._bg_rectangle then
    self._bg_rectangle:draw(win)
  end

  local ox,oy = self:real_origin()

  -- check direction
  if self.direction == "right" then
    local modifier = self.border and 1 or 0
    local top = oy + modifier
    local bottom = (oy+self.size[2]) - modifier-1
    local width = (self.size[1]) - modifier*2
    local left = (ox) + modifier

    for i=top,bottom do
      local blit = self:_blit_line_right(width, self.value, self.mode)
      win.setCursorPos(left, i)
      win.blit(blit[1], blit[2], blit[3])
    end
  end
end


local constructors = {
  rectangle = Rectangle,
  textbox = TextBox,
  input = Input,
  progress = Progress,
}

--- Create a new graphics object, with specified options.
--- @tparam string obj_type The object type to create
--- @tparam table options Options to create the object with.
--- @treturn @{Object} The resulting object
function graphics.new(obj_type, options)
  if not constructors[obj_type] then
    error("Constructor not found!")
  end
  return constructors[obj_type].new(options)
end

return graphics