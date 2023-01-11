require "gosu"


class NPC

    def __init__(health, speed, intent, type)
        @health = health
        @speed = speed
        @intent = intent # Hostile, neutral, friendly

        @type = type # What type of NPC that should spawn

        # Animation ---
        case @type

        when "old_man"
            @npc_sheet_idle = Gosu::Image.new("src/npc/1Old_man/Old_man_idle.png")
            @npc = Gosu::Image.new("src/npc/1Old_man/Old_man_idle.png")
            @player_sheet_right = Gosu::Image.new("ssrc/npc/1Old_man/Old_man_idle.png")
            @player_sheet_left = Gosu::Image.new("src/npc/1Old_man/Old_man_idle.png")
    

        # The more npcs you add --> the more when stuff needs to be added here
        end

  
        @offset_animation_front= 10+@width_front
        @offset_animation_side = 10+@width_side
        
        @animation_span = Array(0..2)
        @last_time_frame_switch = Process.clock_gettime(Process::CLOCK_MONOTONIC) # Reset the timer used to check the delay between animations
        @moving = false
        @direction_changed = false
        @current_frame = 0
        @animation_time = 0.4 # Animation delay in SECONDS
        @player = @player_sheet_down.subimage 0, 0, @width, @height # Set the start image 
        @player_walking_up = false
        @up_key_released = true
        @current_direction = "none"
  
    end

    def animation_walk(animation_sheet, offset)
        # Check which frame to start from
        if (!@moving || @direction_changed) # If the player isnt moving or has changed direction --> assign him to the first frame in his list 
          @current_frame = 0
          @direction_changed = false
        end
    
    
        # Check if its time to switch frame
        if (Process.clock_gettime(Process::CLOCK_MONOTONIC) - @last_time_frame_switch >= @animation_time)
    
          if (@current_frame == (@animation_span[-1].to_i + 1)) # Check if the last frame equals the last number in the animation span
            @current_frame = @animation_span[0].to_i # Then reset the animation
          end
  
          # Apply the animation
          @player = animation_sheet.subimage(@current_frame*offset, 0, @width, @height) # Switch the player frame to the new frame - using the predefined offset multiplied by the current frame
          
          # Keeping track if the player is in motion or not
          @moving = true
    
          # Add to the frame
          @current_frame+=1
    
          # Reset the timer
          @last_time_frame_switch = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end
      end
    



    def stand_idle()


    end


    def patrol_area()


    end


    def attack_player()


    end

    def protect_player()


    end

    def draw()
        


    end


