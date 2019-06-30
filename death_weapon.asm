;
; DEATH WEAPON
;

; Programming, graphics, sound and assorted crimes against humanity
; by Jason

; Cheat mode - $00 is normal game, $01 stops the player losing
cheat		= $00


; A simple single screen shoot 'em up with tile-compressed
; backgrounds and waves of enemies which materialise "randomly" in
; the play area.

; Coded for C64CrapDebunk.Wordpress.com, released for the RGCD
; Cartridge Competition 2019

; Notes: this source is formatted for the ACME cross assembler from
; http://sourceforge.net/projects/acme-crossass/
; Compression is handled with Exomizer 2 which can be downloaded at
; http://hem.bredband.net/magli143/exo/

; build.bat will call both to create an assembled file, crunch it
; and bolt on the cartridge header of the release version.


; Select an output filename
		!to "death_weapon.prg",cbm


; Pull in the binary data
		* = $1000
music		!binary "binary\music.prg",,2

		* = $2000
char_set	!binary "binary\background.chr"

		* = $2800
		!binary "binary\sprites.spr"


; Raster split positions
raster_1_pos	= $00
raster_2_pos	= $39
raster_3_pos	= $67
raster_4_pos	= $f2

; Label assignments
raster_num	= $50		; raster split counter
sync		= $51		; raster sync for runtime code
rt_store_1	= $52		; temporary store for runtime code
counter		= $53		; general purpose counter

music_enable	= $54		; is the music enabled?
sfx_enable	= $55		; are the sound effects enabled?

d021_mirror	= $56		; value for $d021 at the top of the screen
d022_mirror	= $57		; value for $d022 at the top of the screen
d023_mirror	= $58		; value for $d023 at the top of the screen
d025_mirror	= $59		; value for $d025 at the top of the screen

pulse_timer	= $5a		; counter for various text colour effects

ctrl_buffer	= $5b		; current joystick value
fire_direction	= $5c		; player's firing direction

flicker_count	= $5d		; used for various sprite flicker events

titles_flag	= $5e		; is titles mode active?

; Labels for the player's status
player_score	= $60		; $06 bytes used - player's score
score_bonus	= $66		; value for adding to the player's score

player_bonus	= $67		; $05 bytes used - level bonus

player_lives	= $6c		; player's remaining lives
player_shield	= $6d		; player's shield (for after respanws)

player_d_flag	= $6e		; player death flag

player_level	= $6f		; current level counter
player_quota	= $70		; $03 bytes used - current level's enemy quota

; Labels for the player's bullets
bullet_x	= $80		; $02 bytes used - bullet sprite X positions
bullet_y	= $82		; $02 bytes used - bullet sprite Y positions
bullet_dir	= $84		; $02 bytes used - bullet sprite directions
bullet_active	= $86		; $02 bytes used - bullet sprite status bytes
bullet_colour	= $88		; $02 bytes used - bullet sprite colours

bullet_timer	= $8a		; timer, used to stop all the bullets firing at once
bull_col_count	= $8b		; used to count which colour the bullet will be

; Position in memory of the current level's data
level_read	= $8e		; $02 bytes used

; Labels for the enemies
random_x_count	= $90		; current position in the X random table
random_y_count	= $91		; current position in the Y random table

wave_spawn_tmr	= $92		; timer counting down to the next enemy spawn
wave_spawn_spd	= $93		; current level's spawn speed

wave_active	= $94		; flag to say if the wave engine is active
wave_quota	= $95		; counts down until the next wave

coll_temp	= $96		; $04 bytes used - collision work space

; Labels for the background display code
tile_read	= $9a		; $02 bytes used - position in tile being read
tile_write	= $9c		; $02 bytes used - where we're writing to the screen
tile_count	= $9e		; how many tiles have been rendered so far

; Labels for the starfield
star_pos	= $a0		; $08 bytes used - position of stars
star_x_fast	= $a8		; $04 bytes used - X position of faster stars
star_y_fast	= $ac		; $04 bytes used - Y position of faster stars
star_x_slow	= $b0		; $04 bytes used - X position of slower stars
star_y_slow	= $b4		; $04 bytes used - Y position of slower stars

star_dir	= $b8		; direction of starfield


; Sprite position workspace
sprite_x	= $0340		; $08 bytes used - sprite X co-ordinates
sprite_y	= $0348		; $08 bytes used - sprite Y co-ordinates

sprite_status	= $0350		; $08 bytes used - sprite status bytes

sprite_col	= $0358		; $08 bytes used - sprite colours

sprite_dp	= $0370		; $08 bytes used - sprite data pointers
anim_start	= $0378		; $08 bytes used - sprite animation start frames
anim_end	= $0380		; $08 bytes used - sprite animation end frames

anim_timer	= $0388		; sprite animation timer

; Enemy speed, state and timer labels
enemy_x_speeds	= $0390		; $06 bytes used - enemy sprite X speeds
enemy_y_speeds	= $0396		; $06 bytes used - enemy sprite Y speeds
enemy_state	= $039c		; $06 bytes used - enemy sprite states
enemy_timer	= $03a2		; $06 bytes used - enemy sprite X timers

; Attack wave handler's labels
wave_x_speed_1	= $03b0		; current wave - X speed
wave_y_speed_1	= $03b1		; current wave - Y speed

wave_colour	= $03b2		; current wave - colour

wave_anim_start	= $03b3		; current wave - anim start
wave_anim_end	= $03b4		; current wave - anim end

pulse_buffer	= $03e0		; $10 bytes used - store space for text colours


; Where to find the screen, buffer and colour RAM
screen_ram	= $0400		; main screen memory
buffer_ram	= $0800		; back buffer (copy of the screen for the starfield)
colour_ram	= $d800		; colour memory


; Entry point for the code
		* = $4000

; Stop interrupts, disable the ROMS and set up NMI and IRQ interrupt pointers
code_start	sei

		lda #$35
		sta $01

		lda #<nmi_int
		sta $fffa
		lda #>nmi_int
		sta $fffb

		lda #<irq_int
		sta $fffe
		lda #>irq_int
		sta $ffff

; Set the VIC-II up for a raster IRQ interrupt
		lda #$7f
		sta $dc0d
		sta $dd0d

		lda $dc0d
		lda $dd0d

		lda #raster_1_pos
		sta $d012

		lda #$0b
		sta $d011
		lda #$01
		sta $d019
		sta $d01a

; Clear the playfield
		ldx #$00
		txa
screen_init	sta screen_ram+$000,x
		sta screen_ram+$100,x
		sta screen_ram+$200,x
		sta screen_ram+$2e8,x

		sta colour_ram+$000,x
		sta colour_ram+$100,x
		sta colour_ram+$200,x
		sta colour_ram+$2e8,x
		inx
		bne screen_init

; Clear the label spaces in zero page and the tape buffer
		ldx #$50
		lda #$00
nuke_zp		sta $00,x
		inx
		bne nuke_zp

		ldx #$40
		lda #$00
nuke_tape	sta $0300,x
		inx
		bne nuke_tape

; Initialise some of our own labels
		lda #$01
		sta raster_num

		lda #$01
		sta music_enable
		sta sfx_enable

; Quick init of the starfield
		ldx #$00
star_init	lda star_pos_dflt,x
		sta star_pos,x
		inx
		cpx #$08
		bne star_init

; Set up music driver for a blank tune
		lda #$03
		jsr music+$00

; Restart the interrupts
		cli

; Titles page initialisation code
titles_init

; Pick a random level for the titles page backgrounde
		lda random_x_count
		and #$03
		asl
		tax

		lda level_starts+$00,x
		sta level_read+$00
		lda level_starts+$01,x
		sta level_read+$01

		jsr level_init

; Zero the level's quota
		lda #$00
		sta player_quota+$00
		sta player_quota+$01
		sta player_quota+$02

; Turn on titles mode (so the third interrupt displays "weapon")
		lda #$01
		sta titles_flag

; Check if the highscore needs updating before we display it
		jsr highscore_scan

; Initialise the status bar
		jsr status_set
		jsr status_update

; Put up a box for the credits and sound options
		ldx #$00
t_text_box	lda #$2d
		sta screen_ram+$230,x
		sta buffer_ram+$230,x
		lda #$09
		sta colour_ram+$230,x

		lda #$20
		sta screen_ram+$258,x
		sta buffer_ram+$258,x

		sta screen_ram+$280,x
		sta buffer_ram+$280,x

		sta screen_ram+$2a8,x
		sta buffer_ram+$2a8,x

		sta screen_ram+$2d0,x
		sta buffer_ram+$2d0,x

		sta screen_ram+$2f8,x
		sta buffer_ram+$2f8,x

		sta screen_ram+$320,x
		sta buffer_ram+$320,x

		sta screen_ram+$348,x
		sta buffer_ram+$348,x

		lda #$42
		sta screen_ram+$370,x
		sta buffer_ram+$370,x
		lda #$0f
		sta colour_ram+$370,x

		inx
		cpx #$28
		bne t_text_box

; Set up the credits text - line 1
		ldx #$00
