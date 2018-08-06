classdef BoundaryTrack < dynamicprops

    % segmentation & tracking of the boundary of binarized cell image
    % calculation of velocity, curvature, and fluorescent intensity
    % @ Taihei Fujimori
    
    properties
        INPUTDATA
        PARAMS
        RESULTS
    end
    
    methods
        function obj = BoundaryTrack()
            %%% Constructor
            [FileName,PathName] = uigetfile({'*.tif'},'MultiSelect','on');
            obj.PARAMS.pathname = PathName;
            if ~iscell(FileName); FileName = cellstr(FileName); end
            for i = 1:length(FileName)
                disp(' ');
                fprintf(['load:',num2str(i),'/',num2str(length(FileName))]); fprintf('\n');
                obj.INPUTDATA(i).filename = FileName{i};
                obj.INPUTDATA(i).mask = convertMask(xytread([PathName,FileName{i}]));
            end
            param=inputdlg({'frame interval (sec), default=10','scale (um / pixel), default=1'},'Acquisition Parameters',1);
            if isempty(param{1,1})
                obj.PARAMS.secPERframe = 10;
            else
                obj.PARAMS.secPERframe = str2double(param{1,1});
            end

            if isempty(param{2,1})
                obj.PARAMS.umPERpixel  = 1;
            else
                obj.PARAMS.umPERpixel  = str2double(param{2,1});
            end
            disp(' ');
            disp('finish.');
            disp(' ');
        end

        function obj = appendimage(obj)
            load_data_type = [];
            scrsz = get(groot,'ScreenSize');
            h.f = figure('units','pixels','position',[scrsz(3)/2-150/2 scrsz(4)/2-180/2 180 150],...
                         'toolbar','none','menu','none','Name','appendimage','NumberTitle','off');

            h.p(1) = uicontrol('style','pushbutton','units','pixels',...
                            'position',[30,100,120,30],'string','mask','FontSize',20,...
                            'callback',@p_call1);
            h.p(2) = uicontrol('style','pushbutton','units','pixels',...
                            'position',[30,50,120,30],'string','cellimage','FontSize',20,...
                            'callback',@p_call2);
            h.p(3) = uicontrol('style','pushbutton','units','pixels',...
                            'position',[30,5,120,30],'string','extfield','FontSize',20,...
                            'callback',@p_call3);
            function p_call1(varargin)
                load_data_type = 'mask';
                close(h.f);
            end
            function p_call2(varargin)
                load_data_type = 'cellimage';
                close(h.f);
            end
            function p_call3(varargin)
                load_data_type = 'extfield';
                close(h.f);
            end
            waitfor(h.f);
            if ~isempty(load_data_type)
                [FileName,PathName] = uigetfile({'*.tif'},'',obj.PARAMS.pathname,'MultiSelect','on');
                if ~iscell(FileName); FileName = cellstr(FileName); end
                inputs = inputdatanum(obj);
                switch load_data_type
                    case 'mask'
                        for i = 1:length(FileName)
                            disp(' ');
                            fprintf(['load:',num2str(i),'/',num2str(length(FileName))]); fprintf('\n');
                            obj.INPUTDATA(i).filename = FileName{i};
                            obj.INPUTDATA(i+inputs(1)).mask = convertMask(xytread([PathName,FileName{i}]));
                        end
                    case 'cellimage'
                        for i = 1:length(FileName)
                            disp(' ');
                            fprintf(['load:',num2str(i),'/',num2str(length(FileName))]); fprintf('\n');
                            obj.INPUTDATA(i+inputs(2)).cellimage = xytread([PathName,FileName{i}]);
                        end
                    case 'extfield'
                        for i = 1:length(FileName)
                            disp(' ');
                            fprintf(['load:',num2str(i),'/',num2str(length(FileName))]); fprintf('\n');
                            obj.INPUTDATA(i+inputs(3)).extfield = xytread([PathName,FileName{i}]);
                        end
                end
            disp(' ');
            disp('finish.');
            disp(' ');
            end
        end
  
        function obj = loadimage(obj)
            cell_index = [];
            % Create figure
            scrsz = get(groot,'ScreenSize');
            h.f = figure('units','pixels','position',[scrsz(3)/2-200/2 scrsz(4)/2-280/2 200 280],...
                         'toolbar','none','menu','none','Name','reloadimage','NumberTitle','off');
            % Create text
            uicontrol('Style','text',...
              'Position', [1 250 200 20],'FontSize',20,...
              'String','select data');

            uicontrol('Style','text',...
              'Position', [1 100 200 20],'FontSize',20,...
              'String','enter cell #');

            h.c(1) = uicontrol('Style','listbox',...
                                'String',{'mask','cellimage','extfield'},...
                                'Position',[10 130 180 110],'FontSize',15,'Max',1,'Min',1,'Value',1);

            h.c(2) = uicontrol('Style','edit',...
                            'String','',...
                            'Position',[30 50 140 30]);

            % Create OK pushbutton
            h.p = uicontrol('style','pushbutton','units','pixels',...
                            'position',[65,5,70,20],'string','OK',...
                            'callback',@p_call1);
            
            % Pushbutton callback
            function p_call1(varargin)
                load_data_type = h.c(1).Value;
                cell_index = str2num(h.c(2).String);
                close(h.f);
                [FileName,PathName] = uigetfile({'*.tif'},'',obj.PARAMS.pathname,'MultiSelect','on');
                if ~iscell(FileName); FileName = cellstr(FileName);end
                if isempty(cell_index); cell_index = 1:length(FileName); end
                if length(cell_index) == length(FileName)
                    switch load_data_type
                        case 1
                            for i = 1:length(FileName)
                                disp(' ');
                                fprintf(['load:',num2str(i),'/',num2str(length(FileName))]); fprintf('\n');
                                obj.INPUTDATA(i).filename = FileName{i};
                                obj.INPUTDATA(cell_index(i)).mask = convertMask(xytread([PathName,FileName{i}]));
                            end
                        case 2
                            for i = 1:length(FileName)
                                disp(' ');
                                fprintf(['load:',num2str(i),'/',num2str(length(FileName))]); fprintf('\n');
                                obj.INPUTDATA(cell_index(i)).cellimage = xytread([PathName,FileName{i}]);
                            end
                        case 3
                            for i = 1:length(FileName)
                                disp(' ');
                                fprintf(['load:',num2str(i),'/',num2str(length(FileName))]); fprintf('\n');
                                obj.INPUTDATA(cell_index(i)).extfield = xytread([PathName,FileName{i}]);
                            end
                    end
                else
                    disp('Number of selected images is not much input.');
                end
                disp(' ');
                disp('finish.');
                disp(' ');
            end
        end
        
        function obj = boundarytracking(obj)
            param=inputdlg({'number of boundary points, default=500','--- External field calc.--- distance from boundary (pixel), default=5',...
            '---External field calc.--- neighbor (pixel), default=1','---Fluorescent protein intensity calc.--- neighbor (pixel), default=1',...
            'data for analysis, default=ALL'},'Tracking Parameters',1);
            npoints = str2double(param{1,1}); if isnan(npoints); npoints=500; end
            dist    = str2double(param{2,1}); if    isnan(dist);      dist=5; end
            neigh   = str2double(param{3,1}); if   isnan(neigh);     neigh=1; end
            neigh2  = str2double(param{4,1}); if  isnan(neigh2);    neigh2=1; end
            datanum  = str2num(param{5,1}); if isempty(datanum); datanum=1:length(obj.INPUTDATA); end
            obj.PARAMS.trackingpoints    = npoints;
            obj.PARAMS.extfield_distance = dist;
            obj.PARAMS.extfield_neighbor = neigh;
            obj.PARAMS.cell_neighbor     = neigh2;
            %if isempty(obj.RESULTS) obj.RESULTS = struct('dammy',{}); end
            TEMPobj = obj.INPUTDATA;
            if ~isfield(TEMPobj,'extfield')
                TEMPobj = setfield(TEMPobj,{1},'extfield',{});
            end
            
            if ~isfield(TEMPobj,'cellimage')
                TEMPobj = setfield(TEMPobj,{1},'cellimage',{});
            end
            
            for i = 1:length(obj.INPUTDATA)
                if isempty(find(datanum == i))
                    disp(' ');
                    fprintf([num2str(i),'/',num2str(length(obj.INPUTDATA))]); fprintf('\n');
                    fprintf('skipped'); fprintf('\n');
                    if ~isempty(obj.RESULTS) && i <= length(obj.RESULTS)
                        temp(i) = obj.RESULTS(i);
                    end
                else
                    disp(' ');
                    fprintf([num2str(i),'/',num2str(length(obj.INPUTDATA))]); fprintf('\n');
                    temp(i) = BoundTrack12(TEMPobj(i).mask,npoints,...
                        TEMPobj(i).extfield,dist,neigh,...
                        TEMPobj(i).cellimage,neigh2,...
                        obj.PARAMS.umPERpixel,obj.PARAMS.secPERframe);
                end
            end
            obj.RESULTS = temp;
            disp(' ');
        end
        
        function vismap(obj)
            cell_index = [];
            % Create figure
            scrsz = get(groot,'ScreenSize');
            h.f = figure('units','pixels','position',[scrsz(3)/2-200/2 scrsz(4)/2-280/2 200 280],...
                         'toolbar','none','menu','none','Name','map visualization','NumberTitle','off');
            % Create text
            uicontrol('Style','text',...
              'Position', [1 250 200 20],'FontSize',20,...
              'String','select data');

            uicontrol('Style','text',...
              'Position', [1 100 200 20],'FontSize',20,...
              'String','enter cell #');

            h.c(1) = uicontrol('Style','listbox',...
                                'String',{'velocity','curvature','ext. field','f.p. intensity','f.p. intensity norm'},...
                                'Position',[10 130 180 110],'FontSize',15,'Max',5,'Min',1,'Value',1);

            h.c(2) = uicontrol('Style','edit',...
                            'String','',...
                            'Position',[30 50 140 30]);

            % Create OK pushbutton
            h.p = uicontrol('style','pushbutton','units','pixels',...
                            'position',[65,5,70,20],'string','OK',...
                            'callback',@p_call1);
            
            % Pushbutton callback
            function p_call1(varargin)
                vals = h.c(1).Value;
                cell_index = str2num(h.c(2).String);
                close(h.f);
                for k = 1:length(vals)
                    if isempty(cell_index); cell_index = 1:length(obj.RESULTS); end
                    mapimg = cell(1,length(cell_index));
                    for i = 1:length(mapimg)
                        switch vals(k)
                            case 1
                                mapimg{i} = obj.RESULTS(cell_index(i)).velocity; zlab = 'velocity [um/min]';
                            case 2
                                mapimg{i} = obj.RESULTS(cell_index(i)).curvature; zlab = 'curvature [rad/um]';
                            case 3
                                mapimg{i} = obj.RESULTS(cell_index(i)).extField; zlab = 'intensity [a.u.]';
                            case 4
                                mapimg{i} = obj.RESULTS(cell_index(i)).fpIntensity; zlab = 'intensity [a.u.]';
                            case 5
                                mapimg{i} = obj.RESULTS(cell_index(i)).fpIntensity_norm; zlab = 'intensity [a.u.]';
                        end
                    end
                    mapvisualization(mapimg,zlab,cell_index,obj.PARAMS.secPERframe,k,length(vals));
                end
            end
        end
        
        function vistracking(obj)
            cell_index = [];
            % Create figure
            scrsz = get(groot,'ScreenSize');
            h.f = figure('units','pixels','position',[scrsz(3)/2-200/2 scrsz(4)/2-140/2 200 140],...
                         'toolbar','none','menu','none','Name','tracking visualization','NumberTitle','off');

            uicontrol('Style','text',...
              'Position', [1 100 200 20],'FontSize',20,...
              'String','enter cell #');

            h.c = uicontrol('Style','edit',...
                            'String','',...
                            'Position',[30 50 140 30]);

            % Create OK pushbutton
            h.p = uicontrol('style','pushbutton','units','pixels',...
                            'position',[65,5,70,20],'string','OK',...
                            'callback',@p_call1);
            
            % Pushbutton callback
            function p_call1(varargin)
                cell_index = str2num(h.c.String);
                if isempty(cell_index); cell_index = 1:length(obj.RESULTS); end
                close(h.f);
                trackvisualization(obj,cell_index,1,1,1);
            end
        end
        
        function currentstate(obj)
            try close 'Current state'; catch; end
            try close 'Current images @ T = 1'; catch; end
            % contained_data: col=cell#, row=datatype
            % row: 1=mask, 2=cellimage, 3=extfield, 4=velocityANDcurvature,
            % 5=fpIntensity, 6=ext_field, 7=fpIntensity_norm
            rownum = 7;
            contained_data = cell(rownum,1+length(obj.INPUTDATA));
            contained_data{1,1} = 'mask';
            contained_data{2,1} = 'cellimage';
            contained_data{3,1} = 'extfield';
            contained_data{4,1} = 'velocity&curvature';
            contained_data{5,1} = 'fpIntensity';
            contained_data{6,1} = 'ext_field';
            contained_data{7,1} = 'fpIntensity_norm';
            for k = 1:rownum
                tempdata = cell(1,size(contained_data,2)-1);
                for i = 1:length(tempdata)
                    switch k
                        case 1
                            try tempdata{i} = obj.INPUTDATA(i).mask; catch tempdata{i} = []; end
                        case 2
                            try tempdata{i} = obj.INPUTDATA(i).cellimage; catch tempdata{i} = []; end
                        case 3
                            try tempdata{i} = obj.INPUTDATA(i).extfield; catch tempdata{i} = []; end
                        case 4
                            try tempdata{i} = obj.RESULTS(i).velocity; catch tempdata{i} = []; end
                        case 5
                            try tempdata{i} = obj.RESULTS(i).fpIntensity; catch tempdata{i} = []; end
                        case 6
                            try tempdata{i} = obj.RESULTS(i).extField; catch tempdata{i} = []; end
                        case 7
                            try tempdata{i} = obj.RESULTS(i).fpIntensity_norm; catch tempdata{i} = []; end
                    end
                end

                for i = 1:length(tempdata)
                    try
                        contained_data{k,i+1} = ~isempty(tempdata{i});
                    catch
                        contained_data{k,i+1} = 0;
                    end
                end

            end
            columnname = cell(1,size(contained_data,2));
            columnname{1} = 'data type';
            for i=2:size(contained_data,2) columnname{i} = ['cell#',num2str(i-1)]; end

            columnformat = cell(1,size(contained_data,2));
            columnformat{1} = 'char';
            for i=2:size(contained_data,2) columnformat{i} = 'logical'; end

            columnwidth = cell(1,size(contained_data,2));
            columnwidth{1} = 120;
            for i=2:size(contained_data,2) columnwidth{i} = 'auto'; end

            rowname = cell(1,rownum);
            for i=1:3 rowname{i} = 'INPUTDATA'; end
            for i=4:rownum rowname{i} = 'RESULTS'; end
            
            scrsz = get(groot,'ScreenSize');
            figure('NumberTitle','off','Name','Current state','Toolbar','None','Menu','None',...
                'Position',[scrsz(1) scrsz(4)-180 scrsz(3) 180]);
            curr_tab = uitable('Data', contained_data,... 
                        'ColumnName', columnname,...
                        'ColumnFormat', columnformat,...
                        'ColumnWidth', columnwidth,...
                        'RowName',rowname);
            % Set width and height
            curr_tab.Position(3) = curr_tab.Extent(3);
            curr_tab.Position(4) = curr_tab.Extent(4);
            
