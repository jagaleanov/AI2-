% Limpiando las variables y la consola
clear all
clc
close all

disp('ALGORTÍMO GENÉTICO');

% Definir valores predefinidos
matrix_type_input = 2; % 1 para pirámide, 2 para foso
use_recombination_input = 1; % 1 para si, 2 para no
selection_method_input = 3; % 1 para torneo, 2 para ruleta, 3 para rango
max_generations_input = 1000;
executions_input = 1;
range_probability_input = 2/3;
print_process_input = 1; % 1 para si, 2 para no

% Preguntar al usuario si desea usar los valores predefinidos
use_default_values = input('Desea utilizar los valores predefinidos?\n1) Sí\n2) No\nIngrese el número correspondiente: ');

if use_default_values == 2
    % Pedir al usuario los valores de las variables
    matrix_type_input = input('Seleccione el tipo de matriz de calidad que desea utilizar:\n1) Pirámide \n2) Foso \nIngrese el número correspondiente: ');
    use_recombination_input = input('¿Desea utilizar la recombinación de cromosomas?\n1) Sí\n2) No\nIngrese el número correspondiente: ');

    selection_method_input = input('Seleccione el método de selección que desea utilizar:\n1) Torneo\n2) Ruleta\n3) Rango\nIngrese el número correspondiente: ');
    selection_method = selection_method_input;
    max_generations_input = input('Ingrese el número máximo de generaciones: ');
    executions_input = input('Ingrese el número de ejecuciones: ');
    executions = executions_input;

    range_probability_input = 0;

    if selection_method_input == 3
        range_probability_input = input('Ingrese la probabilidad de selección para el método de rango (0 a 1): ');
    end

    print_process_input = 2;

    if executions_input < 10
        print_process_input = input('¿Desea imprimir el proceso de la ejecución?\n1) Sí\n2) No\nIngrese el número correspondiente: ');
    end

end

% Validar los valores de las variables
if ~(matrix_type_input == 1 || matrix_type_input == 2)
    error('El número ingresado para el tipo de matriz no es válido. Debe ser 1 o 2.');
end

if ~(use_recombination_input == 1 || use_recombination_input == 2)
    error('El número ingresado para la utilización de la recombinación no es válido. Debe ser 1 o 2.');
end

if ~(selection_method_input == 1 || selection_method_input == 2 || selection_method_input == 3)
    error('El número ingresado para el método de selección no es válido. Debe ser 1, 2 o 3.');
end

if max_generations_input <= 0
    error('El número máximo de generaciones ingresado no es válido. Debe ser un entero positivo.');
end

if executions_input <= 0
    error('El número de ejecuciones ingresado no es válido. Debe ser un entero positivo.');
end

if ~(range_probability_input >= 0 && range_probability_input <= 1)
    error('La probabilidad de selección ingresada para el método de rango no es válida. Debe ser un número entre 0 y 1.');
end

if ~(print_process_input == 1 || print_process_input == 2)
    error('El número ingresado para mostrar el proceso no es válido. Debe ser 1 o 2.');
end

% Asignar los valores ingresados a las variables
matrix_type = matrix_type_input;
use_recombination = use_recombination_input == 1;
selection_method = '';

max_generations = max_generations_input;
executions = executions_input;
range_probability = range_probability_input;
print_process = print_process_input == 1;
solutions_counter = 0;
accum_generations_counter = 0;
min_generations_total = max_generations_input;
max_generations_total = 0;

%iniciar proceso
if print_process
    fprintf('\nInicia proceso.\n');
else
    fprintf('\nProcesando...\n');
end

if matrix_type == 1
    % matriz de calidad (piramide)
    quality = [
               1 2 3 4 5 4 3 2 1;
               2 3 4 5 6 5 4 3 2;
               3 4 5 6 7 6 5 4 3;
               4 5 6 7 8 7 6 5 4;
               5 6 7 8 9 8 7 6 5;
               4 5 6 7 8 7 6 5 4;
               3 4 5 6 7 6 5 4 3;
               2 3 4 5 6 5 4 3 2;
               1 2 3 4 5 4 3 2 1
               ];
else
    % matriz de calidad (foso)
    quality = [
               1 2 3 4 5 4 3 2 1;
               2 0 0 0 0 0 0 0 2;
               3 0 0 0 0 0 0 0 3;
               4 0 0 7 8 7 0 0 4;
               5 0 0 8 9 8 0 0 5;
               4 0 0 7 8 7 0 0 4;
               3 0 0 0 0 0 0 0 3;
               2 0 0 0 0 0 0 0 2;
               1 2 3 4 5 4 3 2 1
               ];
end

