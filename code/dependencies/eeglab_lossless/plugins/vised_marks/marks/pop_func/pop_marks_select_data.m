function [EEG,com]=pop_marks_select_data(EEG,infotype,indexes,varargin)

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            


% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_marks_purge_data;
	return;
end;	

%% INITIATE VARARGIN STRUCTURES...
try
    options = varargin;
    for index = 1:length(options)
        if iscell(options{index}) && ~iscell(options{index}{1}), options{index} = { options{index} }; end;
    end;
    if ~isempty( varargin ), g=struct(options{:});
    else g= []; end;
catch
    disp('ve_eegplot() error: calling convention {''key'', value, ... } error'); return;
end;

try g.labels;   catch, g.labels ={''};end
try g.exact;    catch, g.exact  ='on';end
try g.remove;   catch, g.remove ='off';end
try g.gui;      catch, g.gui    ='off';end

%% handle inputs
if EEG.trials==1;
    infotype_cell={'time marks','time points','time ms','channel marks','channel indexes'};
else
    infotype_cell={'time marks','time points','time ms','epochs','channel marks','channel indexes'};
end
ninfotype=length(infotype_cell);

if ~isempty(EEG.icaweights);
    infotype_cell{ninfotype+1}='component marks';
    infotype_cell{ninfotype+2}='component indexes';
end

if exist('infotype');
    infotype_ind=find(strcmp(infotype,infotype_cell));
else
    infotype_ind=1;
end

