require "gosu" 

class Overlay

    def init_ingame_ui(window_width, window_height) # The ui displayed during the game
        # Setup fonts
        @title_font_size = 32
        @title_font = Gosu::Font.new(@title_font_size, name: "Nimbus Doggo L")

        # Variables ---
        @Lmouse_clicked = true # Will be toggled false when the inventory is opened

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

        # For moving items ---
        @item_in_movement = ""
        @item_in_movement_arrayPos = -1
        @inventory_item_moving = false

        # Initialize the inventory placeholder
        @inventory_item_holder = Gosu::Image.new("./src/ui/inventory_item_holder.png")
        @itemholder_spacing = 40
        # ---

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

        
    end



    def checkMenuOpen()
        # If you add a menu here - you must say something like: If any? of these variables bla bla are true return true
        return @inventory_showing
    end

    def display_inventory_items(player_inventory)
        inv_frame_tracker = 0
        # Loop through the inventory array and display the inventory
        for row in 0..player_inventory.load_2darray.length-1
            for col in 0..player_inventory.load_2darray[row].length-1
                # Draw the inventory frame
                pos_x = @inventory_x+col*@itemholder_spacing+@itemholder_spacing
                pos_y = @inventory_y+row*@itemholder_spacing+@itemholder_spacing
                @inventory_item_holder.draw(pos_x, pos_y)
                                
                # Get the item on that slot
                item = player_inventory.load_2darray[row][col]

                # Check if thats an item that has a respective image
                if (item != 0 && @item_in_movement_arrayPos != (row*player_inventory.load_2darray[row].length+col)
                    item_image = getItemImage(item)
                    x,y = player_inventory.get_position(inv_frame_tracker)

                    if (x == 0 && y == 0) # Check if its the first time being displayed --> assign it coordinates
                        player_inventory.update_position(inv_frame_tracker, pos_x+@gold_purse1.width, pos_y+@gold_purse1.height) # Then update the position in the stored hash
                        x,y = player_inventory.get_position(inv_frame_tracker)
                    end
    
                    item_image.draw(x, y) # Draw it 
                end
            

                # Updt the inv frame tracker
                inv_frame_tracker+=1
            end
                
        end

    end

    def getItemImage(item)
        case item
            when "gold_purse"
                return @gold_purse1
            when 0
                return 0
        end
    end

    def check_move_inventory_item(player_inventory, mouse_x, mouse_y)
        if (mouse_x > @inventory_x+@itemholder_spacing && mouse_x < @inventory_x+@itemholder_spacing+@inventory_item_holder.width*player_inventory.load_2darray[0].length) # Check within the X span of the inv icon
            if (mouse_y > @inventory_y+@itemholder_spacing && mouse_y < @inventory_y+@itemholder_spacing+@inventory_item_holder.height*player_inventory.load_2darray.length) # Check within the Y span of the inv icon

                # THen need to loop through the inventory to check what kind of item is there
                for row in 0..player_inventory.load_2darray.length-1
                    for col in 0..player_inventory.load_2darray[row].length-1
                        start_pos_x = @inventory_x+col*@itemholder_spacing+@itemholder_spacing # The item frame X position
                        start_pos_y = @inventory_y+row*@itemholder_spacing+@itemholder_spacing # The item frame Y position
        
                        end_pos_x = @inventory_x+col*@itemholder_spacing+@itemholder_spacing+@inventory_item_holder.width # The item frame X position
                        end_pos_y = @inventory_y+row*@itemholder_spacing+@itemholder_spacing+@inventory_item_holder.height # The item frame Y position

                        if (mouse_x > start_pos_x && mouse_x < end_pos_x)
                            if (mouse_y > start_pos_y && mouse_y < end_pos_y)
                                # Get the item on that slot
                                item = player_inventory.load_2darray[row][col]

                                # Check if it is not an empty frame
                                if (item != 0)
                                    # Assign the proper variables
                                    @item_in_movement = item
                                    @item_in_movement_arrayPos = row*player_inventory.load_2darray[row].length+col
                                    @inventory_item_moving = true
                                end
                                
                            end
                        end
                    end
                end
            end
        end
    end


    def move_inventory_item(item, array_pos, player_inventory, mouse_x, mouse_y)
        # Get the image for that item
        item_image = getItemImage(item)

        # Update the coordinates for that item
        player_inventory.update_position(array_pos, mouse_x, mouse_y)

        # Draw it
        item_image.draw(mouse_x, mouse_y)
    end



    def draw(player_inventory, mouse_x, mouse_y) # Draw the ui (later implement that th is function takes an argument so it knows which UI to draw but for now its fine)
        @bg.draw(@bg_x, @bg_y)
        @inv_icon.draw(@inv_icon_x, @inv_icon_y)

        # Check wether the inventory things should be displayed or not
        if (@inventory_showing)
            @inventory.draw(@inventory_x, @inventory_y)
            @title_font.draw("Inventory", @inventory_x+(@inventory.width/2)-@title_font_size*1.5, @inventory_y, 10, 1, 1, Gosu::Color::BLACK)
            display_inventory_items(player_inventory)

            if (@inventory_item_moving)
                move_inventory_item(@item_in_movement, @item_in_movement_arrayPos, player_inventory, mouse_x, mouse_y)
            end

            # Check col with the inv
           # check_move_inventory_item(player_inventory, mouse_x, mouse_y)

        end

    end




end