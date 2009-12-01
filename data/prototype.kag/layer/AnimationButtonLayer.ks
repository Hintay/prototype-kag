; ���d�o�^��h�~
[return cond="typeof(global.animbuttons_obj) != 'undefined'"]

[iscript]

// �c���
// 1) �{�^�������āu�ŏ��ɖ߂�v���o���Ȃ��B�{�^���������u�ԂɃ{�^����������
//    ����Ă��܂��A���̎��̓��삪�ł��Ȃ����߁BonMouseClick�Q�ƁB
// 2) �{�^�������ƁA��x�t�H�[�J�X���O��Ă��܂��B
// 3) selProcessLock�������̂ŁA��d���s�ł����Ⴄ���Ƃ����邩���H
// 4) �L�[�{�[�h����(focus)�̂��Ƃ�S���l���Ă��Ȃ�
// 5) �A�j���[�V��������Transition�͖��`�F�b�N�B�����Ƃł��邩�H



// �A�j���[�V�����������N�{�^�����C��
class AnimationButtonLayer extends ButtonLayer
{
	// �O���t�B�J���{�^���Ƃ��ē��삷�邽�߂̃��C��
	var key;	// �{�^���̎��ʎq
	var storage;	// �N���b�N���ɃW�����v����V�i���I�t�@�C��
	var target;	// �N���b�N���ɃW�����v����V�i���I���x��
	var countpage;	// [button]�^�O��countpage�Q��

	// �A�j���[�V�����{�^���̒ǉ�����
	var conductor;		// �A�j���[�V�����̃R���_�N�^
	var buttonHeight;	// �{�^���̏c��(�摜�T�C�Y����͂킩��Ȃ�����)
	var animIndex;		// �A�j���[�V�����̃C���f�b�N�X
	var animInfo;		// �A�j���[�V������`�t�@�C����
	var maxpatternnum;	// ���݂̃A�j���[�V�����Z���ő吔
	var options;		// �ݒ肳�ꂽsuper�N���X�̃{�^���I�v�V����

	function AnimationButtonLayer(win, parent, i_key)
	{
		// �R���X�g���N�^
		super.ButtonLayer(...);
		focusable = false; // �t�H�[�J�X�͎󂯎��Ȃ�

		key           = i_key === void ? "all" : i_key;
		storage       = void;
		target        = void;
		countpage     = true;
		hint          = void;

		conductor     = new AnimationConductor( this );
		buttonHeight  = 1;		// �Ƃ肠����1��
		animIndex     = 0;
		animInfo      = '';
		maxpatternnum = 1;
		options       = %[];
	}

	function finalize()
	{
		stopAnim();
		invalidate conductor;
		super.finalize(...);
	}

	function stopAnim()
	{
		conductor.stop();
		animIndex = 0;
	}

	// �A�j���[�V�������J�n����B����܂ł�animInfo���ݒ肳��Ă��邱�ƁB
	// jumpAnim()�Ɠ������ꂽ�B
	function startAnim(label)
	{
		stopAnim();
		if(animInfo != "") {
			// �A�j���[�V������`�t�@�C�������݂���
			conductor.startLabel = label;
			conductor.stopping = false;
			conductor.running = true;
			conductor.clearCallStack();
//			conductor.interrupted = Anim_interrupted;
			conductor.loadScenario(animInfo);
			conductor.goToLabel(label);
			conductor.startProcess(true);
		}
	}

	// �A�j���[�V�������t�@�C����ǂݍ���
	function loadAnimInfo(storage)
	{
		animInfo = Storages.chopStorageExt(storage) + ".bsd";
		animInfo = Storages.getPlacedPath(animInfo);
		// animInfo�����������ꍇ�͕��ʂ�Button�Ƃ��ĐU����
		startAnim("*normal");
	}

	// �C���[�W��ǂݍ��ށBbuttonHeight�͂����Ŏw��
	function loadImages(storage, height)
	{
		stopAnim();
		super.loadImages(storage);
		maxpatternnum = imageHeight \ height;
		// KAGLayer��height�ɒ��ڗ������ށB
		// ButtonLayer����imageHeight���ς���Ă��܂����߁B
		global.KAGLayer.height = buttonHeight = height;

//		callOnPaint = true;
//		Butt_imageLoaded = true;

		// �A�j���[�V������񂪂���Γǂ�
		loadAnimInfo(storage);
	}

