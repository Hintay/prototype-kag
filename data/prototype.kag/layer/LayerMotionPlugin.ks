; ���ɒ�`�ς݂Ȃ炷���߂�
[return cond="typeof(global.layermotions_obj) != 'undefined'"]

; �O��N���XInterpolation.ks�̓ǂݍ���
[call storage="prototype.kag/util/Interpolation.ks"]

[iscript]

// �g���K���𓾂�
function lmTrigName(layer = void, page = void, name = void)
{
	return( "endLayerMotion_" + layer + "_" + page + "_" + name );
}


// ���C�����[�V�����f�[�^�N���X�B��ԃN���X��X,Y�������B
// ���ۂ̃��C�����[�V�����ƕ������Ă���̂́A�㏑�����Ďg�����߁B
class LayerMotionDataElement
{
	var name;		// ���[�V����id
	var intp_x, intp_y;	// InterpolationX(��ԃf�[�^X), InterpolationY

	// �R���X�g���N�^
	function LayerMotionDataElement(name="", initx=0, inity=0, locatex=void, locatey=void, loopx=1, loopy=1)
	{
		var tick = System.getTickCount();
		this.name = name;
		intp_x = new Interpolation(initx, tick, locatex, loopx);
		intp_y = new Interpolation(inity, tick, locatey, loopy);
	}

	// �f�X�g���N�^
	function finalize()
	{
	}

	// X�����l���w�肷��
	function setInitValX(initx)
	{
		intp_x.setInitVal(initx);
	}
	// Y�����l���w�肷��
	function setInitValY(inity)
	{
		intp_y.setInitVal(inity);
	}

	// X���[�v��ݒ肷��
	function setLoopX(loopx)
	{
		intp_x.setLoop(loopx);
	}
	// Y���[�v��ݒ肷��
	function setLoopY(loopy)
	{
		intp_y.setLoop(loopy);
	}

	// �J�n���Ԃ�ݒ肷��
	function setInitTick(tick=System.getTickCount())
	{
		intp_x.setInitTick(tick);
		intp_y.setInitTick(tick);
	}

	// ���݂�X���W�𓾂�
	function getCurrentValueX(tick=System.getTickCount())
	{
		return intp_x.getCurrentValue(tick);
	}

	// ���݂�Y���W�𓾂�
	function getCurrentValueY(tick=System.getTickCount())
	{
		return intp_y.getCurrentValue(tick);
	}

	// �ŏI��X���W�𓾂�
	function getLastValueX()
	{
		return intp_x.getLastValue();
	}

	// �ŏI��Y���W�𓾂�
	function getLastValueY()
	{
		return intp_y.getLastValue();
	}

	// �ŏItick�𓾂�
	function getLastTick()
	{
		var retx = intp_x.getLastTick();
		var rety = intp_y.getLastTick();
		return(retx > rety ? retx : rety);
	}

	// ���C��������K�v�����ׂ�
	function isValidTick(tick)
	{
		return intp_x.isValidTick(tick) || intp_y.isValidTick(tick);
	}

	// �R�s�[����
	function assign(src)
	{
		name = src.name;
		intp_x.assign(src.intp_x);
		intp_y.assign(src.intp_y);
	}

	// �Z�[�u���ɏォ��Ă΂��
	function store(tick = System.getTickCount())
	{
		var dic = %[];
		dic.name	= name;
		dic.intp_x	= intp_x.store(tick);
		dic.intp_y	= intp_y.store(tick);
		return(dic);
	}

	// ���[�h���ɏォ��Ă΂��
	function restore(dic, tick = System.getTickCount())
	{
		if(dic === void)
			return;
		name = dic.name;
		intp_x.restore(dic.intp_x, tick);
		intp_y.restore(dic.intp_y, tick);
	}
}


class LayerMotionData extends LayerMotionDataElement
{
	var finished;		// �I���t���O
//	var finish_at_loopend;	// ���[�v�I�����܂ő҂��ďI�����邩

	// �R���X�g���N�^
	function LayerMotionData(name="", ix=0, iy=0, locx=void, locy=void, lpx=1, lpy=1)
	{
		super.LayerMotionDataElement(...);
		finished = false;
	}

	// �f�X�g���N�^
	function finalize()
	{
		super.finalize();
	}

	// �R�s�[����
	function assign(src)
	{
		super.assign(src);
		finished = src.finished;
	}

	// �Z�[�u���ɏォ��Ă΂��
	function store(tick = System.getTickCount())
	{
		var dic = super.store(tick);
		dic.finished = finished;
		return(dic);
	}

	// ���[�h���ɏォ��Ă΂��
	function restore(dic, tick = System.getTickCount())
	{
		if(dic === void)
			return;
		super.restore(dic, tick);
		finished = dic.finished;
	}
}


// ���C�����[�V����
class LayerMotion // extends LayerMotionData
{
	var layer;		// ���[�V������K�p���郌�C��(0�`������������)
	var page;		// ���[�V������K�p����y�[�W(fore/back)
	var finished;		// �S���[�V�����̏I���t���O
	var motions;		// ���[�V�����z��B�������[�V�����̕������\
	var initx, inity;	// �������W

	function LayerMotion(layer="0", page="fore", ix=void, iy=void)
	{
		this.layer  = layer;
		this.page   = page;
		this.finished = false;
		this.motions = [];

		initx = (ix !== void) ? ix : kag[page].layers[layer].left;
		inity = (iy !== void) ? iy : kag[page].layers[layer].top;
	}

	function setInitPos(x = void, y = void)
	{
		if(x !== void)
			initx = x;
		if(y !== void)
			inity = y;
	}

	// �Y�����C�����[�V�������Hlayer=void��page=void�̏ꍇ�͉��ł��}�b�`
	function isTheLayerMotion(layer, page)
	{
		return (layer === void || this.layer == layer) &&
		       (page  === void || this.page  == page || page == 'both');
	}

	function findMotion(name, findfinished = true)
	{
		for (var i = motions.count-1; i >= 0; i--)
			if (name === void || motions[i].name == name)
				if(findfinished || !motions[i].finished)
					return i;
		return -1;
	}

	// ���̃��C�����[�V������Valid���H
	function isValidTick(tick = System.getTickCount())
	{
		for (var i = motions.count-1; i >= 0; i--)
			if (!motions[i].finished &&
			     motions[i].isValidTick(tick))
				return true;
		return false;
	}

	// ���[�V�����ǉ�
	function addLayerMotion(lmd, ix=void, iy=void, lpx=void, lpy=void, tick=System.getTickCount())
	{
		var newmtn = new LayerMotionData();
		(LayerMotionDataElement.assign incontextof newmtn)(lmd);
		if (ix !== void)
			newmtn.setInitValX(ix);
		if (iy !== void)
			newmtn.setInitValY(iy);
		if (lpx !== void)
			newmtn.setLoopX(lpx);
		if (lpy !== void)
			newmtn.setLoopY(lpy);
		newmtn.setInitTick(tick);
		motions.add(newmtn);
		finished = false;
	}

	// mname�ɑΉ����郂�[�V������finished�t���O�ݒ�(mname===void�őS��)
	function setFinishFlag(mname)
	{
		var finishflg = true;
		for (var i = motions.count-1; i >= 0; i--)
			if (mname === void || motions[i].name == mname)
				motions[i].finished = true;
			else
				finishflg = false;
		finished |= finishflg;
	}

	// ���C���𓮂���(�e��1/60 timerCallback���[�`������Ăяo�����)
	function currentMove(tick)
	{
		var x = initx, y = inity;

		if(tick == Infinity)	// �������[�v��������0�ɂ����Ⴄ
			tick = 0;
		for (var i = motions.count-1; i >= 0; i--) {
			var mot = motions[i];
			x += mot.getCurrentValueX(tick);
			y += mot.getCurrentValueY(tick);
			if (!mot.finished && !mot.isValidTick(tick)) {
				// �I�������[�V�����ɏI���}�[�N������
				mot.finished = true;
				// �폜�͐e�C���X�^���X����B�����ł͂��Ȃ�
			}
		}
		kag[page].layers[layer].setPos(x, y);
	}

	// �ŏItick�𓾂�
	function getLastTick()
	{
		var lasttick = 0;
		for (var i = motions.count-1; i >= 0; i--) {
			var tmptick = motions[i].getLastTick();
			if(lasttick < tmptick)
				lasttick = tmptick;
		}
		return lasttick;
	}

	// �I��������[�V�������폜(�e�C���X�^���X����Ă΂��)
	function delEndLayerMotion(lastpos = true)
	{
		for (var i = motions.count-1; i >= 0; i--) {
			if(motions[i].finished) {
				if(lastpos) {
					// �ŏI�ʒu�Ɉړ�
					initx += motions[i].getLastValueX();
					inity += motions[i].getLastValueY();
				}
				var trignam = lmTrigName(layer, page, motions[i].name);
				kag.conductor.trigger(trignam); // KAG�֔��C
				motions.erase(i);
				if(motions.count <= 0) { // for�̊O����_��
					// �Ō�ɍ��W���킹�ďI���
					if(lastpos)
						kag[page].layers[layer].setPos(initx, inity);
					finished = true;
				}
			}
		}
	}

	// �R�s�[����
	function assign(src)
	{
		layer		= src.layer;
		page		= src.page;
		finished	= src.finished;
		motions		= [];
		for (var i = src.motions.count-1; i >= 0; i--) {
			motions[i] = new LayerMotionData();
			motions[i].assign(src.motions[i]);
		}
		initx		= src.initx;
		inity		= src.inity;
	}

	// �Z�[�u���ɏォ��Ă΂��
	function store(tick = System.getTickCount())
	{
		var dic = %[];
		dic.layer	= layer;
		dic.page	= page;
		dic.finished	= finished;
		dic.motions	= [];
		for (var i = motions.count-1; i >= 0; i--)
			dic.motions[i] = motions[i].store(tick);
		dic.initx	= initx;
		dic.inity	= inity;
		return dic;
	}

	// ���[�h���ɏォ��Ă΂��
	function restore(dic, tick = System.getTickCount())
	{
		if(dic === void)
			return;
		layer		= dic.layer;
		page		= dic.page;
		finished	= dic.finished;
		motions	= [];
		for (var i = dic.motions.count-1; i >= 0; i--) {
			motions[i] = new LayerMotionData();
			motions[i].restore(dic.motions[i], tick);
		}
		initx		= dic.initx;
		inity		= dic.inity;
	}
}


