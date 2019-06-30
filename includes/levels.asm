; This is all of the level data, it's split off from the main
; source code to make both a little more readable!

; First some labels to make the wave data easier to read
; ("ast" is shorthand for animation start, "aed" for animation end)
player_ast	= $aa
player_aed	= $b2

enemy_01_ast	= $ba
enemy_01_aed	= $c0

enemy_02_ast	= $c0
enemy_02_aed	= $c6

enemy_03_ast	= $c6
enemy_03_aed	= $cf

enemy_04_ast	= $cf
enemy_04_aed	= $da

rocket_up_ast	= $da
rocket_up_aed	= $dc

rocket_down_ast	= $dc
rocket_down_aed	= $de

rocket_left_ast	= $de
rocket_left_aed	= $e0

rocket_rt_ast	= $e0
rocket_rt_aed	= $e2

enemy_05_ast	= $e2
enemy_05_aed	= $e8

enemy_06_ast	= $e8
enemy_06_aed	= $f2

enemy_07_ast	= $f2
enemy_07_aed	= $f7


; Pointers for the start of the data for each level
level_starts	!word level_data_1
		!word level_data_2
		!word level_data_3
		!word level_data_4
		!word level_data_5
		!word level_data_6
		!word level_data_7
		!word level_data_8

; A special block of data for the completion screen
		!word end_data


; Level 1 - background data
level_data_1	!bin "binary\background.map",$3c,$000
		!byte $0b,$0f		; background colours
		!byte $99		; darker multicolour for the sprites

		!byte $04		; starfield direction

		!byte $48		; enemy spawn speed

; Level 1 - attack wave data
wave_data_1	!byte $ff,$02		; X and Y speed
		!byte $55		; colour
		!byte enemy_01_ast	; start and...
		!byte enemy_01_aed	; ...end frames for the animation
		!byte $0d		; quota for this wave

		!byte $02,$00		; X and Y speed
		!byte $cc		; colour
		!byte rocket_rt_ast	; start and...
		!byte rocket_rt_aed	; ...end frames for the animation
		!byte $08		; quota for this wave

		!byte $00,$03		; X and Y speed
		!byte $aa		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $0e		; quota for this wave

		!byte $01,$fd		; X and Y speed
		!byte $3f		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $06		; quota for this wave

		!byte $fe,$00		; X and Y speed
		!byte $cc		; colour
		!byte rocket_left_ast	; start and...
		!byte rocket_left_aed	; ...end frames for the animation
		!byte $0d		; quota for this wave

		!byte $ff,$fd		; X and Y speed
		!byte $55		; colour
		!byte enemy_01_ast	; start and...
		!byte enemy_01_aed	; ...end frames for the animation
		!byte $05		; quota for this wave

		!byte $00,$00		; X and Y speed
		!byte $88		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $0a		; quota for this wave

		!byte $01,$00		; X and Y speed
		!byte $33		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $ff,$00		; X and Y speed
		!byte $3f		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $01,$00		; X and Y speed
		!byte $33		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $ff,$00		; X and Y speed
		!byte $3f		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $00,$fe		; X and Y speed
		!byte $cc		; colour
		!byte rocket_up_ast	; start and...
		!byte rocket_up_aed	; ...end frames for the animation
		!byte $09		; quota for this wave

		!byte $7f		; end of data marker


; Level 2 - background data
level_data_2	!bin "binary\background.map",$3c,$03c
		!byte $09,$0a		; background colours
		!byte $2b		; darker multicolour for the sprites

		!byte $09		; starfield direction

		!byte $43		; enemy spawn speed

; Level 2 - attack wave data
wave_data_2	!byte $00,$00		; X and Y speed
		!byte $48		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $0a		; quota for this wave

		!byte $ff,$03		; X and Y speed
		!byte $c5		; colour
		!byte enemy_01_ast	; start and...
		!byte enemy_01_aed	; ...end frames for the animation
		!byte $0c		; quota for this wave

		!byte $01,$fd		; X and Y speed
		!byte $ee		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $0f		; quota for this wave

		!byte $ff,$02		; X and Y speed
		!byte $ce		; colour
		!byte enemy_01_ast	; start and...
		!byte enemy_01_aed	; ...end frames for the animation
		!byte $0f		; quota for this wave

		!byte $01,$fd		; X and Y speed
		!byte $55		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $10		; quota for this wave

		!byte $00,$03		; X and Y speed
		!byte $cc		; colour
		!byte rocket_down_ast	; start and...
		!byte rocket_down_aed	; ...end frames for the animation
		!byte $0a		; quota for this wave

		!byte $01,$01		; X and Y speed
		!byte $dd		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $05		; quota for this wave

		!byte $02,$ff		; X and Y speed
		!byte $d7		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $02		; quota for this wave

		!byte $01,$01		; X and Y speed
		!byte $77		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $05		; quota for this wave

		!byte $02,$ff		; X and Y speed
		!byte $d7		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $02		; quota for this wave

		!byte $01,$01		; X and Y speed
		!byte $dd		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $05		; quota for this wave

		!byte $ff,$fe		; X and Y speed
		!byte $33		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $0d		; quota for this wave

		!byte $7f		; end of data marker


