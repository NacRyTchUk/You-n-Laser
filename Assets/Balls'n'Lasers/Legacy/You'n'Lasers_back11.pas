
{
Список того, чем стоит занятся:
!!!Сделать всю карту, пустую, но сделать!
!!!!!!!!!!!!!!!!!!!!Концовка в доме, без падения в ущелину!!!!!!!!!!!!!!!!
-Чем ближе конец, тем яснее становится
-анимация бекграунда
-тригеры ачивок
-Заполнение карты
-Эффект парралакса звезд  в меню
-дорисовать канатную дорогу на миникарте
-Сделать мап эдитор
~Доделать миниигру
!-Дописать текст к очивкам
//!~доделать платформы
-НПС
!+Первая/катсцены в общем
-живность
!+Экраны анимации/зарузки
!~Сюжетец/цель
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
  //CountOfScrens = 10; //Количество 'Полей' 
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
  Player,mosta,LoadScreen: spr;
  CurModeOfScreen: Str;
  vLeft, vRight, vUp, vDown, vShift, vSpase, vEkey, vActivateItem: bool; //Флаги клавиш
  OnFloor, onRoof, CanMove, lookl, lookr, testfalling, notmost, lstop, rstop, ustop, sprint,isDebugOn, isMiniGameStartsDo, IsMiniGameIsFinished,newgame,istextinroomisactivaited: bool; // Флаги состояний
  Selector := new spr(-64, -64, 'Sprites\UI\Selector.png'); ///!!!!!!!!!!!!!!!!!!!!!!!
  MiniGameStartRotate, MiniGameStartX, MiniGameStartY, StartScreenX, StartScreenY, CurScreenX, CurScreenY, ActiveItemX, ActiveItemY, activateitemID: int;
  CurScreen: int := 1;
  textforboxes : array[1..100,1..20] of Str;
  achiveTexts : array[1..100] of Str;
  playbutt, infobutt,exitbutt,playbutt2, infobutt2,exitbutt2: spr;
  alternativepayer,alternativepayer2 : spr;
  isDebugFunction : array[1..10] of bool;
  curspherenumb : byte;
  achivetimercounter : int;
  achivetextboxmain,achivetextboxaddition : textbox;
  achiveUI,housespr,houseinsidespr : pic;
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
      //Numbofsphere : int;
      Active : bool;
   end;


type
  savefile = record 
    CurScreen: position;
    PlayerPos: position;
    magicsphereaktive : array[1..100] of bool; 
    numbofsphere : array[1..100] of int;
    achivecompited : array[1..100] of bool;
    curTime : int;
  end;
  
   
var
  MagicSphere : array[1..10] of magsphere;
  minigamefield: array[1..16, 1..8] of minigameempt;
  dataforsave: savefile;
  listofachive := new List<int>;
  
procedure AniTimer(); forward;

procedure game(); forward;

procedure menu(); forward;

procedure minigame(); forward;

procedure undrawfield(); forward;

//procedure drawfield(Layer,curscreen : int); forward;

function booltostr(answ: bool): str; forward;

procedure kup(key: int); forward;

procedure minigamePlateRotate(xp, yp: int); forward;

procedure savein(); forward;

procedure loadfrom(); forward;

procedure endingAnimation(); forward;

var
  ATimer := new timers.Timer(100, AniTimer);

var
  mapspr: spr;

var dBlk := new RectangleABC(0,round(704*1.5),1344,704);
var uBlk := new RectangleABC(0,-704 div 2 ,1344,0);
procedure animation(Numb : int);
var i : int;
begin
  case Numb of
  1 : begin 
  
    for i := 1 to 5 do begin
            dBlk.MoveOn(0,-round((704 div 10)));
            uBlk.MoveOn(0,round((704 div 10)));
   end;
  
  end;
  
  end;
end;


//Счетчик кадров
procedure FrameTimer(FrameTimer:int);
begin
  
end;


//==============================Вывод далоговых окон============================
procedure TextBoxStart(x, y: int; text: Str);
var curcolor : Color;
begin
 if isDebugFunction[1] = false then begin
  
  var temp : array of Str := text.Split('&');
  text := temp[1];
  
  case StrToInt(temp[0]) of 
    1 : curcolor := clLightGreen;
    2 : curcolor := clRed;
    3 : curcolor := clLightBlue;
    4 : curcolor := clYellowGreen;
    5 : curcolor := clViolet;
    6 : curcolor := clSandyBrown;
    7: curcolor := clOrange;
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
    
    // textboxtest.MoveTo(Player.Position.X - 200 + 20, Player.Position.Y - 200 + 20);
    // textboxback.MoveTo(Player.Position.X - 200, Player.Position.Y - 200);
    textboxtest.Text := textboxtest.Text + textik[i];
    if (textik[i] = ' ') and (textboxtest.Text.Length div 30 > linescount) then begin textboxtest.Text := textboxtest.Text + #10#13; Inc(linescount); end;
     Sleep(10);
  end;
  
  while not vSpase do 
  begin
    Sleep(100); //TextOut(200, 200, booltostr(vSpase)); Write('n'); 
  //TextOut(400,400,'Heh');
  end;
  
  //Sleep(5000);
  textboxtest.Destroy;
  textboxback.Destroy;
  
  
  
  CanMove := true;
 end;
end;


//===================Быстрый вывод сообщения===============================
procedure msg(text: str);
begin
  
  //MessageBox.Show(text, 'Debug', MessageBoxButtons.OK, MessageBoxIcon.Asterisk, MessageBoxDefaultButton.Button1, MessageBoxOptions.ServiceNotification);
end;

var fon : array[1..6] of pic;
//var
  //cir := new CircleABC(10, 10, 5, clwhite);
//===================Ввод информации с клавы и мышки===========================
procedure mmove(mx, my, mb: int);
var
  i, j, xc, yc, bcx, bcy: integer;
begin
  mousex := mx; mousey := my;
  case CurModeOfScreen of
    'Game':
      begin
       // Selector.ToFront;
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
         // TextOut(100, 120, '_____________');
         // TextOut(100, 120, xc + ' ' + yc);
          // if  (bcy <= 10) and (bcx <= 20) then if (Fields[bcx,bcy,1,1] <> 0)  then TextOut(xc*64,yc*64,' ');;
          
          //Selector.MoveTo(xc * 64, yc * 64);
          
          //mxold:=mx;myold:=my;
          //end; 
        end;
      end;
    'Menu':
      begin
        try
          begin {
            case ObjectUnderPoint(mx,my) of
              playbutt  : begin 
  playbutt := new spr(20, 325, 'Sprites\UI\PlayButt2.png'); end;
              exitbutt :begin exitbutt := new spr(20, 450, 'Sprites\UI\ExitButt2.png');end;
              infobutt :begin infobutt := new spr(20, 450, 'Sprites\UI\InfoButt2.png'); end;
               end; }
               fon[1].MoveTo(-60+((Window.Width div 2 - mousex)) div 80,-60+((Window.Height div 2 - mousey)) div 80);
               fon[2].MoveTo(-60+((Window.Width div 2 - mousex)) div 50,-60+((Window.Height div 2 - mousey)) div 50);
               fon[3].MoveTo(-60+((Window.Width div 2 - mousex)) div 30,-60+((Window.Height div 2 - mousey)) div 30);
               fon[4].MoveTo(-60+((Window.Width div 2 - mousex)) div 10,-60+((Window.Height div 2 - mousey)) div 10);
               
               LockDrawingObjects;
               if (ObjectUnderPoint(mx,my) = playbutt) or (ObjectUnderPoint(mx,my) = playbutt2) then begin
               //if (mx >= 25) and (mx <= 25 + playbutt.Width) and (my >= 325) and (my <= 325 + playbutt.Height) then 
                playbutt2.Visible := true; 
                end else begin
                playbutt2.visible := false;
                end;
               UnLockDrawingObjects;
               
               if (ObjectUnderPoint(mx,my) = infobutt) or (ObjectUnderPoint(mx,my) = infobutt2) then begin
               //if (mx >= 25) and (mx <= 25 + playbutt.Width) and (my >= 325) and (my <= 325 + playbutt.Height) then 
               infobutt2.Visible := true; 
                end else begin
                infobutt2.visible := false;
                end;
               
               if (ObjectUnderPoint(mx,my) = exitbutt ) or (ObjectUnderPoint(mx,my) = exitbutt2) then begin
               //if (mx >= 25) and (mx <= 25 + playbutt.Width) and (my >= 325) and (my <= 325 + playbutt.Height) then 
            exitbutt2.Visible := true; 
                end else begin
                exitbutt2.visible := false;
                end;//cir.MoveOn(-Round(2*(cir.Position.X - mx)/Sqrt(Sqr((cir.Position.X - mx)) + Sqr((cir.Position.Y - my)))),-Round(2*(cir.Position.Y - my)/Sqrt(Sqr((cir.Position.X - mx)) + Sqr((cir.Position.Y - my)))));
          end
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
        //Rectangle((mx-((mx) mod 64)) , (my-((my) mod 64)),(mx-((mx) mod 64))+64 , (my-((my) mod 64))+64);
       { var blocknew := Blocks[1].Clone;
        blocknew.Visible := true;
        blocknew.MoveTo((mx - ((mx) mod 64)), (my - ((my) mod 64)));
        Inc(BlockCount);
        BlocksOfField[BlockCount, 1] := blocknew;
        if mb = 1 then Fields[(mx - ((mx) mod 64)) div 64, (my - ((my) mod 64))      div 64, 1] := 1 else Fields[(mx - ((mx) mod 64)) div 64, (my - ((my) mod 64))      div 64, 2] := 1;
      }end;
    'Menu': 
      begin
        // vclick := true;
        //  if (mx < 100) and (my < 100) then begin CurModeOfScreen := 'Game' end else if (mx > Window.Width - 100) and (my > Window.Height - 100) then begin CurModeOfScreen := 'MiniGame'; end else vclick := false;
        
        if ObjectUnderPoint(mx, my) = playbutt2 then begin vclick := true; curmodeofscreen := 'Game'; end;
        if ObjectUnderPoint(mx, my) = infobutt2 then begin infobar := new spr(0,0,'Sprites\Backround\info.png'); Sleep(10000); infobar.destroy;  end;
        if ObjectUnderPoint(mx, my) = exitbutt2 then begin vclick := true; Window.Close; end;
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
          VK_Left: begin vLeft := false; if not CanMove then exit; hspd := 0; if OnFloor then Player.State := 5 else Player.State := 6; if vRight then begin lookr := true; end; end;
          VK_Right: begin vRight := false; if not CanMove then exit; hspd := 0; if OnFloor then Player.State := 2 else Player.State := 3; if vleft then begin lookl := true; end; end;
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
              if not lstop and (Fields[plxl, plyd, 1] = 0) then begin
                if vRight then begin kup(VK_Right); exit; end;
                vLeft := true;
                if not lookl then begin LookL := true; lookr := false; end;
                if canmove then begin  if OnFloor then Player.State := 4 else Player.State := 6; end; hspd := -hforce;
              end else begin exit; end; end;
          VK_Right:
            begin
              if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) or not CanMove then exit;     
              if not rstop and (Fields[plxr, plyd, 1] = 0) then begin
                if vLeft then begin kup(VK_Left); exit; end;
                vRight := true; 
                if not LookR  then begin LookR := true; LookL := false; end;
                if canmove then begin  if OnFloor then Player.State := 1 else Player.State := 3; end; hspd := hforce; end else begin exit;  end; end;
          VK_Space: begin vSpase := true;  if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) or not CanMove then exit;   if not CanMove then exit; if canmove and OnFloor then begin vspd := vforce; if LookR then begin if not vRight then Player.State := 3; end else begin  if not vLeft then Player.State := 6; end; end; end;
          VK_ShiftKey: begin vShift := true; if (vLeft xor vRight) and CanMove and not sprint then begin sprint := true; hspd := hspd * 2; ATimer.Interval := 50;  end; end;
          VK_Escape: begin undrawfield(); menu; end;
          VK_J: listofachive.Add(1);
          VK_E: 
            begin
              vEkey := true; 
              
              if vActivateItem then begin
              
              if (CurScreen <> 49) then begin
                undrawfield();// Dec(CurScreenX);CurScreen := LocationOfFields[CurScreenx,CurScreenY]; loadscreenfrombuffer(FieldsName[CurScreen-1], CurScreen); drawfield(1, CurScreen);
                Player.Destroy;
                vEkey := false;
                CurModeOfScreen := 'MiniGame';
                //minigame;
                exit;
                end else begin
                LockDrawingObjects;
                CanMove := false;
                OnFloor := true;
                Player.State := 2;
                undrawfield();
                housespr.Destroy;
                
                end;
              end; end; 
          VK_M: 
            begin
              mapspr.ToFront; 
              var i: int;
              for i := -7 to 0 do  mapspr.MoveTo(0, i * 100 + 8); 
              
              Sleep(3000);
              for I := 0 downto -7 do mapspr.MoveTo(0, I * 100 - 8);
            end;
          VK_F1 : if isDebugOn then begin if isDebugFunction[1] then isDebugFunction[1] := false else isDebugFunction[1] := true; end;
          VK_F2 : if isDebugOn then savein;
       else //Write(booltostr(CanMove));
        
        end;
        //if ((vLeft) and (vRight)) then begin CanMove:=false; Player.State := 2; end else CanMove:= true;;
        
      end;
    'Menu':
      begin
        case key of
          Vk_Space: begin vSpase := true; vclick := true; CurModeOfScreen := 'Game';  end; 
          VK_F1 : if isDebugOn then isDebugFunction[1] := true;       
        
        
        end; end;
    'MiniGame': 
      begin
        case key of
          vk_space: begin vSpase := true end;
        end;
      end;
  end;
