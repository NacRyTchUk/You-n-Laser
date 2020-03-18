
{
Список того, чем стоит занятся:
//!!!Сделать всю карту, пустую, но сделать!
//!!!!!!!!!!!!!!!!!!!!Концовка в доме, без падения в ущелину!!!!!!!!!!!!!!!!
-Чем ближе конец, тем яснее становится
-анимация бекграунда
//-тригеры ачивок
//-Заполнение карты
//-Эффект парралакса звезд  в меню
//-дорисовать канатную дорогу на миникарте
-Сделать мап эдитор
~Доделать миниигру
//!-Дописать текст к очивкам
//!~доделать платформы
-НПС
//!+Первая/катсцены в общем
-живность
!+Экраны анимации/зарузки
//!~Сюжетец/цель
}
uses abcsprites, abcobjects, graphabc, timers;


const
  Layers = 5; //Количество уровней (Обьекты заднего фона, обьекты между игроком и персоонажем)
  grav = 3; //Гравитация
  vforce = 30; // Сила с которой мы еденично действуем на обьект придавая ему скорость вертикально
  hforce = 8; //Горизонтальная разовая сила
  trenie = 1; // Сила замедляющее тело во время скольжения 
  vspdMAX = 50;// Максимальна скорость на которую может ускориться игрок по вертикали
  nilxpos = 142; 
  nilypos = 77;
  ACHIVNUMB = 21;
  SPHERENUMB = 15;
  COMPITBLEACHIVONONERUN = 10;


type
  int = integer;
  Str = string;
  bool = boolean;
  float = char;
  pic = PictureABC;
  obj = ObjectABC;
  spr = SpriteABC;
  textbox = TextABC;


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
    Spritesphere: spr;
    CurScreen: int;
    LocationOfScreen: position;
    curID: int;
    Active: bool;
  end;


type
  savefile = record 
    CurScreen: position;
    PlayerPos: position;
    magicsphereaktive: array[1..SPHERENUMB] of bool; 
    numbofsphere: array[1..SPHERENUMB] of int;
    achivecompited: array[1..ACHIVNUMB] of bool;
    curTime: int;
  end;
  
  
var //Мусорка (Глобальные переменные)
  Fields: array [0..20, 0..10, 0..Layers] of byte; //Поле индексов
  LocationOfFields: array [1..12, 1..8] of byte; //Расположение полей относительно друг друга
  BlocksOfField: array [1..400, 0..layers] of spr; //Спрайты послойно
  CounterOfBlocksL: array [0..layers] of int; //Счетчик спрайтов послойно
  textforboxes: array[1..100, 1..20] of Str; //Массив текста для текстовых окон
  achiveTexts: array[1..ACHIVNUMB] of Str; //Текст ачивок
  isDebugFunction: array[1..10] of bool; //Активность функций отладки
  fon: array[1..4] of pic; //Массив спрайтов для параллакса в меню 
  MagicSphere: array[1..10] of magsphere;  //Массив сфер на экране
  minigamefield: array[1..16, 1..8] of minigameempt; //Совмещенный массив спрайтов и индексов миниигры
  Blocks, minigameBlocks: array of spr;
  FieldsName, FieldsMiniGame,BlocksName: array of Str;
  alldotsofliser := new List<SpriteABC>;
//================
  MiniGameStartRotate, MiniGameStartX, MiniGameStartY, StartScreenX, StartScreenY, 
  CurScreenX, CurScreenY, ActiveItemX, ActiveItemY, activateitemID,
  BlockCount, BlockCountMini, hspd, vspd, px, py,  mousex, mousey, achivetimercounter : int;
  curspherenumb: byte;
//================
  vLeft, vRight , vShift,vclick, vSpase, vEkey, vActivateItem: bool; //Флаги клавиш
  OnFloor,  CanMove, lookl, lookr,  notmost, lstop, rstop,  sprint, reGame, enddinganim,
  isDebugOn, isMiniGameStartsDo, IsMiniGameIsFinished, newgame, istextinroomisactivaited: bool; // Флаги состояний
//================
  CurModeOfScreen: Str;
//================
  Player,alternativepayer, alternativepayer2: spr;
  mosta, LoadScreen,playbutt, infobutt, exitbutt, playbutt2, infobutt2, exitbutt2: spr;
  //---
  achiveUI, housespr, houseinsidespr,infobar: pic;
//================
  dataforsave: savefile;  
  achivetextboxmain, achivetextboxaddition: textbox;
  blackscr: RectangleABC;

var
  CurScreen: int := 1;
  listofachive := new List<int>;
  cursor := new SpriteABC(-50, -50, 'Sprites\Effects\LaserCursor.png');
  LaserPart := new spr(-80, -80, 'Sprites\Effects\LaserParticle.png');


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

procedure endingAnimation(); forward;

var
  ATimer := new timers.Timer(100, AniTimer);

var
  mapspr: spr;

procedure animation(Numb: int);

begin
//Не реализованно
end;


//Счетчик кадров
procedure FrameTimer(FrameTimer: int);
begin
 //Не реализованно
end;


//==============================Вывод далоговых окон============================
procedure TextBoxStart(x, y: int; text: Str);
var
  curcolor: Color;
begin
  if isDebugFunction[1] = false then begin
    var temp: array of Str := text.Split('&');
    text := temp[1];
    
    case StrToInt(temp[0]) of 
      1: curcolor := clLightGreen;
      2: curcolor := clRed;
      3: curcolor := clLightBlue;
      4: curcolor := clYellowGreen;
      5: curcolor := clViolet;
      6: curcolor := clSandyBrown;
      7: curcolor := clOrange;
    end;
    
    var textboxback := new spr(x, y, 'Sprites/UI/TextBoxGreen.png');
    var textboxtest := new textbox(x + 20, y + 20, 14, '', curcolor);
    
    var textik: Str := text;
    var linescount: int;
    if vRight then kup(VK_Right); 
    if vShift then  kup(VK_Shift);
    if vLeft then kup(vk_left); 
    if vSpase then  kup(VK_Space); 
    CanMove := false;
    
    for var i: int := 1 to textik.Length do
    begin
      textboxtest.Text := textboxtest.Text + textik[i];
      if (textik[i] = ' ') and (textboxtest.Text.Length div 30 > linescount) then 
          begin 
            textboxtest.Text := textboxtest.Text + #10#13; 
            Inc(linescount); 
          end;
      Sleep(10);
    end;
    
    while not vSpase do 
    begin
      Sleep(10);
    end;
    
    textboxtest.Destroy;
    textboxback.Destroy;
    
    CanMove := true;
  end;
end;


//===================Быстрый вывод сообщения===============================
procedure msg(text: str);
begin
//Не реализованно  
end;



  
//===================Ввод информации с клавы и мышки===========================
procedure mmove(mx, my, mb: int);

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
            fon[1].MoveTo(-60 + ((Window.Width div 2 - mousex)) div 80, -60 + ((Window.Height div 2 - mousey)) div 80);
            fon[2].MoveTo(-60 + ((Window.Width div 2 - mousex)) div 50, -60 + ((Window.Height div 2 - mousey)) div 50);
            fon[3].MoveTo(-60 + ((Window.Width div 2 - mousex)) div 30, -60 + ((Window.Height div 2 - mousey)) div 30);
            fon[4].MoveTo(-60 + ((Window.Width div 2 - mousex)) div 10, -60 + ((Window.Height div 2 - mousey)) div 10);
            
            LockDrawingObjects;
            if (ObjectUnderPoint(mx, my) = playbutt) or (ObjectUnderPoint(mx, my) = playbutt2) then begin
              playbutt2.Visible := true; 
            end else begin
              playbutt2.visible := false;
            end;
            UnLockDrawingObjects;
            
            if (ObjectUnderPoint(mx, my) = infobutt) or (ObjectUnderPoint(mx, my) = infobutt2) then begin
              infobutt2.Visible := true; 
            end else begin
              infobutt2.visible := false;
            end;
            
            if (ObjectUnderPoint(mx, my) = exitbutt) or (ObjectUnderPoint(mx, my) = exitbutt2) then begin
              exitbutt2.Visible := true; 
            end else begin
              exitbutt2.visible := false;
            end;
            end
        except; end;
  
  
  end; end;
end;




procedure mdown(mx, my, mb: int);
begin
  case CurModeOfScreen of 
    'Game':
      begin
              end;
    'Menu': 
      begin
        if ObjectUnderPoint(mx, my) = playbutt2 then begin vclick := true; curmodeofscreen := 'Game'; end;
        if ObjectUnderPoint(mx, my) = infobutt2 then begin infobar := new spr(0, 0, 'Sprites\Backround\info.png'); Sleep(10000); infobar.destroy;  end;
        if ObjectUnderPoint(mx, my) = exitbutt2 then begin vclick := true; Window.Close; end;
        end;
    'MiniGame': 
      begin
        minigamePlateRotate(((mx - nilxpos) div 64) + 1, ((my - nilypos) div 64) + 1);
      end;
  end; 
end;


