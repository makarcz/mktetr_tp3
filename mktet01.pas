{
   -----------------------------------------------------------
   Project: MKTRIS
            Tetris-like game / Tetris clone.
   File:    mktet01.pas
   Purpose: Functions definitions for game initialization and
            presentation layer.
   Author:  Copyright (C) by Marek Karcz 2016-2018.
            All rights reserved.
   -----------------------------------------------------------
}

{
   -----------------------------------------------------------
   Write hi-score table with hihest score player on top.
   This file is updated with a new value every time the new
   score is grater than the one currently on file when game
   ends.
   -----------------------------------------------------------
}
procedure WriteHiScore;
var
   i: Integer;
begin
   Assign(HiScoreFile, HiScFname);
   Rewrite(HiScoreFile);
   for i := 1 to 5 do
   begin
      Write(HiScoreFile, HiScTbl[i]);
   end;
   {Write(HiScoreFile, score);}
   Close(HiScoreFile);
end;

{
   -----------------------------------------------------------
   Read scores from a hi-score file.
   -----------------------------------------------------------
}
procedure ReadHiScore;
var
   {score : Integer;}
   iook  : Boolean;
   i     : Integer;
begin
   {score := 0;}
   Assign(HiScoreFile, HiScFName);
   {$I-} Reset(HiScoreFile) {$I+} ;
   iook := (IOresult = 0);
   if not iook then { hi-score file doesn't exist, write one }
   begin
      WriteHiScore;
      Assign(HiScoreFile, HiScFName);
      Reset(HiScoreFile);
   end;
   for i := 1 to 5 do
   begin
      Read(HiScoreFile, HiScTbl[i]);
   end;
   {Read(HiScoreFile, score);}
   Close(HiScoreFile);
   {ReadHiScore := score;}
end;

{
   -----------------------------------------------------------
    Display or erase block.
    x, y - screen coordinates (x (column): 1..40,
                               y (row):    1..24)
    sn - shape # (1..NumOfPcs)
    rn - sequence/rotation # (1..4)
    era - True: erase block/False: paint block.
    cs - True: validate coordinates against scene boundaries
   -----------------------------------------------------------
}
procedure DispBlock(x,y,sn,rn: Integer; era: Boolean; cs: Boolean);
var
   i,j:     Integer;
   scv:     Boolean; { within scene coordinates }
   col,row: Integer;
begin
   scv := False;
   bl := Pieces[sn];
   sh := bl[rn];
   for j := 1 to 4 do
   begin
      row := y + j - 1;
      for i := 1 to 4 do
      begin
         col := x * 2 + i * 2 - 4;
         if cs = True then
         begin
            if (col > ScCol) and (col <= (ScCol + 1 + ScWidth * 2))
               and
               (row >= ScRow) and (row <= (ScRow + ScHeight))
            then scv := True;
         end
         else scv := True;
         if scv = True then
         begin
            {GotoXY(col, row);}
            if sh[i,j] = Filled then
            begin
               GotoXY(col,row);
               if era = True then
                  write('  ')
               else
               begin
                  if SolidBlocks then
                  begin
                     write(Chr(27)); { ESC code }
                     write('G4  ');  { Reverse ON, space }
                     write(Chr(27)); { ESC code }
                     write('G0');    { Reverse OFF }
                  end
                  else
                     write('[]');
               end;
            end;
         end;
      end;
   end;
end;

{
   -----------------------------------------------------------
   Repaint bucket contents on the scene.
   -----------------------------------------------------------
}
procedure RepaintBucket;
var
   x, y, col, row : Integer;
begin
   for y := 1 to ScHeight do
   begin
      row := y + ScRow - 1;
      col := ScCol + 1;
      GotoXY(col,row);
      for x := 1 to ScWidth do
      begin
         if Bucket[x,y] = Filled then
         begin
            if SolidBlocks then
            begin
               write(Chr(27)); { ESC code }
               write('G4  ');  { Reverse ON, space }
               write(Chr(27)); { ESC code }
               write('G0');    { Reverse OFF }
            end
            else
               write('[]');
         end
         else write('  ');
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
   n: Integer; {piece number}
begin
   n := 1;
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
   Pieces[n] := bl;
   n := n + 1;
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
   Pieces[n] := bl;
   n := n + 1;
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
   Pieces[n] := bl;
   n := n + 1;
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
   Pieces[n] := bl;
   n := n + 1;
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
   Pieces[n] := bl;
   n := n + 1;
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
   Pieces[n] := bl;
   n := n + 1;
   InitShape(Empty);
   {
     #
     # # #
   }
   sh[2,4] := Filled;
   sh[3,4] := Filled;
   sh[4,4] := Filled;
   sh[2,3] := Filled;
   bl[1] := sh;
   InitShape(Empty);
   {
      # #
      #
      #
   }
   sh[4,2] := Filled;
   sh[3,2] := Filled;
   sh[3,3] := Filled;
   sh[3,4] := Filled;
   bl[2] := sh;
   InitShape(Empty);
   {
      # # #
          #
   }
   sh[4,4] := Filled;
   sh[2,3] := Filled;
   sh[3,3] := Filled;
   sh[4,3] := Filled;
   bl[3] := sh;
   InitShape(Empty);
   {
        #
        #
      # #
   }
   sh[4,2] := Filled;
   sh[4,3] := Filled;
   sh[4,4] := Filled;
   sh[3,4] := Filled;
   bl[4] := sh;
   Pieces[n] := bl;
end;

{
  -----------------------------------------------------------
   Draw an open U-shaped box of defined dimensions at
   provided coordinates.
  -----------------------------------------------------------
}
procedure DrawBox(x, y, width, height: Integer);
var
   i: Integer;
begin
   for i := y to y+height-1 do
   begin
      GotoXY(x, i);
      if Pretty then
      begin
         write(Chr(27));
         write('G4 ');
         write(Chr(27));
         write('G0');
      end
      else
         write(')');
      {write(BoxVert);}
      GotoXY(x+width*2+1, i);
      if Pretty then
      begin
         write(Chr(27));
         write('G4 ');
         write(Chr(27));
         write('G0');
      end
      else
         write('(');
      {write(BoxVert);}
   end;
   GotoXY(x, y+height);
   for i := 1 to width*2+2 do
   begin
      if Pretty then
      begin
         write(Chr(27));
         write('G4 ');
         write(Chr(27));
         write('G0');
      end
      else
         write('^');
      {write(BoxHoriz);}
   end;
end;

{
  ---------------------------------------------------------
  Refresh score on the screen.
  ---------------------------------------------------------
}
procedure RefreshScore;
begin
   GotoXY(InfoCol, 1);
   write(PlayerName, ' Score: ', Score);
   with HiScoreRec do
      write('   Hi-Score: ', PlrName, ' ', Score);
end;

