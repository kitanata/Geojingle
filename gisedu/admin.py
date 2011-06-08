from django.contrib.gis import admin
from models import OhioCounties, OhioSchoolDistricts, OhioLibraries, GiseduOrg

admin.site.register(OhioCounties, admin.GeoModelAdmin)
admin.site.register(OhioSchoolDistricts, admin.GeoModelAdmin)
admin.site.register(OhioLibraries, admin.GeoModelAdmin)
admin.site.register(GiseduOrg, admin.GeoModelAdmin)