class LayerMotions extends KAGPlugin
{
	var lmdary = [];	// ���C�����[�V�����f�[�^(�ÓI)�z��
	var lmary  = [];	// ���C�����[�V����(���ێg�p���郂�[�V����)�z��
	var timer;		// 1/60�^�C�}
	var trig;		// ���[�V�����폜�Ƃ��̃g���K
	var waittrigs = [];	// �҂���Ԃ̃g���K�z��

	// �R���X�g���N�^
	function LayerMotions()
	{
		super.KAGPlugin(...);
		lmdary 		= [];
		lmary 		= [];
		timer 		= new Timer(timerCallback, '');
		timer.interval	= 16;	// (16msec = 1/60�b�ň��)
		waittrigs = [];
		trig = new AsyncTrigger(endLM, '');
	}

	// �f�X�g���N�^
	function finalize()
	{
		super.finalize();
	}
		
	// �^�C�}�R�[���o�b�N
	function timerCallback()
	{
		var tick = System.getTickCount();
		for (var i = lmary.count-1; i >= 0; i--)
			lmary[i].currentMove(tick);
		trig.trigger();	// endLM��1/60���ƂɌĂԁB�d�����Ȃ��B
	}

	// ���O����LayerMotionData��T���A�C���f�b�N�X��Ԃ�
	function findLayerMotionData(name)
	{
		for (var i = lmdary.count-1; i >= 0; i--)
			if (lmdary[i].name == name)
				return i;
		return -1;
	}

