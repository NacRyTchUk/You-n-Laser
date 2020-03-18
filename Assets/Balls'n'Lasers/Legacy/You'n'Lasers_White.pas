
{
Список того, чем стоит занятся:
-Сделать мап эдитор
~Доделать миниигру
-Ачивки?
-НПС
+Первая/катсцены в общем
-живность
-Экраны анимации/зарузки
~Сюжетец/цель
}
uses abcsprites, abcobjects, graphabc, timers;

type
  int = integer;
  Str = string;
  bool = boolean;
  float = char;
  pic = PictureABC;
  obj = ObjectABC;
  spr = SpriteABC;
  textbox = TextABC;

const
  Layers = 5; //Количество уровней (Обьекты заднего фона, обьекты между игроком и персоонажем)
  CountOfScrens = 10; //Количество 'Полей' 
  grav = 3; //Гравитация
  vforce = 30; // Сила с которой мы еденично действуем на обьект придавая ему скорость вертикально
  hforce = 8; //Горизонтальная разовая сила
  trenie = 1; // Сила замедляющее тело во время скольжения 
  vspdMAX = 50;// Максимальна скорость на которую может ускориться игрок по вертикали
  nilxpos = 142; 
  nilypos = 77;

var
  Blocks, minigameBlocks: array of spr;
  Fields: array [0..20, 0..10, 0..Layers] of byte;
  LocationOfFields: array [1..12, 1..8] of byte;
  BlocksOfField: array [1..400, 0..layers] of spr;
  BlocksOfMiniField: array [1..160] of spr;
  CounterOfBlocksL: array [0..layers] of int;
  FieldsName, FieldsMiniGame: array of Str;
  BlockCount, BlockCountMini, hspd, vspd, px, py, mxold, myold, mousex, mousey: int; 
  Player: spr;
  CurModeOfScreen: Str;
  vLeft, vRight, vUp, vDown, vShift, vSpase, vEkey, vActivateItem: bool; //Флаги клавиш
  OnFloor, onRoof, CanMove, lookl, lookr, falling, testfalling, lstop, rstop, ustop, sprint, isMiniGameStartsDo, IsMiniGameIsFinished,newgame,istextinroomisactivaited: bool; // Флаги состояний
  Selector := new spr(-64, -64, 'Sprites\UI\Selector.png'); ///!!!!!!!!!!!!!!!!!!!!!!!
  MiniGameStartRotate, MiniGameStartX, MiniGameStartY, StartScreenX, StartScreenY, CurScreenX, CurScreenY, ActiveItemX, ActiveItemY, activateitemID: int;
  CurScreen: int := 1;
  textforboxes : array[1..100,1..20] of Str;
  playbutt, infobutt,exitbutt,playbutt2, infobutt2,exitbutt2: spr;
  alternativepayer : spr;
type
  minigameempt = record
    empty: bool;
    objectspr: spr;
    typeofobgect: Str;
    rotate: int;
    numerofsprite: int;
  end;

type
  position = record
    x: int;
    y: int;
  end;


 type 
    magsphere = record
      Spritesphere : spr;
      CurScreen : int;
      LocationOfScreen : position;
      curID : int;
      Active : bool;
   end;


type
  savefile = record 
    CurScreen: position;
    PlayerPos: position;
    magicsphereaktive : array[1..100] of bool; 
  
  end;
  
   
var
  MagicSphere : array[1..10] of magsphere;
  minigamefield: array[1..16, 1..8] of minigameempt;
  dataforsave: savefile;
  
procedure AniTimer(); forward;

procedure game(); forward;

procedure menu(); forward;

procedure minigame(); forward;

procedure undrawfield(); forward;

function booltostr(answ: bool): str; forward;

procedure kup(key: int); forward;

procedure minigamePlateRotate(xp, yp: int); forward;

procedure savein(); forward;

procedure loadfrom(); forward;

var
  ATimer := new timers.Timer(100, AniTimer);

var
  mapspr: spr;




//==============================Вывод далоговых окон============================
procedure TextBoxStart(x, y: int; text: Str);
var curcolor : Color;
begin
  var temp : array of Str := text.Split('&');
  text := temp[1];
  
  case StrToInt(temp[0]) of 
    1 : curcolor := clLightGreen;
    2 : curcolor := clRed;
    3 : curcolor := clLightBlue;
  end;
  var textboxback := new spr(x, y, 'Sprites/UI/TextBoxGreen.png');
  var textboxtest := new textbox(x + 20, y + 20, 14, '', curcolor);
  SetFontName('Comic Sans MS');
  var textik: Str := text;
  var linescount: int;
  if vRight then kup(VK_Right); 
  if vShift then  kup(VK_Shift);
  if vLeft then kup(vk_left); 
  if vSpase then  kup(VK_Space); //kup(VK_J);
  CanMove := false;
  
  for var i: int := 1 to textik.Length do
  begin
    
    textboxtest.Text := textboxtest.Text + textik[i];
    if (textik[i] = ' ') and (textboxtest.Text.Length div 30 > linescount) then begin textboxtest.Text := textboxtest.Text + #10#13; Inc(linescount); end;
    Sleep(10);
  end;
  
  while not vSpase do 
  begin
    Sleep(100);  
  end;
  textboxtest.Destroy;
  textboxback.Destroy;
  
  
  
  CanMove := true;
end;


//===================Быстрый вывод сообщения===============================
procedure msg(text: str);
begin
  
  //MessageBox.Show(text, 'Debug', MessageBoxButtons.OK, MessageBoxIcon.Asterisk, MessageBoxDefaultButton.Button1, MessageBoxOptions.ServiceNotification);
end;


//===================Ввод информации с клавы и мышки===========================
procedure mmove(mx, my, mb: int);
var
  i, j, xc, yc, bcx, bcy: integer;
begin
  mousex := mx; mousey := my;
  case CurModeOfScreen of
    'Game':
      begin
       
      end;
    'Menu':
      begin
        try
          begin 
                LockDrawingObjects;
                if (ObjectUnderPoint(mx,my) = playbutt) or (ObjectUnderPoint(mx,my) = playbutt2) then begin
                playbutt2.Visible := true; 
                end else begin
                playbutt2.visible := false;
                end;
                UnLockDrawingObjects;
               
                if (ObjectUnderPoint(mx,my) = infobutt) or (ObjectUnderPoint(mx,my) = infobutt2) then begin
                infobutt2.Visible := true; 
                end else begin
                infobutt2.visible := false;
                end;
               
                if (ObjectUnderPoint(mx,my) = exitbutt ) or (ObjectUnderPoint(mx,my) = exitbutt2) then begin
                exitbutt2.Visible := true; 
                end else begin
                exitbutt2.visible := false;
                end; end
        except;
      end; end;
  
  
end; end;

var
  vclick: bool;
