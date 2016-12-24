%List Tetangga
tetangga(bedroom,castle).
tetangga(castle,armory).
tetangga(armory,dragon_treasury).



%List Rule :D


%PRIMITIF

write_list([]).							%basis
write_list([H|T]) :-					%tulis head, lalu proses tail
	tab(1),write(H),write_list(T).

is_member(_,[]) :-		%basis 0
	fail,!.
is_member(X,[X|_]).		%basis, ketemu
is_member(X,[H|T]) :-	%head <> X, proses tail
	is_member(X,T).

delete_list([H|T],H,T).
delete_list([H|T1],X,[H|T2]) :-
	delete_list(T1,X,T2).

add_list(L,X,[X|L]).

connected(X,Y) :-
	tetangga(X,Y);tetangga(Y,X).



%FUNGSI GAME


start :-
	asserta(item(bedroom,[bed])),
	asserta(item(castle,[armor,shield,maps])),
	asserta(item(armory,[desk,sword])),
	asserta(item(dragon_treasury,[princess])),
	asserta(item(inventory,[])),
	asserta(here(castle)),
	write('Welcome to Tio''s World where everything is made up and nothing holds an importance!'),nl,
	write('Your job is to find Princess for Tio the Knight in Shining Armor by exploring this nonsense world!'),nl,
	write('You can explore by using command:'),nl,
	write('- look'),nl,
	write('- sleeping'),nl,
	write('- readmap'),nl,
	write('- goto(place)'),nl,
	write('- take(object)'),nl,
	write('- sharpen(object)'),nl,
	write('- quit'),nl,
	repeat,
	nl,write('>'),tab(1),
	read(Command),
	do(Command),
	is_end.


do(start) :- start,!.
do(look) :- look,!.
do(sleeping) :- sleeping,!.
do(readmap) :- readmap,!.
do(goto(Place)) :- goto(Place),!.
do(take(Object)) :- take(Object),!.
do(sharpen(Object)) :- sharpen(Object),!.
do(quit) :- quit,!.
do(X) :-
	write('I don''t understand '),write(X),nl,fail,!.


look :-
	here(X),
	write('You are in '),write(X),nl,
	tab(1),write('You can see: '),item(X,L),write_list(L),nl,
	tab(1),write('Your inventory: '),item(inventory,L1),write_list(L1).


readmap:-				%sudah ada map
	item(inventory,L),
	is_member(maps,L),
	write('You open the wonderful map and see whats inside'),nl,
	write('dragon_treasury | armory | castle | bedroom |'),!.

readmap :-				
	item(inventory,L),
	\+ is_member(maps,L),  %belum ada map
	write('You can''t read map because you don''t have it'),nl,
	!.


take(Object) :-
	here(X),
	item(X,L),
	is_member(Object,L), 					%object ada di ruangan

	delete_list(L,Object,NewList_ruang),	%buang dari list barang di ruangan
	retract(item(X,_)),
	asserta(item(X,NewList_ruang)),

	item(inventory,L1),						%tambahkan ke inventory
	add_list(L1,Object,NewList_inven),
	retract(item(inventory,_)),
	asserta(item(inventory,NewList_inven)),!.

take(Object) :-
	here(X),
	item(X,L),
	\+ is_member(Object,L), 				%object tidak ada di ruangan
	write('There is no such thing as '),write(Object),write(' here'),nl,
	!.

sleeping :-
	here(X),
	X = bedroom,
	write('Have a good night O Tio, Knight in Shining Armor'),nl,!.

sleeping :-
	here(X),
	\+ X = bedroom,
	write('O Tio, Knight in Shining Armor, one shall not lie on peasant mud'),nl,!.

can_slay_dragon :-

	item(inventory,L),
	is_member(armor,L),
	is_member(shield,L),
	have_sharpen(sword).

goto(Place) :-			%mau menyelamatkan putri, tapi belom tercapai
	here(X),
	connected(X,Place),
	Place = dragon_treasury,
	can_slay_dragon,
	retract(here(_)),
	asserta(here(Place)),look,!.

goto(Place) :-
	here(X),
	connected(X,Place),
	Place = dragon_treasury,
	\+ can_slay_dragon,
	write('The Dragon Treasury is being Guarded by Fat Dragon Tiyoks, you have to take armor, shield, and sharpen your sword first'),!.

goto(Place) :-
	here(X),
	connected(X,Place),
	retract(here(_)),
	asserta(here(Place)),look,!.

goto(Place) :-
	here(X),
	\+ connected(X,Place), %tidak terhubung
	write('You can''t get there from here'),nl,!.

sharpen(X) :-
	X = sword,
	item(inventory,L),
	is_member(X,L),

	asserta(have_sharpen(sword)).

sharpen(X) :-
	\+ X = sword,
	write('You can''t sharpen this'),nl,!.

sharpen(X) :-
	X = sword,
	have_sharpen(sword),
	write('One can only sharpen sword once'),nl,!.

sharpen(X) :-
	X = sword,
	item(inventory,L),
	\+ is_member(X,L), %belum ada di inventory
	write('You don''t have sword in your inventory'),nl,!.

quit :-
	item(inventory,L),
	add_list(L,game/off,L1),
	retract(item(inventory,_)),
	asserta(item(inventory,L1)),!.

is_end :-
	item(inventory,L),
	is_member(game/off,L),
	write('Get Off QUITTER'),nl,
	retractall(item(X,_)),
	retract(here(_)),
	asserta(have_sharpen(dummy)) ,!.

is_end :-
	item(inventory,L),
	is_member(princess,L),
	write('Congrats :D'),nl,
	retractall(item(X,_)),retract(here(_)),
	asserta(have_sharpen(dummy)),!.