%             figx = 0;
%             figy = 0;
%             for i = 1:length(obj.INPUTDATA)
%             test = size(obj.INPUTDATA(1).mask);
%             figx = figx + test(1) + 100;
%             figy = max(figy,test(2));
%             end
            figure('NumberTitle','off','Name','Current images @ T = 1','Toolbar','None','Menu','None',...
                'Position',[scrsz(1)+200 scrsz(4)-180-700 scrsz(3)-200 600]);
            for i = 1:length(obj.INPUTDATA)
                if isfield(obj.INPUTDATA,'mask')
                subplot(3,length(obj.INPUTDATA),i);
                imagesc(obj.INPUTDATA(i).mask(:,:,1));
                axis image; colormap(gray); axis off;
                title(['cell#',num2str(i)],'FontSize',15);
                end

                if isfield(obj.INPUTDATA,'cellimage')
                subplot(3,length(obj.INPUTDATA),i+length(obj.INPUTDATA));
                imagesc(obj.INPUTDATA(i).cellimage(:,:,1));
                axis image; colormap(gray); axis off; brighten(0.5);
                end
                
                if isfield(obj.INPUTDATA,'extfield')
                subplot(3,length(obj.INPUTDATA),i+2*length(obj.INPUTDATA));
                imagesc(obj.INPUTDATA(i).extfield(:,:,1));
                axis image; colormap(gray); axis off; brighten(0.5);
                end
            end
        end
        
        function normbycyto(obj)
            disp(' ');
            disp('calculation...');
            se = strel('square',3);
            for i = 1:length(obj.INPUTDATA)
                try
                    tempmask = cast(obj.INPUTDATA(i).mask/255,'double');
                    tempmask = imerode(imerode(imerode(tempmask,se),se),se); %% 3 times erode (4 times until 20180419)
                    tempfp = cast(obj.INPUTDATA(i).cellimage,'double');
                    temptotal = reshape(sum(sum(tempfp.*tempmask,1),2)./sum(sum(tempmask,1),2),1,[]);
                    temptotal = repmat(temptotal,[size(obj.RESULTS(i).fpIntensity,1) 1]);
                    temp =  obj.RESULTS(i).fpIntensity./temptotal(:,2:end-2);
                    obj.RESULTS(i).fpIntensity_norm = temp;
                catch
                end
            end
            disp('finish.');
            disp(' ');
        end
        
        function methodpanel(obj)
            scrsz = get(groot,'ScreenSize');
            f = figure('NumberTitle','off','Name',inputname(1),'Toolbar','None','Menu','None',...
                'Position',[scrsz(1) (scrsz(4)-420)/2 200 420]);
            
            figy = linspace(360,10,8);
            % Create pushbutton
            uicontrol('style','text','units','pixels','FontSize',15,...
                        'position',[10,385,180,30],'string','method panel');
            uicontrol('style','pushbutton','units','pixels','FontSize',15,...
                        'position',[10,figy(1),180,30],'string','appendimage',...
                        'callback',@cb_appendimage);
            uicontrol('style','pushbutton','units','pixels','FontSize',15,...
                        'position',[10,figy(2),180,30],'string','loadimage',...
                        'callback',@cb_loadimage);
            uicontrol('style','pushbutton','units','pixels','FontSize',15,...
                        'position',[10,figy(3),180,30],'string','boundarytracking',...
                        'callback',@cb_boundarytracking);
            uicontrol('style','pushbutton','units','pixels','FontSize',15,...
                        'position',[10,figy(4),180,30],'string','vismap',...
                        'callback',@cb_vismap);
            uicontrol('style','pushbutton','units','pixels','FontSize',15,...
                        'position',[10,figy(5),180,30],'string','vistracking',...
                        'callback',@cb_vistracking);
            uicontrol('style','pushbutton','units','pixels','FontSize',15,...
                        'position',[10,figy(6),180,30],'string','normbycyto',...
                        'callback',@cb_normbycyto);
            uicontrol('style','pushbutton','units','pixels','FontSize',15,...
                        'position',[10,figy(7),180,30],'string','currentstate',...
                        'callback',@cb_currentstate);
            uicontrol('style','pushbutton','units','pixels','FontSize',15,...
                        'position',[10,figy(8),180,30],'string','close all figs',...
                        'callback',@cb_closeall);
                    
            set(f,'handlevisibility','off');
            % Pushbutton callback
            function cb_appendimage(varargin)
                obj.appendimage;
            end
            function cb_loadimage(varargin)
                obj.loadimage;
            end
            function cb_boundarytracking(varargin)
                obj.boundarytracking;
            end
            function cb_vismap(varargin)
                obj.vismap;
            end
            function cb_vistracking(varargin)
                obj.vistracking;
            end
            function cb_normbycyto(varargin)
                obj.normbycyto;
            end
            function cb_currentstate(varargin)
                obj.currentstate;
            end
            function cb_closeall(varargin)
                close all;
            end
        end

        function getversion(obj)
            disp(' ');
            disp('BoundaryTrack(ver 1.0.3)');
            disp('author: Taihei Fujimori');
            disp('last update: 2018/08/06');
            disp(' ');
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%     functions     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A=xytread(imfile)
%
% made by Shotaro Hiwatashi
%
    imnumber=size(imfinfo(imfile),1);
    for i=1:imnumber
        A(:,:,i)=imread(imfile,i);
    end
