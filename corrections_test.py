import gravity as g

gravity_path = '/Users/chrisbert/Documents/Git/GDPS/sample_data/DGS/dgs_test_data.dat'
trajectory_path = '/Users/chrisbert/Documents/Git/GDPS/sample_data/AN03_F1007_20161130_iMAR_PrelimFinal_STD.txt'

data = g.Gravity()
print 'Importing gravity data.'
data.import_DGS_format_data(gravity_path)

print 'Importing trajectory data.'
data.import_trajectory(trajectory_path, interval=.1)

print 'Joining trajectory with gravity data.'
data.join_grav_traj()

print 'Computing Eotvos correction.'
data.eotvos_correction()
print data.gravity['Eotvos correction']

print 'Computing latitude correction.'
data.latitude_correction()
print data.gravity['Latitude correction']

print 'Computing free air correction.'
data.free_air_correction()
print data.gravity['Free air correction']

print 'Computing vertical acceleration correction.'
data.vert_accel_correction()
print data.gravity['Vert accel correction']
