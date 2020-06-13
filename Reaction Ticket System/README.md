# Yet-Another-Reaction-Ticket-System
***Reaction Ticket Systems for YAGPDB seem to be quite popular so I decided to make my own as I didn't like the fact that other systems used so many ccs. Keep in mind these Custom Commands are NOT stand-alone, you either add all or none!***

# Important Note before skimming this README:
**In order for the automatic deletion of tickets to work, you will have to open a ticket and type ANY message in that ticket, at first you will get an error saying "error calling scheduleUniqueCC: did not find the specified CC" all you need to do to fix this is type ANY MESSAGE in the FIRST TICKET YOU OPENED, once you typed a message, that error will never appear again :)**

# Information on this Custom Ticket System:

**The benefits this system has over the standard ticket system:**

-Automatically deletes tickets after a certain amount of time being inactive (the time of inactivity can be configured, standard is 3h inactivity)

-Only one ticket per person can be open at a time

-There's a configurable per-user cooldown for opening tickets to prevent people from opening multiple tickets in a short amount of time (the cooldown can also be configured, or disabled if not wanted, standard cooldown is 30 minutes)

-you can have a custom prefix that is dedicated to the commands add/adduser, remove/removeuser, rename and resend (the standard prefix is "-")

-the system works completely with reactions, except for the command that require arguments to use (rename, adduser, removeuser and the resend command)

-you can have logs/a transcript of the ticket sent to you in DM without having to close the ticket

-Useful resend command that automatically resends and deletes the ticket opening message in case the ticket gets full

**Requirements/Recommendations to make this system work properly:**

disable all standard ticket commands under control panel > core > command settings > command ovverrides

**Benefits this has over other reaction ticket systems:**

-uses only 2 CCs and therefore takes up little space and takes less time to add

-fits a lot of functionality into only 2 CCs (+ The ticket opening message)

If you find any bugs, feel free to DM me on Discord, my Username is ***MeinNameHalt#2569***
