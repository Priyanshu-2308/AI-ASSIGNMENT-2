% Constants  : mira, scroll_7, royal_archive
% Variables  : x (person), r (record)
% Predicates : archivist/1, verifies/2, trusted/1, has_access/2, sealed/1,
%              permitted/2, inspects/2, finds_mark/2, stored_in/2

:- initialization(main).
:- dynamic stage/3, clause_db/3.

% Step 1: Predicate logic representation
fol(1, 'Archivist who verifies a record is trusted',
    forall(v(x), forall(v(r),
        imp(and(archivist(v(x)), verifies(v(x),v(r))), trusted(v(x)))))).
fol(2, 'Trusted person with access to a sealed record may inspect it',
    forall(v(x), forall(v(r),
        imp(and(trusted(v(x)), and(has_access(v(x),v(r)), sealed(v(r)))),
            permitted(v(x),v(r)))))).
fol(3, 'Inspecting a record and finding a hidden mark verifies it',
    forall(v(x), forall(v(r),
        imp(and(inspects(v(x),v(r)), finds_mark(v(x),v(r))), verifies(v(x),v(r)))))).
fol(4, 'Every record stored in the royal archive is sealed',
    forall(v(r),
        imp(stored_in(v(r),royal_archive), sealed(v(r))))).
fol(5, 'scroll_7 is stored in the royal archive',
    stored_in(scroll_7, royal_archive)).
fol(6, 'Mira has access to scroll_7',
    has_access(mira, scroll_7)).
fol(7, 'Mira inspects scroll_7 and finds a hidden mark in it',
    and(inspects(mira,scroll_7), finds_mark(mira,scroll_7))).
fol(8, 'Mira is an archivist',
    archivist(mira)).

goal(trusted(mira)).
step1 :-
    header('STEP 1: Predicate logic representation'),
    forall(fol(Id, Desc, F),
           ( assertz(stage(1,Id,F)),
             format("  [~w] ~w~n        ", [Id, Desc]), pp(F), nl )),
    goal(G), format("~n  GOAL: "), pp(G), nl.

% Step 2: Negation of goal
step2 :-
    header('STEP 2: Negation of goal'),
    forall(stage(1,Id,F), assertz(stage(2,Id,F))),
    goal(G), NG = not(G),
    assertz(stage(2,9,NG)),
    format("  Goal           : "), pp(G),  nl,
    format("  Negated goal   : "), pp(NG), nl,
    format("  [9] added to the knowledge base.~n").

% Step 3: Implication removal
remove_imp(imp(A,B), or(not(A1),B1)) :- !, remove_imp(A,A1), remove_imp(B,B1).
remove_imp(and(A,B), and(A1,B1))     :- !, remove_imp(A,A1), remove_imp(B,B1).
remove_imp(or(A,B),  or(A1,B1))      :- !, remove_imp(A,A1), remove_imp(B,B1).
remove_imp(not(A),   not(A1))        :- !, remove_imp(A,A1).
remove_imp(forall(V,A), forall(V,A1)):- !, remove_imp(A,A1).
remove_imp(exists(V,A), exists(V,A1)):- !, remove_imp(A,A1).
remove_imp(F, F).

step3 :-
    header('STEP 3: Implication removal  (A -> B  ==>  ~A | B)'),
    forall(stage(2,Id,F),
           ( remove_imp(F,G), assertz(stage(3,Id,G)), show(Id,G) )).

% Step 4: Negation movement
nnf(not(not(A)),     R)         :- !, nnf(A,R).
nnf(not(and(A,B)),   or(A1,B1)) :- !, nnf(not(A),A1), nnf(not(B),B1).
nnf(not(or(A,B)),    and(A1,B1)):- !, nnf(not(A),A1), nnf(not(B),B1).
nnf(not(forall(V,A)),exists(V,A1)) :- !, nnf(not(A),A1).
nnf(not(exists(V,A)),forall(V,A1)) :- !, nnf(not(A),A1).
nnf(and(A,B),        and(A1,B1)):- !, nnf(A,A1), nnf(B,B1).
nnf(or(A,B),         or(A1,B1)) :- !, nnf(A,A1), nnf(B,B1).
nnf(forall(V,A),     forall(V,A1)) :- !, nnf(A,A1).
nnf(exists(V,A),     exists(V,A1)) :- !, nnf(A,A1).
nnf(F, F).

step4 :-
    header('STEP 4: Move negation inward (De Morgan / double negation)'),
    forall(stage(3,Id,F),
           ( nnf(F,G), assertz(stage(4,Id,G)), show(Id,G) )),
    format("  (Negations now apply only to atoms.)~n").

% Step 5: Standardization
fresh(N, M) :-
    nb_getval(vc, C), C1 is C+1, nb_setval(vc, C1),
    atomic_list_concat([N,'_',C1], M).

