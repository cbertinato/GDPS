import gravity as g

gravity_path = '/Users/chrisbert/Documents/Git/GDPS/sample_data/DGS/dgs_test_data.dat'
trajectory_path = '/Users/chrisbert/Documents/Git/GDPS/sample_data/AN03_F1007_20161130_iMAR_PrelimFinal_STD.txt'

data = g.Gravity()
print 'Importing gravity data.'
data.import_DGS_format_data(gravity_path)

print data.gravity

print 'Importing trajectory data.'
data.import_trajectory(trajectory_path, interval=.1)

print data.trajectory

print 'Joining trajectory with gravity data.'
data.join_grav_traj()

print data.gravity
