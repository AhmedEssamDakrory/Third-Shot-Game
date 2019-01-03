include DrawWithColour.INC
.MODEL LARGE
.STACK 64

.DATA
;-----------------------------------------------------------------------------------------------------  

SENDPOS DW 0200H  ;postion of the cursor to write sent data
RECPOS DW 0F00H   ;position of the cursor to write received data  
value db ?
   
SentData   DB  ?
RecData    DB  ?
WaitInv    DB  'Waiting for other player response...$'
GameInv    DB  ' sent you game invitation$'   
ChatInv    DB  ' sent you chat invitation$'
AcceptInv  DB  'Press enter to accept invitation$'
RefuseInv  DB  'Press down to return to main menu$'


          ;x1  ;y1   ;x2   ;y2   ;xm   ;ym
Pl1Pos DW 6 DUP(?) 
Pl2Pos DW 6 DUP(?) 

InitialPl1Pos DW 0096H,0000h,00A0H,000AH,009BH,000fh 
InitialPl2Pos DW 0096H,00A9h,00A0H,00B3H,009BH,00A4h

BlockPosX dw 10 dup(?) ;to store the positions of blocks first  row(x1 of the up_left corner,we know the width and highet ) *height

CLRS1           DB  10 DUP(?)
INITIALCLRS1    DB  0FH , 8 , 8 , 0FH , 8 , 0FH , 8 , 4 , 8 , 0FH
CLRS21          DB  10 DUP(?)
INITIALCLRS21   DB  0FH , 8 , 8 , 0FH , 8 , 0FH , 8 , 4 , 8 , 0FH
CLRS22          DB  10 DUP(?)
INITIALCLRS22   DB  8 , 0FH , 0FH , 8 , 4 , 8 , 8 , 0FH , 8 , 0FH

WIDTH EQU 28
HIGHT EQU 8 

Xpoint1  DW  ?
Xpoint2  DW  ?

Plyr1 LABEL BYTE

PL1SIZE DB 20      ;IN THE DOSBOS , WHEN THE USER ENTER A NAME WITH SIZE GREATER THAN OR EQUAL THE MAX SIZE
                   ;IT STOPS AND DOESN'T RESPOND TO ANY ACTION
                   ;SO I MADE THE MAX SIZE = 20 , NO ONE ENTER A USERNAME WITH SIZE GREATER THAN THAT ONE 
                   ;I SUPPOSE THAT "_"   
ACT1SIZE DB 0
PL1NAME DB 0DH , 19 DUP('$')

Plyr2 LABEL BYTE

PL2SIZE DB 20
ACT2SIZE DB 0
PL2NAME DB 0DH , 19 DUP('$')

HEART1POS DW ?
HEART2POS DW ?

SCORE1POS       DW      ?
SCORE2POS       DW      ?

PLNAME_ DB 'Your Name : $'

WaitPl2  DB 'Waiting for Player2 to join...$'

Pl1Health DW 3
Pl2Health DW 3

PLWON  DB  'Congratulations!$Winner: $Loser: $'
PLLOSE DB  'Bad Luck!$$$$$$$$Loser: $$Winner: $'

;start menu messages
start db 'Enter: send a game invitation (:$ '
chat db 'C: send a chatting invitation ^^$'
exitt db   'BackSpace: exit *_*$'
ENDText     DB  'Press any key to return to main menu$'  
LVL2TEXT    DB  'Press any key to go to level 2$'
DRAWTEXT    DB  'It`s a Draw!'

LVLNO       DB  1
PL1SCORE    DB  ?
PL2SCORE    DB  ?

;-----------------------------------------------------------------------------------------------------     
.code

MAIN proc far
     MOV ax , @data
     MOV ds ,ax
     
    ;initialization of ports
    MOV DX,3FBH
    MOV AL,10000000B
    OUT DX,AL
    
    MOV DX,3F8H
    MOV AL,0CH
    OUT DX,AL
    
    MOV DX,3F9H
    MOV AL,00h
    OUT DX,AL
    
    MOV DX,3FBH
    MOV AL,00011011B
    OUT DX, AL
     
       
     ;graphicAL mode  
     MOV BH, 0
     MOV ah , 0
     MOV AL , 13h
     INT 10h
     
     ;Enter username 
     
GetUser1:
      
    CMP Act1Size, 0
    JZ EnterUS1
    JNZ WaitForConn
    
EnterUS1:
    
    CALL UserName1
    JMP GetUser1   

WaitForConn:
    CALL WaitPl2Connect
    ;Recieve Username 2
    CALL RecieveUserName2
    ;Send username1
    CALL SendUserName1
                                  
                                  
MainMenu: 
  
  
     ;INITAILZING ALL VARIABLES
     MOV SI , 0
     MOV CX , 6
     T:   
     
       MOV AX , InitialPl1Pos[SI]
       MOV Pl1Pos[SI] , AX
       MOV AX , InitialPl2Pos[SI] 
       MOV Pl2Pos[SI] , AX
       INC SI
       INC SI
     
     LOOP T
     
     MOV CX , 10
     MOV SI , 0
     T2:
     
       MOV AL, INITIALCLRS1[SI]
       MOV CLRS1[SI] , AL
       MOV AL, INITIALCLRS21[SI]
       MOV CLRS21[SI], AL
       MOV AL, INITIALCLRS22[SI]
       MOV CLRS22[SI], AL
       INC SI
     
     LOOP T2 
      
     MOV PL1SCORE, 0
     MOV PL2SCORE, 0
     MOV Pl1Health , 3
     MOV Pl2Health , 3
     MOV SendPos, 0200H
     Mov RecPos,  0F00H

     MOV LVLNO, 1
     
     ;graphicAL mode  
     MOV BH, 0
     MOV ah , 0
     MOV AL , 13h
     INT 10h
    

GetInput:     
     ;graphicAL mode  
     MOV BH, 0
     MOV ah , 0
     MOV AL , 13h
     INT 10h
     
     ;moving cursor
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 4D
     MOV DH, 10D
     INT 10H
     
     push dx
     
     ;printing messages 
     mov ah , 9
     lea dx , start
     int 21h
   
     
     pop dx  
     
     ;moving cursor one step down
     add dh,2 
     MOV BH, 0                             
     MOV AH, 2
     INT 10H 
     
     push dx 
     
     ;printing message
     
     mov ah , 9
     lea dx , chat
     int 21h
     
     pop dx 
     
     ;moving cursor one step down
     add dh,2 
     MOV BH, 0                             
     MOV AH, 2
     INT 10H 
     
     ;printing message 
     mov ah , 9
     lea dx , exitt
     int 21h
   
    
     ;b7ut feha ay 7aga msh ha-check 3leha
     MOV SentData, '='
     MOV RecData,  '='
      
     ;Get key pressed(wait an input from keyboard) 
     CALL SendOrRec
     
     MOV LVLNO,1
     
     ;graphicAL mode  
     MOV BH, 0
     MOV ah , 0
     MOV AL , 13h
     INT 10h
     
     cmp SentData, 1CH
     jz SendInv
     
     cmp SentData , 2Eh
     jz SendInvChat 
     
     cmp SentData , 0EH
     jz exit
     
     CMP RecData, 1CH
     JZ RecInv
     
     cmp RecData,2Eh
     jz RecInvChat
     
     CMP RecData, 0EH
     JZ exit
     
     JMP GetInput
;-------------------------------------------------------------

SendInvChat:
     
     ;moving cursor
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 2D
     MOV DH, 10D
     INT 10H 
     
     ;PRINTING MESSAGE
     MOV AH, 9
     LEA DX, WaitInv
     INT 21H
   
    ;wait till invitation is accepted 
    MOV RecData, '='
   
    CALL SendAndRec
      
    CMP RecData, 1CH
    jnz nochat
    
    call chat_ ;go to chat
    jmp MainMenu 
    
    nochat:
    ;if down is pressed, return to getInput      
    CMP RecData, 50H
    JZ GetInput
   
    JNZ SendInvChat   
;-------------------------------------------------------------------------------------------------------

