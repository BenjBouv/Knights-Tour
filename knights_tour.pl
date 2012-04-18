% Probl�me du cavalier

%
%
%
% D�placement avec heuristique.
%
%
%
	
cavalier(Parcours) :- 
	config(N,M), 
	Total is N*M, 
	generer(Total, L), 
	position(I,J),
	pos2d(I, J, P),
	changerElement(P, 1, L, L2),
	deplacerMieux(I, J, L2, 1, Solution),
	Parcours = [(I, J)|Solution].

% Teste si (I,J) est bien dans l'�chiquier.
case(I, J) :- config(N, M), I >= 1, J >= 1, N >= I, M >= J.

% Affiche une liste pass�e en param�tre.
affListe([]).
affListe([X|L]) :- write(X), write( ,), affListe(L).

% G�n�re une liste � N �l�ments contenant uniquement des 0.
generer(0, []) :- !.
generer(N, [0|L]) :- N1 is N-1, generer(N1, L).

% Appel : changerElement(+Indice, +ElementDeRemplacement, +ListeEntree, -ListeSortie).
changerElement(1, Y, [_|L], [Y|L]) :- !.
changerElement(I, Y, [X|L], [X|Z]) :- 
	I1 is I-1, 
	changerElement(I1, Y, L, Z).

% Renvoie l'�l�ment en I�me position dans la liste pass�e en second
% argument et stocke le r�sultat dans X (appel element(+Indice, +Liste, -X).).
element(1, [X|_], X) :- !.
element(I, [_|L], Y) :- I1 is I-1, element(I1, L, Y).
	
% Appel : (+I, +J, -P).
% Convertit une case (I,J) en 2D en un indice P � 1D.
pos2d(I, J, P) :- config(N,_), P is (I-1)*N+J.

