{{/*This Command manages all the necessary suggestion commands

     Legend:

          < > = required arguments

          [   ] = optional arguments

Commands available with this:

suggest <suggestion>

editsuggestion <suggestion ID> <new suggestion>

deletesuggestion <suggestion ID>

deny <suggestion ID> [Reason]

approve <suggestion ID> [Reason]

consider <suggestion ID> [Reason]

implement <suggestion ID> [Reason]

 

Trigger type: Regex

Trigger: \A

*/}}

 

{{/*CONFIGURATION VARIABLES START*/}}

 

{{/*The prefix used for all suggestions commands, DO NOT REMOVE THE QUOTES!*/}}

{{$prefix := "-"}}

 

{{/*If your suggestions should be anonymous, set to true. Otherwise set to false*/}}

{{$anonymous := false}}

 

{{/*The emoji that is used to upvote a suggestion

DON'T REMOVE THE BACKTICKS (`)*/}}

{{$upvote := `✅`}}

 

{{/*The emoji that is used to downvote a suggestion

DON'T REMOVE THE BACKTICKS (`)*/}}

{{$downvote := `❌`}}

 

{{/*Cooldown for the suggest command in seconds, this is so that people cannot spam suggestions. Standard value is 900 seconds (15 minutes)*/}}

{{$cooldown := 900}}

 

{{/*IDs of different STAFF ROLES in your server, anyone with one of these roles can deny/approve/consider/implement/delete a suggestion. If you don't want 3 staff roles, insert "" instead of an ID*/}}

{{$Staff1 := 692344457806348328}}

{{$Staff2 := 692344803643621386}}

{{$Staff3 := ""}}

 

{{/*CHANNEL ID of The channel where suggestions are sent to be voted on*/}}

{{$SuggestionsChan := 713172379421114448}}

 

{{/*The CHANNEL ID of the channel where approved/denied/implemented suggestions are sent (set to the same channel ID as $SuggestionsChan if you don't want an extra channel)*/}}

{{$DecisionChan := 713172379421114448}}

 

{{/*EMBED COLORS

ALL EMBED COLORS MUST EITHER BE DECIMAL OR START WITH 0x EXAMPLE:

123654678 - would be a decimal color and does NOT need 0x

0xffa100  - would be a hex color and REQUIRES 0x

ffa100   - This would not work! This is a hex color, all hex colors must start with 0x (0x converts to decimal)

*/}}

 

{{/*The default color*/}}

{{$standardColor := 4886754 }}

 

{{/*The embed color of Approved suggestions*/}}

{{$approveColor := 11403055 }}

 

{{/*The embed color of Denied suggestions*/}}

{{$denyColor := 16719904 }}

 

{{/*The embed color of Considered suggestions*/}}

{{$considerColor := 65535 }}

 

{{/*The embed color of Implemented suggestions*/}}

{{$implementColor := 2061822 }}

 

{{/*CONFIGURATION VARIABLES END*/}}

{{/*START OF CODE, DON'T TOUCH IF YOU DON'T KNOW WHAT YOU'RE DOING!*/}}

 

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

 
{{if (eq $cmd (print $prefix "suggest"))}}

{{if (dbGet .User.ID "suggestcd")}}⚠️ {{.User.Mention}} This command is still on cooldown for: {{humanizeDurationSeconds ((dbGet .User.ID "suggestcd").ExpiresAt.Sub currentTime)}}{{else}}{{dbSetExpire .User.ID "suggestcd" "suggestions" $cooldown}}


{{if ge (len .CmdArgs) 2}}

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

"footer" (sdict "text" (print "Type `" $prefix "Suggestions Help` to get a list of available commands\nSuggestion ID: " (getMessage $SuggestionsChan $msg).ID "\n\nSuggested submitted")) 

"timestamp" $suggestion.Timestamp

"thumbnail" $suggestion.Thumbnail

"color" $suggestion.Color)}}

{{addMessageReactions $SuggestionsChan $msg $upvote $downvote}}

Suggestion submitted in <#{{$SuggestionsChan}}>

{{deleteResponse 5}}

{{else}}

You have to actually suggest something ;)

Correct Usage: `{{$prefix}}Suggest <Your Suggestion>`

{{end}}

{{end}}

 

{{else if or (eq $cmd (print $prefix "approve")) (eq $cmd (print $prefix "deny")) (eq $cmd (print $prefix "consider")) (eq $cmd (print $prefix "implement")) (eq $cmd (print $prefix "implemented"))}}

{{$isStaff := false}}

{{if or (hasRoleID $Staff1) (hasRoleID $Staff2) (hasRoleID $Staff3)}}

{{$isStaff = true}}

{{else}}

You do not have permission to use this command!

{{end}}

{{if eq $isStaff true}}

 

{{if gt (len .CmdArgs) 1}}

{{if and (toInt (index .CmdArgs 1)) (getMessage $SuggestionsChan (index .CmdArgs 1))}}

{{$msgID := toInt (index .CmdArgs 1)}}

{{if not (reFind "Suggestion" (index (getMessage $SuggestionsChan $msgID).Embeds 0).Title)}}

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

{{if or (eq $DecisionChan $SuggestionsChan) (eq $cmd (print $prefix "consider"))}}

{{editMessage $SuggestionsChan $msgID (cembed "title" $suggestion.Title

"description" $suggestion.Description

"author" (sdict "name" $suggestion.Author.Name "icon_url" $suggestion.Author.IconURL)

"footer" (sdict "text" (print "Type `" $prefix "Suggestions Help` to get a list of available commands\nSuggestion ID: " $msgID "\n\nSuggestion " $ft)) 

"timestamp" $timestamp

"thumbnail" $suggestion.Thumbnail

"fields" (cslice (sdict "name" $fieldName "value" $reason))

"color" $color)}}

 

{{else}}


{{$decMsg := sendMessageRetID $DecisionChan (cembed "title" $suggestion.Title

"description" $suggestion.Description

"author" (sdict "name" $suggestion.Author.Name "icon_url" $suggestion.Author.IconURL)

"footer" (sdict "text" (print "Type `" $prefix "Suggestions Help` to get a list of available commands\n\n\n\nSuggested " $ft)) 

"timestamp" $timestamp

"thumbnail" $suggestion.Thumbnail

"fields" (cslice (sdict "name" $fieldName "value" $reason))

"color" $color)}}

 

{{editMessage $DecisionChan $decMsg (cembed "title" $suggestion.Title 

"description" $suggestion.Description

"author" (sdict "name" $suggestion.Author.Name "icon_url" $suggestion.Author.IconURL)

"footer" (sdict "text" (print "Type `" $prefix "Suggestions Help` to get a list of available commands\nSuggestion ID: " (getMessage $SuggestionsChan $decMsg).ID "\n\nSuggestion " $ft)) 

"timestamp" $timestamp

"thumbnail" $suggestion.Thumbnail

"fields" (cslice (sdict "name" $fieldName "value" $reason))

"color" $color)}}

 

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
