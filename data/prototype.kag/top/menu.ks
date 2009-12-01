
*topMenu|トップメニュー

@history enabled="false"
@position page="back" layer="message" opacity="0"


@image storage="prototype.kag/demo/images/startMenu" layer="0" page="back" visible="true" 
@trans method="crossfade" time=500
@wt


@locate x=800 y=250
@button graphic="prototype.kag/demo/images/demo_button_start" name="ゲームスタート" target="*topMenuEnd"

@locate x=800 y=300
@button graphic="prototype.kag/demo/images/demo_button_load" name="ロード" target="*topMenuEnd"

@locate x=800 y=345
@button graphic="prototype.kag/demo/images/demo_button_config" name="設定"

@locate x=800 y=395
@button graphic="prototype.kag/demo/images/demo_button_extra" name="エクストラ"



@s

*topMenuEnd|トップメニュー終了

@history enabled="true"
@cm

@return