; Level 3 - background data
level_data_3	!bin "binary\background.map",$3c,$078
		!byte $0b,$0e		; background colours
		!byte $66		; darker multicolour for the sprites

		!byte $02		; starfield direction

		!byte $3e		; enemy spawn speed

; Level 3 - attack wave data
wave_data_3	!byte $fe,$00		; X and Y speed
		!byte $cc		; colour
		!byte rocket_left_ast	; start and...
		!byte rocket_left_aed	; ...end frames for the animation
		!byte $08		; quota for this wave

		!byte $02,02		; X and Y speed
		!byte $ff		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $0a		; quota for this wave

		!byte $00,$00		; X and Y speed
		!byte $44		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $09		; quota for this wave

		!byte $00,$00		; X and Y speed
		!byte $88		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $10		; quota for this wave

		!byte $ff,$02		; X and Y speed
		!byte $ca		; colour
		!byte enemy_05_ast	; start and...
		!byte enemy_05_aed	; ...end frames for the animation
		!byte $13		; quota for this wave

		!byte $02,$00		; X and Y speed
		!byte $cc		; colour
		!byte rocket_rt_ast	; start and...
		!byte rocket_rt_aed	; ...end frames for the animation
		!byte $09		; quota for this wave

		!byte $01,$fd		; X and Y speed
		!byte $3f		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $14		; quota for this wave

		!byte $ff,$03		; X and Y speed
		!byte $ee		; colour
		!byte enemy_01_ast	; start and...
		!byte enemy_01_aed	; ...end frames for the animation
		!byte $10		; quota for this wave

		!byte $00,$fc		; X and Y speed
		!byte $e5		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $08		; quota for this wave

		!byte $00,$00		; X and Y speed
		!byte $48		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $0a		; quota for this wave

		!byte $7f		; end of data marker


; Level 4 - background data
level_data_4	!bin "binary\background.map",$3c,$0b4
		!byte $09,$0c		; background colours
		!byte $bb		; darker multicolour for the sprites

		!byte $05		; starfield direction

		!byte $39		; enemy spawn speed

; Level 4 - attack wave data
wave_data_4	!byte $02,$03		; X and Y speed
		!byte $ea		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $13		; quota for this wave

		!byte $01,$fd		; X and Y speed
		!byte $33		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $0c		; quota for this wave

		!byte $fe,$fc		; X and Y speed
		!byte $3f		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $10		; quota for this wave

		!byte $00,$05		; X and Y speed
		!byte $ff		; colour
		!byte rocket_down_ast	; start and...
		!byte rocket_down_aed	; ...end frames for the animation
		!byte $06		; quota for this wave

		!byte $00,$03		; X and Y speed
		!byte $cc		; colour
		!byte rocket_down_ast	; start and...
		!byte rocket_down_aed	; ...end frames for the animation
		!byte $06		; quota for this wave

		!byte $02,$fc		; X and Y speed
		!byte $aa		; colour
		!byte enemy_01_ast	; start and...
		!byte enemy_01_aed	; ...end frames for the animation
		!byte $0a		; quota for this wave

		!byte $00,$01		; X and Y speed
		!byte $ca		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $0f		; quota for this wave

		!byte $00,$fb		; X and Y speed
		!byte $ff		; colour
		!byte rocket_up_ast	; start and...
		!byte rocket_up_aed	; ...end frames for the animation
		!byte $14		; quota for this wave

		!byte $fe,$01		; X and Y speed
		!byte $dd		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $02,$ff		; X and Y speed
		!byte $d7		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $ff,$02		; X and Y speed
		!byte $77		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $03,$00		; X and Y speed
		!byte $d7		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $ff,$fc		; X and Y speed
		!byte $a5		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $11		; quota for this wave

		!byte $01,$fc		; X and Y speed
		!byte $ea		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $11		; quota for this wave

		!byte $7f		; end of data marker


; Level 5 - background data
level_data_5	!bin "binary\background.map",$3c,$0f0
		!byte $02,$0a		; background colours
		!byte $99		; darker multicolour for the sprites

		!byte $08		; starfield direction

		!byte $34		; enemy spawn speed