	// ���C�����烌�C�����[�V������T���A�C���f�b�N�X��Ԃ�
	// ������void�Ȃ�A���݂�����ŏ��Ɍ��������̂�Ԃ�
	function findLayerMotions(layer, page)
	{
		for (var i = lmary.count-1; i >= 0; i--)
			if (lmary[i].isTheLayerMotion(layer, page))
				return i;
		return -1;
	}

	// ����̃��C�����[�V������T���ĕԂ��B������void�Ȃ�A���݂�����
	// �ŏ��Ɍ��������̂�Ԃ�
	function findLayerMotion(layer, page, name, findfinished = true)
	{
		var idx, jdx;

		for (idx = lmary.count-1; idx >= 0; idx--)
			if (lmary[idx].isTheLayerMotion(layer, page))
				if((jdx = lmary[idx].findMotion(name, findfinished)) >= 0) {
					var obj = lmary[idx].motions[jdx];
					if(findfinished || !obj.finished)
						return obj;
				}
		return void;
	}

	// LayerMotionData��ǉ�
	// [motion_define name= left=void, top=void, locatex= locatey= lpx=1 lpy=1]
	function addLMD(name, lx=void, iy=void, locatex="", locatey="", lpx=1, lpy=1)
	{
		delLMD(name);		// �d������̂͏���
		lmdary.add(new LayerMotionData(...));
	}

