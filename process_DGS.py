from gravity import Gravity

data_path = '/Users/chrisbert/Documents/Projects/Dev_Gravity_processing/sample_data/DGS/OIB-P3_2017_F2001/'
gravity_path = data_path + 'OIB-P3_20170322_F2001_DGS_100600.dat'
trajectory_path = data_path + 'OIB-P3_20170322_F2001_DGS-INS_RAPID_For_Chris.txt'

data = Gravity()
print 'Importing gravity data.'
data.import_DGS_format_data(gravity_path)

print 'Importing trajectory data.'
data.import_trajectory(trajectory_path, interval=.1)

print 'Joining trajectory with gravity data.'
data.join_grav_traj()

begin_pre_static = '2017-03-22 10:27:00'
end_pre_static = '2017-03-22 10:52:00'
begin_post_static = '2017-03-22 19:06:00'
end_post_static = '2017-03-22 19:49:00'

data.set_pre_static_reading(data.compute_static(begin_pre_static,
                                                end_pre_static))
data.set_post_static_reading(data.compute_static(begin_post_static,
                                                 end_post_static))

tie_reading = 982889.68
data.set_tie_reading(tie_reading)

data.compute_corrections()

begin_line = 1490179239
end_line = 1490180760

# if this is done before the corrections, then the dataframe does not included the additional fields
data.add_line('L0', begin_line, end_line, format='unix')
data.align_signals('L0')
data.apply_corrections('L0')

# print data.lines['L0']
