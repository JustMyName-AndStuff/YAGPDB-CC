{{/*This Command manages most of the necessary suggestion commands

Trigger type: Regex

Trigger: \A

*/}}

 

{{/*CONFIGURATION VARIABLES START*/}}

 

{{/*The prefix used for all suggestions commands*/}}

{{$prefix := "-"}}

 

{{/*If your suggestions should be anonymous, set to true. Otherwise set to false*/}}

{{$anonymous := false}}

 

{{/*If your suggestions should be deleted once denied, set this to true. 

Note: if you have a decision channel denied suggestions will still get sent there*/}}

{{$denyDel := false}}

 

{{/*The emojis used*/}}

{{$upvote := `✅`}}

{{$downvote := `❌`}}

 

{{/*Cooldown for the suggest command in seconds. Standard value is 900 seconds (15 minutes)*/}}

{{$cooldown := 900}}

 

{{/*Cooldown for the editsuggestion command in seconds. Standard value is 300 seconds (5 minutes)*/}}

{{$editcooldown := 300}}

 

{{/*IDs of different STAFF ROLES in your server, anyone with one of these roles can deny/approve/consider/implement/delete a suggestion.*/}}

{{$StaffRoles := cslice 692344457806348328 692344803643621386 693168400096166030 714476033021313045}}

 

{{/*CHANNEL ID of The channel where suggestions are sent to be voted on*/}}

{{$SuggestionsChan := 693451292944629770}}

 

{{/*CHANNEL ID of the channel where approved/denied/implemented suggestions are sent (set to the same channel ID as $SuggestionsChan if you don't want an extra channel)*/}}

{{$DecisionChan := 693451292944629770}}

 

{{/*EMBED COLORS*/}}

 

{{$standardColor := 0x5798fe }}

{{$approveColor := 0xadff2f }}

{{$denyColor := 0xff0000 }}

{{$considerColor := 0x00ffff }}

{{$implementColor := 0x0000ff }}

 

{{/*CONFIGURATION VARIABLES END*/}}

{{/*START OF CODE*/}}

 

{{dbSet (toInt64 0) "suggestion_prefix" (toString $prefix)}}

{{dbSet (toInt64 0) "suggestion_admins" $StaffRoles}}

{{dbSet (toInt64 0) "suggestion_colors" (sdict "standardColor" $standardColor "approveColor" $approveColor "denyColor" $denyColor "considerColor" $considerColor "implementColor" $implementColor)}}

{{dbSet (toInt64 0) "suggestion_other" (sdict "channel" (toString $SuggestionsChan) "editcooldown" (toString $editcooldown))}}

{{$cmd := (lower (index .CmdArgs 0))}}

{{$author := sdict "name" (print .User.String " (ID: " .User.ID ")") "icon_url" (.User.AvatarURL "256")}}

{{$title := print "Suggestion from " .User.Username}}

{{$timestamp := currentTime}}

{{$thumbnail := sdict "url" (.User.AvatarURL "256")}}

{{if eq $anonymous true}}

{{$author = sdict "name" "Anonymous" "icon_url" "https://www.publicdomainpictures.net/pictures/40000/velka/question-mark.jpg"}}

{{$title = print "Suggestion"}}

{{$thumbnail = sdict "url" "https://www.publicdomainpictures.net/pictures/40000/velka/question-mark.jpg"}}

{{end}}

{{$approved := print "Suggestion approved by " .User.String "\nReason:"}}

{{$denied := print "Suggestion denied by " .User.String "\nReason:"}}

{{$considered := print "Suggestion considered by " .User.String "\nReason:"}}

{{$implemented := print "Suggestion marked as implemented by " .User.String "\nReason:"}}

{{$reason := "No reason specified"}}

{{if reFind (print `\A` $prefix `/(?i)suggestions?\s?help/gm`) .StrippedMsg}}

{{sendMessage nil (cembed "title" ":grey_question: Suggestions Help"

"description" (joinStr "" "**`" $prefix "Suggest <Your Suggestion>`**: Creates a new suggestion" 

"\n\n" 

"**`"

$prefix "EditSuggestion <Suggestion ID> <New Text>`**: Edits an existing suggestion (You can only edit suggestions that were sent by you. Approved, considered, denied and implemented suggestions cannot be edited"

"\n\n"

"**`" $prefix "DeleteSuggestion <Suggestion ID>`**: Deletes the selected suggestion (You can only delete suggestions that were sent by you. Approved, considered and implemented suggestions cannot be deleted, NOT YET AVAILABLE!)"

"\n\n"

"__**Staff-only Commands**__:" "\n\n" "**`" $prefix "Deny <Suggestion ID> [Reason]`**: Denies another User's suggestion with an optional reason" 

"\n\n" 

"**`" $prefix "Approve <Suggestion ID> [Reason]`**: Approves another User's suggestion with an optional reason" "\n\n" "**`" $prefix "Consider <Suggestion ID> [Reason]`**: Marks another User's suggestion as 'Considered' with an optional reason" "\n\n" "**`" $prefix "Implement <Suggestion ID> [Reason]`**: Marks another User's suggestion as 'Implemented' with an optional reason"

"\n\n"

"**`" $prefix "Comment <Suggestion ID> <Comment>`**: Submits a comment on the selected suggestion"

"\n\n"

"**`" $prefix "DeleteSuggestion <Suggestion ID>`**: Deletes the selected suggestion (can delete any suggestion except for approved and implemented suggestions, NOT YET AVAILABLE!)"

"\n\n"

"**`" $prefix "DeleteSuggestion <Suggestion ID> -Override`**: Deletes the selected suggestion (can delete any suggestion, even suggestions that were approved or implemented, NOT YET AVAILABLE!)") "color" 65535 "footer" (sdict "text" "The Suggestion ID is placed in the footer of the suggestion, as is this text."))}}

 

