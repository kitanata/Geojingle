from django.contrib.gis import admin
from models import OhioCounties, OhioSchoolDistricts, OhioLibraries

class OhioCountiesAdmin(admin.GeoModelAdmin):
    list_display = ('name', 'cnty_num', 'cnty_code')
    search_fields = ['name']
    exclude = ['gid', 'objectid', 'shape_area', 'shape_len']

class OhioSchoolDistrictsAdmin(admin.GeoModelAdmin):
    list_display = ('name', 'lea_id', 'beg_grade', 'end_grade', 'taxid', 'district_irn')
    search_fields = ['name', 'district_irn']
    exclude = ['gid', 'objectid', 'id', 'shape_leng', 'area', 'len', 'pct_chg', 'shape_area', 'shape_len']
    
admin.site.register(OhioCounties, OhioCountiesAdmin)
admin.site.register(OhioSchoolDistricts, OhioSchoolDistrictsAdmin)
admin.site.register(OhioLibraries, admin.GeoModelAdmin)