class Inventory
    $introw = 8
    $intcol = 4

    def __init__()
        # Create the 1D array
        @array_inventory_1d = []

        # Fill the array (with zeros since its empty)
        list_size = $introw*$intcol
        for x in 0..list_size-1
            @array_inventory_1d.push(0)

        end

        # Create the 2D array
        @array_inventory_2d = Array.new($introw){Array.new($intcol)} # Array_Obstacles_2dim[0...intRowCnt-1][0...intColCnt-1]
        
        # Fill the 2-dimensional array
        for intRow in 0..$introw-1
            for intCol in 0..$intcol-1
                @array_inventory_2d[intRow][intCol] = @array_inventory_1d[intRow * $intcol]
            end
        end

        # Create the position hash (to hold all the items x and y visually)
        @hash_positions = {} 
        (0..$introw*$intcol-1).each { |i| @hash_positions[i] = "0, 0"}

        # Create the equipment slots
        @item1_equipped = 0
        @item2_equipped = 0

        # Create the hotbar
        @array_hotbar = Array.new(5) # It should have 5 slots

        # Hotbar position hash
        @hash_positions = {} 
        (0..5).each { |i| @hash_positions[i] = "0, 0"}

    end

    def addToInventory(item)
        # Loop through the inventory to find an empty space
        catch :find_a_space do
            for intRow in 0..$introw-1
                for intCol in 0..$intcol-1
                    if (@array_inventory_2d[intRow][intCol] == 0)
                        @array_inventory_2d[intRow][intCol] = item
                        throw :find_a_space # Exit through both of the for loops since a space was found
                        
                    end
                end
            end
        end
    end

    def load_2darray()
        return @array_inventory_2d
    end

    def update_position(n, x, y)
        @hash_positions[n] = "#{x}, #{y}"
    end

    def get_position(n)
        x, y = @hash_positions[n].split(", ")
        return x.to_i, y.to_i
    end

    def get_item_from_2darray(row, col)
        return @array_inventory_2d[row*$intRow+col]
    end

    def set_item_in_2darray(row, col, itemid)
        @array_inventory_2d[row][col] = itemid
    end

    def remove_item_in_2darray(row, col)
        @array_inventory_2d[row][col] = 0
    end

    def getHotbarArray()
        return @array_hotbar
    end

end