end;

procedure endingAnimation();
var i,j : int;
begin
Window.Fill('Sprites\Backround\HouseBack.png');
houseinsidespr := new pic(6*64,7*64-122,'Sprites\Blocks\House.inside.png');
houseinsidespr.ToBack;
for i := 6 to 15 do Fields[i,7,1] := 1;
Fields[5,6,1] := 1;Fields[5,5,1] := 1;
Fields[13,6,1] := 1;Fields[13,5,1] := 1;
 alternativepayer2 := new spr(12*64,6*64+8,54,'Sprites\Player\Player_Sheets_Alternative2.png');
alternativepayer2.AddState('RunR', 5); alternativepayer2.AddState('IdleR', 5); alternativepayer2.AddState('JumpR', 4);
  alternativepayer2.AddState('RunL', 5); alternativepayer2.AddState('IdleL', 5); alternativepayer2.AddState('JumpL', 4);
  alternativepayer2.State := 2;
  alternativepayer2.Active := false;
//ATimer.Interval := 200;  
AniTimer();
UnLockDrawingObjects;
Sleep(2000);
OnKeyDown :=kdown;
OnKeyUp :=kup;
  
alternativepayer2.State := 5;
Sleep(1000);
TextBoxStart(600,200,'4&Приветствую тебя, путник, не хочешь остановиться в моей гостинице?');
TextBoxStart(300,200,'1&Я бы с радостью, но сейчас я ищу своего друга');
TextBoxStart(300,200,'1&Мы решили отдохнуть перед подьемом на Элестию, но по пути к вам в гостиницу я упал с моста');
TextBoxStart(600,200,'4&Охохо! Так это вы!');
TextBoxStart(600,200,'4&Ваш друг приходил сюда вчера, он взял сняряжение и отправился искать вас');
TextBoxStart(400,200,'3&*Тук-тук*');
TextBoxStart(300,200,'1&...');
OnKeyDown :=FrameTimer;
  OnKeyUp :=FrameTimer;
