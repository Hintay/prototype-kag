
*start|著作者ロゴ表示画面の開始ラベル

@macro name=starting_logo

@history enabled="false"
;メッセージウィンドウの背景を非表示に
@position page="back" layer="message" opacity="0"
@wait time="500"
;ロゴをクロスフェードで表示
@image storage=%logo|logo layer="0" page="back" visible="true" 
@trans method="crossfade" time=%start|5000
@wt

;すぐ消えたら面白くないので少しだけまつ
@wait time=%wait|10000


;ロゴを消す
@layopt layer="0" page="back" visible="false"
@trans method="crossfade" time=%end|5000
@wt
;kagpp_first.ksへ戻る
@history enabled="true"
@endmacro
@return