var infobar : spr;
procedure mdown(mx, my, mb: int);
begin
  case CurModeOfScreen of 
    'Game':
      begin
        end;
    'Menu': 
      begin
        
        if ObjectUnderPoint(mx, my) = playbutt2 then begin vclick := true; curmodeofscreen := 'Game'; end;
        if ObjectUnderPoint(mx, my) = infobutt2 then begin infobar := new spr(0,0,'Sprites\Backround\info.png'); Sleep(10000); infobar.destroy;  end;
        if ObjectUnderPoint(mx, my) = exitbutt2 then begin vclick := true; Window.Close; end;
      end;
    'MiniGame': 
      begin
        
        minigamePlateRotate(((mx - nilxpos) div 64) + 1, ((my - nilypos) div 64) + 1);
        
      end;
  end; end;

procedure mup(mx, my, mb: int);
begin
  
end;

procedure kpress(key: float);
begin
  
end;


procedure kup(key: int);
begin
  case CurModeOfScreen of
    'Game':
      begin
        case key of
          VK_Left: begin vLeft := false; if not CanMove then exit; hspd := 0; Player.State := 5; if vRight then begin lookr := true; end; end;
          VK_Right: begin vRight := false; if not CanMove then exit; hspd := 0; Player.State := 2; if vleft then begin lookl := true; end; end;
          VK_Space: begin vSpase := false; end;
          VK_ShiftKey: begin vShift := false;  sprint := false; hspd := hspd div 2; ATimer.Interval := 100; end;
          VK_E: vEkey := false;
        end;
      end;
    'Menu':
      begin
        case key of
          VK_Space: begin vSpase := false; end;
        end;
      end;
    'MiniGame': 
      begin
        case key of
          vk_space: begin vSpase := false end;
        end; end;
  
  end; end;

var
  yep: bool;

procedure kdown(key: int);

begin
  case CurModeOfScreen of 
    'Game':
      begin
        var plxl, plxr, plyu, plyd: int;
        plxl := Player.Position.X - hforce; plyu := Player.Position.Y + Player.Height - 5; plxr := Player.Position.X + Player.Width + hforce; plyd := Player.Position.Y + Player.Height - 5;
        plxl := (plxl - (plxl mod 64)) div 64; plyu := (plyu - (plyu mod 64)) div 64; plxr := (plxr - (plxr mod 64)) div 64; plyd := (plyd - (plyd mod 64)) div 64;
        
        if ((vLeft) and (vRight)) then exit;
        case key of
          VK_Left:
            begin
              if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) or not CanMove then exit;
              if not lstop and (Fields[plxl, plyd, 1] = 0) then begin
                if vRight then begin kup(VK_Right); exit; end;
                vLeft := true;
                if not lookl then begin LookL := true; lookr := false; end;
                if canmove then Player.State := 4; hspd := -hforce;
              end else begin exit; end; end;
          VK_Right:
            begin
              if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) or not CanMove then exit;     
              if not rstop and (Fields[plxr, plyd, 1] = 0) then begin
                if vLeft then begin kup(VK_Left); exit; end;
                vRight := true; 
                if not LookR then begin LookR := true; LookL := false; end;
                if canmove then Player.State := 1; hspd := hforce; end; end;
          VK_Space: begin vSpase := true;  if not CanMove then exit; if canmove and OnFloor then begin vspd := vforce; if LookR then if not vRight then Player.State := 3 else if not vLeft then Player.State := 6;  end; end;
          VK_ShiftKey: begin vShift := true; if (vLeft xor vRight) and CanMove and not sprint then begin sprint := true; hspd := hspd * 2; ATimer.Interval := 50;  end; end;
          VK_Escape: begin undrawfield(); menu; end;
          VK_J: yep := true;
          VK_E: 
            begin
              vEkey := true;  
              if vActivateItem then begin
                undrawfield();
                Player.Destroy;
                CurModeOfScreen := 'MiniGame';
                exit;
              end; end; 
          VK_M: 
            begin
              mapspr.ToFront; 
              var i: int;
              for i := -7 to 0 do  mapspr.MoveTo(0, i * 100 + 8); 
              
              Sleep(3000);
              for I := 0 downto -7 do mapspr.MoveTo(0, I * 100 - 8);
            end;
        
        end;
        
      end;
    'Menu':
      begin
        case key of
          Vk_Space: begin vSpase := true; vclick := true; CurModeOfScreen := 'Game';  end; 
        
        
        
        end; end;
    'MiniGame': 
      begin
        case key of
          vk_space: begin vSpase := true end;
        end;
      end;
  end;
end;



var BlocksName : array of str;

//===================Подгрузка обьектов=======================
procedure loadobjfromfile(Path: str);
var
  fileofblocks, fileofminigameblocks: text;
   minigameBlocksName: array of str;
  i: int := 0;
  Line: Str;