RecInvChat:
     
     MOV SentData, '='
     
     ;moving cursor
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 2D
     MOV DH, 10D
     INT 10H 
     
     ;PRINTING MESSAGE
     MOV AH, 9
     LEA DX, PL2Name
     ADD DX, 2
     INT 21H
     DEC DX
     LEA DX, ChatInv   
     INT 21H
     
     ;moving cursor
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 2D
     MOV DH, 12D
     INT 10H
     
     ;PRINTING MESSAGE
     MOV AH, 9
     LEA DX, AcceptInv
     INT 21H
     
     ;moving cursor
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 2D
     MOV DH, 14D
     INT 10H
     
     ;PRINTING MESSAGE
     MOV AH, 9
     LEA DX, RefuseInv
     INT 21H
     
   ;wait till invitation is accepted 
   CALL SendAndRec
   
   CMP SentData, 1CH
   JNZ nochat2
   
   call chat_
   jmp MainMenu
   
   
   nochat2:
   ;if down is pressed, return to getInput       
   CMP SentData, 50H
   JZ GetInput
   
   JNZ RecInvChat    
           
    
;-----------------------------------------------------------------------------------------------------     
SendInv:
     
     ;moving cursor
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 2D
     MOV DH, 10D
     INT 10H 
     
     ;PRINTING MESSAGE
     
     MOV AH, 9
     LEA DX, WaitInv
     INT 21H
   
   ;wait till invitation is accepted 
   MOV RecData, '='
   
   CALL SendAndRec
      
   CMP RecData, 1CH
   JZ ST
          
   CMP RecData, 50H
   JZ GetInput
   
   JNZ SendInv    
     
;-----------------------------------------------------------------------------------------------------     
RecInv:
     
     MOV SentData, '='
     
     ;moving cursor
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 2D
     MOV DH, 10D
     INT 10H 
     
     ;PRINTING MESSAGE
     MOV AH, 9
     LEA DX, PL2Name
     ADD DX, 2 
     INT 21H         
     DEC DX
     LEA DX, GameInv
     INT 21H
     
     ;moving cursor
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 2D
     MOV DH, 12D
     INT 10H
     
     ;PRINTING MESSAGE
     MOV AH, 9
     LEA DX, AcceptInv
     INT 21H
     
     ;moving cursor
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 2D
     MOV DH, 14D
     INT 10H
     
     ;PRINTING MESSAGE
     MOV AH, 9
     LEA DX, RefuseInv
     INT 21H
     
   ;wait till invitation is accepted 
   CALL SendAndRec
   
   CMP SentData, 1CH
   JZ ST
          
   CMP SentData, 50H
   JZ GetInput
   
   JNZ RecInv    
     
;-----------------------------------------------------------------------------------------------------     
     
 ST: 
    ;graphicAL mode
     MOV BH, 0
     MOV ah , 0
     MOV AL , 13h
     INT 10h 
    
;-----------------------------------------------------------------------------------------------------     
     
     ;drawing status bar
     
     call DrawStatusBar 
     
     ;drawing the tow players in their initiAL positions
     ;parameters... two poINTs and colour
     
     DrawWithColour Pl1Pos,Pl1Pos[2],Pl1Pos[4],Pl1Pos[6],5h
     DrawWithColour Pl1Pos[8],Pl1Pos[2],Pl1Pos[8],Pl1Pos[10],5h
     DrawWithColour Pl2Pos,Pl2Pos[2],Pl2Pos[4],Pl2Pos[6],5h
     DrawWithColour Pl2Pos[8],Pl2Pos[10],Pl2Pos[8],Pl2Pos[2],5h
     
     ;drawing blocks
    
     CALL DRAW_BLOCKS
     
     
;-----------------------------------------------------------------------------------------------------     

     ;play as long as you you don't press Esc key 
     
CHECK:   
     ;b7ut feha ay 7aga msh ha-check 3leha
     MOV SentData, '='
     MOV RecData, '='
     
     ;Read data, sent or recieved
     CALL SendAndRec 
     
     ;check ReceivedData ----------------------------------------------------
     
     ;click enter => inline chat
     
     CMP RecData , 1ch
     JZ  InLineChattingRec
     
     ;right button
     CMP RecData,4DH
     JZ right2
      
     ;left button
     CMP RecData,4BH
     JZ left2
     
     ;up button
     CMP RecData, 48H
     JZ Shoot2
     
     ;escape button
     CMP RecData,0EH
     JZ MainMenu
     
     ;check SentData------------------------------------------------------
     
     cmp SentData , 1ch
     jz InLineChattingSend 
     
     ;right button
     CMP SentData,4DH
     JZ right
     
     ;left button
     CMP SentData,4BH
     JZ left  
     
     ;up button
     CMP SentData, 48H 
     JZ Shoot1
     
     ;escape button
     CMP SentData,0EH
     JZ MainMenu        
              
     ;mfe4 7aga sent aw recieved
     JMP CHECK
     
;-----------------------------------------------------------------------------------------------------

InLineChattingSend:

    call InLineChatSend   ;go to inline chat
    call DrawStatusBar
    jmp CHECK

InLineChattingRec:

    call InLineChatReceive   ;go to inline chat
    call DrawStatusBar
    jmp CHECK
        
     
;-----------------------------------------------------------------------------------------------------     
right: 

     CMP Pl1Pos[4],320d   ;reaching right edge... no action
     JZ CHECK  
     
     ;clearing
     
     DrawWithColour Pl1Pos[8],Pl1Pos[6],Pl1Pos[8],Pl1Pos[10],0h  ;reMOVing the most left column
     DrawWithColour Pl1Pos,Pl1Pos[2],Pl1Pos,Pl1Pos[6],0h         ;reMOVing L_madf3 *_*
     
     MOV bx,0
     MOV si,3
     
     ShiftEachXRight:   ;INCrementing Xs
     
         INC Pl1Pos[bx]
     
         ADD bx,4   ;Xs only 
         DEC si
         CMP si,0
         JNZ ShiftEachXright
     
     ;redrawing cleared areas
     
     DrawWithColour Pl1Pos[8],Pl1Pos[6],Pl1Pos[8],Pl1Pos[10],5h ;draw another column in the right side instead of the one has reMOVed from the left recently 
     DrawWithColour Pl1Pos[4],Pl1Pos[2],Pl1Pos[4],Pl1Pos[6],5h  ;draw L_madf3 in the new center (shifted one)  thus we MOVed one step to the right
     
      
      
     JMP CHECK
     
;-----------------------------------------------------------------------------------------------------     
left:

     CMP Pl1Pos , 0h   ;reaching left edge... no action
     JZ CHECK  
     
     ;clearing
     
     DrawWithColour Pl1Pos[8],Pl1Pos[6],Pl1Pos[8],Pl1Pos[10],0h          ;reMOVing the most right column
     DrawWithColour Pl1Pos[4],Pl1Pos[2],Pl1Pos[4],Pl1Pos[6],0h           ;reMOVing L_madf3 ^_^ *_*
     
     MOV bx,0
     MOV si,3
     
     
     ShiftEachXLeft:  ;DECrementing Xs
     
         DEC Pl1Pos[bx]
                      ;Xs only ..don't forget!!!
         ADD bx,4
         DEC si
         CMP si,0
         JNZ ShiftEachXLeft
     
     ;redrawing cleared areas
     
     ;draw another column in the left side instead of the one has reMOVed from the right recently 
     ;draw L_madf3 in the new center (shifted one)  thus we MOVed one step to the left
     
     DrawWithColour Pl1Pos[8],Pl1Pos[6],Pl1Pos[8],Pl1Pos[10],5h
     DrawWithColour Pl1Pos,Pl1Pos[2],Pl1Pos,Pl1Pos[6],5h
            
     JMP CHECK
     
;-----------------------------------------------------------------------------------------------------     
right2:
        
     CMP Pl2Pos[4],320d   ;reaching right edge... no action
     JZ CHECK  
     
     ;clearing
     
     DrawWithColour Pl2Pos[8],Pl2Pos[10],Pl2Pos[8],Pl2Pos[2],0h  ;reMOVing the most left column
     DrawWithColour Pl2Pos,Pl2Pos[2],Pl2Pos,Pl2Pos[6],0h         ;reMOVing L_madf3 *_*
     
     MOV bx,0
     MOV si,3
     
     ShiftEachX2Right:   ;INCrementing Xs
     
        INC Pl2Pos[bx]
     
        ADD bx,4   ;Xs only 
        DEC si
        CMP si,0
        JNZ ShiftEachX2right
     
     ;redrawing cleared areas
     
     DrawWithColour Pl2Pos[8],Pl2Pos[10],Pl2Pos[8],Pl2Pos[2],5h ;draw another column in the right side instead of the one has reMOVed from the left recently 
     DrawWithColour Pl2Pos[4],Pl2Pos[2],Pl2Pos[4],Pl2Pos[6],5h  ;draw L_madf3 in the new center (shifted one)  thus we MOVed one step to the right
     
     JMP CHECK