procedure kup(key: int);
begin
  case CurModeOfScreen of
    'Game':
      begin
        case key of
          VK_Left: 
              begin 
              vLeft := false; 
              if not CanMove then exit; 
              hspd := 0; 
              if OnFloor then Player.State := 5 else Player.State := 6; 
              if vRight then begin lookr := true; end; 
              end;
          VK_Right: 
              begin 
              vRight := false; 
              if not CanMove then exit; 
              hspd := 0;  
              if OnFloor then Player.State := 2 else Player.State := 3; 
              if vleft then begin lookl := true; end; 
              end;
          VK_Space: begin vSpase := false; end;
          VK_ShiftKey: 
              begin 
              vShift := false;  
              sprint := false; 
              hspd := hspd div 2; 
              ATimer.Interval := 100; 
              end;
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
        end; 
      end;
  
  end; 
end;

procedure kdown(key: int);

begin
  case CurModeOfScreen of 
    'Game':
      begin
      try
        if not enddinganim then 
        begin
        var plxl, plxr, plyu, plyd: int;
        
        plxl := Player.Position.X - hforce; plxl := (plxl - (plxl mod 64)) div 64;  
        plyu := Player.Position.Y + Player.Height - 5; plyu := (plyu - (plyu mod 64)) div 64;  
        plxr := Player.Position.X + Player.Width + hforce; plxr := (plxr - (plxr mod 64)) div 64;
        plyd := Player.Position.Y + Player.Height - 5; plyd := (plyd - (plyd mod 64)) div 64;
        
        if ((vLeft) and (vRight)) then exit;
        case key of
          VK_Left:
            begin
              if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) or not CanMove then exit;
              if not lstop and (Fields[plxl, plyd, 1] = 0) then 
              begin
                if vRight then begin kup(VK_Right); exit; end;
                vLeft := true;
                if not lookl then 
                  begin LookL := true; lookr := false; end;
                if canmove then 
                    begin 
                      if OnFloor then 
                        Player.State := 4 else Player.State := 6; 
                    end; 
              hspd := -hforce;
              end 
              else begin exit; end; 
            end;
          VK_Right:
            begin
              if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) or not CanMove then exit;     
              if not rstop and (Fields[plxr, plyd, 1] = 0) then 
              begin
                if vLeft then begin kup(VK_Left); exit; end;
                vRight := true; 
                if not LookR  then begin LookR := true; LookL := false; end;
                if canmove then 
                  begin   
                    if OnFloor then Player.State := 1 else Player.State := 3; end; 
                  hspd := hforce; end else begin exit;  
              end; 
            end;
          VK_Space: 
              begin 
                    try
                    vSpase := true;
                    if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) or not CanMove then exit;   
                    if not CanMove then exit; 
                    if canmove and OnFloor then 
                    begin 
                    vspd := vforce;
                    if LookR then begin if not vRight then Player.State := 3; end 
                        else begin if not vLeft then Player.State := 6; end; 
                    end;
                    except;
                    end;
              end;
          VK_ShiftKey: 
              begin vShift := true; 
                if (vLeft xor vRight) and CanMove and not sprint then 
                    begin 
                    sprint := true; 
                    hspd := hspd * 2; 
                    ATimer.Interval := 50;  
                    end; 
              end;
          VK_E: 
            begin
              vEkey := true; 
              
              if vActivateItem  then 
              begin
            if (achivetimercounter = 0) then 
              begin
                if (CurScreen <> 49) then 
                begin
                LockDrawingObjects;
                  undrawfield();
                  Player.Destroy;
                  vEkey := false;
                  CurModeOfScreen := 'MiniGame';
                  exit;
                end else 
                begin
                  LockDrawingObjects;
                  CanMove := false;
                  OnFloor := true;
                  Player.State := 2;
                  undrawfield();
                  housespr.Destroy;
                  
                end;
              end 
             else
            begin
                  
                  LockDrawingObjects;
                  
                  achivetimercounter := 0;
                  achivetextboxaddition.Destroy;
                  achivetextboxmain.Destroy;
                  achiveUI.Destroy;
                  dataforsave.achivecompited[listofachive[0]] := true;
                  listofachive.RemoveAt(0);
                  LockDrawingObjects;
                  undrawfield();
                  Player.Destroy;
                  vEkey := false;
                  CurModeOfScreen := 'MiniGame';
                  exit;
            end;
              end;
              end;
          VK_M: 
            begin
              mapspr.ToFront; 
              
              for var i := -7 to 0 do  mapspr.MoveTo(0, i * 100 + 8); 
              
              Sleep(4000);
              for var I := 0 downto -7 do mapspr.MoveTo(0, I * 100 - 8);
            end;
          VK_F1: if isDebugOn then begin if isDebugFunction[1] then isDebugFunction[1] := false else isDebugFunction[1] := true; end;
          VK_F2: if isDebugOn then savein;
        else 
        end; 
       end else
       begin
      if key = VK_Space then vSpase := true;
      end;
      except;
      end;
      end;
      
    'Menu':
      begin
        case key of
          Vk_Space: 
            begin 
              vSpase := true; 
              vclick := true; 
              CurModeOfScreen := 'Game';  
              end;
          VK_F1: if isDebugOn then isDebugFunction[1] := true; 
        end; 
      end;
    'MiniGame': 
      begin
        case key of
          vk_space: begin vSpase := true end;
        end;
      end;
  end;
end;

procedure endingAnimation();
begin
enddinganim := true;
OnKeyDown := FrameTimer;
  OnKeyUp := FrameTimer;
CanMove := false;
  Window.Fill('Sprites\Backround\HouseBack.png');
  houseinsidespr := new pic(6 * 64, 7 * 64 - 122, 'Sprites\Blocks\House.inside.png');
  houseinsidespr.ToBack;
  
  for var i := 6 to 15 do Fields[i, 7, 1] := 1;
  
  alternativepayer2 := new spr(12 * 64, 6 * 64 + 8, 54, 'Sprites\Player\Player_Sheets_Alternative2.png');
  alternativepayer2.AddState('RunR', 5); alternativepayer2.AddState('IdleR', 5); alternativepayer2.AddState('JumpR', 4);
  alternativepayer2.AddState('RunL', 5); alternativepayer2.AddState('IdleL', 5); alternativepayer2.AddState('JumpL', 4);
  alternativepayer2.State := 2;
  alternativepayer2.Active := false;
  
  AniTimer();
  UnLockDrawingObjects;
  Sleep(2000);
  OnKeyDown := kdown;
  OnKeyUp := kup;
  
  alternativepayer2.State := 5;
  Sleep(1000);
  CanMove := true;
  OnKeyDown := kdown;
  OnKeyUp := kup;
  if not reGame then
  begin
  
  TextBoxStart(600, 200, '4&Приветствую тебя, путник, не хочешь остановиться в моей гостинице?');
  TextBoxStart(300, 200, '1&Я бы с радостью, но сейчас я ищу своего друга');
  TextBoxStart(300, 200, '1&Мы решили отдохнуть перед подьемом на Элестию, но по пути к вам в гостиницу я упал с моста');
  TextBoxStart(600, 200, '4&Охохо! Так это вы!');
  TextBoxStart(600, 200, '4&Ваш друг приходил сюда вчера, он взял сняряжение и отправился искать вас');
  end else
  begin
  TextBoxStart(600, 200, '4&Охохо! Это снова вы! Приключилось чего?');
  TextBoxStart(300, 200, '1&Да уж... Приключилось');
  
  end;
  TextBoxStart(400, 200, '3&*Тук-тук*');
  TextBoxStart(300, 200, '1&...');
  CanMove := false;
  OnKeyDown := FrameTimer;
  OnKeyUp := FrameTimer;
  
  Player.State := 1;
  
  for var i := 0 to 30 do begin Player.MoveOn(4, 0); Sleep(30); end;
  
  Player.State := 2;
  
  Sleep(300);
  
  Player.State := 5;
  
  OnKeyDown := kdown;
  OnKeyUp := kup;
  //CanMove := true;
  TextBoxStart(400, 200, '3&*Тук-тук*');
  TextBoxStart(600, 200, '4&Входите!');
  CanMove := false;
  OnKeyDown := FrameTimer; OnKeyUp := FrameTimer;
  alternativepayer := new spr(8 * 64 + 32, 6 * 64 + 8, 54, 'Sprites\Player\Player_Sheets_Alternative.png');
  alternativepayer.AddState('RunR', 5); alternativepayer.AddState('IdleR', 5); alternativepayer.AddState('JumpR', 4);
  alternativepayer.AddState('RunL', 5); alternativepayer.AddState('IdleL', 5); alternativepayer.AddState('JumpL', 4);
  alternativepayer.State := 2;
  alternativepayer.Active := false;
  
  Sleep(1000);
  OnKeyDown := kdown; OnKeyUp := kup;
  //CanMove := true;
  if not reGame then begin
  TextBoxStart(400, 200, '2&...!');
  TextBoxStart(400, 200, '2&Ты все-таки выжил!');
  TextBoxStart(500, 200, '1&Да... Мне очень повезло с приземлением');
  CanMove := false;
  
  OnKeyDown := FrameTimer; OnKeyUp := FrameTimer;
  
  Sleep(1000);
  OnKeyDown := kdown; OnKeyUp := kup;
  TextBoxStart(500, 200, '1&Есть столько всего, что я бы хотел тебе рассказать и...');
  TextBoxStart(500, 200, '1&Кстати, почему ко мне никто не пришел на помощь? Я лежал без сознания до полуночи');
  TextBoxStart(400, 200, '2&Спуск к тому месту очень крутой, потребывалось вызывать специалистов, что бы мы смогли спуститься к тебе');
  TextBoxStart(400, 200, '2&Пока они добрались, уже стемнело, а когда мы спустились, тебя там уже небыло');
  TextBoxStart(400, 200, '2&Тем не менее, мне предоставили доступ к состоянию "магических шаров" в реальном времени');
  TextBoxStart(400, 200, '2&Так что я мог следить за тем, в порядке ли ты, и где тебя искать');
  TextBoxStart(400, 200, '2&По ним я узнал, куда ты направляешься, а так же судя по информации о сферах......');
  OnKeyDown := FrameTimer; OnKeyUp := FrameTimer;
  Sleep(2000);
  OnKeyDown := kdown; OnKeyUp := kup;
  end else
  begin
  TextBoxStart(500, 200, '1&Привет...');
  TextBoxStart(400, 200, '2&Как обычно? Судя по информции о сферах...');
  end;
  var actShereCount: int;
  for var i := 1 to 15 do if dataforsave.magicsphereaktive[i] then Inc(actShereCount);
  if actShereCount = 1 then begin TextBoxStart(400, 200, '2&Ты действительно не любишь эти штуки, да? Ты дотронулся только до одного'); listofachive.Add(19); end;
  if (actShereCount = 2) and (dataforsave.magicsphereaktive[15]) then begin TextBoxStart(400, 200, '2&Ты действительно не любишь эти штуки, да? Ты активировал только необходимые'); listofachive.Add(18); end;
  if (actShereCount > 2) and (actShereCount < 7) then begin TextBoxStart(400, 200, '2&Ты не особо увлекался прохождением этих головоломок, видимо задача "выбраться отсюда" стояла выше'); listofachive.Add(17); end;
  if (actShereCount >= 7) and (actShereCount < 12) then begin TextBoxStart(400, 200, '2&Тебе действительно нравилось активировать эти шары, не правда ли? '); listofachive.Add(16); end;
  if (actShereCount >= 12) and (actShereCount < 14) then begin TextBoxStart(400, 200, '2&Хмм, ты активировал почти все шары на своем пути, видимо это довольно весело, не правда ли?'); listofachive.Add(15); end;
  if actShereCount = 14 then begin TextBoxStart(400, 200, '2&Вау!'); TextBoxStart(400, 200, '2&Ты активировал буквально каждый шар по пути!'); listofachive.Add(20); end;
  OnKeyDown := FrameTimer; OnKeyUp := FrameTimer;
  Sleep(1000);
  if not reGame then
  begin
  OnKeyDown := kdown; OnKeyUp := kup;
  TextBoxStart(400, 200, '2&Сейчас раннее утро и мы совсем рядом с Элестией, не хочешь подняться?');
  TextBoxStart(500, 200, '1&Серьзено? После такой-то ночи ты еще хочешь на гору?');
  TextBoxStart(500, 200, '1&Сколько нам до нее идти хотя бы?');
  CanMove := false;
  Sleep(500);
  
  Player.State := 2;
  
  Sleep(500);
  TextBoxStart(600, 200, '4&До вершины рукой подать, нужно всего лишь пройти налево, затем перейти по мосту, а там уже-');
  TextBoxStart(500, 200, '1&По мосту, серьезно? Очень смешно.');
  TextBoxStart(500, 200, '1&Ладно, вы как хотите, а я спать');
  
  Player.State := 5;
  
  TextBoxStart(400, 200, '2&Здравая мысль');
  
  Player.State := 2;
  
  TextBoxStart(600, 200, '4&В таком случае можете расположиться у меня в гостинице, как раз осталось 2 свободных номера');
  TextBoxStart(500, 200, '1&Наконец-то можно отдохнуть');
  end;
  CanMove := false;
  OnKeyDown := FrameTimer; OnKeyUp := FrameTimer;
  Sleep(500);
  OnKeyDown := kdown; OnKeyUp := kup;
  TextBoxStart(400, 200, '2&На боковую?');
  TextBoxStart(500, 200, '1&На боковую');
  
  listofachive.Add(5);
  
  var blrect := new RectangleABC(0, 0, window.Width, window.Height, clblack);
  
  
  CanMove := false;
