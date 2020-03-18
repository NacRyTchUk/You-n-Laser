{
Список того, чем стоит занятся:
-Сделать все необходимые обьекты и спрайты
-Сделать мап эдитор
}
uses abcsprites,abcobjects,graphabc,timers,System.Windows.Forms;
type 
    int = integer;
    Str = string;
    bool = boolean;
    float = char;
    pic = PictureABC;
    obj = ObjectABC;
    spr = SpriteABC;
    textbox = TextABC;

const Layers = 5; //Количество уровней (Обьекты заднего фона, обьекты между игроком и персоонажем)
      CountOfScrens = 10; //Количество 'Полей' 
      grav = 3; //Гравитация
      vforce = 30; // Сила с которой мы еденично действуем на обьект придавая ему скорость вертикально
      hforce = 8; //Горизонтальная разовая сила
      trenie = 1; // Сила замедляющее тело во время скольжения 
      vspdMAX = 50; // Максимальна скорость на которую может ускориться игрок по вертикали
var
   Blocks : array of spr;
   Fields : array [0..20,0..10,0..Layers,0..CountOfScrens] of byte;
   BlocksOfField : array [1..210,0..layers] of spr;
   CounterOfBlocksL : array [0..layers] of int;
   FieldsName : array of Str;
   BlockCount, hspd,vspd,px,py,mxold,myold : int; DebugCount : int := 1;
   Player: spr;
   CurModeOfScreen : Str;
   vLeft,vRight,vUp,vDown,vShift,vSpase,vEkey : bool; //Флаги клавиш
   OnFloor,onRoof,CanMove,lookl,lookr,falling,testfalling,lstop,rstop,ustop, sprint : bool; // Флаги состояний
   Selector := new spr(-64,-64,'Sprites\UI\Selector.png'); ///!!!!!!!!!!!!!!!!!!!!!!!
   CurScreen : int := 1;
   

procedure AniTimer(); forward;
procedure game(); forward;
procedure menu(); forward;
procedure undrawfield(); forward;
function booltostr(answ : bool) : str; forward;
procedure kup(key:int); forward;
var ATimer := new timers.Timer(100,AniTimer);
//==============================Вывод далоговых окон============================
procedure TextBoxStart(x,y : int);
begin
  
  var textboxback := new spr(x,y,'Sprites/UI/TextBoxGreen.png');
  var textboxtest := new textbox(x+20,y+20,14,'',cllightgreen);
  SetFontName('Comic Sans MS');
  var textik : Str := 'Hahaha... My name is frask and i love watching pewdiepie. Tseries are sucks. How many shrimps do have you eat, before youre make your skin tirn pink.  ';
  var linescount : int;
   if vRight then kup(VK_Right); 
   if vShift then  kup(VK_Shift);
   if vLeft then kup(vk_left); 
 //  if vSpase then  kup(VK_Space); //kup(VK_J);
  CanMove := false;
 
  for var i : int := 1 to textik.Length do
  begin
    
    textboxtest.MoveTo(Player.Position.X - 200+ 20, Player.Position.Y - 200 +20);
    textboxback.MoveTo(Player.Position.X - 200 , Player.Position.Y - 200 );
    textboxtest.Text := textboxtest.Text + textik[i];
    if (textik[i] = ' ') and (textboxtest.Text.Length div 40 > linescount) then begin textboxtest.Text := textboxtest.Text + #10#13; Inc(linescount); end;
   Sleep(10);
  end;
  
  while not vSpase do begin Sleep(100); TextOut(200,200,booltostr(vSpase)); Write('n'); end;
  
  textboxtest.Destroy;
  textboxback.Destroy;
  
  
  
  CanMove := true;
end;


//===================Быстрый вывод сообщения===============================
procedure msg(text : str);
begin

MessageBox.Show(text, 'Debug', MessageBoxButtons.OK, MessageBoxIcon.Asterisk, MessageBoxDefaultButton.Button1, MessageBoxOptions.ServiceNotification);
end;