;----------------------------------------------------------------------------------------------------------------------------------------------------------     
left2:

     CMP Pl2Pos , 0h   ;reaching left edge... no action
     JZ CHECK  
     
     ;clearing
     
     DrawWithColour Pl2Pos[8],Pl2Pos[10],Pl2Pos[8],Pl2Pos[2],0h          ;reMOVing the most right column
     DrawWithColour Pl2Pos[4],Pl2Pos[2],Pl2Pos[4],Pl2Pos[6],0h           ;reMOVing L_madf3 ^_^ *_*
     
     MOV bx,0
     MOV si,3
     
     ShiftEachX2Left:  ;DECrementing Xs
     
         DEC Pl2Pos[bx]
                      ;Xs only ..don't forget!!!
         ADD bx,4
         DEC si
         CMP si,0
         JNZ ShiftEachX2Left
     
     ;redrawing cleared areas
     
     ;draw another column in the left side instead of the one has reMOVed from the right recently 
     ;draw L_madf3 in the new center (shifted one)  thus we MOVed one step to the left
     
     DrawWithColour Pl2Pos[8],Pl2Pos[10],Pl2Pos[8],Pl2Pos[2],5h
     DrawWithColour Pl2Pos,Pl2Pos[2],Pl2Pos,Pl2Pos[6],5h
            
     JMP CHECK
      
;-------------------------------------------------------------------    
Shoot1:

     MOV CX, Pl1Pos[8]
     MOV DX, Pl1Pos[10]
     MOV BL, 1	;player 1 is shooting 
     
     PUSH Pl2Pos
     PUSH Pl2Pos[4]
	        
     CALL ShootPlayer
     
     ;Clear Hearts of Player2 JIC
     MOV AX, 0
     MOV BL, 2
     CALL DrawHealth
     
     ;Draw new health of player2
     POP BX  
     ADD PL1SCORE, BL
     MOV AX, Pl2Health
     SUB AX, BX       
     MOV Pl2Health, AX
     ;CHECK IF PLAYER1 WON
     MOV AX, Pl2Health
     CMP AX, 0
     MOV BL, 1
     JZ WIN
     
     MOV BL, 2  
     CALL DrawHealth
     
     
     JMP CHECK                                              
;--------------------------------------------------------------------     
Shoot2:

     MOV CX, Pl2Pos[8]
     MOV DX, Pl2Pos[10]
     MOV BL, 2	;player2 is shooting
     PUSH Pl1Pos
     PUSH Pl1Pos[4]
	        
     CALL ShootPlayer
     ;Clear Hearts of Player1 JIC
     MOV AX, 0
     MOV BL, 1
     CALL DrawHealth
     
     ;Draw new health of player1
     POP BX   ;pop the value last pushed in the stack (one if the shot hit zero if no)
     ADD PL2SCORE, BL
     MOV AX, Pl1Health
     SUB AX, BX ;if hit then it will decrease by one       
     MOV Pl1Health, AX
     ;CHECK IF PLAYER1 WON
     MOV AX, Pl1Health
     CMP AX, 0
     MOV BL, 2
     JZ  WIN
     
     MOV BL, 1
     CALL DrawHealth
     JMP CHECK
     
;--------------------------------------------------------------------
WIN:
       ;graphicAL mode
        MOV BH, 0
        MOV ah , 0
        MOV AL , 13h
        INT 10h
       
       MOV AH, 2
       MOV DL, 2D
       MOV DH, 10D
       INT 10H
       
       CMP BL, 1
       JZ WIN1
       JNZ WIN2
       
       ;PUSH CX
;       MOV CH, PL1SCORE
;       MOV CL, PL2SCORE
;       CMP CH, CL
;       POP CX
;       JZ DRAW
;       JS WIN2
       
   WIN1:
       MOV BX, OFFSET PLWON
       PUSH BX
       MOV AH, 9
       MOV DX, BX
       INT 21H  
       
       ;NEXT LINE
       MOV BH, 0
       MOV AH, 2
       MOV DL, 2D
       MOV DH, 12D
       INT 10H
              
       POP BX       
       MOV AH, 9
       ADD BX, 17D
       PUSH BX
       MOV DX, BX
       INT 21H  
       
       MOV DX, OFFSET PL1NAME
       ADD DX, 2
       INT 21H
       ;NEXT LINE
       MOV BH, 0
       MOV AH, 2
       MOV DL, 2D
       MOV DH, 14D
       INT 10H
       
       POP BX
       MOV AH, 9
       ADD BX, 9D
       MOV DX, BX
       INT 21H
       
       MOV DX, OFFSET PL2NAME
       ADD DX, 2
       INT 21H
       
       CMP LVLNO, 1
       JZ GOTOLVL2
       JMP PRESS_KEY   
         
   WIN2:    
       MOV BX, OFFSET PLLOSE
       PUSH BX
       MOV AH, 9
       MOV DX, BX
       INT 21H  
       
       ;NEXT LINE
       MOV BH, 0
       MOV AH, 2
       MOV DL, 2D
       MOV DH, 12D
       INT 10H
              
       POP BX       
       MOV AH, 9
       ADD BX, 17D
       PUSH BX
       MOV DX, BX
       INT 21H  
       
       MOV DX, OFFSET PL1NAME
       ADD DX, 2
       INT 21H
       ;NEXT LINE
       MOV BH, 0
       MOV AH, 2
       MOV DL, 2D
       MOV DH, 14D
       INT 10H
       
       POP BX
       MOV AH, 9
       ADD BX, 9D
       MOV DX, BX
       INT 21H
       
       MOV DX, OFFSET PL2NAME
       ADD DX, 2
       INT 21H
       
       CMP LVLNO, 1
       JZ GOTOLVL2
       JMP PRESS_KEY
       
       
;DRAW:  
;       MOV BH, 0
;       MOV AH, 2
;       MOV DL, 2D
;       MOV DH, 14D
;       INT 10H
;         
;       MOV BX, OFFSET DRAWTEXT
;       PUSH BX
;       MOV AH, 9
;       MOV DX, BX
;       INT 21H
;       
;       CMP LVLNO, 1
;       JZ GOTOLVL2
;       JMP PRESS_KEY 
       
GOTOLVL2:
     INC LVLNO
     MOV PL1HEALTH, 3
     MOV PL2HEALTH, 3
        
     ;Clear buffer
     MOV ah,0ch
     MOV AL,0
     INT 21h
     
     ;PRESS ANY KEY TO CONTINUE
     MOV BH, 0
     MOV AH, 2
     MOV DL, 2D
     MOV DH, 16D
     INT 10H
     
     MOV DX, OFFSET LVL2TEXT
     MOV AH, 9
     INT 21H
     
     CALL SendOrRec
     JMP ST
       
;--------------------------------------------------------------------    
PRESS_KEY:
     ;Clear buffer
     MOV ah,0ch
     MOV AL,0
     INT 21h
     
     ;PRESS ANY KEY TO CONTINUE
     MOV BH, 0
     MOV AH, 2
     MOV DL, 2D
     MOV DH, 16D
     INT 10H
     
     MOV DX, OFFSET ENDText
     MOV AH, 9
     INT 21H
     
     CALL SendOrRec
     
     jmp MainMenu

exit:
     
     ;Clear Screen
     MOV BH, 0
     MOV AH, 0 
     MOV AL, 0
     INT 10H
     
     MOV AH , 0X4C
     INT 0X21
      
      
MAIN ENDP  