end;




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
  FieldFile, FieldLocationFile, FileT: Text;
  Line: Str;
  i, j: int;

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
  
  
  Assign(FileT, 'Assets\Dialog.list');
  Reset(FileT);
  i := 1;
  repeat
    Readln(FileT, Line);
    if Line = '' then break;
    var temp: array of Str := Line.Split(';');
    for j := 0 to temp.Length - 1 do
      textforboxes[i, j + 1] := temp[j];  
    Inc(i);
  until Line = 'End.';
  Close(FileT);
  
  
  
  Assign(FileT, 'Assets\AchievementText.list');
  Reset(FileT);
  i := 1;
  
  while (Line <> 'End.') do 
  begin
    Readln(FileT, Line);
    if Line = '' then break;
    achiveTexts[i] := Line;
    Inc(i);
  end;
  Close(FileT);
  
  if (FileExists('YesThisIsThe.End')) then reGame := true;
  
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
begin
  Assign(Fieldfile, Path); //Загрузка информации о обьектах из заданного экрана в память
  Reset(Fieldfile);
  for var ij := 1 to 5 do
    for var i := 0 to 10 do
    begin
      Readln(Fieldfile, Line);
      var blkInfo: array of Str := Line.Split(';');
      SetLength(blkInfo, 21);
      for var j := 0 to 20 do
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
begin
  
  Assign(Fieldfile, Path); //Загрузка информации о обьектах из заданного экрана в память
  Reset(Fieldfile);
  for var i := 1 to 8 do
  begin
 
 Readln(Fieldfile, Line);
    var blkInfo: array of Str := Line.Split(';');
    SetLength(blkInfo, 17);
    for var j := 1 to 16 do
    begin
      if blkInfo[j - 1] <> '0' then begin
        if (StrToInt(blkInfo[j - 1]) <= 4) and (StrToInt(blkInfo[j - 1]) >= 1) then 
        begin
          minigameField[j, i].typeofobgect := 'plate'; 
          minigameField[j, i].rotate := StrToInt(blkInfo[j - 1]);
        end;
        if (StrToInt(blkInfo[j - 1]) <= 12) and (StrToInt(blkInfo[j - 1]) >= 9) then begin
          minigameField[j, i].typeofobgect := 'start';
          minigameField[j, i].rotate := StrToInt(blkInfo[j - 1]) - 8;
          MiniGameStartX := j; 
          MiniGameStartY := i; 
          MiniGameStartRotate := minigameField[j, i].rotate;
        end;
        if StrToInt(blkInfo[j - 1]) = 13 then   
              minigameField[j, i].typeofobgect := 'finish';
              
        minigameField[j, i].empty := true;
        minigameField[j, i].numerofsprite := StrToInt(blkInfo[j - 1]); 
      end;
    end;
  end;
  
end;

//=================Выгруз определенного экрана====================
procedure unloadscreenfrombuffer(curscreen: int);  
begin  
  for var ij := 1 to 5 do
    for var i := 0 to 10 do
    begin 
      for var j := 0 to 20 do
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

begin
  for var i := 1 to 10 do MagicSphere[i].curID := 0;
  curspherenumb := 0;
  for  layer := 1 to 5 do 
    for var i := 0 to 10 do 
      for var j := 0 to 20 do
      begin
        if (Fields[j, i, layer] <> 0)  and (Fields[j, i, layer] <> 56) then
        begin
          Inc(BlockCount);
          Inc(CounterOfBlocksL[layer]);
          if (layer = 5) then 
          begin
            if (CurScreen <> 49) then 
              begin
              Inc(curspherenumb);
              MagicSphere[curspherenumb].CurID := Fields[j, i, layer];
              
              if dataforsave.magicsphereaktive[Fields[j, i, layer]]  then 
                begin
                Fields[j, i, layer] := 55;
                
                end else 
                begin
                MagicSphere[curspherenumb].LocationOfScreen.x := j;
                MagicSphere[curspherenumb].LocationOfScreen.y := i;
                Fields[j, i, layer] := 54;
              end; 
            end else 
            begin
              Fields[j, i, layer] := 58;
            end;
          end;
          
          if (Fields[j, i, layer] = 54) or (Fields[j, i, layer] = 55) then 
          begin
            MagicSphere[curspherenumb].Spritesphere  := new spr(j * 64, I * 64, BlocksName[Fields[j, i, layer]]);
            if not istextinroomisactivaited then istextinroomisactivaited := true;
            BlocksOfField[CounterOfBlocksL[layer], layer] := Blocks[Fields[j, i, layer]].Clone;
          end else 
          begin
            if (Fields[j, i, layer] <> 0) then 
              begin
              BlocksOfField[CounterOfBlocksL[layer], layer] :=
              new spr(j * 64, I * 64, BlocksName[Fields[j, i, layer]]);
              if layer = 3 then 
                BlocksOfField[CounterOfBlocksL[layer], layer].ToBack; end;
          end;
        end;
      end; 
  if (curspherenumb > 0) then begin   
    for var i := 0 to 10 do
      for var j := 0 to 20 do
      begin
        if (dataforsave.magicsphereaktive[MagicSphere[curspherenumb].curID]) then 
        begin
          if  (Fields[j, i, 1] = 56) then 
          begin
            Fields[j, i, 2] := 57; Fields[j, i, 1] := 0;   
            Inc(CounterOfBlocksL[2]); 
            BlocksOfField[CounterOfBlocksL[2], 2] := 
            new spr(j * 64, I * 64, BlocksName[57]);
          end;
        end 
          else
        begin  
          if  (Fields[j, i, 1] = 56) then 
          begin
            Inc(CounterOfBlocksL[1]); 
            Inc(BlockCount);
            BlocksOfField[CounterOfBlocksL[1], 1] := 
            new spr(j * 64, I * 64, BlocksName[56]);
            BlocksOfField[CounterOfBlocksL[1], 1].ToFront;
          end;
        end;     
      end;
  end;
  if curspherenumb = -1 then curspherenumb := 0;
  
  if (achivetimercounter <> 0) then 
    begin
    achiveUI.ToFront; 
    achivetextboxmain.ToFront; 
    achivetextboxaddition.ToFront;
    end;
