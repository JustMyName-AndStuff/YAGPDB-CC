{{/*This is an automatic responder to boost messages, in order for it to work properly you must configure some settings
trigger: regex trigger with trigger .*
Useful info:
$booster = the person who boosted, works the same as .User, for example: $booster.ID or $booster.Mention*/}}

{{/*Don't change this*/}}
{{$booster := .Message.Author}}

{{/*CONFIGURATION VARIABLES START*/}}

{{/*Should rep be given? if yes, set to true, otherwise false. If your server allows more than one rep you change the $amount variable*/}}
{{$giveRep := false}}
{{$amount := 1}}

{{/*What message should be sent and what reaction should be added if it's a standard boost (can also be a cembed)*/}}
{{$normalMsg := print "Thank you for boosting " $booster.Mention " ^^"}}
{{$normalReact := `:Aww_Blob:700811456119177317`}}

{{/*What message should be sent and what reaction added if the boost got you to tier 1*/}}
{{$tier1Msg := print "Thank you for boosting and getting us to tier 1 " $booster.Mention " :tada:"}}
{{$tier1React := `🎉`}}

{{/*What message should be sent and what reaction added if the boost got you to tier 2*/}}
{{$tier2Msg := print "Thank you for boosting and getting us to TIER 2!!! " $booster.Mention " <:PandaLove:700744046209007677>"}}
{{$tier2React := `:PandaExcited:700744312907890806`}}

{{/*What message should be sent and what reaction added if the boost got you to tier 3*/}}
{{$tier3Msg := print $booster.Mention " just got us to Tier 3!!! <:happypeepo:705145174434775121>"}}
{{$tier3React := `:Poggers:705145645710835722`}}

{{/*CONFIGURATION VARIABLES END*/}}

{{/*CODE STARTS*/}}

{{$type := .Message.Type}}

{{if or (eq $type 8) (eq $type 9) (eq $type 10) (eq $type 11)}}

{{$msg := ""}}
{{$react := ``}}

     {{if eq $type 8}}
     {{$msg = $normalMsg}}
     {{$react = $normalReact}}

          {{else if eq $type 9}}
          {{$msg = $tier1Msg}}
          {{$react = $tier1React}}

          {{else if eq $type 10}}
          {{$msg = $tier2Msg}}
          {{$react = $tier2React}}

     {{else if eq $type 11}}
     {{$msg = $tier3Msg}}
     {{$react = $tier2React}}

{{end}}

{{if $giveRep}}
{{execAdmin "grep" $booster.Username $amount}}
{{end}}

{{sendMessage nil $msg}}
{{addReactions $react}}


{{/*If you want to add any extra code, such as giving a role, you can add it here*/}}


{{end}}

{{/*CODE ENDS*/}}
