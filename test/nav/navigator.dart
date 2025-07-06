import 'package:flutter_test/flutter_test.dart';
import 'package:ketchup_ui/debug/console.dart';
import 'package:ketchup_ui/ketchup_ui.dart';

void main(){
  group('Test Navigator Tools', (){
    NavigatorCoreTester nt = NavigatorCoreTester(contentPageClass: 3, screenColumn: 5);
    MultiColumns blueFive2 = '蓝五级页'.indexedCol(2);
    MultiColumns yellowFour2 = '黄四级页'.indexedCol(2);
    MultiColumns greenThree3 = '绿三级页'.indexedCol(3);
    MultiColumns redFour2 = '红四级页'.indexedCol(2);
    MultiColumns purpleFour3 = '紫四级页'.indexedCol(3);
    MultiColumns redThree2 = '红三级页'.indexedCol(2);
    MultiColumns blackFive4 = '黑五级页'.indexedCol(4);
    MultiColumns yellowThree2 = '黄三级页'.indexedCol(2);
    MultiColumns greyThree3 = '灰三级页'.indexedCol(3);
    MultiColumns greenFive5 = '绿五级页'.indexedCol(5);

    MultiColumns designedOdds4Page = '[1, 3, 4]'.oddsCol(4);
    MultiColumns designedEven5Page = '[1, 2, 4, 5]'.evenCol(5);
    MultiColumns designedIndexed3Page = '[1, 2, 3]'.indexedCol(3);
    MultiColumns designedBothends6Page = '[1, 6]'.bothendsCol(6);
    MultiColumns designedBothends2Page = '[1, 2]'.bothendsCol(2);
    
    test('MultiColumns',(){
      expect(designedOdds4Page.availableColumns.toString(), designedOdds4Page.toString());
      expect(designedEven5Page.availableColumns.toString(), designedEven5Page.toString());
      expect(designedIndexed3Page.availableColumns.toString(), designedIndexed3Page.toString());
      expect(designedBothends6Page.availableColumns.toString(), designedBothends6Page.toString());
      expect(designedBothends2Page.availableColumns.toString(), designedBothends2Page.toString());
      /// 交集
      expect(designedOdds4Page.intersection(designedBothends6Page).toString(), '[1]');
      expect(designedEven5Page.intersection(designedIndexed3Page).toString(), '[1, 2]');
      /// 差集(除1以外)
      expect(designedEven5Page.difference(designedIndexed3Page).toString(), '[1, 4, 5]');
      expect(designedIndexed3Page.difference(designedEven5Page).toString(), '[1, 3]');
      /// 并集
      expect(designedIndexed3Page.union(designedEven5Page).toString(), '[1, 2, 3, 4, 5]');
      expect(designedOdds4Page.union(designedBothends6Page).toString(), '[1, 3, 4, 6]');
    });
    
    test('NavigatorCore.indexedExpAvbCols', (){
      expect(
        nt.indexedExpAvbCols([(5, 1, designedBothends6Page),(4, 1, designedBothends6Page)]).toString(),
        '[[1], [1]]'
      );
      expect(
        nt.indexedExpAvbCols([(5, 1, designedBothends6Page),(4, 2, designedEven5Page)]).toString(),
        '[[1], [4, 2]]'
      );
      expect(
        nt.indexedExpAvbCols([(5, 1, designedOdds4Page),(4, 2, designedBothends2Page)]).toString(),
        '[[4, 3, 1], [2]]'
      );
      expect(
        nt.indexedExpAvbCols([(5, 1, designedOdds4Page),(4, 2, designedEven5Page)]).toString(),
        '[[4, 3, 1], [4, 2]]'
      );
    });

    test('NavigatorCore.expand', (){
      expect(
        nt.expandString(([(5, 1, designedBothends6Page),(4, 1, designedBothends6Page)],[])),
        ([(5, 1, designedBothends6Page),(4, 1, designedBothends6Page)],[]).toString()
      );
      expect(
        nt.expandString(([(5, 1, designedBothends6Page),(4, 2, designedEven5Page)],[])),
        ([(5, 1, designedBothends6Page),(4, 4, designedEven5Page)],[]).toString()
      );
      expect(
        nt.expandString(([(5, 1, designedOdds4Page),(4, 2, designedBothends2Page)],[])),
        ([(5, 3, designedOdds4Page),(4, 2, designedBothends2Page)],[]).toString()
      );
      expect(
        nt.expandString(([(5, 1, designedOdds4Page),(4, 2, designedEven5Page)],[(3, 1, designedIndexed3Page)])),
        ([(5, 1, designedOdds4Page),(4, 2, designedEven5Page)],[(3, 2, designedIndexed3Page)]).toString()
      );
    });
    /// https://immvpc32u2.feishu.cn/docx/R427dV9WbonppxxMv1xc1Jt4n8c#share-SvSLdSefco2aHDxP0VYcnxSOnTf
    test('NavigatorCore.shift', (){

      expect(nt.shiftString(([],[]), (5,2, blueFive2))
          , ([(5,2,'蓝五级页')], []).toString());

      /// 需要矫正(添加最大值)
      // expect(nt.shiftString(([(5,2,'蓝五级页')],[]), (4,2,'黄四级页'))
      //     , ([(5,2,'蓝五级页'),(4,2,'黄四级页')], <NavPair<String>>[]).toString());
      expect(nt.shiftString(([(5,2, blueFive2)],[]), (4,2, yellowFour2))
          , ([(5,2,'蓝五级页'),(4,2,'黄四级页')], []).toString());

      expect(nt.shiftString(([(5,2, blueFive2),(4,2, yellowFour2)],[]), (3,3, greenThree3))
          , ([(5,1,'蓝五级页'),(4,1,'黄四级页')],[(3,3,'绿三级页')]).toString());

      expect(nt.shiftString(([(5,1, blueFive2),(4,1, yellowFour2)],[(3,3, greenThree3)]), (4,2, redFour2))
          , ([(5,1,'蓝五级页'),(4,2,'红四级页')],[(3,2,'绿三级页')]).toString());

      expect(nt.shiftString(([(5,1, blueFive2),(4,2, redFour2)],[(3,2, greenThree3)]), (4,3, purpleFour3))
          , ([(5,1,'蓝五级页'),(4,3,'紫四级页')],[(3,1,'绿三级页')]).toString());
          
      expect(nt.shiftString(([(5,1, blueFive2),(4,3, purpleFour3)],[(3,1, greenThree3)]), (3,2, redThree2))
          , ([(5,1,'蓝五级页'),(4,1,'紫四级页')],[(3,2,'红三级页'),(3,1,'绿三级页')]).toString());
          
      expect(nt.shiftString(([(5,1, blueFive2),(4,1, purpleFour3)],[(3,2, redThree2),(3,1, greenThree3)]), (5,4, blackFive4))
          , ([(5,4,'黑五级页')],[(3,1,'红三级页')]).toString());
          
      expect(nt.shiftString(([(5,4, blackFive4)],[(3,1, redThree2)]), (3,2, yellowThree2))
          , ([(5,2,'黑五级页')],[(3,2,'黄三级页'),(3,1,'红三级页')]).toString());
          
      expect(nt.shiftString(([(5,2, blackFive4)],[(3,2, yellowThree2),(3,1, redThree2)]), (3,3, greyThree3))
          , ([(5,1,'黑五级页')],[(3,3,'灰三级页'),(3,1,'黄三级页')]).toString());

      expect(nt.shiftString(([(5,1, blackFive4)],[(3,3, greyThree3),(3,1, yellowThree2)]), (5,5, greenFive5))
          , ([(5,5,'绿五级页')], []).toString());
      
    });
    
    test('NavigatorCore.shiftExpand', (){

      expect(nt.shiftExpandString(([(5, 1, '[5, 3, 1]'.oddsCol(5)),(4, 4, '[6, 4, 2, 1]'.evenCol(6))],[]), (4, 2, '[2, 1]'.indexedCol(2)))
          , ([(5, 3,'[5, 3, 1]'), (4, 2, '[2, 1]')], []).toString());

      expect(nt.shiftExpandString(([],[]), (5, 1, '[5, 3, 1]'.oddsCol(5)))
          , ([(5, 5,'[5, 3, 1]')], []).toString());
          
      expect(nt.shiftString(([(5, 5,'[5, 3, 1]'.oddsCol(5))],[]), (3, 2, '[3, 2, 1]'.indexedCol(3)))
          , ([(5, 3,'[5, 3, 1]')], [(3, 2, '[3, 2, 1]')]).toString());
          
      expect(nt.shiftExpandString(([(5, 5,'[5, 3, 1]'.oddsCol(5))],[]), (3, 3, '[3, 2, 1]'.indexedCol(3)))
          , ([(5, 1,'[5, 3, 1]')], [(3, 3, '[3, 2, 1]')]).toString());
          
      expect(nt.shiftExpandString(([(5, 5,'[5, 3, 2, 1]'.oddsCol(5).uni(''.indexedCol(2)))],[]), (3, 3, '[3, 2, 1]'.indexedCol(3)))
          , ([(5, 2,'[5, 3, 2, 1]')], [(3, 3, '[3, 2, 1]')]).toString());
    });
    RouteFinderTester finder = RouteFinderTester(routes());
    test('RouteFinder.find',(){
      expect(finder.find('')?.$2['_debug'].toString(), null);
      expect(finder.find('/')?.$2['_debug'].toString(), '1->/');
      expect(finder.find('/?')?.$2['_debug'].toString(), '1->/');
      expect(finder.find('/?=')?.$2['_debug'].toString(), '1->/');
      expect(finder.find('/?debug')?.$2['_debug'].toString(), '1->/');
      expect(finder.find('/?debug')?.$2['debug'].toString(), '');
      expect(finder.find('/?debug&crash')?.$2['_debug'].toString(), '1->/');
      expect(finder.find('/?debug&crash')?.$2['debug'].toString(), '');
      expect(finder.find('/?debug&crash')?.$2['crash'].toString(), '');
      expect(finder.find('/#debug&crash')?.$2['_debug'].toString(), '1->/');
      expect(finder.find('/#debug&crash')?.$2['_hash'].toString(), 'debug&crash');

      expect(finder.find('/news')?.$2['_debug'].toString(), '1->/news');
      expect(finder.find('/news/2994820302')?.$2['_debug'].toString(), '1->/*unknown404');

      expect(finder.find('/store')?.$2['_debug'].toString(), '1->/store');
      expect(finder.find('/store/search/342342323')?.$2['_debug'].toString(), '1->/*unknown404');

      expect(finder.find('/collection')?.$2['_debug'].toString(), '1->/collection');
      expect(finder.find('/collection/search')?.$2['_debug'].toString(), '1->/*unknown404');
      expect(finder.find('/collection/search/342342323')?.$2['_debug'].toString(), '2->search/:query');
      expect(finder.find('/collection/search/342342323')?.$2['query'].toString(), '342342323');
      expect(finder.find('/collection/tags/342342323')?.$2['_debug'].toString(), '2->tags/:tags');
      expect(finder.find('/collection/tags/342342323')?.$2['tags'].toString(), '342342323');
      expect(finder.find('/collection/games')?.$2['_debug'].toString(), '2->games');
      expect(finder.find('/collection/games?appId=198')?.$2['_debug'].toString(), '2->games');
      expect(finder.find('/collection/games?appId=198')?.$2['appId'].toString(), '198');
      expect(finder.find('/collection/demos')?.$2['_debug'].toString(), '2->demos');
      expect(finder.find('/collection/demos#appId=198')?.$2['_debug'].toString(), '2->demos');
      expect(finder.find('/games?appId=198')?.$2['_debug'].toString(), '1->/*unknown404');
      expect(finder.find('/demos#appId=198')?.$2['_debug'].toString(), '1->/*unknown404');

      expect(finder.find('/version')?.$2['_debug'].toString(), '1->/*unknown404');
      expect(finder.find('/version?v=0.0.3')?.$2['_debug'].toString(), '1->/*unknown404');
      expect(finder.find('/version?v=0.0.3')?.$2['v'].toString(), '0.0.3');
      expect(finder.find('/version/v0.0.3')?.$2['_debug'].toString(), '1->/version/:version');
      expect(finder.find('/version/v0.0.3')?.$2['version'].toString(), 'v0.0.3');
      expect(finder.find('/version/342342323')?.$2['_debug'].toString(), '1->/version/:version');
      expect(finder.find('/version/342342323')?.$2['version'].toString(), '342342323');

      expect(finder.find('/tutorial')?.$2['_debug'].toString(), '1->/tutorial');
      expect(finder.find('/tutorial/342342323')?.$2['_debug'].toString(), '1->/*unknown404');
      expect(finder.find('/342342323/tutorial')?.$2['_debug'].toString(), '1->/*unknown404');

      expect(finder.find('/assets')?.$2['_debug'].toString(), '1->/*unknown404');
      expect(finder.find('/assets/cpo')?.$2['_debug'].toString(), '1->/assets/cpo');
      expect(finder.find('/assets/mkv')?.$2['_debug'].toString(), '1->/*unknown404');
      expect(finder.find('/assets/cpo/pack')?.$2['_debug'].toString(), '2->*unknown-cpo');
      expect(finder.find('/assets/mkv/pack')?.$2['_debug'].toString(), '1->/*unknown404');
      expect(finder.find('/assets/cpo/pck')?.$2['_debug'].toString(), '2->*unknown-cpo');
      expect(finder.find('/assets/cpo/pck/origami-animated-assets-kit')?.$2['_debug'].toString(), '2->:category/:name');
      expect(finder.find('/assets/cpo/pack/origami-animated-assets-kit')?.$2['_debug'].toString(), '2->pack/origami-animated-assets-kit');
      expect(finder.find('/assets/cpo/pack/comic-assets-kit')?.$2['_debug'].toString(), '2->pack/comic-assets-kit');
      expect(finder.find('/assets/cpo/pack/pixel-assets-kit')?.$2['_debug'].toString(), '2->pack/pixel-assets-kit');
      expect(finder.find('/assets/cpo/pack/pixel-assets-kit/text')?.$2['_debug'].toString(), '3->*unknown-text');
      expect(finder.find('/assets/cpo/pack/pixel-assets-kit/text?wokanxing')?.$2['_debug'].toString(), '3->*unknown-text');
      expect(finder.find('/assets/cpo/pack/pixel-assets-kit/text?wokanxing')?.$2['wokanxing'].toString(), '');
      expect(finder.find('/assets/cpo/pack/pixel-assets-kit/text#wokanxing')?.$2['_debug'].toString(), '3->*unknown-text');
      expect(finder.find('/assets/cpo/pack/pixel-assets-kit/text#wokanxing')?.$2['_hash'].toString(), 'wokanxing');
      expect(finder.find('/assets/cpo/pack/pixel-assets-kit/text/wokanxing')?.$2['_debug'].toString(), '3->text/:string');
      expect(finder.find('/assets/cpo/pack/pixel-assets-kit/date-time#now')?.$2['_debug'].toString(), '3->date-time');
      expect(finder.find('/assets/cpo/pack/pixel-assets-kit/date-timenow')?.$2['_debug'].toString(), '3->*unknown-text');
      expect(finder.find('/assets/cpo/animals')?.$2['_debug'].toString(), '2->animals');
      expect(finder.find('/assets/cpo/animals/monkey')?.$2['_debug'].toString(), '3->monkey');
      expect(finder.find('/assets/cpo/animals/elephant')?.$2['_debug'].toString(), '3->elephant');
      expect(finder.find('/assets/cpo/animals/chicken')?.$2['_debug'].toString(), '3->*unknown-animals');
      expect(finder.find('/assets/cpo/plants')?.$2['_debug'].toString(), '2->plants');
      expect(finder.find('/assets/cpo/plants/flower')?.$2['_debug'].toString(), '3->flower');
      expect(finder.find('/assets/cpo/plants/seed')?.$2['_debug'].toString(), '3->*unknown-plants');
      expect(finder.find('/assets/cpo/buildings')?.$2['_debug'].toString(), '2->*unknown-cpo');
      expect(finder.find('/assets/cpo/buildings/tower')?.$2['_debug'].toString(), '2->:category/:name');
      expect(finder.find('/assets/cpo/buildings/hospital')?.$2['_debug'].toString(), '2->:category/:name');
      expect(finder.find('/assets/cpo/buildings/hospital/342342323')?.$2['_debug'].toString(), '2->*unknown-cpo');

      expect(finder.find('/game-kit')?.$2['_debug'].toString(), '1->/game-kit');
      expect(finder.find('/game-kit/will-publish-later')?.$2['_debug'].toString(), '2->*unknown-game-kit');
      expect(finder.find('/game-kit/mmorpg-advanced-game-kit')?.$2['_debug'].toString(), '2->mmorpg-advanced-game-kit');
      expect(finder.find('/game-kit/moba-advanced-game-kit')?.$2['_debug'].toString(), '2->moba-advanced-game-kit');
      expect(finder.find('/game-kit/slg-advanced-game-kit')?.$2['_debug'].toString(), '2->slg-advanced-game-kit');
      expect(finder.find('/game-kit/fpv-mapbased-driving-kit')?.$2['_debug'].toString(), '2->fpv-mapbased-driving-kit');
      expect(finder.find('/game-kit/rpg-mapbased-game-kit')?.$2['_debug'].toString(), '2->rpg-mapbased-game-kit');
      expect(finder.find('/game-kit/multiplayer-card-advanced-game-kit')?.$2['_debug'].toString(), '2->multiplayer-card-advanced-game-kit');
      expect(finder.find('/game-kit/puzzle-escape-game-kit')?.$2['_debug'].toString(), '2->puzzle-escape-game-kit');
      expect(finder.find('/game-kit/simple-card-driven-game-kit')?.$2['_debug'].toString(), '2->simple-card-driven-game-kit');
      expect(finder.find('/game-kit/simple-gridbased-game-kit')?.$2['_debug'].toString(), '2->simple-gridbased-game-kit');

    });
    
  });

  group('Test Navigator Behaviors', (){
    NavigaterBuilder navigaterBuilder = NavigaterBuilder(ca: EmptyContextAccessorImp(ScreenContext(rowColumn: (row: 1, column: 5))), contentPageClass: 3, routes: routes());
    
    find(String name){
      return (TestableRoutePage? page){
        if(page != null){
          return page.name == name;
        }
        return false;
      };
    }

    test('NavigatorPage LifeCycle',(){
      navigaterBuilder.push('/');
      navigaterBuilder.push('/collection');
      navigaterBuilder.push('/collection/games');
      navigaterBuilder.push('/collection/demos');
      navigaterBuilder.push('/collection/tags/good-multiplayer');
      navigaterBuilder.push('/collection/search/gta');
      
      expect(
        navigaterBuilder.findBuiltPage<TestableRoutePage>(find('(nav)-news-store-coll-ver-assets-kit')).toString(),'''(nav)-news-store-coll-ver-assets-kit created
(nav)-news-store-coll-ver-assets-kit screenWillChange ((1-2-3-4-5), (1-2-3-4-5))
(nav)-news-store-coll-ver-assets-kit measured
(nav)-news-store-coll-ver-assets-kit pause
''');
      expect(
        navigaterBuilder.findBuiltPage<TestableRoutePage>(find('(coll)-[search-tags]-games(half)-demos(half)')).toString(), '''(coll)-[search-tags]-games(half)-demos(half) created
(coll)-[search-tags]-games(half)-demos(half) screenWillChange ((1-2-3-4), (1-2-3-4),5)
(coll)-[search-tags]-games(half)-demos(half) measured
(coll)-[search-tags]-games(half)-demos(half) screenWillChange ((1-2), (1-2),(3-4-5))
(coll)-[search-tags]-games(half)-demos(half) measured
(coll)-[search-tags]-games(half)-demos(half) measured
(coll)-[search-tags]-games(half)-demos(half) measured
(coll)-[search-tags]-games(half)-demos(half) measured
''');
      expect(
        navigaterBuilder.findBuiltPage<TestableRoutePage>(find('(coll)-games-fullpage')).toString(), '''(coll)-games-fullpage created
(coll)-games-fullpage screenWillChange ((3-4-5), (1-2),(3-4-5))
(coll)-games-fullpage measured
(coll)-games-fullpage pause
''');
      expect(
        navigaterBuilder.findBuiltPage<TestableRoutePage>(find('(coll)-demos-fullpage')).toString(), '''(coll)-demos-fullpage created
(coll)-demos-fullpage screenWillChange ((3-4-5), (1-2),(3-4-5))
(coll)-demos-fullpage measured
(coll)-demos-fullpage pause
''');
      expect(
        navigaterBuilder.findBuiltPage<TestableRoutePage>(find('(coll)-[tags]')).toString(),'''(coll)-[tags] created
(coll)-[tags] screenWillChange ((3-4-5), (1-2),(3-4-5))
(coll)-[tags] measured
(coll)-[tags] pause
''');
      expect(
        navigaterBuilder.findBuiltPage<TestableRoutePage>(find('(coll)-[search]')).toString(),'''(coll)-[search] created
(coll)-[search] screenWillChange ((3-4-5), (1-2),(3-4-5))
(coll)-[search] measured
''');
      print(VConsole.singleton);
      VConsole.singleton.consoleClear();

      navigaterBuilder.back();

      print(VConsole.singleton);
      VConsole.singleton.consoleClear();
      
      navigaterBuilder.back();
      
      print(VConsole.singleton);
      VConsole.singleton.consoleClear();
      
      navigaterBuilder.forward();

      print(VConsole.singleton);
      VConsole.singleton.consoleClear();
      
      navigaterBuilder.forward();
      
      print(VConsole.singleton);
      VConsole.singleton.consoleClear();
      // navigaterBuilder.findBuiltPage<TestRoutePage>(find('(coll)-[search-tags]-games(half)-demos(half)')).toString();
      // navigaterBuilder.findBuiltPage<TestRoutePage>(find('(coll)-[search]')).toString();
      // navigaterBuilder.findBuiltPage<TestRoutePage>(find('(coll)-[tags]')).toString();
      // navigaterBuilder.findBuiltPage<TestRoutePage>(find('(coll)-games-fullpage')).toString();
      // navigaterBuilder.findBuiltPage<TestRoutePage>(find('(coll)-demos-fullpage')).toString();

    });
  });
}

  
List<KetchupRoute> routes() => [
    /// 官网首页
    KetchupRoute(path: '/', ketchupPageBuilder: ()=>TestableRoutePage.indexed(5, name: '(nav)-news-store-coll-ver-assets-kit')),
    /// 顶级导航
    /// 新闻
    KetchupRoute(path: '/news', ketchupPageBuilder: ()=>TestableRoutePage()),
    /// 游戏商店
    KetchupRoute(path: '/store', ketchupPageBuilder: ()=>TestableRoutePage()),
    /// 我的收藏
    KetchupRoute(path: '/collection', ketchupPageBuilder: ()=>TestableRoutePage.indexed(4, name: '(coll)-[search-tags]-games(half)-demos(half)'), routes: [
      KetchupRoute(path: 'search/:query', ketchupPageBuilder: ()=>TestableRoutePage.indexed(3, name: '(coll)-[search]')),
      KetchupRoute(path: 'tags/:tags', ketchupPageBuilder: ()=>TestableRoutePage.indexed(3, name: '(coll)-[tags]')),
      KetchupRoute(path: 'games', ketchupPageBuilder: ()=>TestableRoutePage.indexed(3, name: '(coll)-games-fullpage')),
      KetchupRoute(path: 'demos', ketchupPageBuilder: ()=>TestableRoutePage.indexed(3, name: '(coll)-demos-fullpage')),
    ]),
    /// 版本信息
    KetchupRoute(path: '/version/:version', ketchupPageBuilder: ()=>TestableRoutePage()),
    /// 教程
    KetchupRoute(path: '/tutorial', ketchupPageBuilder: ()=>TestableRoutePage()),
    /// 资源预览器(CPO格式资源)
    KetchupRoute(path: '/assets/cpo', ketchupPageBuilder: ()=>TestableRoutePage.indexed(5, name: '(assets/cpo)-pack-animals-plants'), routes: [
      /// 折纸动画资源包
      KetchupRoute(path: 'pack/origami-animated-assets-kit', ketchupPageBuilder: ()=>TestableRoutePage()),
      /// 漫画风格资源包
      KetchupRoute(path: 'pack/comic-assets-kit', ketchupPageBuilder: ()=>TestableRoutePage()),
      /// 像素风格资源包
      KetchupRoute(path: 'pack/pixel-assets-kit', ketchupPageBuilder: ()=>TestableRoutePage.indexed(4, name: '(pack/pixel-assets-kit)-text/date-time'), routes: [
        KetchupRoute(path: 'text/:string', ketchupPageBuilder: ()=>TestableRoutePage.indexed(5, name: '(text)-max-5')),
        KetchupRoute(path: 'date-time', ketchupPageBuilder: ()=>TestableRoutePage.indexed(1, name: '(date-time)-1')),
        KetchupRoute(path: '*unknown-text', ketchupPageBuilder: ()=>TestableRoutePage()),
      ]),
      KetchupRoute(path: 'animals', ketchupPageBuilder: ()=>TestableRoutePage.indexed(3, name: '(animals)-monkey-elephant'), routes: [
        KetchupRoute(path: 'monkey', ketchupPageBuilder: ()=>TestableRoutePage.odds(3, name: 'monkey')),
        KetchupRoute(path: 'elephant', ketchupPageBuilder: ()=>TestableRoutePage.odds(3, name: 'elephant')),
        KetchupRoute(path: '*unknown-animals', ketchupPageBuilder: ()=>TestableRoutePage()),
      ]),
      KetchupRoute(path: 'plants', ketchupPageBuilder: ()=>TestableRoutePage.indexed(3, name: '(plants)-flower'), routes: [
        KetchupRoute(path: 'flower', ketchupPageBuilder: ()=>TestableRoutePage.odds(3, name: 'flower')),
        KetchupRoute(path: '*unknown-plants', ketchupPageBuilder: ()=>TestableRoutePage()),
      ]),
      KetchupRoute(path: ':category/:name', ketchupPageBuilder: ()=>TestableRoutePage()),
      KetchupRoute(path: '*unknown-cpo', ketchupPageBuilder: ()=>TestableRoutePage()),
    ]),
    /// 游戏工具包
    KetchupRoute(path: '/game-kit', ketchupPageBuilder: ()=>TestableRoutePage('(game-kit)-...'), routes: [
        KetchupRoute(path: 'simple-gridbased-game-kit', ketchupPageBuilder: ()=>TestableRoutePage('(game-kit)-simple-gridbased-game-kit')),
        KetchupRoute(path: 'simple-card-driven-game-kit', ketchupPageBuilder: ()=>TestableRoutePage('(game-kit)-simple-card-driven-game-kit')),
        KetchupRoute(path: 'puzzle-escape-game-kit', ketchupPageBuilder: ()=>TestableRoutePage('(game-kit)-puzzle-escape-game-kit')),
        KetchupRoute(path: 'multiplayer-card-advanced-game-kit', ketchupPageBuilder: ()=>TestableRoutePage('(game-kit)-multiplayer-card-advanced-game-kit')),
        KetchupRoute(path: 'rpg-mapbased-game-kit', ketchupPageBuilder: ()=>TestableRoutePage('(game-kit)-rpg-mapbased-game-kit')),
        KetchupRoute(path: 'fpv-mapbased-driving-kit', ketchupPageBuilder: ()=>TestableRoutePage('(game-kit)-fpv-mapbased-driving-kit')),
        KetchupRoute(path: 'slg-advanced-game-kit', ketchupPageBuilder: ()=>TestableRoutePage('(game-kit)-slg-advanced-game-kit')),
        KetchupRoute(path: 'moba-advanced-game-kit', ketchupPageBuilder: ()=>TestableRoutePage('(game-kit)-moba-advanced-game-kit')),
        KetchupRoute(path: 'mmorpg-advanced-game-kit', ketchupPageBuilder: ()=>TestableRoutePage('(game-kit)-mmorpg-advanced-game-kit')),
        KetchupRoute(path: '*unknown-game-kit', ketchupPageBuilder: ()=>TestableRoutePage(),)
    ]),
    KetchupRoute(path: '/*unknown404', ketchupPageBuilder: ()=>TestableRoutePage(),)
  ];
  