% Appel : (+P, -I, -J).
% Convertit un indice P � 1D en une case (I,J) en 2D.
pos1d(P, I, J) :- 
	config(N,_), 
	I is 1+ ((P-1) // N), 
	J is P - (I-1)*N.

% V�rifi� si et seulement si la case (I,J), dans l'�chiquier sous forme
% de liste L, est non occup�e.
caseVide(I, J, L) :-
	case(I,J),
	pos2d(I,J,Indice),
	element(Indice,L,Valeur),
	Valeur =:= 0.

% Repr�sente tous les mouvements possibles (I1,J1) du cavalier � partir
% de la case (I, J).
mouvementCavalier(I, J, I1, J1) :- I1 is I+1, J1 is J+2.
mouvementCavalier(I, J, I1, J1) :- I1 is I+2, J1 is J+1.
mouvementCavalier(I, J, I1, J1) :- I1 is I+2, J1 is J-1.
mouvementCavalier(I, J, I1, J1) :- I1 is I+1, J1 is J-2.
mouvementCavalier(I, J, I1, J1) :- I1 is I-1, J1 is J-2.
mouvementCavalier(I, J, I1, J1) :- I1 is I-2, J1 is J+1.
mouvementCavalier(I, J, I1, J1) :- I1 is I-2, J1 is J-1.
mouvementCavalier(I, J, I1, J1) :- I1 is I-1, J1 is J+2.

% V�rifi� si un mouvement est possible � partir de cette case.
% Utilis� pour compter le nombre de mouvements possibles � partir
% d'une case.
mouvementPossible(I, J, L) :- 
	mouvementCavalier(I, J, I1, J1), 
	caseVide(I1,J1,L).

% V�rifie que le nombre de mouvements possibles � partir de la case
% (I,J) dans l'�chiquier L vaut V-1.
% Le -1 provient du fait qu une fois sur la case suivante, on ne
% peut pas retourner sur la case de d�part. 
caseVerifieValuation(I, J, L, V) :-
	caseVide(I, J, L),
	setof(_, mouvementPossible(I,J,L), L2),
	V2 is V-1, 
	length(L2, V2).

% Pour la case (I,J) dans l'�chiquier L, renvoie la prochaine case 
% (I1, J1) qui v�rifie la valuation V, si elle existe (et renvoie faux
% sinon).
mouvementPossibleValue(I, J, L, V, I1, J1) :- 
	mouvementCavalier(I, J, I1, J1),
	caseVerifieValuation(I1,J1,L,V).

% Recherche la valuation minimale accessible depuis la case actuelle.	
rechIndiceMaxV(I, J, L, MaxCherche, MaxReel) :- 
	MaxCherche =< 8, % 8 == nombre maximal de mouvements � partir d'une case
	mouvementPossibleValue(I, J, L, MaxCherche, _, _), 
	% !, % Empiriquement, une coupure ici r�sout plus rapidement certains tours.
	   % Cependant, cela coupe aussi certaines solutions.
	MaxReel is MaxCherche.
rechIndiceMaxV(I, J, L, MaxCherche, MaxReel) :- 
	MaxCherche =< 7, % ligne suivante, on ajoute 1.
	Max1 is MaxCherche+1, 
	rechIndiceMaxV(I, J, L, Max1, MaxReel). 

% Pour le dernier moment, il n'y a pas de valuation � rechercher, mais
% simplement une case disponible. Cette fonction renvoie une derni�re
% case possible, dans le cas o� on est arriv� au dernier mouvement.
dernierMouvement(I, J, L, I1, J1, Num) :-
	config(N,M),
	AvantDernierMouvement is N*M-1,
	Num =:= AvantDernierMouvement,
	mouvementCavalier(I, J, I1, J1),
	caseVide(I1,J1,L).

% Renvoie le mouvement optimal � partir de la case (I,J) dans
% l'�chiquier L et stocke le r�sultat dans (I1, J1).
mouvementOptimal(I, J, L, I1, J1) :-
	rechIndiceMaxV(I, J, L, 1, MaxReel),
	mouvementPossibleValue(I, J, L, MaxReel, I1, J1).

% Fonction de d�placement am�lior�.
% Appel : deplacerMieux(I, J, L, Num, Parcours).
% A partir de la case (I,J) dans l'�chiquier L, effectue le d�placement
% num�ro Num et enregistre le parcours effectu� dans Parcours.

% Pour le dernier d�placement, rediriger vers dernierMouvement.
deplacerMieux(I, J, L, Num, [(I1, J1)]) :- 
	dernierMouvement(I, J, L, I1, J1, Num),
	!.

% Pour les autres d�placement, on r�cup�re le mouvement optimal
% et on se d�place dans la case correspondante, puis on appelle
% r�cursivement la fonction.
deplacerMieux(I, J, L, Num,[(I1,J1)|Parcours]) :-
	mouvementOptimal(I, J, L, I1, J1),
	pos2d(I1, J1, P), 
	changerElement(P, Num, L, L2),
	Num2 is Num+1,
	deplacerMieux(I1, J1, L2, Num2, Parcours),
	!. % pour ne trouver qu une seule solution

%
%
%
% Deplacement simple du cavalier
%
%
%

cavalierSimple(Parcours) :-
	config(N,M), 
	Total is N*M, 
	generer(Total, L), 
	position(I,J),
	deplacer(I, J, L, 0, Parcours).

% Cette fonction renvoie vrai si et seulement si la liste
% pass�e en param�tre ne contient aucun z�ro.
listeSansZero([]) :- !.
listeSansZero([X|L]) :- X \== 0, listeSansZero(L).
	
% Si possible, d�place le cavalier de la position (I,J) dans l'�chiquier L
% pour le Num-i�me coup, enregistrant la liste obtenue dans L2 et en
% incr�mentant le nombre de coups dans Num2.
essayerDeplacer(I, J, L, Num, L2, Num2) :- 
	case(I,J), 
	pos2d(I, J, Indice),
	element(Indice, L, Valeur),
	Valeur =:= 0, % la case est vide
	Num2 is Num+1,
	changerElement(Indice, Num2, L, L2).

% D�place depuis la case (I,J) de l'�chiquier L, pour le Num-i�me coup,
% enregistre la position, essaye le d�placement demand� et demande le
% d�placement suivant.
deplacer(I, J, L, Num, [(I,J)]) :- 
	essayerDeplacer(I,J,L,Num,L2,_), 
	listeSansZero(L2), 
	!.
deplacer(I, J, L, Num, [(I,J)|Parcours]) :- 
	essayerDeplacer(I, J, L, Num, L2, Num2),
	effectuerDeplacementSuivant(I, J, L2, Num2, Parcours),
	!. % pour ne trouver qu une seule solution

% Pour chacun des mouvements possibles du cavalier, essaie le d�placement
% dans cette direction.
effectuerDeplacementSuivant(I, J, L, Num, Parcours) :- 
	mouvementCavalier(I, J, I1, J1),
	deplacer(I1,J1,L, Num,Parcours).

%
%
%
% IHM
%
%
%	
	
afficherSolution(Parcours) :-
	config(N, _),
	echiquier('Cavalier', N),
	simul(Parcours).
	
save([], _).
save([(X,Y)|L], I) :- Term =.. [parcours, I, X, Y], assert(Term), J is I+1 ,save(L, J).
	
simul(L) :-
	save(L, 1),
	parcours(1, X, Y),
	drawCavalier(X,Y),
	new(@go, dialog('Next step')),
	new(@previousStep, button(previous_step)),
	send(@previousStep, message, message(@prolog, previousStep, 1)),
	new(@nextStep, button(next_step)),
	send(@nextStep, message, message(@prolog, nextStep, 1)),
	send(@go, append, @previousStep),
	send(@go, append, @nextStep),
	send(@go, open).
	
colonne(_, 0).
colonne(I, J) :- J >= 1, Term =.. [case1, I, J], assert(Term), J1 is J-1, colonne(I, J1).
grille(0, _).
grille(I, J) :- I >= 1, colonne(I, J), I1 is I-1, grille(I1, J).
genererGrille(N) :- grille(N,N).

colorercase1(X, Y) :- 
	Y mod 2 =:= 1, X mod 2 =:= 1, 
	new(B, box(20, 20)),
	send(@grille, display, B, point((X-1)*20, (Y-1)*20)),
	send(B, fill_pattern, colour(black)).
colorercase1(X, Y) :- 
	Y mod 2 =:= 0, X mod 2 =:= 0, 
	new(B, box(20, 20)),
	send(@grille, display, B, point((X-1)*20, (Y-1)*20)),
	send(B, fill_pattern, colour(black)).
colorercase1(X, Y) :- 
	new(B, box(20, 20)),
	send(@grille, display, B, point((X-1)*20, (Y-1)*20)),
	send(B, fill_pattern, colour(white)).

takecase1(X, Y) :- 
	Y mod 2 =:= 1, X mod 2 =:= 1, 
	new(B, box(20, 20)),
	send(@grille, display, B, point((X-1)*20, (Y-1)*20)),
	send(B, fill_pattern, colour(red)).
takecase1(X, Y) :- 
	Y mod 2 =:= 0, X mod 2 =:= 0,
	new(B, box(20, 20)),
	send(@grille, display, B, point((X-1)*20, (Y-1)*20)),
	send(B, fill_pattern, colour(red)).
takecase1(X, Y) :- 
	new(B, box(20, 20)),
	send(@grille, display, B, point((X-1)*20, (Y-1)*20)),
	send(B, fill_pattern, colour(blue)).

drawCavalier(X, Y) :- 
	new(B, box(20, 20)),
	send(@grille, display, B, point((X-1)*20, (Y-1)*20)),
	send(B, fill_pattern, colour(yellow)).
	
echiquier(T, N) :-
	genererGrille(N),
	Term =.. [size, N],
	assert(Term),
	new(@grille, window(T)),
	send(@grille, open),
	send(@grille, width(N*20)),
	send(@grille, height(N*20)),
	forall(case1(X, Y),colorercase1(X, Y)).
	
setSize :-
	new(Dialog, dialog('Parametres')),
	send_list(Dialog, append,
		[ 	new(T, text_item(titre)),
			new(S1, int_item(taille_echiquier, low := 1, high := 40)),
			button(creer, and(message(@prolog,echiquier,T?selection,S1?selection), 
			message(Dialog, destroy)))
		]),
		send(Dialog, default_button, creer),
		send(Dialog, open).
	
nextStep(I) :-
	parcours(I, X1, Y1),
	J is I+1,
	parcours(J, X2, Y2),
	takecase1(X1, Y1),
	drawCavalier(X2, Y2),
	send(@nextStep, message, message(@prolog, nextStep, J)),
	send(@previousStep, message, message(@prolog, previousStep, J)).

previousStep(I) :-
	I > 1,
	J is I-1,
	parcours(I, X1, Y1),
	parcours(J, X2, Y2),
	colorercase1(X1,Y1),
	drawCavalier(X2,Y2),
	send(@nextStep, message, message(@prolog, nextStep, J)),
	send(@previousStep, message, message(@prolog, previousStep, J)).
	
%
%
%
% - Partie lanc�e au d�marrage
%
%
%
:-  write('Entrez le nombre de lignes de l echiquier '),
	read(N),
	write('Entrez le nombre de colonnes de l �chiquier '),
	read(M),
	write('Entrez la position de d�part du cavalier : I='),
	read(I),
	write('J='),
	read(J),
	TermConfig =.. [config, N, M],
	TermPosition =.. [position, I, J],
	assert(TermConfig),
	assert(TermPosition).
	
go:-
	cavalier(P),
	afficherSolution(P).