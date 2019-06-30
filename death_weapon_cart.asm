;
; CARTRIDGE BUILDER
;

; Select an output filename
		!to "death_weapon.crt",plain

; Labels
code_read	= $50		; source address for code transfer - $02 bytes used
code_write	= $52		; target address for code transfer - $02 bytes used

; Set up the cartridge header data
		* = $7fb0
		!scr "C64 CARTRIDGE   "
		!byte $00,$00				; header length
		!byte $00,$40				; header length

		!word $0001				; version

		!word $0000				; crt type
		!byte $00				; extrom line
		!byte $00				; game line

		!byte $00,$00,$00,$00,$00,$00		; unused

		!scr "DEATH WEAPON -- T.M.R/C64CD 2019"	; $20 bytes

; Chip packet
		!scr "CHIP"
		!byte $00,$00,$40,$10   ; chip length
		!byte $00,$00		; chip type
		!byte $00,$00		; bank
		!byte $80,$00		; adress
		!byte $40,$00		; length


; Code origin - cold/warm start vectors for the cartridge and CBM80
		* = $8000

		!word cart_boot
		!word cart_boot
		!byte $c3,$c2,$cd,$38,$30

; Code entry point
cart_boot	sei

; Sort-of cold start
		jsr $fda3
		jsr $fd15
		jsr $ff5b

; Set a couple of video registers
		lda #$00
		sta $d020
		sta $d021

		lda #$1b
		sta $d011

		lda #$17
		sta $d018

; Zero the colour RAM
		ldx #$00
		txa
colour_clear	sta $d800,x
		sta $d900,x
		sta $da00,x
		sta $dae8,x
		inx
		bne colour_clear

; Position the "please wait" message
		ldx #$00
wait_write	lda pw_text,x
		sta $07db,x
		lda #$0c
		sta $dbdb,x
		inx
		cpx #$0b
		bne wait_write

; Set up the code copier loop
		lda #<crunched_game
		sta code_read+$00
		lda #>crunched_game
		sta code_read+$01

		lda #$00
		sta code_write+$00
		lda #$08
		sta code_write+$01

; Move the compressed game code down to $0801
copy_game	ldy #$00
copy_game_loop	lda (code_read),y
		sta (code_write),y

		inc code_read+$00
		bne *+$04
		inc code_read+$01

		inc code_write+$00
		bne *+$04
		inc code_write+$01

; Check to see if the code copy is done
		lda code_read+$01
		cmp #$c0
		bne copy_game

; If it's all moved, start the game up
		jmp $080d

; Please wait text
pw_text		!scr "Please wait"

; Include the binary data for the game itself and...
crunched_game	!byte $00
		!bin "death_weapon_exo.prg",,2

; ...pad the remaining ROM space to make it 16K
		* = $bfff
		!byte $00