end;

//=================Выгрузка поля=========================
procedure undrawfield();
begin
  for var j := 1 to 5 do 
  begin
    for var i := 1 to CounterOfBlocksL[j]   do 
    begin
      BlocksOfField[i, j].Destroy;  
    end;
    CounterOfBlocksL[j] := 0;
   end;
  
  for var i := 1 to curspherenumb do MagicSphere[i].Spritesphere.Destroy;
  BlockCount := 0;
  unloadscreenfrombuffer(CurScreen);
  
end;
//===================Таймер отвечающий за анимацию персоонажа===================
procedure AniTimer();
begin
  if Player.Frame < 5 then Player.Frame := Player.Frame + 1;
  if Player.Frame  = 5 then Player.Frame := 1;
  if alternativepayer <> nil then begin
    if alternativepayer.Frame < 5 then alternativepayer.Frame := Player.Frame + 1;
    if alternativepayer.Frame  >= 5 then alternativepayer.Frame := 1; end;
  if alternativepayer2 <> nil then begin
    if alternativepayer2.Frame < 5 then alternativepayer2.Frame := Player.Frame + 1;
    if alternativepayer2.Frame  >= 5 then alternativepayer2.Frame := 1; end;
end;






//==============Отрисовка лазера в мини-игре=============================================




procedure partlaserdraw(xf, yf, rotate, otordo: int);
var
   xnul, ynul, step, sleeptime, xnulsum, ynulsum, otstx, otsty, squaresize: int;
  begin
  
  step := 2; 
  sleeptime := 1;  
  squaresize := 6; 
  otstx := nilxpos - 64 - squaresize div 2; 
  otsty := nilypos - 64 - squaresize div 2;
  
  if (rotate = 2) or (rotate = 4) then 
    begin 
      xnul := 1; ynulsum := 32; 
    end   
      else 
    begin 
      ynul := 1; xnulsum := 32; 
    end;
  
  SetBrushColor(clRed); 
  SetPenColor(clRed);
  
  if otordo = 0 then 
  begin
    if (rotate = 2) or (rotate = 3) then 
    begin
      for var i := 1 to 16 div (step * 2) do
      begin
        cursor.MoveTo(otstx + xf * 64 + 4 * step * i * xnul + xnulsum - squaresize div 2, otsty + yf * 64 + 4 * step * i * ynul + ynulsum - squaresize div 2);
        alldotsofliser.Add(LaserPart.Clone);
        alldotsofliser.Item[alldotsofliser.Count - 1].moveto(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum);
        Sleep(sleeptime);  
      end; 
    end else 
    begin
      for var i := 16 div step downto 16 div (step * 2) do
      begin
        cursor.MoveTo(otstx + xf * 64 + 4 * step * i * xnul + xnulsum - squaresize div 2, otsty + yf * 64 + 4 * step * i * ynul + ynulsum - squaresize div 2);
        alldotsofliser.Add(LaserPart.Clone);
        alldotsofliser.Item[alldotsofliser.Count - 1].moveto(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum);
        Sleep(sleeptime);
      end;
    end; 
   end  else
    begin
    if (rotate = 2) or (rotate = 3) then 
    begin
      for var i := 16 div (step * 2) to 16 div (step) do
      begin
        cursor.MoveTo(otstx + xf * 64 + 4 * step * i * xnul + xnulsum - squaresize div 2, otsty + yf * 64 + 4 * step * i * ynul + ynulsum - squaresize div 2);
        alldotsofliser.Add(LaserPart.Clone);
        alldotsofliser.Item[alldotsofliser.Count - 1].moveto(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum);
        Sleep(sleeptime);
      end; end else 
    begin
      for var i := 16 div (step * 2) downto 1 div (step * 2) do
      begin
        cursor.MoveTo(otstx + xf * 64 + 4 * step * i * xnul + xnulsum - squaresize div 2, otsty + yf * 64 + 4 * step * i * ynul + ynulsum - squaresize div 2);
        alldotsofliser.Add(LaserPart.Clone);
        alldotsofliser.Item[alldotsofliser.Count - 1].moveto(otstx + xf * 64 + 4 * step * i * xnul + xnulsum, otsty + yf * 64 + 4 * step * i * ynul + ynulsum);
        Sleep(sleeptime);
      end; 
    end; 
end;
  
  SetBrushColor(clwhite); SetPenColor(clwhite);
  cursor.ToFront;
  
end;

procedure changePlate(sx, sy, delornew: int);
begin
  if delornew = 1 then 
  begin
    LockDrawingObjects; 
    minigamefield[sx, sy].objectspr.Destroy; 
    minigamefield[sx, sy].objectspr := minigameBlocks[minigamefield[sx, sy].rotate - 1 + 4].Clone;
    minigamefield[sx, sy].objectspr.MoveTo(nilxpos + sx * 64 - 64, nilypos + sy * 64 - 64); 
    minigamefield[sx, sy].objectspr.Visible := true; 
    unlockDrawingObjects;
  end else 
  begin
    LockDrawingObjects; minigamefield[sx, sy].objectspr.Destroy; 
    minigamefield[sx, sy].objectspr := minigameBlocks[minigamefield[sx, sy].rotate - 1 + 4].Clone;
    minigamefield[sx, sy].objectspr.MoveTo(nilxpos + sx * 64 - 64, nilypos + sy * 64 - 64); 
    minigamefield[sx, sy].objectspr.Visible := true; 
    unlockDrawingObjects;
  end;
end;



function questrotating(sx, sy, currotation: int): int;
begin
  case minigamefield[sx, sy].typeofobgect of 
    '': begin questrotating := currotation; end;
    'plate':
      begin
        questrotating := -1;
        case minigamefield[sx, sy].rotate of
          1:
            begin
              case currotation of 
                3: begin 
                      partlaserdraw(sx, sy, 3, 0);  
                      changePlate(sx, sy, 1);  
                      partlaserdraw(sx, sy, 2, 1); 
                      changePlate(sx, sy, 1); 
                      questrotating := 2; 
                   end;
                4: begin 
                      partlaserdraw(sx, sy, 4, 0);  
                      changePlate(sx, sy, 1); 
                      partlaserdraw(sx, sy, 1, 1); 
                      changePlate(sx, sy, 1); 
                      questrotating := 1; 
                   end;
              end;
            end;
          2:
            begin
              case currotation of 
                1: begin 
                      partlaserdraw(sx, sy, 1, 0); 
                      changePlate(sx, sy, 1); 
                      partlaserdraw(sx, sy, 2, 1);  
                      changePlate(sx, sy, 1); 
                      questrotating := 2; 
                   end;
                4: begin  
                      partlaserdraw(sx, sy, 4, 0); 
                      changePlate(sx, sy, 1); 
                      partlaserdraw(sx, sy, 3, 1); 
                      changePlate(sx, sy, 1); 
                      questrotating := 3; 
                   end;
              end; 
            end;
          3:
            begin
              case currotation of 
                1: begin 
                      partlaserdraw(sx, sy, 1, 0); 
                      changePlate(sx, sy, 1); 
                      partlaserdraw(sx, sy, 4, 1); 
                      changePlate(sx, sy, 1);  
                      questrotating := 4; 
                   end;
                2: begin 
                      partlaserdraw(sx, sy, 2, 0); 
                      changePlate(sx, sy, 1); 
                      partlaserdraw(sx, sy, 3, 1);  
                      changePlate(sx, sy, 1); 
                      questrotating := 3; 
                   end;
              end; 
            end;
          4:
            begin
              case currotation of 
                2: begin 
                      partlaserdraw(sx, sy, 2, 0); 
                      changePlate(sx, sy, 1); 
                      partlaserdraw(sx, sy, 1, 1); 
                      changePlate(sx, sy, 1); 
                      questrotating := 1; 
                   end;
                3: begin 
                      partlaserdraw(sx, sy, 3, 0); 
                      changePlate(sx, sy, 1);  
                      partlaserdraw(sx, sy, 4, 1); 
                      changePlate(sx, sy, 1); 
                      questrotating := 4; 
                   end;
              end; 
            end;
        end; 
      end;
  
  end; 
end;



//==========================Анимация финиша и завершение уровня=============
procedure finishanimation(xfin, yfin, rotation: int);
begin
  partlaserdraw(xfin, yfin, rotation, 0);
  minigamefield[xfin, yfin].objectspr.Destroy;
  
  var finishanim := new SpriteABC(nilxpos + xfin * 64 - 64, nilypos + yfin * 64 - 64, 64, 'Sprites\Blocks\Mng.Finish.Aktive.png');
 finishanim.NextFrame;
 for var i := 1 to 3 do
 begin
 Sleep(100);
  finishanim.NextFrame;
 end;
 
 Sleep(1000);
 
 TextBoxStart(Window.Width div 2 - 200, Window.Height div 2 - 150, '1&Вы успешно прошли этот шар!');
   finishanim.Destroy;
  cursor.MoveTo(-8, -8);
  
  IsMiniGameIsFinished := true;