Player.State := 1;
for i := 0 to 30 do begin Player.MoveOn(4,0); Sleep(30);end;
Player.State := 2;
Sleep(300);
Player.State := 5;

OnKeyDown :=kdown;
OnKeyUp :=kup;
TextBoxStart(400,200,'3&*Тук-тук*');
TextBoxStart(600,200,'4&Входите!');
alternativepayer := new spr(8*64+32,6*64+8,54,'Sprites\Player\Player_Sheets_Alternative.png');
alternativepayer.AddState('RunR', 5); alternativepayer.AddState('IdleR', 5); alternativepayer.AddState('JumpR', 4);
  alternativepayer.AddState('RunL', 5); alternativepayer.AddState('IdleL', 5); alternativepayer.AddState('JumpL', 4);
  alternativepayer.State := 2;
  alternativepayer.Active := false;
Sleep(1000);
TextBoxStart(400,200,'2&...!');
TextBoxStart(400,200,'2&Ты все-таки выжил!');
TextBoxStart(500,200,'1&Да... Мне очень повезло с приземлением');
Sleep(1000);
TextBoxStart(500,200,'1&Есть столько всего, что я бы хотел тебе рассказать и...');

TextBoxStart(500,200,'1&Кстати, почему ко мне никто не пришел на помощь? Я лежал без сознания до полуночи');
TextBoxStart(400,200,'2&Спуск к тому месту очень крутой, потребывалось вызывать специалистов, что бы мы смогли спуститься к тебе');
TextBoxStart(400,200,'2&Тем не менее, мне предоставили доступ к состоянию "магических шаров" в реальном времени');
TextBoxStart(400,200,'2&Так что я мог следить за тем, в порядке ли ты, и где тебя искать');
TextBoxStart(400,200,'2&По ним я узнал, куда ты направляешься, а так же судя по информации о сферах......');
Sleep(2000);
var actShereCount : int;
for i := 1 to 15 do if dataforsave.magicsphereaktive[i] then Inc(actShereCount);
if actShereCount = 1 then begin TextBoxStart(400,200,'2&Ты действительно не любишь эти штуки, да? Ты дотронулся только до одного'); listofachive.Add(19); end;
if (actShereCount = 2) and (dataforsave.magicsphereaktive[15]) then begin TextBoxStart(400,200,'2&Ты действительно не любишь эти штуки, да? Ты активировал только необходимые'); listofachive.Add(18); end;
if (actShereCount > 2) and (actShereCount < 8) then begin TextBoxStart(400,200,'2&Ты не особо увлекался прохождением этих головоломок, видимо задача "выбраться отсюда" стояла выше'); listofachive.Add(17); end;
if (actShereCount >= 8) and (actShereCount < 13) then begin TextBoxStart(400,200,'2&Тебе действительно нравилось активировать эти шары, не правда ли? '); listofachive.Add(16); end;
if (actShereCount >= 13) and (actShereCount < 15) then begin TextBoxStart(400,200,'2&Хмм, ты активировал почти все шары на своем пути, видимо это довольно весело, не правда ли?'); listofachive.Add(15); end;
if actShereCount = 15 then begin TextBoxStart(400,200,'2&Вау!'); TextBoxStart(400,200,'2&Ты активировал буквально каждый шар по пути!'); listofachive.Add(20); end;
Sleep(1000);
TextBoxStart(400,200,'2&Сейчас раннее утро и мы совсем рядом с Элестией, не хочешь подняться?');
TextBoxStart(500,200,'1&Серьзено? После такой-то ночи ты еще хочешь на гору?');
TextBoxStart(500,200,'1&Сколько нам до нее идти хотя бы?');
Sleep(500);
Player.State := 2;
Sleep(500);
TextBoxStart(600,200,'4&До вершины рукой подать, нужно всего лишь пройти налево, затем перейти по мосту, а там уже-');
TextBoxStart(500,200,'1&По мосту, серьезно? Очень смешно.');
TextBoxStart(500,200,'1&Ладно, вы как хотите, а я спать');

