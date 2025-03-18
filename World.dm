world
	fps = 20              // Slightly lower than default (25) for stability
	icon_size = 32        // Standard icon size
	view = 7              // Reasonable view distance

	// Persistence settings
	name = "VtM Persistent World"
	/*dont forget! -> save_mode = 1*/         // Enable persistent saving

	// Backend settings
	sleep_offline = 0     // Keep the world running even with no players
	/*dont forget! ->autosave = 1 */         // Enable autosaving

	// Log startup and shutdown for tracking
	New()
		..()
		world.log << "[time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")] - World started"

	Del()
		world.log << "[time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")] - World shutdown"
		SaveAll()         // Make sure to save all data on shutdown
		..()

	// Handles auto-saving the world periodically
	proc/AutoSave()
		set background = 1

		while(1)
			sleep(36000)  // Save every hour (3600 deciseconds = 1 hour)
			SaveAll()

			// Create a backup every 6 hours
			if(world.time % (36000 * 6) < 36000)
				BackupSavefiles()

			world.log << "[time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")] - Autosave complete"
	// Save all persistent data
	proc/SaveAll()

		for(var/mob/player/P in world)
			if(P.client)  // Only save player-controlled characters
				P.Save()

		// Save world state if needed
		var/savefile/F = new("world_state.sav")
		F["timestamp"] << world.realtime
		// Add other world state variables here

	proc/BackupSavefiles()
	set background = 1 // IF causing probelms
	var/timestamp = time2text(world.realtime, "YYYY-MM-DD_hh-mm"
	var/backup_dir = "backups/[timestamp]"

    // Check if backups directory exists
    // Create backup directory
if(!fexists("backups/"))
    mkdir("backups")

mkdir("[backup_dir]")

    // Create timestamp directory
    shell("mkdir \"[backup_dir]\"")

    // Copy all savefiles to backup
    for(var/file in flist("players/"))
        if(copytext(file, length(file)-1, length(file)) == "/")  // Skip directories
                continue

        fcopy("players/[file]", "[backup_dir]/[file]")

    world.log << "Backup created at [backup_dir]"