; Level 5 - attack wave data
wave_data_5	!byte $fe,$00		; X and Y speed
		!byte $ff		; colour
		!byte rocket_left_ast	; start and...
		!byte rocket_left_aed	; ...end frames for the animation
		!byte $10		; quota for this wave

		!byte $00,$05		; X and Y speed
		!byte $ff		; colour
		!byte rocket_down_ast	; start and...
		!byte rocket_down_aed	; ...end frames for the animation
		!byte $10		; quota for this wave

		!byte $03,$00		; X and Y speed
		!byte $cc		; colour
		!byte rocket_rt_ast	; start and...
		!byte rocket_rt_aed	; ...end frames for the animation
		!byte $10		; quota for this wave

		!byte $00,$fc		; X and Y speed
		!byte $ff		; colour
		!byte rocket_up_ast	; start and...
		!byte rocket_up_aed	; ...end frames for the animation
		!byte $10		; quota for this wave

		!byte $00,$00		; X and Y speed
		!byte $48		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $10		; quota for this wave

		!byte $00,$03		; X and Y speed
		!byte $cc		; colour
		!byte rocket_down_ast	; start and...
		!byte rocket_down_aed	; ...end frames for the animation
		!byte $10		; quota for this wave

		!byte $fe,$04		; X and Y speed
		!byte $dd		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $00,$04		; X and Y speed
		!byte $77		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $02,$04		; X and Y speed
		!byte $dd		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $02,$00		; X and Y speed
		!byte $77		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $02,$fc		; X and Y speed
		!byte $dd		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $00,$fc		; X and Y speed
		!byte $d7		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $fe,$fc		; X and Y speed
		!byte $77		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $fe,$00		; X and Y speed
		!byte $d7		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $00,$ff		; X and Y speed
		!byte $c5		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $00,$00		; X and Y speed
		!byte $88		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $08		; quota for this wave

		!byte $00,$01		; X and Y speed
		!byte $ce		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $02,$03		; X and Y speed
		!byte $ea		; colour
		!byte enemy_06_ast	; start and...
		!byte enemy_06_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $ff,$fb		; X and Y speed
		!byte $5a		; colour
		!byte enemy_06_ast	; start and...
		!byte enemy_06_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $00,$05		; X and Y speed
		!byte $ea		; colour
		!byte enemy_06_ast	; start and...
		!byte enemy_06_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $7f		; end of data marker


; Level 6 - background data
level_data_6	!bin "binary\background.map",$3c,$12c
		!byte $06,$0c		; background colours
		!byte $bb		; darker multicolour for the sprites

		!byte $06		; starfield direction

		!byte $2f		; enemy spawn speed

; Level 6 - attack wave data
wave_data_6	!byte $fd,$01		; X and Y speed
		!byte $d7		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $09		; quota for this wave

		!byte $01,$03		; X and Y speed
		!byte $33		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $0e		; quota for this wave

		!byte $fd,$00		; X and Y speed
		!byte $ff		; colour
		!byte rocket_left_ast	; start and...
		!byte rocket_left_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $ff,$ff		; X and Y speed
		!byte $ca		; colour
		!byte enemy_01_ast	; start and...
		!byte enemy_01_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $fe,$01		; X and Y speed
		!byte $c5		; colour
		!byte enemy_01_ast	; start and...
		!byte enemy_01_aed	; ...end frames for the animation
		!byte $04		; quota for this wave

		!byte $ff,$fe		; X and Y speed
		!byte $ce		; colour
		!byte enemy_01_ast	; start and...
		!byte enemy_01_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $01,$02		; X and Y speed
		!byte $ce		; colour
		!byte enemy_05_ast	; start and...
		!byte enemy_05_aed	; ...end frames for the animation
		!byte $15		; quota for this wave

		!byte $00,$fd		; X and Y speed
		!byte $cc		; colour
		!byte rocket_up_ast	; start and...
		!byte rocket_up_aed	; ...end frames for the animation
		!byte $08		; quota for this wave

		!byte $ff,$04		; X and Y speed
		!byte $ee		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $11		; quota for this wave

		!byte $02,$fd		; X and Y speed
		!byte $ff		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $0f		; quota for this wave

		!byte $fe,$03		; X and Y speed
		!byte $55		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $11		; quota for this wave

		!byte $00,$04		; X and Y speed
		!byte $aa		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $0a		; quota for this wave

		!byte $ff,$00		; X and Y speed
		!byte $55		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $09		; quota for this wave

		!byte $01,$00		; X and Y speed
		!byte $aa		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $09		; quota for this wave

		!byte $01,$04		; X and Y speed
		!byte $3f		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $01		; quota for this wave

		!byte $fe,$fd		; X and Y speed
		!byte $aa		; colour
		!byte enemy_01_ast	; start and...
		!byte enemy_01_aed	; ...end frames for the animation
		!byte $12		; quota for this wave

		!byte $7f		; end of data marker


