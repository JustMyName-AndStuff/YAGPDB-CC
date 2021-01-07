{{/*This is the optional banned words extension, when a user is warned by the automoderator with the banned words rule, it will show the following reason: "sending the banned word ||<banned word>||" 

the || hide the banned word until you click on it

If you would like to disable the extension, type -bannedwords delete

 

Recommended trigger: command trigger with trigger `bannedwords`

 

Once you have used this cc, you can delete it. If you ever want to change the banned words database, just re-add it and run it again*/}}

 

{{/*NO CONFIGURATION VARIABLES*/}}

 

{{/*START OF CODE*/}}

 

{{$args := parseArgs 1 "Correct Usage:\n\n`-bannedwords <your list of banned words>` to set a list of banned words and enable the banned words extension\n\n`-bannedwords delete` to delete the banned words list and disable the banned words extension\n\n`-bannedwords show` to show the current list of banned words" (carg "string" "list of banned words")}}

 

{{if eq (lower ($args.Get 0)) "delete"}}

{{dbDel 0 "banned words"}}

Deleted the banned words list and disabled the banned words extension

{{else if eq (lower ($args.Get 0)) "show"}}

{{(dbGet 0 "banned words").Value}}

{{else}}

{{dbSet 0 "banned words" ($args.Get 0)}}

All set :)

{{end}}

 

{{deleteTrigger 1}}

{{deleteResponse 5}}

 

{{/*END OF CODE*/}}
