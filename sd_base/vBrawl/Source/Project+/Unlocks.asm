####################################################
All Characters Unlock Checks Are Unlocked [Kapedani]
####################################################
CODE @ $8004f4a0  # gmCheckChKindUseEnable
{
  li r3, 0x1 
  blr
}

CODE @ $8004f654  # gmCheckChKindUseEnableAll
{
  li r3, 0x1 
  blr 
}

###############################################
All Target Smash Levels are Unlocked [Kapedani]
###############################################
CODE @ $806838e8  # muSelCharTask::initProc
{
  nop 
  li r0, 5
}

#########################################################################
More Rules & Random Stage Switch are Selectable without Unlocking [Magus]
#########################################################################
op li r3, 1 @ $8004E818
op li r3, 1 @ $8004E83C

######################################################################
All Stages Selectable on Random Stage Switch without Unlocking [Magus]
######################################################################
op li r0, 0xFFF @ $806AB860
op li r0, 0xFFF @ $806AB8DC

######################################################
All-Star Mode is Selectable without Unlocking [Spigel]
######################################################
op li, r3, 1 @ $8004E7D0

##########################################################
Boss Battles Mode is Selectable without Unlocking [Spigel]
##########################################################
op li, r3, 1 @ $8004E7F4

Unlock all Characters [eric]
* 42000000 90000000
* 0417B640 FFFFFFFF
* 0417B644 FFFFFFFF

Unlock all Stages [eric]
* 42000000 90000000
* 0417B658 FFFFFFFF
 
Have all Trophies [eric]
* 42000000 90000000
* 0817BE80 80638063
* 21100004 00000000

Have all Stickers [eric]
* 42000000 90000000
* 0817C398 80638063
* 215D0004 00000000
 
Have all Challenge Data [eric]
* 42000000 90000000
* 0817CB68 02020202
* 201F0004 00000000