Player.State := 5;
TextBoxStart(400,200,'2&Здравая мысль');
Player.State := 2;
TextBoxStart(600,200,'4&В таком случае можете расположиться у меня в гостинице, как раз осталось 2 свободных номера');
TextBoxStart(500,200,'1&Наконец-то можно отдохнуть');
listofachive.Add(5);
var blrect:= new RectangleABC(0,0,window.Width,window.Height,clblack);
DeleteFile('save.ini');

CanMove := false;

//Sleep(5000);
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
  FieldFile, FieldLocationFile,FileT: Text;
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
  Close(FieldLocationFile);
 
  Assign(FileT,'Assets\Dialog.list');
  Reset(FileT);
  i:=1;
  repeat
    Readln(FileT, Line);
    if Line = '' then break;
    //Line := 'Fields\MiniGame\' + Line;
    //SetLength(FileT, i + 1);
    var temp : array of Str := Line.Split(';');
    for j := 0 to temp.Length -1 do
    textforboxes[i,j+1] := temp[j];
    
    Inc(i);
  until Line = 'End.';
  Close(FileT);
  
  
  
  Assign(FileT,'Assets\AchievementText.list');
  Reset(FileT);
  i:=1;
  repeat
    Readln(FileT, Line);
    if Line = '' then break;
    //Line := 'Fields\MiniGame\' + Line;
    //SetLength(FileT, i + 1);
    achiveTexts[i] := Line;
    
    Inc(i);
  until Line = 'End.';
  Close(FileT);
  
  
  
   
  
  if (FileExists('debug.on')) then isDebugOn := true;
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
        //if (CurScreen = 10) and (MagicSphere[4].Active) and (blkInfo[j] = '56') then blkInfo[j] := '57';
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


//var cursphereid : array[1..10] of byte;


//=================Отрисовка поля=========================
procedure drawfield(layer, CurScreen: int);
var
  i, j: int;
begin
  //LockDrawingObjects;
  //Window.Fill('Sprites\Backround\NIghtSky3.png');
  //var back := new pic(0,0,'Sprites\Backround\NIghtSky3.png'); ////!!!!!!!!!!
  //back.Scale(3);
  //back.ToBack; ///!!!!!!!!!!!!!!!!!!!!!!!
  for i:=1 to 10 do MagicSphere[i].curID := 0;
  curspherenumb := 0;
  
  for layer := 1 to 5 do 
    for i := 0 to 10 do 
      for j := 0 to 20 do
      begin
        if (Fields[j, i, layer] <> 0)  and (Fields[j, i, layer] <> 56) then
        begin
         
          Inc(BlockCount);
          Inc(CounterOfBlocksL[layer]);
          
          
          if (layer = 5) then begin  
          if (CurScreen <> 49) then begin
          Inc(curspherenumb);
          MagicSphere[curspherenumb].CurID := Fields[j, i, layer];
            
          if dataforsave.magicsphereaktive[Fields[j, i, layer]]  then begin
            Fields[j, i, layer] := 55;
             
          end else begin 
            MagicSphere[curspherenumb].LocationOfScreen.x := j;
            MagicSphere[curspherenumb].LocationOfScreen.y := i;
            Fields[j, i, layer] := 54;
            //cursphereid[curspherenumb] := Fields[j, i, layer];
           //if dataforsave.magicsphereaktive[Fields[j, i, layer]] then Fields[j, i, layer] := 55 else Fields[j, i, layer] := 54;
          
          
            end; 
            end else begin
            Fields[j, i, layer] := 58;
            end;
          end;
          if (Fields[j, i, layer] = 54) or (Fields[j, i, layer] = 55) then begin
          MagicSphere[curspherenumb].Spritesphere  := new spr(j * 64, I * 64,BlocksName[Fields[j, i, layer]]);
          if not istextinroomisactivaited then istextinroomisactivaited := true;
          //MagicSphere[curspherenumb].Spritesphere := Blocks[Fields[j, i, layer]].Clone;
          //MagicSphere[curspherenumb].Spritesphere.MoveTo(j * 64, I * 64); // Помещаем его на нужные координаты и делаем видимым
          //MagicSphere[curspherenumb].Spritesphere.Visible := true;
          BlocksOfField[CounterOfBlocksL[layer], layer] := Blocks[Fields[j, i, layer]].Clone;
          end else begin
          if (Fields[j, i, layer] <> 0) then begin
          BlocksOfField[CounterOfBlocksL[layer], layer] :=
          new spr(j * 64, I * 64,BlocksName[Fields[j, i, layer]]);
         // BlocksOfField[CounterOfBlocksL[layer], layer] := Blocks[Fields[j, i, layer]].Clone; //Копируем спрайт из буфера
         // BlocksOfField[CounterOfBlocksL[layer], layer].MoveTo(j * 64, I * 64); // Помещаем его на нужные координаты и делаем видимым
         // BlocksOfField[CounterOfBlocksL[layer], layer].Visible := true;
          if layer = 3 then 
          BlocksOfField[CounterOfBlocksL[layer], layer].ToBack; end;
          end;
        end;
      end;
      
      if (curspherenumb > 0) then begin
      
   for i:= 0 to 10 do
      for j := 0 to 20 do
        begin
        if (dataforsave.magicsphereaktive[MagicSphere[curspherenumb].curID]) then begin
        if  (Fields[j, i, 1] = 56) then begin 
          Fields[j, i, 2] := 57; Fields[j, i, 1] := 0;   Inc(CounterOfBlocksL[2]); //Dec(CounterOfBlocksL[1]); //  
          BlocksOfField[CounterOfBlocksL[2], 2] := 
          new spr(j * 64, I * 64,BlocksName[57]);
         
          
          end;
                  
         end else begin
            
        if  (Fields[j, i, 1] = 56) then begin 
           Inc(CounterOfBlocksL[1]); Inc(BlockCount);
          BlocksOfField[CounterOfBlocksL[1], 1] := 
          new spr(j * 64, I * 64,BlocksName[56]);
         BlocksOfField[CounterOfBlocksL[1], 1].ToFront;
          
            end;
                  
        end;     
        
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
  
  
  
  //UnLockDrawingObjects; 
  if curspherenumb = -1 then curspherenumb := 0;
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
  
  
  for i:=1 to curspherenumb do MagicSphere[i].Spritesphere.Destroy;
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
  if alternativepayer <> nil then begin if alternativepayer.Frame < 5 then alternativepayer.Frame := Player.Frame + 1;
  if alternativepayer.Frame  >= 5 then alternativepayer.Frame := 1; end;
  if alternativepayer2 <> nil then begin if alternativepayer2.Frame < 5 then alternativepayer2.Frame := Player.Frame + 1;
  if alternativepayer2.Frame  >= 5 then alternativepayer2.Frame := 1; end;
  
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
  //var fin := new SquareABC(nilxpos + xfin * 64 - 64, nilxpos + xfin * 64 + 64 - 1, 64, clwhite);
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


