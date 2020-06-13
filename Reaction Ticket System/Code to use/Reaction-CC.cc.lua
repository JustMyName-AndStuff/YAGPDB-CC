{{/*This is the "Reaction Listener" command. It is the main part of the ticket system.

 

          In order to initially set up the ticket system, you must react with ANY STANDARD EMOJI (not custom emoji) on the

          message where people can open tickets on (THIS MUST BE DONE IN THE SAME CHANNEL AND THE REACTION MUST

          BE ADDED TO THE SAME MESSAGE AS PROVIDED IN THE $openmsg VARIABLE!)

 

Trigger type: Reaction

Option to choose: Added Reactions only

 

This is the main set-up cc, in the Code for the "Opening message in new tickets" response box there are 2 more values that can be optionally changed

these values are:

-The time until tickets are closed for inactivity

-The prefix of the resend, add/adduser, remove/removeuser and rename command

 

All the variables in this particular code MUST be defined*/}}

 

{{/*CONFIGURATION VARIABLES START, THESE ARE VARIABLES THAT YOU **MUST** DEFINE*/}}

 

{{/*This is the EMOJI people react on to open a new ticket, theres currently no support for custom emoji, for now you can only use an Emoji Unicode, if you don't know how to get an emoji unicode, visit https://emojipedia.org/ and search for the emoji you want to add (you can use the emoji name, like for example "joy" or "regional_indicator_a" and you can copy the unicode)

BACKTICKS (`) ARE REQUIRED TO MAKE THIS WORK!*/}}

{{$emoji := `📩`}}

 

{{/*the CC-ID of the custom command that manages the resend, rename, adduser, removeuser commands and the inactivity of tickets (the one with the \A regex trigger)*/}}

{{$ccID := 268}}

 

{{/*The CATEGORY ID where tickets are created in (in your server)

YOU WILL STILL HAVE TO SETUP A CATEGORY TO OPEN TICKETS IN

(Tools&Utilities > Ticket System)*/}}

{{$category := 706260358087835689}}

 

{{/*The CHANNEL ID of the channel where the message to open tickets is*/}}

{{$openchan := 706266347960533003}}

 

{{/*This is the MESSAGE ID of the message that people react on to OPEN A TICKET*/}}

{{$openmsg := 706267176134246472}}

 

{{/*This is the COOLDOWN LENGTH IN SECONDS (this prevents people from opening multiple tickets in a short amount of time, set it to 0 or 1 if you don't want a cooldown)

The standard value is 1800 seconds (30 minutes)

 

Side Note: The cooldown is per user, not global*/}}

{{$length := 1800}}

 

{{/*CONFIGURATION VARIABLES END*/}}

 

{{/*CODE STARTS*/}}

{{/*Don't touch if you don't know what you're doing!*/}}

 

{{$ticketmsg := toInt (dbGet .Channel.ID "ticketmsg").Value}}

 

{{if not (dbGet (toInt64 0) "ticketsetup")}}

{{if and (eq (toInt .Channel.ID) $openchan) (eq (toInt .Reaction.MessageID) $openmsg)}}

{{addMessageReactions nil .Reaction.MessageID $emoji}}

{{deleteMessageReaction nil .Reaction.MessageID .Reaction.UserID .Reaction.Emoji.Name}}

{{dbSet (toInt64 0) "ticketsetup" true}}

{{dbSet (toInt64 0) "inactiveticketcc" (toString $ccID)}}

{{dbSet (toInt64 0) "ticketcatID" (toString $category)}}

Reaction Ticket System is now active, __**Remember to disable all built-in ticket commands under core > command settings!**__

{{deleteResponse}}

{{end}}

 

{{else}}

{{if and (eq .Reaction.Emoji.Name $emoji) (eq (toInt .Channel.ID) $openchan) (eq (toInt .Reaction.MessageID) $openmsg)}}

 

{{$name := "ticket opening"}}

{{$dbGet := (dbGet .User.ID $name)}}

{{$dbGet2 := (dbGet .User.ID "ticketactive")}}

{{if and $dbGet (not $dbGet2)}}

⚠️ {{.User.Mention}} You cannot open a ticket for the next {{humanizeDurationSeconds ($dbGet.ExpiresAt.Sub currentTime)}}{{deleteResponse 5}}{{deleteMessageReaction nil .Reaction.MessageID .Reaction.UserID .Reaction.Emoji.Name}}

{{else if $dbGet2}}

⚠️ {{.User.Mention}} You already have an open ticket! {{deleteMessageReaction nil .Reaction.MessageID .Reaction.UserID .Reaction.Emoji.Name}}{{deleteResponse 5}}

{{else}}

{{dbSetExpire .User.ID $name "ticket opening" $length}}

{{exec "tickets open" "new ticket"}}

{{deleteMessageReaction nil .Reaction.MessageID .Reaction.UserID $emoji}}

{{deleteResponse 5}}

{{end}}

 

{{else if and (eq .Reaction.Emoji.Name `🛡️`) (eq (toInt .Reaction.MessageID) $ticketmsg) (eq (toInt .Channel.ParentID) $category)}}

{{exec "tickets adminonly"}}

{{deleteMessageReaction nil .Reaction.MessageID .Reaction.UserID `🛡️`}}

 

{{else if and (eq .Reaction.Emoji.Name `📄`) (eq (toInt .Reaction.MessageID) $ticketmsg) (eq (toInt .Channel.ParentID) $category)}}

{{sendDM (cembed "title" (print "Ticket transcript for " .Channel.Name " has been created!") "description" (print "[**Click Here**](" (execAdmin "logs") ")" ))}}

{{.User.Mention}} Check your DMs :^)

{{deleteMessageReaction nil .Reaction.MessageID .Reaction.UserID `📄`}}

 

{{else if and (eq .Reaction.Emoji.Name `❌`) (eq (toInt .Reaction.MessageID) $ticketmsg) (eq (toInt .Channel.ParentID) $category)}}

{{dbDel (toInt64 (dbGet .Channel.ID "ticketauth").Value) "ticketactive"}}

{{deleteMessageReaction nil .Reaction.MessageID .Reaction.UserID `❌`}}

{{exec "tickets close"}}

{{cancelScheduledUniqueCC $ccID "inactive"}}

 

{{end}}

{{end}}

 

{{/*END OF CODE*/}}
