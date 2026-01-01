
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
  maplist('assign-block-y-x'(Y),X_range,List),
  Grid = [List|Rest],
  Height_ is Height - 1,
  Y_ is Y + 1,
  'make-board'(Height_,Width, Rest, Y_).

'make-board'(Height, Width, Grid) :-
  'make-board'(Height, Width, Grid, 1).

'assign-block-y-x'(Y, X, 'block'(_,'y-x'(Y,X))).

'assign-land-mine'(N, Grid) :-
  % 'assign-land-mine'(+N, +Grid)
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
'draw-board'(Y, X, Flag_ls, Grid) :-
  % draw-board/4
  % draw-board(Y_user, X_user, Flag_ls, Grid)
  % 对棋盘进行文本绘制
  % (Y, X) 是玩家坐标
  length(Grid, Len),
  numlist(1,Len,Y_range),
  maplist('draw-row'(Y,X, Flag_ls),Grid,Y_range).

'draw-row'(Y, X, Flag_ls,Row,Y_now) :-
  % draw-row/5
  % draw-row(+Y_user, +X_user, Flag_ls, +Row, +Y_now)
  % 对棋盘的一行进行绘制
  length(Row, Len),
  numlist(1,Len,X_range),
  findall(X_flag,(member('y-x'(Y_now,X_flag),Flag_ls)), X_Flag_ls),
  (Y =:= Y_now,!,
   maplist('draw-block'(X,X_Flag_ls),X_range,Row);
   !, 
   maplist('draw-block'(0,X_Flag_ls),X_range,Row)),
  write_ln('').

'draw-block'(X,X_Flag_ls,X,_) :-
  member(X,X_Flag_ls),
  write("{F}").
'draw-block'(_,X_Flag_ls,X,_) :-
  member(X,X_Flag_ls),
  write("|F ").
'draw-block'(X,_,X,'block'('land-mine',_)) :-
  write("{_}").
% draw-block/4
% draw-block(+X_now, +X_Flag_ls, +X_user, +Block)
'draw-block'(_,_,_,'block'('land-mine',_)) :-
  write("|_ ").
'draw-block'(X,_,X,'block'(number(N),_)) :-
  % 对节点进行绘制
  var(N), !, write("{_}");
  N = 0, !, write("{ }");
  !, writef("{%w}",[N]).
'draw-block'(_,_,_,'block'(number(N),_)) :-
  % 对节点进行绘制
  var(N), !, write("|_ ");
  N = 0, !, write(":  ");
  !, writef("|%w ",[N]).

% ---------
'uncover'(Grid,Survive,Flag_ls,Y,X) :-
  % 'uncover'/5
  % 'uncover'(+Grid, -Survive, +Flag_ls, +Y, +X)
  'get-board'(Y,X,Grid,Block), !,
  'uncover'(Grid,Survive,Flag_ls,Block).

'uncover'(_,   false,_,'block'('land-mine',_)).
'uncover'(Grid,true,Flag_ls,'block'('number'(N),'y-x'(Y,X))) :-
  % 'uncover'/4
  % 'uncover'(+Grid, -Survive, +Flag_ls, +Block)
  (number(N),!,true; % 此方块已经翻开，无需操作
   member('y-x'(Y,X),Flag_ls),!,true; % 此方块已经插旗，无需操作
   var(N),!,
   'get-3x3'(Y,X,Grid,Neighbor_ls),
   findall(Block,(member(Block, Neighbor_ls),
                  Block='block'('land-mine',_)),
           Mines),
   length(Mines,N),
   (N = 0,!, % 如果周围方块无雷，继续翻开周围方块
    'maplist'('uncover'(Grid,true,Flag_ls),Neighbor_ls);
    true)).

main() :-
  Width = 10, Height = 10,
  N_mines = 9,
  'make-board'(Height,Width,Grid), 'assign-land-mine'(N_mines,Grid),
  repl(Grid,1,1,[],Height,Width,N_mines).

