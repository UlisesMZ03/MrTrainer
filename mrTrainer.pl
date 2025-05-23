:- use_module(library(socket)).
:- use_module(library(streampool)).

% Predicado principal que inicia la conversaci�n.
%
% Recibe:
% - Nada.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Lee la entrada del usuario, la convierte a min�sculas y la divide en palabras.
comenzar:-
    read_string(user_input, '\n', '.',_,Q),
    string_lower(Q,Minuscula),
    atomic_list_concat(List,' ',Minuscula),
    iniciarConversacionAux(List,[]).

% Predicado para iniciar la conversaci�n, considerando diferentes casos de entrada del usuario.
%
% Recibe:
% - Lista de palabras de la entrada del usuario.
% - Lista vac�a.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Verifica si el usuario saluda al entrenador o pregunta por la hora.
% Llama a los predicados correspondientes seg�n la entrada del usuario.
iniciarConversacion(List,Vacio):-
    saludo(List,Resto),
    entrenador(Resto,Vacio).

iniciarConversacion(List,Vacio):-
    saludo(List,Resto),
    hora(Resto,Vacio).

iniciarConversacion(List,Vacio):-
    saludo(List,Vacio).

% Predicado auxiliar para iniciar la conversaci�n y solicitar una rutina personalizada.
%
% Recibe:
% - Lista de palabras de la entrada del usuario.
% - Lista vac�a.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Llama a los predicados para obtener las preferencias del usuario (deporte, nivel y enfermedad).
% Env�a una solicitud al servidor para crear una rutina personalizada.
iniciarConversacionAux(List,[]):-
    iniciarConversacion(List,[]),
    deporteUsuario(Deporte),
    nivelUsuario(Nivel),
    enfermedadUsuario(Enfermedad),
    write("\n\n -> Esta es la rutina completamente personalizada segun tus elecciones: <-\n\n "),
    create_client('localhost',9999,("creame una rutina personalizada para cada dia de la semana tomando en cuenta lo siguiente:","Deporte que quiero practicar: ",Deporte,"Padecimiento que tengo: ",Enfermedad,"Nivel del entrenamiento: ",Nivel,"tomando en cuenta que principiante son solo 2 dias a la semana, intermedio son solo 4 dias dias a la semana y avanzado son solo 6 dias a la semana "),Response),
    break.

iniciarConversacionAux(List,[]):-
    write("�Me est�s saludando? Porque no te entend�.\n"),
    comenzar.

% Predicado para obtener el deporte preferido del usuario.
%
% Recibe:
% - Nada.
%
% Retorna:
% - Deporte seleccionado por el usuario.
%
% Funci�n:
% Pregunta al usuario si quiere empezar a entrenar y qu� deporte prefiere.
% Llama al predicado obtenerDeporte para procesar la respuesta.
deporteUsuario(Deporte):-
    write("�Hola! �C�mo est�s?\n �Te gustar�a empezar a entrenar? (si/no)"), nl,
    read_string(user_input, '\n', '.', _, Q),
    string_lower(Q,Minuscula),
    atomic_list_concat(List,' ',Minuscula),
    obtenerDeporte(List,[],Deporte).

deporteUsuario(Deporte):-
    write("No te entend�. Prueba las siguientes respuestas: \n Si / Si correr \n"),
    deporteUsuario(Deporte).

% Predicado para obtener el deporte preferido del usuario.
%
% Recibe:
% - Lista de palabras de la entrada del usuario.
% - Lista vac�a.
% - Deporte seleccionado por el usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Verifica si el usuario ha respondido afirmativamente y procesa la elecci�n del deporte.
obtenerDeporte(List, Vacio, Deporte):-
    si(List, Vacio),
    listarDeportes(Deporte).

obtenerDeporte(List,Vacio,Deporte):-
    no(List,Vacio),
    write("Av�same cuando quieras entrenar. �Adi�s!"), nl,
    break.

obtenerDeporte(List,Vacio,Deporte):-
    si(List,Resto),
    deporte(Resto,Vacio),
    atomics_to_string(Resto,Deporte).

