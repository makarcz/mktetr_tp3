
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
                  write(Chr(27)); { ESC code }
                  write('G4  ');  { Reverse ON, space }
                  write(Chr(27)); { ESC code }
                  write('G0');    { Reverse OFF }
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
            write(Chr(27)); { ESC code }
            write('G4  ');  { Reverse ON, space }
            write(Chr(27)); { ESC code }
            write('G0');    { Reverse OFF }
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
  Refresh score on the screen.
  ---------------------------------------------------------
}
procedure RefreshScore;
begin
   GotoXY(40, 1);  write('Score: ', Score);
end;

