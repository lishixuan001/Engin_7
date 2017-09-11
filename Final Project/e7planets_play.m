function [game_stats] = e7planets_play(map, player_function)

% game_stats = E7PLANETS_PLAY(map, player_function): plays a game of "E7
% Planets" given a map (input argument "map") and a player function (input
% argument "player_function"). This function runs the game, and creates and
% shows the corresponding visualizer.
%
% "E7 Planets" is the final programming project for the class "Introduction
% to Programming for Scientists and Engineers" (ENGIN 7, Spring 2017
% semester) at the University of California at Berkeley. This code may be
% used only for the purpose of working on this final project. This code may
% NOT be shared with anyone, nor uploaded nor posted online anywhere,
% without prior written consent of the instructor of the class.
%
% The input argument "map" must be a 1 by 1 struct array that contains the
% following fields (and no other field):
%
% - "grid": a m by n array of class double that contains only +Inf and/or
%   integers that are equal to or greater than zero. "grid" must contain at
%   least two elements.
%
% - "player": a 1 by 1 struct array with the following fields (and no other
%   field):
%
%    * "location": a 2 by 2 array of class double. The first row of this
%      array must be full of NaN. The second row describes the initial
%      location of the player in the grid, as the row and column index of
%      this location, in this order.
%
%    * "score": a scalar of class double, which represents the initial
%      score of the player. This field must be equal to zero.
%
% - "scraps": a n_scrap by 1 struct array, where n_scrap is the initial
%   number of scraps on the map. Each element of this struct array
%   represents one scrap. There must be at least one scrap. This struct
%   array must contain the following fields (and no other field):
%
%    * "location": must be a 1 by 2 array of class double that describes
%      the location of the scrap in the grid, as the row and column index
%      of this location, in this order.
%
%    * "value": must be a scalar of class double that represents a positive
%      integer: the value of the scrap.
%
% - "ghosts": a n_ghosts by 1 struct array, where n_ghosts is the number of
%   ghosts on the map. Each element of this struct array represents one
%   ghost. This struct array must be empty (there can be zero ghost on the
%   map) or must contain the following fields (and no other field):
%
%    * "location": a 2 by 2 array of class double. The first row of this
%      array describes the "previous" location of the ghost in the grid, as
%      the row and column index of this location, in this order. The second
%      row describes the "current" (i.e. initial) location of the ghost in
%      the grid, as the row and column index of this location, in this
%      order. The values of the "previous" location of the ghost in the
%      grid depend on the ghost's type (see below for details).
%
%    * "type": a row vector of class char (i.e. a character string) that
%    represents the type of the ghost. Currently supported types are:
%
%       > 'backandforth': the ghost moves back and forth in a straight
%       line. In each direction, it moves until it cannot go any further,
%       in which case it turns around and move in the opposite direction.
%       The initial moving direction is determined by comparing the ghost's
%       "previous" and "current" locations. The current (i.e. initial)
%       location of the ghost must be either:
%
%          - one grid cell above its previous location (in which case the
%            ghost will first move up if possible, and down otherwise); or
%
%          - one grid cell below its previous location (in which case the
%            ghost will first move down if possible, and up otherwise); or
%
%          - one grid cell to the left of its previous location (in which
%            case the ghost will first move left if possible, and right
%            otherwise); or
%
%          - one grid cell to the right of its previous location (in which
%            case the ghost will first move right if possible, and left
%            otherwise).
%
%         This ghost does not use "wrap-around" moves, and views the map's
%         boundaries as impassable.
%
%       > 'towardplayer': the ghost always tries to move toward the player.
%         This ghost does not try to go around objects to get to the
%         player, so this ghost may get stuck behind impassable areas
%         (unless its transparency allows it to move through otherwise
%         impassable areas). This ghost does not use "wrap-around" moves,
%         and views the map's boundaries as impassable.
%
%    * "transparency": a scalar of class double that is either 0, 1, or 2. A
%      value of 0 indicates that the ghost cannot go through asteroid
%      fields, and is slowed down by nebulae, just as the player is. A
%      value of 1 indicates that the ghost cannot go through asteroid
%      fields, but is not slowed down by nebulae (the ghost moves through
%      nebulae as if they were empty space). A value of 2 indicates that
%      the ghost can go through all locations of the map as if they were
%      empty spaces.
%
% - "remaining_turns": a scalar of class double that represents a
%   positive integer, the maximum number of turns allowed in this game.
%
% The player's function (input argument "player_function") must be a
% function handle to a function that takes one and only one input argument
% (this function will be passed the map for the corresponding turn as its
% input argument) and ouputs one and only one output argument.
%
% This function returns statistics about the game in its unique output
% argument "game_stats". This output argument is a 1 by 1 struct array that
% contains the following fields:
%
% - "win": a logical scalar that is true if and only if the player won the
%   game.
%
% - "max_turns": a scalar of class double that represents the maximum number
%   of turns that were allowed in the game.
%
% - "n_turns": a scalar of class double that represents the number of turns
%   in the game before the end of the game.
%
% - "score": a scalar of class double that represents the score obtained
%   by the player for this game.
%
% - "scraps_total_value": a scalar of class double that represents the
%   total value of the scraps on the map. Note that this value includes the
%   values of scraps that are unattainable.
%
% - scraps_picked_up: a struct array that follows the same format as
%   "map.scraps", and that describes the scraps that were picked up by the
%   player during the game (in the order they were picked up).
%
% - scraps_left: a struct array that follows the same format as
%   "map.scraps", and that describes the scraps that were not picked up by
%   the player during the game.
%
% - "caught": a logical scalar that is true if and only if the player
%   was caught by one or more ghost(s) during the game.
%
% - "ghosts_catch_samespot": a row vector of class double that contains the
%   indices of the ghosts that caught the player during the game by landing
%   on the same spot as the player.
%
% - "ghosts_catch_switch:" a row vector of class double that contains the
%   indices of the ghosts that caught the player during the game by
%   switching locations with the player over the course of one turn.
%
% Version: release.

% NOTES ON THIS IMPLEMENTATION:
%
% This function is a wrapper around the function (e7pl_play) that actually
% runs the game and creates the visualizer. This wrapper creates the figure
% for the visualizer, and gracefully handles any error thrown as a result
% of calling e7pl_play. If an error is thrown as a result of calling
% e7pl_play, the figure of the visualizer is closed.
%
% Naming conventions:
%
% - The names of all sub-functions in this file start with e7pl_ (i.e. E7
%   Planets, local function).
%
% - The names of all nested functions in this file start with e7pn_ (i.e.
%   E7 Planets, nested function).
%
% - In all functions, sub-functions, and nested functions defined in this
%   file, the input and/or output arguments "map", "player_function",
%   "game_stats", and "visualizer" always follow the same structures, which
%   are not necessarily described each time in the documentation of these
%   functions. "visualizer" is a 1 by 1 struct array that contains a number
%   of quantities useful to draw the visualizer and interact with it.
%
% - We try to reserve the names i and j (and any name that starts with i_
%   or j_) for variables that describe row and column indices
%   (respectively) of locations in the grid. We use k, l, m, etc. (and
%   names starting with k_, l_, m_, etc.) for other types of indices and
%   counters (e.g. for the iteration variable of a "for" loop that iterates
%   over all the ghosts).
%
% Vocabulary used in the documentation (i.e. the comments) of this code:
%
% - "character string": row vector of class char.
%
% Organization of the subfunctions: as far as reasonably possible, the
% subfunctions are organized in the following order:
%
% - Core functions for running the game.
% - Core functions for the visualizer.
% - Support functions for the two categories above and/or the top-level
%   functions.
% - Move functions for the ghosts.
% - Functions that do quality control on the inputs to the top-level
%   functions.

