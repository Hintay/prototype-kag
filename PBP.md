# PBP 演出支援ツール解析 #

[PBP](http://www5f.biglobe.ne.jp/~pbp/index.html)で配布されている演出支援ツールの解析をメモ。

## メッセージウィンドウ ##

main/Config.tjs内では、デフォルトで

```
;initialMessageLayerVisible = false;
```

となっているので、メッセージは表示できない。シナリオファイル内で、表示させたいテキストの前に

```
@position  visible=true  opacity=255 
```

で表示可能に。


## システムメニュー ##

main/Override.tjs内のKAGWindow\_createMenusで定義

### Config画面を追加 ###

**KAGWindow\_createMenus\*内を以下のように**

```

function KAGWindow_createMenus()
{
	// この関数は MainWindow クラスのオブジェクトのコンテキスト上で実行されます

	menu.add(this.systemMenu = new KAGMenuItem(this, "SYSTEM(&S)", 0, "", false));

	systemMenu.add(this.storeMenu   = new KAGMenuItem(this, "SAVE(F2)", 0,"startSave()",false));
	systemMenu.add(this.restoreMenu = new KAGMenuItem(this, "LOAD(F3)", 0,"startLoad()",false));
	systemMenu.add(this.configMenuItem = new KAGMenuItem(this, "Config(F4)", 0,"startConfig()",false));//これを追加
	
	systemMenu.add(new MenuItem(this, "-"));
	systemMenu.add(this.goToStartMenuItem = new KAGMenuItem(this, "TITLE(&R)", 0,
		onGoToStartMenuItemClick, false));
	systemMenu.add(new MenuItem(this, "-"));
	systemMenu.add(this.exitMenuItem = new KAGMenuItem(this, "EXIT(&X)", 0, onExitMenuItemClick, false));

	systemMenu.add(this.rightClickMenuItem = new KAGMenuItem(this, "メッセージを消す(&S)", 0,
		onRightClickMenuItemClick, false));

	menu.add(this.displayMenu = new KAGMenuItem(this, "DISPLAY(F5)", 0, void, false));
		displayMenu.add(this.windowedMenuItem = new KAGMenuItem(this, "WINDOW(&W)", 1,
			onWindowedMenuItemClick, false));
		displayMenu.add(this.fullScreenMenuItem = new KAGMenuItem(this, "FULLSCREEN(&F)", 1,
			onFullScreenMenuItemClick, false));

	menu.add(this.skipToNextStopMenuItem = new KAGMenuItem(this, "SKIP(F6)", 0, onSkipToNextStopMenuItemClick, false));
	menu.add(this.showHistoryMenuItem = new KAGMenuItem(this, "BACKLOG(F7)", 0, onShowHistoryMenuItemClick, false));
	menu.add(this.autoModeMenuItem = new KAGMenuItem(this, "AUTO(F8)", 0, onAutoModeMenuItemClick, false));

	menu.add(this.helpMenu = new KAGMenuItem(this, "HELP(&H)", 0, void, false));

		helpMenu.add(this.helpIndexMenuItem = new KAGMenuItem(this, "MANUAL", 0,
			onHelpIndexMenuItemClick, false));

		helpMenu.add(this.helpAboutMenuItem = new KAGMenuItem(this, "ABOUT(F1) ", 0,
		onHelpAboutMenuItemClick, false));

	menu.add(this.debugMenu = new KAGMenuItem(this, "デバッグ(&D)", 0, void, false));

		//debugMenu.add(this.EasingNormalMoveMenuItem = new KAGMenuItem(this, "Easing Normal Move", 0,
			//EasingNormalMoveMenuItemClick, false));        
		//debugMenu.add(this.EasingMoveMenuItem = new KAGMenuItem(this, "Easing Ex Move", 0,
			//EasingMoveMenuItemClick, false));        

}



```