import gravity as g

filepath = '/Users/chrisbert/Documents/Git/GDPS/sample_data/ZLS'

zls_data = g.Gravity()
zls_data.import_ZLS_format_data(filepath)

print zls_data.df
