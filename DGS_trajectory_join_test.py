import gravity as g

gravity_path = '/Users/chrisbert/Documents/Git/GDPS/sample_data/DGS/dgs_test_data.dat'
trajectory_path = '/Users/chrisbert/Documents/Git/GDPS/sample_data/DGS/sample_trajectory.txt'

data = g.Gravity()
print 'Importing gravity data.'
data.import_DGS_format_data(gravity_path)

print 'Importing trajectory data.'
data.import_trajectory(trajectory_path)

print 'Joining trajectory with gravity data.'
data.join_grav_traj()

print data.gravity
