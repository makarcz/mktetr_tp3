{
   -----------------------------------------------------------
   Project: MKTRIS
            Tetris-like game / Tetris clone.
   File:    mktetsct.pas
   Purpose: Routines to handle hi-score.
   Author:  Copyright (C) by Marek Karcz 2016-2020.
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
   Close(HiScoreFile);
end;

{
   -----------------------------------------------------------
   Read scores from a hi-score file.
   -----------------------------------------------------------
}
procedure ReadHiScore;
var
   iook  : Boolean;
   i     : Integer;
begin
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
   Close(HiScoreFile);
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

{
   ------------------------------------------------------------------
   Insert score into table below equal or higher score entry.
   Shift entries below down. Save table to file.
   ------------------------------------------------------------------
}
procedure InsertScore(pn: PlName; scre: Integer);
var
   i, j:      Integer;
   keepGoing: Boolean;
begin
   i := 1;
   keepGoing := True;
   while keepGoing and (i < 6) do
   begin
      with HiScTbl[i] do
      begin
         if (scre > Score) then
         begin
            for j := 5 downto i do
            begin
               HiScTbl[j] := HiScTbl[j-1];
            end;
            PlrName := pn;
            Score := scre;
            keepGoing := False;
         end;
      end;
      i := i + 1;
   end;
   if (keepGoing = False) then
   begin
      WriteHiScore;
   end;
end;

{  * * *      EOF      * * * }
