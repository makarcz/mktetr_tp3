{
   -----------------------------------------------------------
   Project: MKTRIS
            Tetris-like game / Tetris clone.
   File:    mktetio.pas
   Purpose: Routines to handle keyboard input.
   Author:  Copyright (C) by Marek Karcz 2016-2020.
            All rights reserved.
   -----------------------------------------------------------
}

{
 ---------------------------------------------------------
 Initialize pressed keys FIFO buffer.
 ---------------------------------------------------------
}
procedure InitKeyBuf;
var
   i:   Integer;
begin
   Key := InvalidKey;
   ValidKey := False;
   KeyBufBegin := 1;
   KeyBufEnd   := 1;
   for i := 1 to KeyBufLen do
   begin
      KeyBuf[i] := InvalidKey;
   end;
end;

{
 ---------------------------------------------------------
 Add character to a circular FIFO buffer.
 ---------------------------------------------------------
}
procedure AddKey2Buf(key2Add: Char);
begin
   KeyBuf[KeyBufEnd] := key2Add;
   KeyBufEnd := KeyBufEnd + 1;
   if (KeyBufEnd > KeyBufLen) then
   begin
      KeyBufEnd := 1;
   end;
   if (KeyBufEnd = KeyBufBegin) then
   begin
      KeyBufBegin := KeyBufBegin + 1;
      if (KeyBufBegin > KeyBufLen) then
      begin
         KeyBufBegin := 1;
      end;
   end;
end;

{
 ---------------------------------------------------------
 Get character from a circular FIFO buffer.
 ---------------------------------------------------------
}
function GetKeyFromBuf: Char;
begin
   if (KeyBufBegin = KeyBufEnd) then
   begin
      GetKeyFromBuf := InvalidKey;  { empty buffer }
   end
   else
   begin
      GetKeyFromBuf := KeyBuf[KeyBufBegin];
      KeyBufBegin := KeyBufBegin + 1;
      if (KeyBufBegin > KeyBufLen) then
      begin
         KeyBufBegin := 1;
      end;
   end;
end;

{
 ---------------------------------------------------------
  Get input from player (keyboard).
  Previous key must be consumed before new read is
  allowed.
 ---------------------------------------------------------
}
procedure GetInput;
var
   LocKey: Char;
begin
   LocKey := InvalidKey; { undefined }
   { if key was pressed, add character to FIFO }
   if KeyPressed then
   begin
      Read(Kbd,LocKey);
      AddKey2Buf(LocKey);
   end;
   { if time to read user input, get character from FIFO }
   if (ValidKey = False) then
   begin
      Key := GetKeyFromBuf;
      if (Key <> InvalidKey) then
      begin
         ValidKey := True;
      end;
   end;
end;

{ * * *         EOF         * * * }