var cir := new CircleABC(10,10,5,clwhite);
//===================Ввод информации с клавы и мышки===========================
procedure mmove(mx,my,mb :int);
var i,j,xc,yc,bcx,bcy : integer;
begin
case CurModeOfScreen of
 'Game' : begin 
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
bcx := (bcx-(bcx mod 64)) div 64;  bcy := (bcy-((bcy) mod 64)) div 64;
xc := (mx-(mx mod 64)) div 64; 
yc := (my-((my) mod 64)) div 64;
TextOut(100,120,'_____________');
TextOut(100,120,xc + ' '+ yc);
   // if  (bcy <= 10) and (bcx <= 20) then if (Fields[bcx,bcy,1,1] <> 0)  then TextOut(xc*64,yc*64,' ');;

Selector.MoveTo(xc*64 , yc*64);

//mxold:=mx;myold:=my;
//end; 
end;
end;
 'Menu' : begin 
 try begin

 cir.MoveOn(-Round(2*(cir.Position.X - mx)/Sqrt(Sqr((cir.Position.X - mx)) + Sqr((cir.Position.Y - my)))),-Round(2*(cir.Position.Y - my)/Sqrt(Sqr((cir.Position.X - mx)) + Sqr((cir.Position.Y - my)))));
 end except;
 end;
end;
end; end;                                    
        


var vclick : bool;

procedure mdown(mx,my,mb :int);
begin
case CurModeOfScreen of 
'Game' : begin
//Rectangle((mx-((mx) mod 64)) , (my-((my) mod 64)),(mx-((mx) mod 64))+64 , (my-((my) mod 64))+64);
var blocknew := Blocks[1].Clone;
blocknew.Visible := true;
blocknew.MoveTo((mx-((mx) mod 64)) , (my-((my) mod 64)));
Inc(BlockCount);
BlocksOfField[BlockCount,1] := blocknew;
if mb = 1 then Fields[(mx-((mx) mod 64)) div 64, (my-((my) mod 64))      div 64,1,CurScreen] := 1 else Fields[(mx-((mx) mod 64)) div 64, (my-((my) mod 64))      div 64,2,CurScreen] := 1;
end;
'Menu': begin vclick := true; if (mx < 100) and (my < 100) then begin CurModeOfScreen := 'Game' end else if (mx > Window.Width - 100) and (my > Window.Height - 100) then begin CurModeOfScreen := 'Test'; end else vclick := false;  end;
end; end;

procedure mup(mx,my,mb :int);
begin

end; 

procedure kpress(key:float);
begin

end;


procedure kup(key :int);
begin
case CurModeOfScreen of
'Game' : begin
  case key of
    VK_Left : begin    vLeft:= false; if not CanMove then exit; hspd := 0; Player.State := 5; if vRight then begin lookr := true; end; end;
    VK_Right : begin  vRight:= false;if not CanMove then exit; hspd := 0; Player.State := 2; if vleft then begin lookl := true; end; end;
    VK_Space : begin vSpase := false; end;
    VK_ShiftKey : begin vShift := false;  sprint := false; hspd:= hspd div 2; ATimer.Interval := 100; end;
    VK_E : vEkey := false;
  end;
  end;
  'Menu' : begin
  case key of
  VK_Space : begin vSpase := false; end;
  end;
  end;
//if ((vLeft) and (vRight)) then begin CanMove:=false; Player.State := 2; end else CanMove:= true;;

end; end;

var yep : bool;
procedure kdown(key :int);
 
begin
case CurModeOfScreen of 
 'Game' : begin
  var plxl,plxr,plyu,plyd:int;
  plxl := Player.Position.X-hforce; plyu := Player.Position.Y + Player.Height - 5; plxr := Player.Position.X+Player.Width+hforce; plyd := Player.Position.Y + Player.Height - 5;
