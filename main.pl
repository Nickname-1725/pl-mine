
'random-select-N-from-list'(N, From, Result, Rest) :-
  % 'random-select-N-from-list'(+N, +From, -Result, -Rest)
  % 从 From 列表中随机抽取 N 个不重复元素，组成 Result 列表
  From = [],!, Result = [], Rest = [];
  N =:= 0, !, Result = [], Rest = From;
  !, Result = [X|Result_],
  N_ is N - 1,
  random_select(X,From,From_),
  'random-select-N-from-list'(N_, From_, Result_, Rest).

% 网格坐标
% O|--- X
%  |
%  |Y

% 节点
% 'block'(
%   , 'land-mine' | 'number'(N)
%   , 'y-x'(Y,X)
% )

'make-board'(Height, Width, Grid, Y) :-
  % 'make-board'/3 的帮助函数
  % 'make-board'(+Height, +Width, -Grid, +Y)
  Height =:= 0, !, Grid = [];
  !,
  length(List,Width),
  numlist(1,Width,X_range),
  maplist('asign-block-y-x'(Y),X_range,List),
  Grid = [List|Rest],
  Height_ is Height - 1,
  Y_ is Y + 1,
  'make-board'(Height_,Width, Rest, Y_).

'make-board'(Height, Width, Grid) :-
  'make-board'(Height, Width, Grid, 1).

'asign-block-y-x'(Y, X, 'block'(_,'y-x'(Y,X))).

'asign-land-mine'(N, Grid) :-
  % 'asign-land-mine'(+N, +Grid)
  % 从新生成的 Grid 中随机赋 N 个雷
  flatten(Grid, Flat_),
  'random-select-N-from-list'(N, Flat_, Mine_list, Non_mine_list),
  maplist(['block'('land-mine',_)]>>true,Mine_list),
  maplist(['block'('number'(_),_)]>>true,Non_mine_list).

% -----

'get-board'(Y,X,Board,Result) :-
  % 从网格中指定索引获取元素
  nth1(Y,Board,Board_),
  nth1(X,Board_,Result).

'get-3'(X_center, Row, List) :-
  % 从一行中截取 3 个元素（自动处理边缘情况）
  X_start is X_center -1,
  X_end is X_center +1,
  bagof(Element, 
        Index^(between(X_start, X_end, Index),
               nth1(Index, Row, Element)),
        List).

'get-3x3'(Y_center,X_center,Board,List) :-
  % 从网格中截取 3x3 元素（自动处理边缘 2x2、2x3 等情况）
  Y_start is Y_center -1,
  Y_end is Y_center +1,
  bagof(Element, 
        Index^(between(Y_start, Y_end, Index),
               nth1(Index, Board, Element)),
        List_),
  maplist('get-3'(X_center), List_, List__),
  flatten(List__,List). % 扁平化截取结果

% -----
'draw-board'(Grid, Y, X) :-
  % 对棋盘进行文本绘制
  % (Y, X) 是玩家坐标
  length(Grid, Len),
  numlist(1,Len,Y_range),
  length(Ys, Len), maplist(=(Y),Ys),
  length(Xs, Len), maplist(=(X),Xs),
  maplist('draw-row',Grid,Y_range,Ys,Xs).

'draw-row'(Row,Y_now, Y, X) :-
  % 对棋盘的一行进行绘制
  length(Row, Len),
  numlist(1,Len,X_range),
  length(Xs, Len),
  (Y =:= Y_now,!,maplist(=(X),Xs);
   maplist(=(0),Xs)),
  maplist('draw-block',Row,X_range,Xs),
  write_ln('').

'draw-block'('block'('land-mine',_),_,_) :-
  write("|_ ").
'draw-block'('block'(number(N),_),X,X) :-
  % 对节点进行绘制
  var(N), !, write("{_}");
  N = 0, !, write("{ }");
  !, writef("{%w}",[N]).
'draw-block'('block'(number(N),_),_,_) :-
  % 对节点进行绘制
  var(N), !, write("|_ ");
  N = 0, !, write(":  ");
  !, writef("|%w ",[N]).

% ---------
'uncover'(Grid,Survive,Y,X) :-
  % 'uncover'/4
  % 'uncover'(+Grid, -Survive, +Y, +X)
  'get-board'(Y,X,Grid,Block), !,
  'uncover'(Grid,Survive,Block).

'uncover'(_,   false,'block'('land-mine',_)).
'uncover'(Grid,true, 'block'('number'(N),'y-x'(Y,X))) :-
  % 'uncover'/3
  % 'uncover'(+Grid, -Survive, +Block)
  (number(N),!,true; % 此方块已经翻开，无需操作
   var(N),!,
   'get-3x3'(Y,X,Grid,Neighbor_ls),
   findall(Block,(member(Block, Neighbor_ls),
                  Block='block'('land-mine',_)),
           Mines),
   length(Mines,N),
   (N = 0,!, % 如果周围方块无雷，继续翻开周围方块
    'maplist'('uncover'(Grid,true),Neighbor_ls);
    true)).

main() :-
  shell('clear'),
  write_ln("[W/A/S/D] 移动"),
  write_ln("[U/u/Spc] 翻开"),
  write_ln("[F/f] 插旗或取消标记"),
  write_ln("[Q/q] 退出").

