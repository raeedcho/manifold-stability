%% load for Juan

filedates = {'20151117', '20151120', '20151201', '20151204', '20151211'};
% filedates = {'20170917'};

%% loop over dates
for dateidx = 1:length(filedates)
    %% Set up
    meta.lab=6;
    meta.ranBy='Raeed';
    meta.monkey='Chips';
    % meta.date='20171128';
    meta.date = filedates{dateidx};
    meta.task='CO'; % for the loading of cds
    meta.taskAlias={'COactpas_001'}; % for the filename (cell array list for files to load and save)
    meta.array='LeftS1Area2'; % for the loading of cds
    meta.arrayAlias='area2'; % for the filename
    meta.project='ForceKin'; % for the folder in data-preproc
    meta.hyperfolder=fullfile('C:\Users\rhc307\Projects\limblab'); % folder for both data_preproc and data_td
    meta.superfolder=fullfile(meta.hyperfolder,'data-preproc',meta.project,meta.monkey); % folder for data dump
    meta.folder=fullfile(meta.superfolder,meta.date); % compose subfolder and superfolder

    meta.neuralPrefix = [meta.monkey '_' meta.date '_' meta.arrayAlias];

    if strcmp(meta.monkey,'Chips')
        meta.mapfile='C:\Users\rhc307\Projects\limblab\data-preproc\Meta\Mapfiles\Chips\left_S1\SN 6251-001455.cmp';
    elseif strcmp(meta.monkey,'Han')
        meta.mapfile='C:\Users\Raeed\Projects\limblab\data-preproc\Meta\Mapfiles\Han\left_S1\SN 6251-001459.cmp';
%         altMeta = meta;
%         altMeta.array='';
%         altMeta.arrayAlias='EMGextra';
%         altMeta.neuralPrefix = [altMeta.monkey '_' altMeta.date '_' altMeta.arrayAlias];
    %     altMeta.mapfile=???;
    elseif strcmp(meta.monkey,'Lando')
        meta.mapfile='C:\Users\rhc307\Projects\limblab\data-preproc\Meta\Mapfiles\Lando\left_S1\SN 6251-001701.cmp';
        altMeta = meta;
        altMeta.array='RightCuneate';
        altMeta.arrayAlias='cuneate';
        altMeta.neuralPrefix = [altMeta.monkey '_' altMeta.date '_' altMeta.arrayAlias];
        altMeta.mapfile='C:\Users\rhc307\Projects\limblab\data-preproc\Meta\Mapfiles\Lando\right_cuneate\SN 1025-001745.cmp';
    end
    
    %% Move data into subfolder
    if ~exist(meta.folder,'dir')
        mkdir(meta.folder)
        movefile(fullfile(meta.superfolder,[meta.monkey '_' meta.date '*']),meta.folder)
    end

    %% Set up folder structure
    if ~exist(fullfile(meta.folder,'preCDS'),'dir')
        mkdir(fullfile(meta.folder,'preCDS'))
        movefile(fullfile(meta.folder,[meta.neuralPrefix '*']),fullfile(meta.folder,'preCDS'))
        if exist('altMeta','var')
            movefile(fullfile(meta.folder,[altMeta.neuralPrefix '*']),fullfile(meta.folder,'preCDS'))
        end
    end
    if ~exist(fullfile(meta.folder,'preCDS','merging'),'dir')
        mkdir(fullfile(meta.folder,'preCDS','merging'))
        movefile(fullfile(meta.folder,'preCDS',[meta.neuralPrefix '*.nev']),fullfile(meta.folder,'preCDS','merging'))
        if exist('altMeta','var') && ~isempty(altMeta.array)
            movefile(fullfile(meta.folder,'preCDS',[altMeta.neuralPrefix '*.nev']),fullfile(meta.folder,'preCDS','merging'))
        end
    end
    if ~exist(fullfile(meta.folder,'preCDS','Final'),'dir')
        mkdir(fullfile(meta.folder,'preCDS','Final'))
        movefile(fullfile(meta.folder,'preCDS',[meta.neuralPrefix '*.n*']),fullfile(meta.folder,'preCDS','Final'))
        if exist('altMeta','var')
            movefile(fullfile(meta.folder,'preCDS',[altMeta.neuralPrefix '*.n*']),fullfile(meta.folder,'preCDS','Final'))
        end
    end
