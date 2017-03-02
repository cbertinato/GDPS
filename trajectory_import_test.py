import gravity as g

filepath = '/Users/chrisbert/Documents/Git/GDPS/sample_data/AN03_F1007_20161130_iMAR_PrelimFinal_STD.txt'

traj_test = g.Gravity()
#traj_test.import_trajectory(filepath, interval=.1, interp=True)
traj_test.import_trajectory(filepath, interval=.1)

print traj_test.trajectory
