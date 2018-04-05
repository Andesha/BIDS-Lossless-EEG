% GUI for input needed to create inputs for tagdir function.
%
% Usage:
%
%   >>  [baseMap, canceled, doSubDirs,inDir, preservePrefix, ...
%       selectFields, useGUI] = pop_tagdir_input()
%
% Output:
%
%   baseMap          A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used to initialize tag
%                    information.
%
%   canceled
%                    True if the cancel button is pressed. False if
%                    otherwise.
%
%   extensionsAllowed
%                    If true (default), the HED can be extended. If
%                    false, the HED can not be extended. The 
%                    'ExtensionAnywhere argument determines where the HED
%                    can be extended if extension are allowed.
%                  
%
%   extensionsAnywhere
%                    If true, the HED can be extended underneath all tags.
%                    If false (default), the HED can only be extended where
%                    allowed. These are tags with the 'extensionAllowed'
%                    attribute or leaf tags (tags that do not have
%                    children).
%
%   hedXML         
%                    Full path to a HED XML file. The default is the 
%                    HED.xml file in the hed directory. 
%
%   doSubDirs        If true (default) the entire inDir directory tree is
%                    searched. If false only the inDir directory is
%                    searched.
%
%   inDir
%                    The input directory containing .set files.
%
%   preservePrefix
%                    If false (default), tags for the same field value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
%   selectFields
%                    If true (default), the user is presented with a
%                    GUI that allow users to select which fields to tag.
%
%   useGUI
%                    If true (default), the CTAGGER GUI is displayed after
%                    initialization.
%
% Copyright (C) 2012-2016 Thomas Rognon tcrognon@gmail.com,
% Jeremy Cockfield jeremy.cockfield@gmail.com, and
% Kay Robbins kay.robbins@utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function [canceled, baseMap, doSubDirs, hedExtensionsAllowed, ...
    hedExtensionsAnywhere, hedXml, inDir, preserveTagPrefixes, ...
    selectEventFields, useCTagger] = pop_tagdir_input(varargin)
p = parseArguments(varargin{:});
baseMap = p.BaseMap;
canceled = true;
doSubDirs = p.DoSubDirs;
hedExtensionsAllowed = p.HedExtensionsAllowed;
hedExtensionsAnywhere = p.HedExtensionsAnywhere;
hedXml = p.HedXml;
inDir = p.InDir;
preserveTagPrefixes = p.PreserveTagPrefixes;
selectEventFields = p.SelectEventFields;
useCTagger = p.UseCTagger;
title = 'Inputs for tagging directory of .set data files';
inputFig = figure( ...
    'Color', [.94 .94 .94], ...
    'MenuBar', 'none', ...
    'Name', title, ...
    'NextPlot', 'add', ...
    'NumberTitle','off', ...
    'Resize', 'on', ...
    'Tag', title, ...
    'Toolbar', 'none', ...
    'Visible', 'off', ...
    'WindowStyle', 'modal');
