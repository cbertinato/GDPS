import gravity as g

filepath = '/Users/chrisbert/Documents/Git/GDPS/sample_data/DGS/sample_trajectory.txt'

traj_test = g.Gravity()
traj_test.import_trajectory(filepath)

print traj_test.trajectory