try
    fig = figure();
    set(fig, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    [game_stats] = e7pl_play(map, player_function, fig);
catch e
    close(fig);
    mid = 'e7planets_play:generalissue';
    msg = sprintf(['\nSomething went wrong when running the game or ', ...
        'setting up the visualizer. %s'], e7pl_describe_error(e));
    throw(MException(mid, msg));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [game_stats] = e7pl_play(map, player_function, fig)

% [game_stats] = E7PL_PLAY(map, player_function, fig): plays a game of "E7
% Planets" given a map (input argument "map") and a player function (input
% argument "player_function"). The input argument "fig" is the handle to
% the figure of the visualizer, which should be created outside of this
% function. This function returns the corresponding game statistics (output
% argument "game_stats").

% Do quality control on "map"
[valid, msg] = e7pl_check_map(map);
if ~valid
    mid = 'e7pl_play:badmap';
    throw(MException(mid, msg));
end

% Do quality control on "player_function"
[valid, msg] = e7pl_check_player_function(player_function);
if ~valid
    mid = 'e7pl_play:badplayerfunction';
    throw(MException(mid, msg));
end

% Create and initialize the visualizer
visualizer = e7pl_initialize_visualizer(map, fig);
set(visualizer.figure, 'KeyPressFcn', @e7pn_figure_key_press);

% The following quantity defines the maximum allowed time (in seconds) for
% the player's function (and the ghosts' move functions) to return
max_time = 1;

% Initialize the wait times
wait = struct('player', map.grid(map.player.location(end,1), ...
    map.player.location(end,2)), 'ghosts', zeros(1, visualizer.n_ghosts));
for k_ghost = 1:visualizer.n_ghosts
    wait.ghosts(k_ghost) = map.grid(map.ghosts(k_ghost).location(end,1), ...
        map.ghosts(k_ghost).location(end,2));
end

% Initialize some of the game statistics
game_stats.max_turns = map.remaining_turns;
game_stats.scraps_total_value = e7pl_count_scraps_total_value(map.scraps);
game_stats.ghosts_catch_samespot = [];
game_stats.ghosts_catch_switch = [];
game_stats.caught = false;
game_stats.win = false;

% Run the game
for turn_number = 1:game_stats.max_turns

    i_frame = turn_number + 1;

    % Process the player's move. We don't update the player's location in
    % "map" just now, because the ghosts' functions must be called on the
    % map before it gets updated
    [i_player, j_player, wait.player] = e7pl_process_move(map, ...
        player_function, max_time, map.player.location(end,1), ...
        map.player.location(end,2), 0, wait.player, 'The player', ...
        turn_number, true);
    location_player = [i_player, j_player];

    % Process the ghosts' moves. Again, we do not want to update "map"
    % until all the ghosts have been processed
    ghosts = map.ghosts;
    for k_ghost = 1:visualizer.n_ghosts

        % Process the move
        ghost = ghosts(k_ghost);
        if strcmp(ghost.type, 'backandforth')
            ghost_function = @(map) e7pl_ghost_backandforth(map, k_ghost);
        elseif strcmp(ghost.type, 'towardplayer')
            ghost_function = @(map) e7pl_ghost_towardplayer(map, k_ghost);
        else
            mid = 'e7pl_play:unknownghosttype';
            msg = sprintf('Unknown ghost type: %s.\n', ghost.type);
            throw(MException(mid, msg));
        end
        which = sprintf('Ghost number %d', k_ghost);
        [ghost.location(end+1,1), ghost.location(end+1,2), ...
            wait.ghosts(k_ghost)] = e7pl_process_move(map, ghost_function, ...
            max_time, ghost.location(end,1), ghost.location(end,2), ...
            ghost.transparency, wait.ghosts(k_ghost), which, turn_number, ...
            false);

        % Check whether the player was caught because the player and the
        % ghost landed on the same spot
        if isequal(ghost.location(end,:), location_player)
            game_stats.ghosts_catch_samespot(end+1) = k_ghost;
        end

        % Check whether the player was caught because the player and the
        % ghost switched locations
        if isequal(ghost.location(end,:), map.player.location(end,:)) && ...
                isequal(ghost.location(end-1,:), location_player)
            game_stats.ghosts_catch_switch(end+1) = k_ghost;
            % In this case, we prevent the ghost from moving, so that it is
            % clearer in the visualizer that the ghost caught the player
            % (either way, the game is over)
            ghost.location(end,:) = ghost.location(end-1,:);
        end

        % Save the updated ghost information
        ghosts(k_ghost) = ghost;

    end

    % Check whether the player picks up scrap this turn
    for k_scrap = 1:numel(map.scraps)
        scrap = map.scraps(k_scrap);
        if isequal(scrap.location, location_player)
            map.player.score = map.player.score + scrap.value;
            if ismember('scraps_picked_up', fieldnames(game_stats))
                game_stats.scraps_picked_up(end+1) = map.scraps(k_scrap);
            else
                game_stats.scraps_picked_up = map.scraps(k_scrap);
            end
            map.scraps(k_scrap) = [];
            break
        end
    end

    % Update the map and the visualizer
    map.ghosts = ghosts;
    map.player.location(end+1,:) = location_player;
    visualizer.frames(i_frame).player.location = location_player;
    visualizer.frames(i_frame).player.score = map.player.score;
    visualizer.frames(i_frame).ghosts = map.ghosts;
    visualizer.frames(i_frame).scraps = map.scraps;

    % Determine if the player was caught
    game_stats.caught = ...
        numel(game_stats.ghosts_catch_samespot) > 0 || ...
        numel(game_stats.ghosts_catch_switch) > 0;

    % The game is over (lost) if the player got caught
    if game_stats.caught
        break
    end

    % The game is won if the player has picked up all the scraps, without
    % getting caught by any of the ghosts
    if map.player.score == game_stats.scraps_total_value
        game_stats.win = true;
        break
    end

end
visualizer.max_frame = i_frame;

% Update the game's statistics
game_stats.score = visualizer.frames(visualizer.max_frame).player.score;
if ~ismember('scraps_picked_up', fieldnames(game_stats))
    game_stats.scraps_picked_up = struct();
end
if numel(fieldnames(game_stats.scraps_picked_up)) == 0
    game_stats.scraps_picked_up = game_stats.scraps_picked_up(1:0,1);
end
game_stats.scraps_left = map.scraps;
game_stats.n_turns = visualizer.max_frame - 1;

% Show the visualizer
visualizer.game_stats = game_stats;
e7pl_draw_visualizer_frame(visualizer)

% We are done (the return statement below is superfluous, but is there to
% make it explicit that the function ends here)
fprintf('\n')
return