for c = 1:executions
    best_chromosome = [];
    population = [1 1]; % población inicial

    for gen = 1:max_generations % Recorre generaciones

        num_generations = gen;
        candidates = population;

        if print_process
            disp(' ');
            disp(['GENERACIÓN ', num2str(gen)]);
            disp('Población seleccionada:');
            disp(candidates);
        end

        if use_recombination

            % Recombinación de cromosomas
            for i = 1:size(population, 1) - 1 % recorre la población actual

                for j = i + 1:size(population, 1) % recorre los cromosomas restantes de la población actual que aún no han sido combinados con i
                    [child1, child2] = recombine(population(i, :), population(j, :), print_process); % recombinar

                    % agregar hijos a candidatos si no existen
                    if ~ismember(child1, candidates, 'rows')
                        candidates = [candidates; child1];
                    end

                    if ~ismember(child2, candidates, 'rows')
                        candidates = [candidates; child2];
                    end

                end

            end

            if print_process
                disp('Población después de la recombinación:');
                disp(candidates);
            end

        end

        % Mutación de cromosomas
        for i = 1:size(population, 1) % Recorre la población actual
            mutant = mutate(population(i, :), print_process);

            % Verificar si el cromosoma mutante no está en la lista de candidatos
            if ~ismember(mutant, candidates, 'rows')
                candidates = [candidates; mutant];
            end

        end

        candidates = unique(candidates, 'rows'); % eliminando repetidos

        if print_process
            disp('Población después de la mutación:');
            disp(candidates);
        end

        switch selection_method_input
            case 1
                selection_method = 'torneo';
                % METODO TORNEO------------------------
                % Evaluar candidatos
                chromosome_scores = zeros(size(candidates, 1), 1); % Inicializar la lista de puntajes con 0

                for i = 1:size(candidates, 1) % Recorrer la lista de candidatos
                    chromosome = candidates(i, :); % Obtener el cromosoma actual
                    score = quality(chromosome(1), chromosome(2)); % Calcular la calidad del cromosoma en función de la matriz de calidad
                    chromosome_scores(i) = score; % Asignar la puntuación resultante a la lista de puntuaciones
                end

                % Comprobar si calidad == 9
                if max(chromosome_scores) == 9
                    best_chromosome = candidates(chromosome_scores == max(chromosome_scores), :); % Seleccionar el mejor cromosoma

                    if num_generations < min_generations_total
                        min_generations_total = num_generations; % Actualizar el mínimo de generaciones
                    end

                    if num_generations > max_generations_total
                        max_generations_total = num_generations; % Actualizar el máximo de generaciones
                    end

                    break; % Salir del bucle de generaciones
                end

                % Seleccionar la siguiente generación
                if print_process
                    disp('Puntajes:');
                    disp(chromosome_scores);
                end

                [unique_candidates, ia, ~] = unique(candidates, 'rows'); % Eliminar cromosomas repetidos
                unique_scores = chromosome_scores(ia); % Obtener puntajes de los cromosomas únicos
                [~, indices] = sort(unique_scores, 'descend'); % Ordenar puntajes únicos de forma descendente
                population = unique_candidates(indices(1:min(4, end)), :); % Seleccionar los mejores cromosomas únicos para la siguiente generación
                % FIN TORNEO------------------------
            case 2
                selection_method = 'ruleta';
                % METODO RULETA RUSA------------------------
                % Evaluar candidatos
                % Se evalúa cada candidato en la función de calidad para obtener su puntuación
                chromosome_scores = zeros(size(candidates, 1), 1);

                for i = 1:size(candidates, 1)
                    chromosome = candidates(i, :);
                    score = quality(chromosome(1), chromosome(2));
                    chromosome_scores(i) = score;
                end

                % Comprobar si calidad == 9
                % Si alguno de los candidatos tiene una puntuación perfecta, lo elegimos como mejor
                if max(chromosome_scores) == 9
                    best_chromosome = candidates(chromosome_scores == max(chromosome_scores), :);

                    if num_generations < min_generations_total
                        min_generations_total = num_generations; % Actualizar el mínimo de generaciones
                    end

                    if num_generations > max_generations_total
                        max_generations_total = num_generations; % Actualizar el máximo de generaciones
                    end

                    break;
                end

                % Calcular probabilidades de selección
                % Se calcula la probabilidad de selección de cada candidato en función de su puntuación
                selection_probabilities = chromosome_scores / sum(chromosome_scores);
                [selection_probabilities, selected_indices] = sort(selection_probabilities, 'descend');

                % Mostrar las probabilidades de selección si se especifica print_process
                if print_process
                    disp('Probabilidades de selección:');
                    disp(selection_probabilities);
                end

                % Seleccionar supervivientes
                % Seleccionamos los supervivientes de la generación actual
                selected_candidates = zeros(4, 2);

                if length(find(chromosome_scores)) <= 4
                    % Si hay 4 o menos candidatos que no tienen puntuación 0, los seleccionamos todos
                    selected_candidates = candidates(find(chromosome_scores), :);
                else
                    % Si hay más de 4 candidatos con puntuación distinta de 0, usamos el método de ruleta rusa
                    count = 1;

                    while count <= 4
                        random_number = rand();
                        candidate_index = 1;
                        accumulated_probability = selection_probabilities(candidate_index);

                        % Buscamos el candidato cuya probabilidad acumulada supere el número aleatorio generado
                        while accumulated_probability < random_number
                            candidate_index = candidate_index + 1;
                            accumulated_probability = accumulated_probability + selection_probabilities(candidate_index);
                        end

                        % Si el candidato elegido no está ya en la lista de supervivientes, lo añadimos
                        if ~ismember(candidates(selected_indices(candidate_index), :), selected_candidates, 'rows')
                            selected_candidates(count, :) = candidates(selected_indices(candidate_index), :);
                            count = count + 1;
                        end

                    end

                end

                % Actualizamos la población con los supervivientes seleccionados
                population = selected_candidates;
                % FIN RULETA RUSA------------------------
            otherwise
                selection_method = 'rango';
                % METODO RANGO------------------------
                % Evaluar candidatos
                chromosome_scores = zeros(size(candidates, 1), 1); % Lista de puntuaciones de los cromosomas

                for i = 1:size(candidates, 1) % Recorrer la lista de candidatos
                    chromosome = candidates(i, :); % Obtener el cromosoma actual
                    score = quality(chromosome(1), chromosome(2)); % Calcular la calidad del cromosoma en función de la matriz de calidad
                    chromosome_scores(i) = score; % Asignar la puntuación resultante a la lista de puntuaciones
                end

                % Comprobar si calidad == 9
                if max(chromosome_scores) == 9
                    best_chromosome = candidates(chromosome_scores == max(chromosome_scores), :); % Seleccionar el mejor cromosoma

                    if num_generations < min_generations_total
                        min_generations_total = num_generations; % Actualizar el mínimo de generaciones
                    end

                    if num_generations > max_generations_total
                        max_generations_total = num_generations; % Actualizar el máximo de generaciones
                    end

                    break; % Salir del bucle de generaciones
                end

                % Seleccionar la siguiente generación
                if print_process
                    disp('Puntajes:');
                    disp(chromosome_scores);
                end

                [unique_candidates, unique_indices, ~] = unique(candidates, 'rows'); % Eliminar cromosomas repetidos
                unique_scores = chromosome_scores(unique_indices); % Obtener puntajes de los cromosomas únicos
                [~, sorted_indices] = sort(unique_scores, 'descend'); % Ordenar puntajes únicos de forma descendente
                selected_candidates = unique_candidates(sorted_indices(1:min(4, end)), :); % Seleccionar los mejores cromosomas únicos para la siguiente generación
                population = selected_candidates; % Actualizar la población con los supervivientes seleccionados
                % FIN RANGO------------------------
        end

    end

    % Mostrar resultado
    if max(chromosome_scores) == 9

        if print_process
            disp(' ');
            disp('SOLUCION ENCONTRADA');
            disp('Mejor cromosoma encontrado:');
            disp(best_chromosome);
            disp(['Número de generaciones utilizadas: ', num2str(gen)]);
        end

        solutions_counter = solutions_counter + 1;
        accum_generations_counter = accum_generations_counter + gen;
    else

        if print_process
            disp(' ');
            disp('SOLUCION NO ENCONTRADA');
            disp('No se ha encontrado la solución dentro del número máximo de generaciones.');
        end

    end

