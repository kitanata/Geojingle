from django.contrib.gis import admin as gis_admin
from django.contrib import admin
from jvsd.models import GiseduJointVocationalSchoolDistrict

class GiseduJointVocationalSchoolDistrictAdmin(gis_admin.GeoModelAdmin):
    list_display = ('jvsd_name', 'building_irn', 'irn', 'has_atomic_learning')
    search_fields = ['jvsd_name', 'building_irn']
    exclude = ['gid', 'org_key']

    list_filter = ('has_atomic_learning', )

admin.site.register(GiseduJointVocationalSchoolDistrict, GiseduJointVocationalSchoolDistrictAdmin)