var blackscr : RectangleABC;


//================================Проверка и кориктировка движений игрока===========================
procedure moveTest();
var
  i: int;
  found: bool;
  debugstring : Str;
begin
   if isDebugOn then begin
    for i:=1 to 1 do 

  if isDebugFunction[i] then debugstring := debugstring + 'debug '+i+': On' + NewLine else debugstring := debugstring + 'debug '+i+': Off' + NewLine;
  var col : Color = Brush.Color;
  Brush.Color := clWhite;
  TextOut(0,0,debugstring);
  Brush.Color := col; 
  end;
  // if (CurScreenX = 16) or (CurScreenX = 1) or (CurScreenY = 8) or CurScreenY = 1 
  //LockDrawingObjects;
    //Вытаскивание игрока из под блока, если он туда провалился
  if (0  >= px  + hspd) then begin if CurScreen = 6 then begin kup(VK_Left); exit; end;  LockDrawingObjects; if CurScreen = 49 then begin housespr.Destroy; end; undrawfield(); if (CurScreenX = 1) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else  Dec(CurScreenX); CurScreen := LocationOfFields[CurScreenx, CurScreenY]; if CurScreen = 0 then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); drawfield(1, CurScreen);  Player.Moveto(window.Width - 70, py); UnLockDrawingObjects; end;
  if (px + Player.Width - 10 + hspd >= Window.Width) then begin
    
    LockDrawingObjects;
    undrawfield(); 
    if (CurScreenX = 16) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else Inc(CurScreenX);
    CurScreen := LocationOfFields[CurScreenx, CurScreenY];
    if (CurScreen = 0)  then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); 
    if (CurScreen = 49) then begin  housespr := new pic(400-40,7*64-200,'Sprites\Blocks\House.outside.png'); housespr.ToBack;   end;
    drawfield(1, CurScreen);  Player.Moveto(8, py); UnLockDrawingObjects; end;
  if (0  >= py - vspd) then begin LockDrawingObjects; undrawfield(); if (CurScreenY = 1) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else if (CurScreen = 12) then listofachive.Add(3);  Dec(CurScreenY); CurScreen := LocationOfFields[CurScreenx, CurScreenY]; if CurScreen = 0 then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); drawfield(1, CurScreen);  Player.Moveto(px, Window.Height - Player.Height); UnLockDrawingObjects; end;
  if (py - vspd  >= Window.Height) then begin  LockDrawingObjects;   undrawfield();  if (CurScreenY = 8) then begin CurScreenX := StartScreenX; CurScreenY := StartScreenY end else if (CurScreen = 52) then listofachive.Add(4); Inc(CurScreenY); if (CurScreen = 6) and (LocationOfFields[CurScreenx, CurScreenY] = 5) then begin Player.Moveto(64 + 32, player.Height); if isDebugFunction[1] = false then mosta.Destroy; end else Player.Moveto(px, player.Height); CurScreen := LocationOfFields[CurScreenx, CurScreenY]; if CurScreen = 0 then loadscreenfrombuffer('Fields\Main\level0.map') else loadscreenfrombuffer(FieldsName[CurScreen - 1]); drawfield(1, CurScreen);  if (CurScreen = 1) and newgame then Window.Fill('Sprites\Backround\Pogoda3.png'); if (CurScreen = 5) and newgame then Window.Fill('Sprites\Backround\Pogoda2.png'); UnLockDrawingObjects;  end;
  if ((0  < px + hspd) and (px + hspd < Window.Width)) and ((0  < py - vspd) and (py - vspd < Window.Height)) then
  begin if CanMove then begin if vRight and vLeft then {Player.moveon(0,-vspd)} else Player.moveon(hspd, -vspd) end end else;// Player.MoveTo(random(64,window.Width-64),64*Random(1,5)+64-Player.Height); 
  //Обработка Нажаните шифта
  //if (vShift and ((vLeft) xor (vRight)) and not sprint) then begin sprint := true; hspd:= hspd*2; ATimer.Interval := 50;  end else if (not vShift and ((vLeft) or (vRight))) and (ATimer.Interval = 50) then  begin   end;
  //UnLockDrawingObjects;
  
  
  //Обработка состояний "На земле" и "В воздухе"
  
  
    //Проверка на падение 
  var plxl, plyu, plxr, plyd, plyd0, plyd1: int;
  var platform: bool;
  
  
  
  plxl := Player.Position.X + 10; plyu := Player.Position.Y + 20; plxr := Player.Position.X + Player.Width - 10; plyd := Player.Position.Y + Player.Height; plyd0 := Player.Position.Y + Player.Height + 4; plyd1 := Player.Position.Y + Player.Height - 8;
  plxl := (plxl - (plxl mod 64)) div 64; plyu := (plyu - (plyu mod 64)) div 64; plxr := (plxr - (plxr mod 64)) div 64; plyd := (plyd - (plyd mod 64)) div 64; plyd0 := (plyd0 - (plyd0 mod 64)) div 64; plyd1 := (plyd1 - (plyd1 mod 64)) div 64; 
  
  if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) then begin exit; end else begin///!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    //Падение с моста
   if isDebugFunction[1] = false then begin
   
   if (((Player.Position.X - (Player.Position.X mod 64)) div 64) >= 12)  and (newgame) and not notmost then begin
    
    var j,st : int;
      Player.MoveTo(Player.Position.X,6*64+8);   
   // Player.Active := false;
   st := Player.State;
    rstop := true;
    lstop := true;
    Player.State := 2;
    mosta.State := 1;
   for j:= 1 to 2 do 
   for i := 1 to 3 do begin
      mosta.Frame := I; 
      if i = 2 then Player.MoveOn(0,4);
      if i = 3 then Player.MoveOn(0,-4);
      Sleep(200);
  end; 
  TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&О нет!');
   for i := 1 to 3 do begin
      mosta.Frame := I; 
      if i = 2 then Player.MoveOn(0,4);
      if i = 3 then Player.MoveOn(0,-4);
      Sleep(200);
  end; 
  mosta.State := 2;
  for i := 1 to 2 do begin
      mosta.Frame := I; Sleep(200);
  end;
  Fields[13,7,1] := 0; Fields[12,7,1] := 0;
  //Sleep(5000);
    notmost := true;
    Player.State := st;
    end;
   end else begin
   
  Fields[13,7,1] := 0; Fields[12,7,1] := 0;
  //Sleep(5000);
    notmost := true;
   end;
    
    
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
            //TextOut(900, 10, 'normal');
            OnFloor := true;
            if (CurScreen = 1) and (newgame) then begin
            blackscr := new RectangleABC(0,0,Window.Width,Window.Height,clblack);
            Sleep(2000);
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Черт...');
            Sleep(1000);
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Повезло остаться в живых... Ух...');
            Sleep(1000);
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Я упал с моста? Он сломался?');
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Видимо, я упал на кучу листьев, которые смягчили мне падение');
            Sleep(500);
            
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Я провалялся тут слишком долго');
            
            
            Window.Fill('sprites\Backround\nightsky3.png');
            blackscr.Destroy;
            Sleep(500);
            
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Уже вечер');
            Sleep(500);
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Видимо друг пошел до гостиницы, почему никто не пришел помочь мне от туда?');
            TextBoxStart(Window.Width div 2 - 200,Window.Height-200,'1&Нужно осмотреться вокруг, возможно я найду способ подняться обратно');
            listofachive.Add(1);
            Sleep(1000);
             rstop := false;
    lstop := false;
            newgame := false;
            savein;
            end;
            
            Player.MoveTo(Player.Position.X, Player.Position.Y - Player.Position.Y mod 64 + 8);
          end else begin
           // if (vspd < -10) and (vspd > -13 ) and vSpase then begin OnFloor := true; kdown(VK_Space); OnFloor := false; end;
            if vspd < -13 then begin
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
  plxl := Player.Position.X + 10 - hforce * mylt; plyu := Player.Position.Y + 8; plxr := Player.Position.X + Player.Width - 10 + hforce * mylt; plyd := Player.Position.Y + Player.Height - 1; //plyu := Player.Position.Y + 20;
  plxl := (plxl - (plxl mod 64)) div 64; plyu := (plyu - (plyu mod 64)) div 64; plxr := (plxr - (plxr mod 64)) div 64; plyd := (plyd - (plyd mod 64)) div 64; //plyu := (plyu - (plyu mod 64)) div 64;                                                     
     
     
     
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
  plxl := Player.Position.X + 10; plyu := Player.Position.Y + 9; plxr := Player.Position.X + Player.Width - 10; plyd := Player.Position.Y + Player.Height;
  plxl := (plxl - (plxl mod 64)) div 64; plyu := (plyu - (plyu mod 64)) div 64; plxr := (plxr - (plxr mod 64)) div 64; plyd := (plyd - (plyd mod 64)) div 64;  
  
  if not OnFloor and ((Fields[plxl, plyu, 1] <> 0) or (Fields[plxr, plyu, 1] <> 0)) then begin vspd := -vspd div 2; Player.MoveTo(Player.Position.X, (plyu + 1) * 64); end else;
  
  //Гравитация 