%% pop up window
% -------------
if nargin < 3 || strcmp(g.gui,'on')
    
    results=inputgui( ...
        {[1] [3 3] [1] [3 3] [5 1] [5 1] [1]}, ...
        {...
        ... %1
        {'style','text','string',blanks(100)}, ...
        ... %2
        {'Style', 'text', 'string', 'Information category to use in the selection'}, ...
        {'Style', 'popup', 'string', infotype_cell, 'value',infotype_ind,'tag', 'pop_it',...
        'callback', ...
        ['s=get(findobj(gcbf,''tag'',''pop_it''),''string'');', ...
        'v=get(findobj(gcbf,''tag'',''pop_it''),''value'');', ...
        'switch s{v};' ...
        '    case ''time marks'';' ...
        '        tmp_labels = {EEG.marks.time_info.label};' ...
        '        set(findobj(gcbf, ''tag'', ''but_lab''), ''callback'',' ...
        '            [''[label_ind,label_str,label_cell]=pop_chansel({EEG.marks.time_info.label});' ...
        '             set(findobj(gcbf,''''tag'''',''''edt_lab''''),''''string'''', vararg2str(label_cell));', ...
        '             eval(get(findobj(gcbf,''''tag'''',''''but_ind''''),''''callback''''));'']);' ...
        '        set(findobj(gcbf,''tag'',''edt_lab''),''string'','''',''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''but_lab''),''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''chk_exact''),''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''edt_ind''),''string'','''');' ...
        '        set(findobj(gcbf,''tag'',''but_ind''),''enable'',''on'');' ...
        '    case {''time points'' ''time ms'' ''epochs''};' ...
        '        set(findobj(gcbf,''tag'',''edt_lab''),''string'', '''',''enable'',''off'');' ...
        '        set(findobj(gcbf,''tag'',''but_lab''),''enable'',''off'');' ...
        '        set(findobj(gcbf,''tag'',''chk_exact''),''enable'',''off'');' ...
        '        set(findobj(gcbf,''tag'',''edt_ind''),''string'','''');' ...
        '        set(findobj(gcbf,''tag'',''but_ind''),''enable'',''off'');' ...
        '    case ''channel marks'';' ...
        '        tmp_labels = {EEG.marks.chan_info.label};' ...
        '        set(findobj(gcbf,''tag'',''but_lab''),''callback'',' ...
        '            [''[label_ind,label_str,label_cell]=pop_chansel({EEG.marks.chan_info.label});' ...
        '             set(findobj(gcbf,''''tag'''',''''edt_lab''''),''''string'''',vararg2str(label_cell));', ...
        '             eval(get(findobj(gcbf,''''tag'''',''''but_ind''''),''''callback''''));'']);' ...
        '        set(findobj(gcbf,''tag'',''edt_lab''),''string'','''',''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''but_lab''),''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''chk_exact''),''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''edt_ind''),''string'','''');' ...
        '        set(findobj(gcbf,''tag'',''but_ind''),''enable'',''on'');' ...
        '    case ''channel indexes'';' ...
        '        tmp_labels = {EEG.chanlocs.labels};' ...
        '        set(findobj(gcbf,''tag'',''but_lab''),''callback'',' ...
        '            [''[flaglabel_ind,flaglabel_str,flaglabel_cell]=pop_chansel({EEG.chanlocs.labels});' ...
        '             set(findobj(gcbf,''''tag'''',''''edt_lab''''),''''string'''', vararg2str(flaglabel_cell));', ...
        '             eval(get(findobj(gcbf,''''tag'''',''''but_ind''''),''''callback''''));'']);' ...
        '        set(findobj(gcbf,''tag'',''edt_lab''),''string'','''',''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''but_lab''),''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''chk_exact''),''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''edt_ind''),''string'','''');' ...
        '        set(findobj(gcbf,''tag'',''but_ind''),''enable'',''on'');' ...
        '    case ''components marks'';' ...
        '        tmp_labels = {EEG.marks.comp_info.label};' ...
        '        set(findobj(gcbf,''tag'',''but_lab''),''callback'',' ...
        '            [''[flaglabel_ind,flaglabel_str,flaglabel_cell]=pop_chansel({EEG.marks.comp_info.label});' ...
        '             set(findobj(gcbf,''''tag'''',''''edt_lab''''),''''string'''', vararg2str(flaglabel_cell));', ...
        '             eval(get(findobj(gcbf,''''tag'''',''''but_ind''''),''''callback''''));'']);' ...
        '        set(findobj(gcbf,''tag'',''edt_lab''),''string'','''',''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''but_lab''),''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''chk_exact''),''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''edt_ind''),''string'','''');' ...
        '        set(findobj(gcbf,''tag'',''but_ind''),''enable'',''on'');' ...
        '    case ''component indexes'';' ...
        '        tmp_labels = cellstr(num2str([1:min(size(EEG.icaweights))]''));' ...
        '        set(findobj(gcbf,''tag'',''but_lab''),''callback'',' ...
        '            [''[flaglabel_ind,flaglabel_str,flaglabel_cell]=pop_chansel(cellstr(num2str([1:min(size(EEG.icaweights))]'''')));' ...
        '             set(findobj(gcbf,''''tag'''',''''edt_lab''''),''''string'''', vararg2str(flaglabel_cell));', ...
        '             eval(get(findobj(gcbf,''''tag'''',''''but_ind''''),''''callback''''));'']);' ...
        '        set(findobj(gcbf,''tag'',''edt_lab''),''string'','''',''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''but_lab''),''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''chk_exact''),''enable'',''on'');' ...
        '        set(findobj(gcbf,''tag'',''edt_ind''),''string'','''');' ...
        '        set(findobj(gcbf,''tag'',''but_ind''),''enable'',''on'');' ...
        '    end;', ...
        ]}, ...
        ... %3
        {}, ...
        ...
        {'Style', 'text', 'string', 'Specific information for data selection'},...
        {'style','checkbox','string','use exact labels in selection','tag','chk_exact','value',1}, ...
        ... %4
        {'Style', 'edit', 'string', '', 'tag', 'edt_lab'}, ...
        {'Style', 'pushbutton', 'string', '...','tag','but_lab', ...
        'callback', ['[label_ind,label_str,label_cell]=pop_chansel({EEG.marks.time_info.label});' ...
        'set(findobj(gcbf, ''tag'', ''edt_lab''), ''string'', vararg2str(label_cell));', ...
        'eval(get(findobj(gcbf,''tag'',''but_ind''),''callback''));']}, ...
        ...
        {'style','edit','string','','tag','edt_ind'}, ...
        {'style','pushbutton','string','Indexes','tag','but_ind', ...
        'callback',...
        ['s=get(findobj(gcbf,''tag'',''pop_it''),''string'');', ...
        'v=get(findobj(gcbf,''tag'',''pop_it''),''value'');', ...
        'switch s{v};' ...
        '    case ''time marks'';' ... %time marks
        '        labs_cell=eval([''{'',(get(findobj(gcbf,''tag'',''edt_lab''),''string'')),''}'']);'...
        '        exact_str=''off'';if get(findobj(gcbf,''tag'',''chk_exact''),''value'');exact_str=''on'';end;' ...
        '        set(findobj(gcbf,''tag'',''edt_ind''),' ...
        '            ''string'',vararg2str(marks_label2index(EEG.marks.time_info,labs_cell,''indexes'',''exact'',exact_str)));'...
        '    case ''channel marks'';' ... %channel marks
        '        labs_cell=eval([''{'',(get(findobj(gcbf,''tag'',''edt_lab''),''string'')),''}'']);'...
        '        exact_str=''off'';if get(findobj(gcbf,''tag'',''chk_exact''),''value'');exact_str=''on'';end;' ...
        '        set(findobj(gcbf,''tag'',''edt_ind''),' ...
        '            ''string'',vararg2str(marks_label2index(EEG.marks.chan_info,labs_cell,''indexes'',''exact'',exact_str)));'...
        '    case ''channel indexes'';' ... %channel indexes
        '        all_labs_cell={EEG.chanlocs.labels};'...
        '        labs_cell=eval([''{'',(get(findobj(gcbf,''tag'',''edt_lab''),''string'')),''}'']);'...
        '        if ~get(findobj(gcbf,''tag'',''chk_exact''),''value'');' ...
        '            labs_cell=marks_match_label(labs_cell,all_labs_cell);'...
        '        end;'...
        '        labs_ind=[];'...
        '        j=0;'...
        '        for i=1:length(labs_cell);'...
        '            for ii=1:length({EEG.chanlocs.labels});'...
        '                if strcmp(labs_cell{i},all_labs_cell{ii});'...
        '                    j=j+1;'...
        '                    labs_ind(j)=ii;'...
        '                end;'...
        '            end;'...
        '        end;'...
        '        set(findobj(gcbf,''tag'',''edt_ind''),' ...
        '            ''string'',vararg2str(labs_ind));'...
        '    case ''component marks'';' ... %component marks
        '        labs_cell=eval([''{'',(get(findobj(gcbf,''tag'',''edt_lab''),''string'')),''}'']);'...
        '        exact_str=''off'';if get(findobj(gcbf,''tag'',''chk_exact''),''value'');exact_str=''on'';end;' ...
        '        set(findobj(gcbf,''tag'',''edt_ind''),' ...
        '            ''string'',vararg2str(marks_label2index(EEG.marks.comp_info,labs_cell,''indexes'',''exact'',exact_str)));'...
        '    case ''component indexes'';' ... %component indexes
        '        all_labs_cell=cellstr(num2str([1:min(size(EEG.icaweights))]''));'...
        '        labs_cell=eval([''{'',(get(findobj(gcbf,''tag'',''edt_lab''),''string'')),''}'']);'...
        '        if ~get(findobj(gcbf,''tag'',''chk_exact''),''value'');' ...
        '            labs_cell=marks_match_label(labs_cell,all_labs_cell);'...
        '        end;'...
        '        labs_ind=[];'...
        '        j=0;'...
        '        for i=1:length(labs_cell);'...
        '            for ii=1:length(all_labs_cell);'...
        '                if strcmp(strtrim(labs_cell{i}),strtrim(all_labs_cell{ii}));'...
        '                    j=j+1;'...
        '                    labs_ind(j)=ii;'...
        '                end;'...
        '            end;'...
        '        end;'...
        '        set(findobj(gcbf,''tag'',''edt_ind''),' ...
        '            ''string'',vararg2str(labs_ind));'...
        '    end;' ...
        ]}, ...
        ...
        {'style','checkbox','string','Remove these indexes','value',0}, ...
        ...
        }, ...
        'pophelp(''pop_marks_select_data'');', 'Select data compatible with the marks structure -- pop_marks_select_data()' ...
        );
    if isempty(results);return;end;
    
    infotype_ind  	 = results{1};
    infotype=infotype_cell{infotype_ind};
    exact_val        = results{2};
    if exact_val
        g.exact='on';
    else
        g.exact='off';
    end
    
    g.labels     	 =eval(['{',results{3},'};']);
    indexes          =eval(['[',results{4},'];']);
    if results{5};
        g.remove='on';
    else
        g.remove='off';
    end
    
end



%% perform purge...
switch infotype
    
    case {'time marks' 'time points' 'time ms'}
        
        switch infotype
            case 'time marks'
                %get the indexes from the infotype and labels if the array is empty...
                if isempty(indexes)
                    indexes=marks_label2index(EEG.marks.time_info,g.labels,'indexes','exact',g.exact);
                end
                
            case 'time ms'
                %convert the millisecond values into point indexes...
                indexes=round(indexes*(EEG.srate/1000));
                
        end
        
        %generate flags array from indexes...
        flags=zeros(1,EEG.pnts);
        flags(indexes)=1;

        %invert the flags if 'remove' is selected...
        if strcmp(g.remove,'on');flags=~flags;end
        
        %convert flags into indexes and bounds...
        indexes=find(flags);
        diffs=find(diff(flags));
        if flags(1)==1;diffs=[0,diffs];end
        if flags(length(flags))==1;diffs=[diffs,length(flags)];end
        bounds=reshape(diffs,2,length(diffs)/2)';
        bounds(:,1)=bounds(:,1)+1;
        
        %perform the index selection on the marks structure...
        for i=1:length(EEG.marks.time_info)
            EEG.marks.time_info(i).flags=EEG.marks.time_info(i).flags(indexes);
        end
        
        %perform the index selection on the data array...
        EEG=pop_select(EEG,'point',bounds);

    case {'channel marks' 'channel indexes'}
        
        if strcmp(infotype,'channel marks')
            %get the indexes from the infotype and labels if the array is empty...
            if isempty(indexes)
                indexes=marks_label2index(EEG.marks.chan_info,g.labels,'indexes','exact',g.exact);
            end
        end
        
        %generate flags array from indexes...
        flags=zeros(EEG.nbchan,1);
        flags(indexes)=1;

        %invert the flags if 'remove' is selected...
        if strcmp(g.remove,'on');flags=~flags;end
        
        %convert flags into indexes...
        indexes=find(flags);
        
        %perform the index selection on the marks structure...
        for i=1:length(EEG.marks.chan_info)
            EEG.marks.chan_info(i).flags=EEG.marks.chan_info(i).flags(indexes);
        end
        
        %perform the index selection on the data array...
        EEG=pop_select(EEG,'channel',indexes);
        
    case {'component marks' 'component indexes'}
        
        if strcmp(infotype,'component marks')
            %get the indexes from the infotype and labels if the array is empty...
            if isempty(indexes)
                indexes=marks_label2index(EEG.marks.comp_info,g.labels,'indexes','exact',g.exact);
            end
        end
        
        %generate flags array from indexes...
        flags=zeros(min(size(EEG.icaweights)),1);
        flags(indexes)=1;

        %invert the flags if 'remove' is selected...
        if strcmp(g.remove,'on');flags=~flags;end
        
        %convert flags into indexes...
        indexes=find(flags);
        
        %perform the index selection on the marks structure...
        for i=1:length(EEG.marks.comp_info)
            EEG.marks.comp_info(i).flags=EEG.marks.comp_info(i).flags(indexes);
        end
        
        %perform the index selection on the data array...
        EEG=pop_subcomp(EEG,setdiff([1:min(size(EEG.icaweights))],indexes));
        
end
% create the string command
% -------------------------
%com = ['EEG = pop_marks_purgedata(EEG,''',infotype_cell{infotype_ind},''',{',g.labels,'});'];
%exec_com = ['EEG = marks_purgedata(EEG,''',infotype_cell{infotype_ind},''',{',g.labels,'});']

%eval(exec_com)