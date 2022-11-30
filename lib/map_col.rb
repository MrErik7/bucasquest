JSON_LAYER_INDEX_COL = 2 # The predefined collision
JSON_LAYER_INDEX_ROADS = 3 # The predefined roads/bridges
JSON_LAYER_INDEX_WATER = 1 # The predefined roads/bridges
TILE_WIDTH_PIXELS = 32
TILE_HEIGHT_PIXELS = 32

$PLAYER_START_POSITION_X = 0
$PLAYER_START_POSITION_Y = 0

#################################
########### JSON file ###########
def create_array_from_file(json_layer)        
    file = File.read('src/tiles/tilemap.json')
    myJSON = JSON.parse(file)

    intRowCnt = myJSON['layers'][json_layer]["height"]
    intColCnt = myJSON['layers'][json_layer]["width"]
  #  print("RowCnt = " + intRowCnt.to_s)
    #print(", ")
   # print("ColCnt = " + intColCnt.to_s)
    #print(", ")
    #puts("ElementCnt = " + (intRowCnt * intColCnt).to_s) 

    # The 1-dimensional array containing all blocks representing obstacles
    array_1dim = myJSON["layers"][json_layer]["data"]

    # Create a new 2-dimensional array (this will represent the block matrix of the map)
    array_2dim = Array.new(intRowCnt){Array.new(intColCnt)} # Array_Obstacles_2dim[0...intRowCnt-1][0...intColCnt-1]

    # Populate the 2-dimensional array
    for intRow in 0..intRowCnt-1
        for intCol in 0..intColCnt-1
            array_2dim[intRow][intCol] = array_1dim[intRow * intRowCnt + intCol]
        end
    end

    return array_2dim

    # Print out the 2-dimensional array
=begin
    for intRow in 0..intRowCnt-1
    for intCol in 0..intColCnt-1
        print $array_Obstacles_2dim[intRow][intCol].to_s + " "
    end
    puts
    end
    puts
    puts
=end
end
########### End JSON ###########
#################################

###############################################
########### Detect hitting obstacle ###########

def check_tile_walkable(x, y, player_width, player_height, map_x, map_y)
    # Add the map offset (the map has moved) to the players location
    x+=map_x
    y+=map_y

    # Get which map-row and map-column the player is at
    startRow = (y / TILE_HEIGHT_PIXELS).round # IF SPAWN POSITION CHANGE FROM ZERO THIS NEEDS TO BE ADDED HERE
    startCol = (x / TILE_WIDTH_PIXELS).round
    endRow = ((y + player_height) / TILE_HEIGHT_PIXELS).round
    endCol = ((x + player_width) / TILE_WIDTH_PIXELS).round

    # Debug
    #puts("startrow: #{startRow}\nstartcol: #{startCol}\nendrow: #{endRow}\nendcol:#{endCol}")
    # ---

    # Loop through all tiles inside the player's rectangle to see if any is > 0
    intHitCount = 0
    for row in startRow..endRow
        for col in startCol..endCol
            intHitCount += $array_Obstacles_2dim[endRow][col]
            intHitCount += $array_Water_2dim[endRow][col]
        end
    end   

    # Loop through all the tiles to see if a road is where the obstacle is at  --> using only feet collision (so end)
    #intHitRoadCount = 0
    #for row in startRow..endRow
    #    intHitRoadCount += $array_Roads_2dim[row][endCol]
    #end    

    # Is the tile walkable?
    if intHitCount == 0  # If everything is zero = no collision = return true
        return true

    else # IF BUCAS HAS HIT SOMETHING >:
        return false
      
    end
end

######### End Detect hitting obstacle #########
###############################################

# Actual code
$array_Obstacles_2dim = Array.new(1){Array.new(1)} # Will use for Array_Obstacles_2dim[0...intRowCnt-1][0...intColCnt-1]
$array_Roads_2dim = Array.new(1){Array.new(1)} # Will use for Array_Obstacles_2dim[0...intRowCnt-1][0...intColCnt-1]
$array_Water_2dim = Array.new(1){Array.new(1)} # Will use for Array_Obstacles_2dim[0...intRowCnt-1][0...intColCnt-1]

$array_Obstacles_2dim = create_array_from_file(JSON_LAYER_INDEX_COL)
$array_Roads_2dim = create_array_from_file(JSON_LAYER_INDEX_ROADS)
$array_Water_2dim = create_array_from_file(JSON_LAYER_INDEX_WATER)