//  if OnFloor then begin TextOut(0, 0, 'На земле');
 // for i:=1 to 4 do TextBoxStart(100,100,textforboxes[1,i]);
  
 // end else TextOut(0, 0, 'В воздухе');
  if not OnFloor then begin if vspd >= -vspdMAX then vspd := vspd - grav end else vspd := 0;
  
  //Взаимодействие с активируемыми предметами
  
  plxl := Player.Position.X + 10; plyu := Player.Position.Y + 8; plxr := Player.Position.X + Player.Width - 10; plyd := Player.Position.Y + Player.Height - 1;
  plxl := (plxl - (plxl mod 64)) div 64; plyu := (plyu - (plyu mod 64)) div 64; plxr := (plxr - (plxr mod 64)) div 64; plyd := (plyd - (plyd mod 64)) div 64;  
  //curspherenumb := 11;
  
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
    if not vActivateItem and istextinroomisactivaited and (MagicSphere[curspherenumb].curID = 1) then begin 
    I:=1;
    istextinroomisactivaited := false;
    while textforboxes[MagicSphere[curspherenumb].curID,i] <> '' do begin
    
    TextBoxStart(ActiveItemX*64-180,ActiveItemY*64-150,textforboxes[MagicSphere[curspherenumb].curID,i]);
    Inc(i);
    end;
    listofachive.Add(6);
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
  
  if OnFloor and ((Fields[plxl, plyu, 5] <> 0) or (Fields[plxr, plyu, 5] <> 0)) and (CurScreen = 49) then 
      begin
      //TextOut(Player.Position.X,Player.Position.Y,'yes, i am');
      vActivateItem := true;
      end else if (CurScreen = 49) then vActivateItem := false;
  
end;

//========================Проверка правильной работы анимаций и их кориктировка==========================
procedure AnimTest();
begin
  TextOut(100,100,booltostr(not OnFloor));
  
  if ((vLeft) xor (vRight)) and (ATimer.Interval = 400) then ATimer.Interval := 100; 
  if not ((vLeft) xor (vRight)) and ((ATimer.Interval = 100) or (ATimer.Interval = 50)) then ATimer.Interval := 400; 
  
  //if not yes then begin TextBoxStart(500,100); yes := true; end;
  
  //Прыжок 
  if not ((vLeft) and (vRight)) and (not OnFloor)  and not ((Player.State = 3) or (Player.State = 6)) then begin
      Player.Active := false;
      if lookr then begin
        Player.State := 3;
      end else Player.State := 6;
      Player.Frame := 1;
    end;
  if (not OnFloor) and (Player.Frame < 3) and ((Player.State = 3) or (Player.State = 6)) then begin
      if vspd > 3 then Player.Frame := 1;
      if (vspd <= 3) and (vspd >= -3) then Player.Frame := 2;
      if vspd < -3 then Player.Frame := 3;
    
  end;
  
  //Обработка анимаций после завершения прыжка
  if OnFloor and ((Player.State = 3) or (Player.State = 6))   then begin
    
    if Player.State = 3 then begin
      if vRight then Player.State := 1 else Player.State := 2;
    end;
    if Player.State = 6 then begin
      if vLeft then Player.State := 4 else Player.State := 5;
    end;
  end; 
  
  if (vActivateItem) and (CurScreen = 49) and (vEkey) then endingAnimation();
  
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
var i,j : int;
begin
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
  
  loadminigamefrombuffer(FieldsMiniGame[MagicSphere[curspherenumb].curID-1]);
  drawminigame;
  
  if MagicSphere[curspherenumb].curID = 1 then begin
  var tutor := new pic((Window.Width - 1271) div 2,(Window.Height - 650) div 2,'Sprites\Backround\MiniGamePlayBack1.png');
  Sleep(5000);
  tutor.Destroy;
  end;
  
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
  
  for i := 1 to 16 do
    for j := 1 to 8 do begin
      if minigamefield[i,j].empty then begin 
      minigamefield[i, j].numerofsprite := 0;
      minigamefield[i, j].typeofobgect := '';
        minigamefield[i, j].objectspr := nil;
        minigamefield[i, j].empty := false;
      end;
    end;
  
  field.Destroy;
  cursor.MoveTo(-8, -8);
  vActivateItem := false;
  
  //dataforsave.magicsphereaktive[cursphereid[1]] := true;
  
  
  //savein;
  dataforsave.magicsphereaktive[MagicSphere[curspherenumb].curID] := true;
  savein;
  CurModeOfScreen := 'Game';
