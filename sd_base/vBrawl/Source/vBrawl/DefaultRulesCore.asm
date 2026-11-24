# Shared body for Default Settings Modifier [Igglyboo, Brkirch, and FMK].
# Included by Source/vBrawl/DefaultRules.asm (offline, RSBE01.txt) and
# Source/Netplay/Net-DefaultRules.asm (netplay, NETPLAY.txt), which define the rule aliases.
#
# Same logic as the original Gecko code:
#   * 24494A98 80000000   if [80494A98] > 0x80000000   (game globals are set up)
#   * 20523300 00000000   if [80523300] == 0           (not applied yet this boot)
#   * 04523300 DEADBEEF   mark as applied
#   * 42000000 90000000   \ write the default rules to the gmSetRule at 9017F360
#   * 0417F360 ...        /  (g_GameGlobal->m_setRule)
# written as a C0 code so every field is a named value.

.alias SET_RULE_HI      = 0x9017   # \ gmSetRule at 9017F360
.alias SET_RULE_LO      = 0xF360   # /
.alias APPLIED_FLAG_HI  = 0x8052   # \ 80523300: 0 at boot, DEADBEEF once applied
.alias APPLIED_FLAG_LO  = 0x3300   # /
.alias GLOBALS_READY_HI = 0x8049   # \ 80494A98: must hold a valid pointer (> 0x80000000)
.alias GLOBALS_READY_LO = 0x4A98   # /

# gmSetRule field offsets
.alias RULE_GAME_TYPE    = 0x02     # _1:5 (kept 0) | m_rule:3
.alias RULE_TIME         = 0x03
.alias RULE_STOCK        = 0x04
.alias RULE_HANDICAP     = 0x05
.alias RULE_DAMAGE_RATIO = 0x06
.alias RULE_STAGE_CHOICE = 0x07
.alias RULE_STOCK_TIME   = 0x08
.alias RULE_TEAM_ATTACK  = 0x09
.alias RULE_PAUSE        = 0x0A
.alias RULE_SCORE        = 0x0B
.alias RULE_DAMAGE_GAUGE = 0x0C

.macro setRule(<offset>, <value>)
{
    li r12, <value>
    stb r12, <offset> (r11)
}

PULSE
{
    lis r12, GLOBALS_READY_HI           # \ if [80494A98] > 0x80000000 (unsigned)
    lwz r12, GLOBALS_READY_LO (r12)     # |
    lis r11, 0x8000                     # |
    cmplw r12, r11                      # |
    ble done                            # /

    lis r12, APPLIED_FLAG_HI            # \ if [80523300] == 0
    lwz r11, APPLIED_FLAG_LO (r12)      # |
    cmpwi r11, 0                        # |
    bne done                            # /
    lis r11, 0xDEAD                     # \ [80523300] = DEADBEEF
    ori r11, r11, 0xBEEF                # |
    stw r11, APPLIED_FLAG_LO (r12)      # /

    lis r11, SET_RULE_HI                # \ r11 = gmSetRule
    ori r11, r11, SET_RULE_LO           # /
    li r12, 0                           # \ padding the original code also cleared
    sth r12, 0x00 (r11)                 # | (+0x00..+0x01, +0x0D..+0x0F)
    stb r12, 0x0D (r11)                 # |
    sth r12, 0x0E (r11)                 # /

    %setRule(RULE_GAME_TYPE,    GAME_TYPE)
    %setRule(RULE_TIME,         TIME_MINUTES)
    %setRule(RULE_STOCK,        STOCK_COUNT)
    %setRule(RULE_HANDICAP,     HANDICAP)
    %setRule(RULE_DAMAGE_RATIO, DAMAGE_RATIO)
    %setRule(RULE_STAGE_CHOICE, STAGE_CHOICE)
    %setRule(RULE_STOCK_TIME,   STOCK_TIME_LIMIT)
    %setRule(RULE_TEAM_ATTACK,  TEAM_ATTACK)
    %setRule(RULE_PAUSE,        ALLOW_PAUSE)
    %setRule(RULE_SCORE,        SHOW_SCORE)
    %setRule(RULE_DAMAGE_GAUGE, SHOW_DAMAGE_GAUGE)
done:
    blr
}