	// LayerMotionData���폜
	// [motion_undefine name=]
	function delLMD(name)
	{
		var idx = findLayerMotionData(name);
		if (idx >= 0)
			 lmdary.erase(idx);
	}

	// ���C�����[�V�����ǉ��B���f�[�^���R�s�[����ix,iy,lp��������
	// [motion_start name= layer=0 page=fore left= top= lpx=1,lpy=1]
	function addLM(layer="0", page="fore", x=void, y=void, name, ix=void, iy=void, lpx=void, lpy=void, tick = System.getTickCount())
	{
		if (page == 'both') {
			addLM(layer, 'fore', x,y, name, ix,iy, lpx,lpy, tick);
			addLM(layer, 'back', x,y, name, ix,iy, lpx,lpy, tick);
			return;
		}

		var idx = findLayerMotions(layer, page);
		if (idx < 0) {
			lmary.add(new LayerMotion(layer, page, x, y));
			idx = lmary.count-1;
		}
		var lmd = lmdary[findLayerMotionData(name)];
		lmary[idx].addLayerMotion(lmd, ix, iy, lpx, lpy, tick);
		timer.enabled = true;
	}

	// 1/60�^�C�}���ƂɌĂ΂�邪�A�^�C�}���łȂ��A�^�C�}����̔��C�ŃR�[��
	// �I���ς݃��C�����[�V�����̍폜�ƁA�K�v�ȃg���K�[�̔��C
	function endLM(lastpos = true)
	{
		for (var i = lmary.count-1; i >= 0; i--) {
			lmary[i].delEndLayerMotion(lastpos);
			if (lmary[i].finished) {
				var trignam = lmTrigName( lmary[i].layer,
							  lmary[i].page );
				kag.conductor.trigger(trignam);
				lmary.erase(i);
			}
		}
		// �o�^�ςݑ҂���Ԃ̃g���K��T���A������΃g���K���C����
		for (var i = waittrigs.count-1; i >= 0; i--) {
			var wt = waittrigs[i];
			var obj = findLayerMotion(wt.layer, wt.page, wt.name);
			if(obj === void) {
				var trignam = lmTrigName( wt.layer, wt.page,
							   wt.name );
				kag.conductor.trigger(trignam);
				waittrigs.erase(i);
			}
		}
	}

	// ���C�����[�V������~�Blayer=void, page=void, name=void�Ȃ�S���~�߂�
	// [motion_stop layer= page= name= lastpos=]
	function stopLM(layer, page, name=void, lastpos=true)
	{
		var obj;
		while((obj=findLayerMotion(layer, page, name, false)) !== void)
			obj.finished = true;
		endLM(lastpos);
	}

	// ���݂̃��[�V�������S��X���W�𓾂�
	function getFixedCurrentPosX(layer="0", page="fore")
	{
		var idx = findLayerMotions(layer, page);
		if(idx < 0)
			return kag[page].layers[layer].left;
		return lmary[idx].initx;
	}
	// ���݂̃��[�V�������S��Y���W�𓾂�
	function getFixedCurrentPosY(layer="0", page="fore")
	{
		var idx = findLayerMotions(layer, page);
		if(idx < 0)
			return kag[page].layers[layer].top;
		return lmary[idx].inity;
	}

	// ���݂̃��[�V�������S��X���W�𓾂�
	function setFixedCurrentPos(layer="0", page="fore", x=void, y=void)
	{
		var idx = findLayerMotions(layer, page);
		if(idx < 0)
			return;
		lmary[idx].setInitPos(x,y);
	}

	// �҂��\��̃g���K��o�^����
	function registerTrigger(layer, page, name)
	{
		waittrigs.add(%[ layer:layer, page:page, name:name ]);
		endLM(); // �����ɑ҂���ԂłȂ��������̂��߂Ɉ�x�`�F�b�N
	}

