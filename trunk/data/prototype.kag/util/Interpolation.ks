; ���d�o�^��h�~
[return cond="typeof(global.Interpolation) != 'undefined'"]

[iscript]

// ��ԗp�G�������g(���Βl�̂݁E�����l��0����J�n)
class RelInterpolationElement
{
	var vals;		// �n�b�V���z��((relval,reltick,accel), ...)

	// �R���X�g���N�^
	function InterpolationElement()
	{
		// �擪�͌v�Z�p�̃_�~�[�Ƃ������^�[�~�l�[�^
		vals = [ %[relval:0, reltick:0, accel:0] ];
	}

	// �f�X�g���N�^
	function finalize()
	{
//		invalidate vals;
	}

	function addPath(relval, tick, accel)
	{
		var pre = vals[vals.count-1];

		// relval�����́A�����ɓn����鎞�ɂ͑��Βl�ɂȂ��Ă���
		tick  = (tick  != "") ? tick  : pre.reltick
						- vals[vals.count-2].reltick;
		accel = (accel != "") ? accel : pre.accel;

		vals.add( %[
			relval:real(relval),
			reltick:(pre.reltick + real(tick)),
			accel:real(accel)
		] );
	}

	function clearPath()
	{
		vals.count = 1;	// �ŏ��̈���c���č폜
	}

	// reltick�������\�Ȏ��Ԃ�(start/end�͈̔͂Ɏ��܂��Ă��邩)
	function isValidRelTick(reltick)
	{
		var lastreltick = vals[vals.count-1].reltick;
		return(0 <= reltick && reltick <= lastreltick);
	}

	function getLastRelVal()
	{
		return(vals[vals.count-1].relval);
	}

	function getLastRelTick()
	{
		return(vals[vals.count-1].reltick);
	}

	function getCurrentIdx(reltick)
	{
		if(reltick < 0)
			return(0);			// �������ق��ɔ͈͊O
		var idx;
		for(idx = 1; idx < vals.count; idx++)	// �����K�{(1�ɒ���)
			if(reltick <= vals[idx].reltick)
				return(idx);
		return(vals.count-1);			// �傫���ق��ɔ͈͊O
	}

	function getCurrentRelVal(reltick)
	{
		var idx      = getCurrentIdx(reltick);
		if(idx == 0)	// �Œ�l�̏ꍇ��idx��0�ɂȂ�
			return 0;
		var cur	     = vals[idx];
		var difftick = cur.reltick - vals[idx-1].reltick;
		var diffval  = cur.relval  - vals[idx-1].relval;
		var per      = (reltick - vals[idx-1].reltick)/difftick;
		// per = �p�[�Z���g, 0�`1.0
		if(cur.accel > 1)		// ����(�ŏ��x�����X�ɑ���)
			per = Math.pow(per, cur.accel);
		else if(cur.accel < -1) {	// �㌷(�ŏ��������X�ɒx��)
			per = 1.0 - per;
			per = Math.pow(per, -cur.accel);
			per = 1.0 - per;
		}
		return(per*diffval + vals[idx-1].relval);
	}

	// �R�s�[����
	function assign(src)
	{
		vals.assignStruct(src.vals);
	}

	// �Z�[�u���ɏォ��Ă΂��
	function store()
	{
		var dic = %[];
		dic.vals = [];
		dic.vals.assignStruct(vals);
		return(dic);
	}

	// ���[�h���ɏォ��Ă΂��
	function restore(dic)
	{
		if(dic === void)
			return;
		vals.assignStruct(dic.vals);
	}

}



// ��ԗp�G�������g(���Βl�̂݁E�����l��0����J�n�E���[�v����)
class RelLoopInterpolationElement extends RelInterpolationElement
{
	var loop = 1;		// loop count(0�Ŗ������[�v)

	function RelLoopInterpolationElement(path=void, loop=1)
	{
		super.InterpolationElement();
		this.setRelValues(path, loop);
	}

	// �f�X�g���N�^
	function finalize()
	{
		super.finalize();
	}

	// �l��ݒ肷��Bpath�̗�́A(���l,���v����(ms),�����x)��g�B
	function setRelValues(path=void, loop=1)
	{
		this.loop = loop;
		if(path === void)
			return;
		clearPath();
		var preval = "0";
		var a = path.split( "()," );	// ���ӁI5�̔{���łȂ��Ɨ�����
		for(var i = 0; i < a.count; i += 5) {	// �����łȂ��ƃ_��
			var val = (a[i+1] != "") ? a[i+1] : preval;
			preval = val;
			if(val[0] == 'r')	// val!=""�͕ۏ؂���Ă�
				val = real(val.substr(1))+super.getLastRelVal();
			else
				val = real(val);
			addPath(val, a[i+2], a[i+3]);
		}
	}

	// loop�̊O����̏��������p�ɁB
	function setLoop(loop = 1)
	{
		this.loop = loop;
	}