; Level 7 - background data
level_data_7	!bin "binary\background.map",$3c,$168
		!byte $09,$05		; background colours
		!byte $22		; darker multicolour for the sprites

		!byte $01		; starfield direction

		!byte $2a		; enemy spawn speed

; Level 7 - attack wave data
wave_data_7	!byte $02,$fe		; X and Y speed
		!byte $dd		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $fd,$02		; X and Y speed
		!byte $77		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $fe,$fd		; X and Y speed
		!byte $dd		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $00,$fc		; X and Y speed
		!byte $77		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $02,$fd		; X and Y speed
		!byte $33		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $0f		; quota for this wave

		!byte $fd,$00		; X and Y speed
		!byte $ff		; colour
		!byte rocket_left_ast	; start and...
		!byte rocket_left_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $00,$fb		; X and Y speed
		!byte $ff		; colour
		!byte rocket_up_ast	; start and...
		!byte rocket_up_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $01,$fd		; X and Y speed
		!byte $aa		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $0e		; quota for this wave

		!byte $fe,$04		; X and Y speed
		!byte $33		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $02,$03		; X and Y speed
		!byte $5e		; colour
		!byte enemy_06_ast	; start and...
		!byte enemy_06_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $03,$00		; X and Y speed
		!byte $ff		; colour
		!byte rocket_rt_ast	; start and...
		!byte rocket_rt_aed	; ...end frames for the animation
		!byte $09		; quota for this wave

		!byte $00,$04		; X and Y speed
		!byte $ff		; colour
		!byte rocket_down_ast	; start and...
		!byte rocket_down_aed	; ...end frames for the animation
		!byte $09		; quota for this wave

		!byte $ff,$00		; X and Y speed
		!byte $ca		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $0b		; quota for this wave

		!byte $01,$00		; X and Y speed
		!byte $c5		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $0b		; quota for this wave

		!byte $00,$fe		; X and Y speed
		!byte $ce		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $0c		; quota for this wave

		!byte $02,$fd		; X and Y speed
		!byte $3f		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $0e		; quota for this wave

		!byte $fe,$02		; X and Y speed
		!byte $d7		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $0c		; quota for this wave

		!byte $ff,$fb		; X and Y speed
		!byte $ee		; colour
		!byte enemy_01_ast	; start and...
		!byte enemy_01_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $02,$04		; X and Y speed
		!byte $ff		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $0e		; quota for this wave

		!byte $01,$fc		; X and Y speed
		!byte $55		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $0c		; quota for this wave

		!byte $7f		; end of data marker


; Level 8 - background data
level_data_8	!bin "binary\background.map",$3c,$1a4
		!byte $0b,$0a		; background colours
		!byte $96		; darker multicolour for the sprites

		!byte $0a		; starfield direction

		!byte $25		; enemy spawn speed

