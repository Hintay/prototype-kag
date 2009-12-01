;kkde_preview_init.ks - KKDEプレビュー実行初期化
;Copyright (C) 2009 PORING SOFT

*init|
;-----------------------------------------------------------
;プラグイン・マクロの読み込み
@loadplugin module="extrans.dll"
@call storage="world.ks"
;@eval exp="KAGLoadScript('kkde_preview.tjs');"


*start|
;-----------------------------------------------------------
;実行開始
@jump storage="kkde_preview_run.ks"

