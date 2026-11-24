##################################################
Select music for match on SSS v2 [Squidgy, mawwwk]
# updated to support StageEx
# button no longer affects pages/random/back
##################################################
# Press a custom button while hovering over a stage to open the My Music screen
# Press the custom button to select the song and automatically start the match
# Press A to preview songs, or B to back out

# --CONTROL OPTIONS--
# Button to open song select
# button values : 21 (X), 20 (Y), 19 (Start/+)
.alias button = 20
# Button to select a song in song select
# selectButton values : 21 (X), 20 (Y), 23 (Start/+)
# selectButton = 23 is Start, as in P+Ex's REL (used by the My Music port below)
.alias selectButton = 23
# Recommended to use the same button for opening song select and picking a song, 
# but note that some buttons (such as Start) use a different number for each

# --CUSTOM ADDRESSES USED--
# 80002810 - we use this address for a flag that tells us what step we are on
# 80002818 - we use this address for the selected song ID
# 8000281C - we use this address for selected stage index
# 80002820 - we use this address for selected stage type
# 80002824 - we use this address for SSS page
# 80002828 - we use this address to store the current mode
# 80002830 - port 1 hidden alt
# 80002834 - port 2 hidden alt
# 80002838 - port 3 hidden alt
# 8000283C - port 4 hidden alt

# --FLAG STATES--
# 1 - going to My Music, 2 - My Music opened, 3 - song chosen, 4 - backing out of My Music, 
# 5 - returning from My Music, 6 - back to SSS, 7 - highlight chosen stage/select stage

# macro to store selected hidden alt so it can load when picking songs
.macro storeHiddenAlt(<baseAddress>,<storeAddress>)
{
    lis r4, 0x9018                  # \ base address for port hidden alt status
    ori r4, r4, <baseAddress>       # /

    lis r10, 0x0004                 # \ offset to hidden alt status
    ori r10, r10, 0x3AD8            # |
    lwzx r4, r10 (r4)               # / store the status in r4

    lis r9, 0x8000                  # \ address where we WILL store port hidden alt
    ori r9, r9, <storeAddress>      # /

    stw r4, 0 (r9)                  # store status in our store location
}

# macro to retrieve any selected hidden alts
.macro retrieveHiddenAlt(<baseAddress>,<storeAddress>)
{
    lis r9, 0x8000                  # \ address where hidden alt is stored
    ori r9, r9, <storeAddress>      # |
    lwz r9, 0 (r9)                  # /

    lis r8, 0x9018                  # \ base address for port hidden alt status
    ori r8, r8, <baseAddress>       # /

    lis r10, 0x0004                 # \ offset to hidden alt status
    ori r10, r10, 0x3AD8            # |
    add r8, r10, r8                 # / final address

    stw r9, 0 (r8)                  # store hidden alt status
}

# macro to get the scene manager address
.macro getSceneManager()
{
    lis r12, 0x8002     # \ call getInstance/[gfSceneManager]
    ori r12, r12 0xd018 # |
    mtctr r12           # |
    bctrl               # / scene manager address placed in r3
}

# macro to reset all stored values
.macro cleanup(<valueRegister>,<addressRegister>)
{
    li <valueRegister>, 0                           # \ reset all stored values to 0
    stw <valueRegister>, 0 (<addressRegister>)      # |
    stw <valueRegister>, 0x8 (<addressRegister>)    # |
    stw <valueRegister>, 0xC (<addressRegister>)    # |
    stw <valueRegister>, 0x10 (<addressRegister>)   # |
    stw <valueRegister>, 0x14 (<addressRegister>)   # |
    stw <valueRegister>, 0x18 (<addressRegister>)   # |
    stw <valueRegister>, 0x20 (<addressRegister>)   # |
    stw <valueRegister>, 0x24 (<addressRegister>)   # |
    stw <valueRegister>, 0x28 (<addressRegister>)   # |
    stw <valueRegister>, 0x2C (<addressRegister>)   # /
}

# this hook makes our button work on SSS
HOOK @ $806b5864 # hook where we check if A is being pressed on SSS
{
    # check to ensure this only works in regular VS mode
    mr r9, r3   # store r3

    %getSceneManager()   # \ get scene manager
    mr r10, r3           # | place scene manager into r10
    lwz r3, 0x10 (r10)   # | load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)       # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqVsMelee" into r4
    ori r4, r4, 0x17E0  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, proceed
    beq versus          # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqSpMelee" into r4
    ori r4, r4, 0x17F8  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, continue
    beq special         # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqTraining" into r4
    ori r4, r4, 0x1870  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings don't match, skip
    beq training        # | proceed
    mr r3, r9           # | restore r3
    bne skip            # / skip

    versus:
    li r10, 1
    b continue

    special:
    li r10, 3
    b continue

    training:
    li r10, 12

    continue:
    mr r3, r9           # \ store r3
    %getSceneManager()  # | get scene manager
    mr r8, r3           # | store scene manager in r8
    mr r3, r9           # | restore r3
    lwz r8, 0x0280 (r8) # |check we are on Main Menu sequence
    cmpwi r8, 1         # |
    beq skip            # / if we are, skip

    # Check ID of selected stage icon
    lwz r9, 0x244 (r27)         # r27 is muSelectStageTask, offset 0x244 is selected stage icon
	cmpwi r9, 0x35; beq skip	# Page button
	cmpwi r9, 0x36;	beq skip	# Random button
	cmpwi r9, 0x37; beq skip	# Back button
    # Check index of selected stage
    lwz r9, 0x248 (r27)                 # \ r27 is muSelectStageTask, offset 0x248 is selected stage index
    cmpwi r9, 0; bge buttonPressed      # / if stage index is -1, check if stage alt list is dispalyed
    # If index is -1, check if we are on stage alt list
    lwz r9, 0x228 (r27)                 # \ offset 0x228 is current page
    cmpwi r9, 2; blt skip               # / if we aren't viewing stage alt list (page 2 aka Stage Builder), skip

    buttonPressed:
    rlwinm. r0, r3, 0, button, button # if button is being pressed, treat that as a valid stage select button
    bne goToMyMusic

    skip:
    rlwinm. r0, r3, 0, 23, 23 # original line
    b %end%

    goToMyMusic:
    lis r9, 0x8000     # \
    ori r9, r9, 0x2810 # |
    li r4, 1           # |
    stw r4, 0 (r9)     # / if we pressed the button, set the flag indicating to go to My Music

    #li r4, 1            # \ set the mode we will jump to from My Music - 1 is VS, 2 is tourney, 3 is special versus
    stw r10, 0x18 (r9)   # / right now is always 1, this could be expanded to work with other modes
}

# additional hook to ensure button works on CSS (prevents a crash with MMU enabled)
HOOK @ $806b5780
{
    # check to ensure this only works in regular VS mode
    mr r9, r3   # store r3

    %getSceneManager()  # \ get scene manager
    mr r10, r3          # | place scene manager in r3
    lwz r3, 0x10 (r10)   # | load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqVsMelee" into r4
    ori r4, r4, 0x17E0  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, continue
    mr r3, r9           # | restore r3
    beq continue        # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqSpMelee" into r4
    ori r4, r4, 0x17F8  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, continue
    beq continue        # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)       # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqTraining" into r4
    ori r4, r4, 0x1870  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings don't match, skip
    beq continue        # | continue
    mr r3, r9           # | restore r3
    bne skip            # / skip

    continue:
    mr r3, r9           # \ store r3
    %getSceneManager()  # | get scene manager
    mr r8, r3           # | store scene manager in r8
    mr r3, r9           # | restore r3
    lwz r8, 0x0280 (r8) # |check we are on Main Menu sequence
    cmpwi r8, 1         # |
    beq skip            # / if we are, skip

    # Check ID of selected stage icon
    lwz r9, 0x244 (r27)         # r27 is muSelectStageTask, offset 0x244 is selected stage icon
	cmpwi r9, 0x35; beq skip	# Page button
	cmpwi r9, 0x36;	beq skip	# Random button
	cmpwi r9, 0x37; beq skip	# Back button
    # Check index of selected stage
    lwz r9, 0x248 (r27)                 # \ r27 is muSelectStageTask, offset 0x248 is selected stage index
    cmpwi r9, 0; bge buttonPressed      # / if stage index is -1, check if stage alt list is dispalyed
    # If index is -1, check if we are on stage alt list
    lwz r9, 0x228 (r27)                 # \ offset 0x228 is current page
    cmpwi r9, 2; blt skip               # / if we aren't viewing stage alt list (page 2 aka Stage Builder), skip

    buttonPressed:
    rlwinm. r0, r3, 0, button, button # if button is being pressed, treat that as a valid stage select button
    bne %end%

    skip:
    rlwinm. r0, r3, 0, 23, 23 # original line
    b %end%
}

