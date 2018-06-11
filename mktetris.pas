{$C-}
program mktetris(input,output);

{ TETRIS clone, TP3, CP/M 3 (C128) by Marek Karcz 2016-2018 }

const { constant definitions }

   ScWidth   = 16;  {scene width}
   ScHeight  = 20;  {scene height}
   ScRow     = 1;   {scene left-upper corner coordinate (Y or Row)}
   ScCol     = 1;   {scene left-upper corner coordinate (X or Col)}
   FallSpeed = 10;  {determines the initial speed of falling piece}
   RefrRate  = 100; {determines how often the scene is refreshed}

type { type declarations }

   Cell = (Empty, Filled);
   Shape = array[1..4,1..4] of Cell; { puzzle shape definition }
   Block = array[1..4] of Shape; { all rotated variations of a puzzle }
   All = array[1..6] of Block;   { array of all puzzles }
   Scene = array[1..ScWidth,1..ScHeight] of Cell;

   { Piece falls and when it can no longer fall down, it is converted    }
   { or rather - transferred to the Scene. Once the piece becomes        }
   { part of the Scene, it is no longer abiding by the rules of the      }
   { Shape. The Scene is being reduced following different set of rules. }
   { If the row of the Scene is filled with Filled Cells, then it is     }
   { reduced and contents above it are scrolled down.                    }

   PtrBlkInfo = ^BlkInfo; { pointer to the piece information }

   BlkInfo = record  { keeps info about the falling piece}

               PrevRow:      Integer;
               PrevCol:      Integer; {previous coord. (for repainting)}
               PrevSeqNum:   Integer;
               Row,Col:      Integer; {block coordinates}
               Repaint:      Boolean; {flag if block needs repainting}
               ShNum,SeqNum: Integer; {shape and sequence numbers}

             end;

var { declare variables of the program }

   Key:        Char;      {code of the key pressed by player}
   ValidKey:   Boolean;   {flag to validate the pressed key}
   sh:         Shape;
   sh2:        Shape;
   bl:         Block;
   bl2:        Block;
   Pieces:     All;
   CurrBlk:    PtrBlkInfo; {pointer to current block}
   NewBlk:     PtrBlkInfo; {pointer to new block - temporary}
   Bucket:     Scene;

{
   -----------------------------------------------------------
    Display or erase block.
    x, y - screen coordinates (x (column): 1..40,
                               y (row):    1..24)
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
         if sh[i,j] = Filled then
         begin
            if era = True then
              write('  ')
            else
            begin
              write(Chr(27)); { ESC code }
              write('G4  ');  { Reverse ON, space }
              write(Chr(27)); { ESC code }
              write('G0');    { Reverse OFF }
            end;
         end;
      end;
   end;
end;

{
   -----------------------------------------------------------
    Init Shape Array.
    v - Empty or Filled.
   -----------------------------------------------------------
}
procedure InitShape(v: Cell);
var
   i,j: Integer; {column, row}
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
    NOTE: Last row of shape matrix should have a filled cell.
          The same with last column. Will make it easier to
          check if piece can fall down or move right.
   -----------------------------------------------------------
}
procedure InitAllShapes;
var
   i,j: Integer;
