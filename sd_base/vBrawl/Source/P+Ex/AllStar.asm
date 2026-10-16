
##################################################################
Stock Rule Ignores "Removed" State (keeps swapping player in) [P+]
##################################################################
# From P+ 3.2 AllStarVs.asm (applied there unconditionally).
# checkStockCountRule / getTeamTotalStock skip any player whose rule-state byte (+0x25) is 3.
# Swapping characters (debug mode / code menu) briefly removes the fighter, which marks
# that player 3, so a 2-player stock match ends instantly. Counting players by stocks only
# keeps them in; eliminated players and empty ports still drop out (0 stocks).
op nop @ $8095506C	# checkStockCountRule: beq skip-if-state-3 (FFA stock)
op nop @ $80957DEC	# getTeamTotalStock:   beq skip-if-state-3 (team stock)