# additional hook to ensure button works on CSS (prevents a crash with MMU enabled)
HOOK @ $806b589c
{
    # check to ensure this only works in regular VS mode
    mr r9, r3   # store r3

    %getSceneManager()  # \ get scene manager
    mr r10, r3          # | place scene manager in r3
    lwz r3, 0x10 (r10)   # | load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqVsMelee" into r4
    ori r4, r4, 0x17E0  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, continue
    mr r3, r9           # | restore r3
    beq continue        # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqSpMelee" into r4
    ori r4, r4, 0x17F8  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, continue
    beq continue        # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)       # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqTraining" into r4
    ori r4, r4, 0x1870  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings don't match, skip
    beq continue        # | continue
    mr r3, r9           # | restore r3
    bne skip            # / skip

    continue:
    mr r3, r9           # \ store r3
    %getSceneManager()  # | get scene manager
    mr r8, r3           # | store scene manager in r8
    mr r3, r9           # | restore r3
    lwz r8, 0x0280 (r8) # |check we are on Main Menu sequence
    cmpwi r8, 1         # |
    beq skip            # / if we are, skip

    # Check ID of selected stage icon
    lwz r9, 0x244 (r27)         # r27 is muSelectStageTask, offset 0x244 is selected stage icon
	cmpwi r9, 0x35; beq skip	# Page button
	cmpwi r9, 0x36;	beq skip	# Random button
	cmpwi r9, 0x37; beq skip	# Back button
    # Check index of selected stage
    lwz r9, 0x248 (r27)                 # \ r27 is muSelectStageTask, offset 0x248 is selected stage index
    cmpwi r9, 0; bge buttonPressed      # / if stage index is -1, check if stage alt list is dispalyed
    # If index is -1, check if we are on stage alt list
    lwz r9, 0x228 (r27)                 # \ offset 0x228 is current page
    cmpwi r9, 2; blt skip               # / if we aren't viewing stage alt list (page 2 aka Stage Builder), skip

    buttonPressed:
    rlwinm. r0, r3, 0, button, button # if button is being pressed, treat that as a valid stage select button
    bne %end%

    skip:
    rlwinm. r0, r3, 0, 23, 23 # original line
    b %end%
}

# this hook makes it so that turn order is kept intact when stage selection option is set to taking turns
HOOK @ $80055584 # gmSetRuleSelStage - when we set which player is in control
{
    lis r8, 0x8000     # \
    ori r8, r8, 0x2810 # |
    lwz r8, 0 (r8)     # | get flag
    cmpwi r8, 7        # | if flag is 7 (coming from My Music), skip changing which player is in control
    beq %end%          # /

    stb r7, 0 (r5) # original line, sets which player is in control
}

# this hook stores the stage index if we open the alt stage submenu
HOOK @ $806b59e8 # muSelectStageTask:buttonProc - when we set the stage index to -1
{
    lis r3, 0x8000          # \ get address
    ori r3, r3, 0x2810      # /

    lwz r8, 0x248 (r29)     # \ offset 248 is stage index
    stw r8, 0xC (r3)        # / store stage index

    done:
    stw r0, 0x0248 (r29) # original code, sets stage index
}

# this hook stores stage info before we go to My Music
HOOK @ $806c905c # muSelectStageTask:process - when we set info for selected stage
{
    lis r8, 0x8000     # \
    ori r8, r8, 0x2810 # |
    lwz r7, 0 (r8)     # | get flag
    cmpwi r7, 1        # | if flag is not 1 (going to My Music), skip to end
    bne done           # /

    lwz r7, 0x248 (r5)  # \ r5 is muSelectStageTask, offset 248 is stage index
    cmpwi r7, -1        # | if stage index is -1, skip storing it
    beq setType         # |
    stw r7, 0xC (r8)    # / store stage index

    setType:
    lwz r7, 0x254 (r5)    # \ offset 254 is stage type
    stw r7, 0x10 (r8)     # / store stage type

    lis r7, 0x8049	    # \
    ori r7, r7, 0x6000	# | address where the SSS page is
    lbz r7, 0 (r7)	    # |
    stb r7, 0x14 (r8)	# / store current page

    done:
    stw r0, 0x0288 (r3) # original line
}

# macro for the code that sends us to My Music
.macro goToMyMusic(<register>,<case>,<stageSelectCase>)
{
    lwz r0, 0x0008 (<register>) # original code

    cmpwi r0, <stageSelectCase> # if we are not changing stages, check if we're returning from My Music
    bne %end%

    %getSceneManager()  # \ get scene manager
    lwz r9, 0x0284 (r3) # | offset 284 from scene manager stores stage builder/regular stage
    cmpwi r9, 3         # | 3 means stage builder, 1 means regular
    bne flagCheck       # / if it's not a stage builder stage, go to flag check
    
    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # / get stored values

    %cleanup(r7,r9)     # reset all stored values to 0
    b %end%             # go to end

    flagCheck:
    lis r9, 0x8000     # \
    ori r9, r9, 0x2810 # |
    lwz r4, 0 (r9)     # | get flag
    cmpwi r4, 1        # | if flag isn't 1 (going to My Music), jump to end
    bne %end%          # /

    # store hidden alts if any were selected
    %storeHiddenAlt(0x0b40, 0x2830)
    %storeHiddenAlt(0x0b9C, 0x2834)
    %storeHiddenAlt(0x0bf8, 0x2838)
    %storeHiddenAlt(0x0c54, 0x283C)

    # if we're on SSS and flag is 1, go to main menu
    li r0, <case> # set switch/case to pick main menu option
}

# this hook makes it so our button sends us to My Music instead of starting the match - VS
HOOK @ $806dcb50 # hook for transitioning to a match
{
    %goToMyMusic(r15, 0x10, 0x7)
}

# this hook makes it so our button sends us to My Music instead of starting the match - Special
HOOK @ $806deaac # hook for transitioning to a match
{
    %goToMyMusic(r30, 0x10, 0x7)
}

# this hook makes it so our button sends us to My Music instead of starting the match - Training
HOOK @ $806f1574 # hook for transitioning to a match
{
    %goToMyMusic(r15, 0xb, 0x6)
}

# this hook makes it so we get warped to My Music instead of just the main menu
HOOK @ $806cc050 # The instruction for when we go to main menu
{
    lis r8, 0x8000      # \
    ori r8, r8, 0x2810  # |
    lwz r8, 0 (r8)      # | get flag
    cmpwi r8, 1         # | if flag isn't 1 (going to My Music), just run original code
    bne done            # /

    li r3, 12 # otherwise, force it to go to My Music
    
    done:
    cmpwi r5, 0 # original code
}

# this hook makes it so that the icons, thumbnails, and other elements don't display when we go to My Music
HOOK @ $806b10d0 # when we call dispPage in muSelectStageTask:initProcWithScreen
{
    lis r4, 0x8000      # \
    ori r4, r4, 0x2810  # |
    lwz r4, 0 (r4)      # | get flag
    cmpwi r4, 1         # | if flag isn't 1 (going to My Music), just run original code
    bne done            # /

    lis r12, 0x806b     # jump to address after dispPage call
    ori r12, r12 0x10dc
    mtctr r12
    bctr

    done:
    lwz r4, 0x0228 (r26) # original code
}

# THESE HOOKS HAVE BEEN MOVED TO THE sora_menu_main.rel
# # this hook makes the tracklist open and hides elements when we go to My Music
# HOOK @ $8117de68 # My Music function that runs every frame
# {
#     lis r4, 0x8000      # \
#     ori r4, r4, 0x2810  # |
#     lwz r4, 0 (r4)      # | get flag
#     cmpwi r4, 1         # |
#     bne done            # / if flag isn't 1, just do original code
	
#     mr r9, r3

#     %getSceneManager()      # \ get scene manager
#     lis r4, 0x806A          # |
#     ori r4, r4 0xDBE4       # | store address of string "muMenuMain" in r4
#     lis r12, 0x8002         # | call searchScene
#     ori r12, r12, 0xd3f4    # |
#     mtctr r12               # |
#     bctrl                   # | r3 is now muMenuMain
#     lwz r8, 0x38c (r3)      # | offset 0x38c of muMenuMain is muProcOptSong
#     lwz r8, 0x694 (r8)      # / offset 0x694 of muProcOptSong is muSelectStageTask

#     lwz r3, 0x0050 (r8)   # \ hides cursor
#     lwz r4, 0x0200 (r8)   # |
#     lwz r12, 0 (r3)       # |
#     lwz r4, 0x0010 (r4)   # |
#     lwz r12, 0x003C (r12) # |
#     mtctr r12             # |
#     bctrl                 # /