	// ���C���̕\�������̏��̃R�s�[
	// backlay �^�O��g�����W�V�����̏I�����ɌĂ΂��
	function onCopyLayer(toback)
	{
		// toback ? �\���� : �����\
		var page = toback ? 'back' : 'fore';
		for (var i = lmary.count-1; i >= 0; i--)
			if(lmary[i].page == page)
				lmary.erase(i);
		for (var i = lmary.count-1; i >= 0; i--) {
			var lm = new LayerMotion();
			lm.assign(lmary[i]);
			lm.page = page;
			lmary.add(lm);
		}
	}

	// ���ƕ\�̊Ǘ���������
	// backlay �^�O��g�����W�V�����̏I�����ɌĂ΂��
	function onExchangeForeBack()
	{
		// children = true �̃g�����W�V�����ł́A�g�����W�V�����I������
		// �\��ʂƗ���ʂ̃��C���\���������������ւ��̂ŁA
		// ����܂ŕ\��ʂ��Ǝv���Ă������̂�����ʂɁA����ʂ��Ǝv����
		// �������̂��\��ʂɂȂ��Ă��܂��B�����̃^�C�~���O�ł��̏���
		// ����ւ���΁A�����͐����Ȃ��B
		for(var i = lmary.count-1; i >= 0; i--)
			lmary[i].page = (lmary[i].page=='fore')?'back':'fore';
	}

	// �Z�[�u
	function onStore(f, elm)
	{
// �Z�[�u���ɂ̓��C�����W���Z�[�u�ł���ʒu�ɂ��Ă����K�v�����邩���B
		var dic = f.layermotionplugin = %[];
		dic.lmdary = [];
		dic.lmary = [];
		for (var i = lmdary.count-1; i >= 0; i--)
			dic.lmdary[i] = lmdary[i].store();
		var tick = System.getTickCount();
		for (var i = lmary.count-1; i >= 0; i--)
			dic.lmary[i] = lmary[i].store(tick);
		dic.timer_enabled = timer.enabled;
	}

	// ���[�h
	function onRestore(f, elm)
	{
		var dic = f.layermotionplugin;
		if(dic === void)
			return;
		lmdary = [];
		lmary = [];
		for (var i = dic.lmdary.count-1; i >= 0; i--) {
			lmdary[i] = new LayerMotionData();
			lmdary[i].restore(dic.lmdary[i]);
		}
		var tick = System.getTickCount();
		for (var i = dic.lmary.count-1; i >= 0; i--) {
			lmary[i] = new LayerMotion();
			lmary[i].restore(dic.lmary[i], tick);
		}
		timer.enabled = dic.timer_enabled;
	}

	// ���΍��W���΍��W�ɕϊ�����֐��B����ȃR���������������̂��B
	function getRelPathFromAbsPathX(layer="0", page="fore", init=getFixedCurrentPosX(layer, page), relpath)
	{
		if(relpath === void)
			return void;
		var ret = "";
		var path = relpath.split(/[,()]/);
		for (var i = 0; i < path.count; i+=5) {
			if(i > 0)
				ret += ',';
			ret += "(" + (real(path[i+1])-init) + "," +
					path[i+2] + "," + path[i+3] + ")";
		}
		return ret;
	}

	// ���΍��W���΍��W�ɕϊ�����֐��B����ȃR���������������̂��B
	function getRelPathFromAbsPathY(layer="0", page="fore", init=getFixedCurrentPosY(layer, page), relpath)
	{
		if(relpath === void)
			return void;
		var ret = "";
		var path = relpath.split(/[,()]/);
		for (var i = 0; i < path.count; i+=5) {
			if(i > 0)
				ret += ',';
			ret += "(" + (real(path[i+1])-init) + "," +
					path[i+2] + "," + path[i+3] + ")";
		}
		return ret;
	}
}



// �v���O�C���I�u�W�F�N�g���쐬���A�o�^����
kag.addPlugin(global.layermotions_obj = new LayerMotions());

[endscript]


; [motion_define name= left= top= locatex= locatey= loop= loopx= loopy=]
[macro name="motion_define"]
[eval exp="mp.left  = real(mp.left)"  cond="mp.left  !== void"]
[eval exp="mp.top   = real(mp.top )"  cond="mp.top   !== void"]
[eval exp="mp.loopx = mp.loopy = real(mp.loop)" cond="mp.loop !== void"]
[eval exp="mp.loopx = real(mp.loopx)" cond="mp.loopx !== void"]
[eval exp="mp.loopy = real(mp.loopy)" cond="mp.loopy !== void"]
[eval exp="layermotions_obj.addLMD(mp.name, mp.left, mp.top, mp.locatex, mp.locatey, mp.loopx, mp.loopy)"]
[endmacro]


