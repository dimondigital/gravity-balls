package 
{
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.*;
import flash.geom.Rectangle;

public class MainController extends Sprite
{
    private var _stage:Stage;
    private var _ballsAmount:int;
    private var _box:Box;
    private var _switchBtn:Switch;
    private var _desc:TfDesc;
    private var _ballArray:Array;
    private var _isGravity:Boolean;
    private const BALL_SIZE:uint = 15;
	private const GRAVITY_SPEED:Number = 0.7;
    private const FRICTION:Number = 0.8;

    /* CONSTRUCTOR */
    public function MainController(stage:Stage, ballsAmount:int)
    {
        _stage = stage;
        _ballsAmount = ballsAmount;
    }

    /* INIT */
    public function init():void
    {
        addBox();
        addBalls();
        addSwitch();
        addDesc();
    }

    /* START */
    public function start():void
    {
        _stage.addEventListener(Event.ENTER_FRAME, mainLoop);
        _stage.addEventListener(MouseEvent.MOUSE_DOWN, dragOn);
        _stage.addEventListener(MouseEvent.MOUSE_UP, dragOff);
    }

    /* ADD BOX */
    private function addBox():void
    {
        _box = new Box();
         _box.x = 0;
         _box.y = 0;
        _stage.addChild(_box);
    }
		
    /* ADD BALLS */
    private function addBalls():void
    {
        _ballArray = [];
        for (var i:int = 0; i < _ballsAmount; i++)
        {
            var ball:Ball = new Ball(BALL_SIZE, stage);
            ball.x = 100 + (i * BALL_SIZE);
            ball.y = 100 + (i * BALL_SIZE);
            _stage.addChild(ball);
            _ballArray.push(ball);
        }
    }

    /* ADD SWITCH */
    private function addSwitch():void
    {
        _switchBtn = new Switch();
        _switchBtn.x = 470;
        _switchBtn.y = 50;
        _switchBtn.gotoAndStop(2);
        _stage.addChild(_switchBtn);
        _switchBtn.addEventListener(MouseEvent.CLICK, onSwitchClick);
    }

    /* ADD DESC */
    private function addDesc():void
    {
        _desc = new TfDesc();
        _desc.x = 414;
        _desc.y = 152;
        _stage.addChild(_desc);
    }

    /* MAIN LOOP */
    private function mainLoop(e:Event):void
    {
        movingBalls();
        if (_isGravity)
        {
            gravityOn();
        }
    }
		
    /* MOVING BALLS */
    private function movingBalls():void
    {
        for each(var ball:Ball in _ballArray)
        {
            ball.x += ball.speedX;
            ball.y += ball.speedY;
            hitTestWithBox(ball);
            hitTestWithBalls(ball);
        }
    }

    /* HIT TEST WITH BALLS */
    private function hitTestWithBalls(curBall:Ball):void
    {
        for each(var hitBall:Ball in _ballArray)
        {
            if (curBall != hitBall)
            {
                var dist:Number = calculateBallsDistance(curBall, hitBall);
                // столкновение !
                if (dist <= curBall.radius + hitBall.radius)
                {
                    collision(curBall, hitBall, dist);
                }
            }
        }
    }

    /* COLLISITON */
    private static function collision(ball1:Ball, ball2:Ball, distance:Number):void
    {
        var x1:Number = ball1.x;
        var y1:Number = ball1.y;
        var x2:Number = ball2.x;
        var y2:Number = ball2.y;

        var distX:Number = x2 - x1;
        var distY:Number = y2 - y1;

        var normalX:Number = distX/distance;
        var normalY:Number = distY/distance;

        var midPointX:Number = (x1 + x2)/2;
        var midPointY:Number = (y1 + y2)/2;

        ball1.x = midPointX - normalX * ball1.radius;
        ball1.y = midPointY - normalY * ball1.radius;
        ball2.x = midPointX + normalX * ball2.radius;
        ball2.y = midPointY + normalY * ball2.radius;

        var vector:Number = (( ball1.speedX - ball2.speedX ) * normalX) +
                (( ball1.speedY - ball2.speedY ) * normalY );
        var velX:Number = vector * normalX;
        var velY:Number = vector * normalY;

        ball1.speedX -= velX;
        ball1.speedY -= velY;
        // при столкновении импульс отдаётся
        // второму шару с коэффициентом распыления энергии
        ball2.speedX += velX * 0.8;
        ball2.speedY += velY * 0.8;
    }

    /* HIT TEST WITH BOX */
    public function hitTestWithBox(curBall:Ball):void
    {
        // если мяч коснулся низа
        if(curBall.y  >= _box.BOTTOM - curBall.diameter)
        {
            // добавляем трение
            curBall.speedY *= FRICTION;
            // меняем направление на противоположное
            curBall.speedY = -curBall.speedY;
            // предотвращаем попадание за пределы ящика
            curBall.y = _box.BOTTOM - curBall.diameter;
        }
        // если мяч коснулся верха
        if(curBall.y  <= _box.TOP)
        {
            curBall.speedY *= FRICTION;
            curBall.speedY = -curBall.speedY;
            curBall.y  = _box.TOP
        }
        // если мяч коснулся левой стороны
        if(curBall.x  <= _box.LEFT)
        {
            curBall.speedX *= FRICTION;
            curBall.speedX = -curBall.speedX;
            curBall.x  = _box.LEFT;
        }
        // если мяч коснулся правой стороны
        if(curBall.x  >= _box.RIGHT - curBall.diameter)
        {
            curBall.speedX *= FRICTION;
            curBall.speedX = -curBall.speedX;
            curBall.x  = _box.RIGHT - curBall.diameter;
        }
    }

    /* ON SWITCH CLICK */
    private function onSwitchClick (e:MouseEvent):void
    {
        // если гравитация включена...
        if (_switchBtn.currentFrame == 1)
        {
            // ...выключаем
            _switchBtn.gotoAndStop(2);
            _isGravity = false;
        }
        // иначе включаем
        else
        {
            _switchBtn.gotoAndStop(1);
            _isGravity = true;
        }
    }
		
    /* GRAVITY ON */
    private function gravityOn():void
    {
        for each(var ball:Ball in _ballArray)
        {
            ball.speedY += GRAVITY_SPEED;
        }
    }

	/* DRAG ON */
    private function dragOn(e:MouseEvent):void
    {
        if (e.target is Ball)
        {
            e.target.startDrag(false, new Rectangle(_box.x, _box.y,
                                    _box.width - Ball(e.target).diameter,
                                    _box.height - Ball(e.target).diameter));
            _stage.removeEventListener(Event.ENTER_FRAME, mainLoop);
        }
    }

    /* DRAG OFF */
    protected function dragOff(e:MouseEvent):void
    {
        if (e.target is Ball)
        {
            e.target.stopDrag();
            _stage.addEventListener(Event.ENTER_FRAME, mainLoop);
        }
    }

    /* CALCULATE BALLS DISTANCE */
    private static function calculateBallsDistance(ball1:Ball, ball2:Ball):Number
    {
        var x1:Number = ball1.x;
        var y1:Number = ball1.y;
        var x2:Number = ball2.x;
        var y2:Number = ball2.y;

        // вычисляем дистанцию по теореме Пифагора
        var dist:Number = Math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));

        return dist;
    }
}
}