% Predicado para listar los deportes disponibles.
%
% Recibe:
% - Deporte seleccionado por el usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Lista los deportes disponibles para que el usuario elija uno.
listarDeportes(DeporteSeleccionado):-
    write("Tenemos las siguientes categor�as: (Escribelo tal cual aparece en la lista)\n"),
    deporte([Deporte|_], _), % Obtener solo el primer elemento de la lista
    write("\t -> "), write(Deporte), write("\n"),
    fail.

listarDeportes(Deporte):-
    repeat,
    writeln('Por favor, introduce el deporte:'),
    read_string(user_input, '\n', '.', _, Q),
    string_lower(Q, DeporteSeleccionado),
    atomic_list_concat(Deporte, ' ', DeporteSeleccionado),
    deporte(Deporte,_),
    !.

% Predicado para obtener la enfermedad del usuario.
%
% Recibe:
% - Enfermedad seleccionada por el usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Pregunta al usuario si tiene alguna enfermedad que afecte su entrenamiento.
% Llama al predicado obtenerEnfermedad para procesar la respuesta.
enfermedadUsuario(Enfermedad):-
    write("�Has tenido alguna patolog�a que te impida hacer ejercicio con normalidad? \n"), nl,
    read_string(user_input, '\n', '.', _, Q),
    string_lower(Q,Minuscula),
    atomic_list_concat(List,' ', Minuscula),
    obtenerEnfermedad(List,[],Enfermedad).

enfermedadUsuario(Enfermedad):-
    write("No entend� tu respuesta. "),
    enfermedadUsuario(Enfermedad).

% Predicado para obtener la enfermedad del usuario.
%
% Recibe:
% - Lista de palabras de la entrada del usuario.
% - Lista vac�a.
% - Enfermedad seleccionada por el usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Verifica si el usuario ha respondido afirmativamente y procesa la elecci�n de la enfermedad.
obtenerEnfermedad(List, Vacio, Enfermedad):-
    si(List, Vacio),
    listarEnfermedades(Enfermedad).

obtenerEnfermedad(List,Vacio,Enfermedad):-
    enfermedad(List,Vacio),
    atomics_to_string(List,Enfermedad).


obtenerEnfermedad(List,Vacio,Enfermedad):-
    si(List,Resto),
    enfermedad(Resto,Vacio),
    atomics_to_string(Resto,enfermedad).

% Predicado para listar las enfermedades disponibles.
%
% Recibe:
% - Enfermedad seleccionada por el usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Lista las enfermedades disponibles para que el usuario elija una.
listarEnfermedades(EnfermedadSeleccionada):-
    write("Tenemos las siguientes enfermedades: (Escribela tal cual aparece en la lista)\n"),
    enfermedad([Enfermedad|_], _), % Obtener solo el primer elemento de la lista
    write("\t -> "), write(Enfermedad), write("\n"),

    fail.
listarEnfermedades(Enfermedad) :-
    repeat,
    writeln('Dime cual padecimiento tienes:'),
    read_string(user_input, '\n', '.', _, Q),
    string_lower(Q, EnfermedadSeleccionada),
    listaEnfermedades(Enfermedades),
    create_client('localhost', 9999,("Del siguiente texto solo devuelveme lo que consideres que es un padecimiento pero solo el padecimiento, sin verbos ni nada mas ", EnfermedadSeleccionada, "devuelvelo con el nombre obtenido aqui y si no se encuentra entres las opciones entonces elige una de las opciones que mas se aproxime al padecimiento (si o si debes elegir una de las opciones) de las siguientes: ",Enfermedades), Response),
    write(Response),
    atomic_list_concat(Enfermedad, ' ',Response ),

    (   enfermedad(Enfermedad, _) ->
        true
    ;   writeln('La enfermedad ingresada no es v�lida, por favor intenta de nuevo.'),
        fail
    ).