end

function output = inputdatanum(obj)
    rownum = 3;
    contained_data = zeros(rownum,length(obj.INPUTDATA));
    for k = 1:rownum
        tempdata = cell(1,size(contained_data,2));
        for i = 1:length(tempdata)
            switch k
                case 1
                    try tempdata{i} = obj.INPUTDATA(i).mask; catch tempdata{i} = []; end
                case 2
                    try tempdata{i} = obj.INPUTDATA(i).cellimage; catch tempdata{i} = []; end
                case 3
                    try tempdata{i} = obj.INPUTDATA(i).extfield; catch tempdata{i} = []; end
            end
        end

        for i = 1:length(tempdata)
            try
                contained_data(k,i) = ~isempty(tempdata{i});
            catch
                contained_data(k,i) = 0;
            end
        end
    end
    output = sum(contained_data,2);
end

function output = convertMask(img)
    if img(1,1,1)
        output = abs(cast(img,'single') - 255);
    else
        output = cast(img,'single');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% visualization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mapvisualization(mapimg,zlab,cell_index,intvl,mapNo,mapNoTot)
    oldfignum = size(get(groot,'Children'),1);
    imgID = [1:length(mapimg);1:length(mapimg)];
    
    H = ones(1,1)/1;
    sft = 0;
    scrsz = get(groot,'ScreenSize');
    figx = linspace(0,scrsz(3)-580,size(mapimg,2));
    figy = linspace(0,scrsz(4)-540,      mapNoTot);
    figy = fliplr(figy);
    for i = 1:length(mapimg)
        figure('Position',[figx(i) figy(mapNo) 580 540],...
                'Name',['cell#',num2str(cell_index(i))],'NumberTitle','off');
        thisax = gca;
        thisax.Position(2) = thisax.Position(2)+0.22;
        thisax.Position(4) = thisax.Position(4)*0.8;
        mapimage(mapimg{i},H,sft,zlab,intvl);
        cax = caxis;

        %%%%%%%%%%%%%%%%%% color map %%%%%%%%%%%%%%%%
        % Create pop-up menu
        uicontrol('Style', 'popup',...
               'String', {'parula','jet','hsv','hot','cool','gray'},...
               'Position', [200 25 120 50],'FontSize',15,...
               'Callback', @setmap);    
         uicontrol('Style','text',...
                'Position', [200 95 120 20],'FontSize',20,...
                'String','Color map');

        %%%%%%%%%%%%%%%%%% position rotation %%%%%%%%%%%%%%%%
        tempF = gcf;
        % Create slider
        uicontrol('Style', 'slider',...
            'Min',0,'Max',500,'Value',0,...
            'Position', [20 50 120 20],...
            'Callback', @bposrotation); 
        % Add a text uicontrol to label the slider.
        uicontrol('Style','text',...
            'Position',[0 95 190 20],'FontSize',20,...
            'String','Position rotation');
        % Add a text uicontrol to label the slider.
        txt_rotpos(tempF.Number) = uicontrol('Style','text',...
            'Position',[143 53 40 20],'FontSize',15,...
            'String',num2str(0));

        %%%%%%%%%%%%%%%%%% caxis max %%%%%%%%%%%%%%%%
        % Create slider
        uicontrol('Style', 'slider',...
            'Min',min(min(mapimg{i})),'Max',max(max(mapimg{i})),'Value',cax(2),...
            'Position', [380 50 120 20],...
            'Callback', @caxis_max); 
        % Add a text uicontrol to label the slider.
        uicontrol('Style','text',...
            'Position',[330 50 50 20],'FontSize',15,...
            'String','MAX');
        % Add a text uicontrol to label the slider.
        txt_cmax(tempF.Number) = uicontrol('Style','text',...
            'Position',[505 52 50 20],'FontSize',15,...
            'String',num2str(cax(2)));
        %%%%%%%%%%%%%%%%%% caxis max %%%%%%%%%%%%%%%%
        % Create slider
        uicontrol('Style', 'slider',...
            'Min',min(min(mapimg{i})),'Max',max(max(mapimg{i})),'Value',cax(1),...
            'Position', [380 20 120 20],...
            'Callback', @caxis_min); 
        % Add a text uicontrol to label the slider.
        uicontrol('Style','text',...
            'Position',[330 20 50 20],'FontSize',15,...
            'String','MIN');
        txt_cmin(tempF.Number) = uicontrol('Style','text',...
            'Position',[505 22 50 20],'FontSize',15,...
            'String',num2str(cax(1)));
        % Add a text uicontrol to label the slider.
        uicontrol('Style','text',...
            'Position',[335 95 200 20],'FontSize',20,...
            'String','MIN & MAX');
        %{
        % Create push button
        btn = uicontrol('Style', 'pushbutton', 'String', 'Clear',...
            'Position', [20 20 50 20],...
            'Callback', 'cla');       
        %}

        % Make figure visble after adding all components
        %f.Visible = 'on';
        imgID(2,i) = tempF.Number;
    end

    function setmap(source,callbackdata)
        val = source.Value;
        maps = source.String;

        newmap = maps{val};
        colormap(newmap);
    end

    function bposrotation(source,callbackdata)
        oldcax = caxis;
        FIG = gcf;
        mapimage(mapimg{imgID(1,imgID(2,:)==FIG.Number)},H,round(source.Value),zlab,intvl);
        caxis(oldcax);
        txt_rotpos(FIG.Number).delete;
        txt_rotpos(FIG.Number) = uicontrol('Style','text',...
            'Position',[143 53 40 20],'FontSize',15,...
            'String',num2str(round(source.Value)));
    end

    function caxis_max(source,callbackdata)
        oldcax = caxis;
        caxis([oldcax(1) source.Value]);
        FIG = gcf;
        txt_cmax(FIG.Number).delete;
        txt_cmax(FIG.Number) = uicontrol('Style','text',...
        'Position',[505 52 50 20],'FontSize',15,...
        'String',num2str(source.Value));
    end

    function caxis_min(source,callbackdata)
        oldcax = caxis;
        caxis([source.Value oldcax(2)]);
        FIG = gcf;
        txt_cmin(FIG.Number).delete;
        txt_cmin(FIG.Number) = uicontrol('Style','text',...
        'Position',[505 22 50 20],'FontSize',15,...
        'String',num2str(source.Value));
    end

