# written for paraview version 5.11.0
# Save this script as $HOME/paraview_test.py

from paraview.simple import *
import os.path
import time

pm = servermanager.vtkProcessModule.GetProcessModule()
layout = CreateLayout(name='Layout #1')

v1 = CreateView('RenderView')
AssignViewToLayout(view=v1, layout=layout)

# add annotation
text = Text()
text.Text = f"""
Total MPI ranks: {pm.GetNumberOfLocalPartitions()}
"""
textDisplay = Show()
textDisplay.Justification = 'Left'
textDisplay.FontSize = 20

Wavelet()
Show()
Render()


# split view
layout.SplitHorizontal(0, 0.5)

# show a line plot
v2 = CreateView('XYChartView')
AssignViewToLayout(view=v2, layout=layout)

PlotOverLine()
Show()

# show line in render view as well
Show(view=v1)

# generate a screenshot.png in the home directory
layout.SetSize(1920, 1080)
SaveScreenshot(os.path.expandvars('$HOME/screenshot.png'), layout)
