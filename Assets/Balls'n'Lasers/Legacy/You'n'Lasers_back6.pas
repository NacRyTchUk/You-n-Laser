{
Список того, чем стоит занятся:
-Сделать мап эдитор
-СОхранение состояний активируемынх предметов
-Доделать миниигру
-Ачивки?
-НПС
-Первая/катсцены в общем
-живность
-Экраны анимации/зарузки
-Сюжетец/цель
-Перерисовать спайты маяков углов блоков, добавить перевернутые версии некоторых блоков
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
  nilxpos = 60; 
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
  OnFloor, onRoof, CanMove, lookl, lookr, falling, testfalling, lstop, rstop, ustop, sprint, isMiniGameStartsDo, IsMiniGameIsFinished: bool; // Флаги состояний
  Selector := new spr(-64, -64, 'Sprites\UI\Selector.png'); ///!!!!!!!!!!!!!!!!!!!!!!!
  MiniGameStartRotate, MiniGameStartX, MiniGameStartY, StartScreenX, StartScreenY, CurScreenX, CurScreenY, ActiveItemX, ActiveItemY, activateitemID: int;
  CurScreen: int := 1;
  playbutt, infobutt: spr;

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
     x : int;
     y : int;
   end;
  
 type
    savefile = record 
    CurScreen : position;
    PlayerPos : position;
    
 
 end;

var
  minigamefield: array[1..16, 1..8] of minigameempt;
  dataforsave : savefile;

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
begin
  
  var textboxback := new spr(x, y, 'Sprites/UI/TextBoxGreen.png');
  var textboxtest := new textbox(x + 20, y + 20, 14, '', cllightgreen);
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
    
    // textboxtest.MoveTo(Player.Position.X - 200 + 20, Player.Position.Y - 200 + 20);
    // textboxback.MoveTo(Player.Position.X - 200, Player.Position.Y - 200);
    textboxtest.Text := textboxtest.Text + textik[i];
    if (textik[i] = ' ') and (textboxtest.Text.Length div 40 > linescount) then begin textboxtest.Text := textboxtest.Text + #10#13; Inc(linescount); end;
    Sleep(10);
  end;
  
  while not vSpase do 
  begin
    Sleep(100); //TextOut(200, 200, booltostr(vSpase)); Write('n'); 
  end;
  //Sleep(5000); 
  textboxtest.Destroy;
  textboxback.Destroy;
  
  
  
  CanMove := true;
end;


//===================Быстрый вывод сообщения===============================
procedure msg(text: str);
begin
  
  //MessageBox.Show(text, 'Debug', MessageBoxButtons.OK, MessageBoxIcon.Asterisk, MessageBoxDefaultButton.Button1, MessageBoxOptions.ServiceNotification);
end;


var
  cir := new CircleABC(10, 10, 5, clwhite);
//===================Ввод информации с клавы и мышки===========================
procedure mmove(mx, my, mb: int);
var
  i, j, xc, yc, bcx, bcy: integer;
begin
  mousex := mx; mousey := my;
  case CurModeOfScreen of
    'Game':
      begin
        Selector.ToFront;
        if ((mx > 0) and (my > 0)) and ((mx < window.Width) and (my < Window.Height)) then
        begin
          //if ((((mx-((mx) mod 64))) and (my-(((my) mod 64))+64)) <> (((mxold-((mxold) mod 64))) and (myold-(((myold) mod 64))+64))) then begin
          //SetPenColor(clWhite);
          //Line(20,20,mxold,myold);
          //Rectangle((mxold-((mxold-20) mod 30)),myold-(((myold-20) mod 30))+30,mxold-(((mxold-20) mod 30))+30,myold-(((myold-20) mod 30)+0));
          //SetPenColor(clBlack);
          //Line(mxold,myold,mx,my);
          //Rectangle((mx-(mx mod 64)) and (my-((my mod 64))+64,(mx-(mx mod 64))) and (my-((my mod 64))+64+3064,(mx-(mx mod 64))) and (my-((my mod 64))+64+0));
          bcx := mx + 10; bcy := my + 10;
          bcx := (bcx - (bcx mod 64)) div 64;  bcy := (bcy - ((bcy) mod 64)) div 64;
          xc := (mx - (mx mod 64)) div 64; 
          yc := (my - ((my) mod 64)) div 64;
          TextOut(100, 120, '_____________');
          TextOut(100, 120, xc + ' ' + yc);
          // if  (bcy <= 10) and (bcx <= 20) then if (Fields[bcx,bcy,1,1] <> 0)  then TextOut(xc*64,yc*64,' ');;
          
          Selector.MoveTo(xc * 64, yc * 64);
          
          //mxold:=mx;myold:=my;
          //end; 
        end;
      end;
    'Menu':
      begin
        try
          begin
            
            //cir.MoveOn(-Round(2*(cir.Position.X - mx)/Sqrt(Sqr((cir.Position.X - mx)) + Sqr((cir.Position.Y - my)))),-Round(2*(cir.Position.Y - my)/Sqrt(Sqr((cir.Position.X - mx)) + Sqr((cir.Position.Y - my)))));
          end
        except;
      end;
  end; end;


end;
var
  vclick: bool;

procedure mdown(mx, my, mb: int);
begin
  case CurModeOfScreen of 
    'Game':
      begin
        //Rectangle((mx-((mx) mod 64)) , (my-((my) mod 64)),(mx-((mx) mod 64))+64 , (my-((my) mod 64))+64);
        var blocknew := Blocks[1].Clone;
        blocknew.Visible := true;
        blocknew.MoveTo((mx - ((mx) mod 64)), (my - ((my) mod 64)));
        Inc(BlockCount);
        BlocksOfField[BlockCount, 1] := blocknew;
        if mb = 1 then Fields[(mx - ((mx) mod 64)) div 64, (my - ((my) mod 64))      div 64, 1] := 1 else Fields[(mx - ((mx) mod 64)) div 64, (my - ((my) mod 64))      div 64, 2] := 1;
      end;
    'Menu': 
      begin
        // vclick := true;
        //  if (mx < 100) and (my < 100) then begin CurModeOfScreen := 'Game' end else if (mx > Window.Width - 100) and (my > Window.Height - 100) then begin CurModeOfScreen := 'MiniGame'; end else vclick := false;
        
        if ObjectUnderPoint(mx, my) = playbutt then begin vclick := true; curmodeofscreen := 'Game'; end;
        if ObjectUnderPoint(mx, my) = infobutt then begin vclick := true; curmodeofscreen := 'MiniGame'; end;
        //1if not (ObjectUnderPoint(mx,my) = playbutt) and not (ObjectUnderPoint(mx,my) = infobutt) then vclick := false;
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
  //if ((vLeft) and (vRight)) then begin CanMove:=false; Player.State := 2; end else CanMove:= true;;
  
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
        { if ((vLeft) and (vRight)) then 
              begin 
               if OnFloor then begin if lookr then begin
            Player.State := 2 ;
          end else begin
           Player.State := 5;
          end; end;
              exit;
              end; }
        case key of
          VK_Left:
            begin
              if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) or not CanMove then exit;
              //  Writeln('nibba' + booltostr(Canmove));
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
                undrawfield();// Dec(CurScreenX);CurScreen := LocationOfFields[CurScreenx,CurScreenY]; loadscreenfrombuffer(FieldsName[CurScreen-1], CurScreen); drawfield(1, CurScreen);
                Player.Destroy;
                CurModeOfScreen := 'MiniGame';
                //minigame;
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
        else Write(booltostr(CanMove));;  
        end;
        //if ((vLeft) and (vRight)) then begin CanMove:=false; Player.State := 2; end else CanMove:= true;;
        
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





