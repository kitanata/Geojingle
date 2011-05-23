from django.contrib.gis import admin
from models import OhioCounties, OhioDistricts, OhioLibraries, OhioEduOrgs

admin.site.register(OhioCounties, admin.GeoModelAdmin)
admin.site.register(OhioDistricts, admin.GeoModelAdmin)
admin.site.register(OhioLibraries, admin.GeoModelAdmin)
admin.site.register(OhioEduOrgs, admin.GeoModelAdmin)