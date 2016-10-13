function filled = FillGapsOnly(datin)

prep = FIRFilterPrepRC(datin,0,0);
filled = prep.data;