%     if ~exist(fullfile(meta.folder,'ColorTracking'),'dir')
%         mkdir(fullfile(meta.folder,'ColorTracking'))
%         movefile(fullfile(meta.folder,'*_colorTracking_*.mat'),fullfile(meta.folder,'ColorTracking'))
%     end
%     if ~exist(fullfile(meta.folder,'ColorTracking','Markers'),'dir')
%         mkdir(fullfile(meta.folder,'ColorTracking','Markers'))
%     end
%     if ~exist(fullfile(meta.folder,'OpenSim'),'dir')
%         mkdir(fullfile(meta.folder,'OpenSim'))
%     end
%     if ~exist(fullfile(meta.folder,'OpenSim','Analysis'),'dir')
%         mkdir(fullfile(meta.folder,'OpenSim','Analysis'))
%     end
%     if ~exist(fullfile(meta.folder,'CDS'),'dir')
%         mkdir(fullfile(meta.folder,'CDS'))
%     end
%     if ~exist(fullfile(meta.folder,'TD'),'dir')
%         mkdir(fullfile(meta.folder,'TD'))
%     end

    %% Merge and strip files for spike sorting
    % Run processSpikesForSorting for the first time to combine spike data from
    % all files with a name starting with file_prefix.
    processSpikesForSorting(fullfile(meta.folder,'preCDS','merging'),meta.neuralPrefix);
    if exist('altMeta','var') && ~isempty(altMeta.array)
        processSpikesForSorting(fullfile(altMeta.folder,'preCDS','merging'),altMeta.neuralPrefix);
    end
    
    pause(2)
    %% rename merged file
    movefile(fullfile(meta.folder,'preCDS','merging',[meta.neuralPrefix '-spikes.nev']),fullfile(meta.folder,'preCDS','merging',[meta.neuralPrefix '-spikes-s.nev']))
    if exist('altMeta','var') && ~isempty(altMeta.array)
        movefile(fullfile(altMeta.folder,'preCDS','merging',[altMeta.neuralPrefix '-spikes.nev']),fullfile(altMeta.folder,'preCDS','merging',[altMeta.neuralPrefix '-spikes-s.nev']))
    end
    
    %% Split files and move to Final folder before loading
    processSpikesForSorting(fullfile(meta.folder,'preCDS','merging'),meta.neuralPrefix);
    if exist('altMeta','var') && ~isempty(altMeta.array)
        processSpikesForSorting(fullfile(altMeta.folder,'preCDS','merging'),altMeta.neuralPrefix);
    end

    % move into final folder
    for fileIdx = 1:length(meta.taskAlias)
        movefile(fullfile(meta.folder,'preCDS','merging',[meta.neuralPrefix '_' meta.taskAlias{fileIdx} '.mat']),...
            fullfile(meta.folder,'preCDS','Final'));
        if exist('altMeta','var') && ~isempty(altMeta.array)
            movefile(fullfile(altMeta.folder,'preCDS','merging',[altMeta.neuralPrefix '_' altMeta.taskAlias{fileIdx} '.mat']),...
                fullfile(altMeta.folder,'preCDS','Final'));
        end
        movefile(fullfile(meta.folder,'preCDS','merging',[meta.neuralPrefix '_' meta.taskAlias{fileIdx} '.nev']),...
            fullfile(meta.folder,'preCDS','Final'));
        if exist('altMeta','var') && ~isempty(altMeta.array)
            movefile(fullfile(altMeta.folder,'preCDS','merging',[altMeta.neuralPrefix '_' altMeta.taskAlias{fileIdx} '.nev']),...
                fullfile(altMeta.folder,'preCDS','Final'));
        end
    end

    %% Load data into CDS file
    % Make CDS files
    cds = cell(size(meta.taskAlias));
    for fileIdx = 1:length(meta.taskAlias)
        cds{fileIdx} = commonDataStructure();
        cds{fileIdx}.file2cds(fullfile(meta.folder,'preCDS','Final',[meta.neuralPrefix '_' meta.taskAlias{fileIdx}]),...
            ['ranBy' meta.ranBy],['array' meta.array],['monkey' meta.monkey],meta.lab,'ignoreJumps',['task' meta.task],['mapFile' meta.mapfile]);