	// �I�v�V������ݒ�
	function setOptions(elm)
	{
		// ������I�v�V����
		var stropts = [
			"key", "graphic",
			"onclick", "clickse", "clicksebuf", "exp",
			"onenter", "enterse", "entersebuf",
			"onleave", "leavese", "leavesebuf",
			"storage", "target"
		];
		// ignore�I�v�V����(���g�܂���super�N���X��property�łȂ�����)
		var ignoreopts = [
			"key", "graphic", "height",
			"onclick", "clickse", "clicksebuf", "exp",
			"onenter", "enterse", "entersebuf",
			"onleave", "leavese", "leavesebuf",
		];

		// ���b�Z�[�W������艜�ɕ\��
		elm.absolute = 2000000-3            if(elm.absolute === void);
		loadImages(elm.graphic, elm.height) if(elm.graphic  !== void);
		// �w��\�ȃI�v�V�����ݒ肪����

		// onclick(or exp)��ݒ�
		if(elm.exp !== void) {
			elm.onclick = elm.exp;
			elm.exp = void;
		}

		// �w��I�v�V������K�X���l�ɕϊ����Ȃ��玩�g�̃v���p�e�B�ɐݒ�
		var ary = [];
		ary.assign( elm );
		for(var i = ary.count-2; i >= 0; i -= 2) {
			var e = options[ary[i]] = ary[i+1];
			// ���l�ɂł�����̂͐��l�ɂ��Ă��܂��B�����̂��B
			if(typeof(e) == "String" && stropts.find(ary[i]) < 0)
				if(+e != 0 || e == "0")
					options[ary[i]] = e = +e;
			// options�ɂ͕ۑ��Athis�ɂ͕K�v�Ȃ�ݒ�(property�̂�)
			this[ary[i]] = e if(ignoreopts.find(ary[i]) < 0);
		}
	}

	// �\����Ԃ̃e���|�����ύX(�E�N���b�N���b�Z�[�WOff�̎��Ɏg��)
	function setTemporalVisible(flag)
	{
		if(!flag)
			visible = false;
		else
			visible = options.visible; // �\����Ԃ��ۑ�����Ă��
	}


	function getSoundExpression(exp, storage, buf)
	{
		// �T�E���h��炷���߂̎����쐬���āAprop�ɐݒ肷��B
		// exp �ɂȂɂ������������ꍇ�̓J���}�łȂ�
		var ret = exp;
		if(storage !== void) {
			buf = 0 if(buf === void);
			ret = "(kag.se[" + buf + "].play(%[storage:\"" + storage.escape() +"\"]))" + ((exp === void) ? "" : ", (" + exp + ")");
		}
		return( ret );
	}

	// �N���b�N���̓���
	function onMouseDown()
	{
		super.onMouseDown(...);
		startAnim('*onclick');	// "*onclick"����A�j���J�n
	}

	function onMouseUp(x, y, button, shift)
	{
		super.onMouseUp(...);
		var exp = getSoundExpression( options.onclick, options.clickse, options.clicksebuf );
		if(enabled && button == mbLeft && exp !== void) {
			Scripts.eval(exp);
//			return;
//			// �u�^�C�g���ɖ߂�v�̎��͂���return���Ȃ��ƃG���[��
			// �Ȃ����Ⴄ���ǁc�ǂ�����B
		}
		if(storage !== void || target !== void)
			window.process( storage, target, countpage );
	}

	function onMouseEnter()
	{
		var exp = getSoundExpression( options.onenter, options.enterse, options.entersebuf );
		if(/*!parent.selProcessLock && */exp !== void)
			Scripts.eval(exp);
		super.onMouseEnter(...);
		startAnim('*onenter');	// "*onenter"����A�j���J�n
	}

	function onMouseLeave()
	{
		var exp = getSoundExpression( options.onleave, options.leavese, options.leavesebuf );
		if(/*!parent.selProcessLock && */exp !== void)
			Scripts.eval(exp);
		super.onMouseLeave(...);
		startAnim('*normal');	// "*normal"����A�j���J�n
	}

	function assign(src)
	{
		super.assign(src);
		storage   = src.storage;
		target    = src.target;
		countpage = src.countpage;
		hint      = src.hint;

		conductor.assign( src.conductor );
		buttonHeight  = src.buttonHeight;
		animIndex     = src.animIndex;
		animInfo      = src.animInfo;
		maxpatternnum = src.maxpatternnum;
		(Dictionary.assignStruct incontextof options)(src.options);
	}

	// ���݂̉摜��\������(s:0 = ���ʁA1 = clicked�A2 = entered)
	function drawState(s)
	{
		super.drawState(s);
		// �C���[�W�������ꍇ�ɁA�c�ʒu��ύX����B
		// ����ŃA�j���[�V�������ۂ��B
		if(Butt_imageLoaded)
			super.imageTop = -buttonHeight*animIndex;
		update();
	}


// ------ ��������A�j���[�V������`�t�@�C���̃^�O�n���h�� --------------------

