{{/*This code goes in the "Opening message in new tickets" message under tools&utilities > ticket system

There are only 2 optional values to configure here, all other values are defined in the Reaction listener cc*/}}

{{/*CONFIGURATION VARIABLES START, THESE VALUES CAN OPTIONALLY BE CHANGED, HOWEVER IT IS NOT OBLIGATORY TO CHANGE THEM*/}}

{{/*Time in SECONDS after which inactive tickets are deleted
Standard value is 10800 seconds (3 hours)*/}}
{{$inlen := 10800}}

{{/*The PREFIX that is to be used for the resend, rename, adduser and removeuser commands
DO NOT REMOVE THE QUOTES*/}}
{{$prefix := "-"}}

{{/*CONFIGURATION VARIABLES END*/}}

{{/*CODE STARTS (DON'T TOUCH IF YOU DON'T KNOW WHAT YOU'RE DOING)*/}}

{{dbSet (toInt64 0) "ticketinlen" (toString $inlen)}}
{{dbSet (toInt64 0) "ticketprefix" (toString $prefix)}}

{{
$msg :=
sendMessageRetID nil (complexMessage
"content"
(joinStr "" .User.Mention " Please describe the reasoning for opening this ticket, include any information you think may be relevant such as proof, other third parties and so on.\n\nHere's a list of commands you can use:")
"embed"
(cembed 
"title" ":ticket:**Tickets Help**"
"description" 
(joinStr "" "**`" $prefix "Add/AddUser <User ID or Mention>`**: Adds a user to the current ticket\n\n**`" $prefix "Remove/RemoveUser <User ID or Mention>`**: Removes a user from the current ticket\n\n**`" $prefix "Rename <new-name>`**: Renames the current ticket\n\n**`" $prefix "Resend`**: If the ticket channel gets full, this command will automatically resend the first message\n\n`❌`: Closes the current ticket\n\n`🛡️`: Toggles admin-only mode for the current ticket\n\n`📄`: Sends a transcript of this ticket to you in DM")
"footer"
(sdict "text" (joinStr "" "Example for " $prefix "Add/AddUser:\n" $prefix "Add @user\nThe " $prefix "Remove/RemoveUser command works the same.\nExample for " $prefix "Rename:\n" $prefix "Rename some kind of name here\nThe " $prefix "Resend command does not require any arguments, example:\n" $prefix "Resend"))
"color" 0x00ffff
))
}}
{{$msget := getMessage nil $msg}}
{{addMessageReactions nil (toInt $msget.ID) `❌` `🛡️` `📄`}}
{{dbSet .Channel.ID "ticketmsg" (toString $msget.ID)}}
{{scheduleUniqueCC (toInt (dbGet (toInt64 0) "inactiveticketcc").Value) nil $inlen "inactive" "tickets close inactive"}}
{{dbSet .User.ID "ticketactive" true}}
{{dbSet .Channel.ID "ticketauth" (toString .User.ID)}}

{{/*END OF CODE*/}}