begin
  mapspr := new spr(0, -708, 'Sprites\UI\Map.png');
  
  Assign(fileofblocks, 'Sprites\Blocks\' + Path);
  Reset(fileofblocks);
  repeat
    Readln(fileofblocks, Line);
    if Line = '' then break; 
    SetLength(BlocksName, I + 1);
    SetLength(Blocks, I + 1);   
    
    Line := 'Sprites\Blocks\' + Line;
    BlocksName[i] := Line;
    Blocks[i] := new spr(-64, -64, Line);
    Blocks[i].Visible := false;
    
    Inc(i);
  until Line = 'End.';
  
  i := 0;
  Assign(fileofminigameblocks, 'Sprites\Blocks\MiniGameSprites.list');
  Reset(fileofminigameblocks);
  repeat
    Readln(fileofminigameblocks, Line);
    if Line = '' then break; 
    SetLength(minigameBlocksName, I + 1);
    SetLength(minigameBlocks, I + 1);   
    Line := 'Sprites\Blocks\' + Line;
    minigameBlocksName[i] := Line;
    minigameBlocks[i] := new spr(-64, -64, Line);
    minigameBlocks[i].Visible := false;
    
    Inc(i);
  until Line = 'End.';
end;

//==================Первоначальная подгрузка всего=============================
procedure loadfieldfromfile();
var
  FieldFile, FieldLocationFile,FileT: Text;
  Line: Str;
  i, j, Layer: int;

begin
  Assign(Fieldfile, 'Fields\Main\Fields.list'); //Подгружаем список всех экранов
  Reset(FieldFile);
  
  repeat
    Readln(FieldFile, Line);
    if Line = '' then break;
    Line := 'Fields\Main\' + Line;
    SetLength(FieldsName, i + 1);
    FieldsName[i] := Line;
    
    Inc(i);
  until Line = 'End.';
  Close(FieldFile);
  
  
  i := 0;
  Assign(Fieldfile, 'Fields\MiniGame\Fields.list'); //Подгружаем список всех экранов
  Reset(FieldFile);
  
  repeat
    Readln(FieldFile, Line);
    if Line = '' then break;
    Line := 'Fields\MiniGame\' + Line;
    SetLength(FieldsMiniGame, i + 1);
    FieldsMiniGame[i] := Line;
    
    Inc(i);
  until Line = 'End.';
  Close(FieldFile);
  
  Assign(FieldLocationFile, 'Fields\Main\LocationOfFields.list');
  Reset(FieldLocationFile);
  for i := 1 to 8 do 
  begin
    Readln(FieldLocationFile, Line);
    if Line = '' then break;
    var temp: array of Str := Line.Split(';');
    for j := 0 to 11 do 
      LocationOfFields[j + 1, i] := 
      StrToInt(temp[j]);
  end;
  Close(FieldLocationFile);
 
  Assign(FileT,'Assets\Dialog.list');
  Reset(FileT);
  i:=1;
  repeat
    Readln(FileT, Line);
    if Line = '' then break;
    var temp : array of Str := Line.Split(';');
    for j := 0 to temp.Length -1 do
    textforboxes[i,j+1] := temp[j];
    
    Inc(i);
  until Line = 'End.';
  Close(FileT);
end;


//=======================Разворот обьектов=======================================
procedure minigamePlateRotate(xp, yp: int);
begin
  
  
  try
    if minigamefield[xp, yp].typeofobgect = 'finish' then exit;
    if isMiniGameStartsDo then exit;
    LockDrawingObjects;
    if minigamefield[xp, yp].rotate <> 4 then begin
      Inc(minigamefield[xp, yp].rotate);
      Inc(minigamefield[xp, yp].numerofsprite);
    end  else begin
      minigamefield[xp, yp].numerofsprite := minigamefield[xp, yp].numerofsprite - 3;
      minigamefield[xp, yp].rotate := 1;
    end;
    minigamefield[xp, yp].objectspr.Destroy;
    minigamefield[xp, yp].objectspr := minigameBlocks[minigamefield[xp, yp].numerofsprite - 1].Clone;
    minigamefield[xp, yp].objectspr.Visible := true;
    minigamefield[xp, yp].objectspr.MoveTo(xp * 64 + nilxpos - 64, yp * 64 + nilypos - 64);
    
    UnLockDrawingObjects;
  except end;
end;

//=================Загрузка определенного экрана====================
procedure loadscreenfrombuffer(Path: Str);
var
  FieldFile: Text;
  Line: Str;
  i, j, ij, Layer: int;

begin
  
  Assign(Fieldfile, Path); //Загрузка информации о обьектах из заданного экрана в память
  Reset(Fieldfile);
  for ij := 1 to 5 do
    for i := 0 to 10 do
    begin
      Readln(Fieldfile, Line);
      var blkInfo: array of Str := Line.Split(';');
      SetLength(blkInfo, 21);
      for j := 0 to 20 do
      begin
        if blkInfo[j] <> '' then Fields[j, i, ij] := StrToInt(blkInfo[j]);
      end;
    end;
  
end;

//=================Загрузка определенного экрана миниигры====================
procedure loadminigamefrombuffer(Path: Str);
var
  FieldFile: Text;
  Line: Str;
  i, j, ij, Layer: int;

begin
  
  Assign(Fieldfile, Path); //Загрузка информации о обьектах из заданного экрана в память
  Reset(Fieldfile);
  //for ij := 1 to 5 do
  for i := 1 to 8 do
  begin
    Readln(Fieldfile, Line);
    var blkInfo: array of Str := Line.Split(';');
    SetLength(blkInfo, 17);
    for j := 1 to 16 do
    begin
      if blkInfo[j - 1] <> '0' then begin
        
        if (StrToInt(blkInfo[j - 1]) <= 4) and (StrToInt(blkInfo[j - 1]) >= 1) then begin
          minigameField[j, i].typeofobgect := 'plate'; 
          
          case StrToInt(blkInfo[j - 1]) of
            1: minigameField[j, i].rotate := 1;
            2: minigameField[j, i].rotate := 2;
            3: minigameField[j, i].rotate := 3;
            4: minigameField[j, i].rotate := 4; end; end;
        if (StrToInt(blkInfo[j - 1]) <= 12) and (StrToInt(blkInfo[j - 1]) >= 9) then begin
          minigameField[j, i].typeofobgect := 'start';
          
          case StrToInt(blkInfo[j - 1]) of
            9: minigameField[j, i].rotate := 1;
            10: minigameField[j, i].rotate := 2;
            11: minigameField[j, i].rotate := 3;
            12: minigameField[j, i].rotate := 4; end;
          MiniGameStartX := j; MiniGameStartY := i; MiniGameStartRotate := minigameField[j, i].rotate;
        end;
        if StrToInt(blkInfo[j - 1]) = 13 then   minigameField[j, i].typeofobgect := 'finish'; 
        
        
        
        
        
        
        minigameField[j, i].empty := true;
        minigameField[j, i].numerofsprite := StrToInt(blkInfo[j - 1]); 
      end else;
    end;
  end;
  
end;

//=================Выгруз определенного экрана====================
procedure unloadscreenfrombuffer(curscreen: int);
var
  FieldFile: Text;
  Line: Str;
  i, j, ij, Layer: int;

begin
  
  
  for ij := 1 to 5 do
    for i := 0 to 10 do
    begin
      
      for j := 0 to 20 do
      begin
        Fields[j, i, ij] := 0;
      end;
    end;
  
end;

//==========================Перевод переменной типа Bool к Str==================
function BoolToStr(Answ: bool): Str;
begin
  if Answ then BoolToStr := 'true' else BoolToStr := 'false'; 
  
end;


var cursphereid : array[1..10] of byte;
var curspherenumb : byte;

//=================Отрисовка поля=========================
procedure drawfield(layer, CurScreen: int);
var
  i, j: int;
begin
  for i:=1 to 10 do MagicSphere[i].curID := 0;
  curspherenumb := 0;
  
  for layer := 1 to 5 do 
    for i := 0 to 10 do 
      for j := 0 to 20 do
      begin
        if Fields[j, i, layer] <> 0 then
        begin
         
          Inc(BlockCount);
          Inc(CounterOfBlocksL[layer]);
          if (layer = 5) and not dataforsave.magicsphereaktive[Fields[j, i, layer]]  then begin
            Inc(curspherenumb);
            MagicSphere[curspherenumb].LocationOfScreen.x := j;
            MagicSphere[curspherenumb].LocationOfScreen.x := i;
            MagicSphere[curspherenumb].CurID := Fields[j, i, layer];
            Fields[j, i, layer] := 54;
           if dataforsave.magicsphereaktive[Fields[j, i, layer]] then Fields[j, i, layer] := 55 else Fields[j, i, layer] := 54;
          
          end;
          if (dataforsave.magicsphereaktive[CurScreen] or IsMiniGameIsFinished) and (Fields[j, i, 1] = 56) then begin Fields[j, i, 2] := 57; Fields[j, i, 1] := 0; Dec(CounterOfBlocksL[1]); Dec(BlockCount);  end;
          if (layer = 5) and dataforsave.magicsphereaktive[Fields[j, i, layer]]  then begin
            Fields[j, i, layer] := 55;
          end;
          if Fields[j, i, layer] = 54 then begin
          MagicSphere[curspherenumb].Spritesphere  := new spr(j * 64, I * 64,BlocksName[Fields[j, i, layer]]);
          if not istextinroomisactivaited then istextinroomisactivaited := true;
          BlocksOfField[CounterOfBlocksL[layer], layer] := Blocks[Fields[j, i, layer]].Clone;
          end else begin
          if Fields[j, i, layer] <> 0 then begin
          BlocksOfField[CounterOfBlocksL[layer], layer] := 
          new spr(j * 64, I * 64,BlocksName[Fields[j, i, layer]]);
          if layer = 3 then BlocksOfField[CounterOfBlocksL[layer], layer].ToBack; end;
          end;
        end;
      end;
   
end;


//=================Выгрузка поля=========================
procedure undrawfield();
var
  i, j: int;
begin
  
  for j := 1 to 5 do 
  begin
    for i := 1 to CounterOfBlocksL[j]   do 
    
    begin
      
      BlocksOfField[i, j].Destroy;  
      
    end;
    CounterOfBlocksL[j] := 0;
    
    
  end;
  for i:=1 to curspherenumb do MagicSphere[i].Spritesphere.Destroy;
  BlockCount := 0;
  unloadscreenfrombuffer(CurScreen);
  
  
  
end;
//===================Таймер отвечающий за анимацию персоонажа===================
procedure AniTimer();
begin
  if Player.Frame < 5 then Player.Frame := Player.Frame + 1;
  if Player.Frame  = 5 then Player.Frame := 1;
  if alternativepayer.Frame < 5 then alternativepayer.Frame := Player.Frame + 1;
  if alternativepayer.Frame  = 5 then alternativepayer.Frame := 1;
  
end;


//Счетчик кадров
procedure FrameTimer(FrameTimer:int);
begin
  
end;




var
  yes: bool;
//==============Отрисовка лазера в мини-игре=============================================
var
  cursor := new SpriteABC(-12, -12, 'Sprites\Effects\LaserCursor.png');

var
  alldotsofliser := new List<SpriteABC>;

var
  LaserPart := new spr(-6, -6, 'Sprites\Effects\LaserParticle.png');

procedure partlaserdraw(xf, yf, rotate, otordo: int);
var
  i, xnul, ynul, step, sleeptime, xnulsum, ynulsum, otstx, otsty, squaresize: int;
  colorofsqre: Color := clRed;
begin
  
  step := 2; sleeptime := 1;  squaresize := 6; otstx := nilxpos - 64 - squaresize div 2; otsty := nilypos - 64 - squaresize div 2; 
  
  if (rotate = 2) or (rotate = 4) then begin xnul := 1; ynulsum := 32; end else begin ynul := 1; xnulsum := 32; end; 
  
  SetBrushColor(clRed); SetPenColor(clRed); 
  
  if otordo = 0 then begin
    
    if (rotate = 2) or (rotate = 3) then begin
      for i := 1 to 16 div (step * 2) do
      begin
        cursor.MoveTo(otstx + xf * 64 + 4 * step * i * xnul + xnulsum - squaresize div 2, otsty + yf * 64 + 4 * step * i * ynul + ynulsum - squaresize div 2);
        alldotsofliser.Add(LaserPart.Clone);
        alldotsofliser.Item[alldotsofliser.Count - 1].moveto(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum);
        Sleep(sleeptime);  
      end; end else begin
      for i := 16 div step downto 16 div (step * 2) do
      begin
        cursor.MoveTo(otstx + xf * 64 + 4 * step * i * xnul + xnulsum - squaresize div 2, otsty + yf * 64 + 4 * step * i * ynul + ynulsum - squaresize div 2);
        alldotsofliser.Add(LaserPart.Clone);
        alldotsofliser.Item[alldotsofliser.Count - 1].moveto(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum);
        Sleep(sleeptime);
      end;
    end; end  else begin
    if (rotate = 2) or (rotate = 3) then begin
      for i := 16 div (step * 2) to 16 div (step) do
      begin
        cursor.MoveTo(otstx + xf * 64 + 4 * step * i * xnul + xnulsum - squaresize div 2, otsty + yf * 64 + 4 * step * i * ynul + ynulsum - squaresize div 2);
        alldotsofliser.Add(LaserPart.Clone);
        alldotsofliser.Item[alldotsofliser.Count - 1].moveto(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum);
        Sleep(sleeptime);
      end; end else begin
      for i := 16 div (step * 2) downto 1 div (step * 2) do
      begin
        cursor.MoveTo(otstx + xf * 64 + 4 * step * i * xnul + xnulsum - squaresize div 2, otsty + yf * 64 + 4 * step * i * ynul + ynulsum - squaresize div 2);
        alldotsofliser.Add(LaserPart.Clone);
        alldotsofliser.Item[alldotsofliser.Count - 1].moveto(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum);
        Sleep(sleeptime);
      end; 
    end; end;
  SetBrushColor(clwhite); SetPenColor(clwhite);
  cursor.ToFront;
  
end;

procedure changePlate(sx, sy, delornew: int);
begin
  if delornew = 1 then begin
    LockDrawingObjects; 
    minigamefield[sx, sy].objectspr.Destroy; minigamefield[sx, sy].objectspr := minigameBlocks[minigamefield[sx, sy].rotate - 1 + 4].Clone;
    minigamefield[sx, sy].objectspr.MoveTo(nilxpos + sx * 64 - 64, nilypos + sy * 64 - 64); 
    minigamefield[sx, sy].objectspr.Visible := true; 
    unlockDrawingObjects;
  end else begin
    LockDrawingObjects; minigamefield[sx, sy].objectspr.Destroy; minigamefield[sx, sy].objectspr := minigameBlocks[minigamefield[sx, sy].rotate - 1 + 4].Clone; 
    minigamefield[sx, sy].objectspr.MoveTo(nilxpos + sx * 64 - 64, nilypos + sy * 64 - 64); 
    minigamefield[sx, sy].objectspr.Visible := true; unlockDrawingObjects;
  end;
end;



function questrotating(sx, sy, currotation: int): int;
begin
  case minigamefield[sx, sy].typeofobgect of 
    '': begin questrotating := currotation; end;
    'plate':
      begin
        
        case minigamefield[sx, sy].rotate of
          1:
            begin
              case currotation of 
                1: questrotating := -1;
                2: questrotating := -1;
                3: begin partlaserdraw(sx, sy, 3, 0);  changePlate(sx, sy, 1);  partlaserdraw(sx, sy, 2, 1); changePlate(sx, sy, 1); questrotating := 2; end;
                4: begin partlaserdraw(sx, sy, 4, 0);  changePlate(sx, sy, 1); partlaserdraw(sx, sy, 1, 1); changePlate(sx, sy, 1); questrotating := 1; end;
              end; end;
          2:
            begin
              case currotation of 
                1: begin partlaserdraw(sx, sy, 1, 0); changePlate(sx, sy, 1); partlaserdraw(sx, sy, 2, 1);  changePlate(sx, sy, 1); questrotating := 2; end;
                2: questrotating := -1;
                3: questrotating := -1;
                4: begin partlaserdraw(sx, sy, 4, 0); changePlate(sx, sy, 1); partlaserdraw(sx, sy, 3, 1); changePlate(sx, sy, 1); questrotating := 3; end;
              end; end;
          3:
            begin
              case currotation of 
                1: begin partlaserdraw(sx, sy, 1, 0); changePlate(sx, sy, 1); partlaserdraw(sx, sy, 4, 1); changePlate(sx, sy, 1);  questrotating := 4; end;
                2: begin partlaserdraw(sx, sy, 2, 0); changePlate(sx, sy, 1); partlaserdraw(sx, sy, 3, 1);  changePlate(sx, sy, 1); questrotating := 3; end;
                3: questrotating := -1;
                4: questrotating := -1;
              end; end;
          4:
            begin
              case currotation of 
                1: questrotating := -1;
                2: begin partlaserdraw(sx, sy, 2, 0); changePlate(sx, sy, 1); partlaserdraw(sx, sy, 1, 1); changePlate(sx, sy, 1); questrotating := 1; end;
                3: begin partlaserdraw(sx, sy, 3, 0); changePlate(sx, sy, 1);  partlaserdraw(sx, sy, 4, 1); changePlate(sx, sy, 1); questrotating := 4; end;
                4: questrotating := -1;
              end; end;
        end; end;
  
  end; end;
//==========================Анимация финиша и завершение уровня=============
procedure finishanimation(xfin, yfin, rotation: int);
begin
  partlaserdraw(xfin, yfin, rotation, 0);
  minigamefield[xfin, yfin].objectspr.Destroy;
  
  var finishanim := new SpriteABC(nilxpos + xfin * 64 - 64, nilypos + yfin * 64 - 64, 64, 'Sprites\Blocks\Mng.Finish.Aktive.png');
  var fin := new SquareABC(nilxpos + xfin * 64 - 64, nilxpos + xfin * 64 + 64 - 1, 64, clwhite);
  Sleep(100);
  finishanim.Frame := 2;
  Sleep(100);
  finishanim.NextFrame;
  Sleep(100);
  finishanim.NextFrame;
  Sleep(100);
  finishanim.NextFrame;
  Sleep(1000);
  TextBoxStart(Window.Width div 2 - 200, Window.Height div 2-150, '1&Вы успешно прошли этот шар!');
  //
  finishanim.Destroy;
  cursor.MoveTo(-8, -8);
  
  IsMiniGameIsFinished := true;
end;





//=====================Отрисовка лазера в мини игре========================
procedure alllaserdrawing();
begin
  var sx, sy, currotate: int;
  var stop: bool;
  sx := MiniGameStartX; sy := MiniGameStartY;
  currotate := minigamefield[sx, sy].rotate;
  partlaserdraw(MiniGameStartX, MiniGameStartY, currotate, 1);
  while  true do
  begin
    
    
    
    while true do
    begin
      stop := true;
      case currotate of
        
        1:
          if (sy > 1) then begin
            var rot: int := questrotating(sx, sy - 1, currotate);
            if (minigamefield[sx, sy - 1].empty  <> false) and (rot = -1) then exit; currotate := rot;
            if minigamefield[sx, sy - 1].empty  = false then begin partlaserdraw(sx, sy - 1, 1, 0); partlaserdraw(sx, sy - 1, 1, 1); end else begin
            end;
            Dec(sy); 
            if (sy > 1) then begin
              if minigamefield[sx, sy - 1].typeofobgect  = 'finish' then 
              begin
                finishanimation(sx, sy - 1, currotate);
                stop := false; end;
              
            end; 
          end
          
          else stop := false;
        
        2:
          if (sx < 16) then begin
            var rot: int := questrotating(sx + 1, sy, currotate);
            if (minigamefield[sx + 1, sy].empty  <> false) and (rot = -1) then exit; currotate := rot;
            if minigamefield[sx + 1, sy].empty  = false then begin partlaserdraw(sx + 1, sy, 2, 0); partlaserdraw(sx + 1, sy, 2, 1); end 
            else begin
            end;
            Inc(sx); 
            if (sx < 16) then begin
              if minigamefield[sx + 1, sy].typeofobgect  = 'finish' then begin stop := false; finishanimation(sx + 1, sy, currotate); end;
              
            end; 
          end
          
          else stop := false;
        
        3: 
          if (sy < 8) then begin
            var rot: int := questrotating(sx, sy + 1, currotate);
            if (minigamefield[sx, sy + 1].empty  <> false) and (rot = -1) then exit; currotate := rot;
            if minigamefield[sx, sy + 1].empty  = false then begin partlaserdraw(sx, sy + 1, 3, 0); partlaserdraw(sx, sy + 1, 3, 1); end 
            else begin
            end;
            Inc(sy); 
            if (sy < 8) then begin
              if minigamefield[sx, sy + 1].typeofobgect  = 'finish' then begin stop := false; finishanimation(sx, sy + 1, currotate); end;
              
            end; 
          end
          
          else stop := false;
        4: 
          if (sx > 1) then begin
            var rot: int := questrotating(sx - 1, sy, currotate);
            if (minigamefield[sx - 1, sy].empty  <> false) and (rot = -1) then exit; currotate := rot;
            if minigamefield[sx - 1, sy].empty  = false then begin partlaserdraw(sx - 1, sy, 4, 0); partlaserdraw(sx - 1, sy, 4, 1); end 
            else begin
            end;
            Dec(sx);
            if (sx > 1) then begin
              if minigamefield[sx - 1, sy].typeofobgect  = 'finish' then begin
                finishanimation(sx - 1, sy, currotate); 
                //
                Stop := false; end;
              
            end; 
          end
          
          else stop := false;
      end; 
      
      if stop = false then break; 
      
      
    end;
    
    
     if stop = false then break; 
  end;
  
  
  
  
  
  alldotsofliser.Item[alldotsofliser.Count - 1].destroy;
end;


var blackscr : RectangleABC;


//================================Проверка и кориктировка движений игрока===========================
procedure moveTest();
var
  i: int;
  found: bool;
begin
  if (0  >= px  + hspd) then begin if CurScreen = 6 then begin kup(VK_Left); exit; end; if CurScreen = 10 then begin var demoend := new spr(0,0,'sprites\backround\demoend.png'); Sleep(5000); kdown(VK_M); Sleep(20000); end; LockDrawingObjects; undrawfield(); if (CurScreenX = 1) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else  Dec(CurScreenX); CurScreen := LocationOfFields[CurScreenx, CurScreenY]; if CurScreen = 0 then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); drawfield(1, CurScreen);  Player.Moveto(window.Width - 70, py); UnLockDrawingObjects; end;
  if (px + Player.Width - 10 + hspd >= Window.Width) then begin
    
    LockDrawingObjects;
    undrawfield(); 
    if (CurScreenX = 16) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else Inc(CurScreenX);
    CurScreen := LocationOfFields[CurScreenx, CurScreenY];
    if CurScreen = 0 then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); drawfield(1, CurScreen);  Player.Moveto(8, py); UnLockDrawingObjects; end;
  if (0  >= py - vspd) then begin LockDrawingObjects; undrawfield(); if (CurScreenY = 1) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else  Dec(CurScreenY); CurScreen := LocationOfFields[CurScreenx, CurScreenY]; if CurScreen = 0 then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); drawfield(1, CurScreen);  Player.Moveto(px, Window.Height - Player.Height); UnLockDrawingObjects; end;
  if (py - vspd  >= Window.Height) then begin  LockDrawingObjects;   undrawfield(); if (CurScreenY = 8) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else  Inc(CurScreenY); if (CurScreen = 6) and (LocationOfFields[CurScreenx, CurScreenY] = 5) then Player.Moveto(64 + 32, player.Height) else Player.Moveto(px, player.Height); CurScreen := LocationOfFields[CurScreenx, CurScreenY]; if CurScreen = 0 then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); drawfield(1, CurScreen);  if (CurScreen = 1) and newgame then Window.Fill('Sprites\Backround\Pogoda3.png'); if (CurScreen = 5) and newgame then Window.Fill('Sprites\Backround\Pogoda2.png'); UnLockDrawingObjects;  end;
  if ((0  < px + hspd) and (px + hspd < Window.Width)) and ((0  < py - vspd) and (py - vspd < Window.Height)) then
  begin if CanMove then begin if vRight and vLeft then {Player.moveon(0,-vspd)} else Player.moveon(hspd, -vspd) end end else;// Player.MoveTo(random(64,window.Width-64),64*Random(1,5)+64-Player.Height); 
  //Обработка Нажаните шифта
  
  
  //Обработка состояний "На земле" и "В воздухе"
  
  
    //Проверка на падение 
  var plxl, plyu, plxr, plyd, plyd0, plyd1: int;
  var platform: bool;
  
  
  
  plxl := Player.Position.X + 10; plyu := Player.Position.Y + 20; plxr := Player.Position.X + Player.Width - 10; plyd := Player.Position.Y + Player.Height; plyd0 := Player.Position.Y + Player.Height + 4; plyd1 := Player.Position.Y + Player.Height - 8;
  plxl := (plxl - (plxl mod 64)) div 64; plyu := (plyu - (plyu mod 64)) div 64; plxr := (plxr - (plxr mod 64)) div 64; plyd := (plyd - (plyd mod 64)) div 64; plyd0 := (plyd0 - (plyd0 mod 64)) div 64; plyd1 := (plyd1 - (plyd1 mod 64)) div 64; 
  
  if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) then begin exit; end else begin///!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (plxl >= 0) and (plyu >= 0) and (plxr <= 20) and (plyd <= 10) then begin
      for i := 24 to 28 do 
      begin
        if (Fields[plxl, plyd, 4] = i) or (Fields[plxr, plyd, 4] = i) then platform := true;
      end;
      if 
      (Fields[plxl, plyd, 1] <> 0) or (Fields[plxr, plyd, 1] <> 0) or platform
      then 
      begin
        if not OnFloor then 
          if not platform then begin
            OnFloor := true;
            if (CurScreen = 1) and (newgame) then begin
            blackscr := new RectangleABC(0,0,Window.Width,Window.Height,clblack);
            Sleep(2000);
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Черт...');
            Sleep(2000);
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Повезло остаться в живых... Ух...');
            Sleep(2000);
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Видимо, я упал на кучу листьев, которые смягчили мне падение');
            Sleep(1000);
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Я провалялся тут слишком долго');
            Sleep(1000);
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Нужно осмотреться вокруг');
            Sleep(1000);
            Window.Fill('sprites\Backround\nightsky3.png');
            blackscr.Destroy;
            newgame := false;
            savein;
            end;
            
            Player.MoveTo(Player.Position.X, Player.Position.Y - Player.Position.Y mod 64 + 8);
          end else begin
            if vspd < 0 then begin
              OnFloor := true;
              Player.MoveTo(Player.Position.X, Player.Position.Y - Player.Position.Y mod 64 + 8);  end;
          end;
      end else  begin if OnFloor then begin OnFloor := false; end; end;
    end; end;
  platform := false;
  //Проверка на падение с края блока
    //Проверка на Столкновение со стенкой
      //Лево
  var mylt: int;
  if sprint then mylt := 2 else mylt := 1;
  plxl := Player.Position.X + 10 - hforce * mylt; plyu := Player.Position.Y + 20; plxr := Player.Position.X + Player.Width - 10 + hforce * mylt; plyd := Player.Position.Y + Player.Height - 1;
  plxl := (plxl - (plxl mod 64)) div 64; plyu := (plyu - (plyu mod 64)) div 64; plxr := (plxr - (plxr mod 64)) div 64; plyd := (plyd - (plyd mod 64)) div 64;                                                  
  if (plxl >= 0) and (plyu >= 0) and (plxr <= 20) and (plyd <= 10) then begin
    if  vLeft and ((Fields[plxl, plyd, 1] <> 0) or (Fields[plxl, plyu, 1] <> 0)) then begin
      kup(vk_left); if ((Player.Position.X - (Player.Position.X mod 64)) div 64) <> plxl then  Player.moveon(0, Player.Position.X mod 64); end;
    if vRight and ((Fields[plxr, plyd, 1] <> 0) or (Fields[plxr, plyu, 1] <> 0)) then begin kup(vk_right); end;
  end; 
  
  //Столкновение с потолком
  plxl := Player.Position.X + 10; plyu := Player.Position.Y + 8; plxr := Player.Position.X + Player.Width - 10; plyd := Player.Position.Y + Player.Height;
  plxl := (plxl - (plxl mod 64)) div 64; plyu := (plyu - (plyu mod 64)) div 64; plxr := (plxr - (plxr mod 64)) div 64; plyd := (plyd - (plyd mod 64)) div 64;  
  
  if not OnFloor and ((Fields[plxl, plyu, 1] <> 0) or (Fields[plxr, plyu, 1] <> 0)) then begin vspd := -vspd div 2; Player.MoveTo(Player.Position.X, (plyu + 1) * 64); end else;
  
  //Гравитация 
  if not OnFloor then begin if vspd >= -vspdMAX then vspd := vspd - grav end else vspd := 0;
  
  //Взаимодействие с активируемыми предметами
  
  plxl := Player.Position.X + 10; plyu := Player.Position.Y + 8; plxr := Player.Position.X + Player.Width - 10; plyd := Player.Position.Y + Player.Height - 1;
  plxl := (plxl - (plxl mod 64)) div 64; plyu := (plyu - (plyu mod 64)) div 64; plxr := (plxr - (plxr mod 64)) div 64; plyd := (plyd - (plyd mod 64)) div 64;  
  if (curspherenumb > 0) and OnFloor and ((Fields[plxl, plyu, 5] <> 0) or (Fields[plxr, plyu, 5] <> 0)) then begin
    if not dataforsave.magicsphereaktive[MagicSphere[curspherenumb].curID] then begin
    if (Fields[plxl, plyu, 5] <> 0) then begin
    
      activateitemID := Fields[plxl, plyu, 5];
      
      activeitemx := plxl; activeitemy := plyu; 
      
      end
    else 
    begin
      activateitemID := Fields[plxr, plyu, 5];
      
      activeitemx := plxr; activeitemy := plyu;
    end;
    if not vActivateItem and istextinroomisactivaited then begin 
    I:=1;
    istextinroomisactivaited := false;
    while textforboxes[MagicSphere[curspherenumb].curID,i] <> '' do begin
    
    TextBoxStart(ActiveItemX*64-180,ActiveItemY*64-150,textforboxes[MagicSphere[curspherenumb].curID,i]);
    Inc(i);
    end;
    I:=0;
     end;
    vActivateItem := true;
    
  
    
    end;
  end else begin
    if vactivateitem then begin
      vActivateItem := false;
      activateitemID := 0;
      
    end;
  end;
  
