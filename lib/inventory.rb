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
        (0..($introw*$intcol)+$intcol-1).each { |i| @hash_positions[i] = "0, 0"}

        # Create the equipment slots
        @item1_equipped = 0
        @item2_equipped = 0

        # Create the hotbar
        @array_hotbar = [] # It should have 4 slots
        
        # Fill the array (with zeros since its empty)
        for x in 0..3
            @array_hotbar.push("bread")
        end
        # Items equipped
        @item1_equipped = 0
        @item1_equipped_index = 0 # To keep track of which place in the array the item is equipped has
        @item1_equipped_x = 0
        @item1_equipped_y = 0

        # All the items in the inventory
        # Economy ---
        @gold_purse1 = Gosu::Image.new("./src/ui/items/gold_purse1.png")
        @bread1 = Gosu::Image.new("./src/ui/items/bread1.png")
        # ---      

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

    # All hotbar related
    def load_hotbar_array()
        return @array_hotbar
    end

    def get_item_from_hotbar_array(pos)
        return @array_hotbar[pos]
    end

    def set_item_in_hotbar_array(pos, itemid)
        @array_hotbar[pos] = itemid
    end

    def remove_item_in_hotbar_array(pos)
        @array_hotbar[pos] = 0
    end

    def set_item_equipped(num)
        @item1_equipped_index = num
        @item1_equipped = @array_hotbar[num]
    end
    
    def get_item_equipped()
        return @item1_equipped
    end

    def get_item_equipped_index()
        return @item1_equipped_index
    end

    def set_coordinates_item_equipped(x, y)
        @item1_equipped_x = x
        @item1_equipped_y = y
    end

    def get_coordinates_item_equipped()
        return @item1_equipped_x, @item1_equipped_y
    end

    def getItemImage(item)
        case item
            when "gold_purse"
                return @gold_purse1

            when "bread"
                return @bread1

            when 0
                return 0
        end
    end
end