plxl := (plxl-(plxl mod 64)) div 64; plyu := (plyu-(plyu mod 64)) div 64; plxr := (plxr-(plxr mod 64)) div 64; plyd := (plyd-(plyd mod 64)) div 64;

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
    VK_Left : begin if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) or not CanMove then exit;
  //  Writeln('nibba' + booltostr(Canmove));
    if not lstop and (Fields[plxl,plyd,1,CurScreen] = 0) then begin
      if vRight then begin kup(VK_Right); exit; end;
                    vLeft := true;
                    if not lookl then begin LookL := true; lookr:=false; end;
                     if canmove then Player.State := 4; hspd:=-hforce;
    end else begin exit; end; end;
    VK_Right : begin if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) or not CanMove then exit;     
    if not rstop and (Fields[plxr,plyd,1,CurScreen] = 0) then begin
    if vLeft then begin kup(VK_Left); exit; end;
                    vRight:= true; 
                    if not LookR then begin LookR := true; LookL:=false; end;
                    if canmove then Player.State := 1; hspd:=hforce; end; end;
    VK_Space : begin vSpase := true;  if not CanMove then exit; if canmove and OnFloor then begin vspd := vforce; if LookR then if not vRight then Player.State := 3 else if not vLeft then Player.State := 6;  end; end;
    VK_ShiftKey : begin  vShift := true; if (vLeft xor vRight) and CanMove and not sprint then begin sprint := true; hspd:= hspd*2; ATimer.Interval := 50;  end; end;
    VK_Escape : begin undrawfield(); menu; end;
    VK_J : yep := true;
    VK_E : begin vEkey := true; undrawfield; end;
    else Write(booltostr(CanMove));;  
  end ;
 //if ((vLeft) and (vRight)) then begin CanMove:=false; Player.State := 2; end else CanMove:= true;;

end;
'Menu' : begin
case key of
    Vk_Space : begin vSpase := true;   end; 



end; end;
 end;
 end;

//===================Подгрузка обьектов=======================
procedure loadobjfromfile(Path : str);
var fileofblocks : text;
    BlocksName : array of str;
    i : int :=0;
    Line : Str;
begin
  //var bl := new obj(700,200,100,50,clblack);
  

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

//==================Первоначальная подгрузка всего=============================
procedure loadfieldfromfile(Path:str;ScreenNumb:int); 
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
    i,j,ij,Layer: int;
    
begin

   Assign(Fieldfile,Path); //Загрузка информации о обьектах из заданного экрана в память
 Reset(Fieldfile);
 for ij := 1 to 5 do
 for i := 0 to 10 do
  begin
  Readln(Fieldfile,Line);
  var blkInfo : array of Str := Line.Split(';');
  SetLength(blkInfo,21);
  for j:= 0 to 20 do
    begin
    if blkInfo[j] <> '' then Fields[j,i,ij,Screennumb] := StrToInt(blkInfo[j]);
    end;
  end;
  
end;


//=================Выгруз определенного экрана====================
procedure unloadscreenfrombuffer(curscreen : int); 
  var  FieldFile : Text;
    Line : Str;
    i,j,ij,Layer: int;
    
begin

 
 for ij := 1 to 5 do
 for i := 0 to 10 do
  begin
  
  for j:= 0 to 20 do
    begin
     Fields[j,i,ij,curscreen] := 0;
    end;
  end;
  
end;

//==========================Перевод переменной типа Bool к Str==================
function BoolToStr(Answ : bool)  : Str;
begin
  if Answ then BoolToStr := 'true' else BoolToStr := 'false'; 
  
end;




//=================Отрисовка поля=========================
procedure drawfield(layer,CurScreen : int); 
var i,j : int;
begin
Window.Fill('Sprites\Backround\NIghtSky3.png');
//var back := new pic(0,0,'Sprites\Backround\NIghtSky3.png'); ////!!!!!!!!!!
//back.Scale(3);
//back.ToBack; ///!!!!!!!!!!!!!!!!!!!!!!!
for layer := 1 to 5 do 
for i:=0 to 10 do 
  for j:=0 to 20 do
    begin
    if Fields[j,i,layer,CurScreen] <> 0 then
        begin
        Inc(BlockCount);
        Inc(CounterOfBlocksL[layer]);
        BlocksOfField[CounterOfBlocksL[layer],layer] := Blocks[Fields[j,i,layer,CurScreen]].Clone; //Копируем спрайт из буфера
        BlocksOfField[CounterOfBlocksL[layer],layer].MoveTo(j*64,I*64); // Помещаем его на нужные координаты и делаем видимым
        BlocksOfField[CounterOfBlocksL[layer],layer].Visible := true;
        
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
    
    


end;


//=================Выгрузка поля=========================
procedure undrawfield(); 
var i,j : int;
begin
 ////!!!!!!!!!!

