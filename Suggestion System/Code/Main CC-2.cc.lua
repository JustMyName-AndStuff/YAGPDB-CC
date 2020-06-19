{{/*This cc is for the editsuggestion, deletesuggestion and comment commands

 

Trigger type: regex

Trigger: \A

 

There are no configuration variables here, leave everything as it is!

*/}}

{{/*CODE STARTS, DON'T TOUCH IF YOU DON'T KNOW WHAT YOU'RE DOING*/}}

 

{{$prefix := toString (dbGet (toInt64 0) "suggestion_prefix").Value}}

{{$StaffRoles := (cslice).AppendSlice (dbGet (toInt64 0) "suggestion_admins").Value}}

{{$colors := sdict (dbGet (toInt64 0) "suggestion_colors").Value}}

{{$SuggestionsChan := ((sdict (dbGet (toInt64 0) "suggestion_other").Value).Get "channel")}}

{{$editCD := toInt ((sdict (dbGet (toInt64 0) "suggestion_other").Value).Get "editcooldown")}}

{{$standardColor := $colors.standardColor}}

{{$approveColor := $colors.approveColor}}

{{$denyColor := $colors.denyColor}}

{{$considerColor := $colors.considerColor}}

{{$implementColor := $colors.implementColor}}

{{$cmd := (lower (index .CmdArgs 0))}}

{{$isStaff := false}}

{{range $StaffRoles}}

{{if (in $.Member.Roles .)}}

{{$isStaff = true}}

{{end}}

{{end}}

{{$comment := print "Comment from " .User.String}}

{{$subcmd := " "}}

{{if or (reFind (print `\A` $prefix `edit(suggest(ion|\b|\s)|sgt)`) .StrippedMsg) (eq $cmd (print $prefix "comment"))}}

{{if reFind (print `\A` $prefix `edit(suggest(ion|\b|\s)|sgt)`) .StrippedMsg}}

{{$subcmd = "EditSuggestion <Suggestion ID> <New Suggestion>"}}

{{else if eq $cmd (print $prefix "comment")}}

{{$subcmd = "Comment <Suggestion ID> <Comment>"}}

{{end}}

{{if gt (len .CmdArgs) 2}}

{{if and (toInt (index .CmdArgs 1)) (getMessage $SuggestionsChan (index .CmdArgs 1))}}

{{$msgID := toInt (index .CmdArgs 1)}}

{{$suggestion := index (getMessage $SuggestionsChan $msgID).Embeds 0}}

{{if not (getMessage $SuggestionsChan $msgID).Embeds}}

Please provide a valid Suggestion ID, either the message you provided does not exist or it is not a suggestion

{{else if not (reFind "Suggestion" $suggestion.Title)}}

Please provide a valid Suggestion ID, either the message you provided does not exist or it is not a suggestion

{{else if (ne $suggestion.Color $standardColor)}}

A decision has already been made on this suggestion! Meaning it has been approved/denied/considered or implemented

{{else}}

{{if reFind (print `\A` $prefix `edit(suggest(ion|\b|\s)|sgt)`) .StrippedMsg}}

{{if (ne .User.ID (toInt64 (reFind `\d{16,20}` (index (getMessage $SuggestionsChan $msgID).Embeds 0).Author.Name)))}}

You can only edit suggestions that were sent by you

{{else}}

{{$dbGet := dbGet .User.ID "editsgtcd"}}

{{if $dbGet}}⚠️ {{.User.Mention}} This command is still on cooldown for: {{humanizeDurationSeconds ($dbGet.ExpiresAt.Sub currentTime)}}{{deleteTrigger 1}}

{{deleteResponse 5}}{{else}}{{dbSetExpire .User.ID "editsgtcd" "editsuggestion" $editCD}}

{{$suggestion := (index (getMessage $SuggestionsChan $msgID).Embeds 0)}}

{{$editEmbed := cembed "title" $suggestion.Title

"description" (joinStr " " (slice .CmdArgs 2) "\n*`(edited)`*")

"author" (sdict "name" $suggestion.Author.Name "icon_url" $suggestion.Author.IconURL)

"footer" (sdict "text" (print "Type `" $prefix "Suggestions Help` to get a list of available commands\nSuggestion ID: " $msgID "\n\nSuggestion was edited")) 

"timestamp" currentTime

"thumbnail" $suggestion.Thumbnail

"color" $suggestion.Color

"fields" $suggestion.Fields}}

{{editMessage $SuggestionsChan $msgID $editEmbed}}

Suggestion edited :+1:

{{end}}

{{end}}

{{else if eq $cmd (print $prefix "comment")}}

{{if $isStaff}}

{{$commentext := joinStr " " (slice .CmdArgs 2)}}

{{$suggestion := index (getMessage $SuggestionsChan $msgID).Embeds 0}}

{{editMessage $SuggestionsChan $msgID (cembed "title" $suggestion.Title "description" $suggestion.Description "author" (sdict "name" $suggestion.Author.Name "icon_url" $suggestion.Author.IconURL) "footer" (sdict "text" $suggestion.Footer.Text) "timestamp" $suggestion.Timestamp "thumbnail" $suggestion.Thumbnail

"color" $suggestion.Color "fields" (cslice 

(sdict "name" $comment "value" $commentext)))}}

Comment has been submitted

{{else}}

You don't have permission to use this command

{{end}}

{{end}}

{{end}}

{{else}}

Please provide a valid Suggestion ID, either the message you provided does not exist or it is not a suggestion

{{end}}

{{else}}

Not enough arguments provided

Correct Usage: `{{print $prefix $subcmd}}`

{{end}}

{{deleteResponse 5}}

{{deleteTrigger 1}}

{{end}}
