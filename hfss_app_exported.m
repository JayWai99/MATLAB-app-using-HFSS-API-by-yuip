classdef hfss_app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        OpenModelfileButton        matlab.ui.control.Button
        Lamp_2                     matlab.ui.control.Lamp
        Label_2                    matlab.ui.control.Label
        AntennaModelDropDown       matlab.ui.control.DropDown
        AntennaModelDropDownLabel  matlab.ui.control.Label
        f_highEditField            matlab.ui.control.NumericEditField
        f_highEditFieldLabel       matlab.ui.control.Label
        MHzLabel_3                 matlab.ui.control.Label
        MHzLabel_2                 matlab.ui.control.Label
        MHzLabel                   matlab.ui.control.Label
        f_lowEditField             matlab.ui.control.NumericEditField
        f_lowEditFieldLabel        matlab.ui.control.Label
        f_targetEditField          matlab.ui.control.NumericEditField
        f_targetEditFieldLabel     matlab.ui.control.Label
        QuitButton                 matlab.ui.control.Button
        StartButton                matlab.ui.control.Button
        ResetButton                matlab.ui.control.Button
        PathtoAnsysElectronicsEditField  matlab.ui.control.EditField
        PathtoAnsysElectronicsEditFieldLabel  matlab.ui.control.Label
        UIAxes                     matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: ResetButton
        function resetCallback(app, event)
            app.f_targetEditField.Value = 0;
            app.f_highEditField.Value = 0;
            app.f_lowEditField.Value = 0;
            cla(app.UIAxes, 'reset');
            title(app.UIAxes, 'Target Frequency Of Antenna Model')
            app.UIAxes.XGrid = "on";
            xlabel(app.UIAxes, 'Frequency (MHz)')
            app.UIAxes.YGrid = 'on';
            ylabel(app.UIAxes, 'Decibel (dB)')
            app.StartButton.Enable = "off";
            app.OpenModelfileButton.Enable = "off";
        end

        % Button pushed function: QuitButton
        function QuitButtonPushed(app, event)
            close(app.UIFigure);
        end

        % Callback function
        function PathtoHFSSAPIEditFieldValueChanged(app, event)
           % if isfolder(app.PathtoHFSSAPIEditField.Value) == true
           %     app.Lamp.Color = [0 1 0];
           % end    
           % if strcmp(app.PathtoAnsysElectronicsEditField.Value, '') == false && ...
           %         app.f_targetEditField.Value > 0 && ...
           %         app.f_lowEditField.Value >= 0 && ...
           %         app.f_highEditField.Value > app.f_lowEditField.Value
           %     app.StartButton.Enable = 'on';
           %     app.OpenModelfileButton.Enable = "off";
           % end
        end

        % Value changed function: PathtoAnsysElectronicsEditField
        function PathtoAnsysElectronicsEditFieldValueChanged(app, event)
            if isfile(app.PathtoAnsysElectronicsEditField.Value) == true
                app.Lamp_2.Color = [0 1 0];
            end
             if app.f_targetEditField.Value > 0 && ...
                    app.f_lowEditField.Value >= 0 && ...
                    app.f_highEditField.Value > app.f_lowEditField.Value
                app.StartButton.Enable = 'on';
                app.OpenModelfileButton.Enable = "off";
            end
        end

        % Value changed function: f_targetEditField
        function TargetValueChanged(app, event)
             if strcmp(app.PathtoAnsysElectronicsEditField.Value, '') == false && ...
                    app.f_lowEditField.Value >= 0 && ...
                    app.f_highEditField.Value > app.f_lowEditField.Value
                app.StartButton.Enable = 'on';
                app.OpenModelfileButton.Enable = "off";
            end          
        end

        % Value changed function: f_lowEditField
        function FrequencyLowChanged(app, event)
             if strcmp(app.PathtoAnsysElectronicsEditField.Value, '') == false && ...
                    app.f_targetEditField.Value >= 0 && ...
                    app.f_highEditField.Value > app.f_lowEditField.Value
                app.StartButton.Enable = 'on';
                app.OpenModelfileButton.Enable = "off";
            end   
        end

        % Value changed function: f_highEditField
        function FrequencyHighChanged(app, event)
             if strcmp(app.PathtoAnsysElectronicsEditField.Value, '') == false && ...
                    app.f_targetEditField.Value >= 0 && ...
                    app.f_highEditField.Value > app.f_lowEditField.Value
                app.StartButton.Enable = 'on';
                app.OpenModelfileButton.Enable = "off";
            end            
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            % The following is an example that has been borrowed from the
            % HFSS-MATLAB-API. This script
            % optimizes a dipole antenna design to resonate at a specified frequency.
            % The initial length of the dipole is taken to be half the wavelength and
            % is optimized so that the simulated resonance frequency and the desired
            % resonance frequency are close.
            
            clc;
            cla(app.UIAxes, 'reset');
            title(app.UIAxes, 'Target Frequency Of Antenna Model')
            app.UIAxes.XGrid = "on";
            xlabel(app.UIAxes, 'Frequency (MHz)')
            app.UIAxes.YGrid = 'on';
            ylabel(app.UIAxes, 'Decibel (dB)')

            hfsspath = [pwd, '\hfss-api_by_yuip'];
            
            % Add paths to the required m-files.
            addpath(hfsspath); % add manually the API root directory.
            hfssIncludePaths(hfsspath);
            
            % Antenna Parameters.
            fC   = app.f_targetEditField.Value*1e6;    % Frequency of Interest.
            Wv   = 3e8/fC;    % Wavelength.
            L    = Wv/2;    % Antenna Length.
            gapL = 5e-2;    % Antenna Gap.
            aRad = 2e-2;    % Antenna Radius.
            
            % Simulation Parameters.
            fLow    = app.f_lowEditField.Value*1e6;
            fHigh   = app.f_highEditField.Value*1e6;
            nPoints = 201;
            
            % AirBox Parameters.
            AirX = Wv/2 + L;    % Include the antenna length.
            AirY = Wv/2; 
            AirZ = Wv/2;
            
            % Temporary Files. These files can be deleted after the optimization
            % is complete. We have to specify the complete path for all of them.
            % With pwd we save them in the current directory.
            tmpPrjFile    = [pwd, '\tmpDipole.aedt'];
            tmpDataFile   = [pwd, '\tmpData.m'];
            tmpScriptFile = [pwd, '\dipole_example.vbs'];
            tmpRunnerFile = strcat(pwd, '\run_aedt.m');
            
            % HFSS Executable Path.
            hfssExePath = app.PathtoAnsysElectronicsEditField.Value;
            
            % Plot Colors.
            pltCols = ['b', 'r', 'k', 'g', 'm', 'c', 'y'];
            nCols = length(pltCols);
            
            % Optimization stop conditions.
            maxIters = 15;        % max # of iterations.
            Accuracy = 0.01;      % accuracy required (1%).
            hasConverged = false;
            
            fprintf('The Initial Dipole Length is %.2f meter...\n', L);
            for iIters = 1:maxIters
                fprintf('Running iteration #%d...\n', iIters);
                disp('Creating the Script File...');
                
                % Create a new temporary HFSS script file.
                fid = fopen(tmpScriptFile, 'wt');
                
                % Create a new HFSS Project and insert a new design.
                hfssNewProject(fid);
                hfssInsertDesign(fid, 'without_balun');
                
                % Create the Dipole.
                hfssDipole(fid, 'Dipole', 'X', [0, 0, 0], L, 2*aRad, gapL, 'meter');
                
                % Assign PE boundary to the antenna elements.
                hfssAssignPE(fid, 'Antennas',  {'Dipole1', 'Dipole2'});
                
                % Create a Lumped Gap Source (a rectangle normal to the Y-axis)
                hfssRectangle(fid, 'GapSource', 'Y', [-gapL/2, 0, -aRad], 2*aRad, ...
                    gapL, 'meter');
                hfssAssignLumpedPort(fid, 'LumpedPort', 'GapSource', ...
                    [-gapL/2, 0, 0], [gapL/2, 0, 0], 'meter');
                
                % Add an AirBox.
                hfssBox(fid, 'AirBox', [-AirX, -AirY, -AirZ]/2, [AirX, AirY, AirZ], ...
                    'meter');
                hfssAssignRadiation(fid, 'ABC', 'AirBox');
                
                % Add a Solution Setup.
                hfssInsertSolution(fid, 'Setup150MHz', fC/1e9);
                hfssInterpolatingSweep(fid, 'Sweep100to200MHz', 'Setup150MHz', ...
                    fLow/1e9, fHigh/1e9, nPoints);
                
                % Save the project to a temporary file and solve it.
                hfssSaveProject(fid, tmpPrjFile, true);
                hfssSolveSetup(fid, 'Setup150MHz');
                
                % Export the Network data as an m-file.
                hfssExportNetworkData(fid, tmpDataFile, 'Setup150MHz', ...
                    'Sweep100to200MHz');
                
                % Close the HFSS Script File.
                fclose(fid);
                
                % Execute the Script by starting HFSS.
                disp('Solving using HFSS...');
                hfssExecuteScript(hfssExePath, tmpScriptFile, '', '');
                
                % Load the data by running the exported matlab file.
                run(tmpDataFile);
                tmpDataFile = [pwd, '\tmpData', num2str(iIters), '.m'];
                
                % The data items are in the f, S, Z variables now. 
                % Plot the data.
                disp('Solution Completed. Plotting Results for this iteration...');
                
                hold(app.UIAxes,'on')
                axis([fLow/1e6, fHigh/1e6, -20, 0]);
                plot(app.UIAxes,f/1e6, 20*log10(abs(S)), pltCols(mod(iIters, nCols) + 1)); 
                hold(app.UIAxes, 'off')
                
                % Find the Resonance Frequency.
                [Smin, iMin] = min(S);
                fActual = f(iMin);
                fprintf('Simulated Resonance Frequency: %.2f MHz\n', fActual/1e6);
                
                % Check if the required accuracy is met.
                if (abs((fC - fActual)/fC) < Accuracy)
                    disp('Required Accuracy is met!');
                    fprintf('Optimized Antenna Length is %.2f meter.\n', L);
                    hasConverged = true;
                    close all;             
                    break;
                end
                
                % Adjust the antenna length in accordance with the discrepancy between
                % the estimated and desired resonance frequency.
                L = L*fActual/fC;
            
                % Loop all over again ...
                disp('Required accuracy not yet met ...');
                fprintf('The new estimate for the dipole length is %.2f meter\n', L);
            end
            
            if (~hasConverged)
                disp('Max Iterations exceeded. Optimization did NOT converge ...');
                close all;
            end
            disp('');
            disp('');
            
            % Remove all the added paths.
            hfssRemovePaths(hfsspath);
            rmpath(hfsspath);

            aedt_runner_id = fopen(tmpRunnerFile, "wt");

            fprintf(aedt_runner_id, "AEDT_PATH='%s ';\n", app.PathtoAnsysElectronicsEditField.Value);
            fprintf(aedt_runner_id, "AEDT_PROJECT='%s';\n", tmpPrjFile);
            double_quotes = '"';
            
            fprintf(aedt_runner_id, "cmdaedt = ['%c', AEDT_PATH, '%c', ' ', '%c', AEDT_PROJECT, '%c'];\n", double_quotes, double_quotes, double_quotes, double_quotes);
            fprintf(aedt_runner_id, "system(cmdaedt);\n");
            
            fclose(aedt_runner_id);

            app.OpenModelfileButton.Enable = "on";
        end

        % Button pushed function: OpenModelfileButton
        function OpenModelFile(app, event)
            run("run_aedt.m");
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 773 619];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Target Frequency Of Antenna Model')
            xlabel(app.UIAxes, 'Frequency (MHz)')
            ylabel(app.UIAxes, 'Decibel (dB)')
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.Position = [98 244 576 339];

            % Create PathtoAnsysElectronicsEditFieldLabel
            app.PathtoAnsysElectronicsEditFieldLabel = uilabel(app.UIFigure);
            app.PathtoAnsysElectronicsEditFieldLabel.HorizontalAlignment = 'right';
            app.PathtoAnsysElectronicsEditFieldLabel.Position = [98 200 140 22];
            app.PathtoAnsysElectronicsEditFieldLabel.Text = 'Path to Ansys Electronics';

            % Create PathtoAnsysElectronicsEditField
            app.PathtoAnsysElectronicsEditField = uieditfield(app.UIFigure, 'text');
            app.PathtoAnsysElectronicsEditField.ValueChangedFcn = createCallbackFcn(app, @PathtoAnsysElectronicsEditFieldValueChanged, true);
            app.PathtoAnsysElectronicsEditField.Placeholder = 'Insert path to the HFSS Ansys executable here';
            app.PathtoAnsysElectronicsEditField.Position = [253 200 359 22];

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @resetCallback, true);
            app.ResetButton.Position = [253 18 100 23];
            app.ResetButton.Text = 'Reset';

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Enable = 'off';
            app.StartButton.Position = [370 18 100 23];
            app.StartButton.Text = 'Start';

            % Create QuitButton
            app.QuitButton = uibutton(app.UIFigure, 'push');
            app.QuitButton.ButtonPushedFcn = createCallbackFcn(app, @QuitButtonPushed, true);
            app.QuitButton.Position = [628 18 100 23];
            app.QuitButton.Text = 'Quit';

            % Create f_targetEditFieldLabel
            app.f_targetEditFieldLabel = uilabel(app.UIFigure);
            app.f_targetEditFieldLabel.HorizontalAlignment = 'right';
            app.f_targetEditFieldLabel.Position = [403 148 46 22];
            app.f_targetEditFieldLabel.Text = 'f_target';

            % Create f_targetEditField
            app.f_targetEditField = uieditfield(app.UIFigure, 'numeric');
            app.f_targetEditField.Limits = [0 Inf];
            app.f_targetEditField.ValueChangedFcn = createCallbackFcn(app, @TargetValueChanged, true);
            app.f_targetEditField.Position = [464 148 100 22];

            % Create f_lowEditFieldLabel
            app.f_lowEditFieldLabel = uilabel(app.UIFigure);
            app.f_lowEditFieldLabel.HorizontalAlignment = 'right';
            app.f_lowEditFieldLabel.Position = [403 106 33 22];
            app.f_lowEditFieldLabel.Text = 'f_low';

            % Create f_lowEditField
            app.f_lowEditField = uieditfield(app.UIFigure, 'numeric');
            app.f_lowEditField.Limits = [0 Inf];
            app.f_lowEditField.ValueChangedFcn = createCallbackFcn(app, @FrequencyLowChanged, true);
            app.f_lowEditField.Position = [451 106 113 22];

            % Create MHzLabel
            app.MHzLabel = uilabel(app.UIFigure);
            app.MHzLabel.Position = [573 148 30 22];
            app.MHzLabel.Text = 'MHz';

            % Create MHzLabel_2
            app.MHzLabel_2 = uilabel(app.UIFigure);
            app.MHzLabel_2.Position = [573 69 30 22];
            app.MHzLabel_2.Text = 'MHz';

            % Create MHzLabel_3
            app.MHzLabel_3 = uilabel(app.UIFigure);
            app.MHzLabel_3.Position = [573 106 30 22];
            app.MHzLabel_3.Text = 'MHz';

            % Create f_highEditFieldLabel
            app.f_highEditFieldLabel = uilabel(app.UIFigure);
            app.f_highEditFieldLabel.HorizontalAlignment = 'right';
            app.f_highEditFieldLabel.Position = [403 69 38 22];
            app.f_highEditFieldLabel.Text = 'f_high';

            % Create f_highEditField
            app.f_highEditField = uieditfield(app.UIFigure, 'numeric');
            app.f_highEditField.Limits = [0 Inf];
            app.f_highEditField.ValueChangedFcn = createCallbackFcn(app, @FrequencyHighChanged, true);
            app.f_highEditField.Position = [456 69 108 22];

            % Create AntennaModelDropDownLabel
            app.AntennaModelDropDownLabel = uilabel(app.UIFigure);
            app.AntennaModelDropDownLabel.HorizontalAlignment = 'right';
            app.AntennaModelDropDownLabel.Position = [98 148 86 22];
            app.AntennaModelDropDownLabel.Text = 'Antenna Model';

            % Create AntennaModelDropDown
            app.AntennaModelDropDown = uidropdown(app.UIFigure);
            app.AntennaModelDropDown.Items = {'Dipole', 'Horn', 'Patch', 'Folded_dipole'};
            app.AntennaModelDropDown.Position = [199 148 100 22];
            app.AntennaModelDropDown.Value = 'Dipole';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [622 199 25 22];
            app.Label_2.Text = '';

            % Create Lamp_2
            app.Lamp_2 = uilamp(app.UIFigure);
            app.Lamp_2.Position = [662 199 20 20];
            app.Lamp_2.Color = [0.9412 0.9412 0.9412];

            % Create OpenModelfileButton
            app.OpenModelfileButton = uibutton(app.UIFigure, 'push');
            app.OpenModelfileButton.ButtonPushedFcn = createCallbackFcn(app, @OpenModelFile, true);
            app.OpenModelfileButton.Enable = 'off';
            app.OpenModelfileButton.Position = [488 18 124 23];
            app.OpenModelfileButton.Text = 'Open Model file';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = hfss_app_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end