#     lwz r3, 0x0214 (r8)    # \ hides highlights around the SSS icon
#     lwz r4, 0x0204 (r8)    # |
#     lwz r12, 0 (r3)        # |
#     lwz r4, 0x0010 (r4)    # |
#     lwz r12, 0x003C (r12)  # |
#     mtctr r12              # |
#     bctrl                  # /

#     lis r3, 0x0000
#     ori r3, r3, 0x0003
#     stw r3, 0x0224 (r8) # flip the flag to disable cursor

#     lis r3, 0x0000
#     ori r3, r3, 0x0001
#     stw r3, 0x0274 (r8) # flip flag to open track list

#     lis r3, 0x8000     # \
#     ori r3, r3, 0x2810 # |
#     li r4, 2           # |
#     stw r4, 0 (r3)     # / set our flag to 2, meaning My Music is opened

#     mr r3, r9 # restore r3

#     done:
#     lwz r0, 0x0664 (r3) # original code
# }

# # this hook forces My Music to open the correct tracklist
# HOOK @ $8117defc # manipulate this instruction so that the correct track list is displayed
# {
#     lis r9, 0x8000      # \
#     ori r9, r9, 0x2810  # |
#     lwz r7, 0 (r9)      # | get flag
#     cmpwi r7, 2         # |
#     bne done            # / if flag isn't 2 (on My Music from SSS)

#     lis r7, 0x805a      # \ load the chosen stage ID instead of a default
#     lwz r7, 0xE0 (r7)   # | 0x805a00e0 - GameGlobal
#     lwz r7, 0x14 (r7)   # | offset 0x14 - gmSelStageData
#     lhz r7, 0x22 (r7)   # | offset 0x22 - stage ID
    
#     b %end%

#     done:
#     li r7, 66 # original line
# }

# # this hook makes our button work on the track list
# HOOK @ $8117f030 # when checking what button is pressed with tracklist open
# {
#     lis r4, 0x8000      # \
#     ori r4, r4, 0x2810  # |
#     lwz r7, 0 (r4)      # | get flag
#     cmpwi r7, 2         # |
#     bne done            # / if flag isn't 2 (on My Music from SSS)

#     rlwinm. r0, r29, 0, selectButton, selectButton # if button is being pressed, treat that as a valid select button
#     bne buttonPressed

#     done:
#     rlwinm. r0, r29, 0, 22, 22 # otherwise, just do original code
#     b %end%

#     buttonPressed:
#     li r7, 3
#     stw r7, 0 (r4) # set flag to 3
#     cmpwi r0, 1 # force the check to fail, so it counts as pressing A
# }

# # this hook stores the chosen song ID when we choose a song
# HOOK @ $8117f07c # when playing a song on my music
# {
#     li r6, 1 # original line

#     lis r8, 0x8000     # \
#     ori r8, r8, 0x2810 # |
#     lwz r7, 0 (r8)     # | get flag
#     cmpwi r7, 3        # |
#     bne %end%          # / if flag isn't 3, skip

#     li r7, 4
#     stw r7, 0 (r8) # set flag to 4, meaning we are returning to SSS

#     lis r8, 0x8000     # \ storing song ID for stage to use
#     ori r8, r8, 0x2810 # | address where we will store song ID
#     stw r30, 0x8 (r8)  # / set stored song ID to the one we are playing - r30 stores current song ID at this point
# }

# # this hook is to make it so pressing our button will keep the song playing even if it is already playing
# HOOK @ $8117f03c # when checking if a song is already playing on My Music when we hit A
# {
#     lis r8, 0x8000      # \
#     ori r8, r8, 0x2810  # |
#     lwz r7, 0 (r8)      # | get flag
#     cmpwi r7, 3         # |
#     bne done            # / if flag isn't 3, skip
#     li r0, 0 # force to count as not playing

#     done:
#     cmpwi r0, 0 # original code
# }

# # this hook is to ensure that pressing our button will trigger the song selection
# HOOK @ $8117f060 # another when we press A on track list
# {
#     lis r8, 0x8000      # \
#     ori r8, r8, 0x2810  # |
#     lwz r7, 0 (r8)      # | get flag
#     cmpwi r7, 3         # |
#     bne done            # / if flag isn't 3, skip
#     li r0, 0 # force to count as not playing

#     done:
#     cmplw r30, r0 # original line
# }

# # this hook is so that when we back out, we'll return to SSS
# HOOK @ $8117e670 # exit/[muProcOptSong] (when exiting My Music)
# {
#     lis r8, 0x8000     		# \
#     ori r8, r8, 0x2810 		# |
#     lwz r7, 0 (r8)     		# | get flag
#     cmpwi r7, 4        		# |
#     bne done			    # / if flag isn't 4, skip

#     li r7, 5
#     stw r7, 0 (r8) 		# set flag to 5, returning from My Music

#     # Old scene change code, no longer used, could be useful reference
#     #lis r9, 0x805b		    # \ tell scene manager to change scenes to vs
#     #ori r9, r9, 0x5030		# | load scene manager into r9
#     #li r10, 0x0		    # |
#     #stb r10, 0x002C (r9)	# |
#     #stb r10, 0x002D (r9)	# |
#     #stb r10, 0x002E (r9)	# |
#     #stb r10, 0x002F (r9) 	# | set some flags that need to be 0
#     #lis r9, 0x805b		    # | 
#     #ori r9, r9, 0x8ba0		# | load scene manager into r9
#     #li r10, 0x1		    # |
#     #stw r10, 0x0284 (r9) 	# | this flag determines what screen we go to from main - 0x1 is VS
#     #li r10, 0x2		    # |
#     #stw r10, 0x0288 (r9) 	# / set flag used by scene manager to 2, triggering scene change

#     mr r10, r3              # \ change scenes - store r3 first
#     %getSceneManager()      # | get scene manager
#     mr r9, r3               # | put scene manager in r9
#     mr r3, r10              # | restore r3
#     lwz r9, 0x4 (r9)        # | this offset gives us the flag to determine what scene to change to
#     lwz r10, 0x18 (r8)      # | load the scene number we stored - right now is always 0x1
#     stw r10, 0x0AB0 (r9)    # /

#     done:
#     mr r31, r3 			# original line
# }

# # this hook is to force the tracklist to close when an option is chosen
# HOOK @ $8117e4b0 # check if B is pressed when My Music tracklist is open
# {
#     lis r9, 0x8000      # \
#     ori r9, r9, 0x2810  # |
#     lwz r8, 0 (r9)      # | get flag
#     cmpwi r8, 4         # |
#     bne done            # / if flag isn't 4, skip

#     li r0, 0x20 # count as we are pressing B
#     cmpwi r0, 0
#     b %end%

#     done:
#     rlwinm. r0, r3, 0, 26, 26 # original line
# }

# # this hook is to ensure we back all the way out to SSS when B is pressed, and to play the correct sound based on the button pressed
# HOOK @ $8117e4e4 # when setting the sound ID for the button pressed while My Music tracklist is open
# {
#     li r4, 2            # original line, sets sound ID to backing out sound

#     lis r9, 0x8000      # \
#     ori r9, r9, 0x2810  # |
#     lwz r8, 0 (r9)      # | get flag
#     cmpwi r8, 2         # |
#     bne nextCheck       # / if flag isn't 2 (pressed B), check if it's 4

#     li r8, 4
#     stw r8, 0 (r9)      # | set flag to 4

#     # clear ASL input
#     lis r8, 0x800C
#     li r9, 0
#     sth r9, -0x615E (r8)

#     # This fixes an issue where looking at the songs for a stage alt would force that alt to load when the stage was selected
#     li r9, 0            # \
#     lis r8, 0x8053      # |
#     ori r8, r8, 0xe000  # | this address stores the chosen stage ID, which is used to determine if we should reload or not
#     sth r9, 0x0FB8 (r8) # / by setting it to 0, the game will see no stage as loaded, and reload the file

#     b %end%

#     nextCheck:
#     cmpwi r8, 4     # \
#     bne %end%       # | if flag isn't 4 (pressed custom button), skip
#     li r4, 1        # / otherwise, set sound ID to confirmation sound (we selected a song instead of backing out)
# }
# END REL HOOKS

# vBrawl: port of P+Ex v1.7 sora_menu_main.rel My Music changes (muProcOptSong).
# vBrawl loads the vanilla module, so the hooks above (which P+Ex keeps in its REL)
# and Desi's "My Music reads the stage TLST" rewrite are applied as GCT codes here:
# 14 hooks (the 9 above, stage TLST load, TLST file load, song list/rate from TLST)
# plus in-place edits so song IDs and titles come from 0x10-byte TLST entries.
# Generated from the REL with relocations resolved; module runtime = file offset + 0x81163780.
# Guarded by a Gecko if-check so nothing is written unless muProcOptSong is in memory.
# Only applied while the vanilla muProcOptSong code is in memory.
* 2117F2BC CBDA0028  # if [8117F2BC] == lfd f30, 0x28(r26)