end

function mapimage(M,H,sft,zlab,intvl)
    %%M must be 2D matrix. you can also declare x,y,z label name
    %%intvl can be used when x is time. intvl defines the duration [sec] of a pixel
    %%when x is time, it's recommended to use 'time [a.u./min]' for x.
    
    step = 1; % step of x axis (time [min])
    sizeOFfont = 20;
    
    temp = imfilter(repmat(circshift(M,[sft 0]),3,1),H);
    M = temp(size(M,1)+1:2*size(M),:);

    imagesc(M);
    set(gca,'FontSize',sizeOFfont);
%    set(gcf,'Color','black');%???n?p
%    set(gca,'XColor','white','YColor','white','ZColor','white','TickDir','out');%???n?p
    xlabel('time [min]', 'FontSize', sizeOFfont);
    ylabel('boundary position', 'FontSize', sizeOFfont);
    x = 1:60/intvl*step:size(M,2);
    xt = 0:step:floor(size(M,2)*intvl/60); %time normalization
    set(gca,'FontSize',sizeOFfont,...
    'XTickLabel',xt,'XTick',x); %*(60/intvl)+1);%%%x axis label

    %%%%%% Yaxis %%%%%
    %%%%%%%%%%%%%%%%%%%%%%% radian, binned into 32 segments
    %{
    set(gca,'FontSize',30,...
    'YTickLabel',{'0','??','2??'},'YTick',[1 16 33]); %*(60/intvl)+1);%%%x axis label
    %}
    %%%%%%%%%%%%%%%%%%%%%%% front to back
    %{
    set(gca,'FontSize',30,...
    'YTickLabel',{'back','front','back'},'YTick',[1 251 500]); %*(60/intvl)+1);%%%x axis label
    %}
    %%%%%%%%%%%%%%%%%%%%%%% none
    %%{
    set(gca,'FontSize',sizeOFfont,...
    'YTickLabel',{100:100:500},'YTick',100:100:500); %*(60/intvl)+1);%%%x axis label
    %}
    %%%%%%%%%%%%%%%%%%
    
    colbar = colorbar('FontSize',sizeOFfont);
    colbar.Label.String = zlab;
   