end;

procedure mostanim();
begin  
        var  st: int;
        Player.MoveTo(Player.Position.X, 6 * 64 + 8);   
        st := Player.State;
        rstop := true;
        lstop := true;
        Player.State := 2;
        mosta.State := 1;
        for var j := 1 to 2 do 
          for var i := 1 to 3 do 
          begin
            mosta.Frame := I; 
            if i = 2 then Player.MoveOn(0, 4);
            if i = 3 then Player.MoveOn(0, -4);
            Sleep(200);
          end; 
        TextBoxStart(Window.Width div 2 - 200, Window.Height - 200, '1&О нет!');
        for var i := 1 to 3 do 
        begin
          mosta.Frame := I; 
          if i = 2 then Player.MoveOn(0, 4);
          if i = 3 then Player.MoveOn(0, -4);
          Sleep(200);
        end; 
        mosta.State := 2;
        for var i := 1 to 2 do 
        begin
          mosta.Frame := I; Sleep(200);
        end;
        Fields[13, 7, 1] := 0; Fields[12, 7, 1] := 0;
        notmost := true;
        Player.State := st;
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
          if (sy > 1) then 
          begin
            var rot: int := questrotating(sx, sy - 1, currotate);
            if (minigamefield[sx, sy - 1].empty  <> false) and (rot = -1) then exit; 
            currotate := rot;
            if minigamefield[sx, sy - 1].empty  = false then 
                begin 
                partlaserdraw(sx, sy - 1, 1, 0); 
                partlaserdraw(sx, sy - 1, 1, 1); 
                end;
            Dec(sy); 
            if (sy > 1) then 
              begin
              if minigamefield[sx, sy - 1].typeofobgect  = 'finish' then 
              begin
                finishanimation(sx, sy - 1, currotate);
                stop := false; 
              end;
            end; 
          end
          else stop := false;
        
        2: 
          if (sx < 16) then 
          begin
            var rot: int := questrotating(sx + 1, sy, currotate);
            if (minigamefield[sx + 1, sy].empty  <> false) and (rot = -1) then exit; 
            currotate := rot;
            
            if minigamefield[sx + 1, sy].empty  = false then 
            begin 
              partlaserdraw(sx + 1, sy, 2, 0); 
              partlaserdraw(sx + 1, sy, 2, 1);
            end;
            Inc(sx); 
            if (sx < 16) then begin
              if minigamefield[sx + 1, sy].typeofobgect  = 'finish' then 
                begin 
                  stop := false; 
                  finishanimation(sx + 1, sy, currotate); 
                end;
              
            end; 
          end
          
          else stop := false;
        
        3: 
          if (sy < 8) then begin
            var rot: int := questrotating(sx, sy + 1, currotate);
            if (minigamefield[sx, sy + 1].empty  <> false) and (rot = -1) then exit; 
            currotate := rot;
           
            if minigamefield[sx, sy + 1].empty  = false then 
              begin 
                partlaserdraw(sx, sy + 1, 3, 0); 
                partlaserdraw(sx, sy + 1, 3, 1); 
            end;
            
            Inc(sy); 
            
            if (sy < 8) then begin
              if minigamefield[sx, sy + 1].typeofobgect  = 'finish' then 
                begin 
                  stop := false; 
                  finishanimation(sx, sy + 1, currotate); 
                end;
            end; 
          end
          
          else stop := false;
        4: 
          if (sx > 1) then begin
            var rot: int := questrotating(sx - 1, sy, currotate);
            if (minigamefield[sx - 1, sy].empty  <> false) and (rot = -1) then exit; 
            currotate := rot;
            if minigamefield[sx - 1, sy].empty  = false then 
              begin 
                partlaserdraw(sx - 1, sy, 4, 0); 
                partlaserdraw(sx - 1, sy, 4, 1); 
              end;
            Dec(sx);
            if (sx > 1) then 
            begin
              if minigamefield[sx - 1, sy].typeofobgect  = 'finish' then 
              begin
                finishanimation(sx - 1, sy, currotate); 
                Stop := false; 
              end;
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



procedure fallinganim();
begin
   blackscr := new RectangleABC(0, 0, Window.Width, Window.Height, clblack);
               Sleep(2000);
              TextBoxStart(Window.Width div 2 - 200, Window.Height - 200, '1&Черт...');
              Sleep(1000);
              if not reGame then
              begin
              TextBoxStart(Window.Width div 2 - 200, Window.Height - 200, '1&Повезло остаться в живых... Ух...');
              Sleep(1000);
              TextBoxStart(Window.Width div 2 - 200, Window.Height - 200, '1&Я упал с моста? Он сломался?');
              TextBoxStart(Window.Width div 2 - 200, Window.Height - 200, '1&Видимо, я упал на кучу листьев, которые смягчили мне падение');
              Sleep(500);
              
              TextBoxStart(Window.Width div 2 - 200, Window.Height - 200, '1&Я провалялся тут слишком долго');
              
              
              Window.Fill('sprites\Backround\nightsky3.png');
              blackscr.Destroy;
              Sleep(500);
              
              TextBoxStart(Window.Width div 2 - 200, Window.Height - 200, '1&Уже вечер');
              Sleep(500);
              TextBoxStart(Window.Width div 2 - 200, Window.Height - 200, '1&Видимо друг пошел до гостиницы, почему никто не пришел помочь мне от туда?');
              TextBoxStart(Window.Width div 2 - 200, Window.Height - 200, '1&Нужно осмотреться вокруг, возможно я найду способ подняться обратно');
              end 
              else
              begin
              TextBoxStart(Window.Width div 2 - 200, Window.Height - 200, '1&И вот я снова здесь...');
              
              
              Window.Fill('sprites\Backround\nightsky3.png');
              blackscr.Destroy;
              Sleep(500);
              end;
              listofachive.Add(1);
              Sleep(1000);
              rstop := false;
              lstop := false;
              newgame := false;
              savein;
            
end;




//================================Проверка и кориктировка движений игрока===========================
procedure moveTest();
var
  debugstring: Str;