end;

//========================Проверка правильной работы анимаций и их кориктировка==========================
procedure AnimTest();
begin
  
  
  if ((vLeft) xor (vRight)) and (ATimer.Interval = 400) then ATimer.Interval := 100; 
  if not ((vLeft) xor (vRight)) and ((ATimer.Interval = 100) or (ATimer.Interval = 50)) then ATimer.Interval := 400; 
  
  
  //Прыжок 
  
  if (not OnFloor) and (Player.Frame < 3) then begin
    falling := true;
    if not ((vLeft) and (vRight)) then begin
      if lookr then begin
        Player.State := 3;
      end else Player.State := 6;
      if vspd > 3 then Player.Frame := 1 else 
      if (vspd <= 3) and (vspd >= -3) then Player.Frame := 2 else 
      if vspd < -3 then Player.Frame := 3;
    end;
  end else begin
    falling := false;
  end;
  
  //Обработка анимаций после завершения прыжка
  if OnFloor and ((Player.State = 3) or (Player.State = 6))   then begin
    if lookr then begin
      if vRight then Player.State := 1 else Player.State := 2;
    end else begin
      if vLeft then Player.State := 4 else Player.State := 5;
    end;
  end; 
  testfalling := falling; 
end;

procedure drawminigame();
var
  i, j: int;
