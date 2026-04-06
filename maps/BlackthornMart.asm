	object_const_def
	const BLACKTHORNMART_CLERK
	const BLACKTHORNMART_COOLTRAINER_M
	const BLACKTHORNMART_BLACK_BELT
	const BLACKTHORNMART_TM_VENDOR

BlackthornMart_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_OBJECTS, BlackthornMartTMVendorCallback

BlackthornMartTMVendorCallback:
	checkflag ENGINE_TM_VENDOR_ENABLED
	iftrue .show
	disappear BLACKTHORNMART_TM_VENDOR
	endcallback
.show
	appear BLACKTHORNMART_TM_VENDOR
	endcallback

BlackthornMartClerkScript:
	opentext
	pokemart MARTTYPE_STANDARD, MART_BLACKTHORN
	closetext
	end

BlackthornMartCooltrainerMScript:
	jumptextfaceplayer BlackthornMartCooltrainerMText

BlackthornMartBlackBeltScript:
	jumptextfaceplayer BlackthornMartBlackBeltText

BlackthornMartTMVendorScript:
	faceplayer
	opentext
	writetext BlackthornMartTMVendorIntroText
	waitbutton
.loop
	special TMVendorGroupSelect
	ifequal 0, .Cancel
	ifequal 1, .TM01to10
	ifequal 2, .TM11to20
	ifequal 3, .TM21to30
	ifequal 4, .TM31to40
	ifequal 5, .TM41to50
	ifequal 6, .TM51to60
	ifequal 7, .TM61to66
	sjump .loop
.Cancel
	closetext
	end
.TM01to10
	pokemart MARTTYPE_STANDARD, MART_TM_VENDOR_1
	sjump .loop
.TM11to20
	pokemart MARTTYPE_STANDARD, MART_TM_VENDOR_2
	sjump .loop
.TM21to30
	pokemart MARTTYPE_STANDARD, MART_TM_VENDOR_3
	sjump .loop
.TM31to40
	pokemart MARTTYPE_STANDARD, MART_TM_VENDOR_4
	sjump .loop
.TM41to50
	pokemart MARTTYPE_STANDARD, MART_TM_VENDOR_5
	sjump .loop
.TM51to60
	pokemart MARTTYPE_STANDARD, MART_TM_VENDOR_6
	sjump .loop
.TM61to66
	pokemart MARTTYPE_STANDARD, MART_TM_VENDOR_7
	sjump .loop

BlackthornMartTMVendorIntroText:
	text "I sell all the"
	line "TMs there are."

	para "Which group are"
	line "you looking for?"
	done

BlackthornMartCooltrainerMText:
	text "You can't buy MAX"
	line "REVIVE, but it"

	para "fully restores a"
	line "fainted #MON."

	para "Beware--it won't"
	line "restore PP, the"

	para "POWER POINTS"
	line "needed for moves."
	done

BlackthornMartBlackBeltText:
	text "MAX REPEL keeps"
	line "weak #MON away"
	cont "from you."

	para "It's the longest"
	line "lasting of the"
	cont "REPEL sprays."
	done

BlackthornMart_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, BLACKTHORN_CITY, 4
	warp_event  3,  7, BLACKTHORN_CITY, 4

	def_coord_events

	def_bg_events

	def_object_events
	object_event  1,  3, SPRITE_CLERK, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, BlackthornMartClerkScript, -1
	object_event  7,  6, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, BlackthornMartCooltrainerMScript, -1
	object_event  5,  2, SPRITE_BLACK_BELT, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, BlackthornMartBlackBeltScript, -1
	object_event  2,  5, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, BlackthornMartTMVendorScript, EVENT_BLACKTHORN_MART_TM_VENDOR