end

function trackvisualization(obj,cell_index,t,newfig,d)
    segnum = 5;
    scbar = 10;
    duration=1;
    %t = 1;
    np = obj.PARAMS.trackingpoints;
    um_pix = obj.PARAMS.umPERpixel;
    cmap = hsv(length(1:segnum:np));
    
    scrsz = get(groot,'ScreenSize');
    figx = linspace(0,scrsz(3)-580,length(cell_index));
    
    for i = 1:length(cell_index)
        if newfig
        figure('NumberTitle','off','Name',['cell#',num2str(cell_index(i))],...
            'Position',[figx(i) scrsz(4) 580 540]);
        currax = gca;
        currax.Position(2) = currax.Position(2)*1.3;
        currax.Position(4) = currax.Position(4)*0.95;
        end
        X = reshape(cat(1,obj.RESULTS(cell_index(i)).mappedbound(:,2,:),obj.RESULTS(cell_index(i)).mappedbound(1,2,:)),np+1,[]);
        Y = reshape(cat(1,obj.RESULTS(cell_index(i)).mappedbound(:,1,:),obj.RESULTS(cell_index(i)).mappedbound(1,1,:)),np+1,[]);
        % V = cat(1,obj.RESULTS(cell_index(i)).velocity(:,:),obj.RESULTS(cell_index(i)).velocity(1,:));
        xlimit = size(obj.INPUTDATA(cell_index(i)).mask,2);
        ylimit = size(obj.INPUTDATA(cell_index(i)).mask,1);
        ctick = 100:100:np;

        plot(X(:,t),Y(:,t),'Color',[.5 .5 .5]);
        axis ij; axis image; axis([1 xlimit 1 ylimit]);
        hold on
        plot(X(:,t+d),Y(:,t+d),'k-');
        axis ij; axis image; axis([1 xlimit 1 ylimit]);
        set(gca,'XTickLabel',{},'YTickLabel',{},'TickLength',[0 0])

        for k = 1:segnum:np
            line([X(k,t) X(k,t+d)],[Y(k,t) Y(k,t+d)],'Color',cmap((k-1)/segnum+1,:));
        end

        rectangle('Position',[10 ylimit*0.8 scbar/um_pix scbar/um_pix/10],'FaceColor',[0 0 0])
        text(10+scbar/um_pix/2, ylimit*0.8+3*scbar/um_pix/10,[num2str(scbar),' um'],...
            'HorizontalAlignment','center','FontSize',15)

        text(xlimit*0.95, ylimit*0.1,'T','Color',[.5 .5 .5],...
        'HorizontalAlignment','center','FontSize',15)
        text(xlimit*0.95, ylimit*0.1+10,['T+',num2str(d)],'Color',[ 0  0  0],...
        'HorizontalAlignment','center','FontSize',15)
        
        colbar = colorbar('FontSize',15,'Ticks',ctick/np,'TickLabels',ctick);
        colbar.Label.String = 'position';
        colormap(hsv);
        
        %%%%%%%%%%%%%%%%%% frame position %%%%%%%%%%%%%%%%
        tempF = gcf;
        % Create slider
        uicontrol('Style', 'slider',...
            'Min',1,'Max',size(X,2)-d,'Value',t,...
            'Position', [70 10 140 20],...
            'SliderStep',[1/(size(X,2)-d) 0.2],...
            'Callback', @framepos); 
        % Add a text uicontrol to label the slider.
        dispmin = (round(((t-1)*obj.PARAMS.secPERframe/60)*10))/10;
        txt_framepos(tempF.Number) = uicontrol('Style','text',...
            'Position',[70 50 200 20],'FontSize',20,...
            'String',['T=',num2str(t),' (',num2str(dispmin),' min.)'],...
            'HorizontalAlignment','left');

        uicontrol('Style','text',...
            'String','T & T +','FontSize',20,...
            'Position',[230 14 100 20]);
        framedist_val = uicontrol('Style','edit',...
                    'String',num2str(d),'FontSize',20,...
                    'Position',[320 8 35 30],'callback',@framedist);
