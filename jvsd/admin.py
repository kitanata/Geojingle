from django.contrib.gis import admin as gis_admin
from django.contrib import admin
from jvsd.models import GiseduJointVocationalSchoolDistrict

class GiseduJointVocationalSchoolDistrictAdmin(gis_admin.GeoModelAdmin):
    list_display = ('jvsd_name', 'building_irn', 'irn', 'has_atomic_learning')
    search_fields = ['jvsd_name', 'building_irn']
    exclude = ['gid', 'org_key']

    list_filter = ('has_atomic_learning', )
    actions = ['atomic_learning_true', 'atomic_learning_false']

    def atomic_learning_true(self, request, queryset):
        rows_updated = queryset.update(has_atomic_learning=True)
        if rows_updated == 1:
            message_bit = "1 JVSD was"
        else:
            message_bit = "%s JVSDs were" % rows_updated
        self.message_user(request, "%s successfully marked as participants in atomic learning." % message_bit)

    def atomic_learning_false(self, request, queryset):
        rows_updated = queryset.update(has_atomic_learning=False)
        if rows_updated == 1:
            message_bit = "1 JVSD was"
        else:
            message_bit = "%s JVSDs were" % rows_updated
        self.message_user(request, "%s successfully un-marked as participants in atomic learning." % message_bit)

    atomic_learning_true.short_description = "Mark selected JVSDs as participants in atomic learning."
    atomic_learning_false.short_description = "Un-mark selected JVSDs as participants in atomic learning."

admin.site.register(GiseduJointVocationalSchoolDistrict, GiseduJointVocationalSchoolDistrictAdmin)