begin
  if isDebugOn then 
  begin
    for var i := 1 to 1 do 
      if isDebugFunction[i] then 
          debugstring := debugstring + 'debug ' + i + ': On' + NewLine 
              else 
          debugstring := debugstring + 'debug ' + i + ': Off' + NewLine;
    var col: Color = Brush.Color;
    Brush.Color := clWhite;
    TextOut(0, 0, debugstring);
    Brush.Color := col; 
  end;
  
  if (0  >= px  + hspd) then 
      begin 
        if CurScreen = 6 then 
            begin kup(VK_Left); exit; end; 
        LockDrawingObjects; 
        if CurScreen = 49 then 
          begin housespr.Destroy; end; 
        undrawfield(); 
        if (CurScreenX = 1) then 
            begin 
              CurScreenX := StartScreenX; 
              CurScreenY := StartScreenY;
              listofachive.Add(2);
            end 
              else  
              Dec(CurScreenX); 
         CurScreen := LocationOfFields[CurScreenx, CurScreenY]; 
         if CurScreen = 0 then 
                  loadscreenfrombuffer('Fields\Main\level0.map') 
                      else 
                  loadscreenfrombuffer(FieldsName[CurScreen - 1]); 
         drawfield(1, CurScreen);  
         Player.Moveto(window.Width - 70, py); 
          if (CurScreen = 52) and (dataforsave.curTime = 1) then
          begin
            dataforsave.curTime := 2;
            window.Fill('Sprites\Backround\MoringSky.png');
          end;
          if CurScreen = 30 then
            begin
              listofachive.Add(7);
              
            end;
        
         UnLockDrawingObjects;
      end;
  
  
  if (px + Player.Width - 10 + hspd >= Window.Width) then 
  begin  
    LockDrawingObjects;
    undrawfield(); 
    if (CurScreenX = 16) then 
      begin 
        CurScreenX := StartScreenX; 
        CurScreenY := StartScreenY;
        listofachive.Add(2);
      end 
        else 
        Inc(CurScreenX);
    CurScreen := LocationOfFields[CurScreenx, CurScreenY];
    if (CurScreen = 0)  then 
        loadscreenfrombuffer('Fields\Main\level0.map') 
          else 
        loadscreenfrombuffer(FieldsName[CurScreen - 1]);
    if (CurScreen = 49) then  
        begin 
        housespr := new pic(400 - 40, 7 * 64 - 200, 'Sprites\Blocks\House.outside.png'); 
        housespr.ToBack;
        end;
    drawfield(1, CurScreen);  
    Player.Moveto(8, py); 
    UnLockDrawingObjects; 
    end;
    
  if (0  >= py - vspd) then 
    begin 
      LockDrawingObjects; 
      undrawfield(); 
      
      if (CurScreen = 12) then listofachive.Add(3);   
      if (CurScreenY = 1) then 
        begin 
          CurScreenX := StartScreenX; 
          CurScreenY := StartScreenY;
          listofachive.Add(2);
        end 
          else Dec(CurScreenY);
       CurScreen := LocationOfFields[CurScreenx, CurScreenY]; 
       if CurScreen = 0 then 
            loadscreenfrombuffer('Fields\Main\level0.map') 
                else 
            loadscreenfrombuffer(FieldsName[CurScreen - 1]); 
       drawfield(1, CurScreen);  
       Player.Moveto(px, Window.Height - Player.Height); 
      if ((CurScreen = 51) or (CurScreen = 50))then 
        begin
        dataforsave.curTime := 3;
         window.Fill('Sprites\Backround\DaySky.png');
          
        end; 
       UnLockDrawingObjects; 
     end;
     
  if (py - vspd  >= Window.Height) then 
    begin 
      LockDrawingObjects;   
      undrawfield();  
      if (CurScreen = 52) then listofachive.Add(4); 
      if (CurScreenY = 8) then 
        begin 
          CurScreenX := StartScreenX; 
          CurScreenY := StartScreenY;
          listofachive.Add(2);
        end 
          else Inc(CurScreenY); 
      if (CurScreen = 6) and (LocationOfFields[CurScreenx, CurScreenY] = 5) then 
          begin 
            Player.Moveto(64 + 32, player.Height); 
            if isDebugFunction[1] = false then mosta.Destroy; 
          end   
            else 
            Player.Moveto(px, player.Height); 
      CurScreen := LocationOfFields[CurScreenx, CurScreenY]; 
      if CurScreen = 0 then 
        loadscreenfrombuffer('Fields\Main\level0.map') 
          else 
        loadscreenfrombuffer(FieldsName[CurScreen - 1]); 
      drawfield(1, CurScreen);  
      if (CurScreen = 1) and newgame then Window.Fill('Sprites\Backround\Pogoda3.png'); 
      if (CurScreen = 5) and newgame then Window.Fill('Sprites\Backround\Pogoda2.png'); 
      UnLockDrawingObjects;  
      end;
      
      
  if ((0  < px + hspd) and (px + hspd < Window.Width)) and ((0  < py - vspd) and (py - vspd < Window.Height)) then
  begin 
  if CanMove then 
    begin 
      if  vRight and vLeft then else  Player.moveon(hspd, -vspd) 
    end 
  end;
  
  
    //Проверка на падение 
  var plxl, plyu, plxr, plyd, plyd0, plyd1: int;
  var platform: bool;
  
  plxl := Player.Position.X + 10; plxl := (plxl - (plxl mod 64)) div 64; 
  plyu := Player.Position.Y + 20; plyu := (plyu - (plyu mod 64)) div 64; 
  plxr := Player.Position.X + Player.Width - 10; plxr := (plxr - (plxr mod 64)) div 64; 
  plyd := Player.Position.Y + Player.Height; plyd := (plyd - (plyd mod 64)) div 64;
  plyd0 := Player.Position.Y + Player.Height + 4; plyd0 := (plyd0 - (plyd0 mod 64)) div 64; 
  plyd1 := Player.Position.Y + Player.Height - 8;  plyd1 := (plyd1 - (plyd1 mod 64)) div 64; 
  
  if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) then begin exit; end else 
  begin
    //Падение с моста
    if isDebugFunction[1] = false then 
    begin
      if (((Player.Position.X - (Player.Position.X mod 64)) div 64) >= 12)  and (newgame) and not notmost then 
      mostanim
       end else begin
      Fields[13, 7, 1] := 0; Fields[12, 7, 1] := 0;
      notmost := true;
      end;
    
    
    
    if (plxl >= 0) and (plyu >= 0) and (plxr <= 20) and (plyd <= 10) then 
    begin
      for var i := 24 to 28 do 
      begin
        if (Fields[plxl, plyd, 4] = i) or (Fields[plxr, plyd, 4] = i) then 
            platform := true;
      end;
      if (Fields[plxl, plyd, 1] <> 0) or (Fields[plxr, plyd, 1] <> 0) or platform then 
       begin
        if not OnFloor then 
          if not platform then 
          begin
            OnFloor := true;
            if (CurScreen = 1) and (newgame) then 
              fallinganim;
            Player.MoveTo(Player.Position.X, Player.Position.Y - Player.Position.Y mod 64 + 8);
          end   
            else 
          begin
            if vspd < -13 then begin
              OnFloor := true;
              Player.MoveTo(Player.Position.X, Player.Position.Y - Player.Position.Y mod 64 + 8);  end;
          end;
      end 
        else  
      begin 
        if OnFloor then OnFloor := false; 
      end;
    end; 
   end;
platform := false;
  
    //Проверка на Столкновение со стенкой
      //Лево
  var mylt: int;
  if sprint then mylt := 2 else mylt := 1;
  plxl := Player.Position.X + 10 - hforce * mylt; plxl := (plxl - (plxl mod 64)) div 64; 
  plyu := Player.Position.Y + 8; plyu := (plyu - (plyu mod 64)) div 64; 
  plxr := Player.Position.X + Player.Width - 10 + hforce * mylt;   plxr := (plxr - (plxr mod 64)) div 64; 
  plyd := Player.Position.Y + Player.Height - 1; plyd := (plyd - (plyd mod 64)) div 64;
   
  
  if (plxl >= 0) and (plyu >= 0) and (plxr <= 20) and (plyd <= 10) then 
  begin
    if  vLeft and ((Fields[plxl, plyd, 1] <> 0) or (Fields[plxl, plyu, 1] <> 0)) then 
    begin
      kup(vk_left); 
      if ((Player.Position.X - (Player.Position.X mod 64)) div 64) <> plxl then  
          Player.moveon(0, Player.Position.X mod 64); 
    end;
    if vRight and ((Fields[plxr, plyd, 1] <> 0) or (Fields[plxr, plyu, 1] <> 0)) then 
      kup(vk_right);
  end; 
  
  //Столкновение с потолком
  plxl := Player.Position.X + 10; plxl := (plxl - (plxl mod 64)) div 64; 
  plyu := Player.Position.Y + 9; plyu := (plyu - (plyu mod 64)) div 64; 
  plxr := Player.Position.X + Player.Width - 10; plxr := (plxr - (plxr mod 64)) div 64; 
  plyd := Player.Position.Y + Player.Height; plyd := (plyd - (plyd mod 64)) div 64;  
     
  
  if not OnFloor and ((Fields[plxl, plyu, 1] <> 0) or (Fields[plxr, plyu, 1] <> 0)) then 
      begin 
        vspd := -vspd div 2; 
        Player.MoveTo(Player.Position.X, (plyu + 1) * 64); 
      end;
  
    //Гравитация 
  if not OnFloor then begin if vspd >= -vspdMAX then vspd := vspd - grav end else vspd := 0;
  //Взаимодействие с активируемыми предметами
  
  plxl := Player.Position.X + 10; plxl := (plxl - (plxl mod 64)) div 64;
  plyu := Player.Position.Y + 8; plyu := (plyu - (plyu mod 64)) div 64; 
  plxr := Player.Position.X + Player.Width - 10; plxr := (plxr - (plxr mod 64)) div 64; 
  plyd := Player.Position.Y + Player.Height - 1; plyd := (plyd - (plyd mod 64)) div 64;  
  
  if (curspherenumb > 0) and OnFloor and ((Fields[plxl, plyu, 5] <> 0) or (Fields[plxr, plyu, 5] <> 0)) then 
    begin
    
      if not dataforsave.magicsphereaktive[MagicSphere[curspherenumb].curID] then 
        begin
          if (Fields[plxl, plyu, 5] <> 0) then  
            begin
              activateitemID := Fields[plxl, plyu, 5];
              activeitemx := plxl; activeitemy := plyu; 
            end
              else 
            begin
              activateitemID := Fields[plxr, plyu, 5];
              activeitemx := plxr; activeitemy := plyu;
            end;
      var i : int;
      if not vActivateItem and istextinroomisactivaited and (MagicSphere[curspherenumb].curID = 1) then 
        begin
        i := 1;
        istextinroomisactivaited := false;
        if not reGame then begin
        while textforboxes[MagicSphere[curspherenumb].curID, i] <> '' do 
        begin  
          TextBoxStart(ActiveItemX * 64 - 180, ActiveItemY * 64 - 150, textforboxes[MagicSphere[curspherenumb].curID, i]);
          Inc(i);
        end;
        end Else 
        begin
        TextBoxStart(ActiveItemX * 64 - 180, ActiveItemY * 64 - 150, '1&Записка, Сферы, Joe и бла-бла-бла ');
              
              
        
        end;
        listofachive.Add(6);
        I := 0;
        end;
      vActivateItem := true;
      
    end; 
  end 
    else 
  begin
    if vactivateitem then 
    begin
      vActivateItem := false;
      activateitemID := 0; //Не реализованно  
    end;
  end;
  
  if OnFloor and ((Fields[plxl, plyu, 5] <> 0) or (Fields[plxr, plyu, 5] <> 0)) and (CurScreen = 49) then 
  begin
     vActivateItem := true;
  end 
    else 
    if (CurScreen = 49) then vActivateItem := false;
  
end;

