function [route]=e7planets_player(map)
[matrix_p,location,location_s]=frame2(map);
route_storage=[];
location_s;
location;
matrix_p;
matrix_i=[map.grid,map.grid,map.grid;map.grid,map.grid,map.grid;map.grid,map.grid,map.grid];
matrix_i=matrix_i+1;
[route]=finding1(matrix_p,location,location_s,matrix_i);
[g_current_location_storage,g_next_location_storage,ghost_type,location_s,n_ghost]=out_g1( map);
    
    [route]=adjustment(location_s,route,g_current_location_storage,g_next_location_storage,ghost_type,n_ghost,map);
   
    for i=1:n_ghost
        g_current_location=g_current_location_storage(i,:);
        g_next_location=g_next_location_storage(i,:);
        location_s_next_tmp=location_s;
        if strcmp(route,'L')
            location_s_next_tmp(2)=location_s(2)-1;
        elseif strcmp(route,'R')
            location_s_next_tmp(2)=location_s(2)+1;
        elseif strcmp(route,'D')
            location_s_next_tmp(1)=location_s(1)+1;
            
        elseif strcmp(route,'U')
            location_s_next_tmp(1)=location_s(1)-1;
        end
        [row,col]=size(map.grid);
        if location_s_next_tmp(1)==0
            location_s_next_tmp(1)=row;
            
        end
        if location_s_next_tmp(1)==row+1
            location_s_next_tmp;
            location_s_next_tmp(1)=1;
            
            location_s_next_tmp;
        end
        if location_s_next_tmp(2)==0
            location_s_next_tmp(2)=col;
            
        end
        if location_s_next_tmp(2)==col+1
            location_s_next_tmp(2)=1;
            
        end
        
        if g_next_location(1)==location_s_next_tmp(1)&&g_next_location(2)==location_s_next_tmp(2)
        elseif g_next_location(1)==location_s(1)...
                &&g_next_location(2)==location_s(2)...
                &&g_current_location(1)==location_s_next_tmp(1)...
                &&g_current_location(2)==location_s_next_tmp(2)
        else
            break
        end
    end
end

function [route]=adjustment(location_s,route,g_current_location_storage,g_next_location_storage,ghost_type,n_ghost,map)
location_s_next_tmp=location_s;
location_s;
if strcmp(route,'L')
    location_s_next_tmp(2)=location_s(2)-1;
    
elseif strcmp(route,'R')
    location_s_next_tmp(2)=location_s(2)+1;
elseif strcmp(route,'D')
    location_s_next_tmp(1)=location_s(1)+1;
    
elseif strcmp(route,'U')
    location_s_next_tmp(1)=location_s(1)-1;
end
location_s_next_tmp;
[row,col]=size(map.grid);
for i=1:n_ghost
    g_current_location=g_current_location_storage(i,:);
    g_next_location=g_next_location_storage(i,:);
    if strcmp(ghost_type(i,:),'towardplayer')||strcmp(ghost_type(i,:),'backandforth')
        %location_s is current direction
        random_1=randi([0,1],1);
        %[ghost_route,g_next_location]=ghost_direction(g_current_location,location_s);
        location_s_next_tmp=location_s;
        if strcmp(route,'L')
            location_s_next_tmp(2)=location_s(2)-1;
        elseif strcmp(route,'R')
            location_s_next_tmp(2)=location_s(2)+1;
        elseif strcmp(route,'U')
            location_s_next_tmp(1)=location_s(1)-1;
        elseif strcmp(route,'D')
            location_s_next_tmp(1)=location_s(1)+1;
        end
        if location_s_next_tmp(1)==0
    location_s_next_tmp(1)=row;
end
if location_s_next_tmp(1)==row+1
    location_s_next_tmp(1)=1;
end
if location_s_next_tmp(2)==0
    location_s_next_tmp(2)=col;
end
if location_s_next_tmp(2)==col+1
    location_s_next_tmp(2)=1;
