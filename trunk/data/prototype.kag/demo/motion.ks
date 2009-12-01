*motionDemo|モーションデモ

@call storage="prototype.kag/layer/LayerMotionPlugin.ks"

;モーションサンプル
[layopt layer=0 page=fore left=100 top=100 visible=true]
[layopt layer=0 page=back visible=true]
[layopt layer=message page=fore visible=true]
[layopt layer=message page=back visible=true]
[image layer=0 page=fore storage="prototype.kag/demo/images/human"]
@laycount layers="10"

てくてくします。[l][r]
[motion_start layer=0 page=fore name="てくてく" wait=false]
[l][r]
飛びのきます。[l][r]
[motion_start layer=0 page=fore name="飛びのく"]
[l][r]
移動します。[l][r]
[motion_krkrmove pathx="(100,2000,-2)" pathy="(100,2000,-2)" wait=false]
[motion_krkrmove_wait]
ふわふわします。[l][r]
[motion_start layer=0 page=fore name="ふわふわ" wait=false]
[l][r]

ふわふわ中に消します。まず backlay[l][r]
[backlay]
次はmotion_stopいくぜ？[l][r]
[motion_stop layer=0 page=back]
[motion_stop layer=0 page=fore]
layopt[l][r]
[layopt layer=0 page=back visible=0]
transいくぜ？[l][r]
[trans method=crossfade time=2000]
[wt]
おしまい。
[l][r]

@cm
@return
