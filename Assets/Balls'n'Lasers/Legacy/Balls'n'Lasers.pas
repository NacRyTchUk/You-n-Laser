uses graphabc;
type int = integer;
     float = real;
     str = string;
     bool = boolean;
     maxfield = array [1..15,1..15,1..10] of byte;

var i,mxold,myold : int;
procedure mmove(x,y, mb: int);
begin
TextOut(0,0,x+' '+y);

if ((x > 20) and (y > 20)) and ((x < 20+30*15) and (y < 20+30*15)) then
begin
if ((x-((x-20) mod 30))) and (y-(((y-20) mod 30))+30) <> ((mxold-((mxold-20) mod 30))) and (myold-(((myold-20) mod 30))+30) then begin
SetPenColor(clWhite);
//Line(20,20,mxold,myold);
Rectangle((mxold-((mxold-20) mod 30)),myold-(((myold-20) mod 30))+30,mxold-(((mxold-20) mod 30))+30,myold-(((myold-20) mod 30)+0));
SetPenColor(clBlack);
//Line(mxold,myold,x,y);
Rectangle((x-((x-20) mod 30)),y-(((y-20) mod 30))+30,x-(((x-20) mod 30))+30,y-(((y-20) mod 30)+0));
mxold:=x;myold:=y;
end; end;
end;

procedure mdown(x,y,mb:int);
begin
if ((x > 20) and (y > 20)) and ((x < 20+30*15) and (y < 20+30*15)) then
begin
if ((x-((x-20) mod 30))) and (y-(((y-20) mod 30))+30) <> ((mxold-((mxold-20) mod 30))) and (myold-(((myold-20) mod 30))+30) then begin
SetPenColor(clWhite);
Rectangle((mxold-((mxold-20) mod 30)),myold-(((myold-20) mod 30))+30,mxold-(((mxold-20) mod 30))+30,myold-(((myold-20) mod 30)+0));
SetPenColor(clBlack);
Rectangle((x-((x-20) mod 30)),y-(((y-20) mod 30))+30,x-(((x-20) mod 30))+30,y-(((y-20) mod 30)+0));

mxold:=x;myold:=y;
end; end;
end;
    
procedure fieddraw();
begin
Rectangle(20-1,20-1,20+30*15+1,20+30*15+1);

end;


begin
Window.SetSize(1000,600);
Window.CenterOnScreen;
OnMouseMove:=mmove;
OnMouseDown := mdown;
fieddraw();
end.