end
        if g_next_location(1)==location_s_next_tmp(1)&&g_next_location(2)==location_s_next_tmp(2)
            %g_next_location==location_s_next_tmp)==numel(g_next_location%%??xiangdeng
            
            if strcmp(route,'R')
                if random_1==1
                    route='U';
                    break
                else
                    route='D';
                    break
                end
            elseif strcmp(route,'L')
                if random_1==1
                    route='U';
                    break
                else
                    route='D';
                    break
                end
            elseif strcmp(route,'D')
                if random_1==1
                    route='L';
                    break
                else
                    route='R';
                    break
                end
            elseif strcmp(route,'U')
                if random_1==1
                    route='L';
                    break
                else
                    route='R';
                    break
                end
            end
            
        elseif g_next_location(1)==location_s(1)...
                &&g_next_location(2)==location_s(2)...
                &&g_current_location(1)==location_s_next_tmp(1)...
                &&g_current_location(2)==location_s_next_tmp(2)
            
            %((g_next_location==location_s)==numel(g_next_location))&&(sum(location_s_next_tmp==g_current_location)==numel(g_current_location))
            if strcmp(route,'R')
                if random_1==1
                    route='U';
                    break
                else
                    route='D';
                    break
                end
            elseif strcmp(route,'L')
                if random_1==1
                    route='U';
                    break
                else
                    route='D';
                    break
                end
            elseif strcmp(route,'D')
                if random_1==1
                    route='L';
                    break
                else
                    route='R';
                    break
                end
            elseif strcmp(route,'U')
                if random_1==1
                    route='L';
                    break
                else
                    route='R';
                    break
                end
            end
            
        end
    end
end
end

function [now_g,next_g,type,now_p,n_g]=out_g1(map)

n_g=length(map.ghosts);
now_g=zeros(0,2);
tran=zeros(0,1);
type=[];%读取当前位置，鬼是否穿墙tran，追人还是来回type
for i=1:n_g
    now_g(i,:)=map.ghosts(i).location(end,:);
    tran(i,:)=map.ghosts(i).transparency;
    type=[type;map.ghosts(i).type];
end
%读取方向
directions=[];
for i= 1:n_g
    if strcmp(type(i,:),'backandforth')==1
        direction=ghost_backandforth(map,i);
        directions=[directions;direction];
    end
    if strcmp(type(i,:),'towardplayer')==1
        direction=ghost_towardplayer(map, i);
        directions=[directions;direction];
    end
end
directions;
next_g=zeros(0,2);%推下一步位置
for i=1:n_g
    if strcmp(directions(i,:),'U')==1
        next_g(i,:)=now_g(i,:)+[-1 0];
    elseif strcmp(directions(i,:),'D')==1
        next_g(i,:)=now_g(i,:)+[1 0];
    elseif strcmp(directions(i,:),'R')==1
        next_g(i,:)=now_g(i,:)+[0 1];
    elseif strcmp(directions(i,:),'L')==1
        next_g(i,:)=now_g(i,:)+[0 -1];
    else next_g(i,:)=now_g(i,:);
    end
end
%player位置现在 now_p
%下一步 next_p
now_p=map.player.location(end,:);


end


function [direction] = ghost_backandforth(map, k_ghost)

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

function [direction] = ghost_towardplayer(map, k_ghost)

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

function [route]=change(map,next,route,matrix_p)
%如果目的地相同，则停一步。
n_g=numel(next)/2;
location_s=map.player.location(end,:);
if strcmp(route,'U')==1
    location_n=location_s+[-1 0];
elseif strcmp(route,'D')==1
    location_n=location_s+[1 0];
elseif strcmp(route,'R')==1
    location_n=location_s+[0 1];
elseif strcmp(route,'L')==1
    location_n=location_s+[0 -1];
end
for i=1:n_g
    now=map.ghosts(i).location(end,:);
    location_n;
    next(i,:);
    if  location_n(1)==next(i,1)&&location_n(2)==next(i,2)
        route='.';
    end
    if location_s(1)==next(1)&&location_s(2)==next(2)&&location_n(1)==now(1)&&location_n(2)==now(2)
        left=matrix_p(location_s(1),location_s(2)-1);
        right=matrix_p(location_s(1),location_s(2)+1);
        up=matrix_p(location_s(1)-1,location_s(2));
        down=matrix_p(location_s(1)+1,location_s(2));
        if strcmp(route,'U')==1
            if isinf(left)==0&&left<=right
                route='L';
                return
            elseif isinf(right)==0&&left>=right
                route='R';
                return
            elseif isinf(down)
                route='D';
            else route='.';
            end
        elseif strcmp(route,'D')==1
            if isinf(left)==0&&left<=right
                route='L';
                return
            elseif isinf(right)==0&&left>=right
                route='R';
                return
            elseif isinf(up)
                route='U';
            else route='.';
            end
        elseif strcmp(route,'R')==1
            if isinf(up)==0&&up<=down
                route='U';
                return
            elseif isinf(down)==0&&up>=down
                route='D';
                return
            elseif isinf(left)
                route='L';
            else route='.';
                return
            end
        elseif strcmp(route,'L')==1
            if isinf(up)==0&&up<=down
                route='U';
                return
            elseif isinf(down)==0&&up>=down
                route='D';
                return
            elseif isinf(right)
                route='R';
            else route='.';
                return
            end
        end
        
    end
end
%如果交换位置，就横着走，如果不能横着走，就往回走。



end

function [output]=finding1(matrix_p,location,location_s,matrix_i)

mini=Inf;
storage=[];
[row,col]=size(matrix_p);
%matrix_p(location_s(1),location_s(2))=1;
matrix_p(location_s(1)+1,location_s(2))=matrix_p(location_s(1),location_s(2))+matrix_i(location_s(1)+1,location_s(2));
xia=matrix_p(location_s(1)+1,location_s(2));
matrix_p(location_s(1)-1,location_s(2))=matrix_p(location_s(1),location_s(2))+matrix_i(location_s(1)-1,location_s(2));
shang=matrix_p(location_s(1)-1,location_s(2));
matrix_p(location_s(1),location_s(2)+1)=matrix_p(location_s(1),location_s(2))+matrix_i(location_s(1),location_s(2)+1);
you=matrix_p(location_s(1),location_s(2)+1);
matrix_p(location_s(1),location_s(2)-1)=matrix_p(location_s(1),location_s(2))+matrix_i(location_s(1),location_s(2)-1);
zuo=matrix_p(location_s(1),location_s(2)-1);
xiao=min([shang,xia,zuo,you]);
ttt=0;
while true
    ttt=ttt+1;
    if location(2)-1>0
        left=matrix_p(location(1),location(2)-1);
        if left==0
            left=Inf;
        end
    end
    if location(2)+1<=col
        right=matrix_p(location(1),location(2)+1);
        if right==0
            right=Inf;
        end
    end
    if location(1)-1>0
        up=matrix_p(location(1)-1,location(2));
        if up==0
            up=Inf;
        end
    end
    if location(1)+1<=row
        down=matrix_p(location(1)+1,location(2));
        if down==0
            down=Inf;
        end
    end
    mini=min([left,right,up,down]);
    if left==mini
        location(2)=location(2)-1;
        output='R';
        storage=[storage,'R'];
    elseif right==mini
        location(2)=location(2)+1;
        output='L';
        storage=[storage,'L'];
    elseif up==mini
        location(1)=location(1)-1;
        output='D';
        storage=[storage,'D'];
    elseif down==mini
        location(1)=location(1)+1;
        output='U';
        storage=[storage,'U'];
    end
    if location(1)==location_s(1)&&location(2)==location_s(2)
        return
    end
    [row col]=size(matrix_p);
    large=max(row,col);
    index='RLUD';
    value=[you, zuo, shang, xia];
    if sum(storage=='R')>large
        random=randi([1,4],1);
        if isinf(value(random))==0
            output=index(random);
            return
            break
        end
    elseif sum(storage=='L')>large
        random=randi([1,4],1);
        if isinf(value(random))==0
            output=index(random);
            return
            break
        end
        
    elseif sum(storage=='U')>large
        random=randi([1,4],1);
        if isinf(value(random))==0
            output=index(random);
            return
            break
        end
        
    elseif sum(storage=='D')>large
        random=randi([1,4],1);
        if isinf(value(random))==0
            output=index(random);
            return
            break
        end
    end
    if ttt>=12000
        [row col]=size(matrix_p);
        large=max(row,col);
        index='RLUD';
        value=[you, zuo, shang, xia];
        random=randi([1,4],1);
        if isinf(value(random))==0
            output=index(random);
            return
            break
        end
    end
end


end


function [matrix_p,location,start]=frame2(map)
location_s=map.player.location(end,:);
matrix_i=[map.grid,map.grid,map.grid;map.grid,map.grid,map.grid;map.grid,map.grid,map.grid];
matrix_i=matrix_i+1;
[row col]=size(matrix_i);
location_s(1)=location_s(1)+row/3;
location_s(2)=location_s(2)+col/3;
start=location_s;
n_scrap=length(map.scraps);
location_e=zeros(0,2);
for i= 1:n_scrap
    location_e=[location_e;map.scraps(i).location;map.scraps(i).location+[row/3 0];map.scraps(i).location+[2/3*row 0];...
        map.scraps(i).location+[0 col/3];map.scraps(i).location+[row/3 col/3];map.scraps(i).location+[2/3*row 1/3*col];...
        map.scraps(i).location+[0 col*2/3];map.scraps(i).location+[row/3 col*2/3];map.scraps(i).location+[2/3*row 2/3*col]];
end
matrix_p=zeros(row,col);
matrix_p(location_s(1),location_s(2))=1;
matrix_p(location_s(1)+1,location_s(2))=matrix_p(location_s(1),location_s(2))+matrix_i(location_s(1)+1,location_s(2));
matrix_p(location_s(1)-1,location_s(2))=matrix_p(location_s(1),location_s(2))+matrix_i(location_s(1)-1,location_s(2));
matrix_p(location_s(1),location_s(2)+1)=matrix_p(location_s(1),location_s(2))+matrix_i(location_s(1),location_s(2)+1);
matrix_p(location_s(1),location_s(2)-1)=matrix_p(location_s(1),location_s(2))+matrix_i(location_s(1),location_s(2)-1);
[matrix_p,location]=my_diagonal3(matrix_i,matrix_p,location_s,location_e);

end
function [output,location]=my_diagonal3(matrix_i,matrix_p,location_s,location_e)
[row,col]=size(matrix_i);
n_scrap=numel(location_e)/2;
tmp=matrix_p;
for i=1:n_scrap
    if location_e(i,1)+1<=row&&location_e(i,1)-1>=1&&location_e(i,2)+1<=col&&location_e(i,2)-1>=1 %确定不在边界
        if (matrix_p(location_e(i,1),location_e(i,2)+1)~=0&& matrix_p(location_e(i,1),location_e(i,2)-1)~=0&& matrix_p(location_e(i,1)+1,location_e(i,2))~=0&& matrix_p(location_e(i,1)-1,location_e(i,2))~=0)...
                &&(isinf(matrix_p(location_e(i,1),location_e(i,2)+1)==0)||isinf(matrix_p(location_e(i,1),location_e(i,2)-1))==0||isinf( matrix_p(location_e(i,1)+1,location_e(i,2)))==0|| isinf(matrix_p(location_e(i,1)-1,location_e(i,2)))==0)
            %周围没有一个0，并且不都是Inf
            output=matrix_p;
            location=location_e(i,:);
            return
        end
        if matrix_p(location_e(i,1),location_e(i,2)+1)~=0&&matrix_p(location_e(i,1),location_e(i,2)-1)~=0&&isinf(matrix_p(location_e(i,1),location_e(i,2)+1))==0&&isinf(matrix_p(location_e(i,1),location_e(i,2)-1))==0&&isinf(matrix_p(location_e(i,1)))==0
            %左和右都不是0且不是Inf
            output=matrix_p;
            location=location_e(i,:);
            return
        end
        if matrix_p(location_e(i,1)+1,location_e(i,2))~=0&&matrix_p(location_e(i,1)-1,location_e(i,2))~=0&&isinf(matrix_p(location_e(i,1)+1,location_e(i,2)))==0&&isinf(matrix_p(location_e(i,1)+1,location_e(i,2)))==0&&isinf(matrix_p(location_e(i,1)))==0
            %上和下都不是0且不是Inf
            output=matrix_p;
            location=location_e(i,:);
            return
        end
    end
end

%如果终点周围没有一个0，并且至少一个不是Inf，则return。如果终点周围，上下/左右都是数字，则return


count=1;
while count~=0
    count=0;
    for r= 2:row-1
        for c=2:col-1
            left=matrix_p(r,c-1);
            right=matrix_p(r,c+1);
            up=matrix_p(r-1,c);
            down=matrix_p(r+1,c);
            %用（r,c）的p和i对比，如果p是inf，但i并不是，看这个点周围有没有不是0也不是inf的数，有，则使用i(r,c)+边上那个数。
            if isinf(matrix_p(r,c))==1&&isinf(matrix_i(r,c))==0 %如果
                if isinf(up)==0&&up~=0 %如果p上面不是inf也不是0
                    matrix_p(r,c)=matrix_i(r,c)+up;%就用上面加该点的i
                elseif isinf(down)==0&&down~=0
                    matrix_p(r,c)=matrix_i(r,c)+down;
                elseif isinf(right)==0&&right~=0
                    matrix_p(r,c)=matrix_i(r,c)+right;
                elseif isinf(left)==0&&left~=0
                    matrix_p(r,c)=matrix_i(r,c)+left;
                end
            end
            %如果该点是0
            if matrix_p(r,c)==0
                %右下
                if right~=0&&down~=0 %如果右和下都不是0
                    if isinf(right)==0&&isinf(down)==0 %如果右和下都不是inf
                        sum1=right+matrix_i(r,c);
                        sum2=down+matrix_i(r,c);
                        sum=min(sum1,sum2);%挑小的
                        count=count+1;
                    elseif isinf(right)==1&&isinf(down)~=1%如果右是inf但下是数
                        sum=down+matrix_i(r,c); %用下面的
                        count=count+1;
                    elseif isinf(down)==1&&isinf(right)~=1 %如果下面是inf但右面是数
                        sum=right+matrix_i(r,c);%用右边的
                        count=count+1;
                    else sum=Inf; %另外的情况即右和下都是inf
                    end
                    matrix_p(r,c)=sum;
                end
                %左下
                if left~=0&&down~=0
                    if isinf(left)==0&&isinf(down)==0
                        sum1=left+matrix_i(r,c);
                        sum2=down+matrix_i(r,c);
                        sum=min(sum1,sum2);
                        count=count+1;
                    elseif isinf(left)==1&&isinf(down)~=1
                        sum=down+matrix_i(r,c);
                        count=count+1;
                    elseif isinf(down)==1&&isinf(left)~=1
                        sum=left+matrix_i(r,c);
                        count=count+1;
                    else sum=Inf;
                    end
                    matrix_p(r,c)=sum;
                end
                %右上
                
                if right~=0&&up~=0
                    if isinf(right)==0&&isinf(up)==0
                        sum1=right+matrix_i(r,c);
                        sum2=up+matrix_i(r,c);
                        sum=min(sum1,sum2);
                        count=count+1;
                    elseif isinf(right)==1&&isinf(up)~=1
                        sum=up+matrix_i(r,c);
                        count=count+1;
                    elseif isinf(up)==1&&isinf(right)~=1
                        sum=right+matrix_i(r,c);
                        count=count+1;
                    else sum=Inf;
                    end
                    matrix_p(r,c)=sum;
                end
                %左上
                if left~=0&&up~=0
                    if isinf(left)==0&&isinf(up)==0
                        sum1=left+matrix_i(r,c);
                        sum2=up+matrix_i(r,c);
                        sum=min(sum1,sum2);
                        count=count+1;
                    elseif isinf(left)==1&&isinf(up)~=1
                        sum=up+matrix_i(r,c);
                        count=count+1;
                    elseif isinf(up)==1&&isinf(left)~=1
                        sum=left+matrix_i(r,c);
                        count=count+1;
                    else sum=Inf;
                    end
                    matrix_p(r,c)=sum;
                end
            end
            
        end
    end
end

if all(all(tmp==matrix_p==1)==1)
    output=matrix_p;
    location=location;
    return
end

for i=1:n_scrap
    if location_e(i,1)+1<=row&&location_e(i,1)-1>=1&&location_e(i,2)+1<=col&&location_e(i,2)-1>=1 %如果不是边界
        if isinf(matrix_p(location_e(i,1),location_e(i,2)+1))&&isinf(matrix_p(location_e(i,1),location_e(i,2)-1))...
                &&isinf( matrix_p(location_e(i,1)+1,location_e(i,2)))&& isinf(matrix_p(location_e(i,1)-1,location_e(i,2)))
            %如果四面全都是Inf
            [matrix_p,location]=square3(matrix_i,matrix_p,location_s,location_e);
            output=matrix_p;
        elseif (matrix_p(location_e(i,1),location_e(i,2)+1)==0|| matrix_p(location_e(i,1),location_e(i,2)-1)==0|| ...
                matrix_p(location_e(i,1)+1,location_e(i,2))==0|| matrix_p(location_e(i,1)-1,location_e(i,2))==0)
            %如果四面至少一个是0.
            [matrix_p,location]=square3(matrix_i,matrix_p,location_s,location_e);
            output=matrix_p;
        else
            output=matrix_p;
            location=location_e(i,:);
        end
    end
end
end

function [output,location]=square3(matrix_i,matrix_p,location_s,location_e)
[row col]=size(matrix_i);
n_scrap=numel(location_e)/2;
for i=1:n_scrap
    if location_e(i,1)+1<=row&&location_e(i,1)-1>=1&&location_e(i,2)+1<=col&&location_e(i,2)-1>=1
        if (matrix_p(location_e(i,1),location_e(i,2)+1)~=0&& matrix_p(location_e(i,1),location_e(i,2)-1)~=0&& matrix_p(location_e(i,1)+1,location_e(i,2))~=0&& matrix_p(location_e(i,1)-1,location_e(i,2))~=0)...
                &&(isinf(matrix_p(location_e(i,1),location_e(i,2)+1)==0)||isinf(matrix_p(location_e(i,1),location_e(i,2)-1))==0||isinf( matrix_p(location_e(i,1)+1,location_e(i,2)))==0|| isinf(matrix_p(location_e(i,1)-1,location_e(i,2)))==0)
            output=matrix_p;
            location=location_e(i,:);
            return
            
        end
        if matrix_p(location_e(i,1),location_e(i,2)+1)~=0&&matrix_p(location_e(i,1),location_e(i,2)-1)~=0&&isinf(matrix_p(location_e(i,1),location_e(i,2)+1))==0&&isinf(matrix_p(location_e(i,1),location_e(i,2)-1))==0&&isinf(matrix_p(location_e(i,1)))==0
            %左和右都不是0且不是Inf
            output=matrix_p;
            location=location_e(i,:);
            return
        end
        if matrix_p(location_e(i,1)+1,location_e(i,2))~=0&&matrix_p(location_e(i,1)-1,location_e(i,2))~=0&&isinf(matrix_p(location_e(i,1)+1,location_e(i,2)))==0&&isinf(matrix_p(location_e(i,1)+1,location_e(i,2)))==0&&isinf(matrix_p(location_e(i,1)))==0
            %上和下都不是0且不是Inf
            output=matrix_p;
            location=location_e(i,:);
            return
        end
    end
end
for i=1:row
    for j=1:col
        if i==1||j==1||i==row||j==col
            continue
        elseif matrix_p(i,j)~=0&&matrix_p(i-1,j)==0&&matrix_p(i,j-1)==0&&matrix_p(i+1,j)~=0&&matrix_p(i,j+1)~=0
            row_min=i;
            col_min=j;
        elseif matrix_p(i,j)~=0&&matrix_p(i-1,j)~=0&&matrix_p(i,j-1)~=0&&matrix_p(i+1,j)==0&&matrix_p(i,j+1)==0
            row_max=i;
            col_max=j;
        end
    end
end
tic=1;
for i=row_min:row_max
    for j=col_min:col_max
        if i==row_min||i==row_max||j==col_min||j==col_max
            if i==row_min&&matrix_i(i-1,j)~=Inf
                storage(tic)=matrix_p(i,j);
                tic=tic+1;
            elseif i==row_max&&matrix_i(i+1,j)~=Inf
                storage(tic)=matrix_p(i,j);
                tic=tic+1;
            elseif j==col_min&&matrix_i(i,j-1)~=Inf
                storage(tic)=matrix_p(i,j);
                tic=tic+1;
            elseif j==col_max&&matrix_i(i,j+1)~=Inf
                storage(tic)=matrix_p(i,j);
                tic=tic+1;
            end
        end
    end
end
minimum=min(storage);
[r,c]=size(matrix_i);
r_s=Inf;
c_s=Inf;
for i=1:r
    for j=1:c
        if matrix_p(i,j)==minimum&&(i==row_min)&&matrix_i(i-1,j)~=Inf%||i==row_max||j==col_min||j==col_max)
            r_s=i;
            c_s=j;
            break
        elseif matrix_p(i,j)==minimum&&(i==row_max)&&matrix_i(i+1,j)~=Inf%||i==row_max||j==col_min||j==col_max)
            r_s=i;
            c_s=j;
            break
        elseif matrix_p(i,j)==minimum&&(j==col_min)&&matrix_i(i,j-1)~=Inf%||i==row_max||j==col_min||j==col_max)
            r_s=i;
            c_s=j;
            break
        elseif matrix_p(i,j)==minimum&&(j==col_max)&&matrix_i(i,j+1)~=Inf%||i==row_max||j==col_min||j==col_max)
            r_s=i;
            c_s=j;
            break
        end
    end
    if r_s==i&&c_s==j
        break
    end