//===================Подгрузка обьектов=======================
procedure loadobjfromfile(Path: str);
var
  fileofblocks, fileofminigameblocks: text;
  BlocksName, minigameBlocksName: array of str;
  i: int := 0;
  Line: Str;
begin
  //var bl := new obj(700,200,100,50,clblack);
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
  FieldFile, FieldLocationFile: Text;
  Line: Str;
  i, j, Layer: int;

begin
  //Dec(ScreenNumb);
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
  
end;


//Разворот обьектов
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




//=================Отрисовка поля=========================
procedure drawfield(layer, CurScreen: int);
var
  i, j: int;
begin
  LockDrawingObjects;
  Window.Fill('Sprites\Backround\NIghtSky3.png');
  //var back := new pic(0,0,'Sprites\Backround\NIghtSky3.png'); ////!!!!!!!!!!
  //back.Scale(3);
  //back.ToBack; ///!!!!!!!!!!!!!!!!!!!!!!!
  for layer := 1 to 5 do 
    for i := 0 to 10 do 
      for j := 0 to 20 do
      begin
        if Fields[j, i, layer] <> 0 then
        begin
          Inc(BlockCount);
          Inc(CounterOfBlocksL[layer]);
          BlocksOfField[CounterOfBlocksL[layer], layer] := Blocks[Fields[j, i, layer]].Clone; //Копируем спрайт из буфера
          BlocksOfField[CounterOfBlocksL[layer], layer].MoveTo(j * 64, I * 64); // Помещаем его на нужные координаты и делаем видимым
          BlocksOfField[CounterOfBlocksL[layer], layer].Visible := true;
          if layer = 3 then BlocksOfField[CounterOfBlocksL[layer], layer].ToBack
          
        end;
      end;
  { for layer := 1 to 2 do
  for i:= 1 to CounterOfBlocksL[layer] do
  begin
  BlocksOfField[i,layer].Destroy;
  }
  // var blk := BlocksOfField[1,1].Clone; blk.moveto(255,255);
  //  TextOut(200,400,CounterOfBlocksL[2]);
  // Readln;
  // end;
  
  
  
  UnLockDrawingObjects; 
end;