//========================Проверка правильной работы анимаций и их кориктировка==========================
procedure AnimTest();
begin
  
  if ((vLeft) xor (vRight)) and (ATimer.Interval = 400) then 
        ATimer.Interval := 100;
  if not ((vLeft) xor (vRight)) and ((ATimer.Interval = 100) or (ATimer.Interval = 50)) then 
        ATimer.Interval := 400;
  
  //Прыжок 
  if not ((vLeft) and (vRight)) and (not OnFloor)  and not ((Player.State = 3) or (Player.State = 6)) then 
  begin
    Player.Active := false;
    if lookr then 
    begin
      Player.State := 3;
    end 
      else 
      Player.State := 6;
    Player.Frame := 1;
  end;
  if (not OnFloor) and (Player.Frame < 3) and ((Player.State = 3) or (Player.State = 6)) then 
  begin
    if vspd > 3 then Player.Frame := 1;
    if (vspd <= 3) and (vspd >= -3) then Player.Frame := 2;
    if vspd < -3 then Player.Frame := 3;  
  end;
  
  //Обработка анимаций после завершения прыжка
  if OnFloor and ((Player.State = 3) or (Player.State = 6))   then 
  begin
      if Player.State = 3 then 
        begin
          if vRight then 
              Player.State := 1 
                else 
              Player.State := 2;
        end;
    if Player.State = 6 then 
    begin
      if vLeft then 
              Player.State := 4 
                else 
              Player.State := 5;
    end;
  end; 
  
  if (vActivateItem) and (CurScreen = 49) and (vEkey) then endingAnimation();
end;


procedure drawminigame();
begin
  for var j := 1 to 16 do 
  begin
    for var i := 1 to 8 do 
    begin
      Inc(BlockCountMini);
      if minigamefield[j, i].empty then begin
        minigamefield[j, i].objectspr := minigameBlocks[minigamefield[j, i].numerofsprite - 1].Clone; 
        minigamefield[j, i].objectspr.MoveTo(nilxpos + j * 64 - 64, nilypos + i * 64 - 64); 
        minigamefield[j, i].objectspr.Visible := true;
      end;      
    end;        
  end;  
end;

procedure undrawminigame();
begin 
 for var j := 1 to 16 do 
  begin
    for var i := 1 to 8 do 
      if minigamefield[j, i].empty then 
      begin
        minigamefield[j, i].objectspr.Destroy;
      end;
  end;
  
  BlockCountMini := 0;
  
  for var i := 1 to alldotsofliser.Count do
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
  
  loadminigamefrombuffer(FieldsMiniGame[MagicSphere[curspherenumb].curID - 1]);
  drawminigame;
  UnLockDrawingObjects;
  if MagicSphere[curspherenumb].curID = 1 then begin
    var tutor := new pic((Window.Width - 1271) div 2, (Window.Height - 650) div 2, 'Sprites\Backround\MiniGamePlayBack1.png');
    Sleep(5000);
    tutor.Destroy;
  end;
  
  while not IsMiniGameIsFinished do 
  begin
    if vSpase and not isMiniGameStartsDo then 
      isMiniGameStartsDo := true;
    
    if isMiniGameStartsDo then 
      begin
        alllaserdrawing;
      
      if not IsMiniGameIsFinished then 
        while true do 
        begin
          vSpase := false;
          Sleep(100);
          if not IsMiniGameIsFinished and vSpase then 
           begin
            LockDrawingObjects;
            undrawminigame;
            drawminigame;
            cursor.MoveTo(-8, -8);
            UnLockDrawingObjects;
            isMiniGameStartsDo := false;
            Sleep(500);
            break;
           end; 
         end;
    end;
  end;
  
  LockDrawingObjects;
  undrawminigame;
  
  for var i := 1 to 16 do
    for var j := 1 to 8 do 
    begin
      if minigamefield[i, j].empty then begin
        minigamefield[i, j].numerofsprite := 0;
        minigamefield[i, j].typeofobgect := '';
        minigamefield[i, j].objectspr := nil;
        minigamefield[i, j].empty := false;
      end;
    end;
  
  field.Destroy;
  cursor.MoveTo(-80, -80);
  vActivateItem := false;
  
  dataforsave.magicsphereaktive[MagicSphere[curspherenumb].curID] := true;
  savein;
  CurModeOfScreen := 'Game';
end;


procedure achieveAnimation();

begin
  try
  if (listofachive.Count = 0) or dataforsave.achivecompited[listofachive[0]] then exit;
  if achivetimercounter = 0 then 
  begin
    var lineup := achiveTexts[listofachive[0]].Split(';');
    LockDrawingObjects;
    achiveUI := new pic(Window.Width, 0, 'Sprites\UI\AchievementUnlocked.png');
    achivetextboxmain := new textbox(Window.Width + 20, 18, 13, lineup[0], clLime);
    achivetextboxaddition := new textbox(Window.Width + 20, 40, 10, lineup[1], clgreen);
    UnLockDrawingObjects;
  end;
  Inc(achivetimercounter);
  Inc(achivetimercounter);
  
  if (achivetimercounter <= 80) and (achivetimercounter mod 10 = 0) then 
  begin
    achivetextboxmain.MoveOn(-50, 0); 
    achivetextboxaddition.MoveOn(-50, 0); 
    achiveUI.MoveOn(-50, 0);
    
  end;
  
  if listofachive.Count = 2 then
    if (listofachive[1] = 5) and (achivetimercounter = 2) then 
    begin
      var end1 := new pic(0, 0, 'Sprites\Backround\Ending1spr.png');
      Sleep(1000);
      var end2 := new pic(0, 0, 'Sprites\Backround\Ending2spr.png');
    end;
    
  if (achivetimercounter >= 200) and (achivetimercounter mod 10 = 0) then 
  begin
    achivetextboxmain.MoveOn(50, 0); 
    achivetextboxaddition.MoveOn(50, 0); 
    achiveUI.MoveOn(50, 0);
  end;
  
  if listofachive.Count >= 2 then 
   if (listofachive[1] = 5) and (achivetimercounter = 2) then 
    begin
      Sleep(4000);
      var achivecounter : int;
      
      for var i := 1 to ACHIVNUMB do if dataforsave.achivecompited[i] then Inc(achivecounter);
      
      
      if (listofachive[0] = 20) and (achivecounter >= 6) then
        begin
          var f : file;
          listofachive.Add(14);
          Assign(f,'YesThisIsThe.End');
          Rewrite(f);
          f.Close;
          achivecounter := 3;
        end else
        begin
        achivecounter := 2;
      
      end;
      
      
        
       if reGame then 
        begin
          achivecounter := 3;
          listofachive.Add(13);
          
          if (listofachive[0] = 20) then 
            begin 
              achivecounter := 5;
              listofachive.Add(12);
            end;
        end;
        
      
      
      for var i := 1 to ACHIVNUMB do if dataforsave.achivecompited[i] then Inc(achivecounter);
      
      var end3 := new textbox(Window.Width div 2 - 320,window.Height div 2 + 240,30,'Выполненно достижений: ' + achivecounter + '/'+COMPITBLEACHIVONONERUN,clwhite);
      DeleteFile('Save.ini');
    end;
  
  if achivetimercounter >= 280 then 
  begin
    LockDrawingObjects;
    achivetextboxaddition.Destroy;
    achivetextboxmain.Destroy;
    achiveUI.Destroy;
    UnLockDrawingObjects;
    
    achivetimercounter := 0;
    
    dataforsave.achivecompited[listofachive[0]] := true;
    listofachive.RemoveAt(0);
  end;
  except;
  end;
end;


procedure newgamecutscene();
begin
  
  if isDebugFunction[1] = false then begin
    
    OnKeyDown := FrameTimer;
    OnKeyUp := FrameTimer;
    Window.Fill('sprites\Backround\pogoda1.png');
    alternativepayer := new spr(180, 6 * 64 + 8, 54, 'Sprites\Player\Player_Sheets_Alternative.png');
    alternativepayer.AddState('RunR', 5); alternativepayer.AddState('IdleR', 5); alternativepayer.AddState('JumpR', 4);
    alternativepayer.AddState('RunL', 5); alternativepayer.AddState('IdleL', 5); alternativepayer.AddState('JumpL', 4);
    alternativepayer.Active := false; 
    alternativepayer.State := 1;
    alternativepayer.ToBack;
    
    mosta := new spr(64 * 11, 64 * 6, 192, 'Sprites\Blocks\Most-a.png');
    mosta.AddState('st', 3); mosta.AddState('st1', 3);
    mosta.State := 1;
    mosta.Active := false;
    
    mosta.Frame := 1;
    ATimer.Interval := 200;
    UnLockDrawingObjects;
    
    for var i := 1 to 80 do begin alternativepayer.MoveOn(4, 0); Sleep(20); end;
    alternativepayer.State := 5;
    
    Sleep(500);
    
    OnKeyDown := kdown;
    OnKeyUp := kup;
    if not reGame then 
    begin
    TextBoxStart(150, 200, '2&Чего встал? ');
    CanMove := false;
    Sleep(300);
    CanMove := true;
    TextBoxStart(50, 200, '1&...Ууух... Ты бы не мог... Ух... Не так сильно торопиться?');
    TextBoxStart(150, 200, '2&Ну же, такими темпами мы не успеем взобраться на Элестию до заката');
    TextBoxStart(50, 200, '1&Мы только что поднялись  на гору такой же высоты как Элестия, зачем нам идти до нее?');
    TextBoxStart(150, 200, '2&Мы поднялись на нее на фуникулере, а у Элестии... ');
    TextBoxStart(150, 200, '2&Стой');
    TextBoxStart(150, 200, '2&Ты так запыхался подымаясь по ступенькам от фуникулера?');
    TextBoxStart(50, 200, '1&Слушай, я не думаю, что смогу осилить полноценный подьем на гору сегодня');
    TextBoxStart(50, 200, '1&Может остановимся в ближайшей гостинице до завтра?');
    TextBoxStart(150, 200, '2&Лентяй! ');
    TextBoxStart(150, 200, '2&Ладно, до гостиницы можно быстро добраться по канатной переправе за этим мостом');
    TextBoxStart(150, 200, '2&Иди за мной');
    end 
    else 
    begin
    TextBoxStart(150, 200, '2&Опять тормозишь? ');
    TextBoxStart(50, 200, '1&Иду-иду...');
    end;
    CanMove := false;
    Sleep(500);
    
    alternativepayer.State := 1;
    alternativepayer.ToBack;
    for var i := 1 to 45 do begin alternativepayer.MoveOn(4, 0); Sleep(20); end;
    mosta.Frame := 2;
    alternativepayer.MoveOn(0, 4);
    for var i := 1 to 15 do begin alternativepayer.MoveOn(4, 0); Sleep(20); end;
    mosta.Frame := 1;
    alternativepayer.MoveOn(0, -4);
    for var i := 1 to 20 do begin alternativepayer.MoveOn(4, 0); Sleep(20); end;
    mosta.Frame := 3;
    alternativepayer.MoveOn(0, 4);
    for var i := 1 to 10 do begin alternativepayer.MoveOn(4, 0); Sleep(20); end;
    mosta.Frame := 1;
    alternativepayer.MoveOn(0, -4);
    for var i := 1 to 30 do begin alternativepayer.MoveOn(4, 0); Sleep(20); end;
    alternativepayer.Destroy;
    Sleep(200);
    CanMove := true;
    TextBoxStart(50, 200, '1&...');
    end;
  newgame := true;