end
if c_s==col_min
    if ~isinf(matrix_i(r_s,c_s-1))
        matrix_p(r_s,c_s-1)=matrix_p(r_s,c_s)+matrix_i(r_s,c_s-1);
    end
end
if c_s==col_max
    if ~isinf(matrix_i(r_s,c_s+1))
        matrix_p(r_s,c_s+1)=matrix_p(r_s,c_s)+matrix_i(r_s,c_s+1);
    end
end
if r_s==row_min
    if ~isinf(matrix_i(r_s-1,c_s))
        matrix_p(r_s-1,c_s)=matrix_p(r_s,c_s)+matrix_i(r_s-1,c_s);
    end
end
if r_s==row_max
    if ~isinf(matrix_i(r_s+1,c_s))
        matrix_p(r_s+1,c_s)=matrix_p(r_s,c_s)+matrix_i(r_s+1,c_s);
    end
end
output=matrix_p;

store=[sum(sum(matrix_p(row_min-1,:))),sum(sum(matrix_p(row_max+1,:))),sum(sum(matrix_p(:,col_min-1))),sum(sum(matrix_p(:,col_max+1)))];
sssum=sum(sum(store));
if sssum==0
    for i=row_min:row_max
        for j=col_min:col_max
            if i==row_min||i==row_max||j==col_min||j==col_max
                if isinf(matrix_p(i,j))==0
                    if i==row_min
                        if isinf(matrix_i(i-1,j))==0
                            matrix_p(i-1,j)=matrix_i(i-1,j);
                        end
                    elseif i==row_max
                        if isinf(matrix_i(i+1,j))==0
                            matrix_p(i+1,j)=matrix_i(i+1,j);
                        end
                    elseif j==col_min
                        if isinf(matrix_i(i,j-1))==0
                            matrix_p(i,j-1)=matrix_i(i,j-1);
                        end
                    elseif j==col_max
                        if isinf(matrix_i(i,j+1))==0
                            matrix_p(i,j+1)=matrix_i(i,j+1);
                        end
                    end
                end
            end
        end
    end
