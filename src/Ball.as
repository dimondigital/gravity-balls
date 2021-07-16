package  
{
	import flash.display.Sprite;
	import flash.display.Stage;
	
	public class Ball extends Sprite 
	{
		private var _stage:Stage;
		private var _randomDir:Number; // случайное направление на старте
		private var _speedY:Number;
		private var _speedX:Number;
		private var _radius:uint;     							
		private var _diameter:uint;
	
    /* CONSTRUCTOR */
    public function Ball(radius:uint, stage:Stage)
    {
        _stage = stage;
        _radius = radius;
        _diameter = _radius * 2;
        _randomDir = Math.random() * 360/Math.PI;
        _speedY =  Math.sin(Math.random() * _randomDir);
        _speedX =  Math.cos(Math.random() * _randomDir);

        drawBall();
    }

    /* DRAW BALL */
    private function drawBall():void
    {
        graphics.lineStyle(2, 0x000000, 0);
        graphics.beginFill(0xFF5A1C, 1);
        graphics.drawCircle(_radius, _radius, _radius);
    }

    public function get speedX():Number{return _speedX;}
    public function set speedX(newSpeed:Number):void{_speedX = newSpeed;}

    public function get speedY():Number{return _speedY;}
    public function set speedY(newSpeed:Number):void{_speedY = newSpeed;}

    public function get diameter():Number{return _diameter;}

    public function get radius():Number{return _radius;}
	}
}