std(forall(v(N),B), forall(v(M),B2)) :- !, fresh(N,M), subst(B,v(N),v(M),B1), std(B1,B2).
std(exists(v(N),B), exists(v(M),B2)) :- !, fresh(N,M), subst(B,v(N),v(M),B1), std(B1,B2).
std(and(A,B), and(A1,B1)) :- !, std(A,A1), std(B,B1).
std(or(A,B),  or(A1,B1))  :- !, std(A,A1), std(B,B1).
std(not(A),   not(A1))    :- !, std(A,A1).
std(F, F).

subst(T,_,_,T)  :- var(T), !.
subst(T,O,N,N)  :- T == O, !.
subst(T,_,_,T)  :- atomic(T), !.
subst(T,O,N,R)  :- T =.. [F|As], subst_list(As,O,N,Bs), R =.. [F|Bs].
subst_list([],_,_,[]).
subst_list([A|As],O,N,[B|Bs]) :- subst(A,O,N,B), subst_list(As,O,N,Bs).

step5 :-
    header('STEP 5: Standardization (variables made unique across formulas)'),
    nb_setval(vc, 0),
    forall(stage(4,Id,F),
           ( std(F,G), assertz(stage(5,Id,G)), show(Id,G) )).

% Step 6: Skolemization
sk(forall(V,B), U, forall(V,B1)) :- !, sk(B,[V|U],B1).
sk(exists(V,B), U, R) :- !,
    nb_getval(skc,C), C1 is C+1, nb_setval(skc,C1),
    atom_concat(sk_,C1,Name), reverse(U,Us),
    ( Us == [] -> Sk = Name ; Sk =.. [Name|Us] ),
    subst(B,V,Sk,B1), sk(B1,U,R).
sk(and(A,B), U, and(A1,B1)) :- !, sk(A,U,A1), sk(B,U,B1).
sk(or(A,B),  U, or(A1,B1))  :- !, sk(A,U,A1), sk(B,U,B1).
sk(F,_,F).

step6 :-
    header('STEP 6: Skolemization'),
    nb_setval(skc, 0),
    forall(stage(5,Id,F),
           ( sk(F,[],G), assertz(stage(6,Id,G)), show(Id,G) )),
    nb_getval(skc, N),
    ( N =:= 0
    -> format("  No existential quantifiers occur in the knowledge base or the~n  negated goal, so NO Skolem constants/functions are needed.~n")
    ;  format("  ~w Skolem symbol(s) introduced.~n", [N]) ),
    format("  Remaining universal quantifiers are dropped (implicit) in Step 7.~n").

% Step 7: CNF clauses
drop_forall(forall(_,B), R) :- !, drop_forall(B,R).
drop_forall(and(A,B), and(A1,B1)) :- !, drop_forall(A,A1), drop_forall(B,B1).
drop_forall(or(A,B),  or(A1,B1))  :- !, drop_forall(A,A1), drop_forall(B,B1).
drop_forall(F,F).

cnf(and(A,B), C) :- !, cnf(A,CA), cnf(B,CB), append(CA,CB,C).
cnf(or(A,B),  C) :- !, cnf(A,CA), cnf(B,CB),
    findall(X, (member(P,CA), member(Q,CB), append(P,Q,X)), C).
cnf(L, [[L]]).

conv_clause(C, PC) :- conv_list(C, PC, [], _).
conv_list([],[],S,S).
conv_list([T|Ts],[U|Us],S0,S) :- conv(T,U,S0,S1), conv_list(Ts,Us,S1,S).
conv(v(N), V, S0, S) :- !, ( memberchk(N-V0, S0) -> V = V0, S = S0 ; S = [N-V|S0] ).
conv(T, T, S, S) :- atomic(T), !.
conv(T, U, S0, S) :- T =.. [F|As], conv_list(As,Bs,S0,S), U =.. [F|Bs].

step7 :-
    header('STEP 7: CNF clauses (each clause is a disjunction of literals)'),
    nb_setval(cn, 0),
    forall(stage(6,Id,F),
           ( drop_forall(F,M), cnf(M,Cs),
             forall(member(C,Cs),
                    ( conv_clause(C,PC),
                      nb_getval(cn,N0), N is N0+1, nb_setval(cn,N),
                      assertz(clause_db(N,PC,Id)),
                      format("  C~w: ", [N]), pp_clause(PC),
                      format("      (from formula [~w])~n", [Id]) )) )).

% Step 8: Resolution implementation and execution
compl(not(A), A) :- !.
compl(A, not(A)).

prove([], _, []) :- !.
prove(Cur, D, [step(CurC, N, CC, LitC, ResC)|T]) :-
    D > 0,
    Cur = [L|Rest],
    clause_db(N, C, Src), Src \== 9,
    copy_term(Cur-C, CurC-CC),
    select(M, C, CRest),
    copy_term(L-M, LitC),
    compl(L, M),
    append(Rest, CRest, Res),
    copy_term(Res, ResC),
    D1 is D-1,
    prove(Res, D1, T).

