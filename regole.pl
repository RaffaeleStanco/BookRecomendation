% ===========================================================================================================
%  Formato fatti: libro(Titolo, Autore, G1, G2, G3, Lunghezza, Valutazione, Liked).
%  Lunghezza: short | medium | long
%  Valutazione: low | average | high | top
%
%  Strategia adottata: ogni regola richiede una combinazione di condizioni così da limitare i falsi positivi.
%  I libri con tutti i generi 'unknown' non vengono mai consigliati.
% ===========================================================================================================

% ------------------------------------------------------------------
%  GUARDIA GLOBALE: generi tutti unknown → mai consigliato
%  (nel dataset: 12 yes vs 88 no e quindi genererebbe troppo rumore)
% ------------------------------------------------------------------

tutti_unknown('unknown', 'unknown', 'unknown').

% ------------------
%  Regola principale
% ------------------

consigliato(Titolo) :-
    libro(Titolo, _, G1, G2, G3, Lunghezza, Valutazione, _),
    \+ tutti_unknown(G1, G2, G3),
    (
        fiction_con_subgenere_forte(G1, G2, G3)
      ; fiction_ben_valutata(G1, G2, G3, Valutazione)
      ; fumetto_ben_valutato(G1, G2, G3, Valutazione)
      ; fiction_breve(G1, G2, G3, Lunghezza)
      ; long_solo_se_top(G1, G2, G3, Lunghezza, Valutazione)
      ; classico_letterario(G1, G2, G3, Valutazione)
    ).

% --------------------------------------------------------------------------------
%  Regola 1 – fiction + subgenere forte
%  Calibrazione: fiction+fantasy 18yes/1no, fiction+mysteryamp 16yes/0no,
%                fiction+thrillers 10yes/2no, quindi hanno un'altissima precisione
% --------------------------------------------------------------------------------

fiction_con_subgenere_forte(G1, G2, G3) :-
    (G1 = fiction ; G2 = fiction ; G3 = fiction),
    (subgenere_forte(G1) ; subgenere_forte(G2) ; subgenere_forte(G3)).

subgenere_forte(fantasy).
subgenere_forte(darkfantasy).
subgenere_forte(epic).
subgenere_forte(mysteryamp).
subgenere_forte(mysterydetective).
subgenere_forte(detective).
subgenere_forte(thrillers).
subgenere_forte(suspense).
subgenere_forte(crime).
subgenere_forte(horror).
subgenere_forte(sciencefiction).
subgenere_forte(actionamp).
subgenere_forte(fairytales).
subgenere_forte(folktales).
subgenere_forte(literary).
subgenere_forte(classics).

% ----------------------------------------------------------------------
%  Regola 2 – fiction generica ma ben valutata
%  fiction senza subgenere forte è accettabile se valutazione top o high
% ----------------------------------------------------------------------

fiction_ben_valutata(G1, G2, G3, Valutazione) :-
    (G1 = fiction ; G2 = fiction ; G3 = fiction),
    \+ (subgenere_forte(G1) ; subgenere_forte(G2) ; subgenere_forte(G3)),
    (Valutazione = top ; Valutazione = high).

% -------------------------------------------------------------
%  Regola 3 – fumetto / graphic novel ben valutato
%  comicsamp+top/high: 6yes/1no, quindi ha una buona precisione
% -------------------------------------------------------------

fumetto_ben_valutato(G1, G2, G3, Valutazione) :-
    (fumetto(G1) ; fumetto(G2) ; fumetto(G3)),
    (Valutazione = top ; Valutazione = high).

fumetto(comicsamp).
fumetto(graphicnovels).
fumetto(comicsgraphicnovels).
fumetto(superheroes).

% --------------------------------------------------------
%  Regola 4 – fiction breve
%  Narrativa di lunghezza short è quasi sempre consigliata
% --------------------------------------------------------

fiction_breve(G1, G2, G3, short) :-
    (G1 = fiction ; G2 = fiction ; G3 = fiction).

% ----------------------------------------------------
%  Regola 5 – lungo solo se fiction + top
%  I libri long sono rischiosi: si consigliano solo se
%  hanno genere fiction/fantasy e valutazione massima
% ----------------------------------------------------

long_solo_se_top(G1, G2, G3, long, top) :-
    (G1 = fiction ; G2 = fiction ; G3 = fiction
   ; subgenere_forte(G1) ; subgenere_forte(G2) ; subgenere_forte(G3)).

% -------------------------------------------------------
%  Regola 6 – classico o letterario ben valutato
%  literary/classics con high o top sono quasi sempre yes
% -------------------------------------------------------

classico_letterario(G1, G2, G3, Valutazione) :-
    (G1 = literary  ; G2 = literary  ; G3 = literary
   ; G1 = classics  ; G2 = classics  ; G3 = classics),
    (Valutazione = top ; Valutazione = high).

% ------------------------------------------------------
%  Regola di esclusione
%  Libro sconsigliato: lungo e poco valutato
%  oppure: tutti i generi unknown poichè troppo rumoroso
% ------------------------------------------------------

sconsigliato(Titolo) :-
    libro(Titolo, _, G1, G2, G3, Lunghezza, Valutazione, _),
    (
        tutti_unknown(G1, G2, G3)
      ; (Lunghezza = long, Valutazione = low)
      ; (Valutazione = low, \+ (G1 = fiction ; G2 = fiction ; G3 = fiction))
    ).
