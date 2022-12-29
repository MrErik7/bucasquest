require "gosu" 

class Overlay

    def init_ingame_ui(window_width, window_height) # The ui displayed during the game
        # Setup fonts
        @title_font_size = 32
        @title_font = Gosu::Font.new(@title_font_size, name: "Nimbus Doggo L")

        # Initialize the UI background
        @bg = Gosu::Image.new("./src/ui/bg.png")
        @bg_x = 10
        @bg_y_offset = 40
        @bg_y = window_height-@bg_y_offset

        # UI icons ---
        # Initialize the inventory icon
		@inv_icon = Gosu::Image.new("./src/ui/icons/inv.png")
        @inv_icon_x = @bg.width-(@inv_icon.width) # Remove 
        @inv_icon_y = window_height-@bg_y_offset+5
        # ----

        # Inventory ---
        # Initialize the inventory background
        @inventory = Gosu::Image.new("./src/ui/inventory.png")
        @inventory_x = (window_width/2)-@inventory.width/2
        @inventory_y = (window_height/2)-@inventory.height/2-30
        @inventory_showing = false

        # Initialize the inventory placeholder
        @inventory_item_holder = Gosu::Image.new("./src/ui/inventory_item_holder.png")
        @itemholder_spacing = 40
        # ---

        # Set the moving inv variables
        @item_in_movement = false # false as default 
        @item_in_movement_id = "" # the item ID  
        @item_in_movement_lastframepos = 36 # the last known frame position (36 out of bonds perfect)
        @item_in_movement_image = 0 # No image as default

        # Hotbar variables
        @hotbar_x = @inventory_x+@inventory.width/1.7
        @hotbar_y = @inventory_y

        # All the items in the inventory
        # Economy ---
        @gold_purse1 = Gosu::Image.new("./src/ui/items/gold_purse1.png")
        # ---      

    end

    def checkUIcol(player_inventory, mouse_x, mouse_y)        
        # Check if the inventory is supposed to show
        if (mouse_x > @inv_icon_x && mouse_x < @inv_icon_x+@inv_icon.width) # Check within the X span of the inv icon
            if (mouse_y > @inv_icon_y && mouse_y < @inv_icon_y+@inv_icon.height) # Check within the Y span of the inv icon
                puts("col with inv icon!")
                @inventory_showing = !@inventory_showing
            end
        end

        # Check if an item should be moved
        if (!@item_in_movement)
            @item_in_movement = check_item_movement(player_inventory, mouse_x, mouse_y)        
        else
            if (mouse_x > @inventory_x && mouse_x < @inventory_x+@inventory.width)
                if (mouse_y > @inventory_y && mouse_y < @inventory_y+@inventory.height)
                    
                    # Get and set the item into the new frame --> the new location for the item that has been moved
                    frame_row, frame_col = check_which_item_frame(player_inventory, mouse_x, mouse_y)

                    if (frame_col == 8) # Hotbar
                        player_inventory.set_item_in_hotbar_array(frame_row, @item_in_movement_id)
                        player_inventory.set_item_equipped(player_inventory.get_item_equipped_index)
                    else
                        player_inventory.set_item_in_2darray(frame_row, frame_col, @item_in_movement_id)
                    end

                    # Stop the movement of the item
                    @item_in_movement = false
                    @item_in_movement_id = ""
                    @item_in_movement_image = 0
                    @item_in_movement_lastframepos = 36
                end
            end
        end
    end

    def checkMenuOpen()
        # If you add a menu here - you must say something like: If any? of these variables bla bla are true return true
        return @inventory_showing
    end

    def getItemImage(item)
        case item
            when "gold_purse"
                return @gold_purse1
            when 0
                return 0
        end
    end

    # This method staticlly diplays all the items on the inv. grid
    def display_inventory_items(player_inventory)
        # Loop through the inventory array and display the inventory grid
        for row in 0..player_inventory.load_2darray.length-1
            for col in 0..player_inventory.load_2darray[row].length-1
                # Draw the inventory frame
                pos_x = @inventory_x+col*@itemholder_spacing+@itemholder_spacing
                pos_y = @inventory_y+row*@itemholder_spacing+@itemholder_spacing
                @inventory_item_holder.draw(pos_x, pos_y)
                                
                # Get item (number) in the hash (0-31) (32 inv slots)
                item_hash_pos = row*player_inventory.load_2darray[row].length+col

                # Get the item position
                item_x, item_y = player_inventory.get_position(item_hash_pos)

                # If the item doesnt have a position --> generate one
                if (item_x == 0 && item_y == 0)
                    item_x, item_y = pos_x+@gold_purse1.width, pos_y+@gold_purse1.height
                    player_inventory.update_position(item_hash_pos, item_x, item_y) # Then update the position in the stored hash

                end

                # Get the item image
                item = player_inventory.load_2darray[row][col]
                item_image = getItemImage(item)

                # Draw the item
                if (item != 0 && item_hash_pos != @item_in_movement_lastframepos)
                    item_image.draw(item_x, item_y)
                end

            end
        end
    end

    # The purpose of this function is to check which frame to put the item down after movement
    def check_which_item_frame(player_inventory, x, y)
        # First check if its being dropped on the inv sec.
        for row in 0..player_inventory.load_2darray.length-1
            for col in 0..player_inventory.load_2darray[row].length-1
                # Get the inventory frame position
                start_pos_x = @inventory_x+col*@itemholder_spacing+@itemholder_spacing
                start_pos_y = @inventory_y+row*@itemholder_spacing+@itemholder_spacing
                
                end_pos_x = start_pos_x+@inventory_item_holder.width
                end_pos_y = start_pos_y+@inventory_item_holder.height

                # Check if the given x and y are in any of these
                if (x > start_pos_x && x < end_pos_x)

                    if (y > start_pos_y && y < end_pos_y)
                        # Return row and col
                        return row, col
                    end
                end
            end
        end  
        
        # Then check the hotbar
        for i in 0..player_inventory.load_hotbar_array.length-1
            # Get the start and end pos of the inv holder
            start_pos_x = @hotbar_x
            start_pos_y = @hotbar_y+i*@itemholder_spacing+@itemholder_spacing

            end_pos_x = start_pos_x+@inventory_item_holder.width
            end_pos_y = start_pos_y+@inventory_item_holder.height

            # Check if the given x and y are in any of these
            if (x > start_pos_x && x < end_pos_x)

                if (y > start_pos_y && y < end_pos_y)
                    # Return row and col
                    return i, 8 # Column 8 is for the hotbar, i will check this in the ui col method
                end
            end

        end

        # If the fucntion does not return anything --> return the best available empty frame
        for row in 0..player_inventory.load_2darray.length-1
            for col in 0..player_inventory.load_2darray[row].length-1
                if (player_inventory.load_2darray[row][col] == 0)
                    return row, col
                end
            end
        end

        

    end

    # This method kickstarts the movement - runs when the user press the item - see which item should move
    def check_item_movement(player_inventory, mouse_x, mouse_y)
        # I cracked it, this can only be run once --> before the object is moving 
        # But it will be checking all the time if an object is supposed to be moving

        # First check so that the click occured in the inventoryy
        if (mouse_x > @inventory_x && mouse_x < @inventory_x+@inventory.width)
            if (mouse_y > @inventory_y && mouse_y < @inventory_y+@inventory.height)
                # Check the rows in the inventory
                for row in 0..player_inventory.load_2darray.length-1
                    for col in 0..player_inventory.load_2darray[row].length-1
                        item = player_inventory.load_2darray[row][col]

                        if (item != 0)
                            item_image = getItemImage(item)
                            start_x = @inventory_x+col*@itemholder_spacing+@itemholder_spacing
                            start_y = @inventory_y+row*@itemholder_spacing+@itemholder_spacing
                                
                            end_x = start_x+@inventory_item_holder.width # The item frame X position
                            end_y = start_y+@inventory_item_holder.height # The item frame Y position
                            if (mouse_x > start_x && mouse_x < end_x)
                                if (mouse_y > start_y && mouse_y < end_y)                            
                                    # Set the new variables
                                    @item_in_movement_id = item
                                    @item_in_movement_image = item_image
                                    @item_in_movement_lastframepos = row*player_inventory.load_2darray[row].length+col

                                    # Clear the old spot
                                    player_inventory.remove_item_in_2darray(row, col)

                                    # Return true - item is now moving
                                    return true
                                end
                            end
                        end

                    end
                end

                # Then check the hotbar
                for i in 0..player_inventory.load_hotbar_array.length-1
                    item = player_inventory.load_hotbar_array[i]

                    if (item != 0)
                        item_image = getItemImage(item)
                        start_x = @hotbar_x
                        start_y = @hotbar_y+i*@itemholder_spacing+@itemholder_spacing
            
                        end_x = start_x+@inventory_item_holder.width
                        end_y = start_y+@inventory_item_holder.height
            
                        if (mouse_x > start_x && mouse_x < end_x)
                            if (mouse_y > start_y && mouse_y < end_y)   

                                # Set the new variables
                                @item_in_movement_id = item
                                @item_in_movement_image = item_image
                                @item_in_movement_lastframepos = row*player_inventory.load_2darray[row].length+col

                                # Clear the old spot
                                player_inventory.remove_item_in_hotbar_array(i)

                                # Unequip the item (if equipped)
                                player_inventory.set_item_equipped(player_inventory.get_item_equipped_index)

                                # Return true - item is now moving
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end

    # This method staticlly diplays all the items on the hotbar grid
    def display_hotbar_items(player_inventory)
        # loop through all the items in the hotbar array and the display them
        for i in 0..player_inventory.load_hotbar_array.length-1
            # Draw the inventory frame
            pos_x = @hotbar_x
            pos_y = @hotbar_y+i*@itemholder_spacing+@itemholder_spacing
            @inventory_item_holder.draw(pos_x, pos_y)
                            
            # Get item (number) in the hash (0-35) (36 inv slots)
            item_hash_pos = 32+i

            # Get the item position
            item_x, item_y = player_inventory.get_position(item_hash_pos)

            # If the item doesnt have a position --> generate one
            if (item_x == 0 && item_y == 0)
                item_x, item_y = pos_x+@gold_purse1.width, pos_y+@gold_purse1.height
                player_inventory.update_position(item_hash_pos, item_x, item_y) # Then update the position in the stored hash

            end

            # Get the item image
            item = player_inventory.load_hotbar_array[i]
            item_image = getItemImage(item)

            # Draw the item
            if (item != 0 && item_hash_pos != @item_in_movement_lastframepos)
                item_image.draw(item_x, item_y)
            end

        end

    end

    # This method displays the equipped item
    def display_equipped_item(player)
        # Set the new x and y
        player_x, player_y = player.pos()
        x = player_x+player.get_width/2
        y = player_y+player.get_height/2
        player.get_inventory.set_coordinates_item_equipped(x, y)
  
        # Get the item image
        item = player.get_inventory.get_item_equipped
        item_image = getItemImage(item)

        # Draw it at its location
        if (item != 0)
            x,y = player.get_inventory.get_coordinates_item_equipped
            item_image.draw(x,y)
        end

    end




    def draw(player, mouse_x, mouse_y) # Draw the ui (later implement that th is function takes an argument so it knows which UI to draw but for now its fine)
        @bg.draw(@bg_x, @bg_y)
        @inv_icon.draw(@inv_icon_x, @inv_icon_y)


        # First check if it exists an item to be equipped and that the player isnt walking up
        if (player.get_inventory.get_item_equipped != 0 && !player.check_if_player_walks_up())
            display_equipped_item(player)
        end

        # Check wether the inventory things should be displayed or not
        if (@inventory_showing)
            @inventory.draw(@inventory_x, @inventory_y)
            @title_font.draw("Inventory", @inventory_x+(@inventory.width/2)-@title_font_size*1.5, @inventory_y, 10, 1, 1, Gosu::Color::BLACK)
            display_inventory_items(player.get_inventory)
            display_hotbar_items(player.get_inventory)

            if (@item_in_movement)
                @item_in_movement_image.draw(mouse_x, mouse_y)
            end    
        end

        

    end
end