HOOK @ $8117DE68  # P+Ex sec7+0x20, replaces lwz     r0,1636(r3)
{
    word 0x3c808000  # lis     r4,-32768
    word 0x60842810  # ori     r4,r4,10256
    word 0x80840000  # lwz     r4,0(r4)
    word 0x2c040001  # cmpwi   r4,1
    bne L0AC
    word 0x7c691b78  # mr      r9,r3
    lis r12, 0x8002
    ori r12, r12, 0xd018
    mtctr r12
    bctrl
    word 0x3c80806a  # lis     r4,-32662
    word 0x6084dbe4  # ori     r4,r4,56292
    lis r12, 0x8002
    ori r12, r12, 0xd3f4
    mtctr r12
    bctrl
    word 0x8103038c  # lwz     r8,908(r3)
    word 0x81080694  # lwz     r8,1684(r8)
    word 0x80680050  # lwz     r3,80(r8)
    word 0x80880200  # lwz     r4,512(r8)
    word 0x81830000  # lwz     r12,0(r3)
    word 0x80840010  # lwz     r4,16(r4)
    word 0x818c003c  # lwz     r12,60(r12)
    word 0x7d8903a6  # mtctr   r12
    word 0x4e800421  # bctrl
    word 0x80680214  # lwz     r3,532(r8)
    word 0x80880204  # lwz     r4,516(r8)
    word 0x81830000  # lwz     r12,0(r3)
    word 0x80840010  # lwz     r4,16(r4)
    word 0x818c003c  # lwz     r12,60(r12)
    word 0x7d8903a6  # mtctr   r12
    word 0x4e800421  # bctrl
    word 0x38600003  # li      r3,3
    word 0x90680224  # stw     r3,548(r8)
    word 0x38600001  # li      r3,1
    word 0x90680274  # stw     r3,628(r8)
    word 0x3c608000  # lis     r3,-32768
    word 0x60632810  # ori     r3,r3,10256
    word 0x38800002  # li      r4,2
    word 0x90830000  # stw     r4,0(r3)
    word 0x7d234b78  # mr      r3,r9
L0AC:
    word 0x80030664  # lwz     r0,1636(r3)
    b %end%
}

HOOK @ $8117DEFC  # P+Ex sec7+0xb4, replaces li      r7,66
{
    word 0x3d208000  # lis     r9,-32768
    word 0x61292810  # ori     r9,r9,10256
    word 0x80e90000  # lwz     r7,0(r9)
    word 0x2c070002  # cmpwi   r7,2
    bne L0DC
    word 0x3ce0805a  # lis     r7,-32678
    word 0x80e700e0  # lwz     r7,224(r7)
    word 0x80e70014  # lwz     r7,20(r7)
    word 0xa3270022  # lhz     r25,34(r7)
    b %end%
L0DC:
    word 0x3b200042  # li      r25,66
    b %end%
}

HOOK @ $8117DF7C  # P+Ex sec7+0x240, replaces lwz     r0,1648(r30)
{
    word 0x7f23cb78  # mr      r3,r25
    word 0x3d808053  # lis     r12,-32685
    word 0x6184ef70  # ori     r4,r12,61296
    word 0x3ce0800b  # lis     r7,-32757
    word 0x60e79ea0  # ori     r7,r7,40608
    word 0xa0e70002  # lhz     r7,2(r7)
    word 0x70e70060  # andi.   r7,r7,96
    word 0x90e40000  # stw     r7,0(r4)
    word 0x618ce000  # ori     r12,r12,57344
    word 0x61870024  # ori     r7,r12,36
    word 0x7ce903a6  # mtctr   r7
    word 0x4e800421  # bctrl
    b %end%
}

HOOK @ $8117E4B0  # P+Ex sec7+0x1c8, replaces rlwinm. r0,r3,0,26,26
{
    word 0x3d208000  # lis     r9,-32768
    word 0x61292810  # ori     r9,r9,10256
    word 0x81090000  # lwz     r8,0(r9)
    word 0x2c080004  # cmpwi   r8,4
    bne L1E8
    word 0x38000020  # li      r0,32
    word 0x2c000000  # cmpwi   r0,0
    b %end%
L1E8:
    word 0x546006b5  # rlwinm. r0,r3,0,26,26
    b %end%
}

HOOK @ $8117E4E4  # P+Ex sec7+0x1f0, replaces li      r4,2
{
    word 0x38800002  # li      r4,2
    word 0x3d208000  # lis     r9,-32768
    word 0x61292810  # ori     r9,r9,10256
    word 0x81090000  # lwz     r8,0(r9)
    word 0x2c080002  # cmpwi   r8,2
    bne L230
    word 0x39000004  # li      r8,4
    word 0x91090000  # stw     r8,0(r9)
    word 0x3d00800c  # lis     r8,-32756
    word 0x39200000  # li      r9,0
    word 0xb1289ea2  # sth     r9,-24926(r8)
    word 0x39200000  # li      r9,0
    word 0x3d008053  # lis     r8,-32685
    word 0x6108e000  # ori     r8,r8,57344
    word 0xb1280fb8  # sth     r9,4024(r8)
    b %end%
L230:
    word 0x2c080004  # cmpwi   r8,4
    bne L23C
    word 0x38800001  # li      r4,1
L23C:
    b %end%
}

HOOK @ $8117E5C0  # P+Ex sec7+0x310, replaces li      r26,0
{
    word 0x3b400000  # li      r26,0
    bl MyMusicSub
    b %end%
MyMusicSub:
    word 0x9421fe60  # stwu    r1,-416(r1)
    word 0x7c0802a6  # mflr    r0
    word 0x900101a4  # stw     r0,420(r1)
    word 0x3d808053  # lis     r12,-32685
    word 0x618cf000  # ori     r12,r12,61440
    word 0x810c0018  # lwz     r8,24(r12)
    word 0x80ec0004  # lwz     r7,4(r12)
    word 0x7ce76214  # add     r7,r7,r12
    word 0x7d083a14  # add     r8,r8,r7
    bl S_FMT_get
    mflr r4
    nop
    word 0x3ca08040  # lis     r5,-32704
    word 0x60a56920  # ori     r5,r5,26912
    bl S_PF_get
    mflr r6
    nop
    bl S_DIR_get
    mflr r7
    nop
    word 0x38610100  # addi    r3,r1,256
    lis r12, 0x803f
    ori r12, r12, 0x89fc
    mtctr r12
    bctrl
    word 0x38610010  # addi    r3,r1,16
    word 0x38a00000  # li      r5,0
    word 0x90a30004  # stw     r5,4(r3)
    word 0x90a30010  # stw     r5,16(r3)
    word 0x3c808053  # lis     r4,-32685
    word 0x6084f200  # ori     r4,r4,61952
    word 0x9083000c  # stw     r4,12(r3)
    word 0xa0840008  # lhz     r4,8(r4)
    word 0x90830008  # stw     r4,8(r3)
    word 0x3880ffff  # li      r4,-1
    word 0x90830014  # stw     r4,20(r3)
    word 0x38810100  # addi    r4,r1,256
    word 0x90830000  # stw     r4,0(r3)
    lis r12, 0x8001
    ori r12, r12, 0xd740
    mtctr r12
    bctrl
    word 0x800101a4  # lwz     r0,420(r1)
    word 0x7c0803a6  # mtlr    r0
    word 0x382101a0  # addi    r1,r1,416
    word 0x4e800020  # blr
S_DIR_get:
    blrl
    word 0x2f736f75  # b'/sou'
    word 0x6e642f74  # b'nd/t'
    word 0x7261636b  # b'rack'
    word 0x6c697374  # b'list'
    word 0x2f000000  # b'/\x00\x00\x00'
S_FMT_get:
    blrl
    word 0x25732573  # b'%s%s'
    word 0x25732573  # b'%s%s'
    word 0x2e746c73  # b'.tls'
    word 0x74000000  # b't\x00\x00\x00'
S_PF_get:
    blrl
    word 0x70660000  # b'pf\x00\x00'
}

HOOK @ $8117E670  # P+Ex sec7+0x188, replaces mr      r31,r3
{
    word 0x3d008000  # lis     r8,-32768
    word 0x61082810  # ori     r8,r8,10256
    word 0x80e80000  # lwz     r7,0(r8)
    word 0x2c070004  # cmpwi   r7,4
    bne L1C0
    word 0x38e00005  # li      r7,5
    word 0x90e80000  # stw     r7,0(r8)
    word 0x7c6a1b78  # mr      r10,r3
    lis r12, 0x8002
    ori r12, r12, 0xd018
    mtctr r12
    bctrl
    word 0x7c691b78  # mr      r9,r3
    word 0x7d435378  # mr      r3,r10
    word 0x81290004  # lwz     r9,4(r9)
    word 0x81480018  # lwz     r10,24(r8)
    word 0x91490ab0  # stw     r10,2736(r9)
L1C0:
    word 0x7c7f1b78  # mr      r31,r3
    b %end%
}

