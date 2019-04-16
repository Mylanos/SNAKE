%include "rw32-2018.inc"

; >>> Naimplemntujte hru Had <<<
; ================================================================================
; Had se bude moci pohybovat v ramci 2D prostoru pomoci klaves
; r-right, l-left, u-up, d-down. Hru lze kdykoliv ukoncit klavesou q.
; Pokud uzivatel zada jinou klavesu, bude vyzvan, aby akci opakoval a bude mu 
; vypsana kratka napoveda.
; Had bude pojidat znaky *, ktere predstavuji stavnate mysky.
; Had je bohuzel hodne vychrtly a snezeni vsech mysek ho nevytrhne.
; Proto nebude rust s poctem snezenych mysi. Pouze za sebou bude zanechavat
; toxickou caru v podobe znaku "o", ktera je jedovata i pro nej. Tzn. pokud had
; prejede svou caru, umre.

; Pokud si chcete hru jakkoliv upravit - rust hada misto toxicke cary,
; prulezove chodbicky, schnuti toxicke cary apod., meze se vam nekladou.
; Kriteria jsou nastaveny tak, aby hra nebyla slozita na implementaci.
;
; Doplnujte kod na vyznacena mista. U vyznacenych mist je popsan i postup, popr.
; napoveda.
;
; Funkce:
; - main    - ridici jadro hry
; - DrawMap - vykresli "map" jako 2D mapu (tak, jak ji vidite). Ve skutecnosti je
;             vsak definovana jako 1D pole hodnot (akorat rozdelena na radky).
; - Move    - bude pracovat s mapou "map". Provede pohyb hada o jednu pozici.
;           - Chova se podle toho, co se na dane pozici nachazi (jidlo, zed, cara, nic).


section .data
; 16bit konstanty pro funkci pohybu
LEFT  equ 0xFF00 ; Pohyb vlevo
RIGHT equ 0x0100 ; Pohyb vpravo
UP    equ 0x00FF ; Pohyb nahoru
DOWN  equ 0x0001 ; Pohyb dolu
; 8bit konstanty True, False
TRUE  equ 0x01
FALSE equ 0x00
; !!Pozor!! Nezapomente, jak pracovat s konstantou definovanou pomoci equ.

; Promenne - Vlastnosti mapy, hada a citac pro jidlo.
width    db 16   ; Sirka mapy
height   db 16   ; Vyska mapy
pos_x    db 1    ; Aktualni pozice na ose X (pozice hlavicky)
pos_y    db 1    ; Aktualni pozice na ose Y (pozice hlavicky)
food     db 0    ; Pocet snezenych jidel
food_max db 8    ; Maximalni pocet jidel, ktere lze snist

; Hlasky
msg_welcome  db "!! Welcome to the Snake Game !!", 0
msg_gameover db ">>> Game Over <<<", 0
msg_summary  db "Had sezral X z Y mysi.", 0
msg_help     db "Povolene znaky: r-right, l-left, u-up, d-down, q-escape.", 0