//=================Выгрузка поля=========================
procedure undrawfield();
var
  i, j: int;
begin
  ////!!!!!!!!!!
  
  for j := 1 to 5 do 
  begin
    for i := 1 to CounterOfBlocksL[j]   do 
    
    begin
      
      BlocksOfField[i, j].Destroy;  //Копируем спрайт из буфера
      
      
    end;
    CounterOfBlocksL[j] := 0;
    
    
  end;
  BlockCount := 0;
  unloadscreenfrombuffer(CurScreen);
  { for layer := 1 to 2 do
  for i:= 1 to CounterOfBlocksL[layer] do
  begin
  BlocksOfField[i,layer].Destroy;
  }
  // var blk := BlocksOfField[1,1].Clone; blk.moveto(255,255);
  //  TextOut(200,400,CounterOfBlocksL[2]);
  // Readln;
  // end;
  
  
  
end;
//===================Таймер отвечающий за анимацию персоонажа===================
procedure AniTimer();
begin
  if Player.Frame < 5 then Player.Frame := Player.Frame + 1;
  if Player.Frame  = 5 then Player.Frame := 1;
end;


//Счетчик кадров
procedure FrameTimer();
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
  
  step := 2; sleeptime := 1;  squaresize := 6; otstx := nilxpos-64 - squaresize div 2; otsty := nilypos-64 - squaresize div 2; 
  
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
        //alldotsofliser.Add(new SquareABC(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum, squaresize, colorofsqre));
        alldotsofliser.Add(LaserPart.Clone);
        alldotsofliser.Item[alldotsofliser.Count - 1].moveto(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum);
        Sleep(sleeptime);
      end;
    end; end  else begin
    if (rotate = 2) or (rotate = 3) then begin
      for i := 16 div (step * 2) to 16 div (step) do
      begin
        cursor.MoveTo(otstx + xf * 64 + 4 * step * i * xnul + xnulsum - squaresize div 2, otsty + yf * 64 + 4 * step * i * ynul + ynulsum - squaresize div 2);
        //alldotsofliser.Add(new SquareABC(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum, squaresize, colorofsqre));
        alldotsofliser.Add(LaserPart.Clone);
        alldotsofliser.Item[alldotsofliser.Count - 1].moveto(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum);
        Sleep(sleeptime);
      end; end else begin
      for i := 16 div (step * 2) downto 1 div (step * 2) do
      begin
        cursor.MoveTo(otstx + xf * 64 + 4 * step * i * xnul + xnulsum - squaresize div 2, otsty + yf * 64 + 4 * step * i * ynul + ynulsum - squaresize div 2);
        //alldotsofliser.Add(new SquareABC(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum, squaresize, colorofsqre));
        alldotsofliser.Add(LaserPart.Clone);
        alldotsofliser.Item[alldotsofliser.Count - 1].moveto(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum);
        Sleep(sleeptime);
      end; 
    end; end;
  SetBrushColor(clwhite); SetPenColor(clwhite);
  cursor.ToFront;
  {if fullofnot = 1 then begin 
  if (rotate = 3) or (rotate = 2) then begin  
  if rotate = 3 then begin ynul := 1; xnulsum := 32; end else begin xnul := 1; ynulsum := 32; end;
  for i := 1 to 16 div step do begin
  cursor.MoveTo(otstx +xf*64+4*step*i*xnul + xnulsum-2,otsty+yf*64+4*step*i*ynul + ynulsum-2);
  alldotsofliser.Add(new SquareABC(otstx +xf*64+4*step*i*xnul + xnulsum,otsty+yf*64+4*step*i*ynul + ynulsum,4,clwhite));
  Sleep(sleeptime);
  end end else begin 
  if rotate = 1 then begin ynul := 1; xnulsum := 32; end else begin xnul := 1; ynulsum := 32; end;
  for i := 16 div step downto 1  do begin
  cursor.MoveTo(otstx+xf*64+4*step*i*xnul+xnulsum-2,otsty+yf*64+4*step*i*ynul+ynulsum-2);
  alldotsofliser.Add(new SquareABC(otstx+xf*64+4*step*i*xnul+xnulsum,otsty+yf*64+4*step*i*ynul+ynulsum,4,clwhite));
  Sleep(sleeptime);
  end;
  end; end Else begin
  if (rotate = 3) or (rotate = 2) then begin
  if otordo = 1 then begin
  
  if rotate = 1 then begin ynul := 1; xnulsum := 32; end else begin xnul := 1; ynulsum := 32; end;
  for i := 16 div (step*2) to 16 div step  do begin
  cursor.MoveTo(otstx+xf*64+4*step*i*xnul+xnulsum-2,otsty+yf*64+4*step*i*ynul+ynulsum-2);
  alldotsofliser.Add(new SquareABC(otstx+xf*64+4*step*i*xnul+xnulsum,otsty+yf*64+4*step*i*ynul+ynulsum,4,clwhite));
  Sleep(sleeptime);
  end; end else begin
  if rotate = 1 then begin ynul := 1; xnulsum := 32; end else begin xnul := 1; ynulsum := 32; end;
  for i := 16 div step downto 16 div (step*2) do begin
  cursor.MoveTo(otstx+xf*64+4*step*i*xnul+xnulsum-2,otsty+yf*64+4*step*i*ynul+ynulsum-2);
  alldotsofliser.Add(new SquareABC(otstx+xf*64+4*step*i*xnul+xnulsum,otsty+yf*64+4*step*i*ynul+ynulsum,4,clwhite));
  Sleep(sleeptime);
  end;end;
  end else begin
  
  
  
  end;
  end;
  }
  
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
  //LockDrawingObjects;
  partlaserdraw(xfin, yfin, rotation, 0);
  minigamefield[xfin, yfin].objectspr.Destroy;
  
  //UnLockDrawingObjects;
  var finishanim := new SpriteABC(nilxpos + xfin * 64 - 64, nilypos + yfin * 64 - 64, 64, 'Sprites\Blocks\Mng.Finish.Aktive.png');
  var fin := new SquareABC(nilxpos + xfin * 64 - 64, nilxpos + xfin * 64 + 64 - 1, 64, clwhite);
  //var finishanim := new SpriteABC(1,1,64,'Sprites\Blocks\Mng.Finish.Aktive.png');
  Sleep(100);
  finishanim.Frame := 2;
  Sleep(100);
  finishanim.NextFrame;
  Sleep(100);
  finishanim.NextFrame;
  Sleep(100);
  finishanim.NextFrame;
  Sleep(1000);
  TextBoxStart(Window.Width div 2, Window.Height div 2, 'конгратс');
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
      // Writeln(IntToStr(sx) + ' ' +  IntToStr(sy));
      // TextOut(900,100,booltostr(stop));
      case currotate of
        
        1:
          if (sy > 1) then begin
            //if (minigamefield[sx,sy-1].typeofobgect  = 'finish') then TextOut(100,100,'ohyeah');
            var rot: int := questrotating(sx, sy - 1, currotate);
            if (minigamefield[sx, sy - 1].empty  <> false) and (rot = -1) then exit; currotate := rot;
            // Writeln(questrotating(sx, sy - 1, currotate));
            if minigamefield[sx, sy - 1].empty  = false then begin partlaserdraw(sx, sy - 1, 1, 0); partlaserdraw(sx, sy - 1, 1, 1); end else begin
            end;
            Dec(sy); 
            if (sy > 1) then begin
              if minigamefield[sx, sy - 1].typeofobgect  = 'finish' then 
              begin
                //
                finishanimation(sx, sy - 1, currotate);
                stop := false; end;
              
            end; 
          end
          
          else stop := false;
        
        2: {if (sx < 16) and (minigamefield[sx+1,sy].typeofobgect  <> 'finish') then begin 
           partlaserdraw(sx+1,sy,2,1,0); 
           Inc(sx); 
           end else begin
           if (sx < 16) then if minigamefield[sx+1,sy].typeofobgect  = 'finish' then TextOut(Window.Width div 2 , Window.Height div 2,'Hoho');
           exit;
          end;
          }
          if (sx < 16) then begin
            //if (minigamefield[sx,sy-1].typeofobgect  = 'finish') then TextOut(100,100,'ohyeah');
            var rot: int := questrotating(sx + 1, sy, currotate);
            if (minigamefield[sx + 1, sy].empty  <> false) and (rot = -1) then exit; currotate := rot;
            //                                             begin if rot = -1 then exit else currotate := rot;  end else begin currotate := rot;  end;
            //   Writeln(questrotating(sx + 1, sy, currotate));
            if minigamefield[sx + 1, sy].empty  = false then begin partlaserdraw(sx + 1, sy, 2, 0); partlaserdraw(sx + 1, sy, 2, 1); end 
            else begin
            end;
            Inc(sx); 
            if (sx < 16) then begin
              if minigamefield[sx + 1, sy].typeofobgect  = 'finish' then begin stop := false; finishanimation(sx + 1, sy, currotate); end;
              
            end; 
          end
          
          else stop := false;
        
        3: {if (sy < 8) and (minigamefield[sx,sy+1].typeofobgect  <> 'finish') then begin 
          partlaserdraw(sx,sy+1,3,0); partlaserdraw(sx,sy+1,3,1); 
          Inc(sy); 
          if (sy < 8) then if minigamefield[sx,sy+1].typeofobgect  = 'finish' then TextOut(Window.Width div 2 , Window.Height div 2,'Hoho');
          end else exit;
          }
          if (sy < 8) then begin
            //if (minigamefield[sx,sy-1].typeofobgect  = 'finish') then TextOut(100,100,'ohyeah');
            var rot: int := questrotating(sx, sy + 1, currotate);
            if (minigamefield[sx, sy + 1].empty  <> false) and (rot = -1) then exit; currotate := rot;
            // Writeln(questrotating(sx, sy + 1, currotate));
            if minigamefield[sx, sy + 1].empty  = false then begin partlaserdraw(sx, sy + 1, 3, 0); partlaserdraw(sx, sy + 1, 3, 1); end 
            else begin
            end;
            Inc(sy); 
            if (sy < 8) then begin
              if minigamefield[sx, sy + 1].typeofobgect  = 'finish' then begin stop := false; finishanimation(sx, sy + 1, currotate); end;
              
            end; 
          end
          
          else stop := false;
        4: {if (sx > 1) and (minigamefield[sx-1,sy].typeofobgect  <> 'finish') then begin 
          partlaserdraw(sx-1,sy,4,1,0); 
          Dec(sx); 
          end else begin
          if (sx > 1) then if minigamefield[sx-1,sy].typeofobgect  = 'finish' then TextOut(Window.Width div 2 , Window.Height div 2,'Hoho');
          exit;}
          if (sx > 1) then begin
            //if (minigamefield[sx,sy-1].typeofobgect  = 'finish') then TextOut(100,100,'ohyeah');
            var rot: int := questrotating(sx - 1, sy, currotate);
            if (minigamefield[sx - 1, sy].empty  <> false) and (rot = -1) then exit; currotate := rot;
            //Writeln(questrotating(sx,sy-1,currotate));
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
      
      //   TextOut(900,120,booltostr(stop));
      if stop = false then break; 
      
      
    end;
    
    
     // TextOut(900,140,booltostr(stop));
    if stop = false then break; 
  end;
  
  
  // if stop = false then break;
  
  
  
  alldotsofliser.Item[alldotsofliser.Count - 1].destroy;