HOOK @ $8117E6E4  # P+Ex sec7+0x3a8, replaces li      r30,0
{
    word 0x3bc00000  # li      r30,0
    word 0x3f408053  # lis     r26,-32685
    word 0x635af20c  # ori     r26,r26,61964
    b %end%
}

HOOK @ $8117E7A4  # P+Ex sec7+0x274, replaces lhz     r5,66(r28)
{
    bl FLOATS_get
    mflr r12
    nop
    word 0x817c0004  # lwz     r11,4(r28)
    word 0x71600040  # andi.   r0,r11,64
    beq L290
    word 0x71600020  # andi.   r0,r11,32
    bne L2B8
L290:
    word 0x73a00040  # andi.   r0,r29,64
    bne L2AC
    word 0x73a00080  # andi.   r0,r29,128
    beq L308
    word 0x38c00064  # li      r6,100
    word 0xc02c0004  # lfs     f1,4(r12)
    b L2C0
L2AC:
    word 0x38c00000  # li      r6,0
    word 0xc02c0000  # lfs     f1,0(r12)
    b L2C0
L2B8:
    word 0x38c00028  # li      r6,40
    word 0xc02c0008  # lfs     f1,8(r12)
L2C0:
    word 0xd0210008  # stfs    f1,8(r1)
    word 0x809c0670  # lwz     r4,1648(r28)
    word 0xa07c0042  # lhz     r3,66(r28)
    word 0x5463103a  # slwi    r3,r3,2
    word 0x1c630004  # mulli   r3,r3,4
    word 0x3ca08053  # lis     r5,-32685
    word 0x60a5f20c  # ori     r5,r5,61964
    word 0x7ca32a14  # add     r5,r3,r5
    word 0x80a50000  # lwz     r5,0(r5)
    word 0x3c60805a  # lis     r3,-32678
    word 0x806301d8  # lwz     r3,472(r3)
    lis r12, 0x8007
    ori r12, r12, 0x8cd8
    mtctr r12
    bctrl
    word 0xc0210008  # lfs     f1,8(r1)
    word 0x7f83e378  # mr      r3,r28
    word 0xa09c0678  # lhz     r4,1656(r28)
    word 0x3884005c  # addi    r4,r4,92
    word 0x38a00009  # li      r5,9
    lis r12, 0x8117
    ori r12, r12, 0xa68c
    lwz r11, 0 (r12)            # vanilla bl to muProcMenu::setAnimFrame
    rlwinm r11, r11, 6, 0, 23   # \ branch offset, AA/LK dropped
    srawi r11, r11, 6           # /
    add r12, r12, r11
    mtctr r12
    bctrl
L308:
    word 0xa0bc0042  # lhz     r5,66(r28)
    b %end%
FLOATS_get:
    blrl
    word 0x42c80000  # b'B\xc8\x00\x00'
    word 0x00000000  # b'\x00\x00\x00\x00'
    word 0x42700000  # b'Bp\x00\x00'
}

HOOK @ $8117F030  # P+Ex sec7+0xe4, replaces rlwinm. r0,r29,0,22,22
{
    word 0x3c808000  # lis     r4,-32768
    word 0x60842810  # ori     r4,r4,10256
    word 0x80e40000  # lwz     r7,0(r4)
    word 0x2c070002  # cmpwi   r7,2
    bne L100
    rlwinm. r0, r29, 0, selectButton, selectButton  # P+Ex: Start (23)
    bne L108
L100:
    word 0x57a005ad  # rlwinm. r0,r29,0,22,22
    b %end%
L108:
    word 0x38e00003  # li      r7,3
    word 0x90e40000  # stw     r7,0(r4)
    word 0x2c000001  # cmpwi   r0,1
    b %end%
}

HOOK @ $8117F03C  # P+Ex sec7+0x148, replaces cmpwi   r0,0
{
    word 0x3d008000  # lis     r8,-32768
    word 0x61082810  # ori     r8,r8,10256
    word 0x80e80000  # lwz     r7,0(r8)
    word 0x2c070003  # cmpwi   r7,3
    bne L160
    word 0x38000000  # li      r0,0
L160:
    word 0x2c000000  # cmpwi   r0,0
    b %end%
}

HOOK @ $8117F060  # P+Ex sec7+0x168, replaces cmplw   r30,r0
{
    word 0x3d008000  # lis     r8,-32768
    word 0x61082810  # ori     r8,r8,10256
    word 0x80e80000  # lwz     r7,0(r8)
    word 0x2c070003  # cmpwi   r7,3
    bne L180
    word 0x38000000  # li      r0,0
L180:
    word 0x7c1e0040  # cmplw   r30,r0
    b %end%
}

HOOK @ $8117F07C  # P+Ex sec7+0x118, replaces li      r6,1
{
    word 0x38c00001  # li      r6,1
    word 0x3d008000  # lis     r8,-32768
    word 0x61082810  # ori     r8,r8,10256
    word 0x80e80000  # lwz     r7,0(r8)
    word 0x2c070003  # cmpwi   r7,3
    bne L144
    word 0x38e00004  # li      r7,4
    word 0x90e80000  # stw     r7,0(r8)
    word 0x3d008000  # lis     r8,-32768
    word 0x61082810  # ori     r8,r8,10256
    word 0x93c80008  # stw     r30,8(r8)
L144:
    b %end%
}

HOOK @ $8117F1D8  # P+Ex sec7+0x3b8, replaces slwi    r0,r8,2
{
    word 0x1c080010  # mulli   r0,r8,16
    word 0x3e408053  # lis     r18,-32685
    word 0x6252f20c  # ori     r18,r18,61964
    b %end%
    word 0x7c7f1b78  # mr      r31,r3
    word 0x81430054  # lwz     r10,84(r3)
    word 0x2c0a0001  # cmpwi   r10,1
    bne L404
    word 0x81430040  # lwz     r10,64(r3)
    word 0x2c0a0008  # cmpwi   r10,8
    bne L404
    word 0x3d60804e  # lis     r11,-32690
    word 0x858b0034  # lwzu    r12,52(r11)
    word 0x2c0c0004  # cmpwi   r12,4
    beq L404
    word 0x3d60804e  # lis     r11,-32690
    word 0x616b0034  # ori     r11,r11,52
    word 0x39800001  # li      r12,1
    word 0x918b0000  # stw     r12,0(r11)
L404:
    word 0x3d60804e  # lis     r11,-32690
    word 0x616b0040  # ori     r11,r11,64
    word 0x39800000  # li      r12,0
    word 0x918b0000  # stw     r12,0(r11)
    lis r12, 0x8119
    ori r12, r12, 0x96b0
    mtctr r12
    bctr
}