begin
  for j := 1 to 16 do 
  begin
    for i := 1 to 8 do 
    begin
      Inc(BlockCountMini);
      if minigamefield[j, i].empty then begin
       // minigamefield[j, i].objectspr := new spr(nilxpos + j * 64 - 64, nilypos + i * 64 - 64,bloc);
        minigamefield[j, i].objectspr := minigameBlocks[minigamefield[j, i].numerofsprite - 1].Clone;
        minigamefield[j, i].objectspr.MoveTo(nilxpos + j * 64 - 64, nilypos + i * 64 - 64); 
        minigamefield[j, i].objectspr.Visible := true;
        
      end;
      
    end;
    
    
  end;
  
end;

procedure undrawminigame();
var
  i, j: int;
begin
  for j := 1 to 16 do 
  begin
    for i := 1 to 8 do 
    begin
      
      if minigamefield[j, i].empty then begin
        minigamefield[j, i].objectspr.Destroy;
        
      end;
      
    end;
    
    
  end;
  BlockCountMini := 0;
  for i := 1 to alldotsofliser.Count do 
  begin
    alldotsofliser.Item[alldotsofliser.Count - 1].Destroy;
    alldotsofliser.RemoveAt(alldotsofliser.Count - 1);
  end;
end;

//==========================Миниигра с лазерами=================================

