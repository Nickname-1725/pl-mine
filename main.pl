
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
%   , 'land-mine' | 'number'(.)
% )

'make-board'(Height, Width, Grid) :-
  % 'make-board'/3 的帮助函数
  % 'make-board'(+Height, +Width, -Grid, +This, +This_height, +This_width)
  Height =:= 0, !, Grid = [];
  !,% 'make-board-row'(Y, X, Width, List, This),
  length(List,Width),
  Grid = [List|Rest],
  Height_ is Height - 1,
  'make-board'(Height_,Width, Rest).

'asign-land-mine'(N, Grid) :-
  % 'asign-land-mine'(+N, +Grid, -Result)
  % 从新生成的 Grid 中随机赋 N 个雷
  flatten(Grid, Flat_),
  'random-select-N-from-list'(N, Flat_, Mine_list, Non_mine_list),
  maplist(['block'('land-mine')]>>true,Mine_list),
  maplist(['block'('number'(_))]>>true,Non_mine_list).

% -----

'get-board'(Row,Col,Board,X) :-
  % 从网格中指定索引获取元素
  nth1(Row,Board,Board_),
  nth1(Col,Board_,X).

'get-3'(X_center, Row, List) :-
  % 从一行中截取 3 个元素（自动处理边缘情况）
  X_start is X_center -1,
  X_end is X_center +1,
  findall(Element, 
           (between(X_start, X_end, Index),
            nth1(Index, Row, Element)),
          List).

'get-3x3'(Y_center,X_center,Board,List) :-
  % 从网格中截取 3x3 元素（自动处理边缘 2x2、2x3 等情况）
  Y_start is Y_center -1,
  Y_end is Y_center +1,
  findall(Element, 
           (between(Y_start, Y_end, Index),
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

'draw-block'('block'('land-mine'),_,_) :-
  write("|_ ").
'draw-block'('block'(number(N)),X,X) :-
  % 对节点进行绘制
  var(N), !, write("{_}");
  N = 0, !, write("{ }");
  !, writef("{%w}",[N]).
'draw-block'('block'(number(N)),_,_) :-
  % 对节点进行绘制
  var(N), !, write("|_ ");
  N = 0, !, write(":  ");
  !, writef("|%w ",[N]).

% ---------
'uncover'(Grid,Y,X, false) :-
  'get-board'(Y,X,Grid,'block'('land-mine')).
'uncover'(Grid,Y,X, true) :-
  'get-board'(Y,X,Grid,'block'('number'(N))), !,
  'get-3x3'(Y,X,Grid,Neighbor_ls),
  findall(Block,(member(Block, Neighbor_ls),
                 Block='block'('land-mine')),
          Mines),
  length(Mines,N).

main() :-
  shell('clear'),
  write_ln("[W/A/S/D] 移动"),
  write_ln("[U/u/Spc] 翻开"),
  write_ln("[F/f] 插旗或取消标记"),
  write_ln("[Q/q] 退出").

