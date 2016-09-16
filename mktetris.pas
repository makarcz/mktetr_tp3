{$C-}
program mktetris(input,output);

{ TETRIS clone, TP3, CP/M 3 (C128) by Marek Karcz 2016 }

type
   Shape = array[1..4,1..4] of Char;
   Block = array[1..4] of Shape;
   All = array[1..6] of Block;
   PtrBlkInfo = ^BlkInfo;
   BlkInfo = record  { keep info about the block on the scene }
               PrevRow,PrevCol: Integer; {previous coord. (for repainting)}
               Row,Col:      Integer; {block coordinates}
               Repaint:      Boolean; {flag if block needs repainting}
               ShNum,SeqNum: Integer; {shape and sequence numbers}
               Next:         PtrBlkInfo; {pointer to next block}
             end;

const
   ScWidth   = 16; {scene width}
   ScHeight  = 20; {scene height}
   ScRow     = 1;  {scene left-upper corner coordinate (Y or Row)}
   ScCol     = 1;  {scene left-upper corner coordinate (X or Col)}
   FallSpeed = 10;
   RefrRate  = 100;
   BoxVert   = 'I';
   BoxHoriz  = '-';
   BlockSymb = '#';
   EmptySymb = ' ';

var
   Key:        Char;
   {BlockSymb: Char;}
   ValidKey:   Boolean;
   sh:         Shape;
   bl:         Block;
   Pieces:     All;
   FrstBlk:    PtrBlkInfo; {pointer to 1st block on scene}
   CurrBlk:    PtrBlkInfo; {pointer to current block}
   NewBlk:     PtrBlkInfo; {pointer to new block}

{
   -----------------------------------------------------------
   Display or erase block.
   x, y - screen coordinates (x: 1..40, y: 1..24)
   sn - shape # (1..5)
   rn - sequence/rotation # (1..4)
   era - True: erase block/False: paint block.
   -----------------------------------------------------------
}
procedure DispBlock(x,y,sn,rn: Integer; era: Boolean);
var
   i,j: Integer;
begin
   bl := Pieces[sn];
   sh := bl[rn];
   for i := 1 to 4 do
   begin
      for j := 1 to 4 do
      begin
         GotoXY(x*2+i*2-4,y+j-1);
         if sh[i,j] = BlockSymb then
         begin
            if era = True then
              write('  ')
            else
            begin
              write(Chr(27));
              write('G4  ');
              write(Chr(27));
              write('G0');
            end;
         end;
      end;
   end;
end;

{
   -----------------------------------------------------------
   Init Shape Array.
   v - character to fill with.
   -----------------------------------------------------------
}
procedure InitShape(v: Char);
var
   i,j: Integer;
begin
   for i := 1 to 4 do
   begin
      for j:= 1 to 4 do
      begin
         sh[i,j] := v;
      end;
   end;
end;

{
   -----------------------------------------------------------
   Initialize All Shapes.
   -----------------------------------------------------------
}
procedure InitAllShapes;
var
   i,j: Integer;