% Predicado para obtener la lista de enfermedades disponibles.
%
% Recibe:
% - Lista de enfermedades disponibles.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Obtiene la lista de enfermedades disponibles para que el usuario elija una.
listaEnfermedades(Enfermedades) :-
    findall(Enfermedad, enfermedad([Enfermedad|_], _), Enfermedades).

% Predicado para obtener el nivel de entrenamiento del usuario.
%
% Recibe:
% - Nivel de entrenamiento del usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Pregunta al usuario con qu� frecuencia practica deporte para determinar su nivel.
nivelUsuario(Nivel):-
    write("�Con qu� frecuencia practicas deporte?"), nl,
    read_string(user_input, '\n', '.', _,Q),
    sub_atom(Q,0,1,Despu�s,D�as),
    obtenerNivel(Nivel,D�as).

% Predicado para obtener el nivel de entrenamiento del usuario.
%
% Recibe:
% - Nivel de entrenamiento del usuario.
% - D�as de entrenamiento por semana.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Asigna un nivel de entrenamiento seg�n la frecuencia de entrenamiento del usuario.
obtenerNivel(Nivel,D�as):-
    nivel(Nivel,Cantidad),
    miembro(D�as,Cantidad).

miembro(X,[X|_]).
miembro(X,[_|Y]):-
    miembro(X,Y).

% Predicado para listar los deportes disponibles.
%
% Recibe:
% - Deporte seleccionado por el usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Lista los deportes disponibles para que el usuario elija uno.
deporte(['correr'|S],S).
deporte(['ciclismo'|S],S).
deporte(['nataci�n'|S],S).
deporte(['triatl�n'|S],S).
deporte(['yoga'|S],S).
deporte(['funcional'|S],S).
deporte(['futbol'|S],S).
deporte(['baloncesto'|S],S).
deporte(['tenis'|S],S).
deporte(['voleibol'|S],S).
deporte(['atletismo'|S],S).
deporte(['gimnasia'|S],S).
deporte(['escalada'|S],S).
deporte(['surf'|S],S).
deporte(['patinaje'|S],S).
deporte(['esgrima'|S],S).
deporte(['boxeo'|S],S).
deporte(['judo'|S],S).
deporte(['taekwondo'|S],S).
deporte(['karate'|S],S).
deporte(['lucha libre'|S],S).
deporte(['hockey sobre hielo'|S],S).
deporte(['rugby'|S],S).
deporte(['golf'|S],S).
deporte(['polo'|S],S).

% Predicado para listar las enfermedades disponibles.
%
% Recibe:
% - Enfermedad seleccionada por el usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Lista las enfermedades disponibles para que el usuario elija una.
enfermedad(['cardiopatia'|S],S).
enfermedad(['problemas_de_articulaciones'|S],S).
enfermedad(['problemas_de_columna'|S],S).
enfermedad(['asmatico'|S],S).
enfermedad(['hipertension_arterial'|S],S).
enfermedad(['enfermedad_cardiovascular'|S],S).
enfermedad(['enfermedad_cardiaca_congenita'|S],S).
enfermedad(['enfermedad_pulmonar_obstructiva_cronica'|S],S).
enfermedad(['diabetes'|S],S).
enfermedad(['obesidad'|S],S).
enfermedad(['sindrome_metabolico'|S],S).
enfermedad(['asma'|S],S).
enfermedad(['arritmia_cardiaca'|S],S).
enfermedad(['insuficiencia_cardiaca'|S],S).
enfermedad(['lesion_de_menisco'|S],S).
enfermedad(['lesion_de_tendon'|S],S).
enfermedad(['lesion_de_musculo'|S],S).
enfermedad(['esguince_de_tobillo'|S],S).
enfermedad(['fractura_de_hueso'|S],S).
enfermedad(['distension_muscular'|S],S).
enfermedad(['lesion_ligamentaria'|S],S).
enfermedad(['sobrecarga_muscular'|S],S).
enfermedad(['bursitis'|S],S).
enfermedad(['tendinitis'|S],S).
enfermedad(['contracturas'|S],S).
enfermedad(['ciatica'|S],S).
enfermedad(['epicondilitis'|S],S).
enfermedad(['bursitis_trocanterea'|S],S).
enfermedad(['sindrome_del_piriforme'|S],S).
enfermedad(['lesion_cervical'|S],S).
enfermedad(['lumbalgia'|S],S).
enfermedad(['hernia_discal'|S],S).
enfermedad(['sindrome_del_tunel_carpiano'|S],S).
enfermedad(['ninguna'|S],S).

