classdef LMM_QC_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        BloodPressureAnalyisisUIFigure  matlab.ui.Figure
        ImageTableLabel                 matlab.ui.control.Label
        ObjectsTableLabel               matlab.ui.control.Label
        UITable_Image                   matlab.ui.control.Table
        filenameLabel                   matlab.ui.control.Label
        ImageLabel                      matlab.ui.control.Label
        nLabel                          matlab.ui.control.Label
        ObjectLabel                     matlab.ui.control.Label
        NextObjectButton                matlab.ui.control.Button
        PreviousObjectButton            matlab.ui.control.Button
        YellowPointsTertiaryButtonGroup  matlab.ui.container.ButtonGroup
        mmButton_6                      matlab.ui.control.RadioButton
        inButton_18                     matlab.ui.control.RadioButton
        CyanPointsSecondaryButtonGroup  matlab.ui.container.ButtonGroup
        inButton_17                     matlab.ui.control.RadioButton
        inButton_16                     matlab.ui.control.RadioButton
        inButton_15                     matlab.ui.control.RadioButton
        inButton_14                     matlab.ui.control.RadioButton
        WrongButton_3                   matlab.ui.control.RadioButton
        inButton_13                     matlab.ui.control.RadioButton
        cmButton_3                      matlab.ui.control.RadioButton
        mmButton_5                      matlab.ui.control.RadioButton
        mmButton_4                      matlab.ui.control.RadioButton
        inButton_12                     matlab.ui.control.RadioButton
        GreenPointsPrimaryButtonGroup   matlab.ui.container.ButtonGroup
        inButton_11                     matlab.ui.control.RadioButton
        inButton_10                     matlab.ui.control.RadioButton
        inButton_9                      matlab.ui.control.RadioButton
        inButton_8                      matlab.ui.control.RadioButton
        WrongButton_2                   matlab.ui.control.RadioButton
        inButton_7                      matlab.ui.control.RadioButton
        cmButton_2                      matlab.ui.control.RadioButton
        mmButton_3                      matlab.ui.control.RadioButton
        mmButton                        matlab.ui.control.RadioButton
        inButton_6                      matlab.ui.control.RadioButton
        inButton_5                      matlab.ui.control.RadioButton
        inButton_4                      matlab.ui.control.RadioButton
        inButton_3                      matlab.ui.control.RadioButton
        inButton_2                      matlab.ui.control.RadioButton
        WrongButton                     matlab.ui.control.RadioButton
        inButton                        matlab.ui.control.RadioButton
        cmButton                        matlab.ui.control.RadioButton
        mmButton_2                      matlab.ui.control.RadioButton
        OpenQCFileButton                matlab.ui.control.Button
        SaveButton                      matlab.ui.control.Button
        QuitButton                      matlab.ui.control.Button
        PreviousImageButton             matlab.ui.control.Button
        NextImageButton                 matlab.ui.control.Button
        Image                           matlab.ui.control.Image
        Image1                          matlab.ui.control.Image
        UITable_Objects                 matlab.ui.control.Table
    end


    methods (Access = private)
    
        function updateplot(app)
            % Get Table UI component data
            t = app.UITable_Objects.DisplayData;            
            
            % Plot modified data 
            x2 = t.Age;
            y2 = t.BloodPressure(:,2);
            plot(app.UIAxes2,x2,y2,'-o');
        end
        
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Read table array from file
            t = readtable('patients.xls');
            vars = {'Age','Systolic','Diastolic','SelfAssessedHealthStatus','Smoker'};
            
            % Select a subset of the table array
            t = t(1:20,vars);
            
            % Sort the data by age
            t = sortrows(t,'Age');
            
            % Combine Systolic and Diastolic into one variable
            t.BloodPressure = [t.Systolic t.Diastolic];
            t.Systolic = [];
            t.Diastolic = [];
            
            % Convert SelfAssessedHealthStatus to categorical
            cats = categorical(t.SelfAssessedHealthStatus,{'Poor','Fair','Good','Excellent'});
            t.SelfAssessedHealthStatus = cats;
            
            % Rearrange columns
            t = t(:,[1 4 3 2]);
            
            % Add data to the Table UI Component
            app.UITable_Objects.Data = t;
            
            % Plot the original data
            x1 = app.UITable_Objects.Data.Age;
            y1 = app.UITable_Objects.Data.BloodPressure(:,2);
            plot(app.UIAxes,x1,y1,'o-');
            
            % Plot the data
            updateplot(app);
        end

        % Display data changed function: UITable_Objects
        function UITable_ObjectsDisplayDataChanged(app, event)
            % Update the plots when user sorts the columns of the table
            updateplot(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create BloodPressureAnalyisisUIFigure and hide until all components are created
            app.BloodPressureAnalyisisUIFigure = uifigure('Visible', 'off');
            app.BloodPressureAnalyisisUIFigure.Position = [100 100 1777 1120];
            app.BloodPressureAnalyisisUIFigure.Name = 'Blood Pressure Analyisis';

            % Create UITable_Objects
            app.UITable_Objects = uitable(app.BloodPressureAnalyisisUIFigure);
            app.UITable_Objects.ColumnName = {'ObjectName'; 'PixelsPerUnit_1'; 'Unit_1'; 'PixelsPerUnit_2'; 'Unit_2'; 'PixelsPerUnit_3'; 'Unit_3'; 'ValidationMessage'; 'ValidationScore'; 'ObjectFileLocation'};
            app.UITable_Objects.RowName = {};
            app.UITable_Objects.ColumnSortable = [true false true true];
            app.UITable_Objects.ColumnEditable = [true false true true];
            app.UITable_Objects.DisplayDataChangedFcn = createCallbackFcn(app, @UITable_ObjectsDisplayDataChanged, true);
            app.UITable_Objects.Position = [27 270 1186 311];

            % Create Image1
            app.Image1 = uiimage(app.BloodPressureAnalyisisUIFigure);
            app.Image1.Position = [56 754 1186 259];

            % Create Image
            app.Image = uiimage(app.BloodPressureAnalyisisUIFigure);
            app.Image.Position = [1296 141 460 651];

            % Create NextImageButton
            app.NextImageButton = uibutton(app.BloodPressureAnalyisisUIFigure, 'push');
            app.NextImageButton.FontSize = 20;
            app.NextImageButton.Position = [1619 897 138 42];
            app.NextImageButton.Text = 'Next Image';

            % Create PreviousImageButton
            app.PreviousImageButton = uibutton(app.BloodPressureAnalyisisUIFigure, 'push');
            app.PreviousImageButton.FontSize = 20;
            app.PreviousImageButton.Position = [1296 897 146 42];
            app.PreviousImageButton.Text = 'Previous Image';

            % Create QuitButton
            app.QuitButton = uibutton(app.BloodPressureAnalyisisUIFigure, 'push');
            app.QuitButton.FontSize = 20;
            app.QuitButton.Position = [1621 32 138 42];
            app.QuitButton.Text = 'Quit';

            % Create SaveButton
            app.SaveButton = uibutton(app.BloodPressureAnalyisisUIFigure, 'push');
            app.SaveButton.FontSize = 20;
            app.SaveButton.Position = [1295 32 138 42];
            app.SaveButton.Text = {'Save'; ''};

            % Create OpenQCFileButton
            app.OpenQCFileButton = uibutton(app.BloodPressureAnalyisisUIFigure, 'push');
            app.OpenQCFileButton.FontSize = 20;
            app.OpenQCFileButton.Position = [27 1059 138 42];
            app.OpenQCFileButton.Text = {'Open QC File'; ''};

            % Create GreenPointsPrimaryButtonGroup
            app.GreenPointsPrimaryButtonGroup = uibuttongroup(app.BloodPressureAnalyisisUIFigure);
            app.GreenPointsPrimaryButtonGroup.Title = 'Green Points (Primary)';
            app.GreenPointsPrimaryButtonGroup.Position = [297 612 216 121];

            % Create mmButton_2
            app.mmButton_2 = uiradiobutton(app.GreenPointsPrimaryButtonGroup);
            app.mmButton_2.Text = 'mm.';
            app.mmButton_2.Position = [13 70 58 22];
            app.mmButton_2.Value = true;

            % Create cmButton
            app.cmButton = uiradiobutton(app.GreenPointsPrimaryButtonGroup);
            app.cmButton.Text = {'cm.'; ''};
            app.cmButton.Position = [13 48 65 22];

            % Create inButton
            app.inButton = uiradiobutton(app.GreenPointsPrimaryButtonGroup);
            app.inButton.Text = '1/32 in.';
            app.inButton.Position = [76 70 65 22];

            % Create WrongButton
            app.WrongButton = uiradiobutton(app.GreenPointsPrimaryButtonGroup);
            app.WrongButton.Text = 'Wrong';
            app.WrongButton.Position = [76 6 65 22];

            % Create inButton_2
            app.inButton_2 = uiradiobutton(app.GreenPointsPrimaryButtonGroup);
            app.inButton_2.Text = '1/16 in.';
            app.inButton_2.Position = [76 48 65 22];

            % Create inButton_3
            app.inButton_3 = uiradiobutton(app.GreenPointsPrimaryButtonGroup);
            app.inButton_3.Text = '1/8 in.';
            app.inButton_3.Position = [76 27 65 22];

            % Create inButton_4
            app.inButton_4 = uiradiobutton(app.GreenPointsPrimaryButtonGroup);
            app.inButton_4.Text = '1/2 in.';
            app.inButton_4.Position = [143 48 65 22];

            % Create inButton_5
            app.inButton_5 = uiradiobutton(app.GreenPointsPrimaryButtonGroup);
            app.inButton_5.Text = '1 in.';
            app.inButton_5.Position = [143 27 65 22];

            % Create inButton_6
            app.inButton_6 = uiradiobutton(app.GreenPointsPrimaryButtonGroup);
            app.inButton_6.Text = '1/4 in.';
            app.inButton_6.Position = [143 70 65 22];

            % Create mmButton
            app.mmButton = uiradiobutton(app.GreenPointsPrimaryButtonGroup);
            app.mmButton.Text = {'1/2 mm.'; ''};
            app.mmButton.Position = [13 27 65 22];

            % Create CyanPointsSecondaryButtonGroup
            app.CyanPointsSecondaryButtonGroup = uibuttongroup(app.BloodPressureAnalyisisUIFigure);
            app.CyanPointsSecondaryButtonGroup.Title = 'Cyan Points (Secondary)';
            app.CyanPointsSecondaryButtonGroup.Position = [542 613 216 121];

            % Create mmButton_3
            app.mmButton_3 = uiradiobutton(app.CyanPointsSecondaryButtonGroup);
            app.mmButton_3.Text = 'mm.';
            app.mmButton_3.Position = [13 70 58 22];
            app.mmButton_3.Value = true;

            % Create cmButton_2
            app.cmButton_2 = uiradiobutton(app.CyanPointsSecondaryButtonGroup);
            app.cmButton_2.Text = {'cm.'; ''};
            app.cmButton_2.Position = [13 48 65 22];

            % Create inButton_7
            app.inButton_7 = uiradiobutton(app.CyanPointsSecondaryButtonGroup);
            app.inButton_7.Text = '1/32 in.';
            app.inButton_7.Position = [76 70 65 22];

            % Create WrongButton_2
            app.WrongButton_2 = uiradiobutton(app.CyanPointsSecondaryButtonGroup);
            app.WrongButton_2.Text = 'Wrong';
            app.WrongButton_2.Position = [76 6 65 22];

            % Create inButton_8
            app.inButton_8 = uiradiobutton(app.CyanPointsSecondaryButtonGroup);
            app.inButton_8.Text = '1/16 in.';
            app.inButton_8.Position = [76 48 65 22];

            % Create inButton_9
            app.inButton_9 = uiradiobutton(app.CyanPointsSecondaryButtonGroup);
            app.inButton_9.Text = '1/8 in.';
            app.inButton_9.Position = [76 27 65 22];

            % Create inButton_10
            app.inButton_10 = uiradiobutton(app.CyanPointsSecondaryButtonGroup);
            app.inButton_10.Text = '1/2 in.';
            app.inButton_10.Position = [143 48 65 22];

            % Create inButton_11
            app.inButton_11 = uiradiobutton(app.CyanPointsSecondaryButtonGroup);
            app.inButton_11.Text = '1 in.';
            app.inButton_11.Position = [143 27 65 22];

            % Create inButton_12
            app.inButton_12 = uiradiobutton(app.CyanPointsSecondaryButtonGroup);
            app.inButton_12.Text = '1/4 in.';
            app.inButton_12.Position = [143 70 65 22];

            % Create mmButton_4
            app.mmButton_4 = uiradiobutton(app.CyanPointsSecondaryButtonGroup);
            app.mmButton_4.Text = {'1/2 mm.'; ''};
            app.mmButton_4.Position = [13 27 65 22];

            % Create YellowPointsTertiaryButtonGroup
            app.YellowPointsTertiaryButtonGroup = uibuttongroup(app.BloodPressureAnalyisisUIFigure);
            app.YellowPointsTertiaryButtonGroup.Title = 'Yellow Points (Tertiary)';
            app.YellowPointsTertiaryButtonGroup.Position = [783 614 216 121];

            % Create mmButton_5
            app.mmButton_5 = uiradiobutton(app.YellowPointsTertiaryButtonGroup);
            app.mmButton_5.Text = 'mm.';
            app.mmButton_5.Position = [13 70 58 22];
            app.mmButton_5.Value = true;

            % Create cmButton_3
            app.cmButton_3 = uiradiobutton(app.YellowPointsTertiaryButtonGroup);
            app.cmButton_3.Text = {'cm.'; ''};
            app.cmButton_3.Position = [13 48 65 22];

            % Create inButton_13
            app.inButton_13 = uiradiobutton(app.YellowPointsTertiaryButtonGroup);
            app.inButton_13.Text = '1/32 in.';
            app.inButton_13.Position = [76 70 65 22];

            % Create WrongButton_3
            app.WrongButton_3 = uiradiobutton(app.YellowPointsTertiaryButtonGroup);
            app.WrongButton_3.Text = 'Wrong';
            app.WrongButton_3.Position = [76 6 65 22];

            % Create inButton_14
            app.inButton_14 = uiradiobutton(app.YellowPointsTertiaryButtonGroup);
            app.inButton_14.Text = '1/16 in.';
            app.inButton_14.Position = [76 48 65 22];

            % Create inButton_15
            app.inButton_15 = uiradiobutton(app.YellowPointsTertiaryButtonGroup);
            app.inButton_15.Text = '1/8 in.';
            app.inButton_15.Position = [76 27 65 22];

            % Create inButton_16
            app.inButton_16 = uiradiobutton(app.YellowPointsTertiaryButtonGroup);
            app.inButton_16.Text = '1/2 in.';
            app.inButton_16.Position = [143 48 65 22];

            % Create inButton_17
            app.inButton_17 = uiradiobutton(app.YellowPointsTertiaryButtonGroup);
            app.inButton_17.Text = '1 in.';
            app.inButton_17.Position = [143 27 65 22];

            % Create inButton_18
            app.inButton_18 = uiradiobutton(app.YellowPointsTertiaryButtonGroup);
            app.inButton_18.Text = '1/4 in.';
            app.inButton_18.Position = [143 70 65 22];

            % Create mmButton_6
            app.mmButton_6 = uiradiobutton(app.YellowPointsTertiaryButtonGroup);
            app.mmButton_6.Text = {'1/2 mm.'; ''};
            app.mmButton_6.Position = [13 27 65 22];

            % Create PreviousObjectButton
            app.PreviousObjectButton = uibutton(app.BloodPressureAnalyisisUIFigure, 'push');
            app.PreviousObjectButton.FontSize = 20;
            app.PreviousObjectButton.Position = [401 1059 157 42];
            app.PreviousObjectButton.Text = 'Previous Object';

            % Create NextObjectButton
            app.NextObjectButton = uibutton(app.BloodPressureAnalyisisUIFigure, 'push');
            app.NextObjectButton.FontSize = 20;
            app.NextObjectButton.Position = [738 1059 138 42];
            app.NextObjectButton.Text = 'Next Object';

            % Create ObjectLabel
            app.ObjectLabel = uilabel(app.BloodPressureAnalyisisUIFigure);
            app.ObjectLabel.HorizontalAlignment = 'center';
            app.ObjectLabel.FontSize = 18;
            app.ObjectLabel.Position = [591 1081 118 32];
            app.ObjectLabel.Text = 'Object:';

            % Create nLabel
            app.nLabel = uilabel(app.BloodPressureAnalyisisUIFigure);
            app.nLabel.BackgroundColor = [0 0 0];
            app.nLabel.HorizontalAlignment = 'center';
            app.nLabel.FontSize = 18;
            app.nLabel.FontColor = [0.8 0.8 0.8];
            app.nLabel.Position = [592 1050 118 32];
            app.nLabel.Text = {'1 / n'; ''};

            % Create ImageLabel
            app.ImageLabel = uilabel(app.BloodPressureAnalyisisUIFigure);
            app.ImageLabel.HorizontalAlignment = 'center';
            app.ImageLabel.FontSize = 18;
            app.ImageLabel.Position = [1496 897 62 36];
            app.ImageLabel.Text = 'Image:';

            % Create filenameLabel
            app.filenameLabel = uilabel(app.BloodPressureAnalyisisUIFigure);
            app.filenameLabel.BackgroundColor = [0 0 0];
            app.filenameLabel.HorizontalAlignment = 'center';
            app.filenameLabel.WordWrap = 'on';
            app.filenameLabel.FontSize = 18;
            app.filenameLabel.FontColor = [0.8 0.8 0.8];
            app.filenameLabel.Position = [1295 836 461 50];
            app.filenameLabel.Text = {'filename...'; ''};

            % Create UITable_Image
            app.UITable_Image = uitable(app.BloodPressureAnalyisisUIFigure);
            app.UITable_Image.ColumnName = {'ImageName'; 'nObjectsMeasured'; 'PixelsPerMM'; 'PixelsPerMM_ManuallyValidated'; 'ImageFileLocation'};
            app.UITable_Image.RowName = {};
            app.UITable_Image.ColumnSortable = [true false true true];
            app.UITable_Image.ColumnEditable = [true false true true];
            app.UITable_Image.Position = [27 50 1186 188];

            % Create ObjectsTableLabel
            app.ObjectsTableLabel = uilabel(app.BloodPressureAnalyisisUIFigure);
            app.ObjectsTableLabel.HorizontalAlignment = 'center';
            app.ObjectsTableLabel.Position = [609 583 85 18];
            app.ObjectsTableLabel.Text = 'Objects Table';

            % Create ImageTableLabel
            app.ImageTableLabel = uilabel(app.BloodPressureAnalyisisUIFigure);
            app.ImageTableLabel.HorizontalAlignment = 'center';
            app.ImageTableLabel.Position = [609 237 85 22];
            app.ImageTableLabel.Text = 'Image Table';

            % Show the figure after all components are created
            app.BloodPressureAnalyisisUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = LMM_QC_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.BloodPressureAnalyisisUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.BloodPressureAnalyisisUIFigure)
        end
    end
end