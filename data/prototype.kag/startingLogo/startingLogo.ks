
*start|����҃��S�\����ʂ̊J�n���x��

@macro name=starting_logo

@history enabled="false"
;���b�Z�[�W�E�B���h�E�̔w�i���\����
@position page="back" layer="message" opacity="0"
@wait time="500"
;���S���N���X�t�F�[�h�ŕ\��
@image storage=%logo|logo layer="0" page="back" visible="true" 
@trans method="crossfade" time=%start|5000
@wt

;������������ʔ����Ȃ��̂ŏ��������܂�
@wait time=%wait|10000


;���S������
@layopt layer="0" page="back" visible="false"
@trans method="crossfade" time=%end|5000
@wt
;kagpp_first.ks�֖߂�
@history enabled="true"
@endmacro
@return


