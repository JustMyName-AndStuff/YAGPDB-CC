{{/*This custom command code manages the add/adduser, remove/removeuser, resend and rename commands

 This is the FIRST bit of code you should add!

Trigger type: Regex

Trigger: \A

 

There are no variables to configure in this code, leave it as it is

*/}}

 

{{/*CODE STARTS (DON'T TOUCH IF YOU DON'T KNOW WHAT YOU'RE DOING)*/}}

 

{{$inlen := toInt (dbGet (toInt64 0) "ticketinlen").Value}}

 

{{$prefix := (dbGet (toInt64 0) "ticketprefix").Value}}

 

{{if eq (toInt .Channel.ParentID) (toInt (dbGet (toInt64 0) "ticketcatID").Value)}}

 

{{if not .ExecData}}

{{cancelScheduledUniqueCC .CCID "inactive"}}

{{scheduleUniqueCC .CCID nil $inlen "inactive" "tickets close inactive"}}

{{else if .ExecData}}

{{exec .ExecData}}

{{dbDel (toInt64 (dbGet .Channel.ID "ticketauth").Value) "ticketactive"}}

{{end}}

 

{{if eq (lower (index .CmdArgs 0)) (joinStr "" $prefix "resend")}}

 

{{deleteMessage nil (toInt (dbGet .Channel.ID "ticketmsg").Value) 1}}

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

 

{{else if or (eq (lower (index .CmdArgs 0)) (joinStr "" $prefix "adduser")) (eq (lower (index .CmdArgs 0)) (joinStr "" $prefix "add"))}}

{{if (ge (len .CmdArgs) 2)}}

{{if (userArg (index .CmdArgs 1))}}

{{with (userArg (index .CmdArgs 1)).ID}}

{{exec "tickets adduser" .}}

{{end}}

{{else}}

Please provide a valid User

{{end}}

{{else}}

Correct Usage: {{print (index .CmdArgs 0) " <user mention or user ID>"}}

{{end}}

 

{{else if or (eq (lower (index .CmdArgs 0)) (joinStr "" $prefix "removeuser")) (eq (lower (index .CmdArgs 0)) (joinStr "" $prefix "remove"))}}

{{if (ge (len .CmdArgs) 2)}}

{{if (userArg (index .CmdArgs 1))}}

{{with (userArg (index .CmdArgs 1)).ID}}

{{exec "tickets removeuser" .}}

{{end}}

{{else}}

Please provide a valid User

{{end}}

{{else}}

Correct Usage: {{print (index .CmdArgs 0) " <user mention or user ID>"}}

{{end}}

 

{{else if eq (lower (index .CmdArgs 0)) (joinStr "" $prefix "rename")}}

{{if ge (len .CmdArgs) 2}}

{{with (slice .CmdArgs 1)}}

{{exec "tickets rename" .}}

{{end}}

{{else}}

Please provide a name to rename the ticket to

{{end}}

{{end}}

{{end}}

 

{{/*END OF CODE*/}}
