from __future__ import print_function
import scard_parser, sqlite3, file_struct, time
import utils

filename = "scard.txt"
scard_fields = scard_parser.scard_parser(filename)
scard_fields.data['group_name'] = scard_fields.data.pop('group') #'group' is a protected word in SQL
scard_fields.data['genExecutable'] = file_struct.genExecutable.get(scard_fields.data.get('generator'))
scard_fields.data['genOutput'] = file_struct.genOutput.get(scard_fields.data.get('generator'))

UID = "robertEJ" #This is more or less a placeholder, currently

def dynamic_data_entry(UID,scard_dict):
    conn = sqlite3.connect('CLAS12_OCRDB.db')
    c = conn.cursor()
    unixtimestamp = int(time.time()) # Can modify this if need 10ths of seconds or more resolution
    c.execute("INSERT INTO Scards(UserID, timestamp) VALUES (?,?)",(UID,unixtimestamp))
    for key in scard_dict:
      strn = "UPDATE Scards SET {} = '{}' WHERE timestamp = {};".format(key,scard_dict[key],unixtimestamp)
      c.execute(strn)
    conn.commit()
    print("Record added to DB from Scard")
    c.close()
    conn.close()

dynamic_data_entry(UID,scard_fields.data)

"""
filename = "scard.txt"
scard_fields = scard_parser.scard_parser(filename)
scard_fields.data['group_name'] = scard_fields.data.pop('group') #'group' is a protected word in SQL
scard_fields.data['genExecutable'] = file_struct.genExecutable.get(scard_fields.data.get('generator'))
scard_fields.data['genOutput'] = file_struct.genOutput.get(scard_fields.data.get('generator'))

DBname = file_struct.DBname

def dynamic_data_entry(DBname,tablename,scard_dict):
    UID = "robert" #This is more or less a placeholder, currently
    unixtimestamp = int(time.time()) # Can modify this if need 10ths of seconds or more resolution
    unixtimestamp = 9999
    strn = "INSERT INTO {} ({}, {}) VALUES ('{}',{})".format(tablename,'UserID','timestamp',UID,unixtimestamp)
    utils.sql3_exec(DBname,strn)
    for key in scard_dict:
      strn = "UPDATE Scards SET {} = '{}' WHERE timestamp = {};".format(key,scard_dict[key],unixtimestamp)
      utils.sql3_exec(DBname,strn)
    print("Record added to DB from Scard")

dynamic_data_entry(DBname,'Scards',scard_fields.data)
"""