begin
   {BlockSymb := Chr(178);}
   InitShape(EmptySymb);
   sh[1,1] := BlockSymb;
   sh[1,2] := BlockSymb;
   sh[1,3] := BlockSymb;
   sh[1,4] := BlockSymb;
   bl[1] := sh;
   InitShape(EmptySymb);
   sh[1,1] := BlockSymb;
   sh[2,1] := BlockSymb;
   sh[3,1] := BlockSymb;
   sh[4,1] := BlockSymb;
   bl[2] := sh;
   bl[3] := bl[1];
   bl[4] := bl[2];
   Pieces[1] := bl;
   InitShape(EmptySymb);
   sh[1,1] := BlockSymb;
   sh[2,1] := BlockSymb;
   sh[1,2] := BlockSymb;
   sh[2,2] := BlockSymb;
   bl[1] := sh;
   bl[2] := sh;
   bl[3] := sh;
   bl[4] := sh;
   Pieces[2] := bl;
   InitShape(EmptySymb);
   sh[2,1] := BlockSymb;
   sh[1,2] := BlockSymb;
   sh[2,2] := BlockSymb;
   sh[3,2] := BlockSymb;
   bl[1] := sh;
   InitShape(EmptySymb);
   sh[1,1] := BlockSymb;
   sh[1,2] := BlockSymb;
   sh[2,2] := BlockSymb;
   sh[1,3] := BlockSymb;
   bl[2] := sh;
   InitShape(EmptySymb);
   sh[1,1] := BlockSymb;
   sh[2,1] := BlockSymb;
   sh[3,1] := BlockSymb;
   sh[2,2] := BlockSymb;
   bl[3] := sh;
   InitShape(EmptySymb);
   sh[2,1] := BlockSymb;
   sh[1,2] := BlockSymb;
   sh[2,2] := BlockSymb;
   sh[2,3] := BlockSymb;
   bl[4] := sh;
   Pieces[3] := bl;
   InitShape(EmptySymb);
   sh[1,1] := BlockSymb;
   sh[2,1] := BlockSymb;
   sh[3,1] := BlockSymb;
   sh[1,2] := BlockSymb;
   bl[1] := sh;
   InitShape(EmptySymb);
   sh[1,1] := BlockSymb;
   sh[2,1] := BlockSymb;
   sh[2,2] := BlockSymb;
   sh[2,3] := BlockSymb;
   bl[2] := sh;
   InitShape(EmptySymb);
   sh[3,1] := BlockSymb;
   sh[1,2] := BlockSymb;
   sh[2,2] := BlockSymb;
   sh[3,2] := BlockSymb;
   bl[3] := sh;
   InitShape(EmptySymb);
   sh[1,1] := BlockSymb;
   sh[1,2] := BlockSymb;
   sh[1,3] := BlockSymb;
   sh[2,3] := BlockSymb;
   bl[4] := sh;
   Pieces[4] := bl;
   InitShape(EmptySymb);
   sh[2,1] := BlockSymb;
   sh[3,1] := BlockSymb;
   sh[1,2] := BlockSymb;
   sh[2,2] := BlockSymb;
   bl[1] := sh;
   bl[3] := sh;
   InitShape(EmptySymb);
   sh[1,1] := BlockSymb;
   sh[1,2] := BlockSymb;
   sh[2,2] := BlockSymb;
   sh[2,3] := BlockSymb;
   bl[2] := sh;
   bl[4] := sh;
   Pieces[5] := bl;
   InitShape(EmptySymb);
   sh[1,1] := BlockSymb;
   sh[2,1] := BlockSymb;
   sh[2,2] := BlockSymb;
   sh[3,2] := BlockSymb;
   bl[1] := sh;
   bl[3] := sh;
   InitShape(EmptySymb);
   sh[2,1] := BlockSymb;
   sh[1,2] := BlockSymb;
   sh[2,2] := BlockSymb;
   sh[1,3] := BlockSymb;
   bl[2] := sh;
   bl[4] := sh;
   Pieces[6] := bl;
end;

procedure DrawBox(x, y, width, height: Integer);
var
   i: Integer;
begin
   for i := y to y+height-1 do
   begin
      GotoXY(x, i);
      write(BoxVert);
      GotoXY(x+width*2+1, i);
      write(BoxVert);
   end;
   GotoXY(x, y+height);
   for i := 1 to width*2+2 do write(BoxHoriz);
end;

