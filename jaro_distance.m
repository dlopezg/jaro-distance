function  [jd, n_matches, n_trans, di] = jaro_distance(str_1,str_2)
%% JARO_DISTANCE This function computes the Jaro distance between two strings.
% -------------------------------------------------------------------------
% David Lopez-Garcia
% dlopez@ugr.es
% University of granada
% -------------------------------------------------------------------------
%
% Inspired by Chetan Jadhav's implementation: 
% https://www.mathworks.com/matlabcentral/fileexchange/60855-jarowinkler
% Last access: 02/04/2019

%% Algorithm initialization:
jd = [];
n_matches = [];
n_trans = [];
di = [];

%% Matching range:
len_1 = length(str_1);
len_2 = length(str_2);
matching_distance = floor(max(len_1,len_2)/2)-1;

%% Return if any of strings is empty:
if ~len_1 || ~len_2
    warning('Warning: empty string!')
    return
end

%% Posible matches matrix:

% Vamos a hacer una comparacion de forma matricial de las cadenas de
% caracteres, para ello transformamos cada cadena en una matriz de la
% siguiente manera:
%
% - Primera cadena: La repetimos por filas tantas veces como caracteres
%                   tenga la segunda cadena.
% - Segunda cadena: La transponemos y la repetimos por columnas tantas
%                   veces comocaracteres tenga la primera cadena.
%
% De esta forma, cuando comparamos las dos matrices, para cada caracter
% coincidente obtendriamos un uno y un cero para los distintos.
% Si las dos cadenas fuesen identicas, la matriz de comparacion seria una
% matriz cuya diagonal serian unos.

mtx_str_1 = repmat(str_1,len_2,1);
mtx_str_2 = repmat(str_2',1,len_1);
posible_matches = double(mtx_str_1 == mtx_str_2);

%% Ignoring chars out of matching range:
outofrange_lo = tril(posible_matches,-matching_distance-1);
outofrange_up = triu(posible_matches,matching_distance+1);
posible_matches = posible_matches - outofrange_lo - outofrange_up;

%% Select the first char to match:
% Puesto que hemos comparado de forma matricial, cada columna
% corresponderia a un caracter, por lo que coincidencias en la misma fila,
% no deben existir, por ello, una vez encontremos la primera, debemos
% obviar las demas.

matches = zeros(len_2,len_1);

for i = 1 : len_1
    if any(posible_matches(:,i))
        posible_matches_char_i = posible_matches(:,i);
        yet_matched = any(matches,2);
        posible_matches_char_i = ~yet_matched & posible_matches_char_i;
        first_match_id = find(posible_matches_char_i,1);
        matches(first_match_id,i) = posible_matches(first_match_id,i);
    end
end

%% Calculate the number of transpositions:
% De la siguiente forma conseguimos el numero de emparejamientos en cada
% una de las cadenas:
matches_str_1 = any(matches)';
matches_str_2 = any(matches,2);
matches_pos_str_1 = find(matches_str_1);
matches_pos_str_2 = find(matches_str_2);

matches_pos = sub2ind(size(matches), matches_pos_str_2, matches_pos_str_1);
matches_diff_order = sum(~posible_matches(matches_pos));
n_trans = matches_diff_order/2;

%% Compute the Jaro distance:
n_matches = sum(matches_str_1);
jd = (n_matches/len_1 + n_matches/len_2 + (n_matches-n_trans)/n_matches)/3;

if isnan(jd)
    jd=0;
end

%% Dissimilarity index:
di = 1 - jd;

%% Winkler modification
%jw = jd + 0.1*(str_1(1:3)==str_2(1:3))*cumprod(str_1(1:3)==str_2(1:3))'*(1-jd);



end