for j := 1 to 5 do
for i:=1 to CounterOfBlocksL[j]   do 
 
        begin
        
        BlocksOfField[i,j].Destroy;  //Копируем спрайт из буфера
        
        
        end;
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
if Player.Frame < 5 then Player.Frame := Player.Frame +1;
if Player.Frame  = 5 then Player.Frame := 1;
end;


//Счетчик кадров
procedure FrameTimer();
begin
   
end;




var yes : bool;

//================================Проверка и кориктировка движений игрока===========================
procedure moveTest();
var i : int;
    found : bool;
begin
  
  
  //Вытаскивание игрока из под блока, если он туда провалился
  if (0  >= px  + hspd) then begin Textout(400,20,'left   '); undrawfield(); loadscreenfrombuffer(FieldsName[0],1); drawfield(1,1); CurScreen := 1; Player.Moveto(window.Width-70, py); end;
  if (px + Player.Width-10 + hspd >= Window.Width) then begin TextOut(400,20,'right  '); undrawfield(); loadscreenfrombuffer(FieldsName[1],2); drawfield(1,2); CurScreen := 2; Player.Moveto(8, py);  end;
  if (0  >= py - vspd) then TextOut(400,20,'up    ');
  if (py - vspd  >= Window.Height) then begin  TextOut(400,20,'down '); Player.Moveto(Window.Width div 2, Window.Height div 2 - 60); end;
  if ((0  < px + hspd) and (px + hspd < Window.Width)) and ((0  < py - vspd) and (py - vspd < Window.Height)) then
begin if CanMove then begin if vRight and vLeft then {Player.moveon(0,-vspd)} else Player.moveon(hspd,-vspd) end end else;// Player.MoveTo(random(64,window.Width-64),64*Random(1,5)+64-Player.Height); 
//Обработка Нажаните шифта
//if (vShift and ((vLeft) xor (vRight)) and not sprint) then begin sprint := true; hspd:= hspd*2; ATimer.Interval := 50;  end else if (not vShift and ((vLeft) or (vRight))) and (ATimer.Interval = 50) then  begin   end;



//Обработка состояний "На земле" и "В воздухе"


  //Проверка на падение 
var plxl,plyu,plxr,plyd : int;



    plxl := Player.Position.X+10; plyu := Player.Position.Y + 20; plxr := Player.Position.X+Player.Width-10; plyd := Player.Position.Y + Player.Height ;
plxl := (plxl-(plxl mod 64)) div 64; plyu := (plyu-(plyu mod 64)) div 64; plxr := (plxr-(plxr mod 64)) div 64; plyd := (plyd-(plyd mod 64)) div 64; 

if (plxl < 0) or (plyu < 0) or (plxr > 20) or (plyd > 10) then begin  exit; end else begin  ///!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if (plxl >= 0) and (plyu >= 0) and (plxr <= 20) and (plyd <= 10) then begin
if 
//((ObjectUnderPoint(plxl,plyu ) = blocksoffield[i,1]) or 
//(ObjectUnderPoint(plxr,plyd) = blocksoffield[i,1]))  
(Fields[plxl,plyd,1,CurScreen] <> 0) or (Fields[plxr,plyd,1,CurScreen] <> 0)
then 
  begin if not OnFloor then OnFloor := true; Player.MoveTo(Player.Position.X,Player.Position.Y - Player.Position.Y mod 64 + 8); end else  begin if OnFloor then begin OnFloor := false; end; end;
  end; end;
//Проверка на падение с края блока
{plxl := Player.Position.X; plxl := (plxl-(plxl mod 64)) div 64;
if OnFloor and (Fields[plxl, plyd , 1,1] = 0) then begin   for i:= 0 to Player.Width-20 do begin  player.MoveOn(-1,1); Player.State := 6; Player.Frame := 3; OnFloor:= false; end;  end; 
plxr := Player.Position.X+Player.Width-20;plxr := (plxr-(plxr mod 64)) div 64;
if OnFloor and (Fields[plxr, plyd , 1,1] = 0) then begin   for i:= 0 to Player.Width-20 do begin  player.MoveOn(1,1); Player.State := 3; Player.Frame := 3; OnFloor:= false;  end;  end; 
}
  //Проверка на Столкновение со стенкой
    //Лево
    var mylt : int;
    if sprint then mylt:= 2 else mylt := 1;
   plxl := Player.Position.X+10-hforce*mylt; plyu := Player.Position.Y + 20; plxr := Player.Position.X+Player.Width-10+hforce*mylt; plyd := Player.Position.Y + Player.Height -1;