end

fprintf('\nProceso finalizado.\n');

fprintf('\nResultados:\n');

if matrix_type == 1
    fprintf('Se utilizo la matriz de piramide.\n');
else
    fprintf('Se utilizo la matriz de foso.\n');
end

if use_recombination
    fprintf('Se utilizaron las operaciones de mutación y recombinación.\n');
else
    fprintf('Sólo se utilizó la operacion de mutación.\n');
end

fprintf('Se utilizó el método de selección por %s.\n', selection_method);
fprintf('Se realizaron un total de %d ejecuciones.\n', executions);
fprintf('Cada ejecución tuvo máximo %d generaciones.\n', max_generations);
fprintf('En %d ejecuciones se encontraron %d soluciónes.\n', executions, solutions_counter);
fprintf('El promedio de generaciones necesarias para encontrar la solución fue %f.\n', accum_generations_counter / solutions_counter);
fprintf('El número mínimo de generaciones necesarias para encontrar la solución fue %d\n', min_generations_total);
fprintf('El número máximo de generaciones necesarias para encontrar la solución fue %d\n', max_generations_total);

% Funciones
% Función de mutación
function mutant = mutate(chromosome, print_process)
    gene = randi(2); % Seleccionar un gen aleatorio
    mutant = chromosome; % Crear una copia del cromosoma original
    mutant(gene) = mod(chromosome(gene), 9) + 1; % Realizar una mutación sumando 1 al gen

    if print_process
        disp('Mutación');
        disp(['Cromosoma inicial: ', num2str(chromosome)]);
        disp(['Cromosoma mutante: ', num2str(mutant)]);
        disp(' ');
    end

end

% Función de recombinación
function [child1, child2] = recombine(parent1, parent2, print_process)
    child1 = [parent1(1), parent2(2)]; % Crear el primer hijo
    child2 = [parent2(1), parent1(2)]; % Crear el segundo hijo

    if print_process
        disp('Recombinación');
        disp(['Padre1: ', num2str(parent1)]);
        disp(['Padre2: ', num2str(parent2)]);
        disp(['Hijo1: ', num2str(child1)]);
        disp(['Hijo2: ', num2str(child2)]);
        disp(' ');
    end

end
