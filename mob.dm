mob/player
    step_size = 3
    
    // Basic attributes for persistence
    var
        saved_x         // Last x position for persistence
        saved_y         // Last y position for persistence
        saved_z         // Last z position for persistence
        last_login      // When player last logged in
        creation_date   // When character was created
    
    // Called when player logs in
    Login()
        ..()
        last_login = world.realtime
        
        // Try to load saved data
        if(!Load())
            // If no saved data, this is a new character
            creation_date = world.realtime
            src << "<b>Welcome to your new life in the World of Darkness.</b>"
        else
            // Returning player
            src << "<b>Welcome back. You were last here [time2text(last_login, "YYYY-MM-DD hh:mm:ss")].</b>"
        
        // Start the autosave process if it's not already running
        if(!global.autosave_running)
            global.autosave_running = 1
            spawn world.AutoSave()
    
    // Called when player logs out
    Logout()
        Save()  // Save player data on logout
        ..()
    
// Save character data
proc/Save()
    // Create directory if it doesn't exist
    if(!fexists())
        var/success = mkdir("players")
            if(!success)
                src << "<span class='warning'>ERROR: Could not create save directory!</span>"
                return 0
                
        // Save current position
        saved_x = x
        saved_y = y
        saved_z = z
        
        // Try/catch style error handling
        try
            // Create a savefile for this player
            var/savefile/F = new("players/[ckey].sav")
            
            // Write the player data
            F["saved_x"] << saved_x
            F["saved_y"] << saved_y
            F["saved_z"] << saved_z
            F["last_login"] << last_login
            F["creation_date"] << creation_date
            
            // Add a version number for future compatibility
            F["version"] << 1
            
            // Add other character attributes to save here
            
            return 1
        catch(var/exception/e)
            // Log the error and inform the player
            world.log << "Save error for [ckey]: [e]"
            src << "<span class='warning'>Error saving character: [e]</span>"
            return 0
    
    // Load character data
    proc/Load()
        // Check if savefile exists
        if(!fexists("players/[ckey].sav"))
            return 0
            
        try
            // Open the savefile
            var/savefile/F = new("players/[ckey].sav")
            
            // Check version for compatibility
            var/version
            F["version"] >> version
            
            // Handle different versions if needed
            if(!version || version < 1)
                src << "<span class='warning'>Your character data is from an older version and may not load correctly.</span>"
            
            // Read the player data
            F["saved_x"] >> saved_x
            F["saved_y"] >> saved_y
            F["saved_z"] >> saved_z
            F["last_login"] >> last_login
            F["creation_date"] >> creation_date
            
            // Restore position if valid
            if(saved_x && saved_y && saved_z)
                var/turf/T = locate(saved_x, saved_y, saved_z)
                if(T)
                    loc = T
                else
                    // Handle invalid location
                    src << "<span class='warning'>Your previous location is no longer accessible.</span>"
                    loc = locate(1, 1, 1)  // Default starting location
            
            return 1
        catch(var/exception/e)
            world.log << "Load error for [ckey]: [e]"
            src << "<span class='warning'>Error loading character: [e]</span>"
            return 0