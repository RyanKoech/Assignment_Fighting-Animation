close all

%game_menu()

game('Pushkinskaya', 'Max', 'Mike')

function game_menu()
    global map player1 player2
    menu_figure = figure();
    menu_figure.Name = 'FEFU FIGHTING SCHOOL - startup menu';
    menu_figure.MenuBar = 'none';
    menu_figure.DockControls = 'off';
    imshow('Menu_background.png');
    hold on
    
    [image_1, ~, alpha_1] = imread('Not_selected.png');
    p1 = imshow(image_1);
    p1.AlphaData = alpha_1;
    image_2 = fliplr(image_1);
    alpha_2 = fliplr(alpha_1);
    p2 = imshow(image_2);
    p2.AlphaData = alpha_2;
    
    p1.XData = p1.XData + 90;
    p1.YData = p1.YData + 130;
    p2.XData = p2.XData + 425;
    p2.YData = p2.YData + 130;
    
    uicontrol('Style','pushbutton', 'Units', 'normalized','Position',[0.4 0.22 0.2 0.1],'String','START GAME','Callback',@start_game);
    
    p1_list = uicontrol('Style','popupmenu', 'Units', 'normalized','Position',[0.18 -0.2 0.2 0.5],'Callback', @set_p1);
    p2_list = uicontrol('Style','popupmenu', 'Units', 'normalized','Position',[0.62 -0.2 0.2 0.5],'Callback', @set_p2);
    map_list = uicontrol('Style','popupmenu', 'Units', 'normalized','Position',[0.4 0.2 0.2 0.5],'Callback', @set_map);
    
    p1_list.String = {'##select character##', 'Mike', 'Elena', 'Boris', 'Max', 'Artem', 'Nikita'};
    p2_list.String = {'##select character##', 'Mike', 'Elena', 'Boris', 'Max', 'Artem', 'Nikita'};
    map_list.String = {'##select map##', 'A_entrance_1', 'A_entrance_2', 'Pushkinskaya'};
    
    function start_game(~, ~)
        close all
        game(map, player1, player2);
    end
    function set_p1(~, ~)
        val = p1_list.Value;
        str = p1_list.String;
        player1 = str{val};
        [y,Fs] = audioread([player1, '_intro.wav']);
        [image, ~, alpha] = imread([player1, '_standing.png']);
        sound(y, Fs)
        p1.CData = image;
        p1.AlphaData = alpha;
    end
    function set_p2(~, ~)
        val = p2_list.Value;
        str = p2_list.String;
        player2 = str{val};
        [y,Fs] = audioread([player2, '_intro.wav']);
        [image, ~, alpha] = imread([player2, '_standing.png']);
        sound(y, Fs)
        image = fliplr(image);
        alpha = fliplr(alpha);
        p2.CData = image;
        p2.AlphaData = alpha;
    end
    function set_map(~, ~)
        val = map_list.Value;
        str = map_list.String;
        map = str{val};
    end
end