# In-place edits (Desi: My Music reads 0x10-byte TLST entries instead of the 0x698 song array)
CODE @ $8117DEE8
{
    word 0x3b200026  # li      r25,38
    word 0x93230670  # stw     r25,1648(r3)
    word 0x48000058  # b       0x8117df48
}
CODE @ $8117DF0C
{
    word 0x83240258  # lwz     r25,600(r4)
}
CODE @ $8117DF14
{
    word 0x3b200000  # li      r25,0
}
CODE @ $8117DF44
{
    word 0x5720103a  # slwi    r0,r25,2
}
CODE @ $8117DF80
{
    word 0x38000000  # li      r0,0
    word 0x93be06d4  # stw     r29,1748(r30)
    word 0x901e0670  # stw     r0,1648(r30)
    word 0x48000174  # b       0x8117e100
    word 0x3fa0805a  # lis     r29,-32678
    word 0x3b600000  # li      r27,0
    word 0x807d01d8  # lwz     r3,472(r29)
    word 0x3b800000  # li      r28,0
    word 0x83430014  # lwz     r26,20(r3)
    word 0x48000028  # b       0x8117dfcc
    word 0x807d01d8  # lwz     r3,472(r29)
    word 0x7f85e378  # mr      r5,r28
    word 0x38800004  # li      r4,4
    word 0x4aefadd9  # bl      0x80078d8c
    word 0x4aed19c1  # bl      0x8004f978
    word 0x28030001  # cmplwi  r3,1
    word 0x40820008  # bne     0x8117dfc8
    word 0x3b7b0001  # addi    r27,r27,1
    word 0x3b9c0001  # addi    r28,r28,1
    word 0x7c1cd040  # cmplw   r28,r26
    word 0x4180ffd8  # blt     0x8117dfa8
    word 0x937e0688  # stw     r27,1672(r30)
    word 0x3fa0805a  # lis     r29,-32678
    word 0x3b600000  # li      r27,0
    word 0x3b400000  # li      r26,0
    word 0x807d01d8  # lwz     r3,472(r29)
    word 0x83830018  # lwz     r28,24(r3)
    word 0x48000028  # b       0x8117e014
    word 0x807d01d8  # lwz     r3,472(r29)
    word 0x7f45d378  # mr      r5,r26
    word 0x38800005  # li      r4,5
    word 0x4aefad91  # bl      0x80078d8c
    word 0x4aed1979  # bl      0x8004f978
    word 0x28030001  # cmplwi  r3,1
    word 0x40820008  # bne     0x8117e010
    word 0x3b7b0001  # addi    r27,r27,1
    word 0x3b5a0001  # addi    r26,r26,1
    word 0x7c1ae040  # cmplw   r26,r28
    word 0x4180ffd8  # blt     0x8117dff0
    word 0x38000000  # li      r0,0
    word 0x937e068c  # stw     r27,1676(r30)
    word 0x3fa0805a  # lis     r29,-32678
    word 0x3b600000  # li      r27,0
    word 0x901e0684  # stw     r0,1668(r30)
    word 0x807d01d8  # lwz     r3,472(r29)
    word 0x80830014  # lwz     r4,20(r3)
    word 0x909e0684  # stw     r4,1668(r30)
    word 0x807d01d8  # lwz     r3,472(r29)
    word 0x80030018  # lwz     r0,24(r3)
    word 0x7c040214  # add     r0,r4,r0
    word 0x901e0684  # stw     r0,1668(r30)
    word 0x3c608054  # lis     r3,-32684
    word 0x8383f204  # lwz     r28,-3580(r3)
    word 0x48000044  # b       0x8117e098
    word 0x807d01d8  # lwz     r3,472(r29)
    word 0x7f65db78  # mr      r5,r27
    word 0x38800004  # li      r4,4
    word 0x4aefad29  # bl      0x80078d8c
    word 0x7c7a1b78  # mr      r26,r3
    word 0x4aed190d  # bl      0x8004f978
    word 0x2c030000  # cmpwi   r3,0
    word 0x41820020  # beq     0x8117e094
    word 0x801e06d4  # lwz     r0,1748(r30)
    word 0x5400103a  # slwi    r0,r0,2
    word 0x7c7e0214  # add     r3,r30,r0
    word 0x93430698  # stw     r26,1688(r3)
    word 0x807e06d4  # lwz     r3,1748(r30)
    word 0x38030001  # addi    r0,r3,1
    word 0x901e06d4  # stw     r0,1748(r30)
    word 0x3b7b0001  # addi    r27,r27,1
    word 0x7c1be040  # cmplw   r27,r28
    word 0x4180ffbc  # blt     0x8117e058
    word 0x3fa0805a  # lis     r29,-32678
    word 0x3b600000  # li      r27,0
    word 0x3c608054  # lis     r3,-32684
    word 0x8383f204  # lwz     r28,-3580(r3)
    word 0x48000044  # b       0x8117e0f4
    word 0x807d01d8  # lwz     r3,472(r29)
    word 0x7f65db78  # mr      r5,r27
    word 0x38800005  # li      r4,5
    word 0x4aefaccd  # bl      0x80078d8c
    word 0x7c7a1b78  # mr      r26,r3
    word 0x4aed18b1  # bl      0x8004f978
    word 0x2c030000  # cmpwi   r3,0
    word 0x41820020  # beq     0x8117e0f0
    word 0x801e06d4  # lwz     r0,1748(r30)
    word 0x5400103a  # slwi    r0,r0,2
    word 0x7c7e0214  # add     r3,r30,r0
    word 0x93430698  # stw     r26,1688(r3)
    word 0x807e06d4  # lwz     r3,1748(r30)
    word 0x38030001  # addi    r0,r3,1
    word 0x901e06d4  # stw     r0,1748(r30)
    word 0x3b7b0001  # addi    r27,r27,1
    word 0x7c1be040  # cmplw   r27,r28
    word 0x4180ffbc  # blt     0x8117e0b4
    word 0x480000a0  # b       0x8117e19c
    word 0x3c60805a  # lis     r3,-32678
    word 0x2c0000ff  # cmpwi   r0,255
    word 0x806301d8  # lwz     r3,472(r3)
    word 0x41800008  # blt     0x8117e114
    word 0x48000010  # b       0x8117e120
    word 0x5400103a  # slwi    r0,r0,2
    word 0x7c630214  # add     r3,r3,r0
    word 0x83a30004  # lwz     r29,4(r3)
    word 0x835e0670  # lwz     r26,1648(r30)
    word 0x3c60805a  # lis     r3,-32678
    word 0x93be0684  # stw     r29,1668(r30)
    word 0x2c1a00ff  # cmpwi   r26,255
    word 0x806301d8  # lwz     r3,472(r3)
    word 0x4180000c  # blt     0x8117e140
    word 0x3b600000  # li      r27,0
    word 0x48000010  # b       0x8117e14c
    word 0x3d808053  # lis     r12,-32685
    word 0x618cf200  # ori     r12,r12,61952
    word 0x836c0004  # lwz     r27,4(r12)
    word 0x3b200000  # li      r25,0
    word 0x3fa0805a  # lis     r29,-32678
    word 0x48000040  # b       0x8117e194
    word 0x807d01d8  # lwz     r3,472(r29)
    word 0x7f44d378  # mr      r4,r26
    word 0x7f25cb78  # mr      r5,r25
    word 0x4aefac29  # bl      0x80078d8c
    word 0x7c7c1b78  # mr      r28,r3
    word 0x4aed180d  # bl      0x8004f978
    word 0x2c030000  # cmpwi   r3,0
    word 0x4182001c  # beq     0x8117e190
    word 0x801e06d4  # lwz     r0,1748(r30)
    word 0x5400103a  # slwi    r0,r0,2
    word 0x7c7e0214  # add     r3,r30,r0
}
CODE @ $8117E198
{
    word 0x4180ffc0  # blt     0x8117e158
}
CODE @ $8117E698
{
    word 0x9421ff80  # stwu    r1,-128(r1)
}
CODE @ $8117E6A0
{
    word 0x90010084  # stw     r0,132(r1)
    word 0x39610080  # addi    r11,r1,128
    word 0x4b272c75  # bl      0x803f131c
}
CODE @ $8117E7AC
{
    word 0x1c050010  # mulli   r0,r5,16
    word 0x7c7a0214  # add     r3,r26,r0
}
CODE @ $8117E7B8
{
    word 0x83c30000  # lwz     r30,0(r3)
}
CODE @ $8117E84C
{
    word 0x1c060010  # mulli   r0,r6,16
}
CODE @ $8117E854
{
    word 0x7c7a0214  # add     r3,r26,r0
}
CODE @ $8117E85C
{
    word 0x80a30000  # lwz     r5,0(r3)
}
CODE @ $8117EB28
{
    word 0x1c060010  # mulli   r0,r6,16
}
CODE @ $8117EB30
{
    word 0x7c7a0214  # add     r3,r26,r0
}
CODE @ $8117EB38
{
    word 0x80a30000  # lwz     r5,0(r3)
}
CODE @ $8117EE0C
{
    word 0x1c060010  # mulli   r0,r6,16
    word 0x7c7a0214  # add     r3,r26,r0
}
CODE @ $8117EE18
{
    word 0x80a30000  # lwz     r5,0(r3)
}
CODE @ $8117EF44
{
    word 0x1c060010  # mulli   r0,r6,16
    word 0x7c7a0214  # add     r3,r26,r0
}
CODE @ $8117EF50
{
    word 0x80a30000  # lwz     r5,0(r3)
}
CODE @ $8117F0D0
{
    word 0x1cc00010  # mulli   r6,r0,16
}
CODE @ $8117F0D8
{
    word 0x7cda3214  # add     r6,r26,r6
}
CODE @ $8117F0E0
{
    word 0x80c60000  # lwz     r6,0(r6)
}
CODE @ $8117F168
{
    word 0x39610080  # addi    r11,r1,128
}
CODE @ $8117F170
{
    word 0x4b2721f9  # bl      0x803f1368
    word 0x80010084  # lwz     r0,132(r1)
}
CODE @ $8117F17C
{
    word 0x38210080  # addi    r1,r1,128
}
CODE @ $8117F1A4
{
    word 0x9421ff80  # stwu    r1,-128(r1)
}
CODE @ $8117F1AC
{
    word 0x90010084  # stw     r0,132(r1)
    word 0xdbe10070  # stfd    f31,112(r1)
    word 0xf3e10078  # xxsel   vs31,vs1,vs0,vs33
    word 0xdbc10060  # stfd    f30,96(r1)
    word 0xf3c10068  # psq_st  f30,104(r1),0,0
    word 0x39610060  # addi    r11,r1,96
    word 0x4b272139  # bl      0x803f12fc
}
CODE @ $8117F1E0
{
    word 0x7c920214  # add     r4,r18,r0
}
CODE @ $8117F1E8
{
    word 0x81240000  # lwz     r9,0(r4)
}
CODE @ $8117F2B4
{
    word 0x1c150010  # mulli   r0,r21,16
}
CODE @ $8117F2C4
{
    word 0x7f320214  # add     r25,r18,r0
}
CODE @ $8117F2E8
{
    word 0x80b90000  # lwz     r5,0(r25)
}
CODE @ $8117F408
{
    word 0x8073066c  # lwz     r3,1644(r19)
    word 0x3992fff4  # addi    r12,r18,-12
    word 0xa16c000a  # lhz     r11,10(r12)
    word 0xa159000a  # lhz     r10,10(r25)
    word 0x7d6b5214  # add     r11,r11,r10
    word 0x7cac5a14  # add     r5,r12,r11
    word 0x7ee4bb78  # mr      r4,r23
    word 0x4af39e0d  # bl      0x800b9230
}
CODE @ $8117F488
{
    word 0x3b390010  # addi    r25,r25,16
}
CODE @ $8117F49C
{
    word 0xe3e10078  # psq_l   f31,120(r1),0,0
    word 0xcbe10070  # lfd     f31,112(r1)
    word 0xe3c10068  # lq      r30,96(r1)
    word 0x39610060  # addi    r11,r1,96
    word 0xcbc10060  # lfd     f30,96(r1)
    word 0x4b271e99  # bl      0x803f1348
    word 0x80010084  # lwz     r0,132(r1)
}
CODE @ $8117F4BC
{
    word 0x38210080  # addi    r1,r1,128
}
* E0000000 80008000  # end if

