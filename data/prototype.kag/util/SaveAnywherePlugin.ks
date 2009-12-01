; ���ɒ�`�ς݂Ȃ炷���߂�
[return cond="typeof(global.saveAnywhere_object) != 'undefined'"]

; �ȉ��A����`�̎��̂ݎ��s

; �u�ǂ��ł��Z�[�u�v���O�C�����v Ver 0.1 2007/07/31 by KAICHO
; ���ǔ�������������}�V�ɂ����ǂ��ł��Z�[�u�v���O�C���B


[iscript]
/*
	�ǂ��ł��Z�[�u�v���O�C��
*/
class SaveAnywherePlugin extends KAGPlugin
{
	var labelstack;		// ���x��No�̃X�^�b�N
	var extend_call;	// SaveAnywhere�p��[call]�^�O�g���t���O
	var pagenamestack;	// PageName�̃X�^�b�N

	var org_onLabel;	// ���x���ʉߎ��̃I���W�i������
	var org_onCall;		// [call]�Ăяo�����̃I���W�i������
	var org_onReturn;	// [return]���̃I���W�i������(extraConductor��)
	var org_onAfterReturn;	// [return]�̌�̃I���W�i������

// �e�X�g�p�B����window.incRecordLabel���e�X�g���鎞�̂ݒ�`���邱��
//var org_incRecordLabel;

	// �R���X�g���N�^
	function SaveAnywherePlugin( window, extend_call_flag = false )
	{
		super.KAGPlugin();
		this.window = window;

		labelstack        = [ int(1) ];
		extend_call       = extend_call_flag;
		pagenamestack	  = [];

		org_onLabel       = window.mainConductor.onLabel;
		org_onCall        = window.mainConductor.onCall;
		org_onReturn      = window.extraConductor.onReturn;
		org_onAfterReturn = window.mainConductor.onAfterReturn;

// �e�X�g�p�B����window.incRecordLabel���e�X�g���鎞�̂ݒ�`���邱��
// org_incRecordLabel = window.incRecordLabel;

		// onLabel(���x���ʉߎ�)�ɁAlabelno�����Z�b�g���鏈����ǉ��B
		// ����Ȃ��Ƃ��ăC�C�́H�X�Q���ȁB
		window.mainConductor.onLabel = function( label, page )
		{
			// "*label_anywhere"�ȊO�̃��x������No��1�ɂ���
			if(label != "*label_anywhere")
				saveAnywhere_object.labelstack[0] = int(1);

			// �ȉ��I���W�i���Ɠ����B�[���I���W�i���͂��ꂾ���B
			return saveAnywhere_object.org_onLabel(...);
		} incontextof (window.mainConductor);


		// onCall([call]�^�O�g�p��)�ɁAlabelno��ۑ����鏈����ǉ�
		window.mainConductor.onCall = function()
		{
// dm( "##################### onCall" );
			if(saveAnywhere_object.extend_call) {
				// �g��call�Ȃ炱���ŒʉߋL�^���Ƃ�
// dm( '�Z�[�u�������x��(call) = ' + kag.currentRecordName );
				kag.incRecordLabel( true );
				// �y�[�W����ۑ����Ă���(void�̎����l���K�v�H)
				saveAnywhere_object.pagenamestack.push(kag.currentPageName);
			}

			// ���݂�label/labelstack��ۑ�����([0]��1��push)
			saveAnywhere_object.labelstack.insert( 0, int(1) );
			// �ȉ��I���W�i���Ɠ���
			return saveAnywhere_object.org_onCall(...);
		} incontextof (window.mainConductor);

		// onReturn([returnl]��)�ɁAlabelno�𕜋A���鏈����ǉ�
		// ���ʗv���̂����AextraConductor����̍ŏIreturn�̏ꍇ�A
		// kag.currentLabel��kag.currentRecordName���߂��Ă��܂��̂ŁB
		window.extraConductor.onReturn = function()
		{
// dm( "##################### onReturn" );
			// �܂��I���W�i�����Ă�
			var ret= saveAnywhere_object.org_onReturn(...);
			// �Z�[�u���x��(�[���ʉߋL�^���x��)�ݒ�
			saveAnywhere_object.overwriteCurrentLabel();
			return ret;
		} incontextof (window.mainConductor);


		// onAfterReturn([returnl]��)�ɁAlabelno�𕜋A���鏈����ǉ�
		window.mainConductor.onAfterReturn = function()
		{
// dm( "##################### onAfterReturn" );
			// �܂��I���W�i�����Ă�
			var ret= saveAnywhere_object.org_onAfterReturn(...);

			// labelstack����O�ɖ߂�([0]���폜����)�A�ݒ肷��
			saveAnywhere_object.labelstack.erase( 0 );
			saveAnywhere_object.overwriteCurrentLabel();
// dm( '���ɃZ�[�u����\��̃��x��(�߂�) = ' + kag.currentRecordName );

			if(saveAnywhere_object.extend_call) {
				// �g��call�Ȃ炱���ŐV���x����ݒ�
				saveAnywhere_object.setCurrentLabel();
				// �g���R�[���Ȃ�y�[�W�������ɖ߂�
				var p=saveAnywhere_object.pagenamestack.pop();
				kag.currentPageName = p;
				kag.pcflags.currentPageName = p;
			}
// dm( '���ɃZ�[�u����\��̃��x��(��) = ' + kag.currentRecordName );
			// �X�L�b�v�`�F�b�N
			if(!kag.usingExtraConductor) {
				if(!kag.getCurrentRead() && kag.skipMode != 4)
					kag.cancelSkip(); // ���ǁA�X�L�b�v��~
			}
			return ret;
		} incontextof (window.mainConductor);

/* �e�X�g�p�B�ʉߋL�^�������x����\������
window.incRecordLabel = function(count)
{
	if(count && kag.currentRecordName!==void && kag.currentRecordName!="")
		dm("########### incRecordLabel = " + kag.currentRecordName);
	saveAnywhere_object.org_incRecordLabel(...);
} incontextof (window.mainConductor);
*/
	}

	// �f�X�g���N�^
	function finalize()
	{
		invalidate labelstack;
		invalidate pagenamestack;
		window.mainConductor.onLabel       = org_onLabel;
		window.mainConductor.onCall        = org_onCall;
		window.extraConductor.onReturn     = org_onReturn;
		window.mainConductor.onAfterReturn = org_onAfterReturn;
		super.finalize(...);
	}

	// kag.currentLabel��kag.currentRecordName���㏑������
	function overwriteCurrentLabel()
	{
		var labelno = int(labelstack[0]);
		if(labelno > 1) { // ����[label]��ʉ߂��Ă���
			kag.currentLabel += ':' + (+labelno-1);
// dm( "#################### kag.currentLabel = " + kag.currentLabel );
			kag.setRecordLabel( kag.conductor.curStorage,
					    kag.currentLabel );
		}
	}

	// �Z�[�u���鎞�̓���
	function onStore( f, elm )
	{
		var dic = f.saveanywhere = %[];
		dic.labelstack = [];
		(Array.assign incontextof dic.labelstack)(labelstack);
		dic.pagenamestack = [];
		dic.pagenamestack.assign(pagenamestack);
		dic.extend_call = extend_call;
	}
	// ���[�h���鎞�̓���
	function onRestore( f, clear, elm )
	{
		var dic = f.saveanywhere;
		if(dic === void) {
			labelstack  = [ int(0) ];
			extend_call = false;
		} else {
			(Array.assign incontextof labelstack)(dic.labelstack);
			extend_call = dic.extend_call;
			pagenamestack.assign(dic.pagenamestack);
		}
	}

	// ���݂̃��x��(=call�O�̃��x��)�����ɁA(���ǔ���̂��߂�)
	// curRecordName��ݒ�B�ݒ肷�邾���ŃZ�[�u���Ȃ��B
	// ���́A���̃��x�����͊��ǔ���̂��߂����ɕK�v�B�Z�[�u�֌W��
	// *label_anywhere�ɂ�(�X�^�b�N���݂�)��������邩��B
	function setCurrentLabel()
	{
		kag.currentLabel = kag.conductor.curLabel+':'+ labelstack[0]++;
		kag.setRecordLabel(kag.conductor.curStorage,kag.currentLabel);
	}
}

// �f�t�H���g�Ŋg��call�g���悤�ɂ���������B�����̂��ȁB
kag.addPlugin(global.saveAnywhere_object = new SaveAnywherePlugin(kag, true));

[endscript]
[endif]

;��label�}�N��
[macro name="label"]
; extend_call�t���O������ƁAcall���O�̃��x���ƒ���̃��x���������I��
; �ύX(":3"�Ƃ��t����)���Ċ��ǔ���z��Ɋi�[����B
[eval exp="mp.extend_call_save = saveAnywhere_object.extend_call"]
[eval exp="saveAnywhere_object.extend_call = true"]

; *label_anywhere���Z�[�u�\���x���Ƃ��Đݒ�
[call storage="saveAnywhere.ks" target="*label_anywhere"]

; extend_call�t���O�����ɖ߂�
[eval exp="saveAnywhere_object.extend_call = mp.extend_call_save"]

[endmacro]

[return]


;---------------------------------------
;���ǂ��ł��Z�[�u�p�T�u���[�`��
*label_anywhere|
[return]
