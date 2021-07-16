package
{

import flash.display.Sprite;

[SWF (width="550", height="400", backgroundColor="0x000000", frameRate="45")]
public class GravityBalls extends Sprite
{
    private var _mainController:MainController;

    public function GravityBalls()
    {
        _mainController = new MainController(stage, 10);
        _mainController.init();
        _mainController.start();
    }
}
}
