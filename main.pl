
'make-board'(Height,Width,X) :-
  % 创建出 Height 行，Width 列的网格
  Height =:= 0, !, X = [];
  !, length(List, Width), X = [List|Rest],
  Height_ is Height - 1,
  'make-board'(Height_,Width,Rest).

'get-board'(Row,Col,Board,X) :-
  % 从网格中指定索引获取元素
  nth1(Row,Board,Board_),
  nth1(Col,Board_,X).

'get-3'(C_center, Row, List) :-
  % 从一行中截取 3 个元素（自动处理边缘情况）
  C_start is C_center -1,
  C_end is C_center +1,
  findall(Element, 
           (between(C_start, C_end, Index),
            nth1(Index, Row, Element)),
          List).

'get-3x3'(R_center,C_center,Board,List) :-
  % 从网格中截取 3x3 元素（自动处理边缘 2x2、2x3 等情况）
  R_start is R_center -1,
  R_end is R_center +1,
  findall(Element, 
           (between(R_start, R_end, Index),
            nth1(Index, Board, Element)),
          List_),
  maplist('get-3'(C_center), List_, List__),
  flatten(List__,List). % 扁平化截取结果

main() :-
  shell('clear'),
  write_ln("[W/A/S/D] 移动"),
  write_ln("[U/u/Spc] 翻开"),
  write_ln("[F/f] 插旗或取消标记"),
  write_ln("[Q/q] 退出").

