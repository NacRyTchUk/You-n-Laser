{
Список того, чем стоит занятся:
-Перевод обработки соприкосновений с ObjectUnderPoint на преобразование координат с массива карты
-Сделать все необходимые обьекты и спрайты
-Сделать мап эдитор
-Реализовать layers
-Реализовать вывод debug информации
}
uses abcsprites,abcobjects,graphabc,timers;
type 
    int = integer;
    Str = string;
    bool = boolean;
    float = char;
    pic = PictureABC;
    obj = ObjectABC;
    spr = SpriteABC;

const Layers = 5; //Количество уровней (Обьекты заднего фона, обьекты между игроком и персоонажем)
      CountOfScrens = 10; //Количество 'Полей' 
      grav = 3; //Гравитация
      vforce = 30; // Сила с которой мы еденично действуем на обьект придавая ему скорость вертикально
      hforce = 10; //Горизонтальная разовая сила
      trenie = 1; // Сила замедляющее тело во время скольжения 
      vspdMAX = 30; // Максимальна скорость на которую может ускориться игрок по вертикали
var
   Blocks : array of spr;
   Fields : array [0..20,0..10,0..Layers,0..CountOfScrens] of byte;
   BlocksOfField : array [1..210,0..layers] of spr;
   FieldsName : array of Str;
   BlockCount, hspd,vspd,px,py,mxold,myold : int;
   Player: spr;
   vLeft,vRight,vUp,vDown,vShift,vSpase : bool; //Флаги клавиш
   OnFloor,onRoof,CanMove,lookl,lookr,falling,testfalling,lstop,rstop,ustop : bool; // Флаги состояний
   Selector := new spr(-64,-64,'Sprites\UI\Selector.png'); ///!!!!!!!!!!!!!!!!!!!!!!!
//===================Ввод информации с клавы и мышки===========================
procedure mmove(mx,my,mb :int);
var i,j,xc,yc,bxc,byc : integer;
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

xc := (mx-(mx mod 64)) div 64; 
yc := (my-((my) mod 64)) div 64;
TextOut(100,120,'_____________');
TextOut(100,120,xc + ' '+ yc);
    if  Fields[xc,yc,1,1] <> 0  then TextOut(xc*64,yc*64,' ');;

Selector.MoveTo(xc*64 , yc*64);

//mxold:=mx;myold:=my;
//end; 
end;
end;

procedure mdown(mx,my,mb :int);
begin

//Rectangle((mx-((mx) mod 64)) , (my-((my) mod 64)),(mx-((mx) mod 64))+64 , (my-((my) mod 64))+64);
var blocknew := Blocks[1].Clone;
blocknew.Visible := true;
blocknew.MoveTo((mx-((mx) mod 64)) , (my-((my) mod 64)));
Inc(BlockCount);
BlocksOfField[BlockCount,1] := blocknew;
end;

procedure mup(mx,my,mb :int);
begin

end;

procedure kpress(key:float);
begin

end;


procedure kup(key :int);
begin
  case key of
    VK_Left : begin vLeft:= false; hspd := 0; Player.State := 5; if vRight then begin lookr := true; end; end;
    VK_Right : begin vRight:= false; hspd := 0; Player.State := 2; if vleft then begin lookl := true; end; end;
    VK_Space : begin vSpase := false; end;
    VK_ShiftKey : vShift := false;
  end;
  
if ((vLeft) and (vRight)) then begin CanMove:=false; Player.State := 2; end else CanMove:= true;;

end;


procedure kdown(key :int);
begin
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
    VK_Left : begin if not lstop then begin
      if vRight then begin kup(VK_Right); exit; end;
                    vLeft := true;
                    if not lookl then begin LookL := true; lookr:=false; end;
                     if canmove then Player.State := 4; hspd:=-hforce;
    end else begin exit; end; end;
    VK_Right : begin if not rstop then begin 
    if vLeft then begin kup(VK_Left); exit; end;
                    vRight:= true; 
                    if not LookR then begin LookR := true; LookL:=false; end;
                    if canmove then Player.State := 1; hspd:=hforce; end; end;
    VK_Space : begin vSpase := true; if canmove and OnFloor then begin vspd := vforce; if LookR then if not vRight then Player.State := 3 else if not vLeft then Player.State := 6;  end; end;
    VK_ShiftKey : begin vShift := true;  end;
    VK_Escape : window.Close;
  end;
 //if ((vLeft) and (vRight)) then begin CanMove:=false; Player.State := 2; end else CanMove:= true;;

end;