%         % also load second file if necessary
%         if exist('altMeta','var')
%             if ~isempty(altMeta.array)
%                 cds{fileIdx}.file2cds(fullfile(altMeta.folder,'preCDS','Final',[altMeta.neuralPrefix '_' altMeta.taskAlias{fileIdx}]),...
%                     ['ranBy' altMeta.ranBy],['array' altMeta.array],['monkey' altMeta.monkey],altMeta.lab,'ignoreJumps',['task' altMeta.task],['mapFile' altMeta.mapfile]);
%             else
%                 cds{fileIdx}.file2cds(fullfile(altMeta.folder,'preCDS','Final',[altMeta.neuralPrefix '_' altMeta.taskAlias{fileIdx}]),...
%                     ['ranBy' altMeta.ranBy],['monkey' altMeta.monkey],altMeta.lab,'ignoreJumps',['task' altMeta.task]);
%             end
%         end
    end
    
    %% Make TD
    % COactpas
    params.array_alias = {'LeftS1Area2','S1'};
    params.exclude_units = [255];
    params.event_list = {'ctrHoldBump';'bumpTime';'bumpDir';'ctrHold'};
    params.trial_results = {'R','A','F','I'};
    td_meta = struct('task',meta.task);
    params.meta = td_meta;
    trial_data = parseFileByTrial(cds{1},params);

    % OOR
    % params.array_alias = {'LeftS1Area2','S1'};
    % % params.exclude_units = [255];
    % params.event_list = {'tgtDir','target_direction';'forceDir','force_direction';'startTargHold','startTargHoldTime';'endTargHoldTime','endTargHoldTime'};
    % params.trial_results = {'R','A','F','I'};
    % td_meta = struct('task','OOR');
    % params.meta = td_meta;
    % 
    % trial_data = parseFileByTrial(cds{1},params);

    % Bumpcurl
    % params.array_alias = {'LeftS1Area2','S1'};
    % params.event_list = {'ctrHoldBump';'bumpTime';'bumpDir';'ctrHold'};
    % td_meta = struct('task',meta.task,'epoch','BL');
    % params.trial_results = {'R','A','F','I'};
    % params.meta = td_meta;
    % trial_data_BL = parseFileByTrial(cds{1},params);
    % params.meta.epoch = 'AD';
    % trial_data_AD = parseFileByTrial(cds{2},params);
    % params.meta.epoch = 'WO';
    % trial_data_WO = parseFileByTrial(cds{3},params);
    % 
    % trial_data = cat(2,trial_data_BL,trial_data_AD,trial_data_WO);

    % TRT
    % params.array_alias = {'LeftS1Area2','S1';'RightCuneate','CN'};
    % params.event_list = {'bumpTime';'bumpDir';'ctHoldTime';'otHoldTime';'spaceNum';'targetStartTime'};
    % params.trial_results = {'R','A','F','I'};
    % td_meta = struct('task',meta.task);
    % params.meta = td_meta;
    % trial_data = parseFileByTrial(cds{1},params);
    % % sanitize?
    % idxkeep = cat(1,trial_data.spaceNum) == 1 | cat(1,trial_data.spaceNum) == 2;
    % trial_data = trial_data(idxkeep);

    % RW DL/PM
    % params.array_alias = {'LeftS1Area2','S1';'RightCuneate','CN'};
    % params.trial_results = {'R','A','F','I'};
    % td_meta = struct('task',meta.task,'spaceNum',2);
    % params.meta = td_meta;
    % trial_data_DL = parseFileByTrial(cds{1},params);
    % td_meta = struct('task',meta.task,'spaceNum',1);
    % params.meta = td_meta;
    % trial_data_PM = parseFileByTrial(cds{2},params);
    % trial_data = [trial_data_PM trial_data_DL];
    % % match up with TRT
    % for trial = 1:length(trial_data)
    %     trial_data(trial).idx_targetStartTime = trial_data(trial).idx_startTime;
    % end
    % trial_data = reorderTDfields(trial_data);

    %% Save TD
    save(fullfile(meta.hyperfolder,'data-td',meta.project,[meta.monkey '_' meta.date '_TD_nosort_notrack_noemg.mat']),'trial_data')
    
    %% clean up
    % delete things in merging folder
    delete(fullfile(meta.folder,'preCDS','merging',[meta.neuralPrefix '-spikes*']));
    % move things back into merging
    for fileIdx = 1:length(meta.taskAlias)
        delete(fullfile(meta.folder,'preCDS','Final',[meta.neuralPrefix '_' meta.taskAlias{fileIdx} '.mat']));
        if exist('altMeta','var') && ~isempty(altMeta.array)
            delete(fullfile(altMeta.folder,'preCDS','Final',[altMeta.neuralPrefix '_' altMeta.taskAlias{fileIdx} '.mat']));
        end
        movefile(fullfile(meta.folder,'preCDS','Final',[meta.neuralPrefix '_' meta.taskAlias{fileIdx} '.nev']),...
            fullfile(meta.folder,'preCDS','merging'));
        if exist('altMeta','var') && ~isempty(altMeta.array)
            movefile(fullfile(altMeta.folder,'preCDS','Final',[altMeta.neuralPrefix '_' altMeta.taskAlias{fileIdx} '.nev']),...
                fullfile(altMeta.folder,'preCDS','merging'));
        end
    end
    
    clearvars -except filedates dateidx
end