plxl := (plxl-(plxl mod 64)) div 64; plyu := (plyu-(plyu mod 64)) div 64; plxr := (plxr-(plxr mod 64)) div 64; plyd := (plyd-(plyd mod 64)) div 64;                                                  
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
if (plxl >= 0) and (plyu >= 0) and (plxr <=20) and (plyd <=10) then begin
 if  vLeft and ((Fields[plxl,plyd,1,CurScreen] <> 0) or (Fields[plxl,plyu,1,CurScreen] <> 0)) then begin  kup(vk_left); if ((Player.Position.X-(Player.Position.X mod 64)) div 64) <> plxl then  Player.moveon(0,Player.Position.X mod 64); end;
 if vRight and ((Fields[plxr,plyd,1,CurScreen] <> 0) or (Fields[plxr,plyu,1,CurScreen] <> 0)) then begin  kup(vk_right); end;
 end; 
  
//Столкновение с потолком
 plxl := Player.Position.X+10; plyu := Player.Position.Y + 8 ; plxr := Player.Position.X+Player.Width-10; plyd := Player.Position.Y + Player.Height;
plxl := (plxl-(plxl mod 64)) div 64; plyu := (plyu-(plyu mod 64)) div 64; plxr := (plxr-(plxr mod 64)) div 64; plyd := (plyd-(plyd mod 64)) div 64;  

  if not OnFloor and ((Fields[plxl,plyu,1,CurScreen] <> 0) or (Fields[plxr,plyu,1,CurScreen] <> 0)) then begin vspd:=-vspd div 2; Player.MoveTo(Player.Position.X,(plyu+1)*64); end else ;
 
//Гравитация 
if OnFloor then TextOut(0,0,'На земле') else TextOut(0,0,'В воздухе');
if not OnFloor then begin if vspd >= -vspdMAX then vspd := vspd - grav end else vspd := 0;


 
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
    if vRight then Player.State := 1 else Player.State := 2 ;
  end else begin
  if vLeft then Player.State := 4 else Player.State := 5;
  end;
end; 
testfalling := falling; 
end;






//===========================Мясо===============================================
procedure game();
begin 
//=================Описание второстепенных элементов============================
Player := new spr(800,64*4+8,54,'Sprites\Player\Player_Sheets.png');
Player.AddState('RunR',5); Player.AddState('IdleR',5); Player.AddState('JumpR',4);
Player.AddState('RunL',5); Player.AddState('IdleL',5); Player.AddState('JumpL',4);
Player.Active := false; 
Player.State := 2;
lookr := true;
CurModeOfScreen := 'Game';
ATimer.Start;
CanMove := true;
//=========================Начало программы=====================================
loadobjfromfile('Sprites.list'); //Подгрузка обьктов и экранов в память и последующая их отрисовка
loadfieldfromfile('Fields.list',1);
loadscreenfrombuffer(FieldsName[0],1);
drawfield(1,1);





//var dialog := new textbox(500,500,14,'',clblack);


while 0=0 do  begin 
  px:= Player.Position.X; py:=Player.Position.Y;
AnimTest();
moveTest();  

if yep then begin TextBoxStart(0,0); yep := false; end;
TextOut(0,0,'OnFloor: ' + BoolToStr(Onfloor));
TextOut(0,20,'Falling: ' + BoolToStr(falling));
TextOut(0,40,'vL: ' + BoolToStr(vLeft));
TextOut(0,60,'vR: ' + BoolToStr(vRight));
TextOut(0,80,'X: ' + Player.Position.X + ' Y: ' + Player.Position.Y);
TextOut(0,100,'Spd: ' + hspd);


 Sleep(50); 
end;
end;


//=====================Менюшка================================
procedure menu();

begin
CurModeOfScreen := 'Menu';
Rectangle(10,10,200,200);
Write('1');
//Sleep(5000);
//game();
while not vclick do begin
Sleep(1);
end;
case CurModeOfScreen of
  'Game' : game;
  'Test' : msg('Тест');
  end;
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
Window.Title := 'You and Lasers';
menu();
end.