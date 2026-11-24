##########################################################################
Default Settings Modifier (Netplay) [Igglyboo, Brkirch, and FMK]
##########################################################################
# Offline values live in Source/vBrawl/DefaultRules.asm.
# Applied once per boot; Rules menu changes stick for the session.

.alias GAME_TYPE         = 1    # 0=Timed  1=Stock  2=Coin
.alias TIME_MINUTES      = 8    # time/coin match duration
.alias STOCK_COUNT       = 3
.alias HANDICAP          = 0    # 0=Off  1=Auto  2=On
.alias DAMAGE_RATIO      = 10   # ratio * 10 (10 = 1.0x)
.alias STAGE_CHOICE      = 0    # 0=Choose  1=Random  2=Turns  3=Ordered  4=Loser's Pick
.alias STOCK_TIME_LIMIT  = 8    # stock match time limit in minutes (0 = infinite)
.alias TEAM_ATTACK       = 1    # 0=Off  1=On
.alias ALLOW_PAUSE       = 0    # 0=Off  1=On
.alias SHOW_SCORE        = 0    # 0=Off  1=On (timed matches only)
.alias SHOW_DAMAGE_GAUGE = 1    # 0=Off  1=On

.include Source/vBrawl/DefaultRulesCore.asm