end;


procedure achieveAnimation();
var endani : bool;
begin

if (listofachive.Count = 0) or dataforsave.achivecompited[listofachive[0]] then exit;
SetFontName('Comic Sans MS');
 if achivetimercounter = 0 then begin 
 var lineup := achiveTexts[listofachive[0]].Split(';');
 //achivetextboxmain.Text := lineup[0];
 //achivetextboxaddition.Text := lineup[1];
 LockDrawingObjects;
 achiveUI := new pic(Window.Width,0,'Sprites\UI\AchievementUnlocked.png');
 
achivetextboxmain := new textbox(Window.Width+20,18,13,lineup[0],clLime);
 achivetextboxaddition := new textbox(Window.Width+20,40,10,lineup[1],clgreen);
UnLockDrawingObjects;
 end;
Inc(achivetimercounter);
Inc(achivetimercounter);
//try

if (achivetimercounter <= 80) and (achivetimercounter mod 10 = 0) then begin
 achivetextboxmain.MoveOn(-50,0); achivetextboxaddition.MoveOn(-50,0); achiveUI.MoveOn(-50,0); 
LockDrawingObjects; 
achiveUI.ToFront; achivetextboxmain.ToFront; achivetextboxaddition.ToFront;
UnLockDrawingObjects;
end;
if (listofachive[1] = 5) and (achivetimercounter = 2) then begin 
var end1 := new pic(0,0,'Sprites\Backround\Ending1spr.png');
Sleep(1000);

var end2 := new pic(0,0,'Sprites\Backround\Ending2spr.png');
end;
if (achivetimercounter >= 200) and (achivetimercounter mod 10 = 0) then begin
 achivetextboxmain.MoveOn(50,0); achivetextboxaddition.MoveOn(50,0); achiveUI.MoveOn(50,0); 
LockDrawingObjects; 
achiveUI.ToFront; achivetextboxmain.ToFront; achivetextboxaddition.ToFront;
UnLockDrawingObjects;
end;

if (listofachive[1] = 5) and (achivetimercounter = 2) then begin 
Sleep(500);
var end3 := new pic(0,0,'Sprites\Backround\Ending3spr.png'); end;
{case achivetimercounter of
  10 : begin achivetextbox.MoveOn(-30,0); achiveUI.d;
  20 : achivetextbox.MoveOn(-30,0);
  30 : achivetextbox.MoveOn(-30,0);
  40 : achivetextbox.MoveOn(-30,0);
  110 : achivetextbox.MoveOn(30,0);
  120 : achivetextbox.MoveOn(30,0);
  130 : achivetextbox.MoveOn(30,0);
  140 : achivetextbox.MoveOn(30,0);
  end;}

if achivetimercounter >= 280 then begin 
LockDrawingObjects;
achivetextboxaddition.Destroy;
achivetextboxmain.Destroy;
achiveUI.Destroy;
UnLockDrawingObjects;

achivetimercounter := 0;

dataforsave.achivecompited[listofachive[0]] := true;
listofachive.RemoveAt(0);
end;
//except
//end;
end;


procedure newgamecutscene();
begin

if isDebugFunction[1] = false then begin

OnKeyDown :=FrameTimer;
  OnKeyUp :=FrameTimer;
  Window.Fill('sprites\Backround\pogoda1.png');
  alternativepayer := new spr(180,6*64+8, 54, 'Sprites\Player\Player_Sheets_Alternative.png');
  alternativepayer.AddState('RunR', 5); alternativepayer.AddState('IdleR', 5); alternativepayer.AddState('JumpR', 4);
  alternativepayer.AddState('RunL', 5); alternativepayer.AddState('IdleL', 5); alternativepayer.AddState('JumpL', 4);
  alternativepayer.Active := false; 
  alternativepayer.State := 1;
  alternativepayer.ToBack;
  
  mosta := new spr(64*11,64*6,192,'Sprites\Blocks\Most-a.png');
  mosta.AddState('st',3); mosta.AddState('st1',3);
  mosta.State := 1;
  mosta.Active := false;
  var i,j : int;
  
  mosta.Frame := 1;
  ATimer.Interval := 200;
  UnLockDrawingObjects;
  
  
  
  
  for i := 1 to 80 do begin alternativepayer.MoveOn(4,0); Sleep (20);end;
  alternativepayer.State := 5;
  
  OnKeyDown :=kdown;
OnKeyUp :=kup;
  Sleep(500);
  TextBoxStart(150, 200,'2&Чего встал? ');
    Sleep(300);
  TextBoxStart(50, 200,'1&...Ууух... Ты бы не мог... Ух... Не так сильно торопиться?');
  TextBoxStart(150, 200,'2&Ну же, такими темпами мы не успеем взобраться на Элестию до заката');
  TextBoxStart(50, 200,'1&Мы только что поднялись  на гору такой же высоты как Элестия, зачем нам идти до нее?');
  TextBoxStart(150, 200,'2&Мы поднялись на нее на фуникулере, а у Элестии... ');
  TextBoxStart(150, 200,'2&Стой');
  TextBoxStart(150, 200,'2&Ты так запыхался подымаясь по ступенькам от фуникулера?');
  TextBoxStart(50, 200,'1&Слушай, я не думаю, что смогу осились полноценный подьем на гору сегодня');
  TextBoxStart(50, 200,'1&Может остановимся в ближайшей гостинице до завтра?');
    TextBoxStart(150, 200,'2&Лентяй! ');
    TextBoxStart(150, 200,'2&Ладно, до гостиницы можно быстро добраться по канатной переправе за этим мостом');
  TextBoxStart(150, 200,'2&Иди за мной');
  OnKeyDown :=FrameTimer;