procedure minigame();

begin
   IsMiniGameIsFinished := false;
  isMiniGameStartsDo := false;
  cursor.ToFront;
  Window.Fill('Sprites\Backround\MiniGameBack.png'); 
  var field := new pic(nilxpos - 18, nilypos - 18, 'Sprites\Backround\MiniGamePlayBack.png');
 
  loadminigamefrombuffer(FieldsMiniGame[MagicSphere[curspherenumb].curID-1]);
  drawminigame;
  
  while not IsMiniGameIsFinished do 
  begin
    if vSpase and not isMiniGameStartsDo then 
      isMiniGameStartsDo := true;
    
    if isMiniGameStartsDo then begin
      alllaserdrawing;
      
      if not IsMiniGameIsFinished then 
        while true do 
        begin
          vSpase := false;
          Sleep(100);
          if not IsMiniGameIsFinished and vSpase then begin
            
            LockDrawingObjects;
            undrawminigame;
            drawminigame;
            cursor.MoveTo(-8, -8);
            UnLockDrawingObjects;
            isMiniGameStartsDo := false;
            break;
          end; end;
    end;
    
  end;
  
  
  
  LockDrawingObjects;
  undrawminigame;
  field.Destroy;
  cursor.MoveTo(-8, -8);
  vActivateItem := false;
  
  
  
  savein;
  
  
  CurModeOfScreen := 'Game';
  
