Dim oAnsoftApp
Dim oDesktop
Dim oProject
Dim oDesign
Dim oEditor
Dim oModule

Set oAnsoftApp  = CreateObject("AnsoftHfss.HfssScriptInterface")
Set oDesktop = oAnsoftApp.GetAppDesktop()
oDesktop.RestoreWindow
oDesktop.NewProject
Set oProject = oDesktop.GetActiveProject

oProject.InsertDesign "HFSS", "without_balun", "DrivenModal", ""
Set oDesign = oProject.SetActiveDesign("without_balun")
Set oEditor = oDesign.SetActiveEditor("3D Modeler")

oEditor.CreateCylinder _
Array("NAME:CylinderParameters", _
"XCenter:=", "0.025000meter", _
"YCenter:=", "0.000000meter", _
"ZCenter:=", "0.000000meter", _
"Radius:=", "0.020000meter", _
"Height:=", "0.416444meter", _
"WhichAxis:=", "X"), _
Array("NAME:Attributes", _
"Name:=", "Dipole1", _
"Flags:=", "", _
"Color:=", "(132 132 193)", _
"Transparency:=", 0, _
"PartCoordinateSystem:=", "Global", _
"MaterialName:=", "vacuum", _
"SolveInside:=", true)


oEditor.CreateCylinder _
Array("NAME:CylinderParameters", _
"XCenter:=", "-0.025000meter", _
"YCenter:=", "0.000000meter", _
"ZCenter:=", "0.000000meter", _
"Radius:=", "0.020000meter", _
"Height:=", "-0.416444meter", _
"WhichAxis:=", "X"), _
Array("NAME:Attributes", _
"Name:=", "Dipole2", _
"Flags:=", "", _
"Color:=", "(132 132 193)", _
"Transparency:=", 0, _
"PartCoordinateSystem:=", "Global", _
"MaterialName:=", "vacuum", _
"SolveInside:=", true)


Set oModule = oDesign.GetModule("BoundarySetup")
oModule.AssignPerfectE _
Array("NAME:Antennas", _
"InfGroundPlane:=", false, _
"Objects:=", _
Array("Dipole1","Dipole2"))

oEditor.CreateRectangle _
Array("NAME:RectangleParameters", _
"IsCovered:=", true, _
"XStart:=", "-0.025000meter", _
"YStart:=", "0.000000meter", _
"ZStart:=", "-0.020000meter", _
"Width:=", "0.040000meter", _
"Height:=", "0.050000meter", _
"WhichAxis:=", "Y"), _
Array("NAME:Attributes", _
"Name:=", "GapSource", _
"Flags:=", "", _
"Color:=", "(132 132 193)", _
"Transparency:=", 7.500000e-01, _
"PartCoordinateSystem:=", "Global", _
"MaterialName:=", "vacuum", _
"SolveInside:=", true)

Set oModule = oDesign.GetModule("BoundarySetup")
oModule.AssignLumpedPort _
Array("NAME:LumpedPort", _
      Array("NAME:Modes", _
             Array("NAME:Mode1", _
                   "ModeNum:=", 1, _
                   "UseIntLine:=", true, _
                   Array("NAME:IntLine", _
                          "Start:=", Array("-0.025000meter", "0.000000meter", "0.000000meter"), _
                          "End:=",   Array("0.025000meter", "0.000000meter", "0.000000meter") _
                         ), _
                   "CharImp:=", "Zpi" _
                   ) _
            ), _
      "Resistance:=", "50.000000Ohm", _
      "Reactance:=", "0.000000Ohm", _
      "Objects:=", Array("GapSource") _
      )

oEditor.CreateBox _
Array("NAME:BoxParameters", _
"XPosition:=", "-1.000000meter", _
"YPosition:=", "-0.500000meter", _
"ZPosition:=", "-0.500000meter", _
"XSize:=", "2.000000meter", _
"YSize:=", "1.000000meter", _
"ZSize:=", "1.000000meter"), _
Array("NAME:Attributes", _
"Name:=", "AirBox", _
"Flags:=", "", _
"Color:=", "(132 132 193)", _
"Transparency:=", 0.75, _
"PartCoordinateSystem:=", "Global", _
"MaterialName:=", "vacuum", _
"SolveInside:=", true)
Set oModule = oDesign.GetModule("BoundarySetup")
oModule.AssignRadiation _
Array("NAME:ABC", _
"Objects:=", Array("AirBox"), _
"UseAdaptiveIE:=", false)

Set oModule = oDesign.GetModule("AnalysisSetup")
oModule.InsertSetup "HfssDriven", _
Array("NAME:Setup150MHz", _
"Frequency:=", "0.150000GHz", _
"PortsOnly:=", false, _
"maxDeltaS:=", 0.020000, _
"UseMatrixConv:=", false, _
"MaximumPasses:=", 25, _
"MinimumPasses:=", 1, _
"MinimumConvergedPasses:=", 1, _
"PercentRefinement:=", 20, _
"ReducedSolutionBasis:=", false, _
"DoLambdaRefine:=", true, _
"DoMaterialLambda:=", true, _
"Target:=", 0.3333, _
"PortAccuracy:=", 2, _
"SetPortMinMaxTri:=", false)

Set oModule = oDesign.GetModule("AnalysisSetup")
oModule.InsertDrivenSweep _
"Setup150MHz", _
Array("NAME:Sweep100to200MHz", _
"Type:=", "Interpolating", _
"InterpTolerance:=", 0.500000, _
"InterpMaxSolns:=", 101, _
"SetupType:=", "LinearCount", _
"StartFreq:=", "0.010000GHz", _
"StopFreq:=", "0.200000GHz", _
"Count:=", 201, _
"SaveFields:=", false, _
"ExtrapToDC:=", false)

oProject.SaveAs _
    "C:\Users\FramelessTenno\Desktop\uni stuff\matlab capstone\MATLAB-app-using-HFSS-API-by-yuip\tmpDipole.aedt", _
    true

oDesign.Solve _
    Array("Setup150MHz") 

Set oModule = oDesign.GetModule("Solutions")
oModule.ExportNetworkData _
        "", _
        Array("Setup150MHz:Sweep100to200MHz"), _
        7,  _
        "C:\Users\FramelessTenno\Desktop\uni stuff\matlab capstone\MATLAB-app-using-HFSS-API-by-yuip\tmpData2.m", _
        Array("All"),  _
        true, _
        50.00 
