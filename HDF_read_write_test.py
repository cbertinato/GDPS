import gravity as g

gravity_path = '/Users/chrisbert/Documents/Git/GDPS/sample_data/DGS/dgs_test_data.dat'
trajectory_path = '/Users/chrisbert/Documents/Git/GDPS/sample_data/AN03_F1007_20161130_iMAR_PrelimFinal_STD.txt'

print 'HDF_read_write_test : begin test'

data = g.Gravity()
data.import_DGS_format_data(gravity_path)
data.store_gravity()

data.gravity = None
assert data.gravity is None, "data.gravity is not None"

data.attributes = None
assert data.attributes is None, "data.attributes is not None"

data.recover_gravity()
assert data.gravity is not None, "data.gravity is None"
assert data.attributes is not None, "data.attributes is None"

assert data.gravity.shape == (401919,10), "data.gravity is not the correct shape"

print 'HDF_read_write_test : end test'
