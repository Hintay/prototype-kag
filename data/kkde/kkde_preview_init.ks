;kkde_preview_init.ks - KKDE�v���r���[���s������
;Copyright (C) 2009 PORING SOFT

*init|
;-----------------------------------------------------------
;�v���O�C���E�}�N���̓ǂݍ���
@loadplugin module="extrans.dll"
@call storage="world.ks"
;@eval exp="KAGLoadScript('kkde_preview.tjs');"


*start|
;-----------------------------------------------------------
;���s�J�n
@jump storage="kkde_preview_run.ks"

