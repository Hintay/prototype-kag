; 既に定義済みならすぐ戻る
[return cond="typeof(global.saveAnywhere_object) != 'undefined'"]

; 以下、未定義の時のみ実行

; 「どこでもセーブプラグイン改」 Ver 0.1 2007/07/31 by KAICHO
; 既読判定をもう少しマシにしたどこでもセーブプラグイン。


[iscript]
/*
	どこでもセーブプラグイン
*/
class SaveAnywherePlugin extends KAGPlugin
{
	var labelstack;		// ラベルNoのスタック
	var extend_call;	// SaveAnywhere用の[call]タグ拡張フラグ
	var pagenamestack;	// PageNameのスタック

	var org_onLabel;	// ラベル通過時のオリジナル処理
	var org_onCall;		// [call]呼び出し時のオリジナル処理
	var org_onReturn;	// [return]時のオリジナル処理(extraConductor含)
	var org_onAfterReturn;	// [return]の後のオリジナル処理

// テスト用。下のwindow.incRecordLabelをテストする時のみ定義すること
//var org_incRecordLabel;

	// コンストラクタ
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

// テスト用。下のwindow.incRecordLabelをテストする時のみ定義すること
// org_incRecordLabel = window.incRecordLabel;

		// onLabel(ラベル通過時)に、labelnoをリセットする処理を追加。
		// こんなことしてイイの？スゲぇな。
		window.mainConductor.onLabel = function( label, page )
		{
			// "*label_anywhere"以外のラベルだとNoを1にする
			if(label != "*label_anywhere")
				saveAnywhere_object.labelstack[0] = int(1);

			// 以下オリジナルと同じ。つーかオリジナルはこれだけ。
			return saveAnywhere_object.org_onLabel(...);
		} incontextof (window.mainConductor);


		// onCall([call]タグ使用時)に、labelnoを保存する処理を追加
		window.mainConductor.onCall = function()
		{
// dm( "##################### onCall" );
			if(saveAnywhere_object.extend_call) {
				// 拡張callならここで通過記録をとる
// dm( 'セーブしたラベル(call) = ' + kag.currentRecordName );
				kag.incRecordLabel( true );
				// ページ名を保存しておく(voidの時を考慮必要？)
				saveAnywhere_object.pagenamestack.push(kag.currentPageName);
			}

			// 現在のlabel/labelstackを保存する([0]に1をpush)
			saveAnywhere_object.labelstack.insert( 0, int(1) );
			// 以下オリジナルと同じ
			return saveAnywhere_object.org_onCall(...);
		} incontextof (window.mainConductor);

		// onReturn([returnl]時)に、labelnoを復帰する処理を追加
		// 普通要らんのだが、extraConductorからの最終returnの場合、
		// kag.currentLabelとkag.currentRecordNameが戻ってしまうので。
		window.extraConductor.onReturn = function()
		{
// dm( "##################### onReturn" );
			// まずオリジナルを呼ぶ
			var ret= saveAnywhere_object.org_onReturn(...);
			// セーブラベル(つーか通過記録ラベル)設定
			saveAnywhere_object.overwriteCurrentLabel();
			return ret;
		} incontextof (window.mainConductor);


		// onAfterReturn([returnl]時)に、labelnoを復帰する処理を追加
		window.mainConductor.onAfterReturn = function()
		{
// dm( "##################### onAfterReturn" );
			// まずオリジナルを呼ぶ
			var ret= saveAnywhere_object.org_onAfterReturn(...);

			// labelstackを一つ前に戻し([0]を削除する)、設定する
			saveAnywhere_object.labelstack.erase( 0 );
			saveAnywhere_object.overwriteCurrentLabel();
// dm( '次にセーブする予定のラベル(戻し) = ' + kag.currentRecordName );

			if(saveAnywhere_object.extend_call) {
				// 拡張callならここで新ラベルを設定
				saveAnywhere_object.setCurrentLabel();
				// 拡張コールならページ名を元に戻す
				var p=saveAnywhere_object.pagenamestack.pop();
				kag.currentPageName = p;
				kag.pcflags.currentPageName = p;
			}
// dm( '次にセーブする予定のラベル(後) = ' + kag.currentRecordName );
			// スキップチェック
			if(!kag.usingExtraConductor) {
				if(!kag.getCurrentRead() && kag.skipMode != 4)
					kag.cancelSkip(); // 未読、スキップ停止
			}
			return ret;
		} incontextof (window.mainConductor);

/* テスト用。通過記録したラベルを表示する
window.incRecordLabel = function(count)
{
	if(count && kag.currentRecordName!==void && kag.currentRecordName!="")
		dm("########### incRecordLabel = " + kag.currentRecordName);
	saveAnywhere_object.org_incRecordLabel(...);
} incontextof (window.mainConductor);
*/
	}

	// デストラクタ
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

	// kag.currentLabelとkag.currentRecordNameを上書きする
	function overwriteCurrentLabel()
	{
		var labelno = int(labelstack[0]);
		if(labelno > 1) { // 既に[label]を通過してたら
			kag.currentLabel += ':' + (+labelno-1);
// dm( "#################### kag.currentLabel = " + kag.currentLabel );
			kag.setRecordLabel( kag.conductor.curStorage,
					    kag.currentLabel );
		}
	}

	// セーブする時の動作
	function onStore( f, elm )
	{
		var dic = f.saveanywhere = %[];
		dic.labelstack = [];
		(Array.assign incontextof dic.labelstack)(labelstack);
		dic.pagenamestack = [];
		dic.pagenamestack.assign(pagenamestack);
		dic.extend_call = extend_call;
	}
	// ロードする時の動作
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

	// 現在のラベル(=call前のラベル)を元に、(既読判定のために)
	// curRecordNameを設定。設定するだけでセーブしない。
	// 実は、このラベル名は既読判定のためだけに必要。セーブ関係は
	// *label_anywhereにて(スタック込みで)処理されるから。
	function setCurrentLabel()
	{
		kag.currentLabel = kag.conductor.curLabel+':'+ labelstack[0]++;
		kag.setRecordLabel(kag.conductor.curStorage,kag.currentLabel);
	}
}

// デフォルトで拡張call使うようにしちゃった。いいのかな。
kag.addPlugin(global.saveAnywhere_object = new SaveAnywherePlugin(kag, true));

[endscript]
[endif]

;▼labelマクロ
[macro name="label"]
; extend_callフラグをつけると、call直前のラベルと直後のラベルを自動的に
; 変更(":3"とか付けて)して既読判定配列に格納する。
[eval exp="mp.extend_call_save = saveAnywhere_object.extend_call"]
[eval exp="saveAnywhere_object.extend_call = true"]

; *label_anywhereをセーブ可能ラベルとして設定
[call storage="saveAnywhere.ks" target="*label_anywhere"]

; extend_callフラグを元に戻す
[eval exp="saveAnywhere_object.extend_call = mp.extend_call_save"]

[endmacro]

[return]


;---------------------------------------
;▼どこでもセーブ用サブルーチン
*label_anywhere|
[return]