; [motion_undefine name=]
[macro name="motion_undefine"]
[eval exp="layermotions_obj.delLMD(mp.name)"]
[endmacro]


; [motion_start layer= page= left= top= name= ix= iy= loopx= loopy= wait=]
[macro name="motion_start"]
[eval exp="mp.left  = real(mp.left)"  cond="mp.left  !== void"]
[eval exp="mp.top   = real(mp.top )"  cond="mp.top   !== void"]
[eval exp="mp.ix    = real(mp.left)"  cond="mp.ix    !== void"]
[eval exp="mp.iy    = real(mp.top )"  cond="mp.iy    !== void"]
[eval exp="mp.loopx = mp.loopy = real(mp.loop)" cond="mp.loop !== void"]
[eval exp="mp.loopx = real(mp.loopx)" cond="mp.loopx !== void"]
[eval exp="mp.loopy = real(mp.loopy)" cond="mp.loopy !== void"]
[eval exp="mp.wait = true"            cond="mp.wait  === void"]
[eval exp="layermotions_obj.addLM(mp.layer, mp.page, mp.left, mp.top, mp.name,  mp.ix, mp.iy, mp.loopx, mp.loopy)"]
[motion_wait layer=%layer page=%page name=%name cond="mp.wait"]
[endmacro]


; [motion_stop layer= page= name= lastpos=]
; layer === void, page === void�őS���I��������
[macro name="motion_stop"]
[eval exp="layermotions_obj.stopLM(mp.layer, mp.page, mp.name, mp.lastpos)"]
[endmacro]


