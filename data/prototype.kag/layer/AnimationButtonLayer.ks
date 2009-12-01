; 多重登録を防止
[return cond="typeof(global.animbuttons_obj) != 'undefined'"]

[iscript]

// 残問題
// 1) ボタン押して「最初に戻る」が出来ない。ボタン押した瞬間にボタンが無効化
//    されてしまい、その次の動作ができないため。onMouseClick参照。
// 2) ボタン押すと、一度フォーカスが外れてしまう。
// 3) selProcessLockが無いので、二重実行できちゃうことがあるかも？
// 4) キーボード操作(focus)のことを全く考えていない
// 5) アニメーション中のTransitionは未チェック。ちゃんとできるか？



// アニメーションつきリンクボタンレイヤ
class AnimationButtonLayer extends ButtonLayer
{
	// グラフィカルボタンとして動作するためのレイヤ
	var key;	// ボタンの識別子
	var storage;	// クリック時にジャンプするシナリオファイル
	var target;	// クリック時にジャンプするシナリオラベル
	var countpage;	// [button]タグのcountpage参照

	// アニメーションボタンの追加部分
	var conductor;		// アニメーションのコンダクタ
	var buttonHeight;	// ボタンの縦幅(画像サイズからはわかんないから)
	var animIndex;		// アニメーションのインデックス
	var animInfo;		// アニメーション定義ファイル名
	var maxpatternnum;	// 現在のアニメーションセル最大数
	var options;		// 設定されたsuperクラスのボタンオプション

