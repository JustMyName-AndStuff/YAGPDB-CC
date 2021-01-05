{{/*A simple reaction verification command that removes the User's reaction
Trigger: Reaction (added reactions only)
If you are already using my Reaction Ticket System, you can add this to the "Reaction Listener" cc to use less custom commands overall :)*/}}

{{/*CONFIGURATION VARIABLES START*/}}

{{/*The reaction emoji (Use unicode! Currently custom emoji aren't supported)*/}}
{{$emoji := `✅` }}

{{/*The Channel where the verification message is in*/}}
{{$channel := 692841897890283609}}

{{/*The ID of the verification message*/}}
{{$msg := 714239212429508618}}

{{/*The role you receive once you've verified*/}}
{{$verified := 693437033426714674}}

{{/*The DM the User gets when they receive the verified role*/}}
{{$verifyDM := "Thanks for verifying!" }}

{{/*The DM the User gets when they already have the verified role*/}}
{{$alreadyDM := "You've already verified :)" }}

{{/*CONFIGURATION VARIABLES END*/}}

{{/*START OF CODE*/}}

{{with .Reaction}}
{{if and (eq (toInt .ChannelID) $channel) (eq (toInt .MessageID) $msg)}}
{{deleteMessageReaction nil .MessageID .UserID .Emoji.Name}}
{{if eq .Emoji.Name $emoji}}
{{if not (dbGet (toInt64 0) "verifysetup")}}
{{dbSet (toInt64 0) "verifysetup" true}}
{{addReactions $emoji}}
{{end}}
{{if not (hasRoleID $verified)}}
{{addRoleID $verified}}
{{sendDM $verifyDM}}
{{else}}
{{sendDM $alreadyDM}}
{{end}}
{{end}}
{{end}}
{{end}}

{{/*END OF CODE*/}}