%         uicontrol('Style','pushbutton','FontSize',10,...
%             'position',[320 35 29 30],'string','apply',...
%             @framedist)
        % Create pushbutton
%         uicontrol('style','pushbutton','units','pixels',...
%                         'position',[80 20 55 20],'string','start',...
%                         'callback',@p_animation);
%         uicontrol('style','pushbutton','units','pixels',...
%                         'position',[145 20 60 20],'string','stop',...
%                         'callback',@p_animestop);
%         stopanime = 0;

    end
    
    function framepos(source,callbackdata)
        FIG = gcf;
        hold off;
        idx = strsplit(FIG.Name,'#');
        idx = str2double(idx{2});
        trackvisualization(obj,idx,round(source.Value),0,d);
    end

    function framedist(source,callbackdata)
        FIG = gcf;
        hold off;
        idx = strsplit(FIG.Name,'#');
        idx = str2double(idx{2});
        trackvisualization(obj,idx,t,0,str2num(framedist_val.String));
    end
%     function p_animation(source,callbackdata)
%         FIG = gcf;
%         idx = strsplit(FIG.Name,'#');
%         idx = str2double(idx{2});
%         for frametemp = 1:size(obj.RESULTS(idx).mappedbound,3)-d
%             hold off;
%             trackvisualization(obj,idx,frametemp,0);
%             pause(0.01);
%         end
%     end
%     function p_animestop(source,callbackdata)
%         stopanime = 1;
%     end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% boundary tracking %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output_struct = BoundTrack12(bwmask,npoints,ext_field,dist,neigh,rawfluo,neigh2,um_pix,intvl)

    nslices = size(bwmask,3);

    if nslices <= 3
    disp('Number of frames is needed to be >3.');
    output_struct = NaN;
    else
    % dataname = inputname(1);
    % centroid = zeros(nslices,2);
    mappedbound = zeros(npoints,2,nslices);
    velocity = zeros(npoints,nslices-1);
    curvature = zeros(npoints,nslices-1);
    extField = zeros(npoints,nslices-1);
    fpIntensity = zeros(npoints,nslices-1);
    normvectpos = zeros(npoints,2,nslices-1);
    segmentpicth = zeros(nslices,1);
    penalty = zeros(npoints,nslices-1);

    %%%%%    progress bar    %%%%%
    %disp(' ');
    fprintf('>processing ');
    % fprintf(dataname);
    fprintf('\n');
    fprintf('>0--------25--------50--------75--------100%%\n>|');
    progbar = linspace(0,nslices,40);
    
    %%%%%    first slice     %%%%%
    [mappedbound(:,:,1),segmentpicth(1)] = Segmentation(Boundarydetect(bwmask(:,:,1)),npoints);
    count = length(find(progbar > 0 & progbar <= 1));
    if count ~= 0
        for j = 1:count; fprintf('='); end
    end

    %%%%% process all slices %%%%%
    %norm = zeros(npoints,2,nslices-1);
    %norm2 = zeros(npoints,1,nslices-1);
    for i = 2:nslices;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%      mapping      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [SegTemp,segmentpicth(i)] = Segmentation(Boundarydetect(bwmask(:,:,i)),npoints);
        SegCircTemp = cat(2,reshape(repmat(SegTemp(:,1),[2*npoints-1 1]),[2*npoints-1 1 npoints]),...
                            reshape(repmat(SegTemp(:,2),[2*npoints-1 1]),[2*npoints-1 1 npoints]));
        SegCircTemp = SegCircTemp(1:npoints,:,:);
        SumOfSquareDist = sum(sum((SegCircTemp - repmat(mappedbound(:,:,i-1),[1 1 npoints])).^2,2),1);
        penalty(:,i-1) = SumOfSquareDist;
        [M,I] = min(SumOfSquareDist);
        mappedbound(:,:,i) = circshift(SegTemp,I-1);

        %%%%%%%%%%%%%%%%%%%%%%%%%    velocity calculation  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tang = circshift(mappedbound(:,:,i-1),[-1 0]) - circshift(mappedbound(:,:,i-1),[1 0]);
        temptang = imfilter(repmat(tang,3,1),ones(11,1)/11);
        tang = temptang(size(tang,1)+1:2*size(tang,1),:);
        %tang2 = sqrt(sum(tang.^2,2));
        norm = cat(2,-1*tang(:,2),tang(:,1));
        norm2 = sqrt(sum(norm.^2,2));
        velocity(:,i-1) = dot(mappedbound(:,:,i)-mappedbound(:,:,i-1),norm,2)./norm2;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%    curvature calculation  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        P2 = circshift(mappedbound(:,:,i-1),[-25 0]) - circshift(mappedbound(:,:,i-1), [0 0]);
        P1 = circshift(mappedbound(:,:,i-1),  [0 0]) - circshift(mappedbound(:,:,i-1),[25 0]);
        cross = P2(:,1).*P1(:,2) - P1(:,1).*P2(:,2);
        P2P1 = sqrt(sum((P2+P1).^2,2));
        curvature(:,i-1) = 2*cross./(P2P1.*sqrt(sum(P1.^2,2)).*sqrt(sum(P2.^2,2)));

        %%%%%%%%%%%%%%%%%%%%%%    extrenal field calculation  %%%%%%%%%%%%%%%%%%%%%%%%%%
        normvectpos(:,:,i-1) = mappedbound(:,:,i-1) + norm./horzcat(norm2,norm2)*dist;
        if ~isempty(ext_field)
            normvectY = round(normvectpos(:,1,i-1));
            normvectX = round(normvectpos(:,2,i-1));
            for j = 1:size(normvectpos,1)
                try
                extField(j,i-1) = mean(mean(ext_field(normvectY(j)-neigh:normvectY(j)+neigh,...
                    normvectX(j)-neigh:normvectX(j)+neigh,i-1)));
                catch
                    extField(j,i-1) = NaN;
                end
            end
            
        end
        
        if dist == 0 %%% if dist is 0, normvectpos is norm=1.
            normvectpos(:,:,i-1) = mappedbound(:,:,i-1) + norm./horzcat(norm2,norm2)*1;
        end
        
        %%%%%%%%%%%%%%%   fluorescent protein intensity calculation  %%%%%%%%%%%%%%%%%%%
        if ~isempty(rawfluo)
            PIX = round(mappedbound(:,:,i-1)); %%nearest pixel of each points
            for j = 1:size(PIX);
                fpIntensity(j,i-1) = mean(mean(rawfluo(PIX(j,1)-neigh2:PIX(j,1)+neigh2,...
                    PIX(j,2)-neigh2:PIX(j,2)+neigh2,i-1)));
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  progress bar  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        count = length(find(progbar > i-1 & progbar <= i));
        if count ~= 0
            for j = 1:count; fprintf('='); end
        end
        if i==nslices; fprintf('|\n>finish\n'); end
    end
    
    %%%% smoothing and truncate %%%%
    tempv = imfilter(repmat(velocity,3,1),ones(3,3)/9);
    velocity = tempv(size(velocity,1)+1:2*size(velocity,1),2:end-1);
    curvature = curvature(:,2:end-1);
    extField = extField(:,2:end-1);
    fpIntensity = fpIntensity(:,2:end-1);
    
    Ymean = mean(mappedbound(:,1,:));
    Xmean = mean(mappedbound(:,2,:));
    centroidpos = [Ymean Xmean];
    centroidv   = reshape(sqrt(sum((centroidpos(:,:,2:end)-centroidpos(:,:,1:end-1)).^2,2)),1,[]);

    % output_struct.dataname = dataname;
    output_struct.centroidpos = centroidpos(:,:,2:end-2);
    output_struct.mappedbound = mappedbound(:,:,2:end-2);
    output_struct.normvectpos = normvectpos(:,:,2:end-1);
    output_struct.centroidv = centroidv(1,2:end-1)*um_pix/intvl*60;
    output_struct.velocity = velocity*um_pix/intvl*60;
    output_struct.curvature = curvature/um_pix;
    if ~isempty(ext_field); output_struct.extField = extField; end
    if ~isempty(rawfluo);   output_struct.fpIntensity = fpIntensity; end
    %output_struct.segmentpitch = segmentpicth;
    %output_struct.penalty = penalty;
    end