	// �Ō��RelTick�𓾂�
	function getLastRelTick()
	{
		if(loop == 0)
			return +Infinity;
		return(loop*super.getLastRelTick());
	}

	// �Ō��RelVal�𓾂�
	function getLastRelVal()
	{
		return(loop*super.getLastRelVal());
	}

	// reltick�ɑ΂��郋�[�v�J�E���g(0�`)��Ԃ��B�͈͊O�Ȃ�-1�B
	function getRelLoopCount(reltick)
	{
		if (!isValidRelTick(reltick))
			return -1;
		if (reltick == 0)
			return 0;
		return int((reltick-1)/super.getLastRelTick()); // -1�Ƀ`���E�C
	}

	// current(���݂̈ʒu)�𓾂�
	function getCurrentRelVal(reltick)
	{
		if(reltick < 0)				// �͈͂�菬����
			return(0);
		if(getLastRelTick() < reltick)		// �͈͊O(���f�J��)
			return(getLastRelVal());

		var lp = getRelLoopCount(reltick);
		var val = super.getCurrentRelVal(reltick
						 - lp*super.getLastRelTick());
		val += lp*super.getLastRelVal();
		return( val );
	}

	// reltick�������\�Ȏ��Ԃ�(start/end�͈̔͂Ɏ��܂��Ă��邩)
	function isValidRelTick(reltick)
	{
		var lastreltick = getLastRelTick();
		return(0 <= reltick && reltick <= lastreltick);
	}

	// �������I���܂łɂ����鎞�Ԃ�Ԃ�(�����߂��Ă�ꍇ��-�̒l��)
	function toFinishRelTick(reltick)
	{
		var ret = getLastRelTick() - reltick;
		return(ret);
	}

	// �R�s�[����
	function assign(src)
	{
		super.assign(src);
		loop = src.loop;
	}

	// �Z�[�u���ɏォ��Ă΂��
	function store()
	{
		var dic = super.store();
		dic.loop = loop;
		return(dic);
	}

	// ���[�h���ɏォ��Ă΂��
	function restore(dic)
	{
		if(dic === void)
			return;
		super.restore(dic);
		loop		= dic.loop;
	}
}



// ��ԗp�G�������g(��Βl����)
class Interpolation extends RelLoopInterpolationElement
{
	var initval;		// �����l�B��x�ݒ肳�ꂽ��ύX����Ȃ��B
	var inittick;		// �J�n���ԁBpause���Ȃ�����ύX����Ȃ�

	function Interpolation(val=0, tick=System.getTickCount(), path=void, loop=1)
	{
		super.RelLoopInterpolationElement(path, loop);
		initval = val;
		inittick = tick;
	}

	// �f�X�g���N�^
	function finalize()
	{
		super.finalize();
	}

	// �l��ݒ肷��Bpath�̗�́A(���l,���v����(ms),�����x)��g�B
	function setValues(val=0, tick=System.getTickCount(), path=void, loop=1)
 	{
 		super.setRelValues(path, loop);
		initval = val;
		inittick = tick;
	}

	// ���݂�(�J�n)���Ԃ�ݒ肷��this.initx = initx;
	function setInitVal(val)
	{
		initval = val;
	}
	// ���݂�(�J�n)���Ԃ�ݒ肷��this.initx = initx;
	function setInitTick(tick=System.getTimeCount())
	{
		inittick = tick;
	}

	// current(���݂̈ʒu)�𓾂�
	function getCurrentValue(tick=System.getTickCount())
	{
		return(initval + super.getCurrentRelVal(tick-inittick));
	}

	// last(�ŏI�̈ʒu)�𓾂�
	function getLastValue()
	{
		return(initval + super.getLastRelVal());
	}

	// last(�ŏI�̎���)�𓾂�
	function getLastTick()
	{
		return(initval + super.getLastRelTick());
	}

	// tick�������\�Ȏ��Ԃ�(start/end�͈̔͂Ɏ��܂��Ă��邩)
	function isValidTick(tick=System.getTickCount())
	{
		return isValidRelTick(tick - inittick);
	}

	// �������I���܂łɂ����鎞�Ԃ�Ԃ�
	function toFinishTick(tick=System.getTimeCount())
	{
		return(toFinishRelTick(tick - inittick));
	}

	// �R�s�[����
	function assign(src)
	{
		initval		= src.initval;
		inittick	= src.inittick;
		super.assign(src);
	}

	// �Z�[�u���ɏォ��Ă΂��
	function store(curtick = System.getTickCount())
	{
		var dic = super.store();
		dic.initval	= initval;
		dic.idxtick	= curtick - inittick;
		return(dic);
	}

	// ���[�h���ɏォ��Ă΂��
	function restore(dic, curtick = System.getTickCount())
	{
		if(dic === void)
			return;
		super.restore(dic);
		initval		= dic.initval;
		inittick	= curtick - dic.idxtick;
	}
}


[endscript]

[return]