createLayout();
movegui(inputFig); % Make sure it is visible
uiwait(inputFig);

    function createLayout()
        % Creates the GUI layout
        createBrowsePanel();
        createExtensionPanel();
        createOptionsGroupPanel();
        createButtonPanel();
    end % createLayout

    function browseBaseTagsCallback(~, ~)
        % Callback for 'Browse' button that sets the 'Base tags' editbox
        [file, path] = uigetfile({'*.mat', 'MATLAB Files (*.mat)'}, ...
            'Browse for event tags');
        tagsFile = fullfile(path, file);
        if ischar(file) && ~isempty(file) && validateBaseTags(tagsFile)
            baseMap = fullfile(path, file);
            set(findobj('Tag', 'BaseTags'), 'String', baseMap);
        end
    end % browseBaseTagsCallback

    function browseHedXMLCallback(src, eventdata, myTitle) %#ok<INUSL>
        % Callback for 'Browse' button that sets the 'HED' editbox
        [tFile, tPath] = uigetfile({'*.xml', 'XML files (*.xml)'}, ...
            myTitle);
        if tFile ~= 0
            hedXml = fullfile(tPath, tFile);
            set(findobj('Tag', 'HEDXMLEB'), 'String', hedXml);
        end
    end % browseHedXMLCallback

    function createBrowsePanel()
        % Creates top panel used for browsing for files
        browsePanel = uipanel('BorderType','none', ...
            'BackgroundColor',[.94 .94 .94],...
            'FontSize',12,...
            'Position',[0 .7 1 .3]);
        uicontrol('Parent', browsePanel, ...
            'Style','text', ...
            'String', 'HED file', ...
            'Units','normalized',...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.015 0.8 0.1 0.13]);
        uicontrol('Parent', browsePanel, ...
            'Style','text', 'String', 'Directory', ...
            'Units','normalized',...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.015 0.5 0.1 0.13]);
        uicontrol('Parent', browsePanel, ...
            'Style','text', 'String', 'Import tags', ...
            'Units','normalized',...
            'HorizontalAlignment', 'Left', ...
            'Position', [0.015 0.2 0.13 0.13]);
        uicontrol('Parent', browsePanel, ...
            'Style', 'edit', ...
            'BackgroundColor', 'w', ...
            'HorizontalAlignment', 'Left', ...
            'Tag', 'HEDXMLEB', ...
            'String', hedXml, ...
            'TooltipString', 'The HED XML file.', ...
            'Units','normalized',...
            'Callback', {@hedEditBoxCallback}, ...
            'Position', [0.15 0.7 0.6 0.25]);
        uicontrol('Parent', browsePanel, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'Directory', 'String', inDir, ...
            'TooltipString', ...
            'Directory of .set files', ...
            'Units','normalized',...
            'Callback', @directoryEditboxCallback, ...
            'Position', [0.15 0.4 0.6 0.25]);
        uicontrol('Parent', browsePanel, 'style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'BaseTags', 'String', baseMap, ...
            'TooltipString', ...
            'Complete path for loading the consolidated event tags', ...
            'Units','normalized',...
            'Callback', @baseTagsEditboxCallback, ...
            'Position', [0.15 0.1 0.6 0.25]);
        uicontrol('Parent', browsePanel, ...
            'string', 'Browse', ...
            'style', 'pushbutton', ...
            'TooltipString', 'Press to bring up file chooser', ...
            'Units', 'normalized',...
            'Callback', {@browseHedXMLCallback, ...
            'Browse for HED XML file'}, ...
            'Position', [0.775 .7 0.21 0.25]);
        uicontrol('Parent', browsePanel, ...
            'string', 'Browse', ...
            'style', 'pushbutton', 'TooltipString', ...
            'Press to bring up directory chooser', ...
            'Units','normalized',...
            'Callback', @browseDirectoryCallback, ...
            'Position', [0.775 0.4 0.21 0.25]);
        uicontrol('Parent', browsePanel, ...
            'string', 'Browse', 'style', 'pushbutton', ...
            'TooltipString', 'Press to choose import event tag file', ...
            'Units','normalized',...
            'Callback', @browseBaseTagsCallback, ...
            'Position', [0.775 0.1 0.21 0.25]);
    end % createBrowsePanel

    function createExtensionPanel()
        % Create the panel for extension options
        bg = uibuttongroup('Title', 'HED extension options', ...
            'Position', [0.15 .43 .6 .3],...
            'FontSize',12,...
            'SelectionChangeFcn',@extensionsCallback);
        b1 = uicontrol(bg,'Style',...
            'radiobutton',...
            'Units','normalized', ...
            'Tag', 'WhereAllowed', ...
            'String','Only where allowed',...
            'Position',[0.15 0.66 0.8 0.33],...
            'HandleVisibility','off');
        b2 = uicontrol(bg,'Style','radiobutton',...
            'Units','normalized', ...
            'Tag','Anywhere',...
            'String','Anywhere',...
            'Position',[0.15 0.33 0.8 0.33],...
            'HandleVisibility','off');     
        b3 = uicontrol(bg,'Style','radiobutton',...
            'Units','normalized', ...
            'Tag','Nowhere',...
            'String','Nowhere',...
            'Position',[0.15 0 0.8 0.33],...
            'HandleVisibility','off');
        setDefaultExtensionOption(bg, b1, b2, b3);
    end % createExtensionPanel

    function setDefaultExtensionOption(bg, b1, b2, b3)
        % Sets the 'HED extension options' 
        if hedExtensionsAllowed && ~hedExtensionsAnywhere
            set(bg,'SelectedObject', b1);
        elseif hedExtensionsAllowed && hedExtensionsAnywhere
            set(bg,'SelectedObject', b2);
        else
            set(bg,'SelectedObject', b3);
        end
    end % setDefaultExtensionOption

    function extensionsCallback(src, ~)
        % Callback for 'HED extension options' radio button group
        if strcmp('WhereAllowed', src.SelectedObject.Tag)
            hedExtensionsAllowed = true;
            hedExtensionsAnywhere = false;
        elseif strcmp('Anywhere', src.SelectedObject.Tag)
            hedExtensionsAllowed = true;
            hedExtensionsAnywhere = true;
        else
            hedExtensionsAllowed = false;
            hedExtensionsAnywhere = false;
        end
    end % extensionsCallback

    function createOptionsGroupPanel()
        % Create the button panel in the middle of the GUI
        optionGroupPanel = uipanel('BackgroundColor',[.94,.94,.94],...
            'FontSize',12,...
            'Title','Additional options', ...
            'Position', [0.15 .12 .6 .3]);
        uicontrol('Parent', optionGroupPanel, ...
            'Style', 'CheckBox', 'Tag', 'DoSubDirsCB', ...
            'String', 'Look in subdirectories', 'Enable', 'on', 'Tooltip', ...
            'If checked, traverse all subdirectories to process .set dataset files', ...
            'Units','normalized', ...
            'Value', 1, ...
            'Callback', @doSubDirsCallback, ...
            'Position', [0.15 0.8 0.8 0.15]);
        uicontrol('Parent', optionGroupPanel, ...
            'Style', 'CheckBox', 'Tag', 'UseGUICB', ...
            'String', 'Use CTagger', 'Enable', 'on', 'Tooltip', ...
            'If checked, use CTagger for each selected field', ...
            'Units','normalized', ...
            'Value', 1, ...
            'Callback', @useCTaggerCallback, ...
            'Position', [0.15 0.55 0.8 0.15]);
        uicontrol('Parent', optionGroupPanel, ...
            'Style', 'CheckBox', 'Tag', 'SelectFieldsCB', ...
            'String', 'Select fields to tag', 'Enable', 'on', ...
            'Tooltip', ...
            'If checked, use menu to select fields to tag', ...
            'Units','normalized', ...
            'Value', 1, ...
            'Callback', @selectFieldsCallback, ...
            'Position', [0.15 0.3 0.8 0.15]);
        uicontrol('Parent', optionGroupPanel, ...
            'Style', 'CheckBox', 'Tag', 'PreservePrefixCB', ...
            'String', 'Preserve tag prefixes', 'Enable', 'on', 'Tooltip', ...
            'If checked, do not consolidate tags that share prefixes', ...
            'Units','normalized', ...
            'Value', 0, ...
            'Callback', @preservePrefixCallback, ...
            'Position', [0.15 0.05 0.9 0.15]);
    end % createOptionsGroupPanel

    function createButtonPanel()
        % Create the button panel at the bottom of the GUI
        rewriteGroupPanel = uipanel('BorderType','none', ...
            'BackgroundColor',[.94 .94 .94],...
            'FontSize',12,...
            'Position', [0.6 0 .4 .1]);
        uicontrol('Parent', rewriteGroupPanel, ...
            'Style', 'pushbutton', 'Tag', 'OkayButton', ...
            'String', 'Okay', 'Enable', 'on', 'Tooltip', ...
            'Continue', ...
            'Units','normalized', ...
            'Callback', {@okayCallback}, ...
            'Position',[0.025 0.1 0.45 .9]);
        uicontrol('Parent', rewriteGroupPanel, ...
            'Style', 'pushbutton', 'Tag', 'CancelButton', ...
            'String', 'Cancel', 'Enable', 'on', 'Tooltip', ...
            'Cancel', ...
            'Units','normalized', ...
            'Callback', {@cancelCallback}, ...
            'Position',[0.515 0.1 0.45 .9]);
    end % createButtonPanel

    function cancelCallback(src, eventdata)  %#ok<INUSD>
        % Callback for 'Cancel' button
        baseMap = '';
        canceled = true;
        preserveTagPrefixes = false;
        selectEventFields = true;
        useCTagger = true;
        close(inputFig);
    end % cancelCallback

    function hedEditBoxCallback(src, ~) 
        % Callback for user directly editing the HED XML editbox
        xml = get(src, 'String');
        if exist(xml, 'file')
            hedXml = xml;
        else 
            errordlg(['XML file is invalid. Setting the XML' ...
                ' file back to the previous file.'], ...
                'Invalid XML file', 'modal');
        end
        set(src, 'String', hedXml);
    end % hedEditBoxCallback

    function okayCallback(src, eventdata)  %#ok<INUSD>
        % Callback for 'Okay' button
        if isempty(inDir)
            errordlg(['Input directory is empty. User input is' ...
                ' required.'], 'Input required', 'modal');
            return;
        end
        canceled = false;
        close(inputFig);
    end % okayCallback

    function p = parseArguments(varargin)
        % Parses the input arguments and returns the results
        parser = inputParser;
        parser.addParamValue('BaseMap', '', @ischar);
        parser.addParamValue('DoSubDirs', true, @islogical);
        parser.addParamValue('HedExtensionsAllowed', true, @islogical);
        parser.addParamValue('HedExtensionsAnywhere', false, @islogical);
        parser.addParamValue('HedXml', which('HED.xml'), @ischar);
        parser.addParamValue('InDir', '', @(x) (~isempty(x) && ischar(x)));
        parser.addParamValue('PreserveTagPrefixes', false, @islogical);
        parser.addParamValue('SelectEventFields', true, @islogical);
        parser.addParamValue('UseCTagger', true, @islogical);
        parser.parse(varargin{:});
        p = parser.Results;
    end % parseArguments

    function preservePrefixCallback(src, ~)
        % Callback for user directly editing the 'Preserve tag prefixes'
        % checkbox
        preserveTagPrefixes = get(src, 'Max') == get(src, 'Value');
    end % preservePrefixCallback

    function selectFieldsCallback(src, eventdata) %#ok<INUSD>
        % Callback for user directly editing the 'Select fields to tag'
        % checkbox
        selectEventFields = get(src, 'Max') == get(src, 'Value');
    end % selectFieldsCallback

    function baseTagsEditboxCallback(hObject, eventdata, tagsCtrl) %#ok<INUSD>
        % Callback for user directly editing the 'Base tags' editbox
        tagsFile = get(src, 'String');
        if ~isempty(strtrim(tagsFile)) && validateBaseTags(tagsFile)
            baseMap = tagsFile;
        end
    end % baseTagsEditboxCallback

    function valid = validateBaseTags(tagsFile)
        % Checks to see if the 'Base tags' passed in is valid
        valid = true;
        if isempty(fieldMap.loadFieldMap(tagsFile))
            valid = false;
            warndlg([ tagsFile ...
                ' is a invalid base tag file'], 'Invalid file');
            set(findobj('Tag', 'BaseTags'), 'String', baseMap);
        end
    end % validateBaseTags

    function useCTaggerCallback(src, ~)
        % Callback for user directly editing the 'Use CTagger' checkbox
        useCTagger = get(src, 'Max') == get(src, 'Value');
        if ~useCTagger
            set(findobj('Tag', 'SelectFieldsCB'), 'Enable', 'off');
            set(findobj('Tag', 'PreservePrefixCB'), 'Enable', 'off');
        else
            set(findobj('Tag', 'SelectFieldsCB'), 'Enable', 'on');
            set(findobj('Tag', 'PreservePrefixCB'), 'Enable', 'on');
        end
    end % useCTaggerCallback

    function browseDirectoryCallback(~, ~)
        % Callback for browse button that sets a input directory
        directory = uigetdir(pwd, 'Browse for input directory');
        if directory ~= 0
            set(findobj('Tag', 'Directory'), 'String', directory);
            inDir = directory;
        end
    end % browseDirectoryCallback

    function directoryEditboxCallback(src, ~)
        % Callback for user directly editing the 'Directory' editbox
        directoryName = get(src, 'String');
        if isdir(directoryName)
            inDir = directoryName;
        else  % if user entered invalid directory reset back
            set(src, 'String', inDir);
        end
    end % directoryEditboxCallback

    function doSubDirsCallback(src, ~)
        % Callback for user directly editing the 'Look in subdirectories'
        % checkbox
        doSubDirs = get(src, 'Max') == get(src, 'Value');
    end % doSubDirsCallback

end % pop_tagdir_input