% -----------------------------------------------------------------------------

    function [] = e7pn_figure_key_press(fig, event)

        % E7PN_FIGURE_KEY_PRESS(fig, event): callback function that handles
        % key-press events originating from the visualizer.
        %
        % The input argument "fig" is the handle to the figure from which
        % the key-press event originated. The input argument "event" is the
        % key-press event itself.

        help_key = 'h';
        if visualizer.running && ~strcmp(event.Key, help_key)
            fprintf(['\nUser input deactivated while running!\n' ...
                '(Except for the help key: %s).\n\n'], help_key);
            return
        end

        switch event.Key

            case help_key
                % Show the help menu
                fprintf('\nAvailable keyboard commands:\n\n')
                fprintf('right or down arrow ... Next frame\n')
                fprintf('left or up arrow ...... Previous frame\n')
                fprintf('home key or page up ... Initial frame\n')
                fprintf('end key or page down .. Last frame\n')
                fprintf('escape key or q ....... Close figure\n')
                fprintf('enter ................. Run game forward\n')
                fprintf('backspace ............. Run game backward\n')
                fprintf(['f ..................... Increase visualizer ', ...
                    'frame rate\n'])
                fprintf(['s ..................... Decrease visualizer ', ...
                    'frame rate\n'])
                fprintf('h ..................... Show this help menu\n')
                fprintf('\n')

            case {'escape', 'q'}
                % Close the figure
                close(visualizer.figure)

            case {'leftarrow', 'uparrow'}
                % Go back one frame
                if visualizer.current_frame > 1
                    visualizer.current_frame = visualizer.current_frame - 1;
                    e7pl_draw_visualizer_frame(visualizer)
                end

            case {'rightarrow', 'downarrow'}
                % Go forward one frame
                if visualizer.current_frame < visualizer.max_frame
                    visualizer.current_frame = visualizer. current_frame + 1;
                    e7pl_draw_visualizer_frame(visualizer)
                end

            case 'return'
                % Run the game forward starting from the current frame
                visualizer.running = true;
                for i_frame = 1:visualizer.max_frame-visualizer.current_frame
                    visualizer.current_frame = visualizer.current_frame + 1;
                    e7pl_draw_visualizer_frame(visualizer)
                    pause(1/visualizer.speed)
                end
                visualizer.running = false;

            case 'backspace'
                % Run the game backwards starting from the current frame
                visualizer.running = true;
                for i_frame = 1:visualizer.current_frame-1
                    visualizer.current_frame = visualizer.current_frame - 1;
                    e7pl_draw_visualizer_frame(visualizer)
                    pause(1/visualizer.speed)
                end
                visualizer.running = false;

            case {'pageup', 'home'}
                % Jump to the initial frame
                visualizer.current_frame = 1;
                e7pl_draw_visualizer_frame(visualizer)

            case {'pagedown', 'end'}
                % Jump to the final frame
                visualizer.current_frame = visualizer.max_frame;
                e7pl_draw_visualizer_frame(visualizer)

            case 'f'
                % Increase the visualizer frame rate
                visualizer.speed = visualizer.speed + 1;
                e7pl_set_visualizer_title(visualizer)

            case 's'
                % Decrease the visualizer frame rate
                visualizer.speed = max(visualizer.speed-1, 1);
                e7pl_set_visualizer_title(visualizer)

            otherwise

                fprintf(['\nPressing key "%s" has no effect. ', ...
                    'Press %s for help.\n\n'], event.Key, help_key)

        end

    end

% -----------------------------------------------------------------------------

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [i_new, j_new, wait] = e7pl_process_move(map, move_function, ...
        max_time, i_current, j_current, transparency, wait, which, ...
        turn_number, verbose)

% [i_new, j_new, wait] = E7PL_PROCESS_MOVE(map, move_function, max_time,
% i_current, j_current, transparency, wait, which, turn_number): calls a
% move function and returns the corresponding new location and wait time.
%
% Description of the input and output arguments:
%
% - "map": map of the game.
%
% - "move_function": a handle to the function that calculates the next move
%   to make. It should follow the same format as the input argument
%   "player_function" in the top-level function. Here, "move_function" can
%   be the move function of the player or of a ghost.
%
% - "max_time": a scalar of class double that represents the maximum time
%   (in seconds) allowed for the move function to return. If the move
%   function takes longer than that to return, then the corresponding move
%   is considered to be invalid.
%
% - "i_current" and "j_current": must be scalars of class double that
%   represent the row and column indices (respectively) of the location of
%   the entity to move, before the move. Here we use the word "entity" to
%   describe the game entity that is trying to move (typically the player
%   or a ghost).
%
% - "transparency": the transparency of the entity to move. See the field
%   "transparency" of ghosts for information about what this field means.
%
% - "wait": a scalar of class double that represents the current (before
%   the move, as input argument) and updated (after the move, as output
%   argument) wait time of the entity to move.
%
% - "which": a character string that describes the entity to move. For
%   example: 'The player' or 'Ghost number 2'.
%
% - "turn_number": a scalar of class double that represents the number of
%   the turn that is currently being processed.
%
% - "verbose": a scalar logical that indicates whether information should
%   be printed to screen.
%
% - "i_new" and "j_new": scalars of class double that represent the row and
%   column indices (respectively) of the location of the entity to move,
%   after the move.
%
% Note: "which" and "turn_number" are used only to display information to
% the screen.

turn_number_txt = sprintf('*** Turn %d ***\n\n', turn_number);

% Start from the current location
i_new = i_current;
j_new = j_current;

% Decrease the entity's wait time before processing the move
wait = wait-1;

% Call and time the move function
valid = true;
try
    tic();
    direction = move_function(map);
    time = toc();
catch e
    valid = false;
end

% Perform quality check on the call to the move function and on the
% corresponding output
if ~valid
    msg = [which, ' is not moving this turn because calling the function ', ...
        'to get the corresponding next move resulted in an error being ', ...
        'thrown. ', e7pl_describe_error(e, 1)];
elseif time > max_time
    valid = false;
    msg = sprintf([which, ' is not moving this turn because the function ', ...
        'to get the corresponding next move took too long to return. It ', ...
        'took %.2e second(s), while the limit is set at %.2e second(s).'], ...
        time, max_time);
else
    [valid, msg] = e7pl_is_move_valid(map, i_current, j_current, direction, ...
        transparency, which);
    if ~valid
        msg = sprintf(['%s is not moving this turn because the output of ', ...
            'the function to get the corresponding next move is not ', ...
            'valid. The reason it is not valid is:\n\n%s'], which, msg);
    end
end

% If the function call did not yield a valid output, the entity does not
% move
if ~valid
    if verbose
        fprintf('\n%s%s\n', turn_number_txt, msg);
    end
    return
end

% Update the entity's location
if wait >= 0 && transparency == 0
    if verbose
        fprintf(['\n%s%s (transparency: %d) is not moving this turn ', ...
            'because it is being slowed down by a nebula.\n'], ...
            turn_number_txt, which, transparency);
    end
else
    i_new = i_new - strcmp(direction, 'U') + strcmp(direction, 'D');
    j_new = j_new - strcmp(direction, 'L') + strcmp(direction, 'R');
end

% Adjust the updated location if the move corresponds to a "wrap around the
% map" move
[n_rows, n_cols] = size(map.grid);
if i_new == 0
    i_new = n_rows;
elseif i_new == n_rows+1
    i_new = 1;
end
if j_new == 0
    j_new = n_cols;
elseif j_new == n_cols+1
    j_new = 1;
end

% Update the wait time if the entity has moved
if i_new ~= i_current || j_new ~= j_current
    wait = map.grid(i_new, j_new);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg] = e7pl_is_move_valid(map, i_current, j_current, ...
    direction, transparency, which)

% [valid, msg] = E7PL_IS_MOVE_VALID(map, i_current, j_current, direction,
% transparency, which): determines whether a move is valid.
%
% Description of the input and output arguments:
%
% - "map": map of the game.
%
% - "i_current" and "j_current": must be scalars of class double that
%   represent the row and column indices (respectively) of the location of
%   the entity to move, before the move.
%
% - "direction": the attempted move.
%
% - "transparency": the transparency of the entity to move. See the field
%   "transparency" of ghosts for information about what this field means.
%
% - "which": a character string that describes the entity to move. For
%   example: 'The player' or 'Ghost number 2'.
%
% - "valid": a logical scalar that is true if and only if the attempted
%   move is valid.
%
% - "msg": if "valid" is true, then "msg" is an empty character string. If
%   "valid" is false, then "msg" is a character string that describes the
%   nature of the problem with the attempted move.
%
% Note: "which" is used only to display information to the screen.

valid = false;
msg = '';

% Check the class and size of "direction"
[valid_local, msg] = e7pl_check_class_and_size(direction, 'char', [1, 1], ...
    'direction');
if ~valid_local
    return
end