% Predicado para definir los niveles de entrenamiento del usuario.
%
% Recibe:
% - Nivel de entrenamiento.
% - Cantidad de d�as de entrenamiento por semana.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Define los niveles de entrenamiento del usuario seg�n la frecuencia de entrenamiento.
nivel('principiante',['0','1','2']).
nivel('intermedio',['3','4']).
nivel('avanzado',['5','6','7']).

% Predicado para identificar el saludo del usuario.
%
% Recibe:
% - Saludo del usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Identifica si el usuario ha saludado al entrenador.
saludo(['hola'|S],S).
saludo(['buenos'|S],S).
saludo(['buenas'|S],S).

% Predicado para identificar la hora del d�a mencionada por el usuario.
%
% Recibe:
% - Hora del d�a mencionada por el usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Identifica si el usuario menciona "d�as", "tardes" o "noches".
hora(['d�as'|S],S).
hora(['tardes'|S],S).
hora(['noches'|S],S).

% Predicado para identificar el entrenador mencionado por el usuario.
%
% Recibe:
% - Nombre del entrenador mencionado por el usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Identifica si el usuario menciona al entrenador de alguna forma.
entrenador(['Sr.Entrenador'|S],S).
entrenador(['sr.entrenador'|S],S).
entrenador(['srentrenador'|S],S).
entrenador(['SrEntrenador'|S],S).

% Predicado para identificar la respuesta afirmativa del usuario.
%
% Recibe:
% - Respuesta afirmativa del usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Identifica si el usuario responde afirmativamente.
si(['si'|S],S).

% Predicado para identificar la respuesta negativa del usuario.
%
% Recibe:
% - Respuesta negativa del usuario.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Identifica si el usuario responde negativamente.
no(['no'|S],S).
no(['ninguno'|S],S).

% Predicado para crear un cliente y enviar un mensaje al servidor.
%
% Recibe:
% - Host: Direcci�n del servidor.
% - Port: Puerto del servidor.
% - Message: Mensaje a enviar al servidor.
% - Response: Respuesta del servidor.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Establece una conexi�n con el servidor y env�a un mensaje para obtener una respuesta.
create_client(Host, Port, Message, Response) :-
    setup_call_catcher_cleanup(tcp_socket(Socket),
                               tcp_connect(Socket, Host:Port),
                               exception(_),
                               tcp_close_socket(Socket)),
    setup_call_cleanup(tcp_open_socket(Socket, In, Out),
                       chat_to_server(In, Out, Message, Response),
                       close_connection(In, Out)).

% Predicado para enviar un mensaje al servidor y recibir una respuesta.
%
% Recibe:
% - Stream de entrada del socket.
% - Stream de salida del socket.
% - Mensaje a enviar al servidor.
% - Respuesta del servidor.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Env�a el mensaje al servidor y recibe la respuesta correspondiente.
chat_to_server(In, Out, Message, Response) :-
    Term = Message,
    (   Term = end_of_file
    ->  true
    ;   format(Out, '~q', [Term]),
        flush_output(Out),
        read_string(In, _, ResponseBytes),  % Read bytes from input stream
        string_codes(ResponseString, ResponseBytes),  % Decode bytes to string
        writeln(ResponseString),
        Response = ResponseString
    ),
    !.

% Predicado para cerrar la conexi�n con el servidor.
%
% Recibe:
% - Stream de entrada del socket.
% - Stream de salida del socket.
%
% Retorna:
% - Nada.
%
% Funci�n:
% Cierra la conexi�n con el servidor.
close_connection(In, Out) :-
    close(In, [force(true)]),
    close(Out, [force(true)]).
