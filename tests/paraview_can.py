# written for paraview version 5.11.0
# Save this script as $HOME/paraview_can.py

from paraview.simple import *
import os.path

# detemine dataset filename
examples_dir = servermanager.vtkPVFileInformation.GetParaViewExampleFilesDirectory()
dataset = os.path.join(examples_dir, "can.ex2")

# open dataset
OpenDataFile(dataset)

# update animation scene
scene = GetAnimationScene()
scene.UpdateAnimationUsingDataTimeSteps()

# render data
Show()

view = Render()

# adjust view
view.ViewSize = [1024, 1024]
view.ResetActiveCameraToNegativeY()
view.ResetCamera()

# save animation
SaveAnimation(os.path.expandvars('$HOME/movie.avi'), FrameRate=10)
