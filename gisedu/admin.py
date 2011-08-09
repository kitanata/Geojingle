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
    actions = ['atomic_learning_true', 'atomic_learning_false']

    def atomic_learning_true(self, request, queryset):
        rows_updated = queryset.update(has_atomic_learning=True)
        if rows_updated == 1:
            message_bit = "1 School District was"
        else:
            message_bit = "%s School Districts were" % rows_updated
        self.message_user(request, "%s successfully marked as participants in atomic learning." % message_bit)

    def atomic_learning_false(self, request, queryset):
        rows_updated = queryset.update(has_atomic_learning=False)
        if rows_updated == 1:
            message_bit = "1 School District was"
        else:
            message_bit = "%s School Districts were" % rows_updated
        self.message_user(request, "%s successfully un-marked as participants in atomic learning." % message_bit)

    atomic_learning_true.short_description = "Mark selected School Districts as participants in atomic learning."
    atomic_learning_false.short_description = "Un-mark selected School Districts as participants in atomic learning."

class OhioHouseDistrictsAdmin(admin.GeoModelAdmin):
    exclude = ['gid']

class OhioSenateDistrictsAdmin(admin.GeoModelAdmin):
    exclude = ['gid']
    
admin.site.register(OhioCounties, OhioCountiesAdmin)
admin.site.register(OhioSchoolDistricts, OhioSchoolDistrictsAdmin)
admin.site.register(OhioLibraries, admin.GeoModelAdmin)
admin.site.register(OhioHouseDistricts, OhioHouseDistrictsAdmin)
admin.site.register(OhioSenateDistricts, OhioSenateDistrictsAdmin)