step8 :-
    header('STEP 8: Resolution refutation'),
    clause_db(GN, Start, 9),
    format("  Start with the negated goal  C~w: ", [GN]), pp_clause(Start), nl, nl,
    ( between(1, 15, Limit), prove(Start, Limit, Trace) -> true ; Trace = fail ),
    (   Trace == fail
    ->  format("  FAILED: no refutation found.~n")
    ;   print_trace(Trace, 1, GN),
        length(Trace, Len),
        format("~n  The empty clause [] was derived after ~w resolution steps.~n", [Len]),
        usage_report(Trace, GN)
    ).

print_trace([], _, _).
print_trace([step(Cur,N,C,LitPair,Res)|T], K, Prev) :-
    ( K =:= 1 -> PrevName = 'C10' ; atom_concat('R', Prev, PrevName) ),
    format("  Step ~w:~n", [K]),
    format("     ~w  = ", [PrevName]), pp_clause(Cur), nl,
    format("     C~w  = ", [N]),       pp_clause(C),   nl,
    LitPair = L-M, copy_term(L-M, L2-M2), numbervars(L2-M2, 0, _),
    format("     resolve on  "), pp(L2), format("  with  "), pp(M2), nl,
    format("     R~w  = ", [K]),       pp_clause(Res), nl, nl,
    K1 is K+1, print_trace(T, K1, K).

usage_report(Trace, _) :-
    findall(N, member(step(_,N,_,_,_), Trace), Used0), sort(Used0, Used),
    findall(N, (clause_db(N,_,Src), Src \== 9, \+ memberchk(N,Used)), Unused),
    format("  Knowledge-base clauses used in the proof   : ~w~n", [Used]),
    format("  Clauses not needed for this proof          : ~w~n", [Unused]).

% Step 9: Cross-check with plain Prolog
pl_trusted(X)   :- pl_archivist(X), pl_verifies(X,_).
pl_permitted(X,R) :- pl_trusted(X), pl_has_access(X,R), pl_sealed(R).
pl_verifies(X,R):- pl_inspects(X,R), pl_finds_mark(X,R).
pl_sealed(R)    :- pl_stored_in(R, royal_archive).
pl_stored_in(scroll_7, royal_archive).
pl_has_access(mira, scroll_7).
pl_inspects(mira, scroll_7).
pl_finds_mark(mira, scroll_7).
pl_archivist(mira).

step9 :-
    header('STEP 9: Cross-check with plain Prolog'),
    ( pl_trusted(mira)
    -> format("  ?- pl_trusted(mira).   true.   (agrees with the refutation)~n")
    ;  format("  ?- pl_trusted(mira).   false.~n") ).

header(T) :- format("~n~`=t~72|~n~w~n~`=t~72|~n", [T]).
show(Id, F) :- format("  [~w] ", [Id]), pp(F), nl.

pp(T) :- var(T), !, write('_').
pp('$VAR'(N)) :- !, write_term('$VAR'(N), [numbervars(true)]).
pp(v(X)) :- !, write(X).
pp(forall(v(X),B)) :- !, format("forall ~w.(", [X]), pp(B), write(')').
pp(exists(v(X),B)) :- !, format("exists ~w.(", [X]), pp(B), write(')').
pp(imp(A,B)) :- !, write('('), pp(A), write(' -> '), pp(B), write(')').
pp(and(A,B)) :- !, write('('), pp(A), write(' & '),  pp(B), write(')').
pp(or(A,B))  :- !, write('('), pp(A), write(' | '),  pp(B), write(')').
pp(not(A))   :- !, write('~'), pp(A).
pp(T) :- atomic(T), !, write(T).
pp(T) :- T =.. [P|Args], write(P), write('('), pp_args(Args), write(')').

pp_args([A])    :- !, pp(A).
pp_args([A|As]) :- pp(A), write(', '), pp_args(As).

pp_clause([]) :- !, write('[]  (EMPTY CLAUSE)').
pp_clause(C)  :- copy_term(C,C2), numbervars(C2,0,_), pp_lits(C2).
pp_lits([L])    :- !, pp(L).
pp_lits([L|Ls]) :- pp(L), write(' | '), pp_lits(Ls).

main :-
    retractall(stage(_,_,_)),
    retractall(clause_db(_,_,_)),
    format("ROYAL ARCHIVE ACCESS VERIFICATION - RESOLUTION REFUTATION~n"),
    step1, step2, step3, step4, step5, step6, step7, step8, step9,
    format("~n~`=t~72|~nCONCLUSION: KB + ~~trusted(mira) is unsatisfiable (empty clause derived),~nhence  trusted(mira)  is logically entailed.  Q.E.D.~n~`=t~72|~n").