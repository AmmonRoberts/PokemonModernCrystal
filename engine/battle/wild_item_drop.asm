_RollWildHeldItem::
; Rolls the item a wild Pokemon carries at the start of battle.
; Result written directly to wEnemyMonItem (farcall doesn't preserve a).
; Odds: 75% NO_ITEM / 23% Item1 / 2% Item2.
	call BattleRandom
	cp 75 percent + 1
	jr nc, .roll_item2  ; >= 25%: give item
	xor a               ; NO_ITEM
	ld [wEnemyMonItem], a
	ret
.roll_item2:
	call BattleRandom
	cp 8 percent        ; 8% of 25% = 2% Item2
	ld a, [wBaseItem1]
	jr nc, .done        ; Item1 on most rolls
	ld a, [wBaseItem2]
.done:
	ld [wEnemyMonItem], a
	ret

_TryDropWildItemCore::
; If MODFLAG_WILD_ITEM_DROP_F is set and the wild #MON held an item,
; add that item to the player's bag (or PC if the bag is full).
; Called via farcall from TryDropWildItem (home bank).
	ld a, [wModFlags]
	bit MODFLAG_WILD_ITEM_DROP_F, a
	ret z
	ld a, [wEnemyMonItem]
	and a                         ; NO_ITEM = 0
	ret z
	ld [wCurItem], a
	ld [wNamedObjectIndex], a
	call GetItemName              ; puts item name into wStringBuffer1
	ld a, 1
	ld [wItemQuantityChange], a
	ld hl, wNumItems
	call ReceiveItem              ; try bag first
	jr c, .got_bag
	ld hl, wNumPCItems
	call ReceiveItem              ; bag full — try PC
	jr c, .got_pc
	ld hl, BattleText_WildItemDropFull ; bag and PC both full — notify
	jp StdBattleTextbox
.got_bag:
	ld hl, BattleText_WildItemDropBag
	jp StdBattleTextbox
.got_pc:
	ld hl, BattleText_WildItemDropPC
	jp StdBattleTextbox