;====================================================================
;               --PROCEDURES--
;====================================================================
ShootPlayer     PROC     
    
    ;ASSUMPTIONS:
    ;CX=XSHOOTER, DX=YSHOOTER, X1,X2 OF OPONENT ARE PUSHED IN STACK, BL=FLAG 
    
    ;PREPARE VARIABLES
    
	MOV DI, 0      
	MOV SI, 145D  ;difference in hieght between the two players  *height
	MOV AH, 0CH   ;pixel drawing command
	MOV AL, 4     ;color RED 
	MOV BH, 0
	
	;Draw first shoot
	
ShootDraw:
	INC DI
	CMP DI, 5
	JZ ShootMOVE
	CMP BL, 1
	JZ ShootPl1		;PLAYER 1 IS SHOOTING 
	JNZ ShootPL2		;PLAYER 2 IS SHOOTING

	
ShootPL1: 
    INC DX
	JMP ShootRET1 
ShootPL2: 
    DEC DX 
    JMP ShootRET1 

ShootRET1:
    INT 10H
	JMP ShootDraw
	
	;MOVE SHOT
	
ShootMOVE:

	;DELAY
	PUSH BX ;not missing any value stored in it
	
	MOV BX, 01000H
	ShootL1:
	DEC BX
	CMP BX,0 
	JNZ ShootL1    
 
    POP BX  

	;DRAW WITH CLR BLACK
	MOV AL, 0
	CMP BL, 1
	JZ ShootPL1_ 
	JNZ ShootPL2_
	 
ShootRET2:
	MOV AL, 4 ;red color
    INT 10H   ;draw
    
    DEC SI    ;shot is getting much closer to the player one 
	CMP LVLNO,1
	JNZ LVL2
	
	CMP SI,80D
	JNZ KEEPMOVING
	PUSH AX
	MOV AX,SI
	CALL BLOCKSHOTLVL1
	CMP SI,AX
	POP AX
	JNZ KEEPMOVING 
	POP AX
	PUSH 0
	PUSH AX
	RET     
	
LVL2:
    CMP SI,88
    JNZ SECONDROW
    PUSH AX
    MOV AX,SI
    CMP BL, 1
    JNZ BLOCK2CALL
    CALL BLOCK1SHOTLVL2
    JMP CON
    
BLOCK2CALL: 
    CALL BLOCK2SHOTLVL2

CON:
    CMP SI,AX
    POP AX
    JNZ SECONDROW
    POP AX
    PUSH 0
    PUSH AX
    RET
    
SECONDROW:
    CMP SI, 72
    JNZ KEEPMOVING
    PUSH AX
    MOV AX,SI
    CMP BL,1
    JNZ BLOCK1CALL
    CALL BLOCK2SHOTLVL2
    JMP CON2

BLOCK1CALL:    
    CALL BLOCK1SHOTLVL2
    
CON2:
    CMP SI,AX
    POP AX
    JNZ KEEPMOVING
    POP AX
    PUSH 0
    PUSH AX
    RET
    
	
KEEPMOVING:
	CMP SI, 0 ;check if it reached to the level the player one moves in
	
	JNZ ShootMOVE ;noo!  go to move 
	JZ ShootCLEAR ;yess! go to clear the shot

;clearing the upper pixel and drawing one more in the lower
;so it seems that it moves downwards

ShootPL1_:

	SUB DX, 3     ;making Y= the upper pixel coordinate 
	INT 10H       ;clearing it with black color
	ADD DX, 4     ;making Y= the coordinate of the pixel down the last one in the shot  
	JMP ShootRET2 ;drawing it with red color

ShootPL2_:

	ADD DX, 3
	INT 10H
	SUB DX, 4
	JMP ShootRET2

ShootCLEAR: 

	MOV AL, 0
	CMP BL,1
	JZ ShootPL1_CLR
	JNZ ShootPL2_CLR

ShootPL1_CLR:
	INT 10H
	DEC DX
	INC SI
	CMP SI, 4
	JNZ ShootPL1_CLR
	JZ ShootEND

ShootPL2_CLR:
	INT 10H
	INC DX
	INC SI
	CMP SI, 4
	JNZ ShootPL2_CLR

ShootEND: 
    POP DX  ;IP 
    POP AX  ;X2 of oponent
    POP BX  ;X1 of oponent
    
    CMP CX, BX
    JS Shoot1RET     ;IF XSHOOTER < X1 OF OPONENT, THEN IT WASN'T HIT
    CMP CX, AX 
    JNS Shoot1RET    ;IF XSHOOTR > X2 OF OPONENT, THEN IT WASN'T HIT
    PUSH 1  ;HIT
    JMP Shoot2RET
Shoot1RET:   
    PUSH 0
Shoot2RET: 
    PUSH DX ;PUSH IP
    RET
ShootPlayer     ENDP
;====================================================================
DRAW_BLOCKS PROC  
     
     ;beginning from the position x=5
     
     MOV CX, 5D 
     MOV DI, 0
     MOV SI,0
     CMP LVLNO,1
     JZ ONEROW
     JMP TWOROWS
     
ONEROW:
BlocksRow:  
       
     MOV BlockPosX[SI],CX  ;STORING THE X COORDINATES OF EACH BLOCK    
     MOV DX, CX
     ADD DX, WIDTH        
     MOV Xpoint1, CX
     MOV Xpoint2, DX
     DrawWithColour Xpoint1, 85D, Xpoint2, 95D, INITIALCLRS1[DI]
     ADD CX, 31D
     INC DI
     ADD SI, 2
     CMP DI, 10D
     JNZ BlocksRow
     JMP ENDDRAWBLOCKS
        
TWOROWS:
BlocksRow1:  
       
     MOV BlockPosX[SI],CX  ;STORING THE X COORDINATES OF EACH BLOCK    
     MOV DX, CX
     ADD DX, WIDTH        
     MOV Xpoint1, CX
     MOV Xpoint2, DX
     DrawWithColour Xpoint1, 77D, Xpoint2, 87D, INITIALCLRS21[DI]
     ADD CX, 31D
     INC DI
     ADD SI, 2
     CMP DI, 10D
     JNZ BlocksRow1
     
     MOV DI,0
     MOV CX,5
     MOV SI,0
                   
BlocksRow2:  
       
     MOV BlockPosX[SI],CX  ;STORING THE X COORDINATES OF EACH BLOCK    
     MOV DX, CX
     ADD DX, WIDTH        
     MOV Xpoint1, CX
     MOV Xpoint2, DX
     DrawWithColour Xpoint1, 93D, Xpoint2, 103D, INITIALCLRS22[DI]
     ADD CX, 31D
     INC DI
     ADD SI, 2
     CMP DI, 10D
     JNZ BlocksRow2

ENDDRAWBLOCKS:    
    RET
DRAW_BLOCKS ENDP 
;====================================================================
DrawHealth  PROC
    ;Assumption, AX = number of hearts
                ;BL=1 => Player1, BL=2 => Player2
                 
    MOV CX, AX             
    MOV AH, 2
    
    MOV BH, 0
                 
    CMP BL, 1
    JZ  Health1
    JNZ Health2
    
Health1:

        MOV DX , HEART1POS
        INT 10H
        
        ;if number of hearts = 0 then 
         
        CMP CX, 0
        JZ DeleteHearts
        
        
        ;printing hearts with the number stored in cx
        
        mov al, 03H     ;ASCII OF HEART SYMBOL
        mov  ah, 9
        mov  bh, 0
        mov  bl, 4      ;RED
        int  10h
        
        JMP HealthExit        
        
Health2:  

        MOV DX , HEART2POS
        INT 10H
        CMP CX, 0
        JZ DeleteHearts
        MOV DL, 03H 
        
        mov al, 03H     ;ASCII OF HEART SYMBOL
        mov  ah, 9
        mov  bh, 0
        mov  bl, 4      ;RED
        int  10h
        
        JMP HealthExit

DeleteHearts:

        MOV DL, 20H ;ascii code of the space 
        MOV CX, 5
        
        ;pronting spaces overwriting hearts 
        
        InnerDeleteHearts:
            INT 21H
            LOOP InnerDeleteHearts
                