end;




//===========================Мясо===============================================
procedure game();
begin
  
  //=================Описание второстепенных элементов============================
  
  Player := new spr(dataforsave.PlayerPos.x, dataforsave.PlayerPos.y, 54, 'Sprites\Player\Player_Sheets.png');
  //Player := new spr(100, 6*64+8, 54, 'Sprites\Player\Player_Sheets.png');
  Player.AddState('RunR', 5); Player.AddState('IdleR', 5); Player.AddState('JumpR', 4);
  Player.AddState('RunL', 5); Player.AddState('IdleL', 5); Player.AddState('JumpL', 4);
  Player.Active := false; 
  Player.State := 2;
  lookr := true;
  CurModeOfScreen := 'Game';
  ATimer.Start;
  CanMove := true;
  
  StartScreenX := dataforsave.CurScreen.x; StartScreenY := dataforsave.CurScreen.y;
 // StartScreenX := 5; StartScreenY := 3;
  
  CurScreenx := StartScreenX; CurScreeny := StartScreeny;
  var startScreen := LocationOfFields[StartScreenX, StartScreenY];
  CurScreen := StartScreen;
  //=========================Начало программы=====================================
  kup(VK_Left); kup(vk_right);
  LockDrawingObjects;
  Window.Fill('sprites\Backround\nightsky3.png');
  loadscreenfrombuffer(FieldsName[StartScreen - 1]);
  drawfield(1, StartScreen);
  
  if not FileExists('save.ini') then begin
  OnKeyDown :=FrameTimer;
  OnKeyUp :=FrameTimer;
  Window.Fill('sprites\Backround\pogoda1.png');
  alternativepayer := new spr(500,6*64+8, 54, 'Sprites\Player\Player_Sheets_Alternative.png');
  alternativepayer.AddState('RunR', 5); alternativepayer.AddState('IdleR', 5); alternativepayer.AddState('JumpR', 4);
  alternativepayer.AddState('RunL', 5); alternativepayer.AddState('IdleL', 5); alternativepayer.AddState('JumpL', 4);
  alternativepayer.Active := false; 
  alternativepayer.State := 2;
  ATimer.Interval := 200;
  UnLockDrawingObjects;
  Sleep(1000);
  OnKeyDown :=kdown;