end

for i=1:n_scrap
    if location_e(i,1)+1<=row&&location_e(i,1)-1>=1&&location_e(i,2)+1<=col&&location_e(i,2)-1>=1
        if matrix_p(location_e(i,1),location_e(i,2)+1)==0|| matrix_p(location_e(i,1),location_e(i,2)-1)==0|| ...
                matrix_p(location_e(i,1)+1,location_e(i,2))==0|| matrix_p(location_e(i,1)-1,location_e(i,2))==0
            [matrix_p,location]=my_diagonal3(matrix_i,matrix_p,location_s,location_e);
            output=matrix_p;
        elseif isinf(matrix_p(location_e(i,1),location_e(i,2)+1))&&isinf(matrix_p(location_e(i,1),location_e(i,2)-1))...
                &&isinf( matrix_p(location_e(i,1)+1,location_e(i,2)))&& isinf(matrix_p(location_e(i,1)-1,location_e(i,2)))
            [matrix_p,location]=my_diagonal3(matrix_i,matrix_p,location_s,location_e);
            output=matrix_p;
        else
            output=matrix_p;
            location=location_e(i,:);
        end
    end
end
end






function [next]=adjust3(map)
n_g=length(map.ghosts);
directions=[];
next=zeros(0,2);
now=zeros(0,2);
last=zeros(0,2);
type=[];
for i=1:n_g
    now=[now;map.ghosts(i).location(end,:)];
    type=[type;map.ghosts(i).type];
    if strcmp(type(i,:),'backandforth')==1
        direction=e7pl_ghost_backandforth(map,i);
        directions=[directions;direction];
    end
    if strcmp(type(i,:),'towardplayer')==1
        direction=e7pl_ghost_towardplayer(map,i);
        directions=[directions;direction];
    end
    if strcmp(directions(i),'D')
        next(i,:)=[now(i,1)+1,now(i,2)];
    elseif strcmp(directions(i),'U')
        next(i,:)=[now(i,1)-1,now(i,2)];
    elseif strcmp(directions(i),'R')
        next(i,:)=[now(i,1),now(i,2)-1];
    elseif strcmp(directions(i),'U')
        next(i,:)=[now(i,1),now(i,2)+1];
    elseif strcmp(directions(i),'.')
        next(i,:)=now;
    end
    
end
end