HealthExit: RET    
DrawHealth  ENDP
;====================================================================
BlockShotLVL1      Proc
            
            PUSHA
            MOV BX,11D
            MOV DI,20D
          
            
     CHECKNXTLVL1: 
            SUB DI,2
            DEC BX
            JZ BLACKLVL1                    ;IF ALL BLOCKS ARE CHECKED AND NON WAS HIT, KEEP THE SHOT GOING
            
            
            MOV DX, BLOCKPOSX[DI]       ;BLOCKPOSX IS A WORD
            CMP CX, DX                  ;CX= X OF THE SHOT
            JS CHECKNXTLVL1                 ;IF X[SHOT]<X[BEGINNING OF THE BLOCK] CHECK THE NEXT BLOCK
            ADD DX, WIDTH
            INC DX
            CMP CX, DX
            JNS BLACKLVL1                   ;IF X[SHOT]>X[END OF THE BLOCK] KEEP THE SHOT GOING
            
            CMP CLRS1[BX-1], 0
            JZ BLACKLVL1
            
            CMP CLRS1[BX-1], 0FH
            JZ WHITELVL1
            
            CMP CLRS1[BX-1], 08H
            JZ GREYLVL1
            
            CMP CLRS1[BX-1], 4
            JZ REDLVL1
            JNZ FINISHLVL1
            
            
     BLACKLVL1: 
            POPA
            DEC SI                   ;INCREASE THE SHOT POSITION AS A FLAG FOR KEEPING THE SHOT GOING
            RET
     
     WHITELVL1: 
            MOV CLRS1[BX-1], 08H       ;CHANGE THE COLOR TO GREY
            MOV CX, BlockPosX[DI]      
            MOV DX, CX
            ADD DX, WIDTH        
            MOV Xpoint1, CX
            MOV Xpoint2, DX
            DrawWithColour Xpoint1, 85D, Xpoint2, 95D, 08h
            JMP ERASETHESHOTLVL1
     
     GREYLVL1:  
            MOV CLRS1[BX-1], 0         ;ERASE THE BLOCK
            MOV CX, BlockPosX[DI]      
            MOV DX, CX
            ADD DX, WIDTH        
            MOV Xpoint1, CX
            MOV Xpoint2, DX
            DrawWithColour Xpoint1, 85D, Xpoint2, 95D, 0
            JMP ERASETHESHOTLVL1
     
            
     REDLVL1:
            MOV CLRS1[BX-1], 0        ;ERASE THE BLOCK
            MOV CX, BlockPosX[DI]      
            MOV DX, CX
            ADD DX, WIDTH       
            MOV Xpoint1, CX
            MOV Xpoint2, DX
            DrawWithColour Xpoint1, 85D, Xpoint2, 95D, 0
            
            POPA
            PUSHA
            CMP BL, 1
            JZ INCHEALTH1LVL1
            JNZ INCHEALTH2LVL1
               
INCHEALTH1LVL1: 
            INC PL1HEALTH
            MOV AX, PL1HEALTH
            CALL DRAWHEALTH
            JMP ERASETHESHOTLVL1
            
            
INCHEALTH2LVL1: 
            INC PL2HEALTH
            MOV AX, PL2HEALTH
            CALL DRAWHEALTH
            
            
ERASETHESHOTLVL1:
            POPA
            PUSHA
            CMP BL, 1
            JZ ERASEPL1LVL1
            JNZ ERASEPL2LVL1
                
                
ERASEPL1LVL1:   
            MOV BX, 4
            SUB DX, 3     ;making Y= the upper pixel coordinate 
	        MOV AL, 0
	        MOV AH, 0CH
    NXTPXL1LVL1:
	        INT 10H       ;clearing it with black color
            INC DX        ;TAKING THE NEXT PIXEL
            DEC BX        
            JNZ NXTPXL1LVL1
            JZ FINISHLVL1

ERASEPL2LVL1:   
            MOV BX, 4
            ADD DX, 3     ;making Y= the upper pixel coordinate 
	        MOV AL, 0
	        MOV AH, 0CH
    NXTPXL2LVL1:
	        INT 10H       ;clearing it with black color
            DEC DX        ;TAKING THE NEXT PIXEL
            DEC BX        
            JNZ NXTPXL2LVL1
                            
            
     FINISHLVL1:       
            POPA
            
            RET
BlockShotLVL1 ENDP  
;===================================================================
Block1ShotLVL2      Proc
            
            PUSHA
            MOV BX,11D
            MOV DI,20D
          
            
     CHECKNXTLVL21: 
            SUB DI,2
            DEC BX
            JZ BLACKLVL21                    ;IF ALL BLOCKS ARE CHECKED AND NON WAS HIT, KEEP THE SHOT GOING
            
            
            MOV DX, BLOCKPOSX[DI]       ;BLOCKPOSX IS A WORD
            CMP CX, DX                  ;CX= X OF THE SHOT
            JS CHECKNXTLVL21                 ;IF X[SHOT]<X[BEGINNING OF THE BLOCK] CHECK THE NEXT BLOCK
            ADD DX, WIDTH
            INC DX
            CMP CX, DX
            JNS BLACKLVL21                   ;IF X[SHOT]>X[END OF THE BLOCK] KEEP THE SHOT GOING
            
            CMP CLRS21[BX-1], 0
            JZ BLACKLVL21
            
            CMP CLRS21[BX-1], 0FH
            JZ WHITELVL21
            
            CMP CLRS21[BX-1], 08H
            JZ GREYLVL21
            
            CMP CLRS21[BX-1], 4
            JZ REDLVL21
            JNZ FINISHLVL21
            
                 
     BLACKLVL21: 
            POPA
            DEC SI                   ;INCREASE THE SHOT POSITION AS A FLAG FOR KEEPING THE SHOT GOING
            RET
     
     WHITELVL21: 
            MOV CLRS21[BX-1], 08H       ;CHANGE THE COLOR TO GREY
            MOV CX, BlockPosX[DI]      
            MOV DX, CX
            ADD DX, WIDTH        
            MOV Xpoint1, CX
            MOV Xpoint2, DX
            DrawWithColour Xpoint1, 77D, Xpoint2, 87D, 08h
            JMP ERASETHESHOTLVL21
     
     GREYLVL21:  
            MOV CLRS21[BX-1], 0         ;ERASE THE BLOCK
            MOV CX, BlockPosX[DI]      
            MOV DX, CX
            ADD DX, WIDTH        
            MOV Xpoint1, CX
            MOV Xpoint2, DX
            DrawWithColour Xpoint1, 77D, Xpoint2, 87D, 0
            JMP ERASETHESHOTLVL21
     
            
     REDLVL21:
            MOV CLRS21[BX-1], 0        ;ERASE THE BLOCK
            MOV CX, BlockPosX[DI]      
            MOV DX, CX
            ADD DX, WIDTH       
            MOV Xpoint1, CX
            MOV Xpoint2, DX
            DrawWithColour Xpoint1, 77D, Xpoint2, 87D, 0
            
            POPA
            PUSHA
            CMP BL, 1
            JZ INCHEALTH1LVL21
            JNZ INCHEALTH2LVL21
                     
INCHEALTH1LVL21: 
            INC PL1HEALTH
            MOV AX, PL1HEALTH
            CALL DRAWHEALTH
            JMP ERASETHESHOTLVL21
            
            
INCHEALTH2LVL21: 
            INC PL2HEALTH
            MOV AX, PL2HEALTH
            CALL DRAWHEALTH
            
            
ERASETHESHOTLVL21:
            POPA
            PUSHA
            CMP BL, 1
            JZ ERASEPL1LVL21
            JNZ ERASEPL2LVL21
                
                
ERASEPL1LVL21:   
            MOV BX, 4
            SUB DX, 3     ;making Y= the upper pixel coordinate 
	        MOV AL, 0
	        MOV AH, 0CH
    NXTPXL1LVL21:
	        INT 10H       ;clearing it with black color
            INC DX        ;TAKING THE NEXT PIXEL
            DEC BX        
            JNZ NXTPXL1LVL21
            JZ FINISHLVL21

ERASEPL2LVL21:   
            MOV BX, 4
            ADD DX, 3     ;making Y= the upper pixel coordinate 
	        MOV AL, 0
	        MOV AH, 0CH
    NXTPXL2LVL21:
	        INT 10H       ;clearing it with black color
            DEC DX        ;TAKING THE NEXT PIXEL
            DEC BX        
            JNZ NXTPXL2LVL21
                            
            
     FINISHLVL21:       
            POPA
            
            RET