# this hook makes sure we go back to SSS from My Music
HOOK @ $806b5670 # check if B is pressed on My Music screen
{
    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 4         # |
    bne done            # / if flag isn't 4, just do original code

    # this snippet makes it so we pause the frames while we return to SSS
    lis r3, 0x805A      # \ get gfApplication
    lwz r3, -0x54 (r3)  # | gfApplication stored in r3
    addi r3, r3, 0xD0   # | gfApplication + 0xD0 = gfKeepFrameBuffer stored in r3
    lis r12, 0x8002     # | call startKeepFrameBuffer (mislabled in symbol map)
    ori r12, r12 0x4e20 # |
    mtctr r12           # |
    bctrl               # /

    li r0, 0x200 # count as we are pressing B
    cmpwi r0, 0
    b %end%

    done:
    rlwinm. r0, r0, 0, 22, 22 # original line
}

# this hook makes it so the cursor doesn't display for a split second when backing out of My Music
HOOK @ $806b4290 # where we restore the cursor in selectingProc/[muSelectStageTask]
{
    lwz r3, 0x0050 (r27) # original line

    lis r4, 0x8000      # \
    ori r4, r4, 0x2810  # |
    lwz r4, 0 (r4)      # | get flag
    cmpwi r4, 4         # |
    bne %end%           # / if flag is not 4, just do original code

    lis r12, 0x806b     # jump to address after Insert call
    ori r12, r12, 0x42b0
    mtctr r12
    bctr
}

# these hooks make it so we don't play a second backing out sound when we back out from music selection
HOOK @ $806b567c # loading sound ID in buttonProc:muSelectStageTask (for My Music)
{
    li r4, 2            # original lines

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 4         # | check that flag is 4
    bne %end%           # / if not, end

    lis r12, 0x806b     # jump to address after playSE call
    ori r12, r12 0x5698
    mtctr r12
    bctr
}

# same as above, but for process:muMenuMain
HOOK @ $806cea08
{
    li r4, 2            # original lines

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 4         # | check that flag is 4
    bne %end%           # / if not, end

    lis r12, 0x806c     # jump to address after playSE call
    ori r12, r12 0xea24
    mtctr r12
    bctr
}

# this hook makes it so we play a normal confirmation sound instead of the stage select sound when opening the music select
HOOK @ $806b5cec # loading sound ID in buttonProc:muSelectStageTask (for SSS)
{
    li r4, 19 # original line

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 1         # | check that flag is 1
    bne %end%           # / if not, end

    # this snippet makes it so we pause the frames while we go to My Music, so that the "Ready to Fight" text doesn't display
    mr r9, r3
    lis r3, 0x805A      # \ get gfApplication
    lwz r3, -0x54 (r3)  # | gfApplication stored in r3
    addi r3, r3, 0xD0   # | gfApplication + 0xD0 = gfKeepFrameBuffer stored in r3
    lis r12, 0x8002     # | call startKeepScreen (mislabeled in symbol map)
    ori r12, r12 0x4e20 # |
    mtctr r12           # |
    bctrl               # /
    mr r3, r9

    li r4, 1 # play normal confirm sound instead
}

# this hook makes it so we play a normal confirmation sound instead of the stage select sound when opening the music select from ASL sub menu
HOOK @ $806b5e5c # loading sound ID in buttonProc:muSelectStageTask (for SSS from ASL sub menu)
{
    li r4, 19 # original line

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 1         # | check that flag is 1
    bne %end%           # / if not, end

    # this snippet makes it so we pause the frames while we go to My Music, so that the "Ready to Fight" text doesn't display
    mr r9, r3
    mr r8, r0
    lis r3, 0x805A      # \ get gfApplication
    lwz r3, -0x54 (r3)  # | gfApplication stored in r3
    addi r3, r3, 0xD0   # | gfApplication + 0xD0 = gfKeepFrameBuffer stored in r3
    lis r12, 0x8002     # | call startKeepScreen (mislabeled in symbol map)
    ori r12, r12 0x4e20 # |
    mtctr r12           # |
    bctrl               # /
    mr r3, r9
    mr r0, r8

    li r4, 1 # play normal confirm sound instead
}

# this hook makes it so we play the stage select sound when a song is selected
HOOK @ $806b53a0 # muSelectStageTask:randomProc - loading audience cheer sound
{
    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 7         # | check that flag is 7
    bne done            # / if not, end

    lwz r3, 0x01D0 (r31)    # \ set parameters for playSE
    li r4, 19               # | 19 is ID for stage select sound
    li r5, -1               # |
    li r6, 0                # |
    li r7, 0                # |
    li r8, -1               # |
    lis r12, 0x8007         # | call playSE
    ori r12, r12, 0x42B0    # |
    mtctr r12               # |
    bctrl                   # /

    lis r9, 0x8000          # \
    ori r9, r9, 0x2810      # |
    li r3, 0                # |
    stw r3, 0x0 (r9)        # / set flag to 0 - we are done

    done:
    lwz r3, 0x01D0 (r31) # original line
}

# this hook makes it so we don't play the audience cheer when opening the music select
HOOK @ $806b46bc # loading sound ID in selectingProc:muSelectStageTask (for SSS)
{
    li r4, 22 # original line

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 1         # | check that flag is 1
    bne %end%           # / if not, end

    lis r12, 0x806b     # jump to address after playSE call
    ori r12, r12, 0x46d4
    mtctr r12
    bctr
}

# this hook makes it so we don't play the audience cheer when opening the music select from ASL sub menu
HOOK @ $806b550c # loading sound ID in selectingProc:muSelectStageTask (for SSS with ASL sub menu)
{
    li r4, 22 # original line

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 1         # | check that flag is 1
    bne %end%           # / if not, end

    lis r12, 0x806b     # jump to address after playSE call
    ori r12, r12, 0x5524
    mtctr r12
    bctr
}

# macro for the code that sends us to My Music
.macro returnFromMyMusic(<register1>,<register2>)
{
    lis r5, 0x8000      # \
    ori r5, r5, 0x2810  # |
    lwz r10, 0 (r5)     # | get flag
    cmpwi r10, 5        # | if flag isn't 5 (returning from My Music), jump to end
    bne done            # /

    # otherwise, load SSS
    li <register1>, 0x5

    li r10, 6           # \
    stw r10, 0 (r5)     # / set our flag to 6

    mr r10, r3              # \ store r3
    %getSceneManager()      # | get scene manager
    mr r5, r3               # | put scene manager in r5
    mr r3, r10              # | restore r3
    li r10, 1               # | set flag to 1
    stw r10, 0x0284 (r5)    # / setting this flag to 1 will make it go to SSS

    done:
    stw <register1>, 0xc (<register2>) # original line
}

# this hook makes it so we go to SSS after backing out from My Music - VS
HOOK @ $806dcbc8 # when transitioning to VS, we set this to tell the game to go to SSS after mem change
{
    %returnFromMyMusic(r24, r15)
}

