require "gosu"
require "gosu_tiled"
require_relative "lib/map_col"
require_relative "lib/player"
require_relative "lib/overlay2"

class BucasQuest < Gosu::Window
    def initialize
      # Window related
      $window_width = 960   
      $window_height = 540

      super($window_width, $window_height, false) # Define the window width and height 
      self.caption = "BucasQuest 2.0"
      #self.fullscreen = true
      #initalize_music("main or something")
      # ------
      
      # Map related
      @map = Gosu::Tiled.load_json(self, 'src/tiles/tilemap.json') # Load the tilemap (json)

      # Get the maps width and height
      file = File.read('src/tiles/tilemap.json')
      myJSON = JSON.parse(file)

      $map_width = myJSON["width"] * myJSON["tilewidth"]
      $map_height = myJSON["height"] * myJSON["tileheight"]

      # Setup map variables
      @map_x = 0
      @map_y = 0
      @map_move_offset = 100
      @map_speed = 3

      # Setup the UI
      @ingame_ui = Overlay.new
      @ingame_ui.init_ingame_ui($window_width, $window_height)

      # Just a sidenote/thought:
      # If the player is in inventory he can not move
      # NOTE: This does not equal that the game is paused - in the future, enemies will still be able to attack the player
      #------

      # Initialize the player and spawn him
      @player = Player.new 
      @player.warp(0, 0)

    end
  
    def update
      # Get players position
      player_x,player_y = @player.pos()

      if (!@ingame_ui.checkMenuOpen) # First determine if the player is eligible to walk
        # Check for user inputs to move the player  ---
        if Gosu.button_down? Gosu::KB_W

          # Check if the map should move aswell
          if (player_y <= @map_move_offset) # If the player is in the camera move zone (Y)
            @map_y -= @map_speed
            @player.move_down(@map_x, @map_y, false)
          end

          # Move the player
          @player.move_up(@map_x, @map_y, true)
        end

        if Gosu.button_down? Gosu::KB_A        
          # Check if the map should move aswell
          if (player_x <= @map_move_offset) # If the player is in the camera move zone (X)
            @map_x -= @map_speed
            @player.move_right(@map_x, @map_y, false)
          end

          # Move the player
          @player.move_left(@map_x, @map_y, true)
        end

        if Gosu.button_down? Gosu::KB_S
          # Check if the map should move aswell
          if (player_y >= $window_height-@map_move_offset) # If the player is in the camera move zone (Y)
            @map_y += @map_speed
            @player.move_up(@map_x, @map_y, false)
          end

          # Move the player
          @player.move_down(@map_x, @map_y, true)
          
        end

        if Gosu.button_down? Gosu::KB_D
          # Check if the map should move aswell
          if (player_x >= $window_width-@map_move_offset) # If the player is in the camera move zone (X)
            @map_x += @map_speed
            @player.move_left(@map_x, @map_y, false)
          end

          # Move the player
          @player.move_right(@map_x, @map_y, true)
        end
        # ---
      end
    end
  
    def draw
      @map.draw(@map_x, @map_y)
      @player.draw
      @ingame_ui.draw(@player.get_inventory(), self.mouse_x, self.mouse_y)

    end

    def button_up(id)
       # Check for keys released - to stop the walking animation
       if id == Gosu::KB_W
        @player.set_animation_frame("up")
      end

      if id == Gosu::KB_A
        @player.set_animation_frame("left")
      end

      if id == Gosu::KB_S
        @player.set_animation_frame("down")
      end

      if id == Gosu::KB_D
        @player.set_animation_frame("right")
      end
    end

    def button_down(id)
      if (id == Gosu::MsLeft) # If the left mouse button is clicked
        @ingame_ui.checkUIcol(@player.get_inventory(), self.mouse_x, self.mouse_y) # Check if any of the things on the ui has been pressed
        #puts("mouse btn down")

      end

      if (id == Gosu::MsRight)
        @player.get_inventory.addToInventory("gold_purse")
        puts("right mouse button down")
      end


    end

    def initialize_muisc(type) 
      # Initalize the theme song
      @music = Gosu::Song.new(self, 'src/audio/main_track.wav')
      @music.volume = 0.575 
      @music.play(true)
    end
end

BucasQuest.new.show