Block1ShotLVL2 ENDP  
;====================================================================
Block2ShotLVL2      Proc
            
            PUSHA
            MOV BX,11D
            MOV DI,20D
          
            
     CHECKNXTLVL22: 
            SUB DI,2
            DEC BX
            JZ BLACKLVL22                    ;IF ALL BLOCKS ARE CHECKED AND NON WAS HIT, KEEP THE SHOT GOING
            
            
            MOV DX, BLOCKPOSX[DI]       ;BLOCKPOSX IS A WORD
            CMP CX, DX                  ;CX= X OF THE SHOT
            JS CHECKNXTLVL22                 ;IF X[SHOT]<X[BEGINNING OF THE BLOCK] CHECK THE NEXT BLOCK
            ADD DX, WIDTH
            INC DX
            CMP CX, DX
            JNS BLACKLVL22                   ;IF X[SHOT]>X[END OF THE BLOCK] KEEP THE SHOT GOING
            
            CMP CLRS22[BX-1], 0
            JZ BLACKLVL22
            
            CMP CLRS22[BX-1], 0FH
            JZ WHITELVL22
            
            CMP CLRS22[BX-1], 08H
            JZ GREYLVL22
            
            CMP CLRS22[BX-1], 4
            JZ REDLVL22
            JNZ FINISHLVL22
            
            
     BLACKLVL22: 
            POPA
            DEC SI                   ;INCREASE THE SHOT POSITION AS A FLAG FOR KEEPING THE SHOT GOING
            RET
     
     WHITELVL22: 
            MOV CLRS22[BX-1], 08H       ;CHANGE THE COLOR TO GREY
            MOV CX, BlockPosX[DI]      
            MOV DX, CX
            ADD DX, WIDTH        
            MOV Xpoint1, CX
            MOV Xpoint2, DX
            DrawWithColour Xpoint1, 93D, Xpoint2, 103D, 08h
            JMP ERASETHESHOTLVL22
     
     GREYLVL22:  
            MOV CLRS22[BX-1], 0         ;ERASE THE BLOCK
            MOV CX, BlockPosX[DI]      
            MOV DX, CX
            ADD DX, WIDTH        
            MOV Xpoint1, CX
            MOV Xpoint2, DX
            DrawWithColour Xpoint1, 93D, Xpoint2, 103D, 0
            JMP ERASETHESHOTLVL22
     
            
     REDLVL22:
            MOV CLRS22[BX-1], 0        ;ERASE THE BLOCK
            MOV CX, BlockPosX[DI]      
            MOV DX, CX
            ADD DX, WIDTH       
            MOV Xpoint1, CX
            MOV Xpoint2, DX
            DrawWithColour Xpoint1, 93D, Xpoint2, 103D, 0
            
            POPA
            PUSHA
            CMP BL, 1
            JZ INCHEALTH1LVL22
            JNZ INCHEALTH2LVL22
               
INCHEALTH1LVL22: 
            INC PL1HEALTH
            MOV AX, PL1HEALTH
            CALL DRAWHEALTH
            JMP ERASETHESHOTLVL22
            
            
INCHEALTH2LVL22: 
            INC PL2HEALTH
            MOV AX, PL2HEALTH
            CALL DRAWHEALTH
            
            
ERASETHESHOTLVL22:
            POPA
            PUSHA
            CMP BL, 1
            JZ ERASEPL1LVL22
            JNZ ERASEPL2LVL22
                
                
ERASEPL1LVL22:   
            MOV BX, 4
            SUB DX, 3     ;making Y= the upper pixel coordinate 
	        MOV AL, 0
	        MOV AH, 0CH
    NXTPXL1LVL22:
	        INT 10H       ;clearing it with black color
            INC DX        ;TAKING THE NEXT PIXEL
            DEC BX        
            JNZ NXTPXL1LVL22
            JZ FINISHLVL22

ERASEPL2LVL22:   
            MOV BX, 4
            ADD DX, 3     ;making Y= the upper pixel coordinate 
	        MOV AL, 0
	        MOV AH, 0CH
    NXTPXL2LVL22:
	        INT 10H       ;clearing it with black color
            DEC DX        ;TAKING THE NEXT PIXEL
            DEC BX        
            JNZ NXTPXL2LVL22
                            
            
     FINISHLVL22:       
            POPA
            
            RET