begin
   InitShape(Empty);
   {
      #
      #
      #
      #
   }
   sh[4,1] := Filled;
   sh[4,2] := Filled;
   sh[4,3] := Filled;
   sh[4,4] := Filled;
   bl[1] := sh;
   InitShape(Empty);
   {
     # # # #
   }
   sh[1,4] := Filled;
   sh[2,4] := Filled;
   sh[3,4] := Filled;
   sh[4,4] := Filled;
   bl[2] := sh;
   bl[3] := bl[1];
   bl[4] := bl[2];
   Pieces[1] := bl;
   InitShape(Empty);
   {
     # #
     # #
   }
   sh[3,3] := Filled;
   sh[4,3] := Filled;
   sh[3,4] := Filled;
   sh[4,4] := Filled;
   bl[1] := sh;
   bl[2] := sh;
   bl[3] := sh;
   bl[4] := sh;
   Pieces[2] := bl;
   InitShape(Empty);
   {
       #
     # # #
   }
   sh[3,3] := Filled;
   sh[2,4] := Filled;
   sh[3,4] := Filled;
   sh[4,4] := Filled;
   bl[1] := sh;
   InitShape(Empty);
   {
     #
     # #
     #
   }
   sh[3,2] := Filled;
   sh[3,3] := Filled;
   sh[4,3] := Filled;
   sh[3,4] := Filled;
   bl[2] := sh;
   InitShape(Empty);
   {
     # # #
       #
   }
   sh[2,3] := Filled;
   sh[3,3] := Filled;
   sh[4,3] := Filled;
   sh[3,4] := Filled;
   bl[3] := sh;
   InitShape(Empty);
   {
       #
     # #
       #
   }
   sh[4,2] := Filled;
   sh[3,3] := Filled;
   sh[4,3] := Filled;
   sh[4,4] := Filled;
   bl[4] := sh;
   Pieces[3] := bl;
   InitShape(Empty);
   {
     # # #
     #
   }
   sh[2,3] := Filled;
   sh[3,3] := Filled;
   sh[4,3] := Filled;
   sh[2,4] := Filled;
   bl[1] := sh;
   InitShape(Empty);
   {
      # #
        #
        #
   }
   sh[3,2] := Filled;
   sh[4,2] := Filled;
   sh[4,3] := Filled;
   sh[4,4] := Filled;
   bl[2] := sh;
   InitShape(Empty);
   {
          #
      # # #
   }
   sh[4,3] := Filled;
   sh[2,4] := Filled;
   sh[3,4] := Filled;
   sh[4,4] := Filled;
   bl[3] := sh;
   InitShape(Empty);
   {
      #
      #
      # #
   }
   sh[3,2] := Filled;
   sh[3,3] := Filled;
   sh[3,4] := Filled;
   sh[4,4] := Filled;
   bl[4] := sh;
   Pieces[4] := bl;
   InitShape(Empty);
   {
        # #
      # #
   }
   sh[3,3] := Filled;
   sh[4,3] := Filled;
   sh[2,4] := Filled;
   sh[3,4] := Filled;
   bl[1] := sh;
   bl[3] := sh;
   InitShape(Empty);
   {
     #
     # #
       #
   }
   sh[3,2] := Filled;
   sh[3,3] := Filled;
   sh[4,3] := Filled;
   sh[4,4] := Filled;
   bl[2] := sh;
   bl[4] := sh;
   Pieces[5] := bl;
   InitShape(Empty);
   {
     # #
       # #
   }
   sh[2,3] := Filled;
   sh[3,3] := Filled;
   sh[3,4] := Filled;
   sh[4,4] := Filled;
   bl[1] := sh;
   bl[3] := sh;
   InitShape(Empty);
   {
        #
      # #
      #
   }
   sh[4,2] := Filled;
   sh[3,3] := Filled;
   sh[4,3] := Filled;
   sh[3,4] := Filled;
   bl[2] := sh;
   bl[4] := sh;
   Pieces[6] := bl;
end;

{
  -----------------------------------------------------------
   Draw a box of defined dimensions at provided coordinates.
  -----------------------------------------------------------
}
procedure DrawBox(x, y, width, height: Integer);
var
   i: Integer;
begin
   for i := y to y+height-1 do
   begin
      GotoXY(x, i);
      write(Chr(27));
      write('G4 ');
      write(Chr(27));
      write('G0');
      {write(BoxVert);}
      GotoXY(x+width*2+1, i);
      write(Chr(27));
      write('G4 ');
      write(Chr(27));
      write('G0');
      {write(BoxVert);}
   end;
   GotoXY(x, y+height);
   for i := 1 to width*2+2 do
   begin
      write(Chr(27));
      write('G4 ');
      write(Chr(27));
      write('G0');
      {write(BoxHoriz);}
   end;
end;

{
  ---------------------------------------------------------
   Initialize game.
  ---------------------------------------------------------
}
procedure InitGame;
var xx,x1,x2,x3,x4,x5 : Integer;
begin
   InitAllShapes;
   for x1:=1 to ScWidth do
      for x2:=1 to ScHeight do
      begin
         Bucket[x1,x2] := Empty;
      end;
   Randomize;
   Key := 'r';
   ValidKey := False;
   ClrScr;
   DrawBox(ScCol, ScRow, ScWidth, ScHeight);
   { Show all pieces - this will be removed in final version }
   xx := ScWidth; x1 := 4; x2 := 8; x3 := 12; x4 := 16; x5 := 20;
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
   GotoXY(40, 21); write('  E - end');
   { Add 1st piece to the scene. }
   New(NewBlk);
   CurrBlk := NewBlk;
   if CurrBlk <> nil then
      with CurrBlk^ do
      begin
        Col := ScCol + 1;
        Row := ScRow;
        PrevCol := Col;
        PrevRow := Row;
        Repaint := True;
        ShNum := Random(6) + 1;
        SeqNum := Random(4) + 1;
        PrevSeqNum := -1;
      end;
   NewBlk := nil;
end;

{
  ---------------------------------------------------------
  Function checks if piece can be rotated.
  TO DO:
     Implement function.
  ---------------------------------------------------------
}
function CanRotate(prow, pcol, sn, rn : Integer; rright : Boolean) : Boolean;
var
   fret : Boolean;
begin
   fret := True;
   { write code to implement this function }
   CanRotate := fret;
end;

{
  ---------------------------------------------------------
   Function checks if piece can descent one step lower.
   NOTE: In current form this function will not produce
         correct outcome with multiple pieces on the scene.
         It just checks if the piece can fall any lower
         (is clear of the bottom of the scene) with no
         consideration for other pieces.
   TO DO:
         Must add code checking if the piece is clear of
         other pieces on the bottom side.
         (the Scene / Bucket)
  ---------------------------------------------------------
}
function CanGoLower(blkptr : PtrBlkInfo) : Boolean;
var
   fret   : Boolean;
   i      : Integer;
   prow   : Integer;
   pcol   : Integer;