; Level 8 - attack wave data
wave_data_8	!byte $02,$01		; X and Y speed
		!byte $ca		; colour
		!byte enemy_06_ast	; start and...
		!byte enemy_06_aed	; ...end frames for the animation
		!byte $06		; quota for this wave

		!byte $03,$ff		; X and Y speed
		!byte $c5		; colour
		!byte enemy_06_ast	; start and...
		!byte enemy_06_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $02,$02		; X and Y speed
		!byte $ca		; colour
		!byte enemy_06_ast	; start and...
		!byte enemy_06_aed	; ...end frames for the animation
		!byte $06		; quota for this wave

		!byte $03,$fe		; X and Y speed
		!byte $c5		; colour
		!byte enemy_06_ast	; start and...
		!byte enemy_06_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $02,$01		; X and Y speed
		!byte $ca		; colour
		!byte enemy_06_ast	; start and...
		!byte enemy_06_aed	; ...end frames for the animation
		!byte $06		; quota for this wave


		!byte $02,$04		; X and Y speed
		!byte $a5		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $0f		; quota for this wave

		!byte $ff,$04		; X and Y speed
		!byte $ae		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $0f		; quota for this wave


		!byte $00,$fb		; X and Y speed
		!byte $ff		; colour
		!byte rocket_up_ast	; start and...
		!byte rocket_up_aed	; ...end frames for the animation
		!byte $08		; quota for this wave

		!byte $fe,$00		; X and Y speed
		!byte $cc		; colour
		!byte rocket_left_ast	; start and...
		!byte rocket_left_aed	; ...end frames for the animation
		!byte $09		; quota for this wave

		!byte $fd,$00		; X and Y speed
		!byte $ff		; colour
		!byte rocket_left_ast	; start and...
		!byte rocket_left_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $02,$00		; X and Y speed
		!byte $cc		; colour
		!byte rocket_rt_ast	; start and...
		!byte rocket_rt_aed	; ...end frames for the animation
		!byte $09		; quota for this wave

		!byte $00,$fd		; X and Y speed
		!byte $cc		; colour
		!byte rocket_up_ast	; start and...
		!byte rocket_up_aed	; ...end frames for the animation
		!byte $09		; quota for this wave

		!byte $00,$04		; X and Y speed
		!byte $ff		; colour
		!byte rocket_down_ast	; start and...
		!byte rocket_down_aed	; ...end frames for the animation
		!byte $08		; quota for this wave

		!byte $ff,$03		; X and Y speed
		!byte $ce		; colour
		!byte enemy_05_ast	; start and...
		!byte enemy_05_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $00,$fd		; X and Y speed
		!byte $aa		; colour
		!byte enemy_03_ast	; start and...
		!byte enemy_03_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $02,$fe		; X and Y speed
		!byte $ca		; colour
		!byte enemy_06_ast	; start and...
		!byte enemy_06_aed	; ...end frames for the animation
		!byte $0a		; quota for this wave

		!byte $02,$03		; X and Y speed
		!byte $d7		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $fe,$fe		; X and Y speed
		!byte $ce		; colour
		!byte enemy_05_ast	; start and...
		!byte enemy_05_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $fe,$02		; X and Y speed
		!byte $3f		; colour
		!byte enemy_04_ast	; start and...
		!byte enemy_04_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $fd,$fe		; X and Y speed
		!byte $77		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $02,$02		; X and Y speed
		!byte $7d		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $05		; quota for this wave

		!byte $03,$ff		; X and Y speed
		!byte $dd		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $fe,$03		; X and Y speed
		!byte $7d		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $05		; quota for this wave

		!byte $03,$fe		; X and Y speed
		!byte $77		; colour
		!byte enemy_02_ast	; start and...
		!byte enemy_02_aed	; ...end frames for the animation
		!byte $03		; quota for this wave

		!byte $00,$00		; X and Y speed
		!byte $aa		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $07		; quota for this wave

		!byte $01,$fe		; X and Y speed
		!byte $5a		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $05		; quota for this wave

		!byte $ff,$fe		; X and Y speed
		!byte $55		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $05		; quota for this wave

		!byte $ff,$02		; X and Y speed
		!byte $e5		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $05		; quota for this wave

		!byte $01,$02		; X and Y speed
		!byte $ee		; colour
		!byte enemy_07_ast	; start and...
		!byte enemy_07_aed	; ...end frames for the animation
		!byte $05		; quota for this wave

		!byte $7f		; end of data marker


; End screen - background data
end_data	!bin "binary\background.map",$3c,$1e0
		!byte $09,$0b		; background colours
		!byte $2b		; darker multicolour for the sprites

		!byte $09		; starfield direction

		!byte $18		; enemy spawn speed

; End screen - attack wave data
end_wave_data	!byte $fe,$fc		; X and Y speed
		!byte $aa		; colour
		!byte player_ast	; start and...
		!byte player_aed	; ...end frames for the animation
		!byte $01		; quota for this wave

		!byte $00,$fc		; X and Y speed
		!byte $a5		; colour
		!byte player_ast	; start and...
		!byte player_aed	; ...end frames for the animation
		!byte $01		; quota for this wave

		!byte $02,$fc		; X and Y speed
		!byte $55		; colour
		!byte player_ast	; start and...
		!byte player_aed	; ...end frames for the animation
		!byte $01		; quota for this wave

		!byte $02,$04		; X and Y speed
		!byte $5e		; colour
		!byte player_ast	; start and...
		!byte player_aed	; ...end frames for the animation
		!byte $01		; quota for this wave

		!byte $00,$04		; X and Y speed
		!byte $ee		; colour
		!byte player_ast	; start and...
		!byte player_aed	; ...end frames for the animation
		!byte $01		; quota for this wave

		!byte $fe,$04		; X and Y speed
		!byte $ea		; colour
		!byte player_ast	; start and...
		!byte player_aed	; ...end frames for the animation
		!byte $01		; quota for this wave

		!byte $7f		; end of data marker