t_text_copy_1	ldy t_text_1,x
		lda char_decode,y
		sta screen_ram+$281,x
		sta buffer_ram+$281,x
		lda #$03
		sta colour_ram+$281,x

		inx
		cpx #$26
		bne t_text_copy_1

; Set up the credits text - line 2
		ldx #$00
t_text_copy_2	ldy t_text_2,x
		lda char_decode,y
		sta screen_ram+$2d2,x
		sta buffer_ram+$2d2,x
		lda #$05
		sta colour_ram+$2d2,x

		inx
		cpx #$24
		bne t_text_copy_2

; Set up the credits text - line 3
		ldx #$00
t_text_copy_3	ldy t_text_3,x
		lda char_decode,y
		sta screen_ram+$321,x
		sta buffer_ram+$321,x
		lda #$04
		sta colour_ram+$321,x

		inx
		cpx #$26
		bne t_text_copy_3

; Position the sprites for the "death" logo
		ldx #$00
t_sprite_init	lda t_sprite_x_1,x
		sta sprite_x,x
		lda t_sprite_y_1,x
		sta sprite_y,x

		lda t_sprite_dp_1,x
		sta sprite_dp,x
		lda t_sprite_col_1,x
		sta sprite_col,x
		inx
		cpx #$08
		bne t_sprite_init

		lda #$22
		sta d025_mirror

; Wait, set up the titles tune and turn the screen on
		jsr sync_wait

		lda #$02
		jsr music+$00

		lda #$1b
		sta $d011

; Titles page loop
titles_loop	jsr sync_wait

; Copy some colour around to make the credits glow
		ldx #$00
		lda pulse_buffer+$06
t_colour_copy_1	sta colour_ram+$2a2,x
		inx
		cpx #$05
		bne t_colour_copy_1

		ldx #$00
		lda pulse_buffer+$03
t_colour_copy_2	sta colour_ram+$2e3,x
		inx
		cpx #$15
		bne t_colour_copy_2

		ldx #$00
		lda pulse_buffer+$00
t_colour_copy_3	sta colour_ram+$321,x
		inx
		cpx #$0d
		bne t_colour_copy_3

; Shift the starfield
		jsr star_update

; Titles page joystick checks for the sound options
t_joy_check	lda $dc00
		sta ctrl_buffer

; See if joystick up has been pressed - disable music
t_up_check	lda ctrl_buffer
		and #$01
		bne t_down_check

		lda #$01
		sta music_enable

; See if joystick left has been pressed - disable music
t_down_check	lda ctrl_buffer
		and #$02
		bne t_left_check

		lda #$00
		sta music_enable

; See if joystick left has been pressed - disable music
t_left_check	lda ctrl_buffer
		and #$04
		bne t_right_check

		lda #$01
		sta sfx_enable

; See if joystick left has been pressed - disable music
t_right_check	lda ctrl_buffer
		and #$08
		bne t_fire_check

		lda #$00
		sta sfx_enable

; See if fire has been pressed to start the game
t_fire_check	jsr t_select_upd

		lda ctrl_buffer
		and #$10
		bne titles_loop

; If fire was pressed, turn the screen off
		lda #$0b
		sta $d011

; Wait for the fire button to be released before continuing
titles_db_loop	lda $dc00
		and #$10
		beq titles_db_loop

; Turn off titles mode and pause for a bit
		lda #$00
		sta titles_flag

		ldy #$18
		jsr sync_wait_long


; Initialise the main game (first pass)
		lda #$00
		sta random_x_count
		lda #$00
		sta random_y_count

; Set up the player's labels
		ldx #$00
		txa
score_reset	sta player_score,x
		inx
		cpx #$06
		bne score_reset

		lda #$05
		sta player_lives
		lda #$00
		sta player_level

		lda #$00
		sta player_d_flag

; Use the level number to decide which background/waves to use
main_init	lda player_level
		asl
		tax

		lda level_starts+$00,x
		sta level_read+$00
		lda level_starts+$01,x
		sta level_read+$01

; Display the background
		jsr level_init

; Initialise the wave wave reader
		jsr wave_fetch
		lda #$01
		sta wave_active

; Zero all the sprite positions
		ldx #$00
		txa
sprite_reset	sta sprite_x,x
		sta sprite_y,x
		inx
		cpx #$08
		bne sprite_reset

; Reset the enemy status bytes so they're ready to use
		ldx #$00
		txa
enemy_reset	sta enemy_state,x
		inx
		cpx #$06
		bne enemy_reset

; delay the first enemy's spawning in by a couple of seconds
		lda #$64
		sta wave_spawn_tmr

; Configure the player's sprite
		lda #$56
		sta sprite_x
		lda #$90
		sta sprite_y

		lda #player_ast
		sta sprite_dp
		sta anim_start

		lda #player_aed
		sta anim_end

		lda #$dd
		sta sprite_col

		lda #$64
		sta player_shield

; Reset the player's bullets
		lda #$00
		sta bullet_x+$00
		sta bullet_x+$01
		sta bullet_y+$00
		sta bullet_y+$01
		sta bullet_active+$00
		sta bullet_active+$01

; Reset the bonus timer and set it for the current stage
		ldx #$00
		txa
bonus_reset	sta player_bonus,x
		inx
		cpx #$05
		bne bonus_reset

		lda player_level
		asl
		tax
		lda level_bonuses+$00,x
		sta player_bonus+$00
		lda level_bonuses+$01,x
		sta player_bonus+$01

