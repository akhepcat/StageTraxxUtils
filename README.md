stem2st4s.sh 
* this is the original framework I wrote in bash to deal with stemdeck exports and
* get them cleaned up for Stage Traxx 4 importing.  It's not complete, and probably doesn't work
* but it was enough of an outline that I could use it as as jumping off point for python development

stem2st4s
* This is an AI (Gemini) conversion of my bash script, along with multiple corrections and extensions by me.
* This works "well enough" for my purposes and workflow, as well as all my naming conventions
* Lots of work would be needed to make it more portable or flexible to other naming conventions.
* added config.json.example, copy it to the local directory as 'config.json' 
** you can leave it in the repo as it's untracked and ignored.
** edit it to your heart's content

Neither of these try to get all the information that can be used by Stage Traxx, so things like 
lyric timing (from PDFs) or tempos aren't even bothered with.  Tempo defaults to 120bpm, but you can fix that in edit mode.
I don't use the tempos at all because I don't  have any triggers or midi to deal with.
