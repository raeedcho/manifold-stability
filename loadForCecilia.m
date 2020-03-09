%% load for Cecilia
monkey_names = {'Chips','Han'};
filedates = {...
    {...
    '20151113',...
    '20151117',...
    '20151120',...
    '20151201',...
    '20151204',...
    '20151211'},...
    {...
    '20171024',...
    '20171030',...
    '20171031', ...
    '20171103', ...
    '20171116', ...
    '20171120', ...
    '20171121', ...
    '20171122', ...
    '20171127', ...
    '20171128', ...
    '20171129', ...
    '20171201', ...
    '20171204', ...
    '20171207'}};

%% loop over dates
for monkeynum = 1:length(monkey_names)
    for dateidx = 1:length(filedates{monkeynum})
        %% Set up
        meta.lab=6;
        meta.ranBy='Raeed';
        meta.monkey=monkey_names{monkeynum};
        meta.date = filedates{monkeynum}{dateidx};
        if strcmpi(meta.monkey,'Chips')
            meta.task='CO'; % for the loading of cds
        else
            meta.task = 'COactpas';
        end
        meta.taskAlias={'COactpas_001'}; % for the filename (cell array list for files to load and save)
        meta.EMGrecorded = false; % whether or not EMG was recorded
        meta.motionTracked = false; % whether or not we have motion tracking
        meta.sorted = false; % whether or not the neurons have already been sorted
        meta.markered = false; % whether or not the colorTracking has already been markered
        meta.array='LeftS1Area2'; % for the loading of cds
        meta.copyfiles=true; % whether or not the script should copy files

        %% Set up meta fields
        meta.homefolder=fullfile('C:\Users\rhc307'); % home user folder
        meta.localdatafolder=fullfile(meta.homefolder,'data'); % folder with data-td and working data folder
        meta.workingfolder=fullfile(meta.localdatafolder,'workspace'); % folder
        meta.cdslibrary=fullfile(meta.localdatafolder,'cds-library');
        meta.tdlibrary=fullfile(meta.localdatafolder,'td-library');
        meta.FSMResfolder=fullfile('Z:\'); % wherever fsmresfiles are mounted
        meta.remotefolder=fullfile(meta.FSMResfolder,'limblab','User_folders','Raeed');
        meta.mapfilefolder=fullfile(meta.remotefolder,'metafiles','mapfiles'); % folder with mapfiles
        meta.semirawfolder=fullfile(meta.remotefolder,'semi-raw');
        meta.markersfolder=fullfile(meta.semirawfolder,'markers');
        meta.sortedfolder=fullfile(meta.semirawfolder,'sorted');
        meta.opensimsettingsfolder=fullfile(meta.remotefolder,'monkeyArmModel');
        
        if strcmp(meta.monkey,'Chips')
            meta.rawfolder=fullfile(meta.FSMResfolder,'data\Chips_12H1\RAW');
            meta.mapfile=fullfile(meta.mapfilefolder,'Chips\left_S1\SN 6251-001455.cmp');
            meta.arrayAlias='area2'; % for the filename
        elseif strcmp(meta.monkey,'Han')
            meta.rawfolder=fullfile(meta.FSMResfolder,'data\Han_13B1\Raw');
            meta.mapfile=fullfile(meta.mapfilefolder,'Han\left_S1\SN 6251-001459.cmp');
            if meta.EMGrecorded
                meta.arrayAlias = 'area2EMG'; % for the filename
                altMeta = meta;
                altMeta.array='';
                altMeta.arrayAlias='EMGextra';
                altMeta.neuralPrefix = [altMeta.monkey '_' altMeta.date '_' altMeta.arrayAlias];
            else
                meta.arrayAlias = 'area2'; % for the filename
            end
        elseif strcmp(meta.monkey,'Lando')
            meta.rawfolder=fullfile(meta.FSMResfolder,'data\Lando_13B2\Raw');
            meta.mapfile=fullfile(meta.mapfilefolder,'Lando\left_S1\SN 6251-001701.cmp');
            meta.arrayAlias = 'area2';
            altMeta = meta;
            altMeta.array='RightCuneate';
            altMeta.arrayAlias='cuneate';
            altMeta.neuralPrefix = [altMeta.monkey '_' altMeta.date '_' altMeta.arrayAlias];
            altMeta.mapfile=fullfile(meta.mapfilefolder,'Lando\right_cuneate\SN 1025-001745.cmp');
        elseif strcmp(meta.monkey,'Butter')
            meta.mapfile=fullfile(meta.mapfilefolder,'Butter\right_CN\SN 6250-001799.cmp');
            meta.arrayAlias='cuneate'; % for the filename
        end
        
        meta.neuralPrefix = [meta.monkey '_' meta.date '_' meta.arrayAlias];
        
        %% Copy data into working directory
        while length(dir(meta.workingfolder))~=2 % check if directory is empty first
            winopen(meta.workingfolder)
            fprintf('The working directory is not empty, please empty it!\n')
            pause
        end
        
        if meta.copyfiles
            for fileIdx = 1:length(meta.taskAlias)
                % copy neural data
                copyfile(fullfile(meta.rawfolder,[meta.neuralPrefix '_' meta.taskAlias{fileIdx} '*']),meta.workingfolder)
                if exist('altMeta','var')
                    copyfile(fullfile(meta.rawfolder,[altMeta.neuralPrefix '_' meta.taskAlias{fileIdx} '*']),meta.workingfolder)
                end
                
                % copy color tracking
                copyfile(fullfile(meta.rawfolder,sprintf('%s_%s_colorTracking_%s.mat',meta.monkey,meta.date,meta.taskAlias{fileIdx})),meta.workingfolder)
            end
        else
            if ispc
                % open windows so that we can move data around
                winopen(meta.workingfolder)
                winopen(meta.rawfolder)
                pause
            else
                fprintf('These directories are probably all wrong...\n')
                error('Cannot open windows through script, do it live!')
                %fprintf('Please navigate to %s and move data to %s',meta.rawfolder,meta.workingfolder)
                % copyfile(fullfile(meta.rawfolder,[meta.monkey '_' meta.date '*']),meta.workingfolder)
            end
        end
        
        %% Set up folder structure
        if ~exist(fullfile(meta.workingfolder,'preCDS'),'dir')
            mkdir(fullfile(meta.workingfolder,'preCDS'))
            movefile(fullfile(meta.workingfolder,[meta.neuralPrefix '*']),fullfile(meta.workingfolder,'preCDS'))
            if exist('altMeta','var')
                movefile(fullfile(meta.workingfolder,[altMeta.neuralPrefix '*']),fullfile(meta.workingfolder,'preCDS'))
            end
        end
        if ~meta.sorted
            if ~exist(fullfile(meta.workingfolder,'preCDS','merging'),'dir')
                mkdir(fullfile(meta.workingfolder,'preCDS','merging'))
                movefile(fullfile(meta.workingfolder,'preCDS',[meta.neuralPrefix '*.nev']),fullfile(meta.workingfolder,'preCDS','merging'))
                if exist('altMeta','var') && ~isempty(altMeta.array)
                    movefile(fullfile(meta.workingfolder,'preCDS',[altMeta.neuralPrefix '*.nev']),fullfile(meta.workingfolder,'preCDS','merging'))
                end
            end
        end
        if ~exist(fullfile(meta.workingfolder,'preCDS','Final'),'dir')
            mkdir(fullfile(meta.workingfolder,'preCDS','Final'))
            movefile(fullfile(meta.workingfolder,'preCDS',[meta.neuralPrefix '*.n*']),fullfile(meta.workingfolder,'preCDS','Final'))
            if exist('altMeta','var')
                movefile(fullfile(meta.workingfolder,'preCDS',[altMeta.neuralPrefix '*.n*']),fullfile(meta.workingfolder,'preCDS','Final'))
            end
        end
    
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
        %% Load data into CDS file
        % Make CDS files
        cds_cell = cell(size(meta.taskAlias));
        for fileIdx = 1:length(meta.taskAlias)
            cds_cell{fileIdx} = commonDataStructure();
            cds_cell{fileIdx}.file2cds(...
                fullfile(meta.workingfolder,'preCDS','Final',[meta.neuralPrefix '_' meta.taskAlias{fileIdx}]),...
                ['ranBy' meta.ranBy],...
                ['array' meta.array],...
                ['monkey' meta.monkey],...
                meta.lab,...
                'ignoreJumps',...
                'unsanitizedTimes',...
                ['task' meta.task{fileIdx}],...
                ['mapFile' meta.mapfile]);
        end
        
        %% Save CDS
        for fileIdx = 1:length(meta.taskAlias)
            cds_name = sprintf('%s_%s_CDS_%s.mat',meta.monkey,meta.date,meta.taskAlias{fileIdx});
            cds = cds_cell{fileIdx};
            save(fullfile(meta.cdslibrary,cds_name),'cds','-v7.3')
        end
        
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
end
