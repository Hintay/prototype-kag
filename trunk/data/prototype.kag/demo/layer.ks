
*layerDemo|レイヤーデモ

レイヤーに適当に描画します
@l
@r
@iscript

//レイヤーデモ

var layer = new Layer( kag , kag.fore.messages[0]);

var font = layer.font;
var face = font.face;
layer.absolute = 100000000;
layer.setPos( 220 , 120 );
layer.setImageSize( 200 , 200 );
layer.setSizeToImageSize();
layer.fillRect( 0 , 0 , 200 , 200 , 0xFF888888 );
layer.fillRect( 0 , 100 , 200 , 1 , 0xFFFF0000 );
layer.fillRect( 100 , 0 , 1 , 200 , 0xFFFF0000 );
layer.visible = true;
font.height = 64;
function dmResult( color ) {
    layer.drawText( 100 , 100 ,  "貧", 0xFFFF0000);
}

font.angle = 0;
dmResult( "0xFF0000" );
font.angle = 900;
dmResult( "0x00FF00" );
font.angle = 1800;
dmResult( "0x0000FF" );



@endscript

@link target="*layerDemoEnd"
次へ
@endlink
@s
*layerDemoEnd|レイヤーデモ終了
@cm
@iscript
layer = null;
@endscript

@return