OnKeyUp :=FrameTimer;
Sleep(500);
  alternativepayer.State := 1;
 // var timer : int := 40;
  alternativepayer.ToBack;
  for i := 1 to 45 do begin alternativepayer.MoveOn(4,0); Sleep (20);end;
  mosta.Frame := 2;
  alternativepayer.MoveOn(0,4);
  for i := 1 to 15 do begin alternativepayer.MoveOn(4,0); Sleep (20);end;
  mosta.Frame := 1;
  alternativepayer.MoveOn(0,-4);
  for i := 1 to 20 do begin alternativepayer.MoveOn(4,0); Sleep (20);end;
  mosta.Frame := 3;
  alternativepayer.MoveOn(0,4);
  for i := 1 to 10 do begin alternativepayer.MoveOn(4,0); Sleep (20);end;
  mosta.Frame := 1;
  alternativepayer.MoveOn(0,-4);
  for i := 1 to 30 do begin alternativepayer.MoveOn(4,0); Sleep (20);end;
  
  //alternativepayer.State := 3;
  //alternativepayer.Active := false;
  //for i:= -10 to  10 do begin if i < -5 then alternativepayer.Frame := 1; if i > 5 then alternativepayer.Frame := 3; if (i <= 5) and (i >=-5 ) then alternativepayer.Frame := 2; alternativepayer.MoveOn(7,i); Sleep (30);end;
  //alternativepayer.Active := true;
  //alternativepayer.State := 1;
  //for i := 1 to 55 do begin alternativepayer.MoveOn(4,0); Sleep (50);end;
  
 alternativepayer.Destroy;
  Sleep(200);
OnKeyUp :=kup;
  OnKeyDown :=kdown;
  TextBoxStart(50, 200,'1&...');
  
  
  CanMove := true;
  end;
  
newgame:= true;
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
  
  CurModeOfScreen := 'Game';
  ATimer.Start;
  CanMove := true;
  if not IsMiniGameIsFinished then
  begin
  Player.State := 2;
  lookr := true;
  OnFloor := true;
  end;
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
  newgamecutscene();
  end;
  UnLockDrawingObjects;
  if IsMiniGameIsFinished then begin
 if curspherenumb > 0 then  begin
 var ox,oy : int;
 AnimTest;
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
  
  
  
  savein;
  var i : int;
  if istextinroomisactivaited then begin 
    I:=1;
    istextinroomisactivaited := false;
    while textforboxes[MagicSphere[curspherenumb].curID+1,i] <> '' do begin
    
    TextBoxStart(ActiveItemX*64-180,ActiveItemY*64-150,textforboxes[MagicSphere[curspherenumb].curID+1,i]);
    Inc(i);
    end;
    I:=0;
     end;
  
  
  
  end;
  end;
  
  
  
  
  //var dialog := new textbox(500,500,14,'',clblack);
  
  
  while 0 = 0 do
  begin
    if CurModeOfScreen = 'MiniGame' then exit;
    px := Player.Position.X; py := Player.Position.Y;
    
    AnimTest();
    
    moveTest();  
    
    achieveAnimation();
    TextOut(10,40,booltostr(vLeft)); TextOut(50,40,booltostr(vRight));
    TextOut(10,60,booltostr(lookl)); TextOut(50,60,booltostr(lookr));
    Sleep(40); 
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
      dataforsave.curTime := 1;
      for i:=1 to 100 do dataforsave.magicsphereaktive[i] := false;
      
      
    end;
  end;
end;

//=====================Менюшка================================
procedure menu();
var i : int;
begin
  CurModeOfScreen := 'Menu';
  var achivecounttext : textbox;
  var achivecount : int;
  for i := 1 to 100 do if dataforsave.achivecompited[i] then Inc(achivecount);
  
  if achivecount > 0 then achivecounttext := new textbox(Window.Width-320,10,16,'Выполненно достижений: ' +achivecount + '/6',cllightGreen);
  
  fon[1] := new pic(0,0,'Sprites\Backround\MenuBack_Moon.png');
  fon[2] := new pic(0,0,'Sprites\Backround\MenuBack_Stars.png');
  fon[3] := new pic(0,0,'Sprites\Backround\MenuBack_Cloude.png');
  fon[4] := new pic(0,0,'Sprites\Backround\MenuBack_Logo.png');
  LoadScreen.ToFront;
  
  
  UnLockDrawingObjects;
  //LoadScreen.ToFront;
  for i := 2 to 5 do begin LoadScreen.Frame := i; Sleep(200); end;
  LoadScreen.Visible := false;
  LockDrawingObjects;
  if FileExists('Save.ini') then playbutt := new spr(-580, 325, 'Sprites\UI\ContinueButt.png') else playbutt := new spr(-580, 325, 'Sprites\UI\NewGameButt.png');
  
  infobutt := new spr(-580, 450, 'Sprites\UI\InfoButt.png');
  exitbutt := new spr(-580, 575,'Sprites\UI\ExitButt.png');
  if FileExists('Save.ini') then playbutt2 := new spr(-580, 325, 'Sprites\UI\ContinueButt2.png') else playbutt2 := new spr(-580, 325, 'Sprites\UI\NewGameButt2.png'); 
  
  infobutt2 := new spr(-580, 450, 'Sprites\UI\InfoButt2.png');
  exitbutt2 := new spr(-580, 575,'Sprites\UI\ExitButt2.png');
  mmove(1,1,1);
  UnLockDrawingObjects;
  for i := 0 to 30 do begin
  playbutt.moveon(20,0);
  infobutt.moveon(20,0);
  exitbutt.moveon(20,0);
  playbutt2.moveon(20,0);
  infobutt2.moveon(20,0);
  exitbutt2.moveon(20,0);
  end;
  //Sleep(5000);
  //game();
  while true do 
  begin
    while not vclick do
    begin
      Sleep(10);
    end;
    fon[1].Destroy;
    fon[2].Destroy;
    fon[3].Destroy;
    fon[4].Destroy;
    if achivecount > 0 then achivecounttext.Destroy;
    playbutt.Destroy;
    infobutt.Destroy;
    exitbutt.Destroy;
    playbutt2.Destroy;
    infobutt2.Destroy;
    exitbutt2.Destroy;
    case CurModeOfScreen of
      'Game': game;
      //begin animation(1); break; end;
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
LockDrawingObjects;
  LoadScreen := new spr(0,0,1344,'Sprites\Backround\LoadScreen.png');
  LoadScreen.Active := false;
  LoadScreen.Frame := 2;
  
//unlockDrawingObjects;
  //===================Описание основ=============================================
  OnMouseMove := mmove; 
  OnMouseDown := mdown;
  OnMouseUp := mup;
  OnKeyPress := kpress;
  OnKeyDown := kdown;
  OnKeyUp := kup;
  Window.SetSize(1344, 704);
  
Window.Fill('Sprites\Backround\MenuBack.png');
  Window.CenterOnScreen;
  Window.IsFixedSize := true;
  Window.Title := 'You and Lasers';
  
  loadfrom;
  loadobjfromfile('Sprites.list'); //Подгрузка обьктов и экранов в память и последующая их отрисовка
  loadfieldfromfile();
  //LockDrawingObjects;
  menu();
  Readln;
end.