end;


procedure minigameanim();
begin 
   if curspherenumb > 0 then  
    begin
      var ox, oy: int;
      kup(vk_left); kup(VK_Right);
         hspd := 0;
      if lookr then 
          Player.State := 2
        else Player.State := 5;
      AnimTest;
      ox := MagicSphere[curspherenumb].Spritesphere.Position.X; 
      oy := MagicSphere[curspherenumb].Spritesphere.Position.y;
      MagicSphere[curspherenumb].Spritesphere.Destroy; 
      MagicSphere[curspherenumb].Spritesphere := new spr(ox, oy, 64, 'Sprites\Blocks\Prt.Mng.Sphere.ActiveA.png');
      for var i := 1 to 5 do 
        begin
          Sleep(100);
          MagicSphere[curspherenumb].Spritesphere.NextFrame;
        end;
      Sleep(1000);
      
      Fields[MagicSphere[curspherenumb].LocationOfScreen.x, MagicSphere[curspherenumb].LocationOfScreen.y, 5] := 55;
      
      savein;
      
      var i: int;
      if istextinroomisactivaited then 
      begin
        I := 1;
        istextinroomisactivaited := false;
        while textforboxes[MagicSphere[curspherenumb].curID + 1, i] <> '' do 
        begin  
          TextBoxStart(ActiveItemX * 64 - 180, ActiveItemY * 64 - 150, textforboxes[MagicSphere[curspherenumb].curID + 1, i]);
          Inc(i);
        end;
        I := 0;
      end;
   end;   
end;

//===========================Мясо===============================================
procedure game();
begin
  
  //=================Описание второстепенных элементов============================
  
  
  CurModeOfScreen := 'Game';
  CanMove := false;
  if not reGame then 
  Player := new spr(dataforsave.PlayerPos.x, dataforsave.PlayerPos.y, 54, 'Sprites\Player\Player_Sheets.png')
   else
  Player := new spr(dataforsave.PlayerPos.x, dataforsave.PlayerPos.y, 54, 'Sprites\Player\Player_Sheets_Prize.png');
  Player.AddState('RunR', 5); Player.AddState('IdleR', 5); Player.AddState('JumpR', 4);
  Player.AddState('RunL', 5); Player.AddState('IdleL', 5); Player.AddState('JumpL', 4);
  Player.Active := false; 
  
  ATimer.Start;
  
  
  if not IsMiniGameIsFinished then
  begin
    Player.State := 2;
    lookr := true;
    OnFloor := true;
  end;
  
  StartScreenX := dataforsave.CurScreen.x; StartScreenY := dataforsave.CurScreen.y;
  
  CurScreenx := StartScreenX; CurScreeny := StartScreeny;
  var startScreen := LocationOfFields[StartScreenX, StartScreenY];
  CurScreen := StartScreen;
  //=========================Начало программы=====================================
  kup(VK_Left); kup(vk_right);
  
  LockDrawingObjects;
  case dataforsave.curTime of 
     1 : Window.Fill('sprites\Backround\nightsky3.png');
     2 : Window.Fill('sprites\Backround\MoringSky.png');
     3 : Window.Fill('sprites\Backround\DaySky.png');
    end;
  loadscreenfrombuffer(FieldsName[StartScreen - 1]);
  drawfield(1, StartScreen);
  
  if not FileExists('save.ini') then begin
    newgamecutscene();
  end;
  
  UnLockDrawingObjects;
  
  if IsMiniGameIsFinished then begin
  minigameanim;
  end;
  
  
  CanMove := true;
  while true do
  begin
    if CurModeOfScreen = 'MiniGame' then exit;
    px := Player.Position.X; py := Player.Position.Y;
    
    AnimTest();
    
    moveTest();  
    
    achieveAnimation();
    
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
      for var i := 1 to SPHERENUMB do dataforsave.magicsphereaktive[i] := false;
      
      
    end;
  end;
end;

//=====================Менюшка================================
procedure menu();

begin
  var achibox : pic;
  var achivecounttext: textbox;
  var achivecount: int;
  for var i := 1 to ACHIVNUMB do if dataforsave.achivecompited[i] then Inc(achivecount);
  
 //Слои для парралакса
  if not reGame then 
  fon[1] := new pic(0, 0, 'Sprites\Backround\MenuBack_Moon.png') 
    else
  fon[1] := new pic(0, 0, 'Sprites\Backround\MenuBack_Moon_Prize.png'); 
 
  fon[2] := new pic(0, 0, 'Sprites\Backround\MenuBack_Stars.png');
  fon[3] := new pic(0, 0, 'Sprites\Backround\MenuBack_Cloude.png');
  fon[4] := new pic(0, 0, 'Sprites\Backround\MenuBack_Logo.png');
 
  if achivecount > 0 then 
      begin 
        achibox := new pic(Window.Width - 340, -80,'Sprites\UI\TextBoxGreen.png');
        achivecounttext := new textbox(Window.Width - 320, 10, 16, 'Выполненно достижений: ' + achivecount + '/' + COMPITBLEACHIVONONERUN, cllightGreen);
      end;
 
  LoadScreen.ToFront;
  
  mmove(WindowWidth div 2, WindowHeight div 2, 1);
  
  UnLockDrawingObjects;
  
  for var i := 2 to 5 do begin LoadScreen.Frame := i; Sleep(200); end;
  LockDrawingObjects;
  LoadScreen.Visible := false;
  
  if FileExists('Save.ini') then playbutt := new spr(-580, 575, 'Sprites\UI\ContinueButt.png') else playbutt := new spr(-580, 575, 'Sprites\UI\NewGameButt.png');
  {
  infobutt := new spr(-580, 450, 'Sprites\UI\InfoButt.png');
  exitbutt := new spr(-580, 575, 'Sprites\UI\ExitButt.png');}
  if FileExists('Save.ini') then playbutt2 := new spr(-580, 575, 'Sprites\UI\ContinueButt2.png') else playbutt2 := new spr(-580, 575, 'Sprites\UI\NewGameButt2.png'); 
  {
  infobutt2 := new spr(-580, 450, 'Sprites\UI\InfoButt2.png');
  exitbutt2 := new spr(-580, 575, 'Sprites\UI\ExitButt2.png');}
  mmove(WindowWidth div 2, WindowHeight div 2, 1);
  UnLockDrawingObjects;
  
  for var j := 0 to 30 do 
  begin
  if vclick then break;
    LockDrawingObjects;
    playbutt.moveon(20, 0);{
    infobutt.moveon(20, 0);
    exitbutt.moveon(20, 0);}
    playbutt2.moveon(20, 0);{
    infobutt2.moveon(20, 0);
    exitbutt2.moveon(20, 0);}
    UnLockDrawingObjects;
  end;
  
  while true do 
  begin
    while not vclick do
    begin
      Sleep(10);
    end;
  LockDrawingObjects;
  for var i := 1 to 4 do fon[i].Destroy;
  if achivecount > 0 then 
   begin 
    achivecounttext.Destroy;
    achibox.Destroy;
   end;
    playbutt.Destroy;{
    infobutt.Destroy;
    exitbutt.Destroy;}
    playbutt2.Destroy;{
    infobutt2.Destroy;
    exitbutt2.Destroy;}
    
    case CurModeOfScreen of
      'Game': game;
      'MiniGame': minigame;
    end; end;
end;

//==============================================================================
//===========================Начало программы===================================
//==============================================================================

//=============Описание переменных используеммых в самой программе==============


begin
  LockDrawingObjects;
  LoadScreen := new spr(0, 0, 1344, 'Sprites\Backround\LoadScreen.png');
  LoadScreen.Active := false;
  LoadScreen.Frame := 2;
  
  //===================Описание основ=============================================
  SetFontName('Comic Sans MS');
  
  CurModeOfScreen := 'Menu';
  OnMouseMove := mmove; 
  OnMouseDown := mdown;
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
  menu();
  Readln;
end.