OnKeyUp :=kup;
  TextBoxStart(Window.Width div 2-200, Window.Height-200,'2&Следуй за мной');
  OnKeyDown :=FrameTimer;
OnKeyUp :=FrameTimer;
Sleep(1000);
  alternativepayer.State := 1;
  var i : int;
  alternativepayer.ToBack;
  for i := 1 to 55 do begin alternativepayer.MoveOn(4,0); Sleep (20);end;
  alternativepayer.State := 3;
  alternativepayer.Active := false;
  for i:= -10 to  10 do begin if i < -5 then alternativepayer.Frame := 1; if i > 5 then alternativepayer.Frame := 3; if (i <= 5) and (i >=-5 ) then alternativepayer.Frame := 2; alternativepayer.MoveOn(7,i); Sleep (30);end;
  alternativepayer.Active := true;
  alternativepayer.State := 1;
  for i := 1 to 55 do begin alternativepayer.MoveOn(4,0); Sleep (50);end;
  
  alternativepayer.Destroy;
  Sleep(1000);
OnKeyUp :=kup;
  OnKeyDown :=kdown;
  TextBoxStart(Window.Width div 2-200, Window.Height-200,'1&...');
  
  newgame:= true;
  CanMove := true;
  end;
  UnLockDrawingObjects;
  if IsMiniGameIsFinished then begin
 if curspherenumb > 0 then  begin
 var ox,oy : int;
 
 ox := MagicSphere[curspherenumb].Spritesphere.Position.X; oy := MagicSphere[curspherenumb].Spritesphere.Position.y;
 MagicSphere[curspherenumb].Spritesphere.Destroy; 
 MagicSphere[curspherenumb].Spritesphere := new spr(ox,oy,64,'Sprites\Blocks\Prt.Mng.Sphere.ActiveA.png');
  Sleep(100);
  MagicSphere[curspherenumb].Spritesphere.NextFrame;
  Sleep(100);
  MagicSphere[curspherenumb].Spritesphere.NextFrame;
  Sleep(100);
  MagicSphere[curspherenumb].Spritesphere.NextFrame;
  Sleep(100);
  MagicSphere[curspherenumb].Spritesphere.NextFrame;
  Sleep(100);
  MagicSphere[curspherenumb].Spritesphere.NextFrame;
  Sleep(1000);
  
  Fields[MagicSphere[curspherenumb].LocationOfScreen.x,MagicSphere[curspherenumb].LocationOfScreen.y,5] := 55;
  
  dataforsave.magicsphereaktive[MagicSphere[curspherenumb].curid] := true;
  savein;
  end;
  end;
  
  
  
  
  
  
  while 0 = 0 do
  begin
    if CurModeOfScreen = 'MiniGame' then exit;
    px := Player.Position.X; py := Player.Position.Y;
    
    AnimTest();
    
    moveTest();  
    
    if yep then begin TextBoxStart(0, 0, 'опа'); yep := false; end;
    
    Sleep(50); 
  end;
end;

//==============================Сохранение и загрузка===========================
procedure savein();
var
  fileforsave: file of savefile;
begin
  
  dataforsave.CurScreen.x := CurScreenX;
  dataforsave.CurScreen.y := CurScreenY;
  dataforsave.PlayerPos.x := Player.Position.X;
  dataforsave.PlayerPos.y := Player.Position.Y;
  
  
  Assign(fileforsave, 'Save.ini');
  Rewrite(fileforsave);
  Reset(fileforsave);
  
  write(fileforsave, dataforsave);
  Close(fileforsave);
end;

procedure loadfrom();
var i : int;
begin
  var fileforsave: file of savefile;
  begin
    if FileExists('Save.ini') then begin
      Assign(fileforsave, 'Save.ini');
      
      Reset(fileforsave);
      
      read(fileforsave, dataforsave);
      Close(fileforsave); end else begin
      dataforsave.CurScreen.x := 2;
      dataforsave.CurScreen.y := 2;
      dataforsave.PlayerPos.x := 100;
      dataforsave.PlayerPos.y := 64 * 6 + 8;
      for i:=1 to 100 do dataforsave.magicsphereaktive[i] := false;
      
      
    end;
  end;
end;

//=====================Менюшка================================
procedure menu();

begin
  CurModeOfScreen := 'Menu';
  LockDrawingObjects;
  Window.Fill('Sprites\Backround\MenuBack.png');
  if FileExists('Save.ini') then playbutt := new spr(20, 325, 'Sprites\UI\ContinueButt.png') else playbutt := new spr(20, 325, 'Sprites\UI\NewGameButt.png'); 
  
  infobutt := new spr(20, 450, 'Sprites\UI\InfoButt.png');
  exitbutt := new spr(20, 575,'Sprites\UI\ExitButt.png');
  if FileExists('Save.ini') then playbutt2 := new spr(20, 325, 'Sprites\UI\ContinueButt2.png') else playbutt2 := new spr(20, 325, 'Sprites\UI\NewGameButt2.png'); 
  
  infobutt2 := new spr(20, 450, 'Sprites\UI\InfoButt2.png');
  exitbutt2 := new spr(20, 575,'Sprites\UI\ExitButt2.png');
  mmove(1,1,1);
  UnLockDrawingObjects;
  //Sleep(5000);
  //game();
  while true do 
  begin
    while not vclick do
    begin
      Sleep(10);
    end;
    playbutt.Destroy;
    infobutt.Destroy;
    exitbutt.Destroy;
    playbutt2.Destroy;
    infobutt2.Destroy;
    exitbutt2.Destroy;
    case CurModeOfScreen of
      'Game': game;
      'MiniGame': minigame;
    end; end;
end;

//==============================================================================
//===========================Начало программы===================================
//==============================================================================

//=============Описание переменных используеммых в самой программе==============
var
  i, j: int;

begin
  //===================Описание основ=============================================
  OnMouseMove := mmove; 
  OnMouseDown := mdown;
  OnMouseUp := mup;
  OnKeyPress := kpress;
  OnKeyDown := kdown;
  OnKeyUp := kup;
  Window.SetSize(1344, 704);
  Window.CenterOnScreen;
  Window.IsFixedSize := true;
  Window.Title := 'You and Lasers';
  loadfrom;
  loadobjfromfile('Sprites.list'); //Подгрузка обьктов и экранов в память и последующая их отрисовка
  loadfieldfromfile();
  menu();
  Readln;
end.