
*topMenu|�g�b�v���j���[

@history enabled="false"
@position page="back" layer="message" opacity="0"


@image storage="prototype.kag/demo/images/startMenu" layer="0" page="back" visible="true" 
@trans method="crossfade" time=500
@wt


@locate x=800 y=250
@button graphic="prototype.kag/demo/images/demo_button_start" name="�Q�[���X�^�[�g" target="*topMenuEnd"

@locate x=800 y=300
@button graphic="prototype.kag/demo/images/demo_button_load" name="���[�h" target="*topMenuEnd"

@locate x=800 y=345
@button graphic="prototype.kag/demo/images/demo_button_config" name="�ݒ�"

@locate x=800 y=395
@button graphic="prototype.kag/demo/images/demo_button_extra" name="�G�N�X�g��"



@s

*topMenuEnd|�g�b�v���j���[�I��

@history enabled="true"
@cm

@return
