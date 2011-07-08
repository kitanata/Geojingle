import psycopg2
import string

conn = psycopg2.connect(database="gis_demo", user="postgres", password="9Aakvc82!", host="127.0.0.1")

cur = conn.cursor()
insert_cur = conn.cursor()

cur.execute("SELECT * FROM building_info;")

curEntry = cur.fetchone()

grade_id_map = {'K': 2, 'P': 1, 'PS': 1, 'SN': 15, 'UNG': 17, 
                'H': 18, 'UN': 16, 'D': 19, 'S': 20 }

while curEntry != None:
    curEntryGid = curEntry[0]
    curEntryGrades = curEntry[4]
    
    #first split out spaces
    if curEntryGrades:
        curEntryGrades = string.split(curEntry[4], ' ')
        
        #if len(curEntryGrades) > 1:
        #    print curEntryGrades
            
        for grade in curEntryGrades:
            if '-' in grade:
                gradeRange = string.split(grade, '-')
                
                if gradeRange[0].isdigit() and gradeRange[1].isdigit():
                    for i in range(int(gradeRange[0]), int(gradeRange[1])):
                        insert_cur.execute("INSERT INTO ohio_school_grade (school_id, grade_id) VALUES (%s, %s);", (curEntryGid, i + 2))
                        
                elif gradeRange[0] == 'K' and gradeRange[1].isdigit():
                    insert_cur.execute("INSERT INTO ohio_school_grade (school_id, grade_id) VALUES (%s, %s);", (curEntryGid, 2)) #Kindergarten
                    
                    for i in range(1, int(gradeRange[1])):
                        insert_cur.execute("INSERT INTO ohio_school_grade (school_id, grade_id) VALUES (%s, %s);", (curEntryGid, i + 2))
                else:
                    print "Problem?"
            else:
                gradeId = None
                
                if grade.isdigit():
                    gradeId = int(grade) + 2
                elif grade in grade_id_map:
                    gradeId = grade_id_map[grade]
                else:
                    print "LOST ONE " + grade + " " + str(len(grade))
                    
                if gradeId != None:
                    insert_cur.execute("INSERT INTO ohio_school_grade (school_id, grade_id) VALUES (%s, %s);", (curEntryGid, gradeId))
            
    
    curEntry = cur.fetchone()

conn.commit()
insert_cur.close()
cur.close()
conn.close()