	function pattern(elm)
	{
		if(elm.num !== void)
			maxpatternnum = +elm.num;
		if(elm.index !== void) {
			var str = elm.index.replace( /index/, animIndex );
			animIndex = Scripts.eval(str);
		}

		// �Ō�ɗL���ȃp�^�[��No.�͈̔͂Ɏ��߂�
		animIndex %= maxpatternnum;
		// �ŁA�`��
		draw();
		return 0;
	}

	function s(elm)
	{
		// ��~
		elm.context.running = false;
		return -1; // ��~
	}

	function wait(elm)
	{
		return elm.time;
	}

	function eval(elm)
	{
		Scripts.eval(elm.exp); // elm.exp �����Ƃ��Ď��s
		return 0;
	}


// ------ �������烍�[�h�E�Z�[�u ----------------------------------------

	// �Z�[�u���ɏォ��Ă΂��
	function store()
	{
		var dic = %[];
		dic.storage         = storage;
		dic.target          = target;
		dic.countpage       = countpage;
                dic.hint            = hint;

		dic.buttonHeight    = buttonHeight;
		dic.animInfo        = animInfo;
		dic.maxpatternnum   = maxpatternnum;
		dic.options         = %[];
		(Dictionary.assignStruct incontextof dic.options)(options);
		return(dic);
	}

	// ���[�h���ɏォ��Ă΂��
	function restore(dic)
	{
		if(dic === void)
			return;
		storage         = dic.storage;
		target          = dic.target;
		countpage       = dic.countpage;
                hint            = dic.hint;

		buttonHeight    = dic.buttonHeight;
		animInfo        = dic.animInfo;
		maxpatternnum   = dic.maxpatternnum;
		(Dictionary.assignStruct incontextof options)(dic.options);
		setOptions(options);
	}
}



// �A�j���[�V�����{�^���v���O�C��
class AnimationButtonPlugin extends KAGPlugin
{
	var animButtons = []; // �{�^���z��

	function AnimationButtonPlugin()
	{
		// AnimationButtonPlugin �R���X�g���N�^
		// �ŏ��͔z�����ɂ��邾���Bobj�̔z�񂾂��Aobj.addopts�Ƃ���
		// ���܂����������Ă���B
		animButtons  = [];
	}

	function finalize()
	{
		invalidateAllButtons();
		super.finalize(...);
	}

	function invalidateAllButtons()
	{
		// �{�^���𖳌���
		invalidateButtons();
	}

	// �{�^���ǉ�(�O�i�E�w�i�̕Б��̂ݒǉ�)
	function addButton(elm)
	{
		elm.page    = 'fore' if(elm.page === void);
		elm.visible = true   if(elm.visible === void);
		var parent = elm.page=='fore' ? kag.fore.base : kag.back.base;

		var obj = new AnimationButtonLayer(kag, parent, elm.key);
		obj.setOptions(elm);
		animButtons.add(obj);
	}

	// key��page�ɑΉ�����{�^����T��
	function searchButtons(key, page = 'both')
	{
		var retary = [];
		for(var i = animButtons.count-1; i >= 0; i--)
			if(animButtons[i].key == key &&
			   (page == 'both' ||
			   animButtons[i].options.page == page))
				retary.add(animButtons[i]);
		return(retary);
	}

	function setOptionsForAllButtons(elm)
	{
		for(var i = animButtons.count-1; i >= 0; i--)
			animButtons[i].setOptions(elm);
	}

	function setOptions(elm)
	{
		if(elm.key === void) {
			for(var i = animButtons.count-1; i >= 0; i--)
				animButtons[i].setOptions(elm);
		}
		else {
			var objary = searchButtons(elm.key, elm.page);
			for(var i = objary.count-1; i >= 0; i--)
				objary[i].setOptions(elm);
		}
	}

	function onStore(f, elm)
	{
		// �x��ۑ�����Ƃ�
		var dic = f.animationButtons = %[];
			// f.animationButtons �Ɏ����z����쐬
		dic.animButtons = [];
		for(var i = animButtons.count-1; i >= 0; i--)
			dic.animButtons[i] = animButtons[i].store();
	}

	function onRestore(f, clear, elm)
	{
		// �x��ǂݏo���Ƃ�
		invalidateAllButtons();
		var dic = f.animationButtons;

		if(dic !== void)
		{
			// animButtons �̏�񂪞x�ɕۑ�����Ă���
			// �{�^���쐬�A�I�v�V�����ݒ�
			for(var i = dic.animButtons.count-1; i >= 0; i--)
				addButton( dic.animButtons[i] );
		}
	}