# this hook makes it so we go to SSS after backing out from My Music - Special
HOOK @ $806deb64 # when transitioning to Special, we set this to tell the game to go to SSS after mem change
{
    %returnFromMyMusic(r21, r30)
}

# this hook makes it so we go to SSS after backing out from My Music - Training
HOOK @ $806f15ac # when transitioning to Training, we set this to tell the game to go to SSS after mem change
{
    %returnFromMyMusic(r29, r15)
}

# this hook is used to ensure addresses correctly indicate we're on SSS after returning from My Music
HOOK @ $806be64c # runs every frame on process/[scMemoryChange]
{
    lis r5, 0x8000      # \
    ori r5, r5, 0x2810  # |
    lwz r10, 0 (r5)     # | get flag
    cmpwi r10, 6        # | if flag isn't 6, go to end
    bne done            # /

    li r10, 7           # \
    stw r10, 0 (r5)     # / set our flag to 7 - set pages

    li r0, 1            # this flag indicates what screen we're on after this, 1 in this case means SSS
    b %end%

    done:
    li r0, 0 # original line
}

# this hook checks if we are changing pages, and if so, doesn't set the flag to go to music select
HOOK @ $806b58d0 # just after checking if we are changing pages
{
    lis r5, 0x8000      # \
    ori r5, r5, 0x2810  # |
    lwz r10, 0 (r5)
    cmpwi r10, 1        # if flag is not 1, go to end
    bne done

    li r10, 0           # \
    stw r10, 0 (r5)     # / set our flag to 0 - we changed pages, didn't select a stage

    done:
    lis r3, 0x806C # original line
}

# this hook forces the song ID to be the one we selected
HOOK @ $8010f9e4 # hook just before calling setBgmId when loading stage
{
    lis r10, 0x8000         # \
    ori r10, r10, 0x2810    # |
    lwz r7, 0x8 (r10)       # | get song ID
    cmpwi r7, 0             # |
    beq done                # / if stored song ID is set to 0, jump to original line

    mr r6, r7               # set r6 (param4 for setBgmId) to song ID, which will force it to be picked
    li r7, 0
    stw r7, 0x8 (r10)       # set stored song ID to 0

    done:
    mr r4, r28 # original line
}

# this hook forces the match to start when returning from My Music and also retrieves hidden alts
HOOK @ $806b42d4 # muSelectStageTask:selectingProc - when we check if a button is pressed
{
    lis r8, 0x8000          # \
    ori r8, r8, 0x2810      # |
    lwz r9, 0x0 (r8)        # | get flag
    cmpwi r9, 7             # |
    bne done                # / if flag is not 7, jump to original line

    # Retrieve hidden alts
    %retrieveHiddenAlt(0x0b40, 0x2830)
    %retrieveHiddenAlt(0x0b9C, 0x2834)
    %retrieveHiddenAlt(0x0bf8, 0x2838)
    %retrieveHiddenAlt(0x0c54, 0x283C)

    li r3, 3    # setting to 3 forces us to random

    done:
    cmpwi r3, 2 # original line
}

# this hook forces random to pick our stage if returning from My Music
HOOK @ $806b4bd8 # muSelectStageTask:selectingProc - after we set all IDs for random
{
    lis r5, 0x8000          # \
    ori r5, r5, 0x2810      # |
    lwz r4, 0x0 (r5)        # | get flag
    cmpwi r4, 7             # |
    bne done                # / if flag is not 7, jump to original line

    lis r4, 0x805a          # \ load the chosen stage ID instead of a default
    lwz r4, 0xE0 (r4)       # | 0x805a00e0 - GameGlobal
    lwz r4, 0x14 (r4)       # | offset 0x14 - gmSelStageData
    lhz r4, 0x22 (r4)       # | offset 0x22 - stage ID
    stw r4, 0x0258 (r27)    # / r27 is muSelectStageTask, offset 258 is selectedId

    lwz r4, 0x10 (r5)
    stw r4, 0x0254 (r27)    # offset 254 is selectedType

    lbz r3, 0x14 (r5)
    lis r4, 0x8049          # \ Store page number for P+ stage system
    ori r4, r4, 0x6000      # |
    stb r3, 0 (r4)          # /

    cmpwi r3, 0x2           # \ if page is >= 2, set it to 0, to prevent issues with P+ stage system
    blt setPage             # |
    li r3, 0x0              # |
    setPage:                # |
    stw r3, 0x6154 (r27)    # / offset 6154 is page in vBrawl

    setIndex:
    lwz r4, 0xC (r5)
    stw r4, 0x6158 (r27)    # offset 6158 is index

    mr r10, r0              # store r0
    lis r12, 0x806b         # \ call MuStageTblAccess_GetStageKind
    ori r12, r12, 0x8f50    # |
    mtctr r12               # |
    bctrl                   # | stageKind placed in r3
    stw r4, 0x615C (r27)    # / offset 615C is stageKind

    mr r0, r10              # restore r0

    done:
    stw r0, 0x0224 (r27) # original line, sets state
}

# this hook is to make it so that the stage is NOT automatically picked if we back out from My Music
HOOK @ $806b533c # muSelectStageTask:randomProc - when we check muSelectStageTask:setting
{
    lis r3, 0x8000          # \
    ori r3, r3, 0x2810      # |
    lwz r5, 0x0 (r3)        # | get flag
    cmpwi r5, 7             # |
    bne done                # / if flag is not 7, jump to original line

    lwz r5, 0x8 (r3)        # \ get song ID
    cmpwi r5, 0             # |
    bne done                # / if stored song ID is not 0, we chose a song, so continue as normal

    li r5, 0                # \ set muSelectStageTask:setting to 0
    stw r5, 0x40 (r31)      # / offset 0x40 is setting

    li r5, 0                # \ set muSelectStageTask:state to 0 - stage not selected yet
    stw r5, 0x224 (r31)     # / offset 0x224 is state

    li r0, 2                # force r0 for comparison, so we skip the stage selecting code

    done:
    cmpwi r0, 2 # original line
}

# this hook is to make it stages aren't deselected when backing out of My Music after selecting a stage on pages after the first
HOOK @ $806b6000 # muSelectStageTask:buttonProc - immediately after checking for page change
{
    lis r3, 0x8000          # \
    ori r3, r3, 0x2810      # |
    lwz r5, 0x0 (r3)        # | get flag
    cmpwi r5, 7             # |
    bne done                # / if flag is not 7, jump to original line

    lwz r5, 0x250 (r29)     # \ 0x250 is frame count
    cmpwi r5, 12            # |
    blt done                # / only perform code if SSS has been up for 12 frames

    # set cursor position, just so stage gets highlighted even if it was removed by page change
    lwz r5, 0x200 (r29)     # \ 0x200 is cursor pointer
    lfs f4, 0x3C (r5)       # | offset 0x3C is cursor X position
    stfs f4, 0x3C (r5)      # / set cursor X position

    lfs f4, 0x40 (r5)       # \ 0x40 is cursor Y position
    stfs f4, 0x40 (r5)      # / set cursor Y position

    %cleanup(r5,r3)         # reset all stored values to 0

    done:
    mr r3, r31 # original line
}

# this hook resets all of our stored values when we return to the main menu
HOOK @ $806dce4c # hook in sqVsMelee/setNext when we are changing to main menu
{
    lis r5, 0x8000      # \
    ori r5, r5, 0x2810  # |
    lwz r6, 0 (r5)      # |
    cmpwi r6, 1         # | if flag is 1 (going to My Music), jump to end
    beq done            # /

    %cleanup(r7,r5)     # reset all stored values to 0

    done:
    stb	r30, 0x0448 (r3) # original line
}

# fixes the code not working on expansion stages if build doesn't have salty runback fix
op NOP @ $8010F9C0

####################################################
CSS Selections Preserved in Special Versus [Squidgy]
####################################################
op nop @ $806de9e8 # nop so we always enter the if

# needs this so rules settings don't break
HOOK @ $806de9f0 # set all necessary values
{
    stw	r0, 0x0008 (r31) # original line
    stw r0, 0x11 (r31)
}

op nop @ $806de9f4 # nop so we still set up SSS stuff, normally it would skip it when we go in the if

# this sets up the SSS stuff
HOOK @ $806dea1c
{
    stw r3, -0x5B08 (r4) # original line, sets SSS stuff

    lis r12, 0x806d     # jump to address to end function
    ori r12, r12 0xea34
    mtctr r12
    bctr
}

###################################################################
Only Reset Team Setting Upon Entering Training [Squidgy, Kapedani]
###################################################################
.alias g_GameGlobal                         = 0x805a00E0

.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}

CODE @ $806f14d0  # sqTraining::start
{
    %lwd(r12, g_GameGlobal)
    lwz r12, 0x10(r12)
    li r11, 0x0
    stb r11, 0x33(r12)
}