; Set up music driver for the in-game tune (if we're on the first level)
		lda player_level
		bne music_init_skip

		jsr sync_wait

		lda #$00
		ldy music_enable
		bne *+$04
		lda #$03
		jsr music+$00

music_init_skip

; Refresh the status bar and turn the screen back on
		jsr status_set
		jsr status_update

		lda #$1b
		sta $d011

; Play the level start sound (if enabled)
		lda sfx_enable
		beq *+$0b

		lda #<level_start_sfx
		ldy #>level_start_sfx
		ldx #$0e
		jsr music+$06


; Main loop start - check for the Run/Stop key to pause the game
main_loop	lda $dc01
		cmp #$7f
		bne main_loop_2

		jsr sync_wait

; Wait for the fire button to be pressed...
pause_wait	lda $dc00
		and #$10
		bne pause_wait

; ...and released to exit pause
pause_wait_db	lda $dc00
		and #$10
		beq pause_wait_db


; The actual main game loop
main_loop_2	jsr sync_wait

; Update the player and their bullets
		jsr player_update
		jsr bullet_update

; Update the enemies
		jsr enemy_update

; Animate the sprites
		jsr anim_update

; Update the score and status bar
		jsr bump_score
		jsr lower_bonus
		jsr status_update

; Shift the starfield
		jsr star_update

; Check the lives counter - if it's $00 then kill the player
; (This is conditional assembly, if cheat isn't $00 it disappears!)
!if cheat=$00 {
		lda player_lives
		bne *+$05
		jmp game_over_init
}

; Check to see if end of level conditions have been met
		lda wave_active
		bne main_loop

		ldx #$00
		txa
check_state	ora enemy_state,x
		inx
		cpx #$06
		bne check_state

		cmp #$00
		bne main_loop


; Get ready for a score bonus!
level_done_init	jsr bump_score

		lda #$ff
		sta player_shield

		lda #$ff
		sta counter

; Play the level complete sound effect (if enabled)
		lda sfx_enable
		beq *+$0b

		lda #<level_end_sfx
		ldy #>level_end_sfx
		ldx #$0e
		jsr music+$06

; The level's been completed, so rack up the score bonus
level_done_loop	jsr sync_wait

; Update the player and their bullets
		jsr player_update
		jsr bullet_update

; Animate the sprites
		jsr anim_update

; Shift the starfield
		jsr star_update

; Display the level completion message and it's box
		ldx #$00
ld_display	lda #$2d
		sta screen_ram+$1c5,x
		sta buffer_ram+$1c5,x
		lda #$09
		sta colour_ram+$1c5,x

		lda #$20
		sta screen_ram+$1ed,x
		sta buffer_ram+$1ed,x
		sta screen_ram+$23d,x
		sta buffer_ram+$23d,x

		ldy ld_text,x
		lda char_decode,y
		sta screen_ram+$215,x
		sta buffer_ram+$215,x
		lda pulse_buffer+$06
		sta colour_ram+$215,x

		lda #$42
		sta screen_ram+$23d+$28,x
		sta buffer_ram+$23d+$28,x
		lda #$0f
		sta colour_ram+$23d+$28,x

		inx
		cpx #$0e
		bne ld_display

; Update the score and status bar (called multiple times for speed)
		lda #$10
		sta rt_store_1

ld_bonus_loop	jsr lb_outer_loop

		lda player_bonus+$00
		ora player_bonus+$01
		ora player_bonus+$02
		ora player_bonus+$03
		cmp #$00
		beq ld_no_bonus

		lda #$01
		sta score_bonus
		jsr bump_score

; If points have been awarded, keep things going a second longer
		lda #$32
		sta counter

		dec rt_store_1
		bne ld_bonus_loop

; Update the status and see if everything is done
ld_no_bonus	jsr status_update

; Little fudge to make sure the player shield never runs out during this
		lda player_shield
		ora #$20
		sta player_shield

		dec counter
		bne level_done_loop


; On to the next level, so turn the screen off
		jsr sync_wait
		lda #$0b
		sta $d011

		ldy #$20
		jsr sync_wait_long

; Bump the level counter and, if needed, exit to the end screen if done
		ldx player_level
		inx
		cpx #$08
		beq game_done_init

		stx player_level

		jmp main_init


; Initialisation for game completion
game_done_init	ldy #$20
		jsr sync_wait_long

; Completion screen init - set up the special background
		lda #$08
		asl
		tax

		lda level_starts+$00,x
		sta level_read+$00
		lda level_starts+$01,x
		sta level_read+$01

		jsr level_init

; Zero the level's quota
		lda #$00
		sta player_quota+$00
		sta player_quota+$01
		sta player_quota+$02

; Initialise the wave wave reader for six player sprites
		lda #$fc
		sta wave_spawn_tmr
		jsr wave_fetch
		lda #$01
		sta wave_active

; Refresh the status bar
		jsr status_set
		jsr status_update

; Build a frame and copy in the first block of text
		ldx #$00
end_text_copy	lda #$2d
		sta screen_ram+$168,x
		sta buffer_ram+$168,x
		lda #$09
		sta colour_ram+$168,x

		lda #$20
		sta screen_ram+$190,x
		sta buffer_ram+$190,x

		sta screen_ram+$1e0,x
		sta buffer_ram+$1e0,x

		sta screen_ram+$208,x
		sta buffer_ram+$208,x

		sta screen_ram+$230,x
		sta buffer_ram+$230,x

		ldy e_text_1,x
		lda char_decode,y
		sta screen_ram+$1b8,x
		sta buffer_ram+$1b8,x

		lda #$42
		sta screen_ram+$258,x
		sta buffer_ram+$258,x
		lda #$0f
		sta colour_ram+$258,x

		inx
		cpx #$28
		bne end_text_copy

; Zero all the sprites...
		ldx #$00
		txa
end_spr_reset	sta sprite_x,x
		sta sprite_y,x
		inx
		cpx #$08
		bne end_spr_reset

; ...and the player's bullets
		sta bullet_x+$00
		sta bullet_x+$01
		sta bullet_y+$00
		sta bullet_y+$01
		sta bullet_active+$00
		sta bullet_active+$01

; Force the "random" enemy spawns to a nice-looking place in the table
		lda #$06
		sta random_x_count
		sta random_y_count

; Set up music driver for the completion tune
		jsr sync_wait

		lda #$01
		jsr music+$00

; Turn the screen back on and set counter as a timer
		lda #$1b
		sta $d011

		lda #$a0
		sta counter

; Completion screen loop
end_loop	jsr sync_wait

; Update the enemies (launches six player craft)
		jsr enemy_update

; Animate the sprites
		jsr anim_update

; Shift the starfield
		jsr star_update

; Update the status bar for when the score bonus gets added
		jsr status_update

; Pulse the two lines of completion text
		ldx #$00
e_pulse		lda pulse_buffer+$00
		sta colour_ram+$1b8,x

		lda pulse_buffer+$08
		sta colour_ram+$208,x
		inx
		cpx #$28
		bne e_pulse

; Update the score if there's a bonus to add
		lda score_bonus
		beq e_bonus_add

		ldx #$02
		jsr bs_bump_loop

		dec score_bonus

; Refresh the counter and, if it hits zero, add the score bonus
e_bonus_add	ldx counter
		dex
		cpx #$ff
		bne *+$04
		ldx #$00
		stx counter

; If the timer has expired start adding the score bonus
		cpx #$01
		bne e_text_check

; Copy in the second block of text - score bonus message
		ldx #$00
e_text_copy_2	ldy e_text_2,x
		lda char_decode,y
		sta screen_ram+$20a,x
		sta buffer_ram+$20a,x

		inx
		cpx #$24
		bne e_text_copy_2

; Add 200,000 points to the score!
		lda #$c8
		sta score_bonus

; Play the end bonus sound (if enabled)
		lda sfx_enable
		beq *+$0b

		lda #<end_bonus_sfx
		ldy #>end_bonus_sfx
		ldx #$0e
		jsr music+$06

; If it's time to change the text again, do so
e_text_check	lda wave_active
		bne e_fire_check

; Copy in the tird block of text - press fire message
		ldx #$00
e_text_copy_3	ldy e_text_3,x
		lda char_decode,y
		sta screen_ram+$209,x
		sta buffer_ram+$209,x

		inx
		cpx #$26
		bne e_text_copy_3

; Prevent fire being pressed until the timer and bonus are zero
e_fire_check	lda counter
		bne end_loop

		lda score_bonus
		bne end_loop

; Check the fire button
		lda $dc00
		and #$10
		beq *+$05
		jmp end_loop

; If fire was pressed, turn the screen off
		lda #$0b
		sta $d011

; Wait for the fire button to be released before continuing
end_db_loop	lda $dc00
		and #$10
		beq end_db_loop

; Turn off the screen and jump to the titles page
		ldy #$18
		jsr sync_wait_long

		jmp titles_init


; Initialise for game over - blow the player up
game_over_init	lda #$a0
		sta sprite_dp+$00
		lda #$a9
		sta anim_start+$00
		lda #$aa
		sta anim_end+$00

		lda #$77
		sta sprite_col+$00
		lda #$07
		sta player_shield

		lda #$00
		sta counter

; Play the game over sound effect (if enabled)
		lda sfx_enable
		beq *+$0b

		lda #<game_over_sfx
		ldy #>game_over_sfx
		ldx #$0e
		jsr music+$06

; Game over loop - ticks over most of the systems
game_over_loop	jsr sync_wait

; Update the player bullets
		jsr bullet_update

; Update the enemies (whilst suppressing the spawn timer)
		lda #$20
		sta wave_spawn_tmr
		jsr enemy_update

; Animate the sprites
		jsr anim_update

; Update the score and status bar
		jsr bump_score
		jsr lower_bonus
		jsr status_update

; Shift the starfield
		jsr star_update

; Dissolve the background out
		ldx counter
		ldy random_fade,x
		lda #$00
		sta screen_ram+$028,y
		sta buffer_ram+$028,y
		sta screen_ram+$128,y
		sta buffer_ram+$128,y
		sta screen_ram+$228,y
		sta buffer_ram+$228,y
		cpy #$c0
		bcs *+$08
		sta screen_ram+$328,y
		sta buffer_ram+$328,y

; Display the game over message and it's box
		ldx #$00
go_display	lda #$2d
		sta screen_ram+$1c6,x
		sta buffer_ram+$1c6,x
		lda #$09
		sta colour_ram+$1c6,x

		lda #$20
		sta screen_ram+$1ee,x
		sta buffer_ram+$1ee,x
		sta screen_ram+$23e,x
		sta buffer_ram+$23e,x

		ldy go_text,x
		lda char_decode,y
		sta screen_ram+$216,x
		sta buffer_ram+$216,x
		lda pulse_buffer+$03
		sta colour_ram+$216,x

		lda #$42
		sta screen_ram+$266,x
		sta buffer_ram+$266,x
		lda #$0f
		sta colour_ram+$266,x

		inx
		cpx #$0c
		bne go_display

; Check to see if we need a strobe effect
go_no_message	lda counter
		and #$0f
		bne go_count

; Strobe the screen pink on the next frame and orange after that
		lda #$8a
		sta d021_mirror

; Update the timer and loop back if it hasn't wrapped around to zero
go_count	inc counter
		beq *+$05
		jmp game_over_loop

; Turn the screen off, wait for a bit and jump to the titles code
		lda #$0b
		sta $d011

		ldy #$18
		jsr sync_wait_long

		jmp titles_init


; Read the joystick and update the player
player_update	lda $dc00
		sta ctrl_buffer
pu_up		and #$01
		bne pu_down

		lda sprite_y+$00
		sec
		sbc #$04
		cmp #$3a
		bcs *+$04
		lda #$3a
		sta sprite_y+$00

pu_down		lda ctrl_buffer
		and #$02
		bne pu_left

		lda sprite_y+$00
		clc
		adc #$04
		cmp #$e4
		bcc *+$04
		lda #$e3
		sta sprite_y+$00

pu_left		lda ctrl_buffer
		and #$04
		bne pu_right

		lda sprite_x+$00
		sec
		sbc #$02
		cmp #$0c
		bcs *+$04
		lda #$0c
		sta sprite_x+$00

pu_right	lda ctrl_buffer
		and #$08
		bne pu_joy_out

		lda sprite_x+$00
		clc
		adc #$02
		cmp #$a1
		bcc *+$04
		lda #$a0
		sta sprite_x+$00

; Player bullet firing (automated, fire button decides direction)
pu_joy_out	ldx bullet_timer
		inx
		stx bullet_timer
		cpx #$0c
		bcc pu_afire_xb

		dex

		lda ctrl_buffer
		and #$0f
		eor #$0f
		sta fire_direction

; No direction currently set so don't fire
		beq pu_afire_xb-$02

; Find a free bullet and spawn it
		ldx #$00
pu_bullet_find	lda bullet_active,x
		beq pu_bullet_spawn
		inx
		cpx #$02
		bne pu_bullet_find
		jmp pu_afire_xb-$02

pu_bullet_spawn	lda sprite_x
		sta bullet_x,x
		lda sprite_y
		sta bullet_y,x

		lda #$14
		sta bullet_active,x

		lda ctrl_buffer
		and #$10
		bne pu_rev_fire

; Forward fire direction
pu_fwd_fire	lda fire_direction
		sta bullet_dir,x

		jmp pu_bull_spawned

; Reverse fire direction
pu_rev_fire	ldy fire_direction
		lda fire_reverse,y
		sta bullet_dir,x

pu_bull_spawned	ldy bull_col_count
		lda bullet_colours,y
		sta bullet_colour,x
		iny
		cpy #$03
		bcc *+$04
		ldy #$00
		sty bull_col_count

		ldx #$00
		stx bullet_timer

; Play the firing sound (if sound enabled and music disabled)
		lda music_enable
		bne pu_afire_xb

		lda sfx_enable
		beq *+$0b

		lda #<plyr_fire_sfx
		ldy #>plyr_fire_sfx
		ldx #$07
		jsr music+$06

pu_afire_xb

; Player to nasty collision checks
		lda sprite_x+$00
		sec
		sbc #$09
		sta coll_temp+$00
		clc
		adc #$12
		sta coll_temp+$01

		lda sprite_y+$00
		sec
		sbc #$10
		sta coll_temp+$02
		clc
		adc #$1c
		sta coll_temp+$03

; Collision check loop
		ldx #$00
pu_coll_loop	lda enemy_state,x
		cmp #$02
		bne pu_coll_skip

		lda sprite_x+$02,x
		cmp coll_temp+$00
		bcc pu_coll_skip
		cmp coll_temp+$01
		bcs pu_coll_skip

		lda sprite_y+$02,x
		cmp coll_temp+$02
		bcc pu_coll_skip
		cmp coll_temp+$03
		bcs pu_coll_skip

; Player has collided, so destroy the enemy
		lda #$01
		sta enemy_state,x

		lda #$a0
		sta sprite_dp+$02,x
		lda #$a9
		sta anim_start+$02,x
		lda #$aa
		sta anim_end+$02,x

		lda #$ac
		sta sprite_col+$02,x

; Remove the destroyed enemy from the level quota
		stx rt_store_1
		jsr quota_down

; Trigger the enemy explosion sound if something was shot (if enabled)
		lda sfx_enable
		beq *+$0b

		lda #<enemy_death_sfx
		ldy #>enemy_death_sfx
		ldx #$0e
		jsr music+$06

		ldx rt_store_1

; Check to see if the player is shielded and skip killing them if so
		lda player_shield
		bne pu_coll_skip

; Decrease the lives counter and set the shield
		ldx player_lives
		dex
		cpx #$ff
		bne *+$04
		ldx #$00
		stx player_lives

		lda #$64
		sta player_shield

; Strobe the screen yellow on the next frame and pink after that
		lda #$a7
		sta d021_mirror

; Trigger the player explosion sound (if enabled)
		lda sfx_enable
		beq *+$0b

		lda #<plyr_death_sfx
		ldy #>plyr_death_sfx
		ldx #$0e
		jsr music+$06

; Finish the loop
pu_coll_skip	inx
		cpx #$06
		bne pu_coll_loop

; Decrease the player shield
		ldx player_shield
		dex
		cpx #$ff
		bne *+$04
		ldx #$00
		stx player_shield

		rts


; Update the player's bullets
bullet_update	ldx #$00
bu_loop		lda bullet_active,x
		bne bu_main

; If a bullet is inactive, zero all the things!
		lda #$00
		sta bullet_x,x
		sta bullet_y,x

		jmp bu_count

; Decrease active counter
bu_main		dec bullet_active,x

; Check the bullet's current direction
		lda bullet_dir,x
		sta ctrl_buffer

; Move bullet up
bu_up		lsr ctrl_buffer
		bcc bu_down

		lda bullet_y,x
		sec
		sbc #$0c
		sta bullet_y,x

; Disable bullet if it's going off screen
		cmp #$3a
		bcs bu_down
		lda #$00
		sta bullet_active,x

; Move bullet down
bu_down		lsr ctrl_buffer
		bcc bu_left

		lda bullet_y,x
		clc
		adc #$0c
		sta bullet_y,x

; Disable bullet if it's going off screen
		cmp #$e3
		bcc bu_left
		lda #$00
		sta bullet_active,x

; Move bullet left
bu_left		lsr ctrl_buffer
		bcc bu_right

		lda bullet_x,x
		sec
		sbc #$06
		sta bullet_x,x

; Disable bullet if it's going off screen
		cmp #$0c
		bcs bu_right
		lda #$00
		sta bullet_active,x

; Move bullet right
bu_right	lsr ctrl_buffer
		bcc bu_count

		lda bullet_x,x
		clc
		adc #$06
		sta bullet_x,x

; Disable bullet if it's going off screen
		cmp #$a0
		bcc bu_count
		lda #$00
		sta bullet_active,x

; Update the loop counter
bu_count	inx
		cpx #$02
		bne bu_loop

; Bullet to nasty collision checks
		ldy #$00
		sty score_bonus

bu_collisions	lda bullet_active,y
		bne *+$05
		jmp bu_coll_exit

		lda bullet_y,y
		sec
		sbc #$13
		sta coll_temp+$02
		clc
		adc #$26
		sta coll_temp+$03

		lda bullet_x,y
		sec
		sbc #$0b
		sta coll_temp+$00
		clc
		adc #$16
		sta coll_temp+$01

; Collision check loop
		ldx #$00
bu_coll_loop	lda enemy_state,x
		cmp #$02
		bcc bu_coll_skip

		lda sprite_x+$02,x
		cmp coll_temp+$00
		bcc bu_coll_skip
		cmp coll_temp+$01
		bcs bu_coll_skip

		lda sprite_y+$02,x
		cmp coll_temp+$02
		bcc bu_coll_skip
		cmp coll_temp+$03
		bcs bu_coll_skip

; Enemy has been shot, add some score
		lda score_bonus
		clc
		adc #$08
		sta score_bonus

; Add more score if the enemy was still spawning
		lda enemy_state,x
		cmp #$03
		bne bu_no_bonus

		lda score_bonus
		clc
		adc #$04
		sta score_bonus

; Remove the destroyed enemy from the level quota
bu_no_bonus	stx rt_store_1
		jsr quota_down
		ldx rt_store_1

; Now deal with blowing the enemy up
		lda #$01
		sta enemy_state,x

		lda #$a0
		sta sprite_dp+$02,x
		lda #$a9
		sta anim_start+$02,x
		lda #$aa
		sta anim_end+$02,x

		lda #$ac
		sta sprite_col+$02,x

; Disable the bullet that did the deed
		lda #$00
		sta bullet_active,y

; Strobe the screen red on the next frame and brown after that
		lda #$92
		sta d021_mirror

		jmp bu_coll_exit

; Finish the loop
bu_coll_skip	inx
		cpx #$06
		bne bu_coll_loop

; Count up to handle all of the player's bullets
bu_coll_exit	iny
		cpy #$02
		beq *+$05
		jmp bu_collisions

; Trigger the enemy explosion sound if something was shot (if enabled)
		lda score_bonus
		beq bu_main_exit

		lda sfx_enable
		beq *+$0b

		lda #<enemy_death_sfx
		ldy #>enemy_death_sfx
		ldx #$0e
		jsr music+$06

bu_main_exit	rts


; Update the enemies
enemy_update	ldx #$00

; Check the enemy's current state and respond accordingly - $00 is disabled,
; $01 is exploding, $02 is active and $03 is spawning
eu_loop		lda enemy_state,x

		cmp #$01
		beq eu_splode_upd

		cmp #$02
		beq eu_main_update

		cmp #$03
		beq eu_spawn_update

		jmp eu_count

; Explosion state: wait for the explosion to end before freeing the object
eu_splode_upd	lda sprite_dp+$02,x
		cmp #$a9
		bne eu_count

; The explosion is done so zero the enemy state for next frame
		lda #$00
		sta enemy_state,x
		jmp eu_count

; Standard state: update sprite X and Y position
eu_main_update	lda sprite_x+$02,x
		clc
		adc enemy_x_speeds,x
		sta sprite_x+$02,x

		lda sprite_y+$02,x
		clc
		adc enemy_y_speeds,x
		sta sprite_y+$02,x

		jmp eu_count

; Spawn state: sprite is in the process of spawning
eu_spawn_update	dec enemy_timer,x
		bne eu_count

		dec enemy_state,x

; Finish counting the sprite update loop
eu_count	inx
		cpx #$06
		bne eu_loop

; Check to see if the wave engine is currently active
		lda wave_active
		beq eu_exit

; And if so, are we due a new enemy?
		lda wave_spawn_tmr
		bne eu_exit

; Looks that way, search for a free enemy object...
		ldx #$00
eu_find_object	lda enemy_state,x
		beq eu_spawn
		inx
		cpx #$06
		bne eu_find_object

; All six objects are in use, so keep the new one pending
		jmp eu_no_free_obj

; We've found an spare object, so get X and Y positions for it
eu_spawn	ldy random_x_count
		lda random_x_pos,y
		sta sprite_x+$02,x
		iny
		cpy #$80
		bne *+$04
		ldy #$00
		sty random_x_count

		ldy random_y_count
		lda random_y_pos,y
		sta sprite_y+$02,x
		iny
		cpy #$7f
		bne *+$04
		ldy #$00
		sty random_y_count

; Fetch the current wave's X and Y speeds
		lda wave_x_speed_1
		sta enemy_x_speeds,x
		lda wave_y_speed_1
		sta enemy_y_speeds,x

; Mark this enemy as spawning and set it's timer
		lda #$03
		sta enemy_state,x
		lda #$3c
		sta enemy_timer,x

; Configure the object's  animation and colour
		lda wave_anim_start
		sta sprite_dp+$02,x
		sta anim_start+$02,x
		lda wave_anim_end
		sta anim_end+$02,x

		lda wave_colour
		sta sprite_col+$02,x

; Trigger the enemy spawn sound (if enabled)
		lda sfx_enable
		beq *+$0b

		lda #<enemy_spawn_sfx
		ldy #>enemy_spawn_sfx
		ldx #$0e
		jsr music+$06

; Was that the last enemy in this wave...
		dec wave_quota
		bne eu_no_free_obj

; ...if so, fetch a new wave ready for our next object
		jsr wave_fetch

; Set the timer up to wait for the next spawn
eu_no_free_obj	lda wave_spawn_spd
		sta wave_spawn_tmr

; Update the spawn timer
eu_exit		dec wave_spawn_tmr

		rts


; Fetch in data for a new attack wave
wave_fetch	ldy #$00
		ldx #$00

; Read the first byte of wave data, check for End Of Data marker ($7f)
		lda (level_read),y
		cmp #$7f
		bne wf_okay

; EOD was found, so react accordingly
		lda #$00
		sta wave_active

		jmp wf_eod_found

; We're good to go, so stash the X speed and...
wf_okay		sta wave_x_speed_1,x
		inc level_read+$00
		bne *+$04
		inc level_read+$01
		inx

; ...grab the remaining wave data
wf_loop		lda (level_read),y
		sta wave_x_speed_1,x
		inc level_read+$00
		bne *+$04
		inc level_read+$01
		inx
		cpx #$05
		bne wf_loop

; Fetch the number of nasties in this wave
		lda (level_read),y
		sta wave_quota
		inc level_read+$00
		bne *+$04
		inc level_read+$01

wf_eod_found	rts


; Animate the sprite definitions
anim_update	ldx anim_timer
		dex
		cpx #$ff
		bne au_exit

; The timer says we're good to go, so update the eight sprites
		ldx #$00
au_loop		cpx #$01
		beq au_s1_skip

		lda sprite_dp,x
		clc
		adc #$01
		cmp anim_end,x
		bne au_skip
		lda anim_start,x
au_skip		sta sprite_dp,x
au_s1_skip	inx
		cpx #$08
		bne au_loop

; Reset the animation timer
		ldx #$03
au_exit		stx anim_timer
		rts


; Update the two speed parallax starfield
star_update

; Remove the stars from the screen using the buffer
		ldx #$00
su_clear	ldy star_pos+$00,x
		lda buffer_ram+$028,y
		sta screen_ram+$028,y

		lda buffer_ram+$128,y
		sta screen_ram+$128,y

		lda buffer_ram+$228,y
		sta screen_ram+$228,y

		cpy #$c0
		bcs su_cl_skip
		lda buffer_ram+$328,y
		sta screen_ram+$328,y

su_cl_skip	inx
		cpx #$08
		bne su_clear

; Clear the two character definitions used for stars
		ldx #$00
		txa
su_char_clear	sta char_set+$7f0,x
		inx
		cpx #$10
		bne su_char_clear

; Update the starfield depending on what star_dir says
su_star_up	lda star_dir
		and #$01
		beq su_star_down

		jsr stars_up

su_star_down	lda star_dir
		and #$02
		beq su_star_left

		jsr stars_down

su_star_left	lda star_dir
		and #$04
		beq su_star_right

		jsr stars_left

su_star_right	lda star_dir
		and #$08
		beq su_star_out

		jsr stars_right

su_star_out

; Plot the faster stars to the screen
		ldx #$00
su_plot_fast	ldy star_pos+$00,x

		lda screen_ram+$028,y
		cmp #$00
		bne su_pf_skip_1
		lda #$ff
		sta screen_ram+$028,y
		lda #$05
		sta colour_ram+$028,y

su_pf_skip_1	lda screen_ram+$128,y
		cmp #$00
		bne su_pf_skip_2
		lda #$ff
		sta screen_ram+$128,y
		lda #$05
		sta colour_ram+$128,y

su_pf_skip_2	lda screen_ram+$228,y
		cmp #$00
		bne su_pf_skip_3
		lda #$ff
		sta screen_ram+$228,y
		lda #$05
		sta colour_ram+$228,y

su_pf_skip_3	cpy #$c0
		bcs su_pf_skip_4

		lda screen_ram+$328,y
		cmp #$00
		bne su_pf_skip_4
		lda #$ff
		sta screen_ram+$328,y
		lda #$05
		sta colour_ram+$328,y

su_pf_skip_4	inx
		cpx #$04
		bne su_plot_fast

; Plot the slower stars to the screen
		ldx #$00
su_plot_slow	ldy star_pos+$04,x

		lda screen_ram+$028,y
		cmp #$00
		bne su_ps_skip_1
		lda #$fe
		sta screen_ram+$028,y
		lda #$04
		sta colour_ram+$028,y

su_ps_skip_1	lda screen_ram+$128,y
		cmp #$00
		bne su_ps_skip_2
		lda #$fe
		sta screen_ram+$128,y
		lda #$04
		sta colour_ram+$128,y

su_ps_skip_2	lda screen_ram+$228,y
		cmp #$00
		bne su_ps_skip_3
		lda #$fe
		sta screen_ram+$228,y
		lda #$04
		sta colour_ram+$228,y

su_ps_skip_3	cpy #$c0
		bcs su_ps_skip_4

		lda screen_ram+$328,y
		cmp #$00
		bne su_ps_skip_4
		lda #$fe
		sta screen_ram+$328,y
		lda #$04
		sta colour_ram+$328,y

su_ps_skip_4	inx
		cpx #$04
		bne su_plot_slow

; Draw character definitions for the faster stars
		lda star_x_fast
		lsr
		and #$07
		tax

		lda star_y_fast
		lsr
		and #$07
		tay

		lda star_decode,x
		sta char_set+$7f8,y

; Draw character definitions for the slower stars
		lda star_x_slow
		lsr
		and #$07
		tax

		lda star_y_slow
		lsr
		and #$07
		tay

		lda star_decode,x
		sta char_set+$7f0,y

		rts


; Starfield update routine - moving up
stars_up

; Update the faster stars
		ldx #$00
su_update_fast	lda star_y_fast
		sec
		sbc #$02
		cmp #$10
		bcc su_uf_skip

		sta rt_store_1

		lda star_pos+$00
		sec
		sbc #$28
		sta star_pos+$00

		lda star_pos+$01
		sec
		sbc #$28
		sta star_pos+$01

		lda star_pos+$02
		sec
		sbc #$28
		sta star_pos+$02

		lda star_pos+$03
		sec
		sbc #$28
		sta star_pos+$03

		lda rt_store_1

		and #$0f
su_uf_skip	sta star_y_fast

; Update the slower stars
		ldx #$00
su_update_slow	lda star_y_slow
		sec
		sbc #$01
		cmp #$10
		bcc su_us_skip

		sta rt_store_1

		lda star_pos+$04
		sec
		sbc #$28
		sta star_pos+$04

		lda star_pos+$05
		sec
		sbc #$28
		sta star_pos+$05

		lda star_pos+$06
		sec
		sbc #$28
		sta star_pos+$06

		lda star_pos+$07
		sec
		sbc #$28
		sta star_pos+$07

		lda rt_store_1

		and #$0f
su_us_skip	sta star_y_slow

		rts


; Starfield update routine - moving down
stars_down

; Update the faster stars
		ldx #$00
sd_update_fast	lda star_y_fast
		clc
		adc #$02
		cmp #$10
		bcc sd_uf_skip

		sta rt_store_1

		lda star_pos+$00
		clc
		adc #$28
		sta star_pos+$00

		lda star_pos+$01
		clc
		adc #$28
		sta star_pos+$01

		lda star_pos+$02
		clc
		adc #$28
		sta star_pos+$02

		lda star_pos+$03
		clc
		adc #$28
		sta star_pos+$03

		lda rt_store_1

		and #$0f
sd_uf_skip	sta star_y_fast

; Update the slower stars
		ldx #$00
sd_update_slow	lda star_y_slow
		clc
		adc #$01
		cmp #$10
		bcc sd_us_skip

		sta rt_store_1

		lda star_pos+$04
		clc
		adc #$28
		sta star_pos+$04

		lda star_pos+$05
		clc
		adc #$28
		sta star_pos+$05

		lda star_pos+$06
		clc
		adc #$28
		sta star_pos+$06

		lda star_pos+$07
		clc
		adc #$28
		sta star_pos+$07

		lda rt_store_1

		and #$0f
sd_us_skip	sta star_y_slow

		rts


; Starfield update routine - moving left
stars_left

; Update the faster stars
		ldx #$00
sl_update_fast	lda star_x_fast
		clc
		adc #$02
		cmp #$10
		bcc sl_uf_skip

		dec star_pos+$00
		dec star_pos+$01
		dec star_pos+$02
		dec star_pos+$03

		and #$0f
sl_uf_skip	sta star_x_fast

; Update the slower stars
		ldx #$00
sl_update_slow	lda star_x_slow
		clc
		adc #$01
		cmp #$10
		bcc sl_us_skip

		dec star_pos+$04
		dec star_pos+$05
		dec star_pos+$06
		dec star_pos+$07

		and #$0f
sl_us_skip	sta star_x_slow

		rts

; Starfield update routine - moving right
stars_right

; Update the faster stars
		ldx #$00
sr_update_fast	lda star_x_fast
		sec
		sbc #$02
		cmp #$10
		bcc sr_uf_skip

		inc star_pos+$00
		inc star_pos+$01
		inc star_pos+$02
		inc star_pos+$03

		and #$0f
sr_uf_skip	sta star_x_fast

; Update the slower stars
		ldx #$00
sr_update_slow	lda star_x_slow
		sec
		sbc #$01
		cmp #$10
		bcc sr_us_skip

		inc star_pos+$04
		inc star_pos+$05
		inc star_pos+$06
		inc star_pos+$07

		and #$0f
sr_us_skip	sta star_x_slow

		rts


; Loop to render 60 tiles to the screen
level_init	ldx #$00

; Fetch a tile byte
tile_loop	stx tile_count

		ldy #$00
		lda (level_read),y
		inc level_read+$00
		bne *+$04
		inc level_read+$01

; Multiply the tile byte by $10
		sty tile_read+$01

		asl
		rol tile_read+$01
		asl
		rol tile_read+$01
		asl
		rol tile_read+$01
		asl
		rol tile_read+$01
		sta tile_read+$00

; Add the base address of the tile data
		lda tile_read+$00
		clc
		adc #<tile_data
		bcc *+$04
		inc tile_read+$01
		sta tile_read+$00

		lda tile_read+$01
		clc
		adc #>tile_data
		sta tile_read+$01

; Set the destination address within the screen RAM
		lda tile_count
		asl
		tax
		lda tile_write_pos+$00,x
		sta tile_write+$00
		lda tile_write_pos+$01,x
		sta tile_write+$01

; Render first character row of the tile
		ldy #$00
		ldx #$00
tile_line_1	lda (tile_read),y
		sta (tile_write),y

		inc tile_read+$00
		bne *+$04
		inc tile_read+$01

		inc tile_write+$00
		bne *+$04
		inc tile_write+$01

		inx
		cpx #$04
		bne tile_line_1

		lda tile_write+$00
		clc
		adc #$24
		bcc *+$04
		inc tile_write+$01
		sta tile_write+$00

; Render second character row of the tile
		ldx #$00
tile_line_2	lda (tile_read),y
		sta (tile_write),y

		inc tile_read+$00
		bne *+$04
		inc tile_read+$01

		inc tile_write+$00
		bne *+$04
		inc tile_write+$01

		inx
		cpx #$04
		bne tile_line_2

		lda tile_write+$00
		clc
		adc #$24
		bcc *+$04
		inc tile_write+$01
		sta tile_write+$00

; Render third character row of the tile
		ldx #$00
tile_line_3	lda (tile_read),y
		sta (tile_write),y

		inc tile_read+$00
		bne *+$04
		inc tile_read+$01

		inc tile_write+$00
		bne *+$04
		inc tile_write+$01

		inx
		cpx #$04
		bne tile_line_3

		lda tile_write+$00
		clc
		adc #$24
		bcc *+$04
		inc tile_write+$01
		sta tile_write+$00

; Render fourth character row of the tile
		ldx #$00
tile_line_4	lda (tile_read),y
		sta (tile_write),y

		inc tile_read+$00
		bne *+$04
		inc tile_read+$01

		inc tile_write+$00
		bne *+$04
		inc tile_write+$01

		inx
		cpx #$04
		bne tile_line_4

; Move on to the next tile
		ldx tile_count
		inx
		cpx #$3c
		beq *+$05
		jmp tile_loop

; Copy the rendered screen to the back buffer
		ldx #$00
buffer_stash	lda screen_ram+$028,x
		sta buffer_ram+$028,x
		lda screen_ram+$128,x
		sta buffer_ram+$128,x
		lda screen_ram+$228,x
		sta buffer_ram+$228,x
		lda screen_ram+$2e8,x
		sta buffer_ram+$2e8,x

		inx
		bne buffer_stash

; Colour the rendered screen of tiles
		ldx #$00
tile_colour	ldy screen_ram+$028,x
		lda tile_col_data,y
		sta colour_ram+$028,x

		ldy screen_ram+$128,x
		lda tile_col_data,y
		sta colour_ram+$128,x

		ldy screen_ram+$228,x
		lda tile_col_data,y
		sta colour_ram+$228,x

		ldy screen_ram+$2e8,x
		lda tile_col_data,y
		sta colour_ram+$2e8,x

		inx
		bne tile_colour

; Read the background multicolour values
		ldy #$00

		lda (level_read),y
		sta d022_mirror

		inc level_read+$00
		bne *+$04
		inc level_read+$01

		lda (level_read),y
		sta d023_mirror

		inc level_read+$00
		bne *+$04
		inc level_read+$01

; Read the sprite multicolour
		lda (level_read),y
		sta d025_mirror

		inc level_read+$00
		bne *+$04
		inc level_read+$01

; Fetch the starfield direction
		lda (level_read),y
		sta star_dir

		inc level_read+$00
		bne *+$04
		inc level_read+$01

; Get the level's spawn speed
		lda (level_read),y
		sta wave_spawn_spd

		inc level_read+$00
		bne *+$04
		inc level_read+$01

; Store the read position before we look ahead for the quota
		lda level_read+$00
		sta coll_temp+$00
		lda level_read+$01
		sta coll_temp+$01

; Generate the level's quota by fast forwarding through the data
		lda #$01
		sta wave_active

enemy_count	jsr wave_fetch
		lda wave_active
		beq ec_out

; Add the fetched wave's quota to the overall counter
		ldy wave_quota
		ldx #$02
ec_quota_up	lda player_quota,x
		clc
		adc #$01
		sta player_quota,x

		cmp #$0a
		bne ec_quota_done
		lda #$00
		sta player_quota,x

		dex
		cpx #$ff
		bne ec_quota_up

ec_quota_done	dey
		bne ec_quota_up-$02

		jmp enemy_count

ec_out

; Restore the read position before exiting the subroutine
		lda coll_temp+$00
		sta level_read+$00
		lda coll_temp+$01
		sta level_read+$01

		rts


; Decrease the level quota by one (unless it's alrady 000)
quota_down	lda player_quota+$00
		ora player_quota+$01
		ora player_quota+$02

		bne qd_loop-$02
		rts

; Main loop to decrease the quota
		ldx #$02
qd_loop		lda player_quota,x
		sec
		sbc #$01
		sta player_quota,x

		cmp #$ff
		bne qd_skip

		lda #$09
		sta player_quota,x

		dex
		cpx #$ff
		bne qd_loop

qd_skip		rts

; Set up status bar text
status_set	ldx #$00
sset_loop_1	ldy status_text,x
		lda char_decode,y
		sta screen_ram,x
		lda #$00
		sta colour_ram,x
		inx
		cpx #$28
		bne sset_loop_1

; Check if we're in titles mode...
		lda titles_flag
		beq sset_exit

; ...and change the bonus counter for the top score if so
		ldx #$00
sset_loop_2	ldy status_text_alt,x
		lda char_decode,y
		sta screen_ram+$1e,x
		inx
		cpx #$0a
		bne sset_loop_2

sset_exit	rts

; Update the status bar
status_update	ldx #$00
su_score	lda player_score,x
		clc
		adc #$21
		sta screen_ram+$00,x
		inx
		cpx #$06
		bne su_score

; Display the lives counter
		lda player_lives
		clc
		adc #$21
		sta screen_ram+$08

; Show the current level's number...
		lda player_level
		clc
		adc #$22
		sta screen_ram+$10

; ...and how many enemies are remaining on it
		lda player_quota+$00
		clc
		adc #$21
		sta screen_ram+$19

		lda player_quota+$01
		clc
		adc #$21
		sta screen_ram+$1a

		lda player_quota+$02
		clc
		adc #$21
		sta screen_ram+$1b

; Check to see if we're in titles mode
		lda titles_flag
		bne su_disp_high_sc

; Titles flag isn't set, update the bonus
		ldx #$00
su_bonus	lda player_bonus,x
		clc
		adc #$21
		sta screen_ram+$24,x
		inx
		cpx #$04
		bne su_bonus

		rts

; Titles page flag is set, so display the high score
su_disp_high_sc	ldx #$00
su_high_sc	lda high_score,x
		clc
		adc #$21
		sta screen_ram+$22,x
		inx
		cpx #$06
		bne su_high_sc

		rts


; Add to the player's score
bump_score	lda score_bonus
		beq bs_exit
		tay

bs_outer_loop	ldx #$04
		jsr bs_bump_loop
		dey
		bne bs_outer_loop

bs_exit		rts

; Actually add points (this is also called for the end of game bonus)
bs_bump_loop	lda player_score,x
		clc
		adc #$01
		sta player_score,x

		cmp #$0a
		bcc bssu_skip

		lda #$00
		sta player_score,x

		dex
		cpx #$ff
		bne bs_bump_loop

bssu_skip	rts

; Score to high score comparison
highscore_scan	ldx #$00
hss_loop	lda player_score,x
		cmp high_score,x
		beq hss_cnt
		bcc hss_out
		bcs hiscore_update
hss_cnt		inx
		cpx #$06
		bne hss_loop
hss_out		rts

; Copy the player's score over the high score
hiscore_update	ldx #$00
hs_copy_loop	lda player_score,x
		sta high_score,x
		inx
		cpx #$06
		bne hs_copy_loop

		rts

; Reduce the bonus counter
lower_bonus	ldx player_bonus+$04
		inx
		cpx #$08
		bne lb_exit

; Decrease the visible bonus
lb_outer_loop	ldx #$03
lb_loop		lda player_bonus,x
		sec
		sbc #$01
		sta player_bonus,x

		cmp #$ff
		bcc lb_skip

		lda #$09
		sta player_bonus,x

		dex
		cpx #$ff
		bne lb_loop

; Check to see the timer hasn't wrapped to 9999
		lda player_bonus
		cmp #$09
		bne lb_skip

; If it has, suppress that by making the bonus 0000
		ldx #$00
		txa
lb_bonus_wipe	sta player_bonus,x
		inx
		cpx #$04
		bne lb_bonus_wipe

lb_skip		ldx #$00
lb_exit		stx player_bonus+$04

		rts


; Option selection update - music on or off
t_select_upd	lda music_enable
		asl
		clc
		adc music_enable
		tay

		ldx #$00
t_supd_loop_1a	lda status_off_txt,y
		sta screen_ram+$338,x
		sta buffer_ram+$338,x
		iny
		inx
		cpx #$03
		bne t_supd_loop_1a

		ldx music_enable
		lda status_off_col,x
		ldx #$00
t_supd_loop_1b	sta colour_ram+$338,x
		inx
		cpx #$03
		bne t_supd_loop_1b

; Option selection update - sound effects on or off
		lda sfx_enable
		asl
		clc
		adc sfx_enable
		tay

		ldx #$00
t_supd_loop_2a	lda status_off_txt,y
		sta screen_ram+$345,x
		sta buffer_ram+$345,x
		iny
		inx
		cpx #$03
		bne t_supd_loop_2a

		ldx sfx_enable
		lda status_off_col,x
		ldx #$00
t_supd_loop_2b	sta colour_ram+$345,x
		inx
		cpx #$03
		bne t_supd_loop_2b

		rts


; IRQ interrupt handler
irq_int		pha
		txa
		pha
		tya
		pha

		lda $d019
		and #$01
		sta $d019
		bne int_go
		jmp irq_exit

; An interrupt has triggered
int_go		lda raster_num

		cmp #$02
		bne *+$05
		jmp irq_rout2

		cmp #$03
		bne *+$05
		jmp irq_rout3

		cmp #$04
		bne *+$05
		jmp irq_rout4


; Raster split 1
irq_rout1	lda #$00
		sta $d020
		lda d021_mirror
		sta $d021

		lda d022_mirror
		sta $d022
		lda d023_mirror
		sta $d023

		lda #$18
		sta $d016
		sta $d018

; Shift d021_mirror so the upper nybble is used on the next frame
		lsr d021_mirror
		lsr d021_mirror
		lsr d021_mirror
		lsr d021_mirror

; Update the flicker counter...
		lda flicker_count
		eor #$01
		and #$01
		sta flicker_count

; ...and use it to select which bullet will be shown
		tax
		lda bullet_x,x
		sta sprite_x+$01
		lda bullet_y,x
		sta sprite_y+$01

		ldy bullet_dir,x
		lda bullet_decode,y
		sta sprite_dp+$01

		lda bullet_colour,x
		sta sprite_col+$01

; Set up and position the hardware sprites
		lda #$ff
		sta $d015

; Change the sprite priority so they're behind the status bar
		sta $d01b

; Multicolour enable
		lda #$fd
		sta $d01c

; Set sprite X and Y positions
		ldx #$00
		ldy #$00
xploder_1	lda sprite_x,x
		asl
		ror $d010
		sta $d000,y
		lda sprite_y,x
		sta $d001,y
		iny
		iny
		inx
		cpx #$08
		bne xploder_1

; Set sprite colours and data pointers
		ldx #$00
xploder_2	lda sprite_col,x

; If the flicker count isn't $00, use the upper colour nybble
		ldy flicker_count
		beq x2_skip

		lsr
		lsr
		lsr
		lsr

x2_skip		sta $d027,x

		lda sprite_dp,x
		sta screen_ram+$3f8,x
		inx
		cpx #$08
		bne xploder_2

; Update the sprite multicolour
		lda d025_mirror
		ldy flicker_count
		beq d025_skip
		lsr
		lsr
		lsr
		lsr
d025_skip	sta $d025

		lda #$01
		sta $d026

; Change sprite colours for the player if shielded
		lda player_shield
		beq xploder_3-$02

		and #$1f
		tax
		lda sprite_pulse,x
		sta $d027
; Change the enemy sprite colours if they're spawning
		ldx #$00
xploder_3	lda enemy_state,x
		cmp #$03
		bne xp3_skip

		lda enemy_timer,x
		and #$1f
		tay
		lda sprite_pulse,y
		sta $d029,x

xp3_skip	inx
		cpx #$06
		bne xploder_3

; Play the music
		jsr music+$03

; Set interrupt handler for split 2
		lda #$02
		sta raster_num
		lda #raster_2_pos
		sta $d012

; Exit IRQ interrupt
		jmp irq_exit


; Raster split 2
irq_rout2

; Change the sprite priority so they're over the background
		bit $ea
		nop
		lda #$00
		sta $d01b

; Update the pulse table's counter
		ldx pulse_timer
		inx
		cpx #$18
		bne *+$04
		ldx #$00
		stx pulse_timer

		txa
		lsr
		tay

; Update the pulse buffer
		ldx #$00
pulse_update	lda status_pulse,y
		sta pulse_buffer+$00,x

		tya
		clc
		adc #$01
		tay

		inx
		cpx #$0a
		bne pulse_update

; Render the status bar's colours
		ldx #$00
status_col	ldy status_colour,x
		lda pulse_buffer,y
		sta colour_ram+$00,x
		inx
		cpx #$28
		bne status_col

; Set interrupt handler for split 3
		lda #$03
		sta raster_num
		lda #raster_3_pos
		sta $d012

; Exit IRQ interrupt
		jmp irq_exit


; Raster split 3
irq_rout3

; Are we in titles mode? If not, skip the following routines which
; position the second line of sprites for the title logo
		lda titles_flag
		beq titles_flag_off

; Position the "weapon" sprites for the title logo
		ldx #$00
		ldy #$00
t_xploder_1	lda t_sprite_x_2,x
		asl
		ror $d010
		sta $d000,y
		lda t_sprite_y_2,x
		sta $d001,y
		iny
		iny
		inx
		cpx #$08
		bne t_xploder_1

		ldx #$00
t_xploder_2	lda t_sprite_col_2,x
		sta $d027,x
		lda t_sprite_dp_2,x
		sta screen_ram+$3f8,x
		inx
		cpx #$08
		bne t_xploder_2

		lda #$09
		sta $d025

titles_flag_off

; Set interrupt handler for split 4
		lda #$04
		sta raster_num
		lda #raster_4_pos
		sta $d012

; Exit IRQ interrupt
		jmp irq_exit


; Raster split 4
irq_rout4

; Tell the runtime code to execute
		lda #$01
		sta sync

; Set interrupt handler for split 1
		lda #$01
		sta raster_num
		lda #raster_1_pos
		sta $d012

; Restore registers and exit IRQ interrupt
irq_exit	pla
		tay
		pla
		tax
		pla
nmi_int		rti


; Wait for near the end of the screen (rout4 is the trigger point)
sync_wait	lda #$00
		sta sync

sw_loop		cmp sync
		beq sw_loop
		rts

; Longer delay - the Y register says how long to wait
sync_wait_long	jsr sync_wait
		dey
		bne sync_wait_long
		rts


; Convert the character set from screen codes to what the font has
char_decode	!byte $00,$01,$02,$03,$04,$05,$06,$07	; @ to G
		!byte $08,$09,$0a,$0b,$0c,$0d,$0e,$0f	; H to O
		!byte $10,$11,$12,$13,$14,$15,$16,$17	; P to W
		!byte $18,$19,$1a,$00,$00,$00,$00,$00	; X to Z

		!byte $20,$1b,$00,$00,$00,$00,$00,$00	; space to '
		!byte $00,$00,$2b,$00,$1d,$1e,$1c,$00	; ( to /
		!byte $21,$22,$23,$24,$25,$26,$27,$28	; 0 to 7
		!byte $29,$2a,$00,$00,$00,$00,$00,$1f	; 8 to ?


; Titles page sprite positions
t_sprite_x_1	!byte $00,$00,$36,$46,$56,$66,$76,$00
t_sprite_y_1	!byte $00,$00,$51,$51,$51,$51,$51,$00
t_sprite_dp_1	!byte $00,$00,$f7,$f8,$f9,$fa,$fb,$00
t_sprite_col_1	!byte $dd,$00,$aa,$aa,$aa,$aa,$aa,$00

t_sprite_x_2	!byte $00,$00,$2e,$3e,$4e,$5e,$6e,$7e
t_sprite_y_2	!byte $00,$00,$71,$71,$71,$71,$71,$71
t_sprite_dp_2	!byte $00,$00,$fc,$f8,$f9,$fd,$fe,$ff
t_sprite_col_2	!byte $0d,$00,$05,$05,$05,$05,$05,$05


; Titles page data
t_text_1	!scr "coding, graphics and sound by    jason"

t_text_2	!scr "released for the rgcd 16k compo 2019"

t_text_3	!scr "fire to start    music  on  sounds  on"

; Music and sound mode selection text and colour
status_off_txt	!scr "off"
status_on_txt	!scr " on"

status_off_col	!byte $02
status_on_col	!byte $05


; Status bar data (second line is for titles mode only)
status_text	!scr "000000 *   area    quota      bonus     "
status_text_alt	!scr "top 000000"

; The current high score
high_score	!byte $00,$01,$06,$03,$08,$04

; Start bonuses for each of the eight levels
level_bonuses	!byte $03,$00
		!byte $03,$03
		!byte $03,$06
		!byte $03,$09
		!byte $04,$02
		!byte $04,$05
		!byte $04,$08
		!byte $05,$01

; Colour decode table for the status bar
status_colour	!byte $00,$00,$00,$00,$00,$00,$00,$02
		!byte $02,$00,$00,$04,$04,$04,$04,$04
		!byte $04,$00,$00,$06,$06,$06,$06,$06
		!byte $06,$06,$06,$06,$00,$00,$08,$08
		!byte $08,$08,$08,$08,$08,$08,$08,$08

; Colour pulse table for the status bar and on-screen text
status_pulse	!byte $06,$02,$04,$05,$03,$07,$01,$07
		!byte $03,$05,$04,$02
		!byte $06,$02,$04,$05,$03,$07,$01,$07
		!byte $03,$05,$04,$02

; Random data for the enemy spawner and game over screen
		!src "includes\random.asm"

; Bit reversal table for firing backwards
fire_reverse	!byte $00,$02,$01,$00,$08,$0a,$09,$00
		!byte $04,$06,$05,$00,$00,$00,$00,$00

; Translate the bullet directions into sprite definitions
bullet_decode	!byte $00,$b2,$b6,$00,$b8,$b9,$b7,$00
		!byte $b4,$b3,$b5

; Colour sequence for the bullets
bullet_colours	!byte $aa,$55,$ee

; Strobe colours for materialising sprites
sprite_pulse	!byte $09,$09,$02,$02,$08,$08,$0a,$0a
		!byte $0c,$0c,$0f,$0f,$07,$07,$01,$01
		!byte $0d,$0d,$03,$03,$05,$05,$0e,$0e
		!byte $04,$04,$0b,$0b,$06,$06,$00,$00

; Starfield bit decode table
star_decode	!byte $01,$02,$04,$08,$10,$20,$40,$80

; Starting positions for the starfield
star_pos_dflt	!byte $11,$47,$80,$f4,$59,$86,$c5,$e4


; Include the level data (a mixture of binary and source code)
		!src "includes\levels.asm"

; Tile and character colour data
tile_data	!bin "binary\background.til"
tile_col_data	!bin "binary\background.col"

; This generates the positions where tiles are to be rendered
tile_write_pos

!set count_y=$00
!do {
		!word screen_ram+$028+$000+(count_y*$a0)
		!word screen_ram+$028+$004+(count_y*$a0)
		!word screen_ram+$028+$008+(count_y*$a0)
		!word screen_ram+$028+$00c+(count_y*$a0)

		!word screen_ram+$028+$010+(count_y*$a0)
		!word screen_ram+$028+$014+(count_y*$a0)
		!word screen_ram+$028+$018+(count_y*$a0)
		!word screen_ram+$028+$01c+(count_y*$a0)

		!word screen_ram+$028+$020+(count_y*$a0)
		!word screen_ram+$028+$024+(count_y*$a0)

		!set count_y=count_y+$01
} until count_y=$06


; Game over text
go_text		!scr " game over! "


; Level completion text
ld_text		!scr " area cleared "


; Completion screen text
e_text_1	!scr "death weapon mission complete, well done"

e_text_2	!scr "have some points for your hard work!"

e_text_3	!scr "earth station 544d52 is safe once more"
;e_text_3	!scr "this sector of space is safe once more"


; Sound effect data
enemy_spawn_sfx	!byte $0b,$00,$02,$a9,$21

		!byte $90,$94,$98,$9c,$b0,$b4,$b8,$bc
		!byte $90,$94,$98,$9c,$b0,$b4,$b8,$bc

		!byte $00

enemy_death_sfx	!byte $00,$fa,$08,$b8,$81

		!byte $a4,$41,$a8,$bc,$81,$a0,$9a,$a4
		!byte $98,$9d,$a6,$9a,$80,$9c,$97,$96
		!byte $97,$94,$95,$96,$97,$96,$95,$94

		!byte $95,$00

plyr_fire_sfx	!byte $0b,$00,$02,$a9,$11

		!byte $b8,$b4,$b2,$b0,$ae,$ac,$aa,$a8

		!byte $00

plyr_death_sfx	!byte $00,$fb,$08,$b8,$81

		!byte $a4,$41,$a0,$b4,$81,$98,$92,$9c
		!byte $90,$95,$9e,$92,$80,$94,$8f,$8e
		!byte $8d,$8c,$8d,$8e,$8f,$8e,$8d,$8c
		!byte $8d,$9e,$92,$80,$94,$8f,$8e,$8d
		!byte $8c,$8d,$8e,$8f,$8e,$8d,$8c,$8d

		!byte $00

level_start_sfx	!byte $0b,$00,$02,$a9,$11

		!byte $88,$8c,$90,$94,$a8,$ac,$b0,$b4
		!byte $90,$94,$98,$9c,$b0,$b4,$b8,$bc
		!byte $98,$9c,$a0,$a4,$b8,$bc,$c0,$c4
		!byte $c0,$bc,$b8,$b0

		!byte $00

level_end_sfx	!byte $0b,$00,$02,$a9,$21

		!byte $8c,$8c,$ac,$ac,$8c,$8c,$ac,$ac
		!byte $90,$b0,$90,$b0,$90,$90,$b0,$b0
		!byte $94,$94,$b4,$b4,$94,$94,$b4,$b4
		!byte $9c,$9c,$bc,$bc,$9c,$9c,$bc,$bc

		!byte $8c,$8c,$ac,$ac,$8c,$8c,$ac,$ac
		!byte $90,$b0,$90,$b0,$90,$90,$b0,$b0
		!byte $94,$94,$b4,$b4,$94,$94,$b4,$b4
		!byte $9c,$9c,$bc,$bc,$9c,$9c,$bc,$bc

		!byte $8c,$8c,$ac,$ac,$8c,$8c,$ac,$ac
		!byte $90,$b0,$90,$b0,$90,$90,$b0,$b0
		!byte $94,$94,$b4,$b4,$94,$94,$b4,$b4
		!byte $9c,$9c,$bc,$bc,$9c,$9c,$bc,$bc

		!byte $00

game_over_sfx	!byte $00,$fa,$08,$b8,$81

		!byte $a4,$41,$a8,$bc,$81,$a0,$9a,$a4
		!byte $98,$9d,$a6,$9a,$80,$9c,$97,$96
		!byte $97,$94,$95,$96,$97,$96,$95,$94
		!byte $95

		!byte $a4,$41,$a8,$bc,$81,$a0,$9a,$a4
		!byte $98,$9d,$a6,$9a,$80,$9c,$97,$96
		!byte $97,$94,$95,$96,$97,$96,$95,$94
		!byte $95

		!byte $a4,$41,$a8,$bc,$81,$a0,$9a,$a4
		!byte $98,$9d,$a6,$9a,$80,$9c,$97,$96
		!byte $97,$94,$95,$96,$97,$96,$95,$94
		!byte $95

		!byte $00

end_bonus_sfx	!byte $0b,$00,$02,$a9,$21

		!byte $88,$8c,$90,$94,$a8,$ac,$b0,$b4
		!byte $90,$94,$98,$9c,$b0,$b4,$b8,$bc
		!byte $98,$9c,$a0,$a4,$b8,$bc,$c0,$c4
		!byte $a0,$a4,$a8,$ac,$c0,$c4,$c8,$cc
		!byte $d0,$cc,$c8,$c0

		!byte $00
