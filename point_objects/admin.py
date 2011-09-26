from django.contrib.gis import admin as gis_admin
from django.contrib import admin
from django.forms.widgets import CheckboxSelectMultiple
from django.db.models import ManyToManyField
from point_objects.models import GiseduPointItemAddress, GiseduPointItem, OhioLibraries, GiseduPointItemBooleanFields, GiseduPointItemIntegerFields, GiseduPointItemStringFields

class GiseduPointItemAddressAdmin(gis_admin.GeoModelAdmin):
    list_display = ('address_line_one', 'city', 'state', 'zip10')
    search_fields = ['address_line_one', 'city', 'state', 'zip10']
    exclude = ['gid']

    list_filter = ('state',)

class GiseduPointItemBooleanFieldAdmin(gis_admin.GeoModelAdmin):
    list_display = ('point', 'point__filter', 'attribute', 'value')
    list_filter = ('point__filter__filter_name', 'attribute', 'value')
    
    search_fields = ['point__item_name']

    actions = ['set_field_true', 'set_field_false']

    def set_field_true(self, request, queryset):
        rows_updated = queryset.update(has_atomic_learning=True)
        if rows_updated == 1:
            message_bit = "1 Item was"
        else:
            message_bit = "%s Items were" % rows_updated
        self.message_user(request, "%s successfully marked. (Set to True)" % message_bit)

    def set_field_false(self, request, queryset):
        rows_updated = queryset.update(has_atomic_learning=False)
        if rows_updated == 1:
            message_bit = "1 Item was"
        else:
            message_bit = "%s Items were" % rows_updated
        self.message_user(request, "%s successfully un-marked. (Set to False)" % message_bit)

    set_field_true.short_description = "Mark selected Items. (Set to True)"
    set_field_false.short_description = "Un-mark selected Items. (Set to False)"

class GiseduPointItemBooleanFieldsInline(admin.TabularInline):
    model = GiseduPointItemBooleanFields

class GiseduPointItemIntegerFieldAdmin(gis_admin.GeoModelAdmin):
    list_display = ('point', 'point__filter', 'attribute', 'value')
    list_filter = ('point__filter__filter_name', 'attribute', 'value')

    search_fields = ['point__item_name']

class GiseduPointItemIntegerFieldsInline(admin.TabularInline):
    model = GiseduPointItemIntegerFields

class GiseduPointItemStringFieldAdmin(gis_admin.GeoModelAdmin):
    list_display = ('point', 'point__filter', 'attribute', 'option')
    list_filter = ('point__filter__filter_name', 'attribute', 'option')

    search_fields = ['point__item_name']

class GiseduPointItemStringFieldsInline(admin.TabularInline):
    model = GiseduPointItemStringFields

class GiseduPointItemAdmin(gis_admin.GeoModelAdmin):
    list_display = ('item_name', 'filter', 'item_type')
    list_filter = ('filter__filter_name', 'item_type')

    inlines = [GiseduPointItemBooleanFieldsInline,
               GiseduPointItemIntegerFieldsInline,
               GiseduPointItemStringFieldsInline]

admin.site.register(GiseduPointItemAddress, GiseduPointItemAddressAdmin)
admin.site.register(GiseduPointItem, GiseduPointItemAdmin)
admin.site.register(GiseduPointItemBooleanFields, GiseduPointItemBooleanFieldAdmin)
admin.site.register(GiseduPointItemIntegerFields, GiseduPointItemIntegerFieldAdmin)
admin.site.register(GiseduPointItemStringFields, GiseduPointItemStringFieldAdmin)
admin.site.register(OhioLibraries, gis_admin.GeoModelAdmin)

#class GiseduOrgTypeAdmin(admin.ModelAdmin):
#    list_display = ('org_type_name',)
#    search_fields = ['org_type_name']
#    exclude = ['gid']
#
#class GiseduOrgAddressAdmin(admin.ModelAdmin):
#    list_display = ('address_line_one', 'city', 'state', 'zip10')
#    search_fields = ['address_line_one', 'city', 'state', 'zip10']
#    exclude = ['gid']
#
#    list_filter = ('state',)
#
#class GiseduOrgAdmin(gis_admin.GeoModelAdmin):
#    list_display = ('org_nm', 'org_type', 'building_irn', 'irn')
#    search_fields = ['org_nm', 'building_irn']
#    exclude = ['gid', 'org_key']
#
#    list_filter = ('org_type', )
#
#class SchoolAreaClassificationAdmin(admin.ModelAdmin):
#    list_display = ('classification',)
#    search_fields = ['classification']
#    exclude = ['gid']
#
#class SchoolItcAdmin(admin.ModelAdmin):
#    list_display = ('itc',)
#    search_fields = ['itc']
#    exclude = ['gid']
#
#class GradeAdmin(admin.ModelAdmin):
#    list_display = ('grade_name', 'grade_num',)
#    search_fields = ['grade_name']
#    exclude = ['gid']
#
#class GiseduSchoolTypeAdmin(admin.ModelAdmin):
#    list_display = ('school_type',)
#    search_fields = ['school_type']
#    exclude = ['gid']
#
#class GiseduSchoolInfoAdmin(admin.ModelAdmin):
#    list_display = ('dirn', 'mbit', 'area_class', 'itc')
#    search_fields = ['dirn']
#    exclude = ['gid', 'fte', 'adm']
#
#    list_filter = ('mbit', 'area_class', 'itc')
#
#class GiseduSchoolAdmin(gis_admin.GeoModelAdmin):
#    list_display = ('school_name', 'building_info', 'school_type')
#    search_fields = ['school_name', 'building_info__dirn']
#    exclude = ['gid']
#
#    formfield_overrides = {
#        ManyToManyField: {'widget': CheckboxSelectMultiple},
#    }
#
#    list_filter = ('school_type', 'grades')
#
#class GiseduJointVocationalSchoolDistrictAdmin(gis_admin.GeoModelAdmin):
#    list_display = ('jvsd_name', 'building_irn', 'irn', 'has_atomic_learning')
#    search_fields = ['jvsd_name', 'building_irn']
#    exclude = ['gid', 'org_key']
#
#    list_filter = ('has_atomic_learning', )
#    actions = ['atomic_learning_true', 'atomic_learning_false']
#
#    def atomic_learning_true(self, request, queryset):
#        rows_updated = queryset.update(has_atomic_learning=True)
#        if rows_updated == 1:
#            message_bit = "1 JVSD was"
#        else:
#            message_bit = "%s JVSDs were" % rows_updated
#        self.message_user(request, "%s successfully marked as participants in atomic learning." % message_bit)
#
#    def atomic_learning_false(self, request, queryset):
#        rows_updated = queryset.update(has_atomic_learning=False)
#        if rows_updated == 1:
#            message_bit = "1 JVSD was"
#        else:
#            message_bit = "%s JVSDs were" % rows_updated
#        self.message_user(request, "%s successfully un-marked as participants in atomic learning." % message_bit)
#
#    atomic_learning_true.short_description = "Mark selected JVSDs as participants in atomic learning."
#    atomic_learning_false.short_description = "Un-mark selected JVSDs as participants in atomic learning."