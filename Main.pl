:- use_module(library(pce)).

% Places in Egypt
place(cairo).
place(mansoura).
place(luxor).
place(aswan).
place(hurghada).
place(sharm_el_sheikh).
place(ismailia).
place(port_said).
place(suez).
place(minya).
place(kafr_elshikh).
place(domyat).
place(sohag).
place(banha).
place(elzagazig).
place(sheben_elkom).

% Transportation modes
transportation(car).
transportation(train).
transportation(plane).

% Connections between places and available modes
connection(cairo, hurghada, plane).
connection(hurghada, sharm_el_sheikh, car).
connection(sharm_el_sheikh, luxor, plane).
connection(luxor, aswan, car).
connection(cairo, sheben_elkom, car).
connection(shebe_elkom, banha, car).
connection(banha, elzagazig, car).
connection(cairo, ismailia, car).
connection(ismailia, port_said, train).
connection(port_said, suez, car).
connection(cairo, mansoura, car).
connection(mansoura, kafr_elshikh, car).
connection(kafr_elshikh, domyat, car).
connection(cairo, minya, plane).
connection(minya, luxor, train).
connection(luxor, sohag, train).

% Time information for connections
time(cairo, hurghada, plane, 1).
time(hurghada, sharm_el_sheikh, car, 3).
time(sharm_el_sheikh, luxor, plane, 2).
time(luxor, aswan, car, 4).
time(cairo, shebe_elkom, car, 1).
time(sheben_elkom, banha, car, 2).
time(banha, elzagazig, car, 1).
time(cairo, ismailia, car, 2).
time(ismailia, port_said, train, 3).
time(port_said, suez, car, 1).
time(cairo, mansoura, car, 2).
time(mansoura, kafr_elshikh, car, 1).
time(kafr_elshikh, domyat, car, 1).
time(cairo, minya, plane, 1).
time(minya, luxor, train, 2).
time(luxor, sohag, train, 3).

% Rule to determine valid travel journeys
valid_journey(Start, End, Places, Modes, TotalTime) :-
    travel(Start, End, Modes, TotalTime),
    length(Modes, Len),
    Len >= 3, % Ensure at least three intermediate states
    get_places(Start, Modes, Places).

% Base case for direct connection
travel(Start, End, [Mode], Time) :-
    connection(Start, End, Mode),
    time(Start, End, Mode, Time).

% Recursive case for chained connections
travel(Start, End, [Mode | RestModes], TotalTime) :-
    connection(Start, Intermediate, Mode),
    time(Start, Intermediate, Mode, Time),
    travel(Intermediate, End, RestModes, RestTime),
    TotalTime is Time + RestTime.

% Helper rule to get the places in the journey
get_places(_, [], []).
get_places(Start, [Mode | RestModes], [Start | Places]) :-
    connection(Start, Intermediate, Mode),
    get_places(Intermediate, RestModes, Places).

% GUI code

% Define the main GUI window
main :-
    new(@main, dialog('Travel Planner')),
    send(@main, append, new(@start, text_item(start, ''))),
    send(@main, append, new(@end, text_item(end, ''))),
    send(@main, append, button(search, message(@prolog, search))),
    send(@main, open).

% Define the search button action
search :-
    get(@start, selection, Start),
    get(@end, selection, End),
    findall(Places-Modes-TotalTime, valid_journey(Start, End, Places, Modes, TotalTime), Journeys),
    display_journeys(Journeys).

% Display the found journeys in a new window
display_journeys([]) :-
    new(@result, dialog('No valid journeys found')),
    send(@result, append, button(ok, message(@result, destroy))),
    send(@result, open).
display_journeys(Journeys) :-
    new(@result, dialog('Valid Journeys')),
    display_journeys(@result, Journeys, 1),
    send(@result, append, button(ok, message(@result, destroy))),
    send(@result, open).

% Recursive predicate to display journeys in the result dialog
display_journeys(_, [], _).
display_journeys(ResultDialog, [Places-Modes-TotalTime | Rest], Index) :-
    atomic_list_concat(Modes, ' -> ', ModeStr),
    atomic_list_concat(['Journey ', Index, ': ', Places, ' (', ModeStr, ') - Total Time: ', TotalTime, ' hours'], DisplayText),
    send(ResultDialog, append, label(DisplayText)),
    NextIndex is Index + 1,
    display_journeys(ResultDialog, Rest, NextIndex).

% Entry point to start the GUI
:- initialization(main).