procedure InitGame;
var xx,x1,x2,x3,x4,x5 : Integer;
begin
   InitAllShapes;
   Key := 'r';
   ValidKey := False;
   ClrScr;
   DrawBox(ScCol, ScRow, ScWidth, ScHeight);
   { Show all pieces - this will be removed in final version }
   xx := ScWidth; x1 := 3; x2 := 8; x3 := 13; x4 := 18; x5 := 23;
   DispBlock(xx+x1, 1, 1, 1, False);
   DispBlock(xx+x1, 5, 1, 2, False);
   DispBlock(xx+x1, 9, 2, 1, False);
   DispBlock(xx+x1, 13, 3, 1, False);
   DispBlock(xx+x2, 13, 3, 2, False);
   DispBlock(xx+x3, 13, 3, 3, False);
   DispBlock(xx+x4, 13, 3, 4, False);
   DispBlock(xx+x2, 1, 4, 1, False);
   DispBlock(xx+x3, 1, 4, 2, False);
   DispBlock(xx+x4, 1, 4, 3, False);
   DispBlock(xx+x5, 1, 4, 4, False);
   DispBlock(xx+x2, 5, 5, 1, False);
   DispBlock(xx+x3, 5, 5, 2, False);
   DispBlock(xx+x4, 5, 5, 3, False);
   DispBlock(xx+x5, 5, 5, 4, False);
   DispBlock(xx+x2, 9, 6, 1, False);
   DispBlock(xx+x3, 9, 6, 2, False);
   DispBlock(xx+x4, 9, 6, 3, False);
   DispBlock(xx+x5, 9, 6, 4, False);
   GotoXY(40, 18); write(':/; - move left/right');
   GotoXY(40, 19); write(',/. - rotate left/right');
   GotoXY(40, 20); write('  @ - start over');
   { Add 1st piece to the scene. }
   New(NewBlk);
   FrstBlk := NewBlk;
   CurrBlk := FrstBlk;
   if FrstBlk <> nil then
   begin
      with FrstBlk^ do
      begin
        Col := ScCol + 1;
        Row := ScRow;
        PrevCol := Col;
        PrevRow := Row;
        Repaint := True;
        ShNum := 4;
        SeqNum := 1;
        Next := nil;
      end;
   end;
end;

procedure UpdScene;
var
  Blk:        PtrBlkInfo;
  PrevSeqNum: Integer;
begin
  Blk := FrstBlk;
  PrevSeqNum := -1;
  while Blk <> nil do
  with Blk^ do
  begin
    if Repaint = True then
    begin
      DispBlock(PrevCol,PrevRow,ShNum,SeqNum,True);
      DispBlock(Col,Row,ShNum,SeqNum,False);
      PrevCol := Col;
      PrevRow := Row;
      Repaint := False;
    end;
    Blk := Next;
  end;
  { perform block rotation }
  if CurrBlk <> nil then
  with CurrBlk^ do
  begin

    if ValidKey and (Key = '.') then
    begin
      PrevSeqNum := SeqNum;
      SeqNum := SeqNum + 1;
      if SeqNum > 4 then SeqNum := 1;
    end;
    if ValidKey and (Key = ',') then
    begin
      PrevSeqNum := SeqNum;
      SeqNum := SeqNum - 1;
      if SeqNum < 1 then SeqNum := 4;
    end;

    if PrevSeqNum > 0 then
    begin
      DispBlock(Col,Row,ShNum,PrevSeqNum,True);
      DispBlock(Col,Row,ShNum,SeqNum,False);
    end;
  end;
  { perform block falling down and movement }
  if CurrBlk <> nil then
  with CurrBlk^ do
  begin
    if ValidKey and (Key = ';') then
    begin
      if Col + 4 < ScCol + 1 + ScWidth then
      begin
        Col := Col + 1;
        Repaint := True;
      end;
    end;
    if ValidKey and (Key = ':') then
    begin
      if Col > ScCol + 1 then
      begin
        Col := Col - 1;
        Repaint := True;
      end;
    end;
    if Row < ScHeight+ScRow-3 then
    begin
      Row := Row + 1;
      Repaint := True;
    end;
    if ValidKey and (Key = '@') then
    begin
      Row := 1;
      Repaint := True;
    end;
  end;
end;

procedure GetInput;
begin
   if KeyPressed then
   begin
      Read(Kbd,Key);
      ValidKey := True;
   end
   else ValidKey := False;
end;

function GameEnd : Boolean;
var
   Ret: Boolean;
   i: Integer;
begin
   Ret := False;
   if ValidKey and (Key = 'e') then
   begin
      GotoXY(40, 22);
      write('Are you sure (Y/N)?');
      repeat until KeyPressed;
      Read(Kbd, Key);
      if (Key = 'y') or (Key = 'Y') then
      begin
         Ret := True;
      end;
      GotoXY(40, 22);
      for i := 1 to 20 do write(' ');
   end;
   GameEnd := Ret;
end;

{ --------------------- MAIN PROGRAM ---------------- }

begin
   InitGame;
   while not GameEnd do
   begin
      UpdScene;
      GetInput;
      Delay(RefrRate);
   end;
   ClrScr;
   writeln('Thank you for playing mktetris!');
end.