end

function [output,pitch] = Segmentation(data,npoints)
    output = zeros(npoints,2);
    L = length(data);
    dataPrev = vertcat(data(L,:),data(1:(L-1),:));
    dist = sqrt(sum((data - dataPrev).^2,2));  %% distance between each pixel
    cdist = cumsum(dist); %% cumulative summation
    D = sum(dist);
    pitch = D/npoints;
    cpitches = linspace(0,(D-pitch),npoints); %%segmented by npoints
    % disp(dist);
    for i = 1:npoints;
        j = 1;
        while cdist(j) <= cpitches(i)
            j = j+1;
        end
        output(i,:) = IntDivPoint(data(j-1,:),data(j,:),...
            abs(cdist(j-1)-cpitches(i)),abs(cdist(j)-cpitches(i)));
    end
end

function output = Boundarydetect(bwmask)
    %%%% define start position %%%%
    h = size(bwmask,1);
    w = size(bwmask,2);
    ini_point = zeros(1,2);
    frag = 0;
    for i = 1:h;
        for j = 1:w;
            if bwmask(i,j) ~= 0;
                ini_point(1,1) = i;
                ini_point(1,2) = j;
                frag = 1;
                break;
            end
        end
        if frag == 1; break; end
    end
    
    %%%%%    find contour     %%%%
    X = [1,1,0,-1,-1,-1, 0, 1];
    Y = [0,1,1, 1, 0,-1,-1,-1];
    output = ini_point;
    i = 3;
    START = 1;
    foundpoint = ini_point;
    while (sum((foundpoint - ini_point).^2) ~= 0) || (START == 1)
        i = rem(i+5,8);
        START = 0;
        while bwmask(foundpoint(1,1)+Y(i+1),foundpoint(1,2)+X(i+1)) == 0.0
            i = rem(i+1,8);
        end
        foundpoint = foundpoint + [Y(i+1),X(i+1)];
        output = cat(1,output,foundpoint);
    end
end

function output = IntDivPoint(Prev,Next,n,m)
% define internally dividing point
    output = zeros(1,2);
    output(1,1) = (Prev(1,1)*m + Next(1,1)*n) / (m + n);
    output(1,2) = (Prev(1,2)*m + Next(1,2)*n) / (m + n);
end
