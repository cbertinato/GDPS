import gravity as g

filepath = '/Users/chrisbert/Documents/Git/GDPS/sample_data/DGS/dgs_test_data.dat'

dgs_data = g.Gravity()
dgs_data.import_DGS_format_data(filepath, interval=0.005, interp=True)

print dgs_data.gravity
