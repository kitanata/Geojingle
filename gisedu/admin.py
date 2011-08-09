from django.contrib.gis import admin
from models import OhioCounties, OhioSchoolDistricts, OhioLibraries, \
    OhioHouseDistricts, OhioSenateDistricts

class OhioCountiesAdmin(admin.GeoModelAdmin):
    list_display = ('name', 'cnty_num', 'cnty_code')
    search_fields = ['name']
    exclude = ['gid', 'objectid', 'shape_area', 'shape_len']

class OhioSchoolDistrictsAdmin(admin.GeoModelAdmin):
    list_display = ('name', 'lea_id', 'beg_grade', 'end_grade', 'taxid', 'district_irn', 'comcast_coverage', 'has_atomic_learning')
    search_fields = ['name', 'district_irn']
    exclude = ['gid', 'id']

    list_filter = ('comcast_coverage', 'has_atomic_learning')

class OhioHouseDistrictsAdmin(admin.GeoModelAdmin):
    exclude = ['gid']

class OhioSenateDistrictsAdmin(admin.GeoModelAdmin):
    exclude = ['gid']
    
admin.site.register(OhioCounties, OhioCountiesAdmin)
admin.site.register(OhioSchoolDistricts, OhioSchoolDistrictsAdmin)
admin.site.register(OhioLibraries, admin.GeoModelAdmin)
admin.site.register(OhioHouseDistricts, OhioHouseDistrictsAdmin)
admin.site.register(OhioSenateDistricts, OhioSenateDistrictsAdmin)