//===================Подгрузка обьектов=======================
procedure loadobjfromfile(Path : str);
var fileofblocks : text;
    BlocksName : array of str;
    i : int :=0;
    Line : Str;
begin
Assign(fileofblocks,'Sprites\Blocks\'+Path);
Reset(fileofblocks);
  Repeat
    Readln(fileofblocks,Line);
    if Line = '' then break; 
    SetLength(BlocksName,I+1);
    SetLength(Blocks,I+1);   
    Line:='Sprites\Blocks\'+Line;
    BlocksName[i] := Line;
    Blocks[i] := new spr(-64,-64,Line);
    Blocks[i].Visible := false;
   Inc(i);
   until Line = 'End.';
end;

//==================Подгрузка списка карт в память=============================
procedure loadscreenfromfile(Path:str;ScreenNumb:int); 
  var  FieldFile : Text;
    Line : Str;
    i,j,Layer: int;
    
begin
Dec(ScreenNumb);
Assign(Fieldfile,'Fields\Main\'+path); //Подгружаем список всех экранов
Reset(FieldFile);

Repeat
    Readln(FieldFile,Line);
    if Line = '' then break;
    Line:='Fields\Main\'+Line;
    SetLength(FieldsName,i+1);
    FieldsName[i] := Line;
    
   Inc(i);
   until Line = 'End.';
   Close(FieldFile);
end;





//=================Загрузка определенного экрана====================
procedure loadscreenfrombuffer(Path:Str;screennumb:int); 
  var  FieldFile : Text;
    Line : Str;
    i,j,Layer: int;
    
begin

   Assign(Fieldfile,Path); //Загрузка информации о обьектах из заданного экрана в память
 Reset(Fieldfile);
 for i := 1 to 10 do 
  begin
  Readln(Fieldfile,Line);
  var blkInfo : array of Str := Line.Split(';');
  SetLength(blkInfo,21);
  for j:= 1 to 20 do
    begin
    if blkInfo[j] <> '' then Fields[j,i,1,Screennumb] := StrToInt(blkInfo[j]);
    end;
  end;
end;
//==========================Перевод переменной типа Bool к Str==================
function BoolToStr(Answ : bool)  : Str;
begin
  if Answ then BoolToStr := 'true' else BoolToStr := 'false'; 
  
end;




//=================Отрисовка поля=========================
procedure drawfield(layer,screennumb : int); 
var i,j : int;
begin
var back := new pic(0,0,'Sprites\Backround\NIghtSky3.png'); ////!!!!!!!!!!
back.Scale(3);
back.ToBack; ////!!!!!!!!!!!!!!!!!!!!!!!
for i:=1 to 10 do 
  for j:=1 to 20 do
    begin
    if Fields[j,i,layer,screennumb] <> 0 then
        begin
        Inc(BlockCount);
        BlocksOfField[BlockCount,layer] := Blocks[Fields[j,i,layer,screennumb]].Clone; //Копируем спрайт из буфера
        BlocksOfField[BlockCount,layer].MoveTo(j*64,I*64); // Помещаем его на нужные координаты и делаем видимым
        BlocksOfField[BlockCount,layer].Visible := true;
        end;
    end;


end;
//===================Таймер отвечающий за анимацию персоонажа===================
procedure AniTimer();
begin
if Player.Frame < 5 then Player.Frame := Player.Frame +1;
if Player.Frame  = 5 then Player.Frame := 1;
end;
var ATimer := new Timer(100,AniTimer);

//Счетчик кадров
procedure FrameTimer();
begin
   
end;


//================================Проверка и кориктировка движений игрока===========================
procedure moveTest();
var i : int;
    found : bool;
begin
  
  
  //Вытаскивание игрока из под блока, если он туда провалился
  if ((0  < px + hspd) and (px + hspd < Window.Width)) and ((0  < py - vspd) and (py - vspd < Window.Height)) then
begin if CanMove then begin if vRight and vLeft then Player.moveon(0,-vspd) else Player.moveon(hspd,-vspd) end end else Player.MoveTo(random(64,window.Width-64),64*Random(1,5)+64-Player.Height);; 
//Обработка Нажаните шифта
if (vShift and ((vLeft) xor (vRight)) and (ATimer.Interval = 100)) then begin hspd:= hspd*2; ATimer.Interval := 50;  end else if (not vShift and ((vLeft) or (vRight))) and (ATimer.Interval = 50) then  begin hspd:= hspd div 2; ATimer.Interval := 100;  end;



//Обработка состояний "На земле" и "В воздухе"

for i:=1 to BlockCount do
begin
  //Проверка на падение 

if ((ObjectUnderPoint(Player.Position.X+10,Player.Position.Y + Player.Height ) = blocksoffield[i,1]) or 
(ObjectUnderPoint(Player.Position.X + Player.Width - 10,Player.Position.Y + Player.Height + 5) = blocksoffield[i,1]))  then 
  begin if not OnFloor then OnFloor := true; Player.MoveTo(Player.Position.X,Player.Position.Y - Player.Position.Y mod 64 + 8); break end else  begin if OnFloor then begin OnFloor := false; end; end;
  end;
  //Проверка на Столкновение со стенкой
    //Лево
    for i:=1 to BlockCount do
  if (ObjectUnderPoint(Player.Position.X+10-1,Player.Position.Y + Player.Height - 5) = blocksoffield[i,1]) then begin Player.MoveTo(Player.Position.X - Player.Position.X mod 64 +64,Player.Position.Y); kup(VK_Left); lstop := true; break; end;
 for i:=1 to BlockCount do
  if (ObjectUnderPoint(Player.Position.X+10-11,Player.Position.Y + Player.Height - 5) = blocksoffield[i,1]) then begin lstop := true; break; end else begin lstop:=false; end;
   if (i = BlockCount) and lstop then lstop := false;
  //Право
    for i:=1 to BlockCount do
  //  if (ObjectUnderPoint(Player.Position.X-10+1,Player.Position.Y + Player.Height - 5) = blocksoffield[i,1]) then begin Player.MoveTo(Player.Position.X - Player.Position.X mod 64,Player.Position.Y); kup(VK_Right); rstop := true; break; end;
 
 if (ObjectUnderPoint(Player.Position.X + Player.Width -10+1,Player.Position.Y + Player.Height - 5 ) = blocksoffield[i,1]) then begin Player.MoveTo(Player.Position.X - Player.Position.X mod 64 + 10,Player.Position.Y); kup(VK_Right); rstop := true; break; end;
 for i:=1 to BlockCount do
  if (ObjectUnderPoint(Player.Position.X+ Player.Width-10+11,Player.Position.Y + Player.Height - 5) = blocksoffield[i,1]) then begin rstop := true; break; end else begin rstop:=false; end;
   TextOut(100,100,'     ');
   TextOut(100,100,i);
   if (i = BlockCount) and rstop then rstop := false;
  
  
  
 
//Гравитация 
if OnFloor then TextOut(0,0,'На земле') else TextOut(0,0,'В воздухе');
if not OnFloor then begin if vspd >= -vspdMAX then vspd := vspd - grav end else vspd := 0;
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
  //TextOut(0,110,'nigga');
  if lookr then begin
    if vRight then Player.State := 1 else Player.State := 2 ;
  end else begin
  if vLeft then Player.State := 4 else Player.State := 5;
  end;
end; 
testfalling := falling; 
end;

//==============================================================================
//===========================Начало программы===================================
//==============================================================================

//=============Описание переменных используеммых в самой программе==============
var i,j : int;

begin
//===================Описание основ=============================================
OnMouseMove:=mmove; 
OnMouseDown:=mdown;
OnMouseUp:=mup;
OnKeyPress:=kpress;
OnKeyDown:=kdown;
OnKeyUp:=kup;
Window.SetSize(1344,704);
Window.CenterOnScreen;
Window.IsFixedSize := true;
Window.Title := 'Ball and Lasers';
//=================Описание второстепенных элементов============================
Player := new spr(800,64*5+8,54,'Sprites\Player\Player_Sheets.png');
Player.AddState('RunR',5); Player.AddState('IdleR',5); Player.AddState('JumpR',4);
Player.AddState('RunL',5); Player.AddState('IdleL',5); Player.AddState('JumpL',4);
Player.Active := false; 
Player.State := 2;
lookr := true;
ATimer.Start;
//=========================Начало программы=====================================
loadobjfromfile('Sprites.list'); //Подгрузка обьктов и экранов в память и последующая их отрисовка
loadscreenfromfile('Fields.list',1);
loadscreenfrombuffer(FieldsName[0],1);
drawfield(1,1);

while 0=0 do  begin 
  px:= Player.Position.X; py:=Player.Position.Y;
AnimTest();
moveTest();  


TextOut(0,0,'OnFloor: ' + BoolToStr(Onfloor));
TextOut(0,20,'Falling: ' + BoolToStr(falling));
TextOut(0,40,'lStop: ' + BoolToStr(lStop));
TextOut(0,60,'rStop: ' + BoolToStr(rStop));
TextOut(0,80,'X: ' + Player.Position.X + ' Y: ' + Player.Position.Y);



 Sleep(50); 
end;
end.