begin
   fret := False;
   with blkptr^ do
   begin
      bl := Pieces[ShNum];
      sh := bl[SeqNum];
      prow := Row;
      pcol := Col;
   end;
   if (prow + 4) < (ScHeight + ScRow) then fret := True;
   { If the piece can go lower in the Bucket without consideration of }
   { other pieces, then now is the time to check for collisions with  }
   { remaining pieces on the Scene (Bucket). }
   if fret = True then
   begin
      { need smart code here to check collisions with the Scene pieces }
      for i:=1 to 4 do
      begin
         if (Bucket[pcol+i-1,prow+3] = Filled) and (sh[i,4] = Filled) then
            fret := False;
      end;
   end;
   CanGoLower := fret;
end;

{
  ---------------------------------------------------------
   Update scene.
   TO DO:
         Must add code to check if the piece can be
         rotated. This includes checking if the piece is
         not obstructed before it can be rotated by the
         boundaries of the scene and by other pieces.
         I will likely implement by adding function
         CanRotate() similar to CanGoLower() and using it
         before rotating the piece.
  ---------------------------------------------------------
}
procedure UpdScene;
var
  Blk:        PtrBlkInfo;
  i, j:       Integer;

begin

  Blk := CurrBlk;

  { refresh block if needed }

  if Blk <> nil then
     with Blk^ do
     begin
        if Repaint = True then
        begin
           if PrevSeqNum > 0 then
              DispBlock(PrevCol,PrevRow,ShNum,PrevSeqNum,True)
           else
              DispBlock(PrevCol,PrevRow,ShNum,SeqNum,True);
           DispBlock(Col,Row,ShNum,SeqNum,False);
           PrevCol := Col;
           PrevRow := Row;
           PrevSeqNum := -1;
           Repaint := False;
        end;
     end;

  if NewBlk <> nil then
  begin

     { dispose of CurrBlk and replace it with new piece }

     Dispose(CurrBlk);
     CurrBlk := NewBlk;
     NewBlk := nil;
     Exit;
  end;

  { perform block rotation }

  if Blk <> nil then
     with Blk^ do
     begin

        if ValidKey and (Key = '.') then
        begin
           if CanGoLower(Blk) = True then
           begin
              if CanRotate(Row, Col, ShNum, SeqNum, True) = True then
              begin
                 Repaint := True;
                 PrevSeqNum := SeqNum;
                 SeqNum := SeqNum + 1;
                 if SeqNum > 4 then SeqNum := 1;
              end;
           end;
        end;

        if ValidKey and (Key = ',') then
        begin
           if CanGoLower(Blk) = True then
           begin
              if CanRotate(Row, Col, ShNum, SeqNum, False) = True then
              begin
                 Repaint := True;
                 PrevSeqNum := SeqNum;
                 SeqNum := SeqNum - 1;
                 if SeqNum < 1 then SeqNum := 4;
              end;
           end;
        end;

     end;

  { perform block falling down and movement }

  if Blk <> nil then
     with Blk^ do
     begin

        if ValidKey and (Key = ';') then
        begin
           if (Col + 3) < (ScCol + 1 + ScWidth) then
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

        if CanGoLower(Blk) = True then
        begin
           Row := Row + 1;
           Repaint := True;
        end
        else { if piece can't go lower, map it to the scene }
        begin
           bl := Pieces[ShNum];
           sh := bl[SeqNum];
           for i:=1 to 4 do
              for j:=1 to 4 do
              begin
                 if ((Col+j-1-ScCol) <= ScWidth) and ((Row+i-1-ScRow) <= ScHeight) then
                    Bucket[Col+j-1,Row+i-1] := sh[j,i];
              end;
        end;

    { Code block below added for demo purpose and will be removed from final }
    { version (or altered - new pieces will be created automatically.) }

       if ValidKey and (Key = '@') and (NewBlk = nil) then
       begin
          New(NewBlk);
          if NewBlk <> nil then
          with NewBlk^ do
          begin
             Col := ScCol + 1 + Random(ScWidth - 4);
             Row := ScRow;
             PrevRow := Row;
             PrevCol := Col;
             ShNum := Random(6) + 1;
             SeqNum := Random(4) + 1;
             Repaint := True;
             PrevSeqNum := -1;
          end;
       end;
    end;

end;

{
 ---------------------------------------------------------
  Get input from player (keyboard).
 ---------------------------------------------------------
}
procedure GetInput;
begin
   if KeyPressed then
   begin
      Read(Kbd,Key);
      ValidKey := True;
   end
   else ValidKey := False;
end;

{
 ---------------------------------------------------------
  Check game-end condition.
 ---------------------------------------------------------
}
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