repl(Grid,Y,X,Flag_ls,Height,Width,N_mines) :-
  shell('clear'),
  write_ln("[W/A/S/D] 移动"),
  write_ln("[U/u/Spc] 翻开"),
  write_ln("[F/f] 插旗或取消标记"),
  write_ln("[Q/q] 退出"),
  'draw-board'(Y,X,Flag_ls,Grid),
  % 获取用户输入
  get_single_char(Input),char_code(Char,Input),
  ((Char = 'Q';Char = 'q'), halt;
   handle_State(Char,Grid,Y,X,Flag_ls, Y_, X_, Flag_ls_,Survive),
   (Survive == false,!,write_ln("死喽"),halt;
    Survive == true,!,
    ('win?'(Grid,Width*Height,N_mines),!,write_ln("你赢了"); %
     % 坐标边界判断
     (Y_ > Height,!, Y__ = Height;
      Y_ < 1,!, Y__ = 1;
      Y__ = Y_),
     (X_ > Width,!, X__ = Width;
      X_ < 1,!, X__ = 1;
      X__ = X_),
     repl(Grid,Y__,X__,Flag_ls_,Height,Width,N_mines)))). % 下一轮 repl

handle_State('W',_   ,Y,X,Flag_ls,Y_,X , Flag_ls,true) :- Y_ is Y - 1.
handle_State('w',_   ,Y,X,Flag_ls,Y_,X , Flag_ls,true) :- Y_ is Y - 1.
handle_State('A',_   ,Y,X,Flag_ls,Y ,X_, Flag_ls,true) :- X_ is X - 1.
handle_State('a',_   ,Y,X,Flag_ls,Y ,X_, Flag_ls,true) :- X_ is X - 1.
handle_State('S',_   ,Y,X,Flag_ls,Y_,X , Flag_ls,true) :- Y_ is Y + 1.
handle_State('s',_   ,Y,X,Flag_ls,Y_,X , Flag_ls,true) :- Y_ is Y + 1.
handle_State('D',_   ,Y,X,Flag_ls,Y ,X_, Flag_ls,true) :- X_ is X + 1.
handle_State('d',_   ,Y,X,Flag_ls,Y ,X_, Flag_ls,true) :- X_ is X + 1.
handle_State(' ',Grid,Y,X,Flag_ls,Y ,X , Flag_ls,Survive) :-
  member('y-x'(Y,X),Flag_ls), !, Survive = true; % 已经插旗则不允许开启
  'uncover'(Grid,Survive,Flag_ls,Y,X).
handle_State('U',Grid,Y,X,Flag_ls,Y ,X , Flag_ls,Survive) :-
  member('y-x'(Y,X),Flag_ls), !, Survive = true;
  'uncover'(Grid,Survive,Flag_ls,Y,X).
handle_State('u',Grid,Y,X,Flag_ls,Y ,X , Flag_ls,Survive) :-
  member('y-x'(Y,X),Flag_ls), !, Survive = true;
  'uncover'(Grid,Survive,Flag_ls,Y,X).
handle_State('F',Grid,Y,X,Flag_ls,Y ,X , Flag_ls_,true) :-
  'get-board'(Y,X,Grid,'block'('number'(N),_)), number(N), !, Flag_ls_ = Flag_ls; % 已经开放的节点不允许插旗
  select('y-x'(Y,X),Flag_ls,Flag_ls_), !; % 已经插旗的节点取消插旗
  Flag_ls_ = ['y-x'(Y,X)|Flag_ls].
handle_State('f',Grid,Y,X,Flag_ls,Y ,X , Flag_ls_,true) :-
  'get-board'(Y,X,Grid,'block'('number'(N),_)), number(N), !, Flag_ls_ = Flag_ls;
  select('y-x'(Y,X),Flag_ls,Flag_ls_), !;
  Flag_ls_ = ['y-x'(Y,X)|Flag_ls].

'win?'(Grid,N_blocks,N_mines) :-
  % 胜利的条件是所有非雷块均被开启
  flatten(Grid, List),
  findall(N,(member('block'('number'(N),_),List),number(N)),Uncovered),
  length(Uncovered,N),
  N =:= N_blocks - N_mines.