function game(game_map, p1_character, p2_character)
    %########FEFU FIGHTING SCHOOL########
    %Controls:
    %PLAYER 1:
    %---left:  A
    %---right: D
    %---jump:  W
    %---block: S
    %---punch: E
    %---kick:  R
    %PLAYER 2:
    %---left:  J
    %---right: L
    %---jump:  I
    %---block: K
    %---punch: O
    %---kick:  P
    
    %####SETUP####
    root_figure = figure('KeyPressFcn',@Key_Down,'KeyReleaseFcn',@Key_Release);
    root_figure.Name = 'FEFU FIGHTING SCHOOL - v0.6';
    root_figure.MenuBar = 'none';
    root_figure.DockControls = 'off';
    root_figure.WindowState = 'fullscreen'; %FULL SCREEN MODE
    global p1_left p1_right p1_up p1_punch p1_kick p2_left p2_right p2_up p2_punch p2_kick p1_block p2_block
    global level_bg
    global p1_jump_flag p1_jump_counter p2_jump_flag p2_jump_counter
    global p1_skin p1_pose p1_direction p2_skin p2_pose p2_direction
    global p1_walking p2_walking
    global level_length level_height
    global player_length player_height
    global p1_walking_step p2_walking_step p1_punch_step p2_punch_step p1_kick_step p2_kick_step
    global p1_punch_flag p2_punch_flag p1_kick_flag p2_kick_flag
    global p1_health p2_health
    global punch_distance kick_distance
    global punch_damage kick_damage
    global beat_animation_step
    global end_flag
    global p1_cue_y p1_cue_Fs p1_win_y p1_win_Fs p2_cue_y p2_cue_Fs p2_win_y p2_win_Fs
    global p1_cue_health p2_cue_health p1_cue_flag p2_cue_flag
    
    %----LOADING SOUND----
    %COMMON
    [y_woosh,Fs_woosh] = audioread('woosh.wav');
    [y_punch,Fs_punch] = audioread('punch.wav');
    
    setSound(p1_character, p2_character);
    
    %----LEVEL SETTING----
    %level_heigth and level_length are dimensions of 
    %level background picture
    level_length = 384;
    level_height = 216;
    setLevel(game_map);
    imshow(level_bg);
    hold on
    
    %----PLAYER SETTING----
    player_length = 102;
    player_height = 138;
    
    player_step = 4;
    jump_height = 20;
    
    punch_damage = 5;
    kick_damage = 5;
    
    punch_distance = -55;
    kick_distance = -50;
    
    beat_animation_step = 10;
    
    p1_health = 100; %100 is maximum
    p2_health = 100;
    
    %----INTERFACE SETTING----
    rectangle('Position', [20 10 200 20], 'FaceColor', 'k', 'EdgeColor', 'k', 'LineWidth', 3); %p1 health bar background
    rectangle('Position', [(level_length - 220) 10 200 20], 'FaceColor', 'k', 'EdgeColor', 'k', 'LineWidth', 3);%p2 health bar background
    
    p1_health_bar = rectangle('Position', [20 10 (2 * p1_health) 30], 'FaceColor', 'r', 'EdgeColor', 'none');
    p2_health_bar = rectangle('Position', [(level_length - (2 * p2_health + 20)) 10 (2 * p2_health) 30], 'FaceColor', 'r', 'EdgeColor', 'none');
    
    %Technical values
    p1_cue_health = randi(100);
    p2_cue_health = randi(100);
    p1_cue_flag = 1;
    p2_cue_flag = 1;
    
    end_flag = 0;
    
    p1_jump_flag = 0;
    p2_jump_flag = 0;
    p1_punch_flag = 0;
    p2_punch_flag = 0;
    p1_kick_flag = 0;
    p2_kick_flag = 0;
    
    p1_jump_counter = 1;
    p2_jump_counter = 1;
    
    p1_walking = 0;
    p2_walking = 0;
    
    p1_walking_step = 1;
    p2_walking_step = 1;
    p1_punch_step = 1;
    p2_punch_step = 1;
    p1_kick_step = 1;
    p2_kick_step = 1;
    
    %----IMAGE INITIALIZATION----
    [image, ~, alpha] = imread('Mike_standing.png'); %common
    p1 = imshow(image);
    p1.AlphaData = alpha;
    
    p2 = imshow(image);
    p2.AlphaData = alpha;
    
    %----SKIN SETTINGS----
    %PLAYER 1
    p1_skin = p1_character;
    p1_pose = 'standing';
    p1_direction = 'right';
    
    %PLAYER 2
    p2_skin = p2_character;
    p2_pose = 'standing';
    p2_direction = 'left';
    
    %Call skin changing function
    setCharacter('p1', p1_skin, p1_pose, p1_direction);
    setCharacter('p2', p2_skin, p2_pose, p2_direction);
    
    %----FLOOR POSITION----
    %Must be the same for all players
    p1.YData = level_height - player_height - 30;
    p2.YData = level_height - player_height - 30;
    floor_y1 = p1.YData;
    floor_y2 = p2.YData;
    
    %----START POSITION----
    p1.XData = p1.XData + 10;
    p2.XData = p2.XData + level_length - player_length - 10;
    
    
    while 1
        %####LOOP####
        
        if end_flag == 1
            break
        end
        
        %----MOVEMENT----
        x1 = p1.XData;
        x2 = p2.XData;
        
        %PLAYER 1
        if p1_block == 0
            if p1_left == 1
                p1.XData = p1.XData - player_step;
                p1_direction = 'left';
                p1_walking = 1;
            end
            if p1_right == 1
                p1.XData = p1.XData + player_step;
                p1_direction = 'right';
                p1_walking = 1;
            end
            if p1_up == 1
                p1_jump_flag = 1;
            end
            if p1_punch == 1
                p1_punch_flag = 1;
            end
            if p1_kick == 1
                p1_kick_flag = 1;
            end
        end
        
        if isequal(p1_left, 0) && isequal(p1_right, 0)
            p1_walking = 0;
        end
        
        %PLAYER 2
        if p2_block == 0
            if p2_left == 1
                p2.XData = p2.XData - player_step;
                p2_direction = 'left';
                p2_walking = 1;
            end
            if p2_right == 1
                p2.XData = p2.XData + player_step;
                p2_direction = 'right';
                p2_walking = 1;
            end
            if p2_up == 1
                p2_jump_flag = 1;
            end
            if p2_punch == 1
                p2_punch_flag = 1;
            end
            if p2_kick == 1
                p2_kick_flag = 1;
            end
        end
        
        if isequal(p2_left, 0) && isequal(p2_right, 0)
            p2_walking = 0;
        end
        
        %----POSE CHANGING----
        if p1_block == 1
            p1_pose = 'block';
        elseif p1_walking == 1
            if p1_walking_step > 12
                p1_pose = 'walking_2';
                p1_walking_step = p1_walking_step + 1;
            else
                p1_pose = 'walking_1';
                p1_walking_step = p1_walking_step + 1;
            end
            if p1_walking_step > 24
                p1_walking_step = 1;
            end
        else
            p1_pose = 'standing';
        end
        
        if p2_block == 1
            p2_pose = 'block';
        elseif p2_walking == 1
            if p2_walking_step > 12
                p2_pose = 'walking_2';
                p2_walking_step = p2_walking_step + 1;
            else
                p2_pose = 'walking_1';
                p2_walking_step = p2_walking_step + 1;
            end
            if p2_walking_step > 24
                p2_walking_step = 1;
            end
        else
            p2_pose = 'standing';
        end
        
        %----BATTLE ANIMATIONS----
        if p1_punch_flag == 1
            if p1_punch_step == 1
                beatHim('p1', 'punch');
            end
            if p1_punch_step < beat_animation_step
                p1_pose = 'punch_1';
            elseif  p1_punch_step < beat_animation_step * 2
                p1_pose = 'punch_2';
            elseif  p1_punch_step < beat_animation_step * 3
                p1_pose = 'punch_1';
            elseif p1_punch_step >= beat_animation_step * 4
                p1_pose = 'standing';
                p1_punch_step = 0;
                p1_punch_flag = 0;
            end
            p1_punch_step = p1_punch_step + 1;
        end
        if p2_punch_flag == 1
            if p2_punch_step == 1
                beatHim('p2', 'punch');
            end
            if p2_punch_step < beat_animation_step
                p2_pose = 'punch_1';
            elseif  p2_punch_step < beat_animation_step * 2
                p2_pose = 'punch_2';
            elseif  p2_punch_step < beat_animation_step * 3
                p2_pose = 'punch_1';
            elseif p2_punch_step >= beat_animation_step * 4
                p2_pose = 'standing';
                p2_punch_step = 0;
                p2_punch_flag = 0;
            end
            p2_punch_step = p2_punch_step + 1;
        end
        if p1_kick_flag == 1
            if p1_kick_step == 1
                beatHim('p1', 'kick');
            end
            if p1_kick_step < beat_animation_step
                p1_pose = 'kick_1';
            elseif  p1_kick_step < beat_animation_step * 2
                p1_pose = 'kick_2';
            elseif  p1_kick_step < beat_animation_step * 3
                p1_pose = 'kick_1';
            elseif p1_kick_step >= beat_animation_step * 4
                p1_pose = 'standing';
                p1_kick_step = 0;
                p1_kick_flag = 0;
            end
            p1_kick_step = p1_kick_step + 1;
        end
        if p2_kick_flag == 1
            if p2_kick_step == 1
                beatHim('p2', 'kick');
            end
            if p2_kick_step < beat_animation_step
                p2_pose = 'kick_1';
            elseif  p2_kick_step < beat_animation_step * 2
                p2_pose = 'kick_2';
            elseif  p2_kick_step < beat_animation_step * 3
                p2_pose = 'kick_1';
            elseif p2_kick_step >= beat_animation_step * 4
                p2_pose = 'standing';
                p2_kick_step = 0;
                p2_kick_flag = 0;
            end
            p2_kick_step = p2_kick_step + 1;
        end
        
        %----BORDERS----
        if p1.XData(2) < player_length * 0.7 || p1.XData(2) > level_length + player_length * 0.3
            p1.XData = x1;
        end
        if p2.XData(2) < player_length * 0.7 || p2.XData(2) > level_length + player_length * 0.3
            p2.XData = x2;
        end
        
        %----JUMP----
        if p1_jump_flag == 1
            if p1_jump_counter <= jump_height
                p1.YData = p1.YData - 1;
            elseif p1.YData(1) < floor_y1
                p1.YData = p1.YData + 1;
            end
            if p1_jump_counter == jump_height * 2
                p1_jump_flag = 0;
                p1_jump_counter = 1;
            end
            p1_jump_counter = p1_jump_counter + 1;
        end
        
        if p2_jump_flag == 1
            if p2_jump_counter <= jump_height
                p2.YData = p2.YData - 1;
            elseif p2.YData(1) < floor_y2
                p2.YData = p2.YData + 1;
            end
            if p2_jump_counter == jump_height * 2
                p2_jump_flag = 0;
                p2_jump_counter = 1;
            end
            p2_jump_counter = p2_jump_counter + 1;
        end
        
        %----Phrases----
        if p1_health < p1_cue_health && p1_cue_flag == 1
            sound(p1_cue_y, p1_cue_Fs)
            p1_cue_flag = 0;
        end
        if p2_health < p2_cue_health && p2_cue_flag == 1
            sound(p2_cue_y, p2_cue_Fs)
            p2_cue_flag = 0;
        end
        
        %----WHO WIN----
        if p1_health == 0
            p2_pose = 'win';
            sound(p2_win_y, p2_win_Fs);
            end_flag = 1;
        end
        if p2_health == 0
            p1_pose = 'win';
            sound(p1_win_y, p1_win_Fs);
            end_flag = 1;
        end
        
        setCharacter('p1', p1_skin, p1_pose, p1_direction);
        setCharacter('p2', p2_skin, p2_pose, p2_direction);
        
        %----HEALTH BARS----
        set(p1_health_bar, 'Position', [20 10 (2 * p1_health) 20]);
        set(p2_health_bar, 'Position', [(level_length - (2 * p2_health + 20)) 10 (2 * p2_health) 20]);
        
        %DRAWING
        drawnow
    end
    
    %####FUNCTIONS####
    %This function damages enemy
    function beatHim(player, beat_type)
        switch beat_type
            case 'punch'
                beat_distance = punch_distance;
                damage_step = punch_damage;
            case 'kick'
                beat_distance = kick_distance;
                damage_step = kick_damage;
        end
        switch player
            case 'p1'
                if isequal(p1_direction, 'right') && p1.XData(2) < p2.XData(2) && p1.XData(2) + player_length + beat_distance >= p2.XData(2)
                    if p2_health - damage_step > 0
                        sound(y_punch, Fs_punch);
                        if p2_block == 0
                            p2_health = p2_health - damage_step;
                        else
                            p2_health = p2_health - damage_step * 0.5;
                        end
                    else
                        p2_health = 0;
                    end
                elseif isequal(p1_direction, 'left') && p1.XData(2) > p2.XData(2) && p1.XData(2) - player_length - beat_distance <= p2.XData(2)
                    if p2_health - damage_step > 0
                        sound(y_punch, Fs_punch);
                        if p2_block == 0
                            p2_health = p2_health - damage_step;
                        else
                            p2_health = p2_health - damage_step * 0.5;
                        end
                    else
                        p2_health = 0;
                    end
                else
                    sound(y_woosh, Fs_woosh);
                end
            case 'p2'
                if isequal(p2_direction, 'right') && p2.XData(2) < p1.XData(2) && p2.XData(2) + player_length + beat_distance >= p1.XData(2)
                    if p1_health - damage_step > 0
                        sound(y_punch, Fs_punch);
                        if p1_block == 0
                            p1_health = p1_health - damage_step;
                        else
                            p1_health = p1_health - damage_step * 0.5;
                        end
                    else
                        p1_health = 0;
                    end
                elseif isequal(p2_direction, 'left') && p2.XData(2) > p1.XData(2) && p2.XData(2) - player_length - beat_distance <= p1.XData(2)
                    if p1_health - damage_step > 0
                        sound(y_punch, Fs_punch);
                        if p1_block == 0
                            p1_health = p1_health - damage_step;
                        else
                            p1_health = p1_health - damage_step * 0.5;
                        end
                    else
                        p1_health = 0;
                    end
                else
                    sound(y_woosh, Fs_woosh);
                end
        end
    end
    
    %This function changes player skin
    function [image, alpha] = setCharacter(player, name, pose, direction)
        switch name
            case 'Mike'
                switch pose
                    case 'standing'
                        [image, ~, alpha] = imread('Mike_standing.png');
                end
            case 'Elena'
                switch pose
                    case 'standing'
                        [image, ~, alpha] = imread('Elena_standing.png');
                end
            case 'Boris'
                switch pose
                    case 'standing'
                        [image, ~, alpha] = imread('Boris_standing.png');
                end
            case 'Max'
                switch pose
                    case 'standing'
                        [image, ~, alpha] = imread('Max_standing.png');
                end
            case 'Artem'
                switch pose
                    case 'standing'
                        [image, ~, alpha] = imread('Artem_standing.png');
                end
            case 'Nikita'
                switch pose
                    case 'standing'
                        [image, ~, alpha] = imread('Nikita_standing.png');
                end
        end
        switch pose
            case 'standing'
                [image, ~, alpha] = imread([name '_standing.png']);
            case 'walking_1'
                [image, ~, alpha] = imread([name '_walking_1.png']);
            case 'walking_2'
                [image, ~, alpha] = imread([name '_walking_2.png']);
            case 'punch_1'
                [image, ~, alpha] = imread([name '_punch_1.png']);
            case 'punch_2'
                [image, ~, alpha] = imread([name '_punch_2.png']);
            case 'kick_1'
                [image, ~, alpha] = imread([name '_kick_1.png']);
            case 'kick_2'
                [image, ~, alpha] = imread([name '_kick_2.png']);
            case 'block'
                [image, ~, alpha] = imread([name '_block.png']);
            case 'win'
                [image, ~, alpha] = imread([name '_win.png']);
        end
        switch direction
            case 'right'
                %just send picture
            case 'left'
                %flip image and alpha
                image = fliplr(image);
                alpha = fliplr(alpha);
        end
        switch player
            case 'p1'
                p1.CData = image;
                p1.AlphaData = alpha;
            case 'p2'
                %p2 = imshow(image);
                p2.CData = image;
                p2.AlphaData = alpha;
        end
    end

    %This funchion changes game field (background)
    function setLevel(location)
        level_bg = imread([location, '.png']);
        level_length = 618;
        level_height = 348;
    end

    %This function is setting sounds of different characters
    function setSound(ch_1, ch_2)
        [p1_cue_y,p1_cue_Fs] = audioread([ch_1, '_cue.wav']);
        [p1_win_y,p1_win_Fs] = audioread([ch_1, '_win.wav']);
        
        [p2_cue_y,p2_cue_Fs] = audioread([ch_2, '_cue.wav']);
        [p2_win_y,p2_win_Fs] = audioread([ch_2, '_win.wav']);
    end

    %Next pair of functions are setting keyboard keys
    function Key_Down(~,event)
      switch event.Key
          %----PLAYER 1 KEYS----
          case 'w'
              p1_up = logical(true);
          case 'a'
              p1_left = logical(true);
          case 'd'
              p1_right = logical(true);
          case 'e'
              p1_punch = logical(true);
          case 'r'
              p1_kick = logical(true);
          case 's'
              p1_block = logical(true);
          %----PLAYER 2 KEYS----
          case 'i'
              p2_up = logical(true);
          case 'j'
              p2_left = logical(true);
          case 'l'
              p2_right = logical(true);
          case 'o'
              p2_punch = logical(true);
          case 'p'
              p2_kick = logical(true);
          case 'k'
              p2_block = logical(true);
      end
       
    end

    function Key_Release(~,event)
        switch event.Key
          %----PLAYER 1 KEYS----
          case 'w'
              p1_up = logical(false);
          case 'a'
              p1_left = logical(false);
          case 'd'
              p1_right = logical(false);
          case 'e'
              p1_punch = logical(false);
          case 'r'
              p1_kick = logical(false);
          case 's'
              p1_block = logical(false);
          %----PLAYER 2 KEYS----
          case 'i'
              p2_up = logical(false);
          case 'j'
              p2_left = logical(false);
          case 'l'
              p2_right = logical(false);
          case 'o'
              p2_punch = logical(false);
          case 'p'
              p2_kick = logical(false);
          case 'k'
              p2_block = logical(false);
        end
    end
    if end_flag == 1
        pause(5);
        imshow('Logo.png')
        pause(2);
    end
end