//  cursor.MoveTo(alldotsofliser.Item[alldotsofliser.Count - 1].position.x, alldotsofliser.Item[alldotsofliser.Count - 1].position.y);
end;
//end;





//================================Проверка и кориктировка движений игрока===========================
procedure moveTest();
var
  i: int;
  found: bool;
begin
  // if (CurScreenX = 16) or (CurScreenX = 1) or (CurScreenY = 8) or CurScreenY = 1 
  
    //Вытаскивание игрока из под блока, если он туда провалился
  if (0  >= px  + hspd) then begin Textout(400, 20, 'left   ');  undrawfield(); if (CurScreenX = 1) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else  Dec(CurScreenX); CurScreen := LocationOfFields[CurScreenx, CurScreenY]; if CurScreen = 0 then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); drawfield(1, CurScreen);  Player.Moveto(window.Width - 70, py); end;
  if (px + Player.Width - 10 + hspd >= Window.Width) then begin
    TextOut(400, 20, 'right  '); 
    undrawfield(); 
    if (CurScreenX = 16) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else Inc(CurScreenX);
    CurScreen := LocationOfFields[CurScreenx, CurScreenY];
    if CurScreen = 0 then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); drawfield(1, CurScreen);  Player.Moveto(8, py); end;
  if (0  >= py - vspd) then begin TextOut(400, 20, 'up    '); undrawfield(); if (CurScreenY = 1) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else  Dec(CurScreenY); CurScreen := LocationOfFields[CurScreenx, CurScreenY]; if CurScreen = 0 then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); drawfield(1, CurScreen);  Player.Moveto(px, Window.Height - Player.Height); end;
  if (py - vspd  >= Window.Height) then begin TextOut(400, 20, 'down '); undrawfield(); if (CurScreenY = 8) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else  Inc(CurScreenY); if (CurScreen = 6) and (LocationOfFields[CurScreenx, CurScreenY] = 5) then Player.Moveto(64+32, player.Height) else Player.Moveto(px, player.Height); CurScreen := LocationOfFields[CurScreenx, CurScreenY]; if CurScreen = 0 then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); drawfield(1, CurScreen);    end;
  if ((0  < px + hspd) and (px + hspd < Window.Width)) and ((0  < py - vspd) and (py - vspd < Window.Height)) then
  begin if CanMove then begin if vRight and vLeft then {Player.moveon(0,-vspd)} else Player.moveon(hspd, -vspd) end end else;// Player.MoveTo(random(64,window.Width-64),64*Random(1,5)+64-Player.Height); 
  //Обработка Нажаните шифта
  //if (vShift and ((vLeft) xor (vRight)) and not sprint) then begin sprint := true; hspd:= hspd*2; ATimer.Interval := 50;  end else if (not vShift and ((vLeft) or (vRight))) and (ATimer.Interval = 50) then  begin   end;
  
  
  
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
      //((ObjectUnderPoint(plxl,plyu ) = blocksoffield[i,1]) or 
      //(ObjectUnderPoint(plxr,plyd) = blocksoffield[i,1]))  
      (Fields[plxl, plyd, 1] <> 0) or (Fields[plxr, plyd, 1] <> 0) or platform
      then 
      begin
        if not OnFloor then 
          if not platform then begin
            TextOut(900, 10, 'normal');
            OnFloor := true;
            Player.MoveTo(Player.Position.X, Player.Position.Y - Player.Position.Y mod 64 + 8);
          end else begin
            if vspd < 0 then begin
              OnFloor := true;
              Player.MoveTo(Player.Position.X, Player.Position.Y - Player.Position.Y mod 64 + 8);  end;
          end;
        {else begin
        TextOut(900,10,'То что нужно ' + booltostr((Fields[plxl, plyd0, 4, CurScreen] <> 0) or (Fields[plxr, plyd0, 4, CurScreen] <> 0)));
        if ((Fields[plxl, plyd, 4, CurScreen] <> 0) or (Fields[plxr, plyd, 4, CurScreen] <> 0)) then begin
        if (Fields[plxl, plyd, 4, CurScreen] <> 0) then begin
        if (Fields[plxl, plyd0, 4, CurScreen] <> 0) and (Fields[plxl, plyd1, 4, CurScreen] = 0) then begin 
        OnFloor := true;
        Player.MoveTo(Player.Position.X, Player.Position.Y - Player.Position.Y mod 64 + 8); end;
        end;
        if (Fields[plxr, plyd, 4, CurScreen] <> 0) and (Fields[plxr, plyd, 4, CurScreen] = 0) then begin
        if (Fields[plxr, plyd0, 4, CurScreen] <> 0) and  (Fields[plxr, plyd1, 4, CurScreen] = 0) then begin
        OnFloor := true;
        Player.MoveTo(Player.Position.X, Player.Position.Y - Player.Position.Y mod 64 + 8); end;
        end;
        end;
        
        //((Fields[plxl, plyd0, 4, CurScreen] <> 0) or (Fields[plxr, plyd0, 4, CurScreen] <> 0)) and
        //((Fields[plxl, plyd1, 4, CurScreen] = 0) or (Fields[plxr, plyd1, 4, CurScreen] = 0)) 
        {then begin
        TextOut(900,10,'Иделаьно ' + booltostr((Fields[plxl, plyd, 4, CurScreen] <> 0) or (Fields[plxr, plyd, 4, CurScreen] <> 0)) + ' ' + booltostr(((Fields[plxl, plyd0, 4, CurScreen] <> 0) or (Fields[plxr, plyd0, 4, CurScreen] <> 0))) + ' ' + booltostr((Fields[plxl, plyd1, 4, CurScreen] = 0) or (Fields[plxr, plyd1, 4, CurScreen] = 0)));
        Circle(Player.Position.X + 10,Player.Position.Y + Player.Height,4); Circle(Player.Position.X + Player.Width - 10,Player.Position.Y + Player.Height,4);
        Circle(Player.Position.X + 10,Player.Position.Y + Player.Height-4,4); Circle(Player.Position.X + Player.Width - 10,Player.Position.Y + Player.Height-4,4);
        Circle(Player.Position.X + 10,Player.Position.Y + Player.Height+4,4); Circle(Player.Position.X + Player.Width - 10,Player.Position.Y + Player.Height+4,4);
        
        OnFloor := true;
        Player.MoveTo(Player.Position.X, Player.Position.Y - Player.Position.Y mod 64 + 8);
        end;}
        //end;}
      end else  begin if OnFloor then begin OnFloor := false; end; end;
    end; end;
  platform := false;
  //Проверка на падение с края блока
  {plxl := Player.Position.X; plxl := (plxl-(plxl mod 64)) div 64;
  if OnFloor and (Fields[plxl, plyd , 1,1] = 0) then begin   for i:= 0 to Player.Width-20 do begin  player.MoveOn(-1,1); Player.State := 6; Player.Frame := 3; OnFloor:= false; end;  end; 
  plxr := Player.Position.X+Player.Width-20;plxr := (plxr-(plxr mod 64)) div 64;
  if OnFloor and (Fields[plxr, plyd , 1,1] = 0) then begin   for i:= 0 to Player.Width-20 do begin  player.MoveOn(1,1); Player.State := 3; Player.Frame := 3; OnFloor:= false;  end;  end; 
  }
    //Проверка на Столкновение со стенкой
      //Лево
  var mylt: int;
  if sprint then mylt := 2 else mylt := 1;
  plxl := Player.Position.X + 10 - hforce * mylt; plyu := Player.Position.Y + 20; plxr := Player.Position.X + Player.Width - 10 + hforce * mylt; plyd := Player.Position.Y + Player.Height - 1;
  plxl := (plxl - (plxl mod 64)) div 64; plyu := (plyu - (plyu mod 64)) div 64; plxr := (plxr - (plxr mod 64)) div 64; plyd := (plyd - (plyd mod 64)) div 64;                                                  
     { for i:=1 to BlockCount do
    if (ObjectUnderPoint(plxl,plyu) = blocksoffield[i,1]) then begin Player.MoveTo(Player.Position.X - Player.Position.X mod 64 +64,Player.Position.Y); kup(VK_Left); lstop := true; break; end;
   for i:=1 to BlockCount do
    if (ObjectUnderPoint(plxr,plyd) = blocksoffield[i,1]) then begin lstop := true; break; end else begin lstop:=false; end;
     if (i = BlockCount) and lstop then lstop := false;}
  {   if Fields[plxl,plyd,1,1] <> 0 then begin kup(VK_left); Player.MoveOn(hforce,0);  lstop := true;  end else lstop:=false;
     //if Fields[plxl,plyd,1,1] <> 0 then begin lstop := true;  end else begin lstop:=false; end;
    //Право
      for i:=1 to BlockCount do
    //  if (ObjectUnderPoint(Player.Position.X-10+1,Player.Position.Y + Player.Height - 5) = blocksoffield[i,1]) then begin Player.MoveTo(Player.Position.X - Player.Position.X mod 64,Player.Position.Y); kup(VK_Right); rstop := true; break; end;
  
   if (ObjectUnderPoint(Player.Position.X + Player.Width -10+1,Player.Position.Y + Player.Height - 5 ) = blocksoffield[i,1]) then begin Player.MoveTo(Player.Position.X - Player.Position.X mod 64 + 10,Player.Position.Y); kup(VK_Right); rstop := true; break; end;
   for i:=1 to BlockCount do
      if (ObjectUnderPoint(Player.Position.X+ Player.Width-10+11,Player.Position.Y + Player.Height - 5) = blocksoffield[i,1]) then begin rstop := true; break; end else begin rstop:=false; end;
     TextOut(100,100,'     ');
     TextOut(100,100,i);
     if (i = BlockCount) and rstop then rstop := false;
  }  
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
  if OnFloor then TextOut(0, 0, 'На земле') else TextOut(0, 0, 'В воздухе');
  if not OnFloor then begin if vspd >= -vspdMAX then vspd := vspd - grav end else vspd := 0;
  
  //Взаимодействие с активируемыми предметами
  
  plxl := Player.Position.X + 10; plyu := Player.Position.Y + 8; plxr := Player.Position.X + Player.Width - 10; plyd := Player.Position.Y + Player.Height - 1;
  plxl := (plxl - (plxl mod 64)) div 64; plyu := (plyu - (plyu mod 64)) div 64; plxr := (plxr - (plxr mod 64)) div 64; plyd := (plyd - (plyd mod 64)) div 64;  
  if OnFloor and ((Fields[plxl, plyu, 5] <> 0) or (Fields[plxr, plyu, 5] <> 0)) then begin
    if (Fields[plxl, plyu, 5] <> 0) then begin
      activateitemID := Fields[plxl, plyu, 5];
      activeitemx := plxl; activeitemy := plyu; end 
    else 
    begin
      activateitemID := Fields[plxr, plyu, 5];
      
      activeitemx := plxr; activeitemy := plyu;
    end;
    vActivateItem := true;
    
    
    
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
  
  //if not yes then begin TextBoxStart(500,100); yes := true; end;
  
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
    //TextOut(0,110,'nigga');
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
        //BlocksOfMiniField[BlockCountMini] := minigameBlocks[minigamefield[j, i].numerofsprite-1].Clone;
        minigamefield[j, i].objectspr := minigameBlocks[minigamefield[j, i].numerofsprite - 1].Clone; 
        minigamefield[j, i].objectspr.MoveTo(nilxpos + j * 64 - 64, nilypos + i * 64 - 64); 
        minigamefield[j, i].objectspr.Visible := true;
        //SetLength(BlocksOfMiniField,BlockCountMini+1);
        //BlocksOfMiniField[BlockCountMini] := minigameBlocks[minigamefield[j, i].numerofsprite-1].Clone; 
        //BlocksOfMiniField[BlockCountMini].MoveTo(nilxpos+j*64-64,nilypos+i*64-64); 
        //BlocksOfMiniField[BlockCountMini].Visible := true;
        
      end;
      
    end;
    
    
  end;
  
end;

procedure undrawminigame();
var
  i, j: int;
begin
//  LockDrawingObjects;
  for j := 1 to 16 do 
  begin
    for i := 1 to 8 do 
    begin
      
      if minigamefield[j, i].empty then begin
        minigamefield[j, i].objectspr.Destroy;
        //SetLength(BlocksOfMiniField,BlockCountMini+1);
        //BlocksOfMiniField[BlockCountMini] := minigameBlocks[minigamefield[j, i].numerofsprite-1].Clone; 
        //BlocksOfMiniField[BlockCountMini].MoveTo(nilxpos+j*64-64,nilypos+i*64-64); 
        //BlocksOfMiniField[BlockCountMini].Visible := true;
        
      end;
      
    end;
    
    
  end;
  BlockCountMini := 0;
  for i := 1 to alldotsofliser.Count do 
  begin
    alldotsofliser.Item[alldotsofliser.Count - 1].Destroy;
    alldotsofliser.RemoveAt(alldotsofliser.Count - 1);
  end;
  //UnLockDrawingObjects;
end;

//==========================Миниигра с лазерами=================================

procedure minigame();
var
  i, xp, yp: int;
begin
  savein();
   //minigamefield[1,1].typeofobgect := 'finish';
   //minigamefield[1,1].rotate := 2;
  // minigamefield[1, 8].typeofobgect := 'start';
  // minigamefield[1, 8].rotate := 1;
   //nilxpos := 142; nilypos := 77;
  IsMiniGameIsFinished := false;
  isMiniGameStartsDo := false;
  cursor.ToFront;
  Window.Fill('Sprites\Backround\MiniGameBack.png'); 
  //var field := new RectangleABC(158, 94, 1024,516,clwhite);
  var field := new pic(nilxpos - 18, nilypos - 18, 'Sprites\Backround\MiniGamePlayBack.png');
  //var ver := new squareabc(142+64*15,77+64*7,64,clwhite);
  //for i := 2 to 17 do partlaserdraw(i,2,0);
  //alllaserdrawing(1,8);
  
  //minigamefield[1,1].typeofobgect := 'finish';
  //minigamefield[1,1].rotate := 2;
  
  //nilxpos := 142; nilypos := 77;
  //cursor.ToFront;
  //Window.Fill('Sprites\Backround\MiniGameBack.png'); 
  //var field := new RectangleABC(158, 94, 1024,516,clwhite);
  //var field := new pic(142-18,77-18,'Sprites\Backround\MiniGamePlayBack.png');
  //var ver := new squareabc(142+64*15,77+64*7,64,clwhite);
  //for i := 2 to 17 do partlaserdraw(i,2,0);
  xp := 1; yp := 8;
  loadminigamefrombuffer(FieldsMiniGame[0]);
  drawminigame;
  
  while not IsMiniGameIsFinished do 
  begin
    if vSpase and not isMiniGameStartsDo then 
    isMiniGameStartsDo := true;
    
    if isMiniGameStartsDo then begin
      alllaserdrawing;
      
      if not IsMiniGameIsFinished then 
      while true do begin
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
  CurModeOfScreen := 'Game';
  UnLockDrawingObjects;
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
  //StartScreenX := 2; StartScreenY := 2;
  StartScreenX := dataforsave.CurScreen.x; StartScreenY := dataforsave.CurScreen.y;
  CurScreenx := StartScreenX; CurScreeny := StartScreeny;
  var startScreen := LocationOfFields[StartScreenX, StartScreenY];
  CurScreen := StartScreen;
  //=========================Начало программы=====================================
  
  loadscreenfrombuffer(FieldsName[StartScreen - 1]);
  drawfield(1, StartScreen);
  
  
  
  
  
  //var dialog := new textbox(500,500,14,'',clblack);
  
  
  while 0 = 0 do
  begin
    if CurModeOfScreen = 'MiniGame' then exit;
    px := Player.Position.X; py := Player.Position.Y;
    AnimTest();
    moveTest();  
    
    if yep then begin TextBoxStart(0, 0, 'опа'); yep := false; end;
    TextOut(0, 0, 'OnFloor: ' + BoolToStr(Onfloor));
    TextOut(0, 20, 'Active: ' + BoolToStr(vActivateItem));
    TextOut(0, 40, 'vL: ' + BoolToStr(vLeft));
    TextOut(0, 60, 'vR: ' + BoolToStr(vRight));
    TextOut(0, 80, 'X: ' + CurScreenx + ' Y: ' + CurScreenY + ' ' + CurScreen);
    TextOut(0, 100, 'Spd: ' + hspd);
    
    
    Sleep(50); 
  end;
end;

//==============================Сохранение и загрузка===========================
procedure savein();
var fileforsave : file of savefile;
begin

dataforsave.CurScreen.x := CurScreenX;
dataforsave.CurScreen.y := CurScreenY;
dataforsave.PlayerPos.x := Player.Position.X;
dataforsave.PlayerPos.y := Player.Position.Y;


Assign(fileforsave,'Save.ini');
Rewrite(fileforsave);
Reset(fileforsave);

write(fileforsave,dataforsave);
Close(fileforsave);
end;

procedure loadfrom();
begin
var fileforsave : file of savefile;
begin
if FileExists('Save.ini') then begin
Assign(fileforsave,'Save.ini');

Reset(fileforsave);

read(fileforsave,dataforsave);
Close(fileforsave); end else begin
dataforsave.CurScreen.x := 2;
dataforsave.CurScreen.y := 2;
dataforsave.PlayerPos.x := 100;
dataforsave.PlayerPos.y := 64*6 + 8;

end;
end;
end;

//=====================Менюшка================================
procedure menu();

begin
  CurModeOfScreen := 'Menu';
  Window.Fill('Sprites\Backround\MenuBack.png');
  playbutt := new spr(537, 359, 'Sprites\UI\PlayButt.png');
  infobutt := new spr(556, 479, 'Sprites\UI\InfoButt.png');
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