; [motion_wait layer= page= name=]
; layer === void, page === void, name === void�őS���҂�
[macro name="motion_wait"]
; �҂ׂ����[�V�������o�^����ĂȂ�������҂��Ȃ�
[if exp="layermotions_obj.findLayerMotion(mp.layer, mp.page, mp.name)"]
	[eval exp="mp.trignam = lmTrigName(mp.layer,mp.page,mp.name)"]
	[eval exp="layermotions_obj.registerTrigger(mp.layer,mp.page,mp.name)"]
	[waittrig name=%trignam canskip=true]
[endif]
[motion_stop *]
[if exp="mp.layer !== void"]
[eval exp="dm('wait(x,y) = (' + kag.fore.layers[mp.layer].left + ', ' + kag.fore.layers[mp.layer].top + ')')"]
[endif]
[endmacro]


; [motion_move layer= page= left= top= pathx= pathy= wait=]
; locatex��locatey�͎w�莞�͐�΍��W�ɂȂ��Ă���̂ŁA���΍��W�ɕϊ�����B
; ����͋g���g����[move]��replace���邽�߂ɓ��ʂɍ�����B
[macro name="motion_krkrmove"]
[eval exp="mp.layer = '0'"    cond="mp.layer === void"]
[eval exp="mp.page  = 'fore'" cond="mp.page  === void"]
[eval exp="mp.locatex = layermotions_obj.getRelPathFromAbsPathX(mp.layer, mp.page, mp.left, mp.pathx)"]
[eval exp="mp.locatey = layermotions_obj.getRelPathFromAbsPathY(mp.layer, mp.page, mp.top,  mp.pathy)"]
; ���O�͌Œ�
[eval exp="mp.mname = 'krkrmove_' + mp.layer"]
; �O�̓������~�߂�
[motion_stop layer=%layer page=%page name=%mname]
[motion_define name=%mname locatex=%locatex locatey=%locatey]
[motion_start layer=%layer page=%page name=%mname wait=%wait]
; ��������łȂ����motion_undefine����Ȃ����c�܂�������
[motion_undefine name=%mname cond="mp.wait"]
[endmacro]


; [motion_krkrmove_wait layer= page=]
; [motion_krkrmove]�p�҂�
; �������Alayer�͎w�肵�Ȃ��ƃ_��
[macro name="motion_krkrmove_wait"]
[eval exp="mp.mname = 'krkrmove_' + mp.layer"]
[motion_wait layer=%layer page=%page name=%mname]
[motion_undefine name=%mname cond="mp.wait"]
[endmacro]


; [motion_krkrmove_stop layer= page=]
; [motion_krkrmove]���~�߂�
[macro name="motion_krkrmove_stop"]
[eval exp="mp.mname = 'krkrmove_' + mp.layer"]
[motion_stop layer=%layer page=%page name=%mname]
[if exp="mp.layer !== void"]
[eval exp="dm('stop(x,y) = (' + kag.fore.layers[mp.layer].left + ', ' + kag.fore.layers[mp.layer].top + ')')"]
[endif]
[endmacro]


[iscript]

function make_quake_array(time, max, speed, signcnt=1)
{
	var ret = "";

	time = int(time);
	max = int(max);
	speed = int(speed);
	signcnt = int(signcnt); // ����������Ɉ�񔽓]���邩

	// time�b���ɉ���Ăяo�����ɂ���ă��[�v�񐔂��ς��
	var cnt = 0, sign = 1;
	for(var tick = 0; tick < time; tick += speed, cnt++) {
		var rand = int(Math.random()*sign*max);
		// �A���I�ɓ������ƂȂ񂩊Ԕ����������̂ŁA�킴�Ɨ��U�I�ɓ�����
		ret += '(' + rand + ',' + '1,0),';
		ret += '(' + rand + ',' + (speed-1) + ',0),';
		// �A���I�ɓ����Ȃ炱��Ȃ񁫈�s��O.K.�B
		// ret += '(' + rand + ',' + speed + ',0),';
		if(cnt%signcnt == 0)
			sign *= -1; // �������]����
	}
	ret += '(0,1,0)';	// �Ō�Ɍ��̈ʒu�ɖ߂�
dm('ret = ' + ret);
	return ret;
}

[endscript]


; ���C���[��quake�̂��߂̃}�N��
; [motion_quake layer= time= page= hmax= vmax= speed= wait= loop=]
[macro name="motion_quake"]
[eval exp="mp.time   = 1000"   cond="mp.time   === void"]
[eval exp="mp.page   = 'fore'" cond="mp.page   === void"]
[eval exp="mp.hmax   = 10"     cond="mp.hmax   === void"]
[eval exp="mp.vmax   = 10"     cond="mp.vmax   === void"]
[eval exp="mp.speed  = 50"     cond="mp.speed  === void"]
[eval exp="mp.wait   = true"  cond="mp.wait   === void"]
[eval exp="mp.loop   = 1"      cond="mp.loop   === void"]
[eval exp="mp.locatex = make_quake_array(mp.time, mp.hmax, mp.speed)"]
[eval exp="mp.locatey = make_quake_array(mp.time, mp.vmax, mp.speed, 2)"]
[eval exp="mp.name = 'quake_layer_' + mp.layer"]
[motion_define name=%name locatex=%locatex locatey=%locatey]
[motion_start name=%name layer=%layer name=%name wait=%wait loop=%loop]
;�o�^���Ă����폜����
[motion_undefine name=%name]
[endmacro]


; �T���v�����[�V����
[motion_define name="�Ă��Ă�" locatey="(-50,500,-2),(0,500,2)" loop=0]
[motion_define name="�ӂ�ӂ�" locatex="(-20,2000,-2),(0,2000,2),(20,2000,-2),(0,2000,2)" locatey="(-5,1200,-2),(0,1200,2),(5,1200,-2),(0,1200,2)" loop=0]
[motion_define name="��т̂�" locatex="(200,600,-2)" locatey="(-50,300,-2),(0,300,2)"]
[motion_define name="�����[�V����" locatex="(200,600,-2)"]
[return]

; �ȉ��A�T���v���B
[layopt layer=0 page=fore left=100 top=100 visible=true]
[layopt layer=0 page=back visible=true]
[layopt layer=message page=fore visible=true]
[layopt layer=message page=back visible=true]
[image layer=0 page=fore storage="�K���ȉ摜"]

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
[s]

[return]


;������:
; �����x�ύX

; Known BUG
; �����g�����W�V�������ɃZ�[�u�����f�[�^�����[�h����ƁALayerMotion
; ���Ă���Ȃ��B����͂����������̂Ȃ̂��B[wt]�̌�ɃZ�[�u����Α��v�������B