Block2ShotLVL2 ENDP  
;====================================================================
UserName1 PROC 
    
     PUSHA
     
     ;moving cursor
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 3D
     MOV DH, 10D
     INT 10H 
     
     ;PRINTING MESSAGE
     
     MOV AH , 9
     LEA DX,PLNAME_
     INT 21H
     
     ;GETTING STRING INPUT FROM KEYBOARD
     
     MOV AH,0AH
     LEA DX,PL1Name
     INT 21H 
     
     ;ENFORCING THE PROGRAM TO TAKE THE FIRST 8 CHARACTERS 
     ;NO WHERE FOR MORE (;
     
     MOV PL1NAME[8],0DH
     MOV PL1NAME[9],'$'
     
     MOV SI, 0
     LEA BX, PL1NAME
     ADD BX, 2
     
CalcSize1:
     CMP [BX], 0DH
     JZ CalcSize1Done
     INC SI
     INC BX
     JMP CalcSize1    

CalcSize1Done:
     
     MOV CX, SI
     MOV ACT1SIZE, CL
     
     POPA
    
RET
UserName1 ENDP
;====================================================================
SendAndRec  PROC
    
    PUSHA       
    ;not wait for input
    MOV AH,1 
    INT 16H 
    ;lw mfe4 7aga to send, check l recieve
    JZ recieveData 
    ;fe 7aga etktbt fe ah, 7utaha fe sentData
    mov sentData, ah
    ;Clear buffer
    MOV AH,0CH
    MOV AL,0
    INT 21H
    MOV DX,3FDH
    
sendData:   
        ;Check status of transmitter holding reg.
        IN AL,DX
        AND AL,00100000B
        JZ sendData ;wait till l holding reg. yfda                        
        
        ;send what is in sentData to transmit data reg.
        MOV DX,3F8H  
        MOV AL,sentData
        OUT DX,AL 
        ;o5rog mn l proc.      
        JMP escapeData 
    
recieveData:  
    MOV DX,3FDH
    ;check fe data to recieve wla l2
    IN AL,DX
    AND AL,1 
    ;lw l2 o5rog
    JZ escapeData 
    ;lw ah, estlm l byte fe al we 7uteha fe recData
    MOV DX,3F8H
    IN AL,DX
    MOV RecData, AL
          
escapeData: 
    POPA           
            RET
SendAndRec  ENDP
;====================================================================
SendOrRec  PROC
    
startAgain:
    ;not wait for input
    MOV AH,1 
    INT 16H 
    ;lw mfe4 7aga to send, check l recieve
    JZ recieveData2 
    ;fe 7aga etktbt fe ah, 7utaha fe sentData
    mov sentData, ah
    ;Clear buffer
    MOV AH,0CH
    MOV AL,0
    INT 21H
    MOV DX,3FDH
    
sendData2:   
        ;Check status of transmitter holding reg.
        IN AL,DX
        AND AL,00100000B
        JZ sendData2 ;wait till l holding reg. yfda                        
        
        ;send what is in sentData to transmit data reg.
        MOV DX,3F8H  
        MOV AL,sentData
        OUT DX,AL 
        ;o5rog mn l proc.      
        JMP escapeData2 
    
recieveData2:
    MOV DX,3FDH
    ;check fe data to recieve wla l2
    IN AL,DX
    AND AL,1 
    ;lw l2 o5rog
    JZ startAgain 
    ;lw ah, estlm l byte fe al we 7uteha fe recData
    MOV DX,3F8H
    IN AL,DX
    MOV RecData, AL 
    
escapeData2:            
            RET
SendOrRec  ENDP
;====================================================================
WaitPl2Connect  PROC
    
     ;moving cursor
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 3D
     MOV DH, 12D
     INT 10H 
     
     ;PRINTING MESSAGE
     
     MOV AH , 9
     LEA DX,WaitPl2
     INT 21H
     
     
WaitToRecieve:   
    MOV DX,3FDH
    ;check fe data to recieve wla l2
    IN AL,DX
    AND AL,1 
    ;lw l2 wait
    JZ WaitToRecieve 
    ;lw ah, estlm l byte fe al
    MOV DX,3F8H
    IN AL,DX
    ;m4 hn5rug 8er lw l estlmto da down button
    ;w da m3naha en l user l tany d5l l name bta3o
    CMP AL, 50H
    JNZ WaitToRecieve        
                        
            RET
WaitPl2Connect  ENDP
;====================================================================
RecieveUserName2  PROC
    ;recieve Act2Size (size of username2)
    
RecSize2:
        MOV DX,3FDH  
        ;check fe data to recieve wla l2
        IN AL,DX
        AND AL,1
        JZ RecSize2 ;wait till I recieve size                        
        
        ;recieve l size fe AL
        MOV DX,3F8H
        IN AL,DX
        ;7ut l size fe ACT2SIZE
        MOV ACT2SIZE, AL
        
        ;Now, 3yzen n-loop 3la 7rof l name w send it
        MOV CL, ACT2SIZE
        LEA BX, PL2Name
        ADD BX, 2 
        
RecUser2Loop:   
        MOV DX, 3FDH
        ;check fe data to recieve wla l2
        IN AL,DX
        AND AL,1
        JZ RecUser2Loop                        
        
        ;recieve awl 7rf w 7utu fe PL2Name
        MOV DX,3F8H
        IN AL,DX
        MOV [BX], AL
        ;incerements
        INC BX
        DEC CL
        JNZ RecUser2Loop
                        
            RET
RecieveUserName2  ENDP
;====================================================================
SendUserName1  PROC
            
    ;send Act1Size (size of username1)
    MOV DX,3FDH  
    
sendSize1:
        ;Check status of transmitter holding reg.
        IN AL,DX
        AND AL,00100000B
        JZ sendSize1 ;wait till l holding reg. yfda                        
        
        ;send what is in sentData to transmit data reg.
        MOV DX,3F8H  
        MOV AL,ACT1SIZE
        OUT DX,AL
        
        ;Now, 3yzen n-loop 3la 7rof l name w send it
        MOV DX,3FDH
        MOV CL, ACT1SIZE
        LEA BX, PL1Name
        ADD BX, 2 
        
sendUser1Loop:   
        ;Check status of transmitter holding reg.
        IN AL,DX
        AND AL,00100000B
        JZ sendUser1Loop ;wait till l holding reg. yfda                        
        
        ;send 7rf 7rf mn PL1Name
        MOV DX,3F8H  
        MOV AL,[BX]
        OUT DX,AL 
        ;incerements
        MOV DX,3FDH
        INC BX
        DEC CL
        JNZ sendUser1Loop 
            
        RET
SendUserName1  ENDP
;====================================================================    

chat_ proc
    
    pusha
    
    ;graphicAL mode 
    
    MOV BH, 0
    MOV ah , 0
    MOV AL , 03h
    INT 10h
    
    
    ;CLEAR SCREEN
    
    mov ax,0600h
    mov bh,07
    mov cx,0
    mov dx,184FH  
    INT 10H 
    
    
    ;MOV CURSOR to position 0c00h(almost the middle of the screen)
    
     mov ah,2
     MOV BH , 0
     mov dx,0C00H
     INT 10H
     
     ;DIVIDE THE SCREEN with a line( printing "_" with the width of screen )
     
     MOV CX , 4FH
     AG:
   
     INT 10H
     
     MOV BL,DL
     
     mov dl , 0C4H
     int 21h
     
     MOV DL , BL
     
     INC DL
     
     
     LOOP AG
     
    ;moving cursor
    
    mov ah,2
    MOV BH , 0
    mov dx,0000H
    INT 10H 
     
    ;printing User1 name
    mov bh , 0
    lea dx , PL1NAME
    ADD DX, 2
    mov ah , 09
    int 21h
    
    ;moving cursor
    
    mov ah,2
    MOV BH , 0
    mov dx,0D00H
    INT 10H 
     
    ;printing User2 name
    mov bh , 0
    lea dx , PL2NAME
    ADD DX, 2
    mov ah , 09
    int 21h
    
    
    ;MOV CURSOR to position 0100h
    
     mov ah,2
     MOV BH , 0
     mov dx,0100H
     INT 10H
     
     ;draw line
     
     MOV CX , 4FH
     AG1:
   
     INT 10H
     
     MOV BL,DL
     
     mov dl , 0C4H
     int 21h
     
     MOV DL , BL
     
     INC DL
     
     
     LOOP AG1  
     
     
     ;MOV CURSOR to position 0F00h
    
     mov ah,2
     MOV BH , 0
     mov dx,0E00H
     INT 10H
     
     ;draw line
     
     MOV CX , 4FH
     AG2:
   
     INT 10H
     
     MOV BL,DL
     
     mov dl , 0C4H
     int 21h
     
     MOV DL , BL
     
     INC DL
     
     
     LOOP AG2           
     
                                               ;Configuration
;-----------------------------------------------------------------------------------------------------------     
;-----------------------------------------------------------------------------------------------------------
    
    ; Set Divisor Latch Access Bit 
    
    mov dx,3fbh 			; Line Control Register
    mov al,10000000b		;Set Divisor Latch Access Bit
    out dx,al			    ;Out it
    
    ;Set LSB byte of the Baud Rate Divisor Latch register.
    
    mov dx,3f8h			
    mov al,0ch			
    out dx,al
    
    ;Set MSB byte of the Baud Rate Divisor Latch register.
    
    mov dx,3f9h
    mov al,00h
    out dx,al
    
    ;Set port configuration
    
    mov dx,3fbh
    mov al,00011011b

    out dx,al  


                                               ;send $ receive logic    
;_----------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------------
    
    
    
         
    Send:
    
      
    ;MOV CURSOR to send pos
    mov ah,2  
    MOV BH , 0
    mov dx,SENDPOS
    INT 10H
    
    ;take input from keyboard(don't wait!)
    
    mov ah,1
    mov bl , ah
    int 16h
    
    cmp bl , ah  ;see if there is an input or not!
    jz Receive   ;if not go to receive!!!
    
    cmp ah , 4fh ;pressing end exit chat
    jnz notend
    
    mov al , ah 
    
    notend:
    
    mov value , al
    
    
    ;CLEARING BUFFER
     
    MOV AH,0CH
    MOV AL,0
    INT 21H
    
                          ;printing the character on the sender'screen
                           
;------------------------------------------------------------------------------------------------------------    
    
    ;compare if enter then send newline
    
    cmp value , 0Dh
    jnz m
    mov value , 10 
    
    m:
    
    ;see if backspace
  	
  		
  	cmp value , 08h
  	jnz print       ;no go and print
  	
  	;yes?!
  	;print it then space to clear character
  		
  	mov ah , 2
    mov dl , value
    int 21h
        
    ;print space
    mov dl , 20h
    int 21h
     
    print:
    
    mov ah , 2
    mov dl , value
    int 21h
    
    ;GET CURSOR POS(the new position of the cursor!)
    mov ah,3h
    mov bh,0h
    INT 10H
    MOV SENDPOS , DX
    
                                       ;send 
;---------------------------------------------------------------------------------------------------------    
        
    mov dx , 3FDH		; Line Status Register
    
 
    AGAIN:  
	         
       
        In al , dx 			;Read Line Status
  		AND al , 00100000b
  		JZ AGAIN
  		
    ;If empty put the VALUE in Transmit data register
  	
  	mov dx  , 3F8H		; Transmit data register
  	mov  al , value
  	out dx  , al
  	
  	cmp value , 4fh
  	jz exitchat 
  	
  	
  	;if reached the middle of screen scroll the top half ! 
  	
  	CMP BYTE PTR SENDPOS[1] , 0CH
    JZ SCROLL
    JMP Receive
    
    
    SCROLL: 
     
    ;SCROLL 
    
    mov ah,06h
    mov al,01h
    mov bh,07h
    mov bl,0h
    mov cx,0200h
    mov dx,0B4FH  
    INT 10H
     
   
    mov SENDPOS , 0B00H 
  	                                          
  	                                          ;Receive
;------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------  
  	
  	 
 Receive:
 
 
    
    
    ;MOV CURSOR
    
    mov ah,2  
    MOV BH , 0
    mov dx,RECPOS
    INT 10H
           
       

    mov dx , 3FDH		; Line Status Register
        
	CHK:
		
	    in al , dx 
  		AND al , 1
  		JZ Send   ;if not ready to receive go to send

         ;If Ready read the VALUE in Receive data register
  		
  		mov dx , 03F8H
  		in al , dx 
  		mov value , al 
  		
  		cmp value , 4fh
  		jz exitchat
  		
  		;check the ascii code if(between 20h - 7Eh ) the logic characters to chat
  		
  		CMP value , 20h
  		jb chkmore1     ;if below go and see if enter or backspace  
  		cmp value , 7Eh
  		ja over         ;if above don't print
  		
  		jmp print2    ;if in the range go and print
  		
  		
  		chkmore1:
  		
  		cmp value , 0Ah ;if enter
  		jnz chkmore2    ;no?
  		
  		;see if cursor in the beginning of the line so don't go down again!!
  		cmp byte ptr RECPOS , 0
  		jz over
  		jmp print2
  		 
  		
  		
  		;see if backspace
  		chkmore2:
  		
  		cmp value , 08h
  		jnz over
  		
  		mov ah , 2
        mov dl , value
        int 21h
        
        ;print space
        mov dl , 20h
        int 21h 
        
  		
        
        
        print2:
        
        mov ah , 2
        mov dl , value
        int 21h
        
        over:
        
        ;GET CURSOR POS
        
        mov ah,3h
        mov bh,0h
        INT 10H
        MOV RECPOS , DX
        
        CMP BYTE PTR RECPOS[1] , 18H ;if reached the bottom of the screen go and scroll up the down half!
        JZ SCROL2
        JMP Send
    
    
        SCROL2: 
     
        ;SCROLL 
    
        mov ah,06h
        mov al,01h
        mov bh,07h
        mov bl,0h
        mov cx,0f00h
        mov dx,184FH  
        INT 10H
     
   
        mov RECPOS , 1700H 
        
        
        
        jmp Send
    
 
    
    
    exitchat:
    
    ;CLEARING BUFFER
     
    MOV AH,0CH
    MOV AL,0
    INT 21H
    
    popa
    ret
chat_ endp  

;-----------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------

DrawStatusBar proc
    
        
     pusha
     
     ;clear status bar 
    
     DrawWithColour 0d,181D,320D,200D,0H
     
     DrawWithColour 0d,180D,320D,181D,0FH
     
     
     ;moving cursor
     
     MOV BH, 0
     MOV AH, 2 
     MOV DL, 0    ;x position
     MOV DH, 23D  ;y position
     INT 10H
     
     ADD DL, ACT1SIZE
     add Dl , 2
     MOV HEART1POS,DX   ;STORING THE POSITION OF THE FIRST HEART TO DRAW  

     ;printing text
       
     MOV BH, 0
     MOV AH, 9
     MOV DX, OFFSET Pl1NAME
     ADD DX, 2
     INT 21H   
     
     ;moving cursor
              
     MOV BH, 0                             
     MOV AH, 2
     MOV DL, 20D
     MOV DH, 23D
     INT 10H
     
     ADD DL, ACT2SIZE
     add dl , 2
     MOV HEART2POS,DX   ;STORING THE POSITION OF THE FIRST HEART TO DRAW

     ;printing text
       
     MOV BH, 0 
     MOV AH, 9
     MOV DX, OFFSET Pl2NAME
     ADD DX, 2
     INT 21H
      
     
     MOV AX, Pl1Health
     MOV BL, 1             ;if Bl=1 palyer one health
     CALL DrawHealth
     
     
     MOV AX, Pl2Health
     MOV BL, 2             ;if bl = 2 player 2 health
     CALL DrawHealth
    
     popa
     
    ret
DrawStatusBar endp

;-----------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------
InLineChatSend proc
    
    pusha
    
    ;clear status bar 
    
    DrawWithColour 0d,181D,320D,200D,0H
   
    
    ;cursor send in bl , bh
    mov cl , 1d
    mov ch , 23d
    
    
    ;clearing buffer
    MOV AH,0CH
    MOV AL,0
    INT 21H 
    
    call Config
    
    
    tany:
    
    
    mov ah , 1
    int 16h
    
    ;CLEARING BUFFER 
    push ax
    
    
     
    
    ;move cursor
   
   
    
    mov bh,0
    mov ah,2
    mov dl,cl
    mov dh ,ch
    int 10h
    
    ;clearing buffer
    
    MOV AH,0CH
    MOV AL,0
    INT 21H
    
    pop ax
    
    cmp cl , 38d
    jnz j
    
    mov cl ,1d
    mov ch ,23d
    
    ;clear status bar 
    
    DrawWithColour 0d,181D,320D,200D,0H
    
    jmp tany 
    
    j:
    cmp ah ,1
    jz tany
    
    push ax 
    
    
    mov dx , 3FDH		; Line Status Register
    
 
    AGAIN_:  
	         
       
        In al , dx 			;Read Line Status
  		AND al , 00100000b
  		JZ AGAIN_
  		
    ;If empty put the VALUE in Transmit data register
  	pop ax  
  	
  	mov dx  , 3F8H		; Transmit data register
  	out dx  , al
  	
  	
  	cmp ah ,1ch
    jz ExitInLineSend
    cmp al , 08h ;if backspace
    jnz print_
    
    cmp cl , 1d
    jz tany
    
    ;print it then space to clear character
  		
  	mov ah , 2
    mov dl , al
    int 21h
    
        
    ;print space
    mov dl , 20h
    int 21h
    
    dec cl
    dec cl
    
    
    ;print
    
    print_:
    
    mov ah,2
    mov dl, al
    int 21h
    inc cl
  	
  	jmp tany 
  	
  	
    
    
  ExitInLineSend:
    
    popa
    ret
    
InLineChatSend endp 
;---------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------

InLineChatReceive proc
    
    pusha
    
    ;clear status bar 
    
    DrawWithColour 0d,181D,320D,200D,0H
    
    
    ;cursor receive in bl , bh
    mov cl , 1d
    mov ch , 23d
    
    
    call Config
     
  	
  	receive2:
  	
  	mov dx , 3FDH		; Line Status Register   
	
		
	in al , dx 
    AND al , 1
  	JZ receive2   ;if not ready to receive go to send

    ;If Ready read the VALUE in Receive data register
  		
    mov dx , 03F8H
  	in al , dx 
  	
  	
  	
  	cmp cl , 38d
  	jnz j_:
  	
  	mov cl , 1
  	mov ch , 23d
  	
  	;clear status bar 
    DrawWithColour 0d,181D,320D,200D,0H
  	
  	;mov cursor
  	j_:
  	mov bh ,0
  	mov ah,2
    mov dl,cl
    mov dh ,ch
    int 10h
      
    cmp al , 0dh
    jz ExitInLineReceive
    
    cmp al , 08h ;if backspace
    jnz print2_
    
    cmp cl , 1d
    jz receive2
    
    ;print it then space to clear character
  		
  	mov ah , 2
    mov dl , al
    int 21h
    
    
        
    ;print space
    mov dl , 20h
    int 21h
    
    dec cl
    dec cl
    
    ;print
    
    print2_:   
    
  	;print
    
    mov ah,2
    mov dl, al
    int 21h
    inc cl
  	
  	 
     
    jmp receive2 
    
    
    
    
    
  ExitInLineReceive:
    
    popa
    ret
    
InLineChatReceive endp 

;----------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------------

Config proc
    
    pusha
        
    ; Set Divisor Latch Access Bit 
    
    mov dx,3fbh 			; Line Control Register
    mov al,10000000b		;Set Divisor Latch Access Bit
    out dx,al			    ;Out it
    
    ;Set LSB byte of the Baud Rate Divisor Latch register.
    
    mov dx,3f8h			
    mov al,0ch			
    out dx,al
    
    ;Set MSB byte of the Baud Rate Divisor Latch register.
    
    mov dx,3f9h
    mov al,00h
    out dx,al
    
    ;Set port configuration
    
    mov dx,3fbh
    mov al,00011011b

    out dx,al
    
    popa  
     
    ret
    
Config endp    


END MAIN