% Check the value of "direction"
up = strcmp(direction, 'U');
down = strcmp(direction, 'D');
left = strcmp(direction, 'L');
right = strcmp(direction, 'R');
stay = strcmp(direction, '.');
if ~(up || down || left || right || stay)
    msg = sprintf(['It should be one of (''U'', ''D'', ''L'', ''R'', or ', ...
        '''.''), but it is %s instead.'], direction);
    return
end

% If we reach this point, "direction" has one of the valid values. Staying
% put is never a non-valid move. An entity with transparency 2 can go
% wherever it wants
if stay || transparency == 2
    valid = true;
    return
end

% If we reach this point, the entity is trying to move, but its
% transparency value does not allow it to move into asteroid fields. We
% check that the entity's attempted move is possible
[n_rows, n_cols] = size(map.grid);
if up && ( ...
        i_current == 1 && isinf(map.grid(end, j_current)) || ...
        i_current ~= 1 && isinf(map.grid(i_current-1, j_current)))
    msg = [which, ' cannot move up from where it is.'];
    return
elseif down && ( ...
        i_current == n_rows && isinf(map.grid(1, j_current)) || ...
        i_current ~= n_rows && isinf(map.grid(i_current+1, j_current)))
    msg = [which, ' cannot move down from where it is.'];
    return
elseif left && ( ...
        j_current == 1 && isinf(map.grid(i_current, end)) || ...
        j_current ~= 1 && isinf(map.grid(i_current, j_current-1)))
    msg = [which, ' cannot move left from where it is.'];
    return
elseif right && ( ...
        j_current == n_cols && isinf(map.grid(i_current, 1)) || ...
        j_current ~= n_cols && isinf(map.grid(i_current, j_current+1)))
    msg = [which, ' cannot move righ from where it is.'];
    return
end

% If we reach this point, the move is valid
valid = true;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [visualizer] = e7pl_initialize_visualizer(map, fig)

% visualizer = E7PL_INITIALIZE_VISUALIZER(map): initializes the visualizer
% (output argument "visualizer") given the game's map (input argument
% "map"). The input argument "fig" is the handle to the figure of the
% visualizer, which should be created outside of this function.

visualizer = struct();
visualizer.figure = fig;

% Initialize the game quantities
[n_rows, n_cols] = size(map.grid);
grid_inf = isinf(map.grid);
max_nebula = max(map.grid(~grid_inf));
visualizer.has_impassable = any(grid_inf(:));
visualizer.n_rows = n_rows;
visualizer.n_cols = n_cols;
visualizer.max_nebula = max_nebula;
visualizer.n_ghosts = numel(map.ghosts);
if visualizer.n_ghosts > 0
    visualizer.ghost_types = unique(...
        arrayfun(@(ghost) ghost.type, map.ghosts, 'UniformOutput', false));
else
    visualizer.ghost_types = {};
end
visualizer.n_ghost_types = numel(visualizer.ghost_types);

% Initialize the first frame
visualizer.current_frame = 1;
visualizer.frames.player.location = map.player.location(end,:);
visualizer.frames.player.score = 0;
visualizer.frames.scraps = map.scraps;
visualizer.frames.ghosts = map.ghosts;

% Initialize some of the graphical elements of the visualizer (the other
% graphical elements of the visualizer are hard-coded in the function
% "e7pl_draw_visualizer_frame")

% ---> Functions to plot different items
visualizer.draw.player = @(x, y) rectangle( ...
    'Position', [x-0.5, y-0.5, 1, 1], 'Curvature', 1, ...
    'EdgeColor', [0, 0.8, 0], 'FaceColor', 'none', 'LineWidth', 5);
visualizer.draw.scrap = @(x, y) patch( ...
    'XData', [x, x-0.5, x, x+0.5], 'YData', [y-0.5, y, y+0.5, y], ...
    'EdgeColor', 'none', 'FaceColor', [0.5, 0.65, 1]);
visualizer.draw.ghosts.backandforth = @(x, y) patch( ...
    'XData', [x-0.5, x-0.5, x+0.5, x+0.5], ...
    'YData', [y-0.5, y+0.5, y+0.5, y-0.5], ...
    'EdgeColor', 'none', 'FaceColor', [1, 0.17, 0.25]);
visualizer.draw.ghosts.towardplayer = @(x, y) patch( ...
    'XData', [x-0.25, x-0.5, x-0.5, x-0.25, x+0.25, x+0.5, x+0.5, x+0.25], ...
    'YData', [y-0.5, y-0.25, y+0.25, y+0.5, y+0.5, y+0.25, y-0.25, y-0.5], ...
    'EdgeColor', 'none', 'FaceColor', [1, 0.17, 0.25]);

% ---> The following quantity defines the vertical spacing between legend
%      items
visualizer.between_legend_items = 0.2;

% ---> The x_margin and y_margin are the sizes of the areas added to the
%      left and top (respectively) of the map to fit the legend
visualizer.x_margin = 6;
visualizer.y_margin = max(ceil(3 + visualizer.has_impassable + ...
    max_nebula + visualizer.n_ghost_types - n_rows + ...
    visualizer.between_legend_items*(2+visualizer.n_ghost_types)), 0);

% ---> Set the limits of the grid, including the margins
visualizer.ij2xy = @(ij) e7pl_ij2xy(ij, n_rows);
[x, y] = visualizer.ij2xy([1, 1]);
visualizer.x_min = x - 0.5;
visualizer.y_max = y + 0.5 + visualizer.y_margin;
[x, y] = visualizer.ij2xy([n_rows, n_cols]);
visualizer.x_max = x + 0.5 + visualizer.x_margin;
visualizer.y_min = y - 0.5;

% ---> Set the x-location of the legend
visualizer.x_legend = visualizer.x_max - visualizer.x_margin + 1.5;

% --> Create the array that will be plotted (the last two operations add
%     part of the legend)
visualizer.grid_image = zeros([n_rows+visualizer.y_margin, ...
    n_cols+visualizer.x_margin]) + max_nebula + 3;
visualizer.grid_image(1:n_rows,1:n_cols) = map.grid(end:-1:1,:)+1;
visualizer.grid_image(isinf(visualizer.grid_image)) = max_nebula + 2;
visualizer.grid_image(1:max_nebula+1,n_cols+2) = [1:max_nebula+1];
if visualizer.has_impassable
    visualizer.grid_image(max_nebula+2,n_cols+2) = max_nebula + 2;
end

% ---> Set the colorscale for the backgroud of the map
visualizer.colorscale = gray(max_nebula+2);
if visualizer.has_impassable
    % * set the color of the impassable areas
    visualizer.colorscale(end,:) = [1, 1, 0.75];
else
    visualizer.colorscale(end,:) = [];
end
% * set the color of the background of the legend area
visualizer.colorscale = [visualizer.colorscale; 1, 1, 1];

% Initialize other visualizer features
visualizer.running = false;
visualizer.speed = 10;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = e7pl_draw_visualizer_frame(visualizer)

% E7PL_DRAW_VISUALIZER_FRAME(visualizer): draws the current frame of the
% visualizer (input argument "visualizer").

% Prepare to draw the current frame of the visualizer
current_figure = gcf();
figure(visualizer.figure)
clf()
hold on
axis equal tight
add_text = @(x, y, txt, color, ha) text(x, y, txt, 'Color', color, ...
    'VerticalAlignment', 'middle', 'HorizontalAlignment', ha);
frame = visualizer.frames(visualizer.current_frame);

% Draw the background
colormap(visualizer.colorscale)
image( ...
    [visualizer.x_min+0.5, visualizer.x_max-0.5], ...
    [visualizer.y_min+0.5, visualizer.y_max-0.5], ...
    visualizer.grid_image)

% Draw the scraps
for k_scrap = 1:numel(frame.scraps)
    [x, y] = visualizer.ij2xy(frame.scraps(k_scrap).location);
    visualizer.draw.scrap(x, y)
    add_text(x, y, [num2str(k_scrap), '^{(', ...
        num2str(frame.scraps(k_scrap).value), ')}'], 'w', 'center')
end

% Draw the ghosts
txt_transparency = {'', '^*', '^{**}'};
for k_ghost = 1:visualizer.n_ghosts
    [x, y] = visualizer.ij2xy(frame.ghosts(k_ghost).location(end,:));
    visualizer.draw.ghosts.(frame.ghosts(k_ghost).type)(x, y)
    transparency = frame.ghosts(k_ghost).transparency;
    txt = [num2str(k_ghost), txt_transparency{transparency+1}];
    add_text(x, y, txt, 'w', 'center')
end

% Draw the player
[x, y] = visualizer.ij2xy(frame.player.location);
visualizer.draw.player(x, y)

% Add text labels showing row and column indices
for i = 1:round(visualizer.n_rows/10):visualizer.n_rows
    [x, y] = visualizer.ij2xy([i, 1]);
    add_text(0, y, num2str(i), 'k', 'right');
end
for j = 1:round(visualizer.n_cols/10):visualizer.n_cols
    [x, y] = visualizer.ij2xy([1, j]);
    add_text(x, 0, num2str(j), 'k', 'center')
end

% Write the "end of game" message if necessary
if visualizer.current_frame == visualizer.max_frame
    if visualizer.game_stats.win
        txt = sprintf('Congratulations...\nYou won!');
        color = 'g';
    else
        txt = sprintf('Game over...\nTry again!');
        color = 'r';
    end
    text( ...
        (visualizer.x_min+visualizer.x_max)/2, ...
        (visualizer.y_min+visualizer.y_max)/2, ...
        txt, 'Color', color, 'FontSize', 30, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
end

% Draw what is left to draw of the legend
% ---> Background values
for y = 1:visualizer.max_nebula+visualizer.has_impassable+1
    if y > visualizer.max_nebula+1
        txt = 'Asteroid field (+Inf)';
    else
        txt = num2str(y-1);
    end
    add_text(visualizer.x_legend+1, y, txt, 'k', 'left')
end
% ---> Ghost types
for k_ghost_type = 1:visualizer.n_ghost_types
    ghost_type = visualizer.ghost_types{k_ghost_type};
    y = y + 1 + visualizer.between_legend_items;
    visualizer.draw.ghosts.(ghost_type)(visualizer.x_legend, y)
    add_text(visualizer.x_legend+1, y, sprintf('Ghost: %s', ghost_type), ...
        'k', 'left')
end
% ---> Scrap
y = y + 1 + visualizer.between_legend_items;
visualizer.draw.scrap(visualizer.x_legend, y)
add_text(visualizer.x_legend+1, y, 'Scrap', 'k', 'left')
% ---> Player
y = y + 1 + visualizer.between_legend_items;
visualizer.draw.player(visualizer.x_legend, y)
add_text(visualizer.x_legend+1, y, 'Player', 'k', 'left')

% Format the figure
xlabel('')
ylabel('')
set(gca(), 'XTick', [])
set(gca(), 'YTick', [])
xlim([visualizer.x_min, visualizer.x_max]);
ylim([visualizer.y_min, visualizer.y_max]);
e7pl_set_visualizer_title(visualizer)
hold off

% Restore the original figure as the active figure
figure(current_figure)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = e7pl_set_visualizer_title(visualizer)

% E7PL_SET_VISUALIZER_TITLE(visualizer): sets the title of the visualizer
% (input argument "visualizer").

current_figure = gcf();
figure(visualizer.figure)
hold on
title(sprintf(['Map right after turn %d out of %d (speed: %d)\n', ...
    'Number of turns allowed in the game: %d\nCurrent score: %d'], ...
    visualizer.current_frame-1, visualizer.max_frame-1, ...
    visualizer.speed, visualizer.game_stats.max_turns, ...
    visualizer.frames(visualizer.current_frame).player.score))
hold off
figure(current_figure)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result] = e7pl_count_scraps_total_value(scraps);

% result = E7PL_COUNT_SCRAPS_TOTAL_VALUE(scraps): returns (output argument
% "result", a scalar of class double) the total value of the scraps
% described by "scraps", including the scraps that are unreachable.
% "scraps" should have the same format as "map.scraps".

result = sum(arrayfun(@(scrap) scrap.value, scraps));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [msg] = e7pl_describe_error(e, max_depth)

% msg = E7PL_DESCRIBE_ERROR(e): Creates a nicely-formatted message (output
% argument "msg", a character string) that describes why and where the
% error "e" originated, possibly uncluding information about the full trace
% of this error. "max_depth", if present (it is optional), should be a
% positive integer (of class double) that indicates how deep in the stack
% of the error's trace this function should look into (it is okay if
% "max_depth" is larger than the size of the stack of the error's trace).
% If "max_depth" is absent, this function looks into the entire stack of
% the error's trace.

narginchk(1, 2)
if nargin < 2
    max_depth = numel(e.stack);
else
    max_depth = min(max_depth, numel(e.stack));
end

msg = sprintf('The error message was:\n\n%s\n', e.message);
for k = 1:max_depth
    if k == 1
        msg = sprintf(['%s\nThe error happened inside the function or ', ...
            'script:\n\n%s (line %d)'], msg, e.stack(k).name, e.stack(k).line);
        continue
    end
    msg = sprintf(['%s\n\nwhich was called by the function or ' ...
        'script\n\n%s (line %d)'], msg, e.stack(k).name, e.stack(k).line);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x, y] = e7pl_ij2xy(ij, n_rows)

% E7PL_IJ2XY(ij, n_rows): returns the x- and y-coordinates (output
% arguments "x" and "y", respectively) corresponding to location "ij" (a 1
% by 2 array of class double that specifies the row and column indices of
% this location, in this order). "n_rows" should be the number of rows in
% the grid.

x = ij(2);
y = n_rows - ij(1) + 1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg] = e7pl_check_class(v, class_expected, v_description)

% [valid, msg] = E7PL_CHECK_CLASS(v, class_expected, v_description): Checks
% whether the class of "v" is "class_expected" (a character string).
% "v_description" (a character string) should be the name and/or the
% description of the variable "v". "valid" is a scalar logical that is true
% if and only if the class of "v" is "class_expected". If "valid" is true,
% then "msg" is an empty character string. If "valid" is false, then "msg"
% is a character string that describes the expected versus actual class of
% "v".

class_actual = class(v);
valid = strcmp(class_actual, class_expected);
if valid
    msg = '';
else
    msg = sprintf(['Expected the class of "%s" to be "%s", but it is ', ...
        '"%s" instead.'], v_description, class_expected, class_actual);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg] = e7pl_check_size(v, size_expected, v_description)

% [valid, msg] = E7PL_CHECK_SIZE(v, size_expected, v_description): Checks
% whether the size of "v" is "size_expected" (a row vector of class
% double). "v_description" (a character string) should be the name and/or
% the description of the variable "v". "valid" is a scalar logical that is
% true if and only if the size of "v" is "size_expected". If "valid" is
% true, then "msg" is an empty character string. If "valid" is false, then
% "msg" is a character string that describes the expected versus actual
% size of "v".

size_actual = size(v);
valid = isequal(size_actual, size_expected);
if valid
    msg = '';
else
    size_expected = sprintf('%dx', size_expected);
    size_actual = sprintf('%dx', size_actual);
    msg = sprintf(['Expected the size of "%s" to be %s, but it is %s ', ...
        'instead.'], v_description, size_expected(1:end-1), ...
        size_actual(1:end-1));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg] = e7pl_check_size_row(v, v_description)

% [valid, msg] = E7PL_CHECK_SIZE_ROW(v, v_description): Checks whether "v"
% is a non-empty row vector. "v_description" (a character string) should be
% the name and/or the description of the variable "v". "valid" is a scalar
% logical that is true if and only if "v" is a non-empty row vector. If
% "valid" is true, then "msg" is an empty character string. If "valid" is
% false, then "msg" is a character string that describes the expected
% versus actual size of "v".

size_actual = size(v);
valid = numel(size_actual) == 2 && size_actual(1) == 1 && size_actual(2) > 0;
if valid
    msg = '';
else
    size_actual = sprintf('%dx', size_actual);
    msg = sprintf(['Expected the size of "%s" to be 1xn (n>0), but it is ', ...
        '%s instead.'], v_description, size_actual(1:end-1));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg] = e7pl_check_size_column(v, v_description)

% [valid, msg] = E7PL_CHECK_SIZE_COLUMN(v, v_description): Checks whether
% "v" is a non-empty column vector. "v_description" (a character string)
% should be the name and/or the description of the variable "v". "valid" is
% a scalar logical that is true if and only if "v" is a non-empty column
% vector. If "valid" is true, then "msg" is an empty character string. If
% "valid" is false, then "msg" is a character string that describes the
% expected versus actual size of "v".

size_actual = size(v);
valid = numel(size_actual) == 2 && size_actual(1) > 0 && size_actual(2) == 1;
if valid
    msg = '';
else
    size_actual = sprintf('%dx', size_actual);
    msg = sprintf(['Expected the size of "%s" to be nx1 (n>0), but it is ', ...
        '%s instead.'], v_description, size_actual(1:end-1));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg] = e7pl_check_class_and_size(v, class_expected, ...
    size_expected, v_description)

% [valid, msg] = E7PL_CHECK_CLASS_AND_SIZE(v, class_expected,
% size_expected, v_description): Checks whether the class of "v" is
% "class_expected" (a character string) and whether the size of "v" is
% "size_expected" (a row vector of class double). "v_description" (a
% character string) should be the name and/or the description of the
% variable "v". "valid" is a scalar logical that is true if and only if the
% class of "v" is "class_expected" and if the size of "v" is
% "size_expected". If "valid" is true, then "msg" is an empty character
% string. If "valid" is false, then "msg" is a character string that
% describes the issue with the expected versus actual class or size of "v".

[valid, msg] = e7pl_check_class(v, class_expected, v_description);
if ~valid
    return
end
[valid, msg] = e7pl_check_size(v, size_expected, v_description);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg] = e7pl_check_fieldnames(v, fieldnames_expected, ...
    v_description)

% [valid, msg] = E7PL_CHECK_FIELDNAMES(v, fieldnames_expected,
% v_description): Checks whether the list of the field names of the struct
% array "v" is the same (order does not matter) as the list of field names
% described by "fieldnames_expected" (a vector of class cell, where each
% element is a character string). "v_description" (a character string)
% should be the name and/or the description of the struct array "v".
% "valid" is a scalar logical that is true if and only if the list of field
% names of the struct array "v" is as described in "fieldnames_expected".
% If "valid" is true, then "msg" is an empty character string. If "valid"
% is false, then "msg" is a character string that describes the expected
% versus actual list of field names of "v".

[valid, msg] = e7pl_check_class(v, 'struct', v_description);
if ~valid
    mid = 'e7pl_check_fieldnames:notastructarray';
    throw(MException(mid, msg));
end

fieldnames_actual = fieldnames(v);
fieldnames_extra = fieldnames_actual(~ismember(fieldnames_actual, ...
    fieldnames_expected));
valid = all(ismember(fieldnames_expected, fieldnames_actual)) && ...
    numel(fieldnames_extra) == 0;
if valid
    msg = '';
else
    fieldnames_expected = sprintf('%s, ', fieldnames_expected{:});
    fieldnames_actual = sprintf('%s, ', fieldnames_actual{:});
    msg = sprintf(['Expected the struct array "%s" to have the following ', ...
        'fields (and no other field): (%s), but it has the following ', ...
        'fields instead: (%s).'], v_description, ...
        fieldnames_expected(1:end-2), fieldnames_actual(1:end-2));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [direction] = e7pl_ghost_backandforth(map, k_ghost)

% direction = E7PL_GHOST_BACKANDFORTH(map, k_ghost): determines the next
% move (output argument "direction") of ghost number "k_ghost", which must
% be of type 'backandforth'. The input argument "map" is the same as the
% input argument of the same name in the top-level function. The output
% argument "direction" is the direction of the move, following the same
% format as the output argument of the same name expected of the player's
% function.
%
% This ghost does not use "wrap around the map" moves. In other words, this
% ghost views the edges of the map as impassable.

ghost = map.ghosts(k_ghost);

% Check that the type of the ghost is the correct one
if ~strcmp(ghost.type, 'backandforth')
    mid = 'e7pl_ghost_backandforth:wrongghosttype';
    msg = sprintf(['You are trying to move ghost number %d, which is of ', ...
        'type "%s", with the function "e7pl_ghost_backandforth".'], ...
        k_ghost, ghost.type);
    throw(MException(mid, msg));
end

% Get useful quantities
[n_rows, n_cols] = size(map.grid);
i_previous = ghost.location(end-1,1);
j_previous = ghost.location(end-1,2);
i_current = ghost.location(end,1);
j_current = ghost.location(end,2);
transparency = ghost.transparency;
blocked_above = i_current == 1 || ...
    isinf(map.grid(i_current-1,j_current)) && transparency < 2;
blocked_below = i_current == n_rows || ...
    isinf(map.grid(i_current+1,j_current)) && transparency < 2;
blocked_left = j_current == 1 || ...
    isinf(map.grid(i_current,j_current-1)) && transparency < 2;
blocked_right = j_current == n_cols || ...
    isinf(map.grid(i_current,j_current+1)) && transparency < 2;
d_horizontal = abs(j_current-j_previous);
d_vertical = abs(i_current-i_previous);

% We double-check that the previous and current locations of this ghost are
% not more than one grid cell apart
if d_horizontal + d_vertical > 1
    mid = 'e7pl_ghost_backandforth:badpreviouslocation';
    msg = sprintf(['The previous (%d,%d) and current (%d,%d) locations ', ...
        'of ghost number %d are located more than one grid cell away.'], ...
        i_previous, j_previous, i_current, j_current, k_ghost);
    throw(MException(mid, msg));
end

% If the ghost's previous and current locations are the same, look at the
% ghost's location history to determine in which direction it last moved
k_move = size(ghost.location, 1) - 1;
while k_move > 1 && i_current == i_previous && j_current == j_previous
    k_move = k_move - 1;
    i_previous = ghost.location(k_move,1);
    j_previous = ghost.location(k_move,2);
end
horizontal = abs(j_current-j_previous) > 0;
vertical = abs(i_current-i_previous) > 0;

% The following situation should never happen. We check for it anyway, as
% it may help us detect possible bugs in the code
if horizontal && vertical || ~horizontal && ~vertical
    mid = 'e7pl_ghost_backandforth:badlocationhistory';
    msg = {'false', 'true'};
    msg = sprintf(['The location history of ghost number %d is faulty ', ...
        '(horizontal is %s and vertical is %s).'], k_ghost, ...
        msg{horizontal+1}, msg{vertical+1});
    throw(MException(mid, msg));
end

% If the ghost is blocked on both sides, then it just does not move
if horizontal && blocked_left && blocked_right || ...
        vertical && blocked_above && blocked_below
    direction = '.';
    return
end

% This ghost tries to keep moving in the same direction as before. If it
% cannot, it moves in the opposite direction
if vertical && i_current > i_previous
    if blocked_below
        direction = 'U';
    else
        direction = 'D';
    end
elseif vertical && i_current < i_previous
    if blocked_above
        direction = 'D';
    else
        direction = 'U';
    end
elseif horizontal && j_current > j_previous
    if blocked_right
        direction = 'L';
    else
        direction = 'R';
    end
elseif horizontal && j_current < j_previous
    if blocked_left
        direction = 'R';
    else
        direction = 'L';
    end
else
    mid = 'e7pl_ghost_backandforth:cannotcalculatemove';
    msg = sprintf(['Was unable to calculate the next move of ghost ', ...
        'number %d. Its type is %s, its previous location is (%d,%d), ', ...
        'and its current location is (%d,%d).'], k_ghost, ghost.type, ...
        i_previous, j_previous, i_current, j_current);
    throw(MException(mid, msg));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [direction] = e7pl_ghost_towardplayer(map, k_ghost)

% direction = E7PL_GHOST_TOWARDPLAYER(map, k_ghost): determines the next
% move (output argument "direction") of ghost number "k_ghost", which must
% be of type 'towardplayer'. The input argument "map" is the same as the
% input argument of the same name in the top-level function. The output
% argument "direction" is the direction of the move, following the same
% format as the output argument of the same name expected of the player's
% function.
%
% This ghost does not try to go around objects to get to the player, so
% this ghost may get stuck behind impassable areas (unless its transparency
% allows it to move through otherwise impassable areas). This ghost does
% not use "wrap around the map" moves. In other words, this ghost views the
% edges of the map as impassable.

ghost = map.ghosts(k_ghost);

% Check that the type of the ghost is the correct one
if ~strcmp(ghost.type, 'towardplayer')
    mid = 'e7pl_ghost_towardplayer:wrongghosttype';
    msg = sprintf(['You are trying to move ghost number %d, which is of ', ...
        'type "%s", with the function "e7pl_ghost_towardplayer".'], ...
        k_ghost, ghost.type);
    throw(MException(mid, msg));
end

% Get useful quantities
i_ghost = ghost.location(end,1);
j_ghost = ghost.location(end,2);
i_player = map.player.location(end,1);
j_player = map.player.location(end,2);
player_is_above = i_ghost > i_player;
player_is_below = i_ghost < i_player;
player_is_right = j_ghost < j_player;
player_is_left = j_ghost > j_player;

% If the ghost is on the same row or same column as the player, then there
% is only one possible option for the ghost's next move. Otherwise, the
% ghost must choose between moving along rows or moving along columns
direction = '';
if player_is_right
    direction(end+1) = 'R';
elseif player_is_left
    direction(end+1) = 'L';
end
if player_is_below
    direction(end+1) = 'D';
elseif player_is_above
    direction(end+1) = 'U';
end
if numel(direction) == 1
    return
end

% If we reach this point, the ghost must choose between moving along rows
% or moving along columns. If one of the move is possible but the other one
% is not, then the choice is clear
possible = arrayfun(@(direction) ghost.transparency == 2 || ( ...
    direction == 'U' && ~isinf(map.grid(i_ghost-1, j_ghost)) || ...
    direction == 'D' && ~isinf(map.grid(i_ghost+1, j_ghost)) || ...
    direction == 'L' && ~isinf(map.grid(i_ghost, j_ghost-1)) || ...
    direction == 'R' && ~isinf(map.grid(i_ghost, j_ghost+1))), direction);
if nnz(possible) == 1
    direction = direction(possible);
    return
end

% If we reach this point, both choices (moving along rows or moving along
% columns) are possible. The ghost moves along the direction that
% corresponds to the longest distance to the player. If the distances to
% the player along rows and along columns are the same, then the ghost
% moves along the largest dimension of the map (e.g. it moves vertically if
% the map is taller than it is wide); in this last case, the ghost moves
% horizontally if the map is square
d_horizontal = abs(j_ghost-j_player);
d_vertical = abs(i_ghost-i_player);
[n_rows, n_cols] = size(map.grid);
if d_vertical > d_horizontal
    if player_is_below
        direction = 'D';
    else
        direction = 'U';
    end
elseif d_horizontal > d_vertical
    if player_is_right
        direction = 'R';
    else
        direction = 'L';
    end
elseif n_rows > n_cols
    if player_is_below
        direction = 'D';
    else
        direction = 'U';
    end
else
    if player_is_right
        direction = 'R';
    else
        direction = 'L';
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg] = e7pl_check_map(map)

% [valid, msg] = E7PL_CHECK_MAP(map): performs quality control on a map
% (input argument "map") in its initial state (before any move has been
% made). "valid" is a scalar logical that is true if and only if the map
% successfully passes the quality control. If "valid" is true, then "msg"
% is an empty character string. If "valid" is false, then "msg" is a
% character string that describes the nature of the issue with the map.
% This function tries to be fairly verbose and explicit when describing the
% nature of the issue with the map (if any), which is why this function is
% quite lengthy.

valid = false;

% Check "map"
% ---> Class and Size
[valid_local, msg] = e7pl_check_class_and_size(map, 'struct', [1, 1], 'map');
if ~valid_local
    return
end
% ---> field names
fieldnames_expected = {'grid'; 'player'; 'scraps'; 'ghosts'; ...
    'remaining_turns'};
[valid_local, msg] = e7pl_check_fieldnames(map, fieldnames_expected, 'map');
if ~valid_local
    return
end

% Check "map.grid"
% ---> Class
[valid_local, msg] = e7pl_check_class(map.grid, 'double', 'map.grid');
if ~valid_local
    return
end
% ---> size
s = size(map.grid);
if numel(s) ~= 2 || numel(map.grid) < 2
    msg = sprintf('%dx', s)
    msg = sprintf(['Expected "map.grid" to be a 2-dimensional array that ', ...
        'has at least two elements, but it is a %s array instead.'], ...
        msg(1:end-1));
    return
end
n_rows = s(1);
n_cols = s(2);
% ---> content
if ...
        any(map.grid(:) < 0) || sum(map.grid(:) == 0) < 2 || ...
        any(~isinf(map.grid(:)) & mod(map.grid(:), 1) ~= 0)
    msg = ['Elements of "map.grid" must be +Inf, or integers that are ', ...
        'zero or positive. At least two of the elements of "map.grid" ', ...
        'must be zero.'];
    return
end

% Check "map.player"
% ---> Class and size
[valid_local, msg] = e7pl_check_class_and_size(map.player, 'struct', ...
    [1, 1], 'map.player');
if ~valid_local
    return
end
% ---> Field names
fieldnames_expected = {'location'; 'score'};
[valid_local, msg] = e7pl_check_fieldnames(map.player, ...
    fieldnames_expected, 'map.player');
if ~valid_local
    return
end
% ---> Field values
% * location
location = map.player.location;
[valid_local, msg] = e7pl_check_class_and_size(location, 'double', [2, 2], ...
    'map.player.location');
if ~valid_local
    return
end
is_nan_location = @(ij) isequal(size(ij), [1, 2]) && all(isnan(ij));
if ~is_nan_location(location(1,:))
    msg = ['The "previous" location of the player in "map" is not valid. ', ...
        'It must be (NaN, NaN).'];
    return
end
is_valid_location = @(ij) all(mod(ij, 1) == 0) && all(ij > 0) && ...
    ij(1) <= n_rows && ij(2) <= n_cols && ~isinf(map.grid(ij(1),ij(2)));
if ~is_valid_location(location(end,:))
    msg = ['The "current" location of the player in "map" is not valid.'];
    return
end
% * score
[valid_local, msg] = e7pl_check_class_and_size(map.player.score, 'double', ...
    [1, 1], 'map.player.score');
if ~valid_local
    return
end
if map.player.score ~= 0
    msg = 'The player''s initial score (map.player.score) should be 0.';
    return
end

% Check "map.scraps"
% ---> Class
[valid_local, msg] = e7pl_check_class(map.scraps, 'struct', 'map.scraps');
if ~valid_local
    return
end
% ---> Size
[valid_local, msg] = e7pl_check_size_column(map.scraps, 'map.scraps');
if ~valid_local
    return
end
% ---> Fields names
fieldnames_expected = {'location'; 'value'};
[valid_local, msg] = e7pl_check_fieldnames(map.scraps, ...
    fieldnames_expected, 'map.scraps');
if ~valid_local
    return
end
% ---> Field values
for k_scrap = 1:numel(map.scraps)
    scrap = map.scraps(k_scrap);
    scrap_txt = sprintf('map.scraps(%d)', k_scrap);
    location = scrap.location;
    % * location
    [valid_local, msg] = e7pl_check_class_and_size(location, 'double', ...
        [1, 2], [scrap_txt, '.location']);
    if ~valid_local
        return
    end
    if ~is_valid_location(location)
        msg = sprintf('"%s.location" is not valid.', scrap_txt);
        return
    end
    % * the scrap's location cannot be where the player is
    if isequal(location, map.player.location(end,:))
        msg = sprintf(['The location of "%s" is the same as the initial ', ...
            'location of the player.'], scrap_txt);
        return
    end
    % * the scrap's location cannot be the same as the location of another
    %   scrap
    for l_scrap = 1:k_scrap-1
        if isequal(location, map.scraps(l_scrap).location)
            msg = sprintf(['In "map", scraps number %d and %d are in the ', ...
                'same location.'], l_scrap, k_scrap);
            return
        end
    end
    % * value
    [valid_local, msg] = e7pl_check_class_and_size(scrap.value, ...
        'double', [1, 1], [scrap_txt, '.value']);
    if ~valid_local
        return
    end
    if scrap.value <= 0 || mod(scrap.value, 1) ~= 0
        msg = sprintf('"%s.value" is not valid.', scrap_txt);
        return
    end
end

% Check "map.ghosts"
% ---> Class
[valid_local, msg] = e7pl_check_class(map.ghosts, 'struct', 'map.ghosts');
if ~valid_local
    return
end
% ---> The quality control of ghosts is completed if "map.ghosts" is empty
if numel(map.ghosts) > 0
    % ---> Size
    [valid_local, msg] = e7pl_check_size_column(map.ghosts, 'map.ghosts');
    if ~valid_local
        return
    end
    % ---> Fields names
    fieldnames_expected = {'location'; 'type'; 'transparency'};
    [valid_local, msg] = e7pl_check_fieldnames(map.ghosts, ...
        fieldnames_expected, 'map.ghosts');
    if ~valid_local
        return
    end
    % ---> Field values
    for k_ghost = 1:numel(map.ghosts)
        ghost = map.ghosts(k_ghost);
        ghost_txt = sprintf('map.ghosts(%d)', k_ghost);
        location = map.ghosts(k_ghost).location;
        % * ghost type
        [valid_local, msg] = e7pl_check_class(ghost.type, 'char', ...
            [ghost_txt, '.type']);
        if ~valid_local
            return
        end
        [valid_local, msg] = e7pl_check_size_row(ghost.type, ...
            [ghost_txt, '.type']);
        if ~valid_local
            return
        end
        if ~ismember(ghost.type, {'backandforth', 'towardplayer'})
            msg = sprintf('"%s.type" is not valid.', ghost_txt);
            return
        end
        % * transparency
        transparency = ghost.transparency;
        [valid_local, msg] = e7pl_check_class_and_size(transparency, ...
            'double', [1, 1], [ghost_txt, '.transparency']);
        if ~valid_local
            return
        end
        if ~any(transparency == (0:2))
            msg = sprintf('"%s".transparency is not valid.', ghost_txt);
            return
        end
        % * location
        [valid_local, msg] = e7pl_check_class_and_size(location, 'double', ...
            [2, 2], [ghost_txt, '.location']);
        if ~valid_local
            return
        end
        % * current location
        if ~is_valid_location(location(end,:))
            msg = sprintf(['The current location of ghost number %d in ', ...
                '"map" is not valid.'], k_ghost);
            return
        end
        % * previous location
        msg = sprintf(['The previous location of ghost number %d ', ...
            '(type: %s) in "map" is not valid.'], k_ghost, ghost.type);
        if strcmp(ghost.type, 'backandforth') && ~( ...
            all(mod(location(1,:), 1) == 0) && all(location(1,:) > 0) && ...
                location(1,1) <= n_rows && location(1,2) <= n_cols && ...
                sum(abs(location(1,:)-location(2,:))) == 1)
            return
        elseif strcmp(ghost.type, 'towardplayer') && ...
                ~is_nan_location(location(1,:))
            return
        end
        % * the ghost's location cannot be where the player is
        if isequal(location(end,:), map.player.location(end,:))
            msg = sprintf(['The location of ghost number %d in "map" is ', ...
                'the same as the initial location of the player.'], k_ghost);
            return
        end
        % * the ghost's location cannot be the same as the location of
        %   another ghost
        for l_ghost = 1:k_ghost-1
            if isequal(location(end,:), map.ghosts(l_ghost).location(end,:))
                msg = sprintf(['In "map", ghosts number %d and %d are in ', ...
                    'the same location.'], l_ghost, k_ghost);
                return
            end
        end
        % * the ghost's location cannot be where a scrap is
        for k_scrap = 1:numel(map.scraps)
            if isequal(location(end,:), map.scraps(k_scrap).location)
                msg = sprintf([...
                    'In "map", the initial location of ghost number %d ', ...
                    'is the same as the location of scrap number %d.'], ...
                    k_ghost, k_scrap);
                return
            end
        end
    end
end

% Check "map.remaining_turns"
% ---> Class and size
[valid_local, msg] = e7pl_check_class_and_size(map.remaining_turns, ...
    'double', [1, 1], 'map.remaining_turns');
if ~valid_local
    return
end
% ---> Value
if map.remaining_turns <= 0 || mod(map.remaining_turns, 1) ~= 0
    msg = ['The value of "map.remaining_turns" is not valid. It must be ', ...
        'a positive non-infinite integer.'];
    return
end

% If we reach this point, then "map" is valid
valid = true;
msg = '';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, msg] = e7pl_check_player_function(player_function);

% [valid, msg] = E7PL_CHECK_PLAYER_FUNCTION(player_function): performs
% quality control on the player's function (input argument
% "player_function"). "valid" is a scalar logical that is true if and only
% if the player's function successfully passes the quality control. If
% "valid" is true, then "msg" is an empty character string. If "valid" is
% false, then "msg" is a character string that describes the nature of the
% issue with the player's function.
%
% To pass the quality control, "player_function" must be a function handle
% to a function that takes one and only one input argument, and returns one
% and only one output argument.

valid = false;

% Check the class and size
[valid_local, msg] = e7pl_check_class_and_size(player_function, ...
    'function_handle', [1, 1], 'player_function');
if ~valid_local
    return
end

% Check the number of input arguments
n = nargin(player_function);
if n ~= 1
    if n < 0
        n_txt = 'an undetermined (maybe variable) number of'
    else
        n_txt = num2str(n);
    end
    msg = sprintf(['The input argument "player_function" must be a ', ...
        'function handle to a function that takes one and only one ', ...
        'input argument. The function handle that you provided ', ...
        'corresponds to a function that takes %s input argument(s).'], n_txt);
    return
end

% Check the number of output arguments
n = nargout(player_function);
if n ~= 1
    if n < 0
        n_txt = 'an undetermined (maybe variable) number of'
    else
        n_txt = num2str(n);
    end
    msg = sprintf(['The input argument "player_function" must be a ', ...
        'function handle to a function that returns one and only one ', ...
        'output argument. The function handle that you provided ', ...
        'corresponds to a function that returns %s output argument(s). ', ...
        'Note: "player_function" cannot be a handle to an anonymous ', ...
        'function.'], n_txt);
    return
end

% If we reach this point, the player's function successfully passed the
% quality control
valid = true;
msg = '';

end
