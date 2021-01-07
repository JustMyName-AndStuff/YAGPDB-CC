{{/*This goes in the warn DM in moderation settings. Make sure the option "Send warnings to modlog" is turned off, otherwise the bot will send the default warn message + this custom warn message
If you would like the optional banned words extension, add the "banned words extension.cc.go" and follow the instructions*/}}

{{/*CONFIGURATION VARIABLES START*/}}

{{/*The Channel ID of your modlog*/}}
{{$logChan := 694837286403178536}}

{{/*The color of the embed*/}}
{{$color := 0xffd11a}}

{{/*If a DM should be sent to the warned user, set this to true, otherwise false (the DM will show the same info as the message sent to the modlog)*/}}
{{$sendDM := false}}

{{/*CONFIGURATION VARIABLES END*/}}

{{/*START OF CODE*/}}

{{$bannedWords := ""}}

{{if (dbGet 0 "banned words")}}

{{$bannedWords = reReplace `\A` (toString (dbGet 0 "banned words").Value) "("}}
{{$bannedWords = reReplace `\z` $bannedWords ")"}}
{{$bannedWords = reReplace `\s` $bannedWords "|"}}

{{end}}

{{$author := sdict "name" (print .Author.String " (ID: " .Author.ID " )") "icon_url" (.Author.AvatarURL "256")}}
{{$thumbnail := sdict "url" (.User.AvatarURL "256")}}
{{$title := print "has warned " .User.String " (ID: " .User.ID " )"}}
{{$timestamp := currentTime}}

{{$reason := ""}}
{{$channel := sdict "name" ":speech_balloon: Channel: " "value" (print "<#" .Channel.ID ">") "inline" false}}
{{$msg := sdict "name" ":link: Message Link: " "value" (print "[Click Here](https://discord.com/channels/" .Guild.ID "/" .Channel.ID "/" .Message.ID ")") "inline" false}}
{{$logs := sdict "name" ":floppy_disk: Message Logs: " "value" (print "[Click Here](" (execAdmin "logs") ")") "inline" false}}

 {{if .Reason}}
     
      {{if and (reFind "banned words" .Reason) (dbGet 0 "banned words")}}
           
           {{$reason = sdict "name" ":grey_question: Reason: " "value" (print "Sending the banned word ||" (reFind $bannedWords .Message.Content) "||") "inline" false}}

      {{else if or (not (reFind "word blacklist" .Reason)) (not (dbGet 0 "banned words"))}}
           
           {{if reFind `Automoderator:` .Reason}}
{{$reason = sdict "name" ":page_facing_up: Reason: " "value" (reReplace `Triggered rule:\s` (reReplace `Automoderator:\s` .Reason "") "") "inline" false}}
           
           {{else}}
           {{$reason = sdict "name" ":page_facing_up: Reason: " "value" .Reason "inline" false}}

           {{end}}

      {{end}}
 
 {{end}}

 {{$embed := cembed
     "author" $author
     "title" $title
     "thumbnail" $thumbnail
     "fields" (cslice
          $reason
          $channel
          $msg
          $logs)
     "timestamp" $timestamp
     "color" $color}}

{{sendMessage $logChan (complexMessage "content" .User.Mention "embed" $embed)}}

{{if $sendDM}}
{{sendDM $embed}}
{{end}}
