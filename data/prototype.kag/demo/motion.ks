*motionDemo|���[�V�����f��

@call storage="prototype.kag/layer/LayerMotionPlugin.ks"

;���[�V�����T���v��
[layopt layer=0 page=fore left=100 top=100 visible=true]
[layopt layer=0 page=back visible=true]
[layopt layer=message page=fore visible=true]
[layopt layer=message page=back visible=true]
[image layer=0 page=fore storage="prototype.kag/demo/images/human"]
@laycount layers="10"

�Ă��Ă����܂��B[l][r]
[motion_start layer=0 page=fore name="�Ă��Ă�" wait=false]
[l][r]
��т̂��܂��B[l][r]
[motion_start layer=0 page=fore name="��т̂�"]
[l][r]
�ړ����܂��B[l][r]
[motion_krkrmove pathx="(100,2000,-2)" pathy="(100,2000,-2)" wait=false]
[motion_krkrmove_wait]
�ӂ�ӂ킵�܂��B[l][r]
[motion_start layer=0 page=fore name="�ӂ�ӂ�" wait=false]
[l][r]

�ӂ�ӂ풆�ɏ����܂��B�܂� backlay[l][r]
[backlay]
����motion_stop�������H[l][r]
[motion_stop layer=0 page=back]
[motion_stop layer=0 page=fore]
layopt[l][r]
[layopt layer=0 page=back visible=0]
trans�������H[l][r]
[trans method=crossfade time=2000]
[wt]
�����܂��B
[l][r]

@cm
@return