; * v mape znaci zradylko pro hada
; Pokud narazi na stenu nebo olizne svou toxickou caru, umre :-( A to fakt nechces!
; Pro vypocet indexu v ramci "map" budeme brat "map" jako 1D pole (ptz to je 1D pole).
; Pri tisku ale budeme uvazovat 2D pole (tj. vytisknete mapu tak, jak ji vidite).
map    db "+--------------+"
       db "|              |"
       db "|     *        |"
       db "|              |"
       db "|        *     |"
       db "|              |"
       db "|     *  *     |"
       db "|              |"
       db "|              |"
       db "|*             |"
       db "|            * |"
       db "|              |"
       db "|    *         |"
       db "|              |"
       db "|         *    |"
       db "+--------------+"

section .text
   global main
main:
    mov ebp, esp; for correct debugging
   ; vytvoreni zasobnikoveho ramce
   push ebp
   mov ebp, esp

   ; Tisk uvitaci hlasky
   mov esi, msg_welcome
   call WriteString
   call WriteNewLine

   ; Usazeni hada "O" na pocatecni pozici v "map"
   ; @ Provedte vypocet pozice v ramci 1D "map".
   ;   eax = width*pos_y + pos_x
   ; *** ZDE DOPLNTE VAS KOD ***
   xor eax, eax
   mov al, [width]
   mov bl, [pos_y]
   mul bl
   movsx bx, byte [pos_x]
   add ax, bx
   
   ; Posad hlavu hada na vypoctenou pozici (1, 1) v "map"

                         
   mov byte [map+eax], "0"
   
.game_loop:
   xor eax, eax
   ; @ Implementujte:
   ; game_loop:
   ;
   ; DrawMap();
   ; al = ReadChar();
   ; switch(al)
   ; {
   ;    case "u":
   ;      al = Move(UP);
   ;      if (al == TRUE)
   ;        goto game_over;
   ;
   ;    case "d":
   ;      al = Move(DOWN);
   ;      if (al == TRUE)
   ;        goto game_over;
   ;
   ;    case "l":
   ;      al = Move(LEFT);
   ;      if (al == TRUE)
   ;        goto game_over;
   ;
   ;    case "r":
   ;      al = Move(RIGHT);
   ;      if (al == TRUE)
   ;        goto game_over;
   ;
   ;    case "q":
   ;      goto game_over;
   ;    default:
   ;      WriteString(msg_help)
   ;      goto game_loop;
   ; }
   ; game_over:
   ; ...
   ; *** ZDE DOPLNTE VAS KOD ***
   call DrawMap
   
   call ReadChar

.switch:
   cmp al, "u"
   je .Ucase
   cmp al, "d"
   je .Dcase
   cmp al, "l"
   je .Lcase
   cmp al, "r"
   je .Rcase
   cmp al, "q"
   je .Qcase
.default:
   mov esi, msg_help
   call WriteString
   call WriteNewLine
   jmp .game_loop   

.Qcase:
   jmp .game_over      
.Ucase:
   push UP
   call Move
   jmp .compareAL 
.Dcase:
   push DOWN
   call Move
   jmp .compareAL
.Lcase:
   push LEFT
   call Move
   jmp .compareAL
.Rcase:
   push RIGHT
   call Move
 
.compareAL:   
   cmp al, TRUE
   jne .continue
   jmp .game_over
.continue:   
   jmp .game_loop 
   
.game_over: ;12 a 16
   ; Vypis Game Over
   mov esi, msg_gameover
   call WriteString
   call WriteNewLine

   ; @ Modifikujte X a Y v "msg_summary" a vytisknete.
   ; Hint: K cislum, ktere dosazujete za X a Y je nutne jeste
   ; neco pricist - viz ASCI tabulka.
   ; *** ZDE DOPLNTE VAS KOD ***
   add byte [food], 48
   add byte [food_max], 48
   mov bl, [food]
   mov byte [msg_summary+11], bl    ;X
   mov bl, [food_max]
   mov byte [msg_summary+15], bl    ;Y
   mov esi, msg_summary
   call WriteString
   call WriteNewLine

   ; Zaverecne vykresleni "map"
   call DrawMap
   ; zniceni zasobnikoveho ramce
   mov esp, ebp
   pop ebp
   ret

; Funkce vykresli promennou "map" jako 2D mapu.
; Nema zadne vstupy ani vystupy.
DrawMap:
   ; vytvoreni zasobnikoveho ramce
   push ebp
   mov ebp, esp
   pushad
   
    ; Ukol 1:
    ; @ Vykreslete 2D mapu ulozenou v promenne "map"
    ; Pouzijte tyto funkce: WriteChar, WriteNewLine.
    ;
    ; esi = map;
    ; WriteNewLine();
    ; for (cl = *height; cl > 0;  cl--) // rows
    ; {
    ;   for (ch = *width; ch > 0; ch--) // cols
    ;   {
    ;      al = *esi;
    ;      WriteChar();
    ;      esi++;
    ;   }
    ;
    ;   WriteNewLine();
    ; }
    ; Pozn. *height => v asm. [height] => hodnota
    ;
    ; *** ZDE DOPLNTE VAS KOD ***
    mov esi, map
    mov cl, [height] ;cl = *height;
    dec cl
.outercycle:
    cmp cl, 0  ; cl > 0
    jl .end
    
    mov bl, [width]
    dec bl
    .innercycle:
        cmp bl, 0
        jl .endinner
        
        mov al, [esi]
        call WriteChar
        inc esi 
        dec bl
        
        jmp .innercycle
    .endinner:
    call WriteNewLine

    dec cl
    jmp .outercycle
.end:

   ; zniceni zasobnikoveho ramce
   popad
   mov esp, ebp
   pop ebp
   ret

; Funkce provede pohyb hada ve 2D mape o jednu pozici. Smer je urceny parametrem funkce.
; Vstup  - parametr predany na zasobnik urcujici smer pohybu (konstanta UP, DOWN, ...)
; Vystup - registr AL (AL==FALSE, vse ok, pokracuj ve hre; AL==TRUE, ukonci hru)
; Uvazujte konvenci stdcall.
Move:
   ; @ Vytvorte zasobnikovy ramec
   ; *** ZDE DOPLNTE VAS KOD ***
   push ebp
   mov ebp, esp

   push edx
   push ecx
   push ebx

   xor eax, eax
   xor ebx, ebx

   ; Vypocet aktualni pozice v ramci 1D pole ("map")
   ;   ebx = (width*pos_y)+pos_x
   mov al, [width]
   imul byte [pos_y] ; ah:al <- al*pos_y
   movsx eax, ax     ; eax <- ax. Convert word to dword with the sign extension.
   movzx ebx, byte [pos_x]
   add ebx, eax
   ; Zmena hlavicky na toxickou caru
   mov byte [map+ebx], "o"

   ; @ Provedte vypocet nasledujici pozice:
   ; dir = EBP[8] // parametr funkce
   ; // dir lze rozdelit na dir_y a dir_x
   ; ebx = (width * (pos_y+dir_y)) + (pos_x+dir_x)
   ; *** ZDE DOPLNTE VAS KOD ***
   mov edx, eax ;ulozenie si eax(moze sa zmenit pri nasobeni)
   mov cx, [ebp+8]  ; v ch mam dir_x v cl mam dir_y
   xor eax, eax
   mov al, [width]  ;al = width
   mov bl, [pos_y]  ;bl = pos_y
   add bl, cl   ;pos_y+dir_y
   imul bl      ;width * (pos_y+dir_y
   add ch, [pos_x]  ;pos_x+dir_x
   movsx cx, ch
   add ax, cx       ;(width * (pos_y+dir_y)) + (pos_x+dir_x)
   mov ebx, eax     ;ulozenie vysledku vypoctu 
   mov eax, edx     ;vlozenie povodnej hodnoty
   

   ; Overte, co je na nasledujici pozici?
   ;    al = map[ebx];
   ;    if (al == " ") // mezera?
   ;       map[ebx] = "O";
   ;       if (food == food_max)
   ;           al = TRUE;
   ;           goto game_over;
   ;       else
   ;           al = FALSE;
   ;    else if (al == "*") // zradylko?
   ;       food++;
   ;       map[ebx] = "O";
   ;       if (food == food_max)
   ;           al = TRUE;
   ;           goto game_over;
   ;       else
   ;           al = FALSE;
   ;    else
   ;       al = TRUE
   ;       goto game_over
   ;
   ;    if (food == food_max)
   ;       al = TRUE;
   ;       goto game_over
   ;    else
   ;       al = FALSE;
   ;
   ; Pokud je game_over, zapiste na policko znak "X" znacici naraz.
   ; *** ZDE DOPLNTE VAS KOD ***
   mov al, [map+ebx]
 
mainIf:  
   cmp al, " "      ; (al == " ")
   jne .mainElseIf
   mov byte [map+ebx], "0"
   jmp .actualPosition
.mainElseIf:
   cmp al, "*"      ;(al == "*")
   jne .mainElse
   add byte [food], 1   ;narazil na jedlo
   mov byte [map+ebx], "0"
   jmp .actualPosition
.mainElse:
   mov al, TRUE
   jmp .end

.actualPosition: 
   mov cl, 0  
   mov byte [pos_y], cl
.cycle:
   cmp ebx, 16
   jl .addX
.addY:
   sub ebx, 16
   add byte [pos_y], 1      
   jmp .cycle
.addX:
   mov byte[pos_x], bl 
   
.food:
   mov dl, [food_max]
   cmp [food], dl
   jne .nowin
   mov al, TRUE
   jmp .end
.nowin:
   mov al, FALSE

.end:
   pop ebx
   pop ecx
   pop edx
   ; @ Znicte zasobnikovy ramec
   ; *** ZDE DOPLNTE VAS KOD ***
   mov esp, ebp
   pop ebp
   ret 4


