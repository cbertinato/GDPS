def convert_to_utc(sow, **kwargs):
    if 'week' in kwargs:
        dt = datetime.datetime(1980,1,6) + datetime.timedelta(weeks=kwargs['week'])
    elif 'date' in kwargs:
        if isinstance(kwargs['date'], basestring):
            d = kwargs['date'].split('-')
            if len(d) != 3:
                d = kwargs['date'].split('/')
                if len(d) != 3:
                    print 'date not correctly formatted. expect MM-DD-YYYY or MM/DD/YYYY'
                    return

            dt = datetime.datetime(d[2], d[0], d[1])
    else:
        print 'must specify week number or date'
        return

    ls_table = [(1980,1,1,1981,7,1),\
              (1981,7,1,1982,7,1),\
              (1982,7,1,1983,7,1),\
              (1983,7,1,1985,7,1),\
              (1985,7,1,1988,1,1),\
              (1988,1,1,1990,1,1),\
              (1990,1,1,1991,1,1),\
              (1991,1,1,1992,7,1),\
              (1992,7,1,1993,7,1),\
              (1993,7,1,1994,7,1),\
              (1994,7,1,1996,1,1),\
              (1996,1,1,1997,7,1),\
              (1997,7,1,1999,1,1),\
              (1999,1,1,2006,1,1),\
              (2006,1,1,2009,1,1),\
              (2009,1,1,2012,7,1),\
              (2012,7,1,2015,7,1),\
              (2015,7,1,2017,1,1)]

    leap_seconds = 0
    for entry in ls_table:
      if dt >= datetime.datetime(entry[0],entry[1],entry[2]) and dt < datetime.datetime(entry[3],entry[4],entry[5]):
          break
      else:
          leap_seconds = leap_seconds + 1

    sow = sow - leap_seconds
    dt = dt + datetime.timedelta(seconds=sow)

    return dt