{{else if or (eq $cmd (print $prefix "suggest")) (eq $cmd (print $prefix "suggestion"))}}

{{$dbGet := dbGet .User.ID "suggestcd"}}

 

{{if ge (len .CmdArgs) 2}}

{{if $dbGet}}⚠️ {{.User.Mention}} This command is still on cooldown for: {{humanizeDurationSeconds ($dbGet.ExpiresAt.Sub currentTime)}}{{deleteTrigger 1}}

{{deleteResponse 5}}{{else}}{{dbSetExpire .User.ID "suggestcd" "suggestions" $cooldown}}

{{$msg := sendMessageRetID $SuggestionsChan (cembed "title" $title 

"description" (joinStr " " (slice .CmdArgs 1)) 

"author" $author

"thumbnail" $thumbnail

"timestamp" $timestamp

"color" $standardColor)}}

{{$suggestion := (index (getMessage $SuggestionsChan $msg).Embeds 0)}}

{{editMessage $SuggestionsChan $msg (cembed "title" $suggestion.Title 

"description" $suggestion.Description

"author" (sdict "name" $suggestion.Author.Name "icon_url" $suggestion.Author.IconURL)

"footer" (sdict "text" (print "Type `" $prefix "Suggestions Help` to get a list of available commands\nSuggestion ID: " (getMessage $SuggestionsChan $msg).ID "\n\nSuggestion submitted")) 

"timestamp" $suggestion.Timestamp

"thumbnail" $suggestion.Thumbnail

"color" $suggestion.Color)}}

{{addMessageReactions $SuggestionsChan $msg $upvote $downvote}}

Suggestion submitted in <#{{$SuggestionsChan}}>

{{deleteTrigger 1}}

{{deleteResponse 5}}

{{end}}

{{else}}

You have to actually suggest something ;)

Correct Usage: `{{$prefix}}Suggest <Your Suggestion>`

{{deleteTrigger 1}}

{{deleteResponse 5}}

{{end}}

{{else if or (eq $cmd (print $prefix "approve")) (eq $cmd (print $prefix "deny")) (eq $cmd (print $prefix "consider")) (eq $cmd (print $prefix "implement")) (eq $cmd (print $prefix "implemented"))}}

{{$isStaff := false}}

 

{{range $StaffRoles}}

{{if (in $.Member.Roles .)}}

{{$isStaff = true}}

{{end}}

{{end}}

{{if $isStaff}}

 

{{if gt (len .CmdArgs) 1}}

{{if and (toInt (index .CmdArgs 1)) (getMessage $SuggestionsChan (index .CmdArgs 1))}}

{{$msgID := toInt (index .CmdArgs 1)}}

{{if not (getMessage $SuggestionsChan $msgID).Embeds}}

Please provide a valid Suggestion ID, either the message you provided does not exist or it is not a suggestion

{{else if not (reFind "Suggestion" (index (getMessage $SuggestionsChan $msgID).Embeds 0).Title)}}

Please provide a valid Suggestion ID, either the message you provided does not exist or it is not a suggestion

{{else}}

{{if ge (len .CmdArgs) 3}}

{{$reason = joinStr " " (slice .CmdArgs 2)}}

{{end}}

 

{{$fieldName := " "}}

{{$color := " "}}

{{$ft := " "}}

{{if eq $cmd (print $prefix "approve")}}

{{$fieldName = $approved}}

{{$color = $approveColor}}

{{$ft = "approved"}}

{{else if eq $cmd (print $prefix "deny")}}

{{$fieldName = $denied}}

{{$color = $denyColor}}

{{$ft = "denied"}}

{{else if eq $cmd (print $prefix "consider")}}

{{$fieldName = $considered}}

{{$color = $considerColor}}

{{$ft = "considered"}}

{{else}}

{{$fieldName = $implemented}}

{{$color = $implementColor}}

{{$ft = "implemented"}}

{{end}}

 

{{$suggestion := (index (getMessage $SuggestionsChan $msgID).Embeds 0)}}

{{if and (eq $cmd (print $prefix "deny")) (eq $denyDel true)}}

{{deleteMessage $SuggestionsChan $msgID 1}}

{{end}}

{{$editEmbed := cembed "title" $suggestion.Title

"description" $suggestion.Description

"author" (sdict "name" $suggestion.Author.Name "icon_url" $suggestion.Author.IconURL)

"footer" (sdict "text" (print "Type `" $prefix "Suggestions Help` to get a list of available commands\nSuggestion ID: " $msgID "\n\nSuggestion " $ft)) 

"timestamp" $timestamp

"thumbnail" $suggestion.Thumbnail

"fields" (cslice (sdict "name" $fieldName "value" $reason))

"color" $color}}

 

{{if or (eq $DecisionChan $SuggestionsChan) (eq $cmd (print $prefix "consider"))}}

{{editMessage $SuggestionsChan $msgID $editEmbed}}

Suggestion {{$msgID}} has been {{$ft}}

{{else}}

{{sendMessage $DecisionChan $editEmbed}}

Suggestion {{$msgID}} has been {{$ft}} and sent to <#{{$DecisionChan}}>

{{end}}

{{end}}

{{else}}

Please provide a valid Suggestion ID, either the message you provided does not exist or it is not a suggestion

{{end}}

{{else}}

Not enough arguments passed, please provide a suggestion ID

{{end}}

{{end}}

{{deleteTrigger 1}}

{{deleteResponse 5}}

{{end}}

 

{{/*END OF CODE*/}}
