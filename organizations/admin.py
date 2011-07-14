from django.contrib.gis import admin as gis_admin
from django.contrib import admin

from models import GiseduOrgType, GiseduOrgAddress, GiseduOrg

class GiseduOrgTypeAdmin(admin.ModelAdmin):
    list_display = ('org_type_name',)
    search_fields = ['org_type_name']
    exclude = ['gid']

class GiseduOrgAddressAdmin(admin.ModelAdmin):
    list_display = ('address_line_one', 'city', 'state', 'zip10')
    search_fields = ['address_line_one', 'city', 'state', 'zip10']
    exclude = ['gid']

    list_filter = ('state',)

class GiseduOrgAdmin(gis_admin.GeoModelAdmin):
    list_display = ('org_nm', 'org_type', 'building_irn', 'irn')
    search_fields = ['org_nm', 'building_irn']
    exclude = ['gid', 'org_key']

    list_filter = ('org_type', )

admin.site.register(GiseduOrgType, GiseduOrgTypeAdmin)
admin.site.register(GiseduOrgAddress, GiseduOrgAddressAdmin)
admin.site.register(GiseduOrg, GiseduOrgAdmin)