	function AnimationButtonLayer(win, parent, i_key)
	{
		// コンストラクタ
		super.ButtonLayer(...);
		focusable = false; // フォーカスは受け取らない

		key           = i_key === void ? "all" : i_key;
		storage       = void;
		target        = void;
		countpage     = true;
		hint          = void;

		conductor     = new AnimationConductor( this );
		buttonHeight  = 1;		// とりあえず1に
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

	// アニメーションを開始する。これまでにanimInfoが設定されていること。
	// jumpAnim()と統合された。
	function startAnim(label)
	{
		stopAnim();
		if(animInfo != "") {
			// アニメーション定義ファイルが存在した
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

	// アニメーション情報ファイルを読み込む
	function loadAnimInfo(storage)
	{
		animInfo = Storages.chopStorageExt(storage) + ".bsd";
		animInfo = Storages.getPlacedPath(animInfo);
		// animInfoが無かった場合は普通のButtonとして振舞う
		startAnim("*normal");
	}

	// イメージを読み込む。buttonHeightはここで指定
	function loadImages(storage, height)
	{
		stopAnim();
		super.loadImages(storage);
		maxpatternnum = imageHeight \ height;
		// KAGLayerのheightに直接流し込む。
		// ButtonLayerだとimageHeightも変わってしまうため。
		global.KAGLayer.height = buttonHeight = height;

//		callOnPaint = true;
//		Butt_imageLoaded = true;

		// アニメーション情報があれば読む
		loadAnimInfo(storage);
	}

	// オプションを設定
	function setOptions(elm)
	{
		// 文字列オプション
		var stropts = [
			"key", "graphic",
			"onclick", "clickse", "clicksebuf", "exp",
			"onenter", "enterse", "entersebuf",
			"onleave", "leavese", "leavesebuf",
			"storage", "target"
		];
		// ignoreオプション(自身またはsuperクラスのpropertyでないもの)
		var ignoreopts = [
			"key", "graphic", "height",
			"onclick", "clickse", "clicksebuf", "exp",
			"onenter", "enterse", "entersebuf",
			"onleave", "leavese", "leavesebuf",
		];

		// メッセージ履歴より奥に表示
		elm.absolute = 2000000-3            if(elm.absolute === void);
		loadImages(elm.graphic, elm.height) if(elm.graphic  !== void);
		// 指定可能なオプション設定が続く

		// onclick(or exp)を設定
		if(elm.exp !== void) {
			elm.onclick = elm.exp;
			elm.exp = void;
		}

		// 指定オプションを適宜数値に変換しながら自身のプロパティに設定
		var ary = [];
		ary.assign( elm );
		for(var i = ary.count-2; i >= 0; i -= 2) {
			var e = options[ary[i]] = ary[i+1];
			// 数値にできるものは数値にしてしまう。いいのか。
			if(typeof(e) == "String" && stropts.find(ary[i]) < 0)
				if(+e != 0 || e == "0")
					options[ary[i]] = e = +e;
			// optionsには保存、thisには必要なら設定(propertyのみ)
			this[ary[i]] = e if(ignoreopts.find(ary[i]) < 0);
		}
	}

	// 表示状態のテンポラリ変更(右クリックメッセージOffの時に使う)
	function setTemporalVisible(flag)
	{
		if(!flag)
			visible = false;
		else
			visible = options.visible; // 表示状態が保存されてる故
	}


	function getSoundExpression(exp, storage, buf)
	{
		// サウンドを鳴らすための式を作成して、propに設定する。
		// exp になにか式があった場合はカンマでつなぐ
		var ret = exp;
		if(storage !== void) {
			buf = 0 if(buf === void);
			ret = "(kag.se[" + buf + "].play(%[storage:\"" + storage.escape() +"\"]))" + ((exp === void) ? "" : ", (" + exp + ")");
		}
		return( ret );
	}

	// クリック時の動作
	function onMouseDown()
	{
		super.onMouseDown(...);
		startAnim('*onclick');	// "*onclick"からアニメ開始
	}

	function onMouseUp(x, y, button, shift)
	{
		super.onMouseUp(...);
		var exp = getSoundExpression( options.onclick, options.clickse, options.clicksebuf );
		if(enabled && button == mbLeft && exp !== void) {
			Scripts.eval(exp);
//			return;
//			// 「タイトルに戻る」の時はすぐreturnしないとエラーに
			// なっちゃうけど…どうしよ。
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
		startAnim('*onenter');	// "*onenter"からアニメ開始
	}

	function onMouseLeave()
	{
		var exp = getSoundExpression( options.onleave, options.leavese, options.leavesebuf );
		if(/*!parent.selProcessLock && */exp !== void)
			Scripts.eval(exp);
		super.onMouseLeave(...);
		startAnim('*normal');	// "*normal"からアニメ開始
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

	// 現在の画像を表示する(s:0 = 普通、1 = clicked、2 = entered)
	function drawState(s)
	{
		super.drawState(s);
		// イメージだった場合に、縦位置を変更する。
		// これでアニメーションっぽく。
		if(Butt_imageLoaded)
			super.imageTop = -buttonHeight*animIndex;
		update();
	}


// ------ ここからアニメーション定義ファイルのタグハンドラ --------------------

	function pattern(elm)
	{
		if(elm.num !== void)
			maxpatternnum = +elm.num;
		if(elm.index !== void) {
			var str = elm.index.replace( /index/, animIndex );
			animIndex = Scripts.eval(str);
		}

		// 最後に有効なパターンNo.の範囲に収める
		animIndex %= maxpatternnum;
		// で、描画
		draw();
		return 0;
	}

	function s(elm)
	{
		// 停止
		elm.context.running = false;
		return -1; // 停止
	}

	function wait(elm)
	{
		return elm.time;
	}

	function eval(elm)
	{
		Scripts.eval(elm.exp); // elm.exp を式として実行
		return 0;
	}


// ------ ここからロード・セーブ ----------------------------------------

	// セーブ時に上から呼ばれる
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

	// ロード時に上から呼ばれる
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



// アニメーションボタンプラグイン
class AnimationButtonPlugin extends KAGPlugin
{
	var animButtons = []; // ボタン配列

	function AnimationButtonPlugin()
	{
		// AnimationButtonPlugin コンストラクタ
		// 最初は配列を空にするだけ。objの配列だが、obj.addoptsという
		// おまけがくっついてくる。
		animButtons  = [];
	}

	function finalize()
	{
		invalidateAllButtons();
		super.finalize(...);
	}

	function invalidateAllButtons()
	{
		// ボタンを無効化
		invalidateButtons();
	}

	// ボタン追加(前景・背景の片側のみ追加)
	function addButton(elm)
	{
		elm.page    = 'fore' if(elm.page === void);
		elm.visible = true   if(elm.visible === void);
		var parent = elm.page=='fore' ? kag.fore.base : kag.back.base;

		var obj = new AnimationButtonLayer(kag, parent, elm.key);
		obj.setOptions(elm);
		animButtons.add(obj);
	}

	// keyとpageに対応するボタンを探す
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
		// 栞を保存するとき
		var dic = f.animationButtons = %[];
			// f.animationButtons に辞書配列を作成
		dic.animButtons = [];
		for(var i = animButtons.count-1; i >= 0; i--)
			dic.animButtons[i] = animButtons[i].store();
	}

	function onRestore(f, clear, elm)
	{
		// 栞を読み出すとき
		invalidateAllButtons();
		var dic = f.animationButtons;

		if(dic !== void)
		{
			// animButtons の情報が栞に保存されている
			// ボタン作成、オプション設定
			for(var i = dic.animButtons.count-1; i >= 0; i--)
				addButton( dic.animButtons[i] );
		}
	}

	function onStableStateChanged(state)
	{
		// 「安定」( s l p の各タグで停止中 ) か、
		// 「走行中」 ( それ以外 ) かの状態が変わったときに呼ばれる
		// 走行中は各ボタンを無効にする
		setOptionsForAllButtons(%[ enabled:state ]);
	}

	function onMessageHiddenStateChanged(hidden)
	{
	// メッセージレイヤがユーザの操作によって隠されるとき、現れるときに
	// 呼ばれる。メッセージレイヤとともに表示/非表示を切り替えたいときは
	// ここで設定する。
		if(hidden)
			for(var i = animButtons.count-1; i >= 0; i--)
				animButtons[i].setTemporalVisible(false);
		else
			for(var i = animButtons.count-1; i >= 0; i--)
				animButtons[i].setTemporalVisible(true);
	}

	// 指定されたページに属する全てのanimbuttonを削除する
	function invalidateButtonsOnPage( page )
	{
		if(page === void || page == 'both') {
			// こんなトコで再起(?)呼び出し…
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

	// keyとpageに対応するボタンを削除する
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
		// レイヤの表←→裏の情報のコピー
		// backlay タグやトランジションの終了時に呼ばれる
		if(toback)
		{
			// 表→裏
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
			// 裏→表
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
		// 裏と表の管理情報を交換

		// children = true のトランジションでは、トランジション終了時に
		// 表画面と裏画面のレイヤ構造がそっくり入れ替わるので、
		// それまで 表画面だと思っていたものが裏画面に、裏画面だと思って
		// いたものが表画面になってしまう。ここのタイミングでその情報を
		// 入れ替えれば、矛盾は生じないで済む。

		// ここで表画面、裏画面のレイヤに関して管理すべきなのは
		// animButtons[xx].options.pageだけ
		for(var i = animButtons.count-1; i >= 0 ; i--)
			if(animButtons[i].options.page == 'fore')
				animButtons[i].options.page = 'back';
			else
				animButtons[i].options.page = 'fore';
	}
}

kag.addPlugin(global.animbuttons_obj = new AnimationButtonPlugin(kag));
// プラグインオブジェクトを作成し、登録する

[endscript]


; アニメーションボタンを登録するマクロ
; [animbutton key="xx" storage="xx" height=## page="xx" top=## left=##]
[macro name="animbutton"]
[eval exp="animbuttons_obj.addButton(mp)"]
; mp がマクロに渡された属性を示す辞書配列オブジェクト
[endmacro]

; 指定ページのアニメーションボタンを削除するマクロ
; [erase_animbutton key="xx" page="fore|back"]
[macro name="animbutton_erase"]
[eval exp="animbuttons_obj.invalidateButtons(mp.key, mp.page)"]
[endmacro]

; 指定ボタンにオプションを設定する(top=とかgraphic=とかonenter=とか)
[macro name="animbutton_setopt"]
[eval exp="animbuttons_obj.setOptions(mp)"]
[endmacro]


[return]