	function onStableStateChanged(state)
	{
		// �u����v( s l p �̊e�^�O�Œ�~�� ) ���A
		// �u���s���v ( ����ȊO ) ���̏�Ԃ��ς�����Ƃ��ɌĂ΂��
		// ���s���͊e�{�^���𖳌��ɂ���
		setOptionsForAllButtons(%[ enabled:state ]);
	}

	function onMessageHiddenStateChanged(hidden)
	{
	// ���b�Z�[�W���C�������[�U�̑���ɂ���ĉB�����Ƃ��A�����Ƃ���
	// �Ă΂��B���b�Z�[�W���C���ƂƂ��ɕ\��/��\����؂�ւ������Ƃ���
	// �����Őݒ肷��B
		if(hidden)
			for(var i = animButtons.count-1; i >= 0; i--)
				animButtons[i].setTemporalVisible(false);
		else
			for(var i = animButtons.count-1; i >= 0; i--)
				animButtons[i].setTemporalVisible(true);
	}

	// �w�肳�ꂽ�y�[�W�ɑ�����S�Ă�animbutton���폜����
	function invalidateButtonsOnPage( page )
	{
		if(page === void || page == 'both') {
			// ����ȃg�R�ōċN(?)�Ăяo���c
			invalidateButtonsOnPage( 'fore' );
			invalidateButtonsOnPage( 'back' );
			return;
		}
		for(var i = animButtons.count-1; i >= 0 ; i--)
			if(animButtons[i].options.page == page) {
				var obj = animButtons[i];
				animButtons.erase(i);
				invalidate obj;
			}
	}

	// key��page�ɑΉ�����{�^�����폜����
	function invalidateButtons( key = 'all', page )
	{
		if(key == 'all')
			invalidateButtonsOnPage( page );
		else {
			var objary = searchButtons( key, page );
			for(var i = objary.count-1; i >= 0; i--) {
				var obj = objary[i];
				animButtons.remove(obj);
				invalidate obj;
			}
		}
	}

	function onCopyLayer(toback)
	{
		// ���C���̕\�������̏��̃R�s�[
		// backlay �^�O��g�����W�V�����̏I�����ɌĂ΂��
		if(toback)
		{
			// �\����
			invalidateButtonsOnPage( 'back' );
			for(var i = animButtons.count-1; i >= 0 ; i--) {
				var elm = %[];
				(Dictionary.assignStruct incontextof elm)
						(animButtons[i].options);
				elm.page = 'back';
				addButton(elm);
			}
		}
		else {
			// �����\
			invalidateButtonsOnPage( 'fore' );
			for(var i = animButtons.count-1; i >= 0 ; i--) {
				var elm = %[];
				(Dictionary.assignStruct incontextof elm)
						(animButtons[i].options);
				elm.page = 'fore';
				addButton(elm);
			}
		}

	}

	function onExchangeForeBack()
	{
		// ���ƕ\�̊Ǘ���������

		// children = true �̃g�����W�V�����ł́A�g�����W�V�����I������
		// �\��ʂƗ���ʂ̃��C���\���������������ւ��̂ŁA
		// ����܂� �\��ʂ��Ǝv���Ă������̂�����ʂɁA����ʂ��Ǝv����
		// �������̂��\��ʂɂȂ��Ă��܂��B�����̃^�C�~���O�ł��̏���
		// ����ւ���΁A�����͐����Ȃ��ōςށB

		// �����ŕ\��ʁA����ʂ̃��C���Ɋւ��ĊǗ����ׂ��Ȃ̂�
		// animButtons[xx].options.page����
		for(var i = animButtons.count-1; i >= 0 ; i--)
			if(animButtons[i].options.page == 'fore')
				animButtons[i].options.page = 'back';
			else
				animButtons[i].options.page = 'fore';
	}
}

kag.addPlugin(global.animbuttons_obj = new AnimationButtonPlugin(kag));
// �v���O�C���I�u�W�F�N�g���쐬���A�o�^����

[endscript]


; �A�j���[�V�����{�^����o�^����}�N��
; [animbutton key="xx" storage="xx" height=## page="xx" top=## left=##]
[macro name="animbutton"]
[eval exp="animbuttons_obj.addButton(mp)"]
; mp ���}�N���ɓn���ꂽ���������������z��I�u�W�F�N�g
[endmacro]

; �w��y�[�W�̃A�j���[�V�����{�^�����폜����}�N��
; [erase_animbutton key="xx" page="fore|back"]
[macro name="animbutton_erase"]
[eval exp="animbuttons_obj.invalidateButtons(mp.key, mp.page)"]
[endmacro]

; �w��{�^���ɃI�v�V������ݒ肷��(top=�Ƃ�graphic=�Ƃ�onenter=�Ƃ�)
[macro name="animbutton_setopt"]
[eval exp="animbuttons_